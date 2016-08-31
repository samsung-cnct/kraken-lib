# -*- coding: utf-8 -*-
"""
Update Route53 Records based on Autoscaling event notifications sent via SNS.
To configure your domain you need to specify:
1) Tags per Auto Scaling Group (ASG) :
   'srvconfig' such as <Route53Zone:domain.com:prefix:SRV Client:SRV Server:SrvClientPort:SrvServerPort>.
A Route53 entry will be created with the AWS generated EC2 Instance Id .e.g i-abc123456.domain.com. 

When the server is terminated it will be removed from the Route53 zone you specified in the ASG tag.
"""

import json

from collections import namedtuple
from itertools import chain

import boto3


DomainEntry = namedtuple('DomainEntry', ['zone', 'name', 'prefix', 'srvclient', 'srvserver', 'srvclientport', 'srvserverport'])


class Error(Exception):
  pass


class UpdaterClient(object):

  srv_config_tag = 'srvconfig'
  ttl = 300

  def __init__(self, event):
    self._boto = {}
    self.event = event
    self.record = event['Records'][0]
    self.region = self.record['EventSubscriptionArn'].split(':')[3]
    self.message = json.loads(self.record['Sns']['Message'])
    self.instance_id = self.message['EC2InstanceId']
    
    self.instance = self.boto('ec2').describe_instances(
      InstanceIds=[self.instance_id])['Reservations'][0]['Instances'][0]
    
    self.autoscaling_group_name = self.message['AutoScalingGroupName']
    self.event_type = self.message['Event']
    
    self.asg = self.boto('autoscaling').describe_auto_scaling_groups(
      AutoScalingGroupNames=[self.autoscaling_group_name]
    )['AutoScalingGroups'][0]

    self.comment = 'Automatically updated Route53 Record'
    self.route53 = self.boto('route53')

  def boto(self, resource):
    if resource not in self._boto:
      self._boto[resource] = boto3.client(resource, region_name=self.region)
    return self._boto[resource]

  def domains(self):
    tags = [x for x in self.asg['Tags'] if x['Key'] == self.srv_config_tag]

    if len(tags) != 1:
      raise Error(
        'You must specify the {} tag in your autoscaling group {}'.format(
          self.srv_config_tag, self.autoscaling_group_name
        )
      )

    for entry in tags[0]['Value'].split(','):
      domain = DomainEntry(*entry.split(':'))
      yield domain


  def query_existing_a_record(self, domain):
    a_record_name = '{}.'.format(self.instance_id)
    
    if domain.prefix:
      a_record_name = '{}{}.'.format(
          a_record_name, 
          domain.prefix
        )

    a_record_name = '{}{}.'.format(
      a_record_name, 
      domain.name
    )

    record_sets = self.route53.list_resource_record_sets(
      HostedZoneId=domain.zone
    )['ResourceRecordSets']
    a_record = [rc for rc in record_sets if rc['Name'] == a_record_name and rc['Type'] == 'A']
    
    ip_address = ''
    if a_record:
      a_record = a_record[0]
      if a_record['ResourceRecords']:
        ip_address = a_record['ResourceRecords'][0]['Value']

    return ip_address

  def update_records(self, action):

    print('ASG: {}'.format(self.asg))

    for domain in self.domains():
      zone = self.route53.get_hosted_zone(Id=domain.zone) 
      
      if action == 'DELETE':
        ip_address = self.query_existing_a_record(domain)
      elif action == 'UPSERT':
        if zone['HostedZone']['Config']['PrivateZone']:
          ip_address = self.instance['NetworkInterfaces'][0]['PrivateIpAddress']
        else:
          ip_address = self.instance['PublicIp']
      
    
      a_record_name = '{}.'.format(self.instance_id)
      a_record_value = ip_address

      srv_client_record_name = '{}'.format(domain.srvclient)
      srv_client_record_value = '0 0 {} {}'.format(domain.srvclientport, self.instance_id)

      srv_server_record_name = '{}'.format(domain.srvserver)
      srv_server_record_value = '0 0 {} {}'.format(domain.srvserverport, self.instance_id)

      roundrobin_record_name = ''
      roundrobin_record_value = ip_address
      
      if domain.prefix:
        a_record_name = '{}{}.'.format(
          a_record_name, 
          domain.prefix
        )

        srv_client_record_name = '{}.{}'.format(
          srv_client_record_name, 
          domain.prefix
        )
        srv_client_record_value = '{}.{}'.format(
          srv_client_record_value, 
          domain.prefix
        )

        srv_server_record_name = '{}.{}'.format(
          srv_server_record_name, 
          domain.prefix
        )
        srv_server_record_value = '{}.{}'.format(
          srv_server_record_value, 
          domain.prefix
        )

        roundrobin_record_name = '{}.{}.'.format(
          domain.prefix, 
          domain.name
        )
      
      a_record_name = '{}{}.'.format(
        a_record_name, 
        domain.name
      )

      srv_client_record_name = '{}.{}.'.format(
        srv_client_record_name, 
        domain.name
      )
      srv_client_record_value = '{}.{}.'.format(
        srv_client_record_value, 
        domain.name
      )

      srv_server_record_name = '{}.{}.'.format(
        srv_server_record_name, 
        domain.name
      )
      srv_server_record_value = '{}.{}.'.format(
        srv_server_record_value, 
        domain.name
      )

      record_sets = self.route53.list_resource_record_sets(
        HostedZoneId=domain.zone
      )['ResourceRecordSets']

      records_to_process = [ 
        {'Name': a_record_name, 'Value': a_record_value, 'Type': 'A', 'Multiline': False}, 
        {'Name': srv_client_record_name, 'Value': srv_client_record_value, 'Type': 'SRV', 'Multiline': True}, 
        {'Name': srv_server_record_name, 'Value': srv_server_record_value, 'Type': 'SRV', 'Multiline': True}
      ]
      if roundrobin_record_name:
        records_to_process.append(
          {
            'Name': roundrobin_record_name, 
            'Value': roundrobin_record_value, 
            'Type': 'A', 
            'Multiline': True
          }
        )

      upsert_recordset = []
      delete_recordset = []

      for item in records_to_process:
        record_to_update = {
          'Name': item['Name'],
          'Type': item['Type'],
          'TTL': self.ttl,
          'ResourceRecords': [{ 'Value': item['Value'] }]
        }          

        print('{}-ing item {} in record {}'.format(action, item, record_to_update))

        # remove the line record 
        if action == 'DELETE':
          delete_recordset.append(record_to_update)
        elif action == 'UPSERT':
          upsert_recordset.append(record_to_update)
        else:
          raise Error('Unknown action {}'.format(action))

      print('delete recordset: {}  upser recordset: {}'.format(delete_recordset, upsert_recordset))
      newUpdate = {
        'HostedZoneId': domain.zone,
        'ChangeBatch': {
          'Comment': self.comment,
          'Changes': []
        }
      } 

      for item in upsert_recordset:
        newUpdate['ChangeBatch']['Changes'].append(
          {
            'Action': 'UPSERT',
            'ResourceRecordSet': item
          }
        )

      for item in delete_recordset:
        newUpdate['ChangeBatch']['Changes'].append(
          {
            'Action': 'DELETE',
            'ResourceRecordSet': item
          }
        )

      if newUpdate['ChangeBatch']['Changes']:
        print('Route 53 update: {}'.format(newUpdate))
        self.route53.change_resource_record_sets(**newUpdate)
      else:
        raise Error('Empty change set!')

def handler(event, context):

  print('event: {}'.format(event))
  client = UpdaterClient(event)

  if client.event_type == 'autoscaling:EC2_INSTANCE_LAUNCH':
    client.update_records(action='UPSERT')

  elif client.event_type == 'autoscaling:EC2_INSTANCE_TERMINATE':
    client.update_records(action='DELETE')

  else:
    raise Error('Unknown event type {}'.format(client.event_type))


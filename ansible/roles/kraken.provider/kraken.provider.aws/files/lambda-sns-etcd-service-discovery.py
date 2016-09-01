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

  def get_a_record_name(self, domain):
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

    return a_record_name

  def get_srv_record_name(self, domain, isclient):
    if isclient:
      srv_record_name = '{}'.format(domain.srvclient)
    else:
      srv_record_name = '{}'.format(domain.srvserver)

    srv_record_name = '{}.{}.{}.'.format(
      srv_record_name, 
      domain.prefix,
      domain.name
    )

    return srv_record_name

  def get_roundrobin_record_name(self, domain):

    rr_record_name = '{}.{}.'.format(
      domain.prefix, 
      domain.name
    )

    return rr_record_name

  def get_a_record(self, domain):
    record_sets = self.route53.list_resource_record_sets(
      HostedZoneId=domain.zone
    )['ResourceRecordSets']
    
    a_record = [rc for rc in record_sets if rc['Name'] == self.get_a_record_name(domain) and rc['Type'] == 'A']
    if a_record:
      return a_record[0] 
    else:
      return None

  def get_srv_record(self, domain, isclient):

    record_sets = self.route53.list_resource_record_sets(
      HostedZoneId=domain.zone
    )['ResourceRecordSets']
    
    srv_record = [rc for rc in record_sets if rc['Name'] == self.get_srv_record_name(domain, isclient) and rc['Type'] == 'SRV']
    if srv_record:
      return srv_record[0] 
    else:
      return None

  def get_roundrobin_record(self, domain):
    record_sets = self.route53.list_resource_record_sets(
      HostedZoneId=domain.zone
    )['ResourceRecordSets']
    
    rr_record = [rc for rc in record_sets if rc['Name'] == self.get_roundrobin_record_name(domain) and rc['Type'] == 'A']
    if rr_record:
      return rr_record[0] 
    else:
      return None

  def update_records(self, action):

    for domain in self.domains():

      # build up a DNS update request
      dns_update = {
        'HostedZoneId': domain.zone,
        'ChangeBatch': {
          'Comment': self.comment,
          'Changes': []
        }
      } 

      # first delete requests for all current records if thoes exist
      records_to_delete = [
        self.get_a_record(domain),
        self.get_srv_record(domain, True),
        self.get_srv_record(domain, False),
        self.get_roundrobin_record(domain)
      ]
      
      for deletion in records_to_delete:
        if deletion:
          dns_update['ChangeBatch']['Changes'].append(
            {
              'Action': 'DELETE',
              'ResourceRecordSet': deletion
            }
          )

      # Now collect all asg instances
      aws_instances = [
        aws_instance for aws_instance in self.asg['Instances'] 
          if aws_instance['LifecycleState'] == 'InService'
      ]

      aws_instance_ids = [aws_instance['InstanceId'] for aws_instance in aws_instances]

      # build up upsert requests
      self.boto('ec2').describe_instances(InstanceIds=[self.instance_id])['Reservations'][0]['Instances'][0]

      srv_client_record_values = [
        '0 0 {} {}.{}.{}.'.format(domain.srvclientport, instance['InstanceId'], domain.prefix, domain.name) for instance in aws_instances
      ]

      srv_server_record_values = [
        '0 0 {} {}.{}.{}.'.format(domain.srvserverport, instance['InstanceId'], domain.prefix, domain.name) for instance in aws_instances
      ]

      roundrobin_record_values = [
        instance['NetworkInterfaces'][0]['PrivateIpAddress'] for instance in self.boto('ec2').describe_instances(InstanceIds=aws_instance_ids)['Reservations'][0]['Instances'] 
      ]

      # on DELETE, don't try to re-create the A record 
      if action == 'DELETE':
        records_to_upsert = [  
          {'Name': self.get_srv_record_name(domain, True), 'Value': srv_client_record_values, 'Type': 'SRV'}, 
          {'Name': self.get_srv_record_name(domain, False), 'Value': srv_server_record_values, 'Type': 'SRV'},
          {'Name': self.get_roundrobin_record_name(domain), 'Value': roundrobin_record_values, 'Type': 'A'}
        ]
      else:
        a_record_value = self.instance['NetworkInterfaces'][0]['PrivateIpAddress']
        records_to_upsert = [ 
          {'Name': self.get_a_record_name(domain), 'Value': [a_record_value], 'Type': 'A'}, 
          {'Name': self.get_srv_record_name(domain, True), 'Value': srv_client_record_values, 'Type': 'SRV'}, 
          {'Name': self.get_srv_record_name(domain, False), 'Value': srv_server_record_values, 'Type': 'SRV'},
          {'Name': self.get_roundrobin_record_name(domain), 'Value': roundrobin_record_values, 'Type': 'A'}
        ]

      # add DNS requests
      for upsert in records_to_upsert:

        record_to_upsert = {
          'Name': upsert['Name'],
          'Type': upsert['Type'],
          'TTL': self.ttl,
          'ResourceRecords': [{'Value':val} for val in upsert['Value']]
        } 

        if record_to_upsert['ResourceRecords']:
          dns_update['ChangeBatch']['Changes'].append(
            {
              'Action': 'UPSERT',
              'ResourceRecordSet': record_to_upsert
            }
          )

      print('updte: {}'.format(dns_update))
      self.route53.change_resource_record_sets(**dns_update)

def handler(event, context):
  client = UpdaterClient(event)

  if client.event_type == 'autoscaling:EC2_INSTANCE_LAUNCH':
    client.update_records(action='UPSERT')

  elif client.event_type == 'autoscaling:EC2_INSTANCE_TERMINATE':
    client.update_records(action='DELETE')

  else:
    raise Error('Unknown event type {}'.format(client.event_type))


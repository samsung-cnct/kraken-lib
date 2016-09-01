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

    self.autoscaling_group_name = self.message['AutoScalingGroupName']
    self.event_type = self.message['Event']
    self.comment = 'Automatically updated Route53 Record'
    self.route53 = self.boto('route53')

    self.asg = self.boto('autoscaling').describe_auto_scaling_groups(
      AutoScalingGroupNames=[self.autoscaling_group_name]
    )['AutoScalingGroups'][0]
    self.aws_instance_ids = [
      aws_instance['InstanceId'] for aws_instance in self.asg['Instances'] 
        if aws_instance['LifecycleState'] == 'InService'
    ]

    self.instance_id = self.message['EC2InstanceId']
    
    if self.aws_instance_ids:
      self.raw_instance_data = self.boto('ec2').describe_instances(InstanceIds=self.aws_instance_ids)
    else:
      self.raw_instance_data = {'Reservations': []}

    self.aws_instances = []
    self.aws_instance_ips = []
    self.instance = {}
    for reservation in self.raw_instance_data['Reservations']:
      for instance in reservation['Instances']:
        self.aws_instances.append(instance)
        if 'PrivateIpAddress' in instance:
          self.aws_instance_ips.append(instance['PrivateIpAddress'])

        if instance['InstanceId'] == self.instance_id:
          self.instance = instance

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
    a_record_name = '{}.{}.{}.'.format(
      self.instance_id,
      domain.prefix,
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

  def get_a_records(self, domain):
    record_sets = self.route53.list_resource_record_sets(
      HostedZoneId=domain.zone
    )['ResourceRecordSets']
    
    a_records = [rc for rc in record_sets if rc['Name'] == self.get_a_record_name(domain) and rc['Type'] == 'A']

    return a_records

  def get_srv_records(self, domain, isclient):

    record_sets = self.route53.list_resource_record_sets(
      HostedZoneId=domain.zone
    )['ResourceRecordSets']
    
    srv_records = [rc for rc in record_sets if rc['Name'] == self.get_srv_record_name(domain, isclient) and rc['Type'] == 'SRV']

    return srv_records

  def get_roundrobin_records(self, domain):
    record_sets = self.route53.list_resource_record_sets(
      HostedZoneId=domain.zone
    )['ResourceRecordSets']
    
    rr_records = [rc for rc in record_sets if rc['Name'] == self.get_roundrobin_record_name(domain) and rc['Type'] == 'A']

    return rr_records

  def update_records(self, action):

    print('action: {}'.format(action))
    print('aws_instance_ids: {}'.format(self.aws_instance_ids))
    print('aws_instance_ips: {}'.format(self.aws_instance_ips))
    print('aws_instances: {}'.format(self.aws_instances))
    print('instance_id: {}'.format(self.instance_id))
    print('instance: {}'.format(self.instance))

    for domain in self.domains():

      # build up a DNS update request
      dns_update = {
        'HostedZoneId': domain.zone,
        'ChangeBatch': {
          'Comment': self.comment,
          'Changes': []
        }
      } 

      # first delete requests for all current records if those exist
      records_to_delete = self.get_a_records(domain) + \
        self.get_srv_records(domain, True) + \
        self.get_srv_records(domain, False) + \
        self.get_roundrobin_records(domain)
      
      for deletion in records_to_delete:
        dns_update['ChangeBatch']['Changes'].append(
          {
            'Action': 'DELETE',
            'ResourceRecordSet': deletion
          }
        )

      # build up upsert requests
      roundrobin_record_values = self.aws_instance_ips

      srv_client_record_values = [
        '0 0 {} {}.{}.{}.'.format(domain.srvclientport, instance_id, domain.prefix, domain.name) for instance_id in self.aws_instance_ids
      ]

      srv_server_record_values = [
        '0 0 {} {}.{}.{}.'.format(domain.srvserverport, instance_id, domain.prefix, domain.name) for instance_id in self.aws_instance_ids
      ]

      # on DELETE, don't try to re-create the A record for the  
      if action == 'DELETE':
        records_to_upsert = [  
          {'Name': self.get_srv_record_name(domain, True), 'Value': srv_client_record_values, 'Type': 'SRV'}, 
          {'Name': self.get_srv_record_name(domain, False), 'Value': srv_server_record_values, 'Type': 'SRV'},
          {'Name': self.get_roundrobin_record_name(domain), 'Value': roundrobin_record_values, 'Type': 'A'}
        ]
      else:
        if 'PrivateIpAddress' in self.instance:
          a_record_values = [self.instance['PrivateIpAddress']]
        else:
          a_record_values = []
        
        records_to_upsert = [ 
          {'Name': self.get_a_record_name(domain), 'Value': a_record_values, 'Type': 'A'}, 
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

      print('full update: {}'.format(dns_update))
      self.route53.change_resource_record_sets(**dns_update)

def handler(event, context):
  client = UpdaterClient(event)

  if client.event_type == 'autoscaling:EC2_INSTANCE_LAUNCH':
    client.update_records(action='UPSERT')

  elif client.event_type == 'autoscaling:EC2_INSTANCE_TERMINATE':
    client.update_records(action='DELETE')

  else:
    raise Error('Unknown event type {}'.format(client.event_type))


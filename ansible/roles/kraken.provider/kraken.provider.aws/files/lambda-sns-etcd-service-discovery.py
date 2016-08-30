# -*- coding: utf-8 -*-
"""
Update Route53 Records based on Autoscaling event notifications sent via SNS.
To configure your domain you need to specify:
1) Tags per Auto Scaling Group (ASG) :
   'srvconfig' such as <Route53Zone:domain.com:prefix:SRV Client:SRV Server:SrvPort>.
A Route53 entry will be created with the AWS generated EC2 Instance Id .e.g i-abc123456.domain.com. 

When the server is terminated it will be removed from the Route53 zone you specified in the ASG tag.
"""

import json

from collections import namedtuple
from itertools import chain

import boto3


DomainEntry = namedtuple('DomainEntry', ['zone', 'name', 'prefix', 'srvclient', 'srvserver', 'srvport'])


class Error(Exception):
  pass


class UpdaterClient(object):

  srv_config_tag = 'srvconfig'

  ttl = 300
  dry_run = False

  def __init__(self, event):
    self._boto = {}
    self.event = event
    self.record = event['Records'][0]
    self.region = self.record['EventSubscriptionArn'].split(':')[3]
    self.message = json.loads(self.record['Sns']['Message'])
    self.instance_id = self.message['EC2InstanceId']
    self.autoscaling_group_name = self.message['AutoScalingGroupName']
    self.event_type = self.message['Event']

  def boto(self, resource):
    if resource not in self._boto:
      self._boto[resource] = boto3.client(resource, region_name=self.region)
    return self._boto[resource]

  def domains(self):
    asg = self.boto('autoscaling').describe_auto_scaling_groups(
      AutoScalingGroupNames=[self.autoscaling_group_name]
    )['AutoScalingGroups'][0]
    
    tags = [x for x in asg['Tags'] if x['Key'] == self.srv_config_tag]

    if len(tags) != 1:
      raise Error(
        'You must specify the {} tag in your autoscaling group {}'.format(
          self.srv_config_tag, self.autoscaling_group_name
        )
      )
    for entry in tags[0]['Value'].split(','):
      domain = DomainEntry(*entry.split(':'))
      print('Loaded domain configuration: {}'.format(domain))
      yield domain

  def instance(self):
    ec2 = self.boto('ec2')
    reservation = ec2.describe_instances(InstanceIds=[self.instance_id])
    return reservation['Reservations'][0]['Instances'][0]

  def records(self):
    route53 = self.boto('route53')
    for domain in self.domains():
      zone = route53.get_hosted_zone(Id=domain.zone)
      private = zone['HostedZone']['Config']['PrivateZone']
      name = '{}.'.format(self.instance_id)
      
      if domain.prefix:
        name = '{}{}.'.format(name, domain.prefix)
      name = '{}{}.'.format(name, domain.name)
      
      record_sets = route53.list_resource_record_sets(
        HostedZoneId=domain.zone,
        StartRecordName=name
      )['ResourceRecordSets']
      record = [x for x in record_sets if x['Name'] == name and x['Type'] == 'A']
      if record:
        record = record[0]
      else:
        instance = self.instance()
        interface = instance['NetworkInterfaces'][0]

        if private:
          ip_address = interface['PrivateIpAddress']
        else:
          ip_address = instance['PublicIp']
        record = {
          'Name': name,
          'Type': 'A',
          'TTL': self.ttl,
          'ResourceRecords': [
            {
              'Value': ip_address
            }
          ]
        }
      yield domain.zone, record
  
  def srvsClient(self, action):
    route53 = self.boto('route53')
    for domain in self.domains():
      zone = route53.get_hosted_zone(Id=domain.zone)
      private = zone['HostedZone']['Config']['PrivateZone']
        
      if domain.srvclient:
        srvValue = '0 0 {} {}'.format(domain.srvport, self.instance_id)
        srvName = '{}'.format(domain.srvclient)

        if domain.prefix:
          srvValue = '{}.{}.{}.'.format(srvValue, domain.prefix, domain.name)
          srvName = '{}.{}.{}.'.format(srvName, domain.prefix, domain.name)
        else:
          srvValue = '{}.{}.'.format(srvValue, domain.name)
          srvName = '{}.{}.'.format(srvName, domain.name)
        
        record_sets = route53.list_resource_record_sets(
          HostedZoneId=domain.zone,
          StartRecordName=srvName
        )['ResourceRecordSets']
        record = [x for x in record_sets if x['Type'] == 'SRV' and x['Name'] == srvName]

        if record:
          record = record[0]
        else:
          record = {
            'Name': srvName,
            'Type': 'SRV',
            'TTL': self.ttl,
            'ResourceRecords': []
          }
        
        record['ResourceRecords'][:] = [value for value in record['ResourceRecords'] if value.get('Value') != srvValue]
        if action == 'UPSERT':
          record['ResourceRecords'].append({'Value':srvValue})
        yield domain.zone, record

  def srvsServer(self, action):
    route53 = self.boto('route53')
    for domain in self.domains():
      zone = route53.get_hosted_zone(Id=domain.zone)
      private = zone['HostedZone']['Config']['PrivateZone']
        
      if domain.srvserver:
        srvValue = '0 0 {} {}'.format(domain.srvport, self.instance_id)
        srvName = '{}'.format(domain.srvserver)

        if domain.prefix:
          srvValue = '{}.{}.{}.'.format(srvValue, domain.prefix, domain.name)
          srvName = '{}.{}.{}.'.format(srvName, domain.prefix, domain.name)
        else:
          srvValue = '{}.{}.'.format(srvValue, domain.name)
          srvName = '{}.{}.'.format(srvName, domain.name)
        
        record_sets = route53.list_resource_record_sets(
          HostedZoneId=domain.zone,
          StartRecordName=srvName
        )['ResourceRecordSets']
        record = [x for x in record_sets if x['Type'] == 'SRV' and x['Name'] == srvName]

        if record:
          record = record[0]
        else:
          record = {
            'Name': srvName,
            'Type': 'SRV',
            'TTL': self.ttl,
            'ResourceRecords': []
          }
        
        record['ResourceRecords'][:] = [value for value in record['ResourceRecords'] if value.get('Value') != srvValue]
        if action == 'UPSERT':
          record['ResourceRecords'].append({'Value':srvValue})
        yield domain.zone, record

  def roundrobin(self, action):
    route53 = self.boto('route53')
    for domain in self.domains():
      zone = route53.get_hosted_zone(Id=domain.zone)
      private = zone['HostedZone']['Config']['PrivateZone']
        
      if domain.prefix:
        recordName = '{}.{}.'.format(domain.prefix, domain.name)
        recordValue = ''
        
        record_sets = route53.list_resource_record_sets(
          HostedZoneId=domain.zone,
          StartRecordName=recordName
        )['ResourceRecordSets']

        if action == 'DELETE':
          # on delete, lookup the old private ip address from a pre-existing individual A record
          # since the instance is already terminated
          individualARecord = '{}.{}.{}.'.format(self.instance_id, domain.prefix, domain.name)
          record = [x for x in record_sets if x['Type'] == 'A' and x['Name'] == individualARecord]
          recordValue = record[0]['ResourceRecords'][0]['Value']
        else:
          # otherwise we can just grab the private ip from NIC
          recordValue = self.instance()['NetworkInterfaces'][0]['PrivateIpAddress']

        record = [x for x in record_sets if x['Type'] == 'A' and x['Name'] == recordName]

        if record:
          record = record[0]
        else:
          record = {
            'Name': recordName,
            'Type': 'A',
            'TTL': self.ttl,
            'ResourceRecords': []
          }
        
        record['ResourceRecords'][:] = [value for value in record['ResourceRecords'] if value.get('Value') != recordValue]
        if action == 'UPSERT':
          record['ResourceRecords'].append({'Value':recordValue})
        yield domain.zone, record

  def update_records(self, action):
    route53 = self.boto('route53')
    comment = 'Automatically updated Route53 Record'
    updates = []

    # grouped records that only upsert
    upserts = chain(self.roundrobin(action), self.srvsClient(action), self.srvsServer(action))
    for zone, record in upserts:      
      if (not updates) or (not filter(lambda sameZone: sameZone['HostedZoneId'] == zone, updates)): 
        newUpdate = {
          'HostedZoneId': zone,
          'ChangeBatch': {
            'Comment': comment,
            'Changes': [
              {
                'Action': 'UPSERT',
                'ResourceRecordSet': record
              }
            ]
          }
        }
        updates.append(newUpdate)
      else:
        existingUpdate = filter(lambda sameZone: sameZone['HostedZoneId'] == zone, updates)
        if not record['ResourceRecords']:
          existingUpdate[0]['ChangeBatch']['Changes'].append({'Action': 'DELETE', 'ResourceRecordSet': record})
        else:
          existingUpdate[0]['ChangeBatch']['Changes'].append({'Action': 'UPSERT', 'ResourceRecordSet': record})


    for zone, record in self.records():      
      if (not updates) or (not filter(lambda sameZone: sameZone['HostedZoneId'] == zone, updates)): 
        newUpdate = {
          'HostedZoneId': zone,
          'ChangeBatch': {
            'Comment': comment,
            'Changes': [
              {
                'Action': action,
                'ResourceRecordSet': record
              }
            ]
          }
        }
        updates.append(newUpdate)
      else:
        existingUpdate = filter(lambda sameZone: sameZone['HostedZoneId'] == zone, updates)
        existingUpdate[0]['ChangeBatch']['Changes'].append({'Action': action, 'ResourceRecordSet': record})

    if not self.dry_run:
      for update in updates:
        route53.change_resource_record_sets(**update)


def handler(event, context):

  print('Processing event: {}'.format(event))

  client = UpdaterClient(event)

  if client.event_type == 'autoscaling:EC2_INSTANCE_LAUNCH':
    print('Launch event: {}'.format(client.event_type))
    client.update_records(action='UPSERT')
    print(context.get_remaining_time_in_millis())

  elif client.event_type == 'autoscaling:EC2_INSTANCE_TERMINATE':
    print('Termination event: {}'.format(client.event_type))
    client.update_records(action='DELETE')
    print(context.get_remaining_time_in_millis())

  else:
    raise Error('Unknown event type {}'.format(client.event_type))


#!/bin/sh
aws ec2 run-instances --count 5 --image-id ami-6d138f7a \
      --subnet-id subnet-d90f3df3 \
      --security-group-ids sg-92ccdbe9 \
      --region us-east-1 \
      --key-name venezia-testing \
      --instance-type m3.medium \
      --block-device-mapping '{"DeviceName":"/dev/xvdf","Ebs": {"VolumeSize":10}}' \
      --user-data file://./cloud-config.yaml

#aws ec2 run-instances --count 1 --image-id ami-6d138f7a \
#      --subnet-id subnet-d90f3df3 \
#      --security-group-ids sg-92ccdbe9 \
#      --region us-east-1 \
#      --key-name venezia-testing \
#      --instance-type m3.medium \
#      --block-device-mapping '{"DeviceName":"/dev/xvdf","Ebs": {"VolumeSize":10}}' \
#      --user-data file://./cloud-config-node-1.yaml
#aws ec2 run-instances --count 1 --image-id ami-6d138f7a \
#      --subnet-id subnet-d90f3df3 \
#      --security-group-ids sg-92ccdbe9 \
#      --region us-east-1 \
#      --key-name venezia-testing \
#      --instance-type m3.medium \
#      --block-device-mapping '{"DeviceName":"/dev/xvdf","Ebs": {"VolumeSize":10}}' \
#      --user-data file://./cloud-config-node-2.yaml
#aws ec2 run-instances --count 1 --image-id ami-6d138f7a \
#      --subnet-id subnet-d90f3df3 \
#      --security-group-ids sg-92ccdbe9 \
#      --region us-east-1 \
#      --key-name venezia-testing \
#      --instance-type m3.medium \
#      --block-device-mapping '{"DeviceName":"/dev/xvdf","Ebs": {"VolumeSize":10}}' \
#      --user-data file://./cloud-config-node-3.yaml
#aws ec2 run-instances --count 1 --image-id ami-6d138f7a \
#      --subnet-id subnet-d90f3df3 \
#      --security-group-ids sg-92ccdbe9 \
#      --region us-east-1 \
#      --key-name venezia-testing \
#      --instance-type m3.medium \
#      --block-device-mapping '{"DeviceName":"/dev/xvdf","Ebs": {"VolumeSize":10}}' \
#      --user-data file://./cloud-config-node-4.yaml
#aws ec2 run-instances --count 1 --image-id ami-6d138f7a \
#      --subnet-id subnet-d90f3df3 \
#      --security-group-ids sg-92ccdbe9 \
#      --region us-east-1 \
#      --key-name venezia-testing \
#      --instance-type m3.medium \
#      --block-device-mapping '{"DeviceName":"/dev/xvdf","Ebs": {"VolumeSize":10}}' \
#      --user-data file://./cloud-config-node-5.yaml

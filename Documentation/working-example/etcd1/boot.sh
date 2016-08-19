#!/bin/sh
aws ec2 run-instances --count 5 --image-id ami-6d138f7a \
      --subnet-id subnet-d90f3df3 \
      --security-group-ids sg-92ccdbe9 \
      --region us-east-1 \
      --key-name venezia-testing \
      --instance-type m3.medium \
      --block-device-mapping '{"DeviceName":"/dev/xvdf","Ebs": {"VolumeSize":10}}' \
      --user-data file://./cloud-config.yaml

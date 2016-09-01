#!/bin/bash
echo "ZIP the lambda source"
cp ../../files/lambda-sns-etcd-service-discovery.py .
zip ./lambda-sns-etcd-service-discovery.zip lambda-sns-etcd-service-discovery.py
rm lambda-sns-etcd-service-discovery.py

echo "Run terraform 0.7.x"
terraform apply
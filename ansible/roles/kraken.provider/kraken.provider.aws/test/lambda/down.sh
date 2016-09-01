#!/bin/bash
echo "clean zip"
rm lambda-sns-etcd-service-discovery.zip

echo "Run terraform 0.7.x"
terraform destroy -force
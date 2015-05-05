# Overivew
* Create a Cloudformation template
  * Use nested stacks
    http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-stack.html
  * Acknowledge IAM capabilities even though IAM’s resources are not used in this template
    http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-iam-template.html
  * Create an Amazon VPC network
  * Create a public address
  * Bind a DNS to the public address 
  * Create the kubernetes security group
  * Create the kubernetes master node stack
  * Create the kubernetes minion node stack
  * Bind the public address to the new kubernetes stack for demoing or troubleshooting
* E2E test
* Destroy stack if pass


vpc: vpc-c9369dac

subnet_id: subnet-f8c14c9d
subnet: 10.1.1.0/24
ami: ami-fe724896
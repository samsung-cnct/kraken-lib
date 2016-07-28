# AWS Deployment Configuration

This snippet will describe an AWS configuration for deployment

# Sections

## region

Region will describe what region you want your cluster to be created in.  Currently we only support one AWS region per cluster

Examples include `us-east-1` and `us-west-2`

## subnets

Subnets describe the AWS subnets to be created per AZ

# Prototype
```yaml
    provider: aws
    configuration:
      # Provider-Specific Configuration Data
      resourcePrefix: mrrobot
      region: us-east-1
      subnets:
        - 
          az: us-east-1a
          cidr: 10.0.1.0/22
          netmask: 255.255.255.0
        -
          az: us-east-1b
          cidr: 10.0.2.0/22
          netmask: 255.255.255.0
        - 
          az: us-east-1c
          cidr: 10.0.3.0/22
          netmask: 255.255.255.0
      authentication:
        accessKey: abc123
        accessSecret: xyz789
        credentialsFile: 
        credentialsProfile:
```


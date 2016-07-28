# AWS Deployment Configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| resourcePrefix | Optional | String | String prefix to use for AWS resource naming. Defaults to cluster name |
| region | __Required__ | String | region you want your cluster to be created in.  Currently we only support one AWS region per cluster |
| subnets | __Required__ | Object Array | Subnets describe the AWS subnets to be created per AZ |
| authentication | Optional | Object | Authentication info for AWS |

## subnets options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| az | __Required__ | String | AWS AZ name |
| cidr | __Required__ | String | Subnet CIDR block |

## authentication options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| accessKey | Optional | String | AWS secret key ID. Default is picked up from standart AWS evironment variables |
| accessSecret | Optional | String | AWS secret. Default is picked up from standart AWS evironment variables |
| credentialsFile | Optional | String | This is the path to the shared credentials file. If this is not set and a profile is specified, ~/.aws/credentials will be used. |
| credentialsProfile | Optional | String | AWS credentials profile |

# Example
```yaml
    provider: aws
    providerConfig:
      # Provider-Specific Configuration Data
      resourcePrefix: mrrobot
      region: us-east-1
      subnets:
        - 
          az: us-east-1a
          cidr: 10.0.1.0/22
        -
          az: us-east-1b
          cidr: 10.0.2.0/22
        - 
          az: us-east-1c
          cidr: 10.0.3.0/22
      authentication:
        accessKey: abc123
        accessSecret: xyz789
        credentialsFile: 
        credentialsProfile:
```


# AWS Deployment Configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| resourcePrefix | Optional | String | String prefix to use for AWS resource naming. Defaults to cluster name |
| region | __Required__ | String | region you want your cluster to be created in.  Currently we only support one AWS region per cluster |
| subnet | __Required__ | Object Array | Subnet describes the AWS subnets to be created per AZ |
| authentication | Optional | Object | Authentication info for AWS |
| cert | Optional | Object | Loadbalancer certificates info |
| vpc | Required | String | VPC CIDR block |
| ingressAcl | __Required__ | Object Array  | Array of VPC ingresses |
| egressAcl | __Required__ | Object Array  | Array of VPC egresses |
| ingressSecurity | __Required__ | Object Array  | Array of Security group ingresses |
| egressSecurity | __Required__ | Object Array  | Array of Secuirty group egresses |


## subnets options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | subnet name |
| az | __Required__ | String | AWS AZ name |
| cidr | __Required__ | String | Subnet CIDR block |

## ingressAcl and egressAcl options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| protocol | __Required__ | String | The protocol. If you select a protocol of "-1", you must specify a "from_port" and "to_port" equal to 0. |
| rule_no | __Required__ | String | The rule number. Used for ordering |
| action | __Required__ | String | The action to take |
| cidr_block | __Required__ | String | CIDR block this applies to |
| from_port | __Required__ | Integer | The from port to match |
| to_port | __Required__ | Integer | The to port to match |
| icmp_type | Optional | String | The ICMP type to be used. Default 0. |
| icmp_code | Optional | String |  The ICMP type code to be used. Default 0. |


## authentication options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| accessKey | Optional | String | AWS secret key ID. Default is picked up from standart AWS evironment variables |
| accessSecret | Optional | String | AWS secret. Default is picked up from standart AWS evironment variables |
| credentialsFile | Optional | String | This is the path to the shared credentials file. If this is not set and a profile is specified, ${HOME}/.aws/credentials will be used. |
| credentialsProfile | Optional | String | AWS credentials profile |

## cert options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| certFile | Optional | String | path to certificate file |
| privateKeyFile | Optional | String | path to private key file. |
| certCountry | Optional | String | country for generated cert. |
| certState | Optional | String | state for generated cert |
| certLocality | Optional | String | locality for generated cert |
| certOrg | Optional | String | org for generated cert |
| certCommonName | Optional | String | common name for generated cert |


## ingressSecurity and egressSecurity options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| cidr_blocks | Optional | String array | List of CIDR blocks |
| from_port | __Required__ | Integer | The from port to match |
| to_port | __Required__ | Integer | The to port to match |
| protocol | Optional | __Required__ |  The protocol. If you select a protocol of "-1", you must specify a "from_port" and "to_port" equal to 0. |

# Example
```yaml
    provider: aws
    providerConfig:
      resourcePrefix: defaults
      vpc: 10.0.0.0/16
      region: us-west-2
      subnet:
        -
          name: uwswest2a
          az: us-west-2a
          cidr: 10.0.1.0/22
        -
          name: uwswest2b
          az: us-west-2b
          cidr: 10.0.2.0/22
        -
          name: uwswest2c
          az: us-west-2c
          cidr: 10.0.3.0/22
      egressAcl:
        -
          protocol: "-1"
          rule_no: 100
          action: "allow"
          cidr_block: "0.0.0.0/0"
          from_port: 0
          to_port: 0
      ingressAcl:
        -
          protocol: "-1"
          rule_no: 100
          action: "allow"
          cidr_block: "0.0.0.0/0"
          from_port: 0
          to_port: 0
      ingressSecurity:
        - 
          from_port: 22
          to_port: 22
          protocol: "TCP"
          cidr_blocks: ["0.0.0.0/0"]
      egressSecurity:
        - 
          from_port: 0
          to_port: 0
          protocol: "-1"
          cidr_blocks: ["0.0.0.0/0"]
      authentication:
        accessKey: abc123
        accessSecret: xyz789
        credentialsFile: 
        credentialsProfile:
      certs:
        certFile: /path/to/cert.pem
        privateKeyFile: /path/to/private.key
```


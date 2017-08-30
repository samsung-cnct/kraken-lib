# AWS Deployment Configuration

# Options
## Root Options
| Key Name        | Required     | Type          | Description |
| --------------  | ------------ | ------------- | ----------  |
| name            | __Required__ | String        | defaultAWS  |
| kind            | __Required__ | String        | kind is provider |
| provider        | __Required__ | String        | depends on provider, in this case - aws |
| type            | Optional     | String        | Type of provider. cloudinit or autonomous. Autonomous providers do not require cloud init configuration. Defaults to cloudinit |
| resourcePrefix  | Optional     | String        | String prefix to use for AWS resource naming |
| vpc             | __Required__ | String        | VPC CIDR block |
| existing_vpc    | Optional     | Object Array  | pre-existing VPC to land cluster in |
| region          | __Required__ | String        | region you want your cluster to be created in.  Currently we only support one AWS region per cluster |
| subnet          | __Required__ | Object Array  | Subnet describes the AWS subnets to be created per AZ |
| egressAcl       | __Required__ | Object Array  | Array of VPC egresses |
| ingressAcl      | __Required__ | Object Array  | Array of VPC ingresses |
| authentication  | Optional     | Object        | Authentication info for AWS |
| ingressSecurity | __Required__ | Object Array  | Array of Security group ingresses |
| egressSecurity  | __Required__ | Object Array  | Array of Secuirty group egresses |
| cert            | Optional     | Object        | Loadbalancer certificates info |

## existing_vpc
| Key Name | Required     | Type   | Description|
| -------- | ------------ | ------ | --- |
| id       | __Required__ | String | id of an existing VPC from the AWS console |
| route_table_id | __Required__ | String | id of a route table in the linked VPC |
| default_security_group_id | __Required__ | String | id of the default security group for the linked VPC |

It is important to note that kraken-lib will not auto-detect any existing networking infrastructure in the VPC.  kraken-lib assumes
that you have configured things correctly and will throw an error on a resource conflict.  The listed route_table_id
must have a valid route to an internet gateway.  kraken-lib has each node pull images from public repositories.  

## subnets options
| Key Name | Required     | Type   | Description|
| -------- | ------------ | ------ | --- |
| name     | __Required__ | String | subnet name |
| az       | __Required__ | String | AWS AZ name |
| cidr     | __Required__ | String | Subnet CIDR block |

## ingressAcl and egressAcl options
| Key Name   | Required     | Type    | Description|
| ---------- | ------------ | ------- | --- |
| protocol   | __Required__ | String  | The protocol. If you select a protocol of "-1", you must specify a "from_port" and "to_port" equal to 0. |
| rule_no    | __Required__ | String  | The rule number. Used for ordering |
| action     | __Required__ | String  | The action to take |
| cidr_block | __Required__ | String  | CIDR block this applies to |
| from_port  | __Required__ | Integer | The from port to match |
| to_port    | __Required__ | Integer | The to port to match |
| icmp_type  | Optional     | String  | The ICMP type to be used. Default 0. |
| icmp_code  | Optional     | String  |  The ICMP type code to be used. Default 0. |


## authentication options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| accessKey          | Optional | String | AWS secret key ID. Default is picked up from standart AWS evironment variables |
| accessSecret       | Optional | String | AWS secret. Default is picked up from standart AWS evironment variables |
| credentialsFile    | Optional | String | This is the path to the shared credentials file. If this is not set and a profile is specified, ${HOME}/.aws/credentials will be used. |
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

| Key Name    | Required     | Type         | Description|
| ----------- | ------------ | ------------ | --- |
| cidr_blocks | Optional     | String array | List of CIDR blocks |
| from_port   | __Required__ | Integer      | The from port to match |
| to_port     | __Required__ | Integer      | The to port to match |
| protocol    | Optional     | __Required__ |  The protocol. If you select a protocol of "-1", you must specify a "from_port" and "to_port" equal to 0. |


# Example
```yaml
providerConfigs:
  - &defaultAws
    name: defaultAws
    kind: provider
    provider: aws
    type: cloudinit
    resourcePrefix:
    vpc: 10.0.0.0/16
    region: us-west-2
    subnet:
      -
        name: uwswest2a
        az: us-west-2a
        cidr: 10.0.0.0/18
      -
        name: uwswest2b
        az: us-west-2b
        cidr: 10.0.64.0/18
      -
        name: uwswest2c
        az: us-west-2c
        cidr: 10.0.128.0/17
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
    authentication:
      accessKey:
      accessSecret:
      credentialsFile: "$HOME/.aws/credentials"
      credentialsProfile:
    ingressSecurity:
      -
        from_port: 22
        to_port: 22
        protocol: "TCP"
        cidr_blocks: ["0.0.0.0/0"]
      -
        from_port: 443
        to_port: 443
        protocol: "TCP"
        cidr_blocks: ["0.0.0.0/0"]
    egressSecurity:
      -
        from_port: 0
        to_port: 0
        protocol: "-1"
        cidr_blocks: ["0.0.0.0/0"]
```

# AWS specific node configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| azs | __Required__ | Object Array | Indicates what availability zone we are addressing |
| instance-type | __Required__ | String | String indicating machine type (m3.medium, etc.) |
| ssh-key-name | Optional | String |  Indicates what ssh key should be able to SSH in.  Lack of setting this indicates nobody should be able to log in. |

    
## azs Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| az  | __Required__ | String | Name of the AZ this option is regarding |
| count | __Required__ | Integer | Number of instances created |

# Example
```yaml
azs:
  - az: us-east-1a
    count: 2
  - az: us-east-1b
    count: 2
  - az: us-east-1c
    count: 1
instance-type: m3.medium
ssh-key-name: etcd-cluster
```
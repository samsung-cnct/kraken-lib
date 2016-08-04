# AWS specific node configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| azs | __Required__ | Object Array | Indicates what availability zone we are addressing |
| type | __Required__ | String | String indicating machine type (m3.medium, etc.) |
| tags | Optional | Object Array |  Array of tags to apply to node. Note that 'Name' is forced to value of resourcePrefix + pool name. |
| storage | Required | Object Array | Array of storage volume specs.|


## azs Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| az  | __Required__ | String | Name of the AZ this option is regarding |
| count | __Required__ | Integer | Number of instances created in that AZ. Total count of all AZs must match the node pool count|

## tags Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| key  | __Required__ | String | Tag key |
| value | __Required__ | Integer | Tag value |

## storage Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| type  | __Required__ | String | Storage volume type. root (only one supported), ebs or ephemeral |
| volume | __Required__ | String | The type of volume. Can be "standard", "gp2", or "io1". Only supported by root and ebs volumes |
| size | __Required__ | Integer | Size of volume in gigabytes. Only supported by root and ebs volumes. |
| delete | Optional | Bool | Delete volume on instance termination. Defaults to false |
| iops | Optional | Integer | The amount of provisioned IOPS. This must be set with a volume of "io1". Only supported by root and ebs volumes |
| snapshotId | Optional | String | The Snapshot ID to mount. Only supported by ebs volumes |
| encrypted | Optional | Bool | Enables EBS encryption on the volume. Cannot be used with snapshotId. Only supported by ebs volumes. Defaults to false |
| deviceName | Optional | String | The name of the device to mount. Supported by ebs and ephemeral only. |
| virtualName | Optional | String | The [Instance Store Device](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/InstanceStorage.html#InstanceStoreDeviceNames) Name (e.g. "ephemeral0") |


# Example

```yaml
nodepool:
  -
    name: master
    ...
    providerConfig:
      type: m3.medium
      azs:
        - az: us-east-1a
          count: 2
        - az: us-east-1b
          count: 2
        - az: us-east-1c
          count: 1
      tags:
        -
          key: comments
          value: "bow down before your master"
      storage:
        -
          type: root
          volume: gp2
          size: 10
          delete: false
        -
          type: ebs
          deviceName: sdf
          volume: io1
          size: 100
          iops: 5000
          delete: false
          snapshotId:
          encrypted: true
        -
          type: ephemeral
          deviceName: sdb
          virtualName: ephemeral0
```
# AWS specific node configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| subnet | __Required__ | String Array | Which subnets to span (defined in top level providerConfig) |
| type | __Required__ | String | String indicating machine type (m3.medium, etc.) |
| tags | Optional | Object Array |  Array of tags to apply to node. Note that 'Name' is forced to value of resourcePrefix + pool name. |
| storage | Required | Object Array | Array of storage volume specs.|


| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| key  | __Required__ | String | Tag key |
| value | __Required__ | Integer | Tag value |

## storage Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| type  | __Required__ | String | Storage volume type. root_block_device (only one supported), ebs_block_device or ephemeral_block_device |
| opts  | __Required__ | Object | Storage options |

## storage.opts Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| volume_type | __Required__ | String | The type of volume. Can be "standard", "gp2", or "io1". Only supported by root and ebs volumes |
| volume_size | __Required__ | Integer | Size of volume in gigabytes. Only supported by root and ebs volumes. |
| delete_on_termination | Optional | Bool | Delete volume on instance termination. Defaults to false |
| iops | Optional | Integer | The amount of provisioned IOPS. This must be set with a volume of "io1". Only supported by root and ebs volumes |
| snapshot_id | Optional | String | The Snapshot ID to mount. Only supported by ebs volumes |
| encrypted | Optional | Bool | Enables EBS encryption on the volume. Cannot be used with snapshotId. Only supported by ebs volumes. Defaults to false |
| device_name | Optional | String | The name of the device to mount. Supported by ebs and ephemeral only. |
| virtual_name | Optional | String | The [Instance Store Device](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/InstanceStorage.html#InstanceStoreDeviceNames) Name (e.g. "ephemeral0") |


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
          value: "bleep bloop, I'm a cluster master"
      storage:
        -
          type: root_block_device
          opts:
            volume_type: gp2
            volume_size: 10
            delete_on_termination: false
        -
          type: ebs_block_device
          opts:
            device_name: sdf
            volume_type: io1
            volume_size: 100
            iops: 5000
            delete_on_termination: false
            snapshot_id:
            encrypted: true
        -
          type: ephemeral_block_device
          opts:
            device_name: sdb
            virtual_name: ephemeral0
```
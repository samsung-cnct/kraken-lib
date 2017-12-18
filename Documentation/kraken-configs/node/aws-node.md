# Node Configurations for node on AWS

## Root Options
| Key Name       | Required     | Type         | Description      |
| -------------- | ------------ | ----------   | ---------------- |
| mounts         |              | Object Array |                  |
| providerConfig |              | Object       | Provider details |
| taints         |  Optional    | Object Array | Restrict node to only allow pods that tolerate the taints |

## Mounts Options
| Key Name       | Required     | Type         | Description  |
| -------------- | ------------ | ----------   | ------------ |
| device         |              | String       |              |
| path           |              | String       |              |
| forceFormat    |              | Boolean      |              |

## Provider Options
| Key Name       | Required     | Type         | Description  |
| -------------- | ------------ | ----------   | ------------ |
| provider       | __Required__ | String       | Provider     |
| type           | __Required__ | String       | Type of node to be launched - will vary depending on provider |
| subnet         | __Required__ | String Array | Describes AWS subnets to be created per AZ |
| label          |   Optional   | Object Array | Array of labels to apply to kubernetes nodes ( defaultAwsMasterNode, defaultAwsClusterNode, defaultAwsSpecialNode) |
| tags           |   Optional   | Object Array | Array of tags to apply to node |
| storage        | __Required__ | Object Array | Array of storage volume specs |

## [Taints Options](https://kubernetes.io/docs/user-guide/kubectl/v1.7/#taint)
| Key Name       | Required     | Type         | Description  |
| -------------- | ------------ | ----------   | ------------ |
| key            | __Required__ | string       | Must match key when adding toleration to pod |
| value          | __Required__ | string       | Can be "" if no value desired |
| effect         | __Required__ | string       | Must be NoSchedule, PreferNoSchedule or NoExecute |

### Storage Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| type  | __Required__ | String | Storage volume type. root_block_device (only one supported), ebs_block_device or ephemeral_block_device |
| opts  | __Required__ | Object | Storage options |

### storage.opts Options
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


## Example
```yaml
nodeConfigs:
  - &defaultAwsEtcdNode
    name: defaultAwsEtcdNode
    kind: node
    mounts:
      -
        device: sdf
        path: /var/lib/docker
        forceFormat: true
      -
        device: sdg
        path: /ephemeral
        forceFormat: false
    providerConfig:
      provider: aws
      type: t2.small
      subnet: ["uwswest2a", "uwswest2b", "uwswest2c"]
      tags:
        -
          key: comments
          value: "Cluster etcd"
      storage:
        -
          type: ebs_block_device
          opts:
            device_name: sdf
            volume_type: gp2
            volume_size: 100
            delete_on_termination: true
            snapshot_id:
            encrypted: false
        -
          type: ebs_block_device
          opts:
            device_name: sdg
            volume_type: gp2
            volume_size: 10
            delete_on_termination: true
            snapshot_id:
            encrypted: false
  - &defaultAwsEtcdEventsNode
    name: defaultAwsEtcdEventsNode
    kind: node
    mounts:
      -
        device: sdf
        path: /var/lib/docker
        forceFormat: true
      -
        device: sdg
        path: /ephemeral
        forceFormat: false
    providerConfig:
      provider: aws
      type: t2.small
      subnet: ["uwswest2a", "uwswest2b", "uwswest2c"]
      tags:
        -
          key: comments
          value: "Cluster events etcd"
      storage:
        -
          type: ebs_block_device
          opts:
            device_name: sdf
            volume_type: gp2
            volume_size: 100
            delete_on_termination: true
            snapshot_id:
            encrypted: false
        -
          type: ebs_block_device
          opts:
            device_name: sdg
            volume_type: gp2
            volume_size: 10
            delete_on_termination: true
            snapshot_id:
            encrypted: false
  - &defaultAwsMasterNode
    name: defaultAwsMasterNode
    kind: node
    mounts:
      -
        device: sdf
        path: /var/lib/docker
        forceFormat: true
    providerConfig:
      provider: aws
      type: m3.medium
      subnet: ["uwswest2a", "uwswest2b", "uwswest2c"]
      label:
        - name: label
          value: this is an example
        - name: another_label
          value: one more example
      tags:
        -
          key: comments
          value: "Master instances"
      storage:
        -
          type: ebs_block_device
          opts:
            device_name: sdf
            volume_type: gp2
            volume_size: 100
            delete_on_termination: true
            snapshot_id:
            encrypted: false
  - &defaultAwsClusterNode
    name: defaultAwsClusterNode
    kind: node
    mounts:
      -
        device: sdf
        path: /var/lib/docker
        forceFormat: true
    providerConfig:
      provider: aws
      type: c4.large
      subnet: ["uwswest2a", "uwswest2b", "uwswest2c"]
      label:
        - name: label
          value: this is an example
        - name: another_label
          value: one more example
      tags:
        -
          key: comments
          value: "Cluster plain nodes"
      storage:
        -
          type: ebs_block_device
          opts:
            device_name: sdf
            volume_type: gp2
            volume_size: 100
            delete_on_termination: true
            snapshot_id:
            encrypted: false
    taints:
      - key: firstKey
        value: firstValue
        effect: PreferNoSchedule
      - key: secondKey
        value: ""
        effect: NoSchedule
  - &defaultAwsSpecialNode
    name: defaultAwsSpecialNode
    kind: node
    mounts:
      -
        device: sdf
        path: /var/lib/docker
        forceFormat: true
    keypair: krakenKey
    providerConfig:
      provider: aws
      type: m3.medium
      subnet: ["uwswest2a", "uwswest2b", "uwswest2c"]
      label:
        - name: label
          value: this is an example
        - name: another_label
          value: one more example
      tags:
        -
          key: comments
          value: "Cluster special nodes"
      storage:
        -
          type: ebs_block_device
          opts:
            device_name: sdf
            volume_type: gp2
            volume_size: 100
            delete_on_termination: true
            snapshot_id:
            encrypted: false
```

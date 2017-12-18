# Node Configurations for node on GKE
| Key Name       | Required     | Type         | Description      |
| -------------- | ------------ | ----------   | ---------------- |
| name           | __Required__ | string       | Name of node     |
| providerConfig | __Required__ | Object       | Provider details |
| taints         |  Optional    | Object Array | Restrict node to only allow pods that tolerate the taints |


## ProviderConfig Options
| Key Name       | Required     | Type         | Description  |
| -------------- | ------------ | ----------   | ------------ |
| diskSize       | __Required__ | Integer      | Size in GB for node VM boot disks. Defaults to 100GB.|
| machineType    | __Required__ | String       | The type of machine to use for nodes. Defaults to server-specified.|
| scopes         | Optional     | String Array | Specifies scopes for the node instances. The project's default service account is used. |
| autoscaling    | Optional     | Object       | Nodepool autoscaling configuration. |
| localSsdCount  | Optional     | Integer      | The number of local SSD disks to be attached to the node. |
| disableCloudEndpoints | Optional | Boolean   | Disable Google Cloud Endpoints to take advantage of API management features. Enabled by default |
| imageType      | Optional     | String       | The image type to use for the node pool. Defaults to server-specified. |
| serviceAccount | Optional     | String       | The Google Cloud Platform Service Account to be used by the node VMs. If no Service Account is specified, the "default" service account is used. |
| label          | Optional     | Object Array | Node k8s labels. |
| metadata       | Optional     | Object Array | Node gce metadata. |
| tags           | Optional     | String Array | List of RFC1035 compliant node tags. |
| kubeConfig     | Optional     | String       | Name of a [kubeConfig](../kubeconfig.md) object. Only name and version number are relevant |

## [Taints Options](https://kubernetes.io/docs/user-guide/kubectl/v1.7/#taint)
| Key Name       | Required     | Type         | Description  |
| -------------- | ------------ | ----------   | ------------ |
| key            | __Required__ | string       | Must match key when adding toleration to pod |
| value          | __Required__ | string       | Can be "" if no value desired |
| effect         | __Required__ | string       | Must be NoSchedule, PreferNoSchedule or NoExecute |

### autoscaling options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| minNodeCount | __Required__ | Integer | Minimum number of nodes in the NodePool. Must be >= 1 and <= maxNodeCount. |
| maxNodeCount | __Required__ | Integer | Maximum number of nodes in the NodePool. Must be >= minNodeCount. There has to enough quota to scale up the cluster. |

### label options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | Label name |
| value | __Required__ | String | Label value |

### metadata options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | Metadata name |
| value | __Required__ | String | Metadata value |


## Examples
```yaml
nodeConfigs:
    - &defaultGKEClusterNode
      name: defaultGKEClusterNode
      kind: node
      providerConfig:
        diskSize: 100
        machineType: n1-standard-1
        scopes:
          - https://www.googleapis.com/auth/compute
          - https://www.googleapis.com/auth/devstorage.read_only
          - https://www.googleapis.com/auth/logging.write
          - https://www.googleapis.com/auth/monitoring
    - &defaultGKEOtherNode
      name: defaultGKEOtherNode
      kind: node
      providerConfig:
        diskSize: 100
        machineType: n1-standard-1
        scopes:
          - https://www.googleapis.com/auth/compute
          - https://www.googleapis.com/auth/devstorage.read_only
          - https://www.googleapis.com/auth/logging.write
          - https://www.googleapis.com/auth/monitoring
```

```yaml
...
    providerConfig:
      diskSize: 300
      imageType: GCI
      machineType: n1-standard-16
      label:
        - name: label
          value: this is an example
        - name: another_label
          value: one more example
...
    providerConfig:
      diskSize: 300
      imageType: GCI
      machineType: n1-standard-4
      scopes:
        - storage-rw
        - logging-write
```

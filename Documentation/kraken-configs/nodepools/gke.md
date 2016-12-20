# GKE specific node configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| autoscaling | Optional | Object | Nodepool autoscaling configuration. |
| diskSize | Optional | Integer | Size in GB for node VM boot disks. Defaults to 100GB. |
| localSsdCount | Optional | Integer | The number of local SSD disks to be attached to the node. |
| disableCloudEndpoints | Optional | Boolean | Disable Google Cloud Endpoints to take advantage of API management features. Enabled by default |
| imageType | Optional | String | The image type to use for the node pool. Defaults to server-specified. |
| machineType | Optional | String | The type of machine to use for nodes. Defaults to server-specified. |
| serviceAccount | Optional | String | The Google Cloud Platform Service Account to be used by the node VMs. If no Service Account is specified, the "default" service account is used. |
| scopes | Optional | String Array | Specifies scopes for the node instances. The project's default service account is used. |
| label | Optional | Object Array | Node k8s labels. |
| metadata | Optional | Object Array | Node gce metadata. |
| tags | Optional | String Array | List of RFC1035 compliant node tags. |
| kubeConfig | Optional | String | Name of a [kubeConfig](../kubernetes.md) object. Only name and version number are relevant |

## autoscaling options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| minNodeCount | __Required__ | Integer | Minimum number of nodes in the NodePool. Must be >= 1 and <= maxNodeCount. |
| maxNodeCount | __Required__ | Integer | Maximum number of nodes in the NodePool. Must be >= minNodeCount. There has to enough quota to scale up the cluster. |

## label options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | label name |
| value | __Required__ | String | label value |

## metadata options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | metadata name |
| value | __Required__ | String | metadata value |


# Example

```yaml
nodepool:
  -
    name: defaultPool
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
  -
    name: storagePool
    ...
    providerConfig:
      diskSize: 300
      imageType: GCI
      machineType: n1-standard-4
      scopes:
        - storage-rw
        - logging-write



```
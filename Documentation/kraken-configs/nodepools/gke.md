# GKE specific node configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| diskSize | Optional | Integer | Size in GB for node VM boot disks. Defaults to 100GB. |
| disableCloudEndpoints | Optional | Boolean | Disable Google Cloud Endpoints to take advantage of API management features. Enabled by default |
| imageType | Optional | String | The image type to use for the node pool. Defaults to server-specified. |
| machineType | Optional | String |  The type of machine to use for nodes. Defaults to server-specified. |
| scopes | Optional | String Array | Specifies scopes for the node instances. The project's default service account is used. |
| label | Optional | Object Array | Node labels. |

## label options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | label name |
| value | __Required__ | String | label value |


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
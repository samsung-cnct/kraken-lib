#Kubernetes node configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| nodes | __Required__ | Object array | Array of node objects |

## workers Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| nodepool | __Required__ | String | Name of the [nodepool](nodepool.md) to use for this node collection |


#Example
```yaml
nodes:
  - nodepool: cluster_nodes
  - nodepool: special_nodes
```
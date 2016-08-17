#Kubernetes node configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | Name of this node collection |
| nodepool | __Required__ | String | Name of the [nodepool](nodepool.md) to use for this node collection |


#Example
```yaml
node:
  - 
    name: cluster-nodes
    nodepool: cluster_nodes
  - 
    name: herp-derp
    nodepool: special_nodes
```
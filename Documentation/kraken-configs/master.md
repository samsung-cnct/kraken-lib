#Kubernetes master configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| nodepool | __Required__ | String | Name of the [nodepool](nodepool.md) to use for master |
| loadbalancer | __Required__ | String | Type of loadbalancer to use. cloud or nginx. Some loadbalncers might not be compatible with some providers |

# Example
```yaml
master: 
  nodepool: master
  loadbalancer: cloud 
```
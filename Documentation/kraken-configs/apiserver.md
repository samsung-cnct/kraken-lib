# Kubernetes apiserver configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| nodepool | __Required__ | String | Name of the [nodepool](nodepool.md) to use for api server |
| loadbalancer | __Required__ | String | Type of loadbalancer to use. cloud or nginx. Some loadbalncers might not be compatible with some providers |

# Example
```yaml
apiServer: 
  nodepool: master
  loadbalancer: cloud 
```
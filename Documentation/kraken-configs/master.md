#Kubernetes master configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| nodepool | __Required__ | String | Name of the [nodepool](nodepool.md) to use for master |
| loadbalancer | __Required__ | String | Type of loadbalancer to use. cloud or nginx. Some loadbalncers might not be compatible with some providers |
| infra | __Required__ | String | infra etcd cluster configuration |
| events | __Required__ | String | events etcd cluster configuration |


## infra options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| etcd | __Required__ | String | [etcd cluster](etcd.md) name |

## events options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| etcd | __Required__ | String | [etcd cluster](etcd.md) name |

# Example
```yaml
master: 
  nodepool: master
  loadbalancer: cloud 
  infra:
    etcd: etcd
  events:
    etcd: etcdEvents
```
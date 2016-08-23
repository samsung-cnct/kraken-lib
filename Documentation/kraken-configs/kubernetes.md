#Kubernetes configurations

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | Configuration name |
| version | __Required__ | String | Kubernetes version |
| containerConfig | Optional | String | Name of a [Container runtime configuration](container.md)  |
| clusterEtcd | __Required__ | object | configuration for cluster[etcd](etcd.md)  |
| eventsEtcd | Optional | Object | configuration for events[etcd](etcd.md)  |

# clusterEtcd and eventsEtcd options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| etcd | __Required__ | String | Name of configuration for events[etcd](etcd.md) |

# Example
```yaml
kubeConfig:
  - 
    name: masterconfig
    version: 1.3.2
    containerConfig: dockerconfig
    clusterEtcd:
      etcd: etcd
    eventsEtcd:
      etcd: etcdEvents
  -
    name: nodeconfig
    version: 1.2.5
    containerConfig: dockerconfig
    clusterEtcd:
      etcd: etcd
```
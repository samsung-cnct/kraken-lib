# API Server Configuration
The API Server stanza includes all configuration options for the control plane (master controller, api server, etc). There are configuration options for what type of loadBalancers to create for serviceType=LoadBalancer and if the cluster should have a separate etcd cluster for event.

## Options
| Key Name     | Required    | Type    | Description |
| ------------ | ----------- | ------- | ----------  |
| loadbalancer | __Required__| String  |             |
| state        | __Required__|         |             |
| events       | Optional    |         |             |


## Example

```yaml
apiServerConfigs:
  - &defaultApiServer
    name: defaultApiServer
    kind: apiServer
    loadBalancer: cloud
    state:
      etcd: *defaultEtcd
    events:
      etcd: *defaultEtcdEvents
```

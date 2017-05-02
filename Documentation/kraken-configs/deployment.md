# Deployment Configuration

The configuration for deployments depends on the provider.

## Root Options
| Key Name        | Required     | Type         |  Description  |
| --------------- | ------------ | ------------ | ------------- |
| clusters        | __Required__ | Object Array | Cluster Specs |
| readiness       | __Required__ | Object       | When is cluster considered to be ready. Defaults to 'exact' with 600 second total wait. |

## Cluster Options
| Key Name        | Required     | Type   | Description |
| --------------- | ------------ | ------ | ----------- |
| name            | __Required__ | String | Name to use for the cluster created by this deployment |
| network         | __Required__ | String |    |
| dns             | __Required__ | String | Cluster (kubedns) service IP |
| domain          | __Required__ | String | Domain name for cluster (internal resolution) |
| providerConfig  | __Required__ | String | Pointer to [providerConfig](provider/README.md) |
| kubeAuth        | __Required__ | String | Pointer to [Master admin authentication](kubeauth.md) |
| nodePools       | __Required__ | Object Array | Configs for nodes in each nodepool |
| fabricConfig    | __Required__ | String | Pointer to [fabricConfig](fabric.md) configuration section |
| helmConfig      | __Required__ | String | Pointer to [helmConfigs](helmconfigs.md) - specific configuration section |
| dnsConfig       | __Required__ | String | Pointer to [dnsConfing](dns.md) configuration section |


## Readiness Options

| Key Name | Required     | Type    | Description|
| -------- | ------------ | ------- | ---------- |
| type     | __Required__ | String  | Type of check: 'exact' 'percent' 'delta' |
| value    | Optional     | Integer | For percent - what percentage of nodes currently up from total node count is a healthy cluster (Default - 100). For delta - allowed difference between expected and current node count (default 0) |
| wait     | Optional     | Integer | Wait for how many seconds total |

# Example AWS deployement

```yaml
deployment:
  clusters:
    - name: myCluster
      network: 10.32.0.0/12
      dns: 10.32.0.2
      domain: cluster.local
      providerConfig: *defaultAws
      nodePools:
        - name: etcd
          count: 5
          etcdConfig: *defaultEtcd
          containerConfig: *defaultDocker
          osConfig: *defaultCoreOs
          nodeConfig: *defaultAwsEtcdNode
          keyPair: *defaultKeyPair
        - name: etcdEvents
          count: 5
          etcdConfig: *defaultEtcdEvents
          containerConfig: *defaultDocker
          osConfig: *defaultCoreOs
          nodeConfig: *defaultAwsEtcdEventsNode
          keyPair: *defaultKeyPair
        - name: master
          count: 3
          apiServerConfig: *defaultApiServer
          kubeConfig: *defaultKube
          containerConfig: *defaultDocker
          osConfig: *defaultCoreOs
          nodeConfig: *defaultAwsMasterNode
          keyPair: *defaultKeyPair
        - name: clusterNodes
          count: 3
          kubeConfig: *defaultKube
          containerConfig: *defaultDocker
          osConfig: *defaultCoreOs
          nodeConfig: *defaultAwsClusterNode
          keyPair: *defaultKeyPair
        - name: specialNodes
          count: 2
          kubeConfig: *defaultKube
          containerConfig: *defaultDocker
          osConfig: *defaultCoreOs
          nodeConfig: *defaultAwsSpecialNode
          keyPair: *defaultKeyPair
      fabricConfig: *defaultCanalFabric
      kubeAuth: *defaultKubeAuth
      helmConfig: *defaultHelm
      dnsConfig: *defaultDns
  readiness:
    type: exact
    value: 0
    wait: 600
```

# Example GKE deployment
```yaml
deployment:
  clusters:
    - name: delight
      network: 10.32.0.0/12
      dns: 10.32.0.2
      domain: cluster.local
      providerConfig: *defaultGKE
      kubeAuth: *defaultKubeAuth
      nodePools:
        - name: clusternodes
          count: 3
          kubeConfig: *defaultKube
          nodeConfig: *defaultGKEClusterNode
        - name: othernodes
          count: 2
          kubeConfig: *defaultKube
          nodeConfig: *defaultGKEOtherNode
      fabricConfig: *defaultCanalFabric
      helmConfig: *defaultHelm
      dnsConfig: *defaultDns
  readiness:
    type: exact
    value: 0
    wait: 600
```

See each configuration section for more details.

# Kraken nodepools

All instances in the cluster are to be described within the node pool.

Examples would include

* Instances used for etcd
* Instance used for non-HA master
* Instances used for specific worker loads

Each node pool is given a name that is referenced elsewhere in the configuration for the cluster.

We do not expect the same machine types to be used for each purpose, therefore each node pool will have information specific to its hardware provider (public cloud, local, bare metal, etc.)


## Options
### Root Options
| Key Name        | Required     | Type    | Description|
| ----------      | ----------   | ------- | --- |
| name            | __Required__ | String  | node pool name |
| count           | __Required__ | Integer | Total count of nodepool nodes |
| etcdConfig      | Optional     | String  | Name of [etcd configuration](kvstore.md) for nodes
| containerConfig | __Required__ | String  | Name of one of the [container configurations](container.md) |
| osConfig        | __Required__ | String  | Name of the [os configuration](os.md)|
| nodeConfig      | __Required__ | String  | Name of the [node config](node/README.md) for this nodepool
| keypair         | Optional     | String  | Key name from list of keypairs in [deployment](deployment.md). Lack of setting this indicates nobody should be able to log in. |
| kubeConfig      | Optional     | String  | Name of one of the [Kubernetes configurations](kubeconfig.md)|
| schedulingConfig| Optional     | String  | [Taints](schedulingConfig.md) to apply to nodePool |

## Example
```yaml
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
    schedulingConfig: *defaultScheduling
```

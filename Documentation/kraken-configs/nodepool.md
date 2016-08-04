#Kraken nodepools

All instances in the cluster are to be described within the node pool.

Examples would include

* Instances used for etcd
* Instance used for non-HA master
* Instances used for specific worker loads

Each node pool is given a name that is referenced elsewhere in the configuration for the cluster.

We do not expect the same machine types to be used for each purpose, therefore each node pool will have information specific to its hardware provider (public cloud, local, bare metal, etc.)


# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String |node pool name |
| count | __Required__| Integer | Total count of nodepool nodes |
| keypair | Optional | String | Key name from list of keypairs in [deployment](deployment.md). Lack of setting this indicates nobody should be able to log in. |
| providerConfig | __Required__ | Object | [Provider](nodepools/README.md) - specific node configuration |
| kubeConfig | Optional | String | Name of one of the [Kubernetes configurations](kubernetes.md)|


# Example
```yaml
nodepool:
  -
    name: master
    count: 3
    providerConfig:
      ...
    keypair: master-key
    kubeConfig: masterconfig
  -
    name: etcd_cluster
    count: 3
    keypair: etcd-key
    providerConfig:
      ...
  -
    name: cluster_nodes
    count: 20
    keypair: node-key
    providerConfig:
      ...
    kubeConfig: nodeconfig
  -
    name: special_nodes
    count: 5
    keypair: node-key
    providerConfig:
      ...
    kubeConfig: nodeconfig
```
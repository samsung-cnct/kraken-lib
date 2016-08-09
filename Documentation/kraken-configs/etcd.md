# ETCD Options

# Sections

## Root

By default we have an array of etcd clusters that we want to configure

| Name | Required | Type | Description |
| --- | --- | --- | --- |
| clusters | __TRUE__ | Object Array | array of etcd clusters |
| containerConfig | __TRUE__ | String | Name of a [Container runtime configuration](container.md)  |
| clientPorts | __FALSE__ | Integer Array | Defaults to 2379 and 4001 - the client ports for etcd |
| clusterToken | __FALSE__ | String | Defaults to _name_-cluster-token - the initial cluster token used |
| nodepool | __TRUE__ | String | Name of the node pool used to run this etcd cluster off of |
| peerPorts | __FALSE__ | Integer Array | Defaults to 2380 - the peer ports for peer-to-peer traffic |
| ssl | __FALSE__ | Boolean | Whether or not SSL is used for etcd traffic.  Defaults to true |
| version | __TRUE__ | String | etcd tag version |
| image | __FALSE__ | String | etcd image path - defaults to quay.io/coreos/etcd |

# Example
```yaml
- etcd:
  -
    clientPorts: [2379, 4001]
    clusterToken: etcd-cluster-token
    nodepool: etcd
    peerPorts: [2380]
    ssl: true
    version: 3.0.3
    containerConfig: dockerconfig
  -
    clientPorts: [2381]
    clusterToken: etcd-events-cluster-token
    nodepool: etcd-events
    peerPorts: [2382]
    ssl: true
    version: 3.0.3
    containerConfig: dockerconfig
```
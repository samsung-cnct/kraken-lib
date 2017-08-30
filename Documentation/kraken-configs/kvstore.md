# KV Store Options
kraken-lib only support etcd clusters now, but any KV store that implements the etcd API can be used.

## Options

By default we have an array of etcd clusters that we want to configure

| Name            | Required  | Type          | Description |
| --------------- | --------- | ------------- | --- |
| name            | __Required__  | String        | name for this kvStore cluster |
| kind            | __Required__  | String        | Must be kvStore |
| type            | __Required__  | String        | Type is etcd |
| clientPorts     | Optional      | Integer Array | Defaults to 2379 and 4001 - the client ports for etcd |
| clusterToken    | Optional      | String        | Defaults to _name_-cluster-token - the initial cluster token used |
| peerPorts       | Optional      | Integer Array | Defaults to 2380 - the peer ports for peer-to-peer traffic |
| ssl             | Optional      | Boolean       | Whether or not SSL is used for etcd traffic.  Defaults to true |
| version         | __Required__  | String        | etcd tag version |
| image           | Optional      | String        | etcd image path - defaults to quay.io/coreos/etcd |

## Example
```yaml
kvStoreConfigs:
  - &defaultEtcd
    name: etcd
    kind: kvStore
    type: etcd
    clientPorts: [2379, 4001]
    clusterToken: espouse-monger-rarely
    peerPorts: [2380]
    ssl: true
    version: v3.1.0
  - &defaultEtcdEvents
    name: etcdEvents
    kind: kvStore
    type: etcd
    clientPorts: [2381]
    clusterToken: animism-training-chastity
    peerPorts: [2382]
    ssl: true
    version: v3.1.0
```

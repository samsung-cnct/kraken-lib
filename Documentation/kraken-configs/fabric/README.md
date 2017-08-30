# Network Fabric configruation

The configuration for network fabrics depending on the provider.  The fabric stanza will tell kraken-lib which CNI plugin to use for creating the kubernetes network. kraken-lib supports Canal and Flannel.

## Fabric providers

* `flannel` - [Flannel](flannel.md)
* `calico` - [Calico](calico.md)

## Options
| Key Name | Required     | Type   | Description|
| -------- | ------------ | ------ | --- |
| name     | __Required__ | String | defaultCanalFabric |
| kind     | __Required__ | String | should be fabric |
| type     | Optional     | String | Name of a network fabric provider. Options are flannel, canal, or calico. Defaults to flannel |
| options  | Optional     | Object | Network fabric provider options|

## Example

```yaml
fabricConfigs:
  - &defaultCanalFabric
    name: defaultCanalFabric
    kind: fabric
    type: canal
    options:
      containers:
        kubePolicyController:
          version: v0.5.1
          location: calico/kube-policy-controller
        etcd:
          version: v3.0.9
          location: quay.io/coreos/etcd
        calicoCni:
          version: v1.4.2
          location: calico/cni
        calicoNode:
          version: v1.0.0-rc1
          location: quay.io/calico/node
        flannel:
          version: v0.6.1
          location: quay.io/coreos/flannel
      network:
        network: 10.128.0.0/10
        subnetLen: 22
        subnetMin: 10.128.0.0
        subnetMax: 10.191.255.255
        backend:
          type: vxlan
```

# Flannel options

# Options
## Root Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| containers | Required | Object | Container configurations |
| network | Required | Object | Network Fabric configuration |

## Container Configurations
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| calicoCni.location | Required | String | Location of the calico CNI Installer |
| calicoCni.version | Required | String | Version of the calico CNI installer |
| calicoNode.location | Required | String | Location of the calico node container |
| calicoNode.version | Required | String | Version of the calico node container |
| etcd.location | Required | String | Location of the etcd container |
| etcd.version | Required | String | Version of the etcd container |
| flannel.location | Required | String | Location of the flannel container |
| flannel.version | Required | String | Version of the flannel container |
| kubePolicyController.location | Required | String | Location of the kube policy container |
| kubePolicyController.version | Required | String | Version of the kube policy controller |

## Network Fabrice Configuration
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| network | Required | String | The CIDR for the subnet |
| subnetLen | Required | String | The length of the subnet |
| subnetMin | Required | String | The min portion of the subnet |
| subnetMax | Required | String | The max portion of the subnet |
| backend.type | Required | String | What should the backend transport be (vxlan, etc.) |

# Example
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

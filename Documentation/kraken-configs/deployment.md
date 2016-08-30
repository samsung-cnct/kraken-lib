#Deployment Configuration

The snippet configuration for deployments depends on the provider.

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| cluster | __Required__ | String | Name to use for the cluster created by this deployment |
| network | __Required__ | String | Cluster ip range CIDR |
| coreos | Optional | Object array | named CoreOS options array|
| keypair | Optional | Object Array | Array of key pairs to use in this deployment (in node pools and so on) |
| kubeConfig | __Required__ | Object Array | Array of [Kubernetes configurations](kubernetes.md) |
| containerConfig | __Required__ | Object Array | Array of [Container runtime configurations](container.md) |
| provider | __Required__ | String | Type of cluster provider, e.g. aws, vagrant, etc |
| providerConfig | __Required__ | Object | [Provider](deployments/README.md) - specific configuration section |
| master | __Required__ | Object | [Master](master.md) - specific configuration section |
| node | __Required__ | Object | [Nodes](nodes.md) - specific configuration section |
| clusterServices | __Required__ | Object | [Cluster services](clusterservices.md) - specific configuration section |
| etcd | __Required__ | Object | [etcd](nodes.md) - specific configuration section |


## coreos Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | Required | String | Name of this configuration|
| version | Optional | String | OS version. Specific version number or 'current'. Defaults to current |
| channel | Optional | String | OS update channel. Stable, alpha, beta. Defaults to beta |
| rebootStrategy | Optional | String | CoreOS reboot strategy values. etcd-lock, reboot, off. Defaults to off. |

## keypair Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | Keypair name |
| publicKeyFile | Optional | String | Path to public key material. |
| publickey | Optional | String | Public key material. |


# Prototype
```yaml
  deployment:
    cluster: myCluster
    coreos:
      -
        name: allNodes
        version: current
        channel: beta
        rebootStrategy: off
    keypair:
      -
        name: kraken-testing
        publickeyFile:
        publickey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5l7G63qrQZX/JomlW4jL6JP8ZIWVuQboRcBmD8AzQC5L/z2wBpfw9URGonreBNfiA/ASZ9XndKc4THj3D4a0jd87hlwwRRaL8m5cYvU4J5g2224FRbOhmvxItmrwDE1pIK/wkvZbgyhTtgNW3B+nmTmhni1q3GRH+TmXwE6OT6pcoUdvraMbMoSBeUsserwAGxc0GnEp+LPESfrNLSP5+DRcg/JpqFNE+Teg6SV3F98l0DPAW1/BEGQcuCPv2XOZ3QKaz3WUR9CRiC7oIRGRL8LL8j3DTM7mJX9EDE4J94fqBDAMYV0vpQgTHxwP3nj62CeUcwNGnWyPOOiM1TquD dummy@donotuse.io
    kubeConfig:
      # kubernetes configurations
    containerConfig:
      # container runtime configurations
    provider: aws
    providerConfig:
      # Provider-Specific Configuration Data
    master:
      # master config
    node:
      # node config
    clusterServices:
      # cluster services config
    etcd:
      # etcd config
```


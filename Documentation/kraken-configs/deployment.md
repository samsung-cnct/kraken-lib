#Deployment Configuration

The snippet configuration for deployments depends on the provider.

# Options

## Root Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| cluster | __Required__ | String | Name to use for the cluster created by this deployment |
| resourcePrefix | Optional | String | Tagging and naming prefix for providers that need it. |
| serviceCidr | __Required__ | String | Cluster service ip range CIDR |
| serviceDNS | __Required__ | String | Cluster (kubedns) service IP <br>Also mus be st in `cluster.dnsConfig.kubedns.cluster_ip` |
| clusterDomain | __Required__ | String | Domain name for cluster (internal resolution) <br>Also mus be st in `cluster.dnsConfig.kubedns.dns_domain` |
| coreos | Optional | Object array | named CoreOS options array|
| keypair | Optional | Object Array | Array of key pairs to use in this deployment (in node pools and so on) |
| kubeConfig | __Required__ | Object Array | Array of [Kubernetes configurations](kubernetes.md) |
| containerConfig | __Required__ | Object Array | Array of [Container runtime configurations](container.md) |
| provider | __Required__ | String | Type of cluster provider, e.g. aws, etc |
| providerConfig | __Required__ | Object | provider configuration section |
| master | __Required__ | Object | [Master](master.md) - specific configuration section |
| node | __Required__ | Object | [Nodes](nodes.md) - specific configuration section |
| clusterServices | __Required__ | Object | [Cluster services](clusterservices.md) - specific configuration section |
| etcd | __Required__ | Object | [etcd](nodes.md) - specific configuration section |
| readiness | __Required__ | Object | When is cluster considered to be ready. Defaults to 'exact' with 600 second total wait. |
| auth | Optional | Object | Master admin authentication. Defaults to admin:<random character string> |


## auth Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | Required | String | Name of this configuration|
| user | Optional | String | Username. Defaults to 'admin' |
| password | Optional | String | Password. Defaults to a random character string 11 characters long. |

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
| publickeyFile | Optional | String | Path to public key material. |
| publickey | Optional | String | Public key material. |
| privatekeyFile | Optional | String | Path to private key. |
| providerConfig | Optional | Object | [Provider](keypair/README.md)-specific configuration. |

## readiness Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| type | __Required__ | String | Type of check: 'exact' 'percent' 'delta' |
| value | Optional | Integer | For percent - what percentage of nodes currently up from total node count is a healthy cluster (Default - 100). For delta - allowed difference between expected and current node count (default 0) |
| wait | Optional | Integer | Wait for how many seconds total |

## providerConfig Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| type | Optional | String | Type of provider. cloudinit or autonomous. Autonomous providers do not require cloud init configuration. Defaults to cloudinit |
| ... | __Required__ | Object | [Provider](deployments/README.md) - specific configuration section |

# Prototype

```yaml
  deployment:
    cluster: myCluster
    serviceCidr: 10.32.0.0/12
    serviceDNS: 10.32.0.2
    clusterDomain: cluster.local
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
      type: cloudinit
      # Provider-Specific Configuration Data
    master:
      # master config
    node:
      # node config
    clusterServices:
      # cluster services config
      kubedns:
        namespace: kube-system
        cluster_ip: 10.32.0.2
        dns_domain: cluster.local
    etcd:
      # etcd config
```

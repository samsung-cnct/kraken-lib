#Kraken nodepools

All instances in the cluster are to be described within the node pool.

Examples would include

* Instances used for etcd
* Instance used for non-HA master
* Instances used for specific worker loads

Each node pool is given a name that is referenced elsewhere in the configuration for the cluster.

We do not expect the same machine types to be used for each purpose, therefore each node pool will have information specific to its hardware provider (public cloud, local, bare metal, etc.)

#Sections

##name

name of the nodepool

##number

number of nodes in the nodepool

##sshKeyName

Indicates what ssh key should be able to SSH in. Lack of setting this indicates nobody should be able to log in.

##providerConfig

[Provider](nodepool/README.md) - specific node configuration 

##kubernetes

Kubernetes - specific node configuration

###version

Kubernetes version

###mode

How to run kubernetes components. Binary or container

###labels

Array of kubernetes labels to apply to node

## container

Information on container runtime to use

###runtime

Currently only docker is supported

###version

runtime version

# Prototype
```yaml
nodepools:
  - 
    name: master
    number: 3
    providerConfig:
      ...
    sshKeyName: master-key
    kubernetes:
      version: 1.3.2
      mode: container
    container:
      runtime: docker
      version: 1.11.1
  -
    name: etcd_cluster
    number: 3
    sshKeyName: etcd-key
    providerConfig:
      ...
    kubernetes:
      version: 1.3.2
      mode: container
    container:
      runtime: docker
      version: 1.11.1 
  -
    name: cluster_nodes
    number: 20
    sshKeyName: node-key
    providerConfig:
      ...
    kubernetes:
      version: 1.3.2
      mode: container
      labels:
        - 
          name: kind
          value: "etcd state"
    container:
      runtime: docker
      version: 1.11.1 
```
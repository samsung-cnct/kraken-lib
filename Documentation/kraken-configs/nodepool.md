#Kraken nodepools

Configures nodepools to be used by various kraken node types

#Sections

##name

name of the nodepool

##number

number of nodes in the nodepool

##configuration

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
    configuration:
      ...
    kubernetes:
      version: 1.3.2
      mode: container
    container:
      runtime: docker
      version: 1.11.1
  -
    name: etcd_cluster
    number: 3
    configuration:
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
    configuration:
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
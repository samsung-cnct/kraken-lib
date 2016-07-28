#Kubernetes master configuration

Configures kubernetes master

#Sections

##nodepool 

Name of the [nodepool](nodepool.md) to use for master

##loadbalancer

Type of loadbalancer to use if ha is enabled. cloud or nginx. Some loadbalncers might not be compatible with some providers

# Prototype
```yaml
master: 
  nodepool: master
  loadbalancer: cloud 
```
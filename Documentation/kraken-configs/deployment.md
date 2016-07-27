#Deployment Configuration

The snippet configuration for deployments depends on the provider.

#Sections

##name

Name to use for the cluster created by this deployment

##coreos

CoreOS options 

###version

OS verison. Specific verison number or 'latest'

###channel 

OS update channel. Stable, alpha, beta

###rebootStrategy

CoreOS reboot strategy values. etcd-lock, reboot, off


##provider

Type of cluster provider, e.g. aws, vagrant, etc

##configuration

Provider - specific configuration section

# Prototype
```yaml
  deployment:  
    name: myCluster
    coreos:
      version: latest
      channel: beta
      rebootStrategy: off
    provider: aws
    configuration:
      # Provider-Specific Configuration Data      
```


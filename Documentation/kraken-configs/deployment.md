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

##keypairs

Array of key pairs to use in this deployment (in node pools and so on)

###name 

Keypair name

###publicKeyFile

Path to public key material. Optional

###publickey

Public key material. Optional

##provider

Type of cluster provider, e.g. aws, vagrant, etc

##configuration

[Provider](deployments/README.md) - specific configuration section

# Prototype
```yaml
  deployment:  
    name: myCluster
    coreos:
      version: latest
      channel: beta
      rebootStrategy: off
    keypairs:
      -
        name: kraken-testing
        publickeyFile: 
        publickey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5l7G63qrQZX/JomlW4jL6JP8ZIWVuQboRcBmD8AzQC5L/z2wBpfw9URGonreBNfiA/ASZ9XndKc4THj3D4a0jd87hlwwRRaL8m5cYvU4J5g2224FRbOhmvxItmrwDE1pIK/wkvZbgyhTtgNW3B+nmTmhni1q3GRH+TmXwE6OT6pcoUdvraMbMoSBeUsserwAGxc0GnEp+LPESfrNLSP5+DRcg/JpqFNE+Teg6SV3F98l0DPAW1/BEGQcuCPv2XOZ3QKaz3WUR9CRiC7oIRGRL8LL8j3DTM7mJX9EDE4J94fqBDAMYV0vpQgTHxwP3nj62CeUcwNGnWyPOOiM1TquD dummy@donotuse.io
    provider: aws
    configuration:
      # Provider-Specific Configuration Data      
```


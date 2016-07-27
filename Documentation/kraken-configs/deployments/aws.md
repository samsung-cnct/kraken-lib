# AWS Deployment Configuration

This snippet will describe an AWS configuration for deployment

# Sections

## region

Region will describe what region you want your cluster to be created in.  Currently we only support one AWS region per cluster

Examples include `us-east-1` and `us-west-2`

## subnets

Subnets describe 

# Prototype
```yaml
    provider: aws
    configuration:
      # Provider-Specific Configuration Data
      resourcePrefix: mrrobot
      region: us-east-1
      subnets:
        - 
          az: us-east-1a
          ipStart: 10.0.1.0
          netmask: 255.255.255.0
        -
          az: us-east-1b
          ipStart: 10.0.2.0
          netmask: 255.255.255.0
        - 
          az: us-east-1c
          ipStart: 10.0.3.0
          netmask: 255.255.255.0
      authentication:
        accessKey: abc123
        accessSecret: xyz789
        credentialsFile: 
        credentialsProfile:
      keypairs:
        -
          name: kraken-testing
          publickeyFile: 
          publickey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5l7G63qrQZX/JomlW4jL6JP8ZIWVuQboRcBmD8AzQC5L/z2wBpfw9URGonreBNfiA/ASZ9XndKc4THj3D4a0jd87hlwwRRaL8m5cYvU4J5g2224FRbOhmvxItmrwDE1pIK/wkvZbgyhTtgNW3B+nmTmhni1q3GRH+TmXwE6OT6pcoUdvraMbMoSBeUsserwAGxc0GnEp+LPESfrNLSP5+DRcg/JpqFNE+Teg6SV3F98l0DPAW1/BEGQcuCPv2XOZ3QKaz3WUR9CRiC7oIRGRL8LL8j3DTM7mJX9EDE4J94fqBDAMYV0vpQgTHxwP3nj62CeUcwNGnWyPOOiM1TquD dummy@donotuse.io
```


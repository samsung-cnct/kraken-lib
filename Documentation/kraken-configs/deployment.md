#Deployment Configuration

The snippet configuration for deployments depends on the provider.

# Prototype
```yaml
  deployment:
    provider: aws
    configuration:
      # Provider-Specific Configuration Data
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
```


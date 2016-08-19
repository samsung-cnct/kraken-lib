# Flannel options

# Options
## Root Options

Options dictionary gets converted directly to flannel json options blob

# Example
```yaml
  fabric:
    provider: flannel
    options:
      Network: 10.1.0.0/16
    Backend:
      Type: aws-vpc
```


#Kubernetes labels configurations

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | label key |
| value | __Required__ | String | label value |


# Example
```yaml
kubeLabels:
    - 
      name: blah
      value: you
```
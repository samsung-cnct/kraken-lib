#Kubernetes configurations

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | Configuration name |
| version | __Required__ | String | Kubernetes version |
| hyperkubeLocation | __Required__ | String | URL to hyperkube |

# Example
```yaml
kubeConfig:
  - 
    name: masterconfig
    version: 1.3.2
    hyperkubeLocation: gcr.io/google_containers/hyperkube
  -
    name: nodeconfig
    version: 1.2.5
    hyperkubeLocation: gcr.io/google_containers/hyperkube
```

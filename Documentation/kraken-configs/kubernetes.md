#Kubernetes configurations

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | Configuration name |
| version | __Required__ | String | Kubernetes version |
| containerConfig | Optional | String | Name of a [Container runtime configuration](container.md)  |

# Example
```yaml
kubeConfig:
  - 
    name: masterconfig
    version: 1.3.2
    containerConfig: dockerconfig
  -
    name: nodeconfig
    version: 1.2.5
    containerConfig: dockerconfig
```
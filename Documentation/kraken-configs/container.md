#Container runtime configurations

# Options
## Root Options
| Key Name | Required | Type | Description|
| name | __Required__ | String | Configuration name |
| version | __Required__ | String | Kubernetes version |
| runtime | Optional | String | Name of container runtime. At this time only docker is supported |

# Example
```yaml
containerConfig:
  - 
    name: dockerconfig
    version: 1.11.1
    runtime: docker
  -
    name: old-docker
    version: 1.9.2
    runMode: docker
```
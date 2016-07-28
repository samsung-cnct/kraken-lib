#Kubernetes configurations

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | Configuration name |
| version | __Required__ | String | Kubernetes version |
| runMode | Optional | String | Run kubernetes components as 'binary' or 'container'. Defaults to 'container' |
| containerConfig | Optional | String | Name of a [Container runtime configuration](container.md)  |
| labels | Optional | Object array | Array of kubernetes labels |


##labels options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| key | __Required__ | String | Label name |
| value | __Required__ | String | Label value |

# Example
```yaml
kubeConfig:
  - 
    name: masterconfig
    version: 1.3.2
    runMode: container
    containerConfig: dockerconfig
  -
    name: nodeconfig
    version: 1.2.5
    labels:
      - key: role
        value: doesStuff
      - key: price
        value: high
    runMode: binary
```
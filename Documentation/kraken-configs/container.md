# Container runtime configurations

# Options
## Root Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | Configuration name |
| runtime | Optional | String | Name of container runtime. At this time only docker is supported |

# Example
```yaml
containerConfig:
  - 
    name: dockerconfig
    runtime: docker
  -
    name: old-docker
    runtime: docker
```
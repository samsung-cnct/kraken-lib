# Kubernetes cluster services configuration

Cluster services are helm charts to be installed on cluster startup

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| repos | __Required__ | Object array | Array of helm repositories |
| services | __Required__ | Object array | Array of helm charts |
| namespaces | __Required__ | String array | Array namespaces to be created prior to installing services |

## repos Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | Repository name |
| url | __Required__ | String | Repository address |

# services Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | Chart release name |
| repo | __Required__ | String | Repository name for the chart |
| chart | __Required__ | String | Chart name with version |

# Example
```yaml
clusterServices: 
  namespaces:
    - kube-system
  repos: 
    -
      name: atlas
      url: http://atlas.cnct.io
    -
      name: official
      url: http://helm.kubernetes.io
  services:
    -
      name: kubedns
      repo: atlas
      chart: kubedns-0.1.0
    -
      name: alpine
      repo: official
      chart: alpinebase-1.1.2

```
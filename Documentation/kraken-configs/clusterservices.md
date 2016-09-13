# Kubernetes cluster services configuration

Cluster services are helm charts to be installed on cluster startup

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| repos | __Required__ | Object array | Array of helm repositories |
| services | __Required__ | Object array | Array of helm charts |
| namespaces | Optional | String array | Array namespaces to be created prior to installing services |

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
| values | Optional | Object | Chart values |

# Example
```yaml
clusterServices:
    repos:
      -
        name: atlas
        url: http://atlas.cnct.io
    services:
      -
        name: kubedns
        repo: atlas
        chart: kubedns-0.1.0
        values:
          cluster_ip: 10.32.0.2
          dns_domain: krakenCluster.local

```
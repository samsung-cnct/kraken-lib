# Kubernetes Helm configuration

These are helm charts to be installed on cluster startup.

## Options
### Root Options
| Key Name   | Required     | Type         | Description|
| ---------- | ------------ | ------------ | --- |
| repos      | Optional     | Object array | Array of helm repositories |
| registries | Optional   | Object array | Array of helm app registries |
| charts     | __Required__ | Object array | Array of helm charts |

### Repos Options
| Key Name | Required     | Type   | Description|
| -------- | ------------ | ------ | ----- |
| name     | __Required__ | String | Repository name |
| url      | __Required__ | String | Repository address |

### Registries Options

This is only required if you need access to private charts within the registry.

| Key Name | Required     | Type   | Description|
| -------- | ------------ | ------ | ----- |
| name     | __Required__ | String | Registry name |
| username | __Required__ | String | Registry username |
| password | __Required__ | String | Registry password |

### Charts Options
| Key Name                 | Required     | Type   | Description|
| ---------                | ------------ | ------ | --- |
| name                     | __Required__ | String | Chart release name |
| repo __OR__ registry     | __Required__ | String | Repository name for the chart |
| chart                    | __Required__ | String | Chart name |
| version                  | __Required__ | String | Chart version |
| namespace                | Optional     | String | Kubernetes namespace to install chart into. Defaults to 'default' |
| values                   | Optional     | Object | Chart values |

###  Example
```yaml
helmConfigs:
  - &defaultHelm
    name: defaultHelm
    kind: helm
    repos:
      - name: atlas
        url: http://atlas.cnct.io
      - name: stable
        url: https://kubernetes-charts.storage.googleapis.com
    registries:
      - name: quay.io
        username: samsung_cnct+helmro
        password: 12345
    charts:
      - name: heapster
        registry: quay.io
        chart: samsung_cnct/heapster
        version: 0.1.0
        namespace: kube-system
      - name: central-logging
        repo: atlas
        chart: central-logging
        version: 0.2.0
      - name: kubedns
        repo: atlas
        chart: kubedns
        version: 0.1.0
        namespace: kube-system
        values:
          cluster_ip: 10.32.0.2
          dns_domain: krakenCluster.local
```

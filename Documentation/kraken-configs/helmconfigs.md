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
| version __OR__ channel   | __Required__ | String | Chart version or channel ( channel used with registry only )|
| namespace                | Optional     | String | Kubernetes namespace to install chart into. Defaults to 'default' |
| values                   | Optional     | Object | Chart values |

###  Example
```yaml
helmConfigs:
  - &defaultHelm
    name: defaultHelm
    kind: helm
    repos:
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
      - name: curator
        registry: quay.io
        chart: samsung_cnct/curator
        channel: stable
```

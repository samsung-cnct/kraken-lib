# KubeConfig

Options for which version and build of kubernetes to use. Any version of kubernetes that is built and shipped in the "hyperkube" format can be used.

## Options
### Root Options
| Key Name          | Required     | Type | Description|
| ----------------- | ------------ | --- | --- |
| name              | __Required__ | String | Configuration name |
| kind              | __Required__ | String | kubernetes |
| version           | __Required__ | String | Kubernetes version |
| hyperkubeLocation | __Required__ | String | URL to hyperkube |

## Example
```yaml
kubeConfigs:
  - &defaultKube
    name: defaultKube
    kind: kubernetes
    version: v1.5.6
    hyperkubeLocation: gcr.io/google_containers/hyperkube
```

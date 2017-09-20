# Scheduling Configuration for nodePools

## Taints
Taints and tolerations work together to ensure that pods are not scheduled onto inappropriate nodes. One or more taints are applied to a node; this marks that the node should not accept any pods that do not tolerate the taints. Tolerations are applied to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints.

## [Taint Options](https://kubernetes.io/docs/user-guide/kubectl/v1.7/#taint)
| Key Name       | Required     | Type         | Description  |
| -------------- | ------------ | ----------   | ------------ |
| key            | __Required__ | string       | must match key when adding toleration to pod |
| value          | __Required__ | string       | Can be "" if no value desired |
| effect         | __Required__ | string       | must be NoSchedule, PreferNoSchedule or NoExecute |

## Example
```yaml
definitions:
  ...
  schedulingConfigs:
    - &defaultScheduling
      name: defaultScheduling
      kind: scheduling
      taints:
        - key: testKey
          value: testValue
          effect: NoSchedule
```

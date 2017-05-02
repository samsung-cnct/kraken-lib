# OS Configuration

## Options
| Key Name | Required     | Type    | Description  |
| -------- | ------------ | ------  | ------------ |
| type     | __Required__ | String  | Operating System |
| version  | __Required__ |         |              |
| channel  |              |         |              |
| rebootStrategy |        |         |              |     


```yaml
osConfigs:
  - &defaultCoreOs
    name: defaultCoreOs
    kind: os
    type: coreOs
    version: current
    channel: stable
    rebootStrategy: "off"
```

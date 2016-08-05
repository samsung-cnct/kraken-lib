# Network Fabric configruation

The snippet configuration for network fabrics depending on the provider.

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| provider | Optional | String | Name of a network fabric provider. flannel or calico. Defaults to flannel |
| options | Optional | Object | [Network fabric provider ](fabric) options|

# Example

```yaml
fabric:
 provider: flannel
 options:
  
```
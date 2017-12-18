# DNS Configuration

## Options
### Root Options
| Key Name | Required     | Type    | Description  |
| -------- | ------------ | ------  | ------------ |
| name     | __Required__ | String  | Name for DNS |
| kind     | __Required__ | String  | Dns          |
| kubedns  | __Required__ | Object  | Kubedns info |


### KubeDNS Options
| Key Name   | Required     | Type   | Description |
| ---------- | ------------ | ------ | ----------- |
| cluster_ip | __Required__ | String | This should be the same as the IP set in the deployment.clusters[x].dns in the main configuration file |        
| dns_domain | __Required__ | String | This should be the same as the domain set in deployment.clusters[x].domain in the main configuration file |
| namespace  | __Required__ | String | Kubernetes is expecting DNS to be in kube-system |

## Example
```yaml
dnsConfig:
  - &defaultDns
    name: defaultDns
    kind: dns
    kubedns:
      cluster_ip: 10.32.0.2
      dns_domain: cluster.local
      namespace: kube-system
```

Reminder that cluster_ip and dns_domain should match dns and domain in the deployment section of the config:
```yaml
deployment:
  clusters:
    - name:
      network: 10.32.0.0/12
      dns: 10.32.0.2
      domain: cluster.local
```

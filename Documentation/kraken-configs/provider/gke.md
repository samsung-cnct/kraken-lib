# GKE Deployment Configuration

## Options
### Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| clusterIpv4Cidr         | Optional | String | The IP address range of the container pods in this cluster. |
| disableAddons           | Optional | String Array | List of cluster addons to disable. Options are HttpLoadBalancing,HorizontalPodAutoscaling |
| disableCloudLogging     | Optional | Boolean | Do not send logs from the cluster to the Google Cloud Logging API. Enabled by default |
| disableCloudMonitoring  | Optional | Boolean | Do not send metrics from pods in the cluster to the Google Cloud Monitoring API |
| disableHTTPLoadbalancer | Optional | Boolean | disable HttpLoadBalancing addon |
| disableHorizontalAutoscaler | Optional | Boolean | disable HorizontalPodAutoscaling addon |
| enableKubernetesAlpha   | Optional | Boolean | Enable kubernetes alpha features. Will cause cluster to be deleted after 30 days. (false) |
| network                 | Optional | String | The Compute Engine Network that the cluster will connect to. Defaults to 'default' |
| password                | Optional | String | The password to use for cluster auth. Defaults to a server-specified randomly-generated string |
| subnetwork              | Optional | String | he name of the Google Compute Engine subnetwork |
| username                | Optional | String | The user name to use for cluster auth. Defaults to 'admin' |
| zone                    | __Required__ | Object | Information on cluster zones |
| project                 | __Required__ | String  | Name of the Google Cloud project to use |
| keypair                 | __Required__ | String | Name of a keypair object |
| kubeConfig              | Optional | String | Name of a [kubeConfig](../kubernetes.md) object. Only name and version number are relevant |


### zone options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| primaryZone | __Required__ | String | Zone for the primary nodepool |
| additionalZones | Optional | String Array | Array of additional zones |


## Example

```yaml
providerConfigs:
    - &defaultGKE
      name: defaultGKE
      kind: provider
      provider: gke
      type: autonomous
      project: k8s-work
      keypair: *defaultGKEKeyPair
      zone:
        primaryZone: us-central1-a
        additionalZones:
          - us-central1-b
          - us-central1-c
```

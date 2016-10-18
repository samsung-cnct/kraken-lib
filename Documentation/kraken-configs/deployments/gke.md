# GKE Deployment Configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| disableAddons | Optional | String Array | List of cluster addons to disable. Options are HttpLoadBalancing,HorizontalPodAutoscaling |
| disableCloudLogging | Optional | Boolean | Do not send logs from the cluster to the Google Cloud Logging API. Enabled by default |
| disableCloudMonitoring | Optional | Boolean | Do not send metrics from pods in the cluster to the Google Cloud Monitoring API |
| network | Optional | String | The Compute Engine Network that the cluster will connect to. Defaults to 'default' |
| password | Optional | String | The password to use for cluster auth. Defaults to a server-specified randomly-generated string |
| subnetwork | Optional | String | he name of the Google Compute Engine subnetwork |
| username | Optional | String | The user name to use for cluster auth. Defaults to 'admin' |
| nodepool | __Required__ | String | Name of the [nodepool](nodepools/README.md) to use as the primary cluster nodepool |
| zone | __Required__ | Object | Information on cluster zones |
| project | __Required__ | String  | Name of the Google Cloud project to use |
| region | __Required__ | String  | Name of the Google Cloud region to use |
| authentication | __Required__ | Object | Authentication info for GKE |

## authentication options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| serviceAccount | __Required__ | String | Service account name, i.e serviceaccount@project-name.iam.gserviceaccount.com |
| serviceAccountKeyFile | __Required__ | String | Service acount key file. |
| serviceAccountPasswordFile | Optional | String | Service acount key file password. Only relevant for p12-formatted key files. |

## zone options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| primaryZone | __Required__ | String | Zone for the primary nodepool |
| additionalZones | Optional | String Array | Array of additional zones |


# Example
```yaml
    provider: gke
    providerConfig:
      password: Dfae4@3dAF#SF;;O
      username: adm1n
      nodepool: defaultPool
      proejct: my-gce-project
      region: us-central1 
      authentication:
        serviceAccount: serviceaccount@my-gce-project.iam.gserviceaccount.com
        serviceAccountKeyFile: /path/to/serviceaccount-key.json
      zone:
        zone: us-central1-a
        additionalZones: 
          - us-central1-b
          - us-central1-c
```


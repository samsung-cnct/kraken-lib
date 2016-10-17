# GKE Deployment Configuration

# Options
## Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| disableAddons | Optional | String Array | List of cluster addons to disable. Options are HttpLoadBalancing,HorizontalPodAutoscaling |
| disableCloudEndpoints | Optional | Boolean | Disable Google Cloud Endpoints to take advantage of API management features. Enabled by default |
| disableCloudLogging Optional | Boolean | Do not send logs from the cluster to the Google Cloud Logging API. Enabled by default |
| network | Optional | String | The Compute Engine Network that the cluster will connect to. Defaults to 'default' |
| password | Optional | String | The password to use for cluster auth. Defaults to a server-specified randomly-generated string |
| subnetwork | Optional | String | he name of the Google Compute Engine subnetwork |
| username | Optional | String | The user name to use for cluster auth. Defaults to 'admin' |
| nodepool | __Required__ | String  | Name of the [nodepool](nodepools/README.md) to use as the primary cluster nodepool |
| project | __Required__ | String  | Name of the Google Cloud project to use |
| region | __Required__ | String  | Name of the Google Cloud region to use |
| authentication | __Required__ | Object | Authentication info for GKE |

## authentication options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| serviceAccount | __Required__ | String | Service account name, i.e serviceaccount@project-name.iam.gserviceaccount.com |
| serviceAccountKeyFile | __Required__ | String | Service acount key file. |
| serviceAccountPasswordFile | Optional | String | Service acount key file password. Only relevant for p12-formatted key files. |




# Example
```yaml
    provider: gke
    providerConfig:
      password: Dfae4@3dAF#SF;;O
      username: adm1n
      nodepool: defaultPool
      proejct: my-gce-project
      region: us-west1-a 
      authentication:
        serviceAccount: abc123
        accessSecret: xyz789
        credentialsFile: 
        credentialsProfile:
      certs:
        serviceAccount: serviceaccount@my-gce-project.iam.gserviceaccount.com
        serviceAccountKeyFile: /path/to/serviceaccount-key.json
```


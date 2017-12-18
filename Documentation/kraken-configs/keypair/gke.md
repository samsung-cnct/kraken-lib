# GKE specific node configuration

## Options
### Root Options
| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| username | Optional | String | GCE user name for the privatekeyFile/publickeyFile. I.e. 'core' |
| serviceAccount | Optional | String | Service account name, i.e serviceaccount@project-name.iam.gserviceaccount.com |
| serviceAccountKeyFile | Optional | String | Service account key file. |
| serviceAccountPasswordFile | Optional | String | Service account key file password. Only relevant for p12-formatted key files. |

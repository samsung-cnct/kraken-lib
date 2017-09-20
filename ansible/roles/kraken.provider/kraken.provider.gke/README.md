Role Name
=========

kraken.provider.gke


Example provider configuration
----------------

```
---
deployment:
  cluster: your-gke-cluster
  keypair:
    -
      name: k2key
      providerConfig:
        serviceAccount: "your-service-account@developer.gserviceaccount.com"
        serviceAccountKeyFile: "{{ '~/.ssh/your-service-account-key.json' }}"
  provider: gke
  providerConfig:
    type: autonomous
    nodepool: default
    project: your-gcloud-project
    keypair: k2key
    zone:
      primaryZone: us-central1-a
      additionalZones:
        - us-central1-b
        - us-central1-c
  nodepool:
    -
      name: default
      count: 3
      providerConfig:
        diskSize: 100
        machineType: n1-standard-1
        scopes:
          - https://www.googleapis.com/auth/compute
          - https://www.googleapis.com/auth/devstorage.read_only
          - https://www.googleapis.com/auth/logging.write
          - https://www.googleapis.com/auth/monitoring
    -
      name: other
      count: 2
      providerConfig:
        diskSize: 100
        machineType: n1-standard-2
        scopes:
          - https://www.googleapis.com/auth/compute
          - https://www.googleapis.com/auth/devstorage.read_only
          - https://www.googleapis.com/auth/logging.write
          - https://www.googleapis.com/auth/monitoring
  clusterServices:
    repos:
      -
        name: atlas
        url: http://atlas.cnct.io
    services:
      -
        name: podpincher
        registry: quay.io
        chart: samsung_cnct/podpincher
        version: 0.1.0
```

License
-------

Apache 2.0

Author Information
------------------

Samsung CNCT

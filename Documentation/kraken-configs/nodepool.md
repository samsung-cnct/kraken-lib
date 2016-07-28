#Node Pools

All instances in the cluster are to be described within the node pool.

Examples would include

* Instances used for etcd
* Instance used for non-HA master
* Instances used for specific worker loads

Each node pool is given a name that is referenced elsewhere in the configuration for the cluster.

We do not expect the same machine types to be used for each purpose, therefore each node pool will have information specific to its hardware provider (public cloud, local, bare metal, etc.)

#Example Configuration
```yaml
- nodepools:
  - name: etcd
    provider-config: 
      azs:
        - az: us-east-1a
          count: 2
        - az: us-east-1b
          count: 2
        - az: us-east-1c
          count: 1
      instance-type: m3.medium
      ssh-key-name: etcd-cluster
  - name: etcd-2
    provider-config:
      count: 3
      instance-type: c4.large
      ssh-key-name: etcd-cluster
  - name: worker-pool-a
    provider-config:
      azs:
        - az: us-east-1a
          count: 10
      instance-type: c4.2xlarge
      ssh-key-name: k8s-cluster
  - name: worker-pool-b
    provider-config:
      azs:
        - az: us-east-1b
          count: 20
      instance-type: c4.xlarge
      ssh-key-name: k8s-cluster
  - name: master-apiserver
    provider-config:
      azs:
        - az: us-east-1c
          count: 1
      ssh-key-name: k8s-cluster
```
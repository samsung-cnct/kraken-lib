# Definitions

These are the new definitions which are used throughout the configuration.
For specific configuration details, see [relevant files](README.md).


```yaml
version: v1
definitions:
  dnsConfig:
    - &defaultDns
      # dns configurations
  helmConfigs:
    - &defaultHelm
      # helm configuration
  fabricConfigs:
    - &defaultCanalFabric
      # fabric configuration
  kvStoreConfigs:
    - &defaultEtcd
    # etcd configurations
    - &defaultEtcdEvents
      # etcd events configuration
  apiServerConfigs:
    - &defaultApiServer
      # api server configuration
  kubeConfigs:
    - &defaultKube
      # kubeConfigs
  containerConfigs:
    - &defaultDocker
      # container configuration
  osConfigs:
    - &defaultCoreOs
      # os Configs
  nodeConfigs:
    - &defaultAwsEtcdNode
      #etcd node configurations
    - &defaultAwsEtcdEventsNode
      # etcd events node configurations
    - &defaultAwsMasterNode
      # aws master node configuration
    - &defaultAwsClusterNode
      # cluster node configuration
    - &defaultAwsSpecialNode
      # cluster node configuration
  providerConfigs:
    - &defaultAws
    # provider configuration
  keyPairs:
   - &defaultKeyPair
      # keypair configuration
  kubeAuth:
   - &defaultKubeAuth
      #kubeAuth configuration
  schedulingConfigs:
   - &defaultScheduling
     # taint and label configurations
```

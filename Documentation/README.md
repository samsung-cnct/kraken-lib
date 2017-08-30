# Documentation

## Kraken Configuration File Format

kraken-lib configuration is done through a yaml file, and is broken up into two sections.  The top of the file will contain the definitions of the component stanzas and the bottom of the file will contain a list of clusters which are composed of the component stanzas.

### Definitions

* `definitions` - [Definitions of sections](kraken-configs/definitions.md)
  * `dns` - [dns configurations](kraken-configs/dns.md)
  * `helm` - [helm charts configuration](kraken-configs/helmconfigs.md)
  * `fabric` - [Network Fabric configuration](kraken-configs/fabric/README.md)
  * `kvStore` - [kvStore configuration](kraken-configs/kvstore.md)
  * `apiServer` - [apiServer configuration](kraken-configs/apiserver.md)
  * `kubeConfig` - [kubeConfigs](kraken-configs/kubeconfig.md)
  * `container` - [container configuration](kraken-configs/container.md)
  * `os` - [os configuration](kraken-configs/os.md)
  * `node` - [node configuration](kraken-configs/node/README.md)
  * `provider` -[provider configuration](kraken-configs/provider/README.md)
  * `keypairs` -[keyPair configuration](kraken-configs/keypair/README.md)
  * `kubeAuth` -[kubeAuth configuration](kraken-configs/kubeauth.md)

### Deployment

* `deployment` - [The core of the configuration](kraken-configs/deployment.md)

## Additional Guide For Developer

* [Upgrading to newer Kubernetes](./UPGRADING_KUBERNETES.md)

### Usage For Tags

* `tags` - [Usage for tags](tags/README.md)
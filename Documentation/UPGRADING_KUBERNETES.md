# Upgrading Kubernetes

Kubernetes features advance, evolve, and deprecate fast enough that CNCT needs
to support targeted configurations for each Kubernetes release.


## Configuration Branching

Example version notation: when Kubernetes releases 1.7, `N` means `v1.7`, while `N-1` means `v1.6`.

For each new release `N` of Kubernetes, we should:

1. Ensure that [Kraken-tools][1] is upgraded accordingly, to include `N`, `N-1`, and `N-2` binaries. Support for `N-3` will be removed.
2. Copy the kraken-lib default configuration to a directory `N-1`, representing functional configuration of the previous release-version.
3. [Update the cluster configuration templates](#updating-cluster-configuration) as below.
4. Test creation of clusters of `N` and `N-1` to confirm functional configurations.
5. Remove references to the `N-3` version, as it's no longer within our support policy pending adoption of the newly released version.

This repository also provides a few shortcuts to facilitate this:

```shell
# Copies the "default" templates to subdirectories named "v1.7"
# This requires a version expression [v<major>.<minor>].
sh hack/clone_version_config.sh copy_default v1.7
```

### Updating Cluster Configuration

Various parts of the cluster configuration have version-specific mapping. In
particular, the files `kraken.config/files/config.yaml` and `gke-config.yaml`
are probably of interest.

Examples:

```yaml
  kubeConfigs:
    - &defaultKube
      <<: *defaultKube19  #  this needs to be updated to the newest kube stanza
```

```yaml
 - &kubeVersionedFabric
      name: kubeVersionedFabric
      kind: versionedFabric
      type: canal
      kubeVersion:
        default: *defaultCanalFabric
        versions:
          v1.6: *defaultCanalFabric16
          v1.7: *defaultCanalFabric16
```

When introducing a new version of Kubernetes, preceding configuration details may
still be valid. If changes are necessary, copy the referenced block within the
YAML (e.g. `defaultCanalFabric16`), update its names and references accordingly
(e.g. rename to `defaultCanalFabric17`). *DO NOT* alter configuration of preceding
versions.

### Branch Naming
For ease of testing, any branch that updates the supported versions of kubernetes
should have 'test-all' in the branch name.  This will cause gitlab CI to excercise
all of the supported versions of kubernetes. 

[1]: https://github.com/samsung-cnct/kraken-tools

# Container runtime configurations

# Options
## Root Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | Configuration name |
| runtime | __Required__ | String | Name of container runtime. At this time only docker is supported |
| type | __Required__ | String | Type of docker installation. If not specified distro is assumed. |
| url | Depends | String | If type is not distro, URL where the installation medium can be found |

Type may be one of [distro, tgz]. If type is distro then the distribution provided installation of docker will be used. If type is tgz then url must be a valid url pointing to a gzipped tarball containing a single directory. The contents of the directory must include all binaries needed to install the container runtime. __These binaries will be placed in /opt/cnct/bin__ and systemd drop-ins will be generated to start the container runtime.

# Example 1
```yaml
containerConfig:
  - 
    name: dockerconfig
    runtime: docker
  -
    name: old-docker
    runtime: docker
```

#Example 2
```yaml
containerConfig:
  - 
    name: customDockerConfig
    runtime: docker
    type: tgz
    url: "https://s3-us-west-2.amazonaws.com/samsung-cnct-artifacts/docker-1.12.6%2B7ab89465.tgz"
```

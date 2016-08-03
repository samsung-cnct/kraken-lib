# etcd cloud-config snippets

Because etcd is being run through a container, there are a few requirements

* Container engine must be available
* Storage for etcd must be somewhere
    * We do not want to store the data in an overlay filesystem

We assume that ephemeral storage is available at `/ephemeral` on the host

## Container Engine Specifics

* [docker](docker.md)
* _[rkt](rkt.md)_

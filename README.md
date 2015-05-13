# kraken

## Overview
Deploy a __Kubernetes__ cluster using __Vagrant__ on top of __CoreOS__. You will also find tools here to build an __etcd__ cluster on __CoreOS__ and a __Docker__ playground all using __Vagrant__.

## Getting Started
 
Gather bits that you will to need deploy these systems on your machine.

 * [Virtualbox](https://www.virtualbox.org/)
 * [Vagrant](https://www.vagrantup.com/downloads.html)
 * __Docker__
 * __kraken__
 * `kubectl`
 * `fleetctl`
 * `etcdctl`

## kraken
Download __kraken__ into your working directory 

```bash
git clone git@github.com:Samsung-AG/kraken.git
cd kraken
```
## Docker
For Mac people, use `brew` to install Docker. Get `brew` [here](http://brew.sh/)

```bash
brew update
brew install docker
```

## Gems for helper kraken tool

Run bundler install from kraken folder

```bash
bundle install
```

### kubectl

Download and install the latest kubectl into your /opt directory.
You can locate the latest binaries [here](https://github.com/GoogleCloudPlatform/kubernetes/releases/latest)

```bash
cd /opt
curl -L https://github.com/GoogleCloudPlatform/kubernetes/releases/download/v0.13.2/kubernetes.tar.gz | tar xv
```

## Hacking
Deploy details and README's for each system are located within their respective folders.

### Helpful Links
* kubectl user documentation can be found [here](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/kubectl.md)
*  kubectl [FAQ](https://github.com/GoogleCloudPlatform/kubernetes/wiki/User-FAQ)

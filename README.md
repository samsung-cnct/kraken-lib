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

### Using LogEntries.com

**NOTE: current releases of systemd have [a bug introduced in systemd v220 that breaks journald HTTP gateway]( https://github.com/systemd/systemd/issues/506). This bug is now fixed, but at this time the latest systemd release (v222) does not have the fix merged yet. Last stable CoreOS release with systemd v219 is 681.2.0**

1. First, create an account on logentries.com.
2. Create a new log in your Logentries account by clicking + Add New Log.

 ![new log](https://d2rqpywgspga97.cloudfront.net/mstatic/1435755113/content/uploads/2015/03/Selection_049.png)
 
3. Next, select Manual Configuration.

 ![manual config](https://d2rqpywgspga97.cloudfront.net/mstatic/1435755113/content/uploads/2015/03/02manualconfig_small.png)
 
4. Give your log a name of your choice, select Token TCP, and then click the Register new log button. A token will be displayed in green.
5. Add the logentries section to the settings.yaml file of your cluster

        logentries:
            enabled: true
            url: api.logentries.com:20000
            token: <log entries token>

6. Run kraken [cluster name] up as usual. All journald logs will now be sent to logentries.com 

## Hacking
Deploy details and README's for each system are located within their respective folders.

### Helpful Links
* kubectl user documentation can be found [here](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/kubectl.md)
*  kubectl [FAQ](https://github.com/GoogleCloudPlatform/kubernetes/wiki/User-FAQ)

#Changelog

##86.0.0
###Features
* Checks for settings.yaml file
* Docker now runs without TLS

##83.0.0
###Features
* Added setting.sample.yaml for all configuration settings
* AWS Coreos AMI is not automatically configured
* Added kubernetes api version settings
* Improved AWS flannelconfiguration timing

###Bug
* .kubconfig is now automatically generated again

##80.0.0
###Features
* Added metrics collection and graphing
* Reorganized and collapsed AWS and local code
* Removed old kubernetes-ui code

###Bug fixes
* Guard against flanneld start up failures

##76.0.0
###Features
* Add environment settings for AWS Keypair

###Bug fixes
* Fixed bug where docker cache was no longer used

##74.1.0
###Features
* Add kubeconfig builder to Kubernetes clusters that are built locally

###Bug fixes
* Fixed bug where detecting AWS variables was not reliable

##74.0.0
###Features
* Add kube_cluster for AWS cluster deployment
* Add master 

##72.0.0
###Features
* Add guestbook example to boot process
* Ability to assign AWS EIP to master
* Ability to assign AWS EIP to node-01
* Ability to assign CIDR network to AWS cluster
* Ability to assign CIDR network to Virtual Box cluster
* Using kubernetes release 0.15.0
* SkyDNS with kube2skydns now on vagrant and AWS deploys
* Building a kubernetes on AWS or Virtual Box VMS uses the same cloud-config files

###Bug fixes
* Fixed occasional flannel failures by changing flannelconfig service dependency

##69.0.0
###Features
* Change version scheme to number of days since start of project followed by semantic versioning
* Bumped Kubernetes to release 0.15.0
* Bumped kube-register to 0.0.3
* Added healthz settings

##0.3.2
###Features
* Updated docker to 1.6.0

###Bug fixes
* Fixed docker cert generation

##0.3.1
###Features1
* Flannel builds using etcd2.0 native

##0.3.0
###Features
* Renamed kuburnetes vms from etcd-node and master-node to etcd and master respectively
* Docker cache is now on master
* Moved to using etcd2 native
* Add config-collector container on master
* Docker REST service is now listening on port 4243


###Bug fixes

##0.2.1
###Bug fixes
* Bug where pinning Coreos versions failed to work after previous changes

##0.2.0

###Features
* Added support for Kubernetes UI in the API server
* Added Kubernetes UI available at http://172.16.1.102:8900
* README clean up

###Bug fixes
* Corrected host IP Addresses in export file

##0.1.3

###Features

###Bug fixes
* disabled landrush to support windows users and because it may be causing some users to hang on ```vagrant <cmd>```

##0.1.2

##Features
* export for docker env settings added
* polishing READMEs some more

##0.1.1

###Features
* More README additions

###Bug fixes
* Fixed tls rebuild issue where tls wasn't being updated when docker was restarted

##0.1.0

###Features
* Updated to use Kubernetes release v0.14.2

###Bug fixes
#Changelog

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
# custom-jnlp image is for working around a jenkins bug

Jenkins Kubernetes job plugin gets confused when attempting to remote into different containers in a pod when there are several
build pipelines running.  This image adds kubectl to the base jnlp-slave image so that sh commands can be tunneled over a 
`kubectl exec` command.  Only sh commands are affected by this bug.

## How to build
There is makefile in this directory.  Run `make container` then `make push`.  By default both operations will use the TAG and
PREFIX values that are set in the makefile.  You can overide either at the command line using -e switches like so: 
`make container TAG=1.4`.  If you want to build and push the container, `make push` will do both.
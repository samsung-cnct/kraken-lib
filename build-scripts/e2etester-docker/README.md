# e2etester docker image is for running the e2etest suite against Kubernetes

The e2e-test suite has many options depending on which tests to run and what the underlying hardware is.  This image will execute
e2e conformance tests on aws.  It may work for other test suites and on other platforms but they have not been tested.

## How to build
There is makefile in this directory.  Run `make container` then `make push`.  By default both operations will use the TAG and
PREFIX values that are set in the makefile.  You can overide either at the command line using -e switches like so: 
`make container TAG=1.4`.  If you want to build and push the container, `make push` will do both.

## Why is it so large
Because the author has run out of time to go test any more.  Patches with a more minimal set of installs or source image is 
greatly welcome.
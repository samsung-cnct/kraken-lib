# Run without docker container / Local cluster   
It is possible to build a Kraken cluster without using docker-machine:

## Tools setup
Quick setup on OSX with [homebrew](http://brew.sh/) Ensure that you are in the Kraken file (cd kraken):

    brew update
    brew tap Homebrew/bundle
    brew bundle

This installs Ansible, Terraform, Vagrant, Virtualbox, kubectl, awscli and custom terraform providers 'terraform-provider-execute', 'terraform-provider-coreosbox'.  
If terraform is having trouble finding the custom providers, try explicitly uninstalling them and re-installing them, eg:

    for formula in $(grep 'brew.*terraform-provider' Brewfile | awk '{print $2}' | tr -d "'"); do
      brew uninstall $formula
    done
    brew bundle

## If you already have a hypervisor (Virtualbox, Vmware Fusion), ansible, AWS CLI installed:
* Install Terraform:

Access [https://www.terraform.io/downloads.html] to obtain the download for your OS. Unzip the archive, and copy all terraform* binaries in the uncompressed directory to ```/usr/local/bin```

* Install terraform-provider-execute:

```brew tap Samsung-AG/terraform-provider-execute```

```brew install terraform-provider-execute```

* Install terraform-provider-coreosbox

```brew tap Samsung-AG/terraform-provider-coreosbox```

```brew install terraform-provider-coreosbox```

* Install ```kubectl```

```brew install kubectl```

Alternative/non-OSX setup:

* Install [Ansible](https://github.com/ansible/ansible/releases)
* install awscli
* Install Terraform. Currently we are using a patched terraform version (PR is pending in terraform master). Get it [here](https://github.com/Samsung-AG/homebrew-terraform/releases)
* Install [Vagrant](https://www.vagrantup.com/downloads.html) if you will be working with a local cluster
* Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads) if you will be working with a local cluster
* Download/Build terraform-provider-execute. OSX 64bit binary is available [here](https://github.com/Samsung-AG/terraform-provider-execute/releases). Copy the terraform-provider-execute binary to the the folder in which Terraform binary resides in.
* Download/Build terraform-provider-coreos from https://github.com/bakins/terraform-provider-coreos. OSX 64bit binary is [here](https://github.com/Samsung-AG/homebrew-terraform-provider-coreos/releases/download/v0.0.1/terraform-provider-coreos.tar.gz)
* Download/Build terraform-provider-coreosver from https://github.com/Samsung-AG/terraform-provider-coreosver. OSX 64bit binary is [here](https://github.com/Samsung-AG/terraform-provider-coreosver/releases/download/v0.0.1/terraform-provider-coreosver_darwin_amd64.tar.gz)
* Download and install the latest [kubectl](https://github.com/GoogleCloudPlatform/kubernetes/releases/latest). Make sure 'kubectl' is in your PATH

## Create cluster.

Once you are done with tools setup and variable settings you should be able to create a cluster:

    terraform apply -input=false -state=terraform/<cluster type>/terraform.tfstate terraform/<cluster type>

For example, to create an AWS cluster:

    terraform apply -input=false -state=terraform/aws/terraform.tfstate terraform/aws

or (overriding node_count variable)

    terraform apply -input=false -state=terraform/aws/terraform.tfstate -var 'node_count=10' terraform/aws
    
or a local cluster: 

    terraform apply -input=false -state=terraform/local/terraform.tfstate terraform/local

If you don't specify the -state switch, terraform will write the current 'state' to pwd - which could be a problem if you are using multiple cluster types.

### Interact with your kubernetes cluster
Terraform will write a kubectl config file for you. To issue cluster commands just use

    kubectl <command>

for example

    kubectl get pods

To reach specific clusters, issue the follow command

    kubectl --cluster=<cluster_name> <command>

for example
    
    kubectl --cluster=aws_kubernetes get nodes
    
## Destroy Cluster
Destroy a running cluster by running:

    terraform destroy -input=false -state=terraform/<cluster type>/terraform.tfstate terraform/<cluster type>

## Optional remote setup for Terraform
You could setup [remote state](https://www.terraform.io/intro/getting-started/remote.html) for Terraform, if you want to be able to control your cluster lifecycle from multiple machines (only applies to non-local clusters)

## SSH to cluster nodes
Ansible provisioning creates a ssh config file for each cluster type in you .ssh folder. You can ssh to node names using this file:

    ssh -F ~/.ssh/config_<cluster_name> node-001
    ssh -F ~/.ssh/config_<cluster_name> master
    ssh -F ~/.ssh/config_<cluster_name> etcd

And so on

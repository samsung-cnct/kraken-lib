# Kraken
## Overview
Deploy a __Kubernetes__ cluster using __Terraform__  and __Ansible__ on top of __CoreOS__.

## Tools setup

    git clone git@github.com:Samsung-AG/kraken.git
    cd kraken

Quick setup on OSX with [homewbrew](http://brew.sh/):

    brew update
    brew tap Homebrew/bundle
    brew bundle


This installs Ansible, Terraform, Vagrant, Virtualbox, kubectl, awscli and custom terraform providers 'terraform-provider-execute', 'terraform-provider-coreosver' and 'terraform-provider-coreos'

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

## Variables setup

Create a terraform.tfvars file under the `kraken` folder.

File contents should be vairable pairs:

    vairable_name = variable_value

As described [here](https://www.terraform.io/intro/getting-started/variables.html). For local cluster you have to provide:

    cluster_name=<name of your cluster> 

For AWS cluster you __have__ to provide:

    cluster_name=<name of your cluster>
    aws_access_key="<your aws key id>"
    aws_secret_key="<your aws secret key>"
    aws_user_prefix="<prefix to use for named resources>"

Optionally, you can customize the cluster to better suite your needs by adding:

    apiserver_count = "<apiserver pool size>"
    node_count = "<number of kubernetes nodes>"

For better performance, you should consider adding and modifing the following configuration items:

    aws_etcd_type = "<aws instance type for etcd>"
    aws_storage_type_etcd = "<ephemeral>"

#### Ludicrous speed

Looking to create a **ludicrous** cluster? Use the following `terraform.tfvars`:

```
cluster_name="<your cluster name>"
aws_access_key="<your aws key id>"
aws_secret_key="<your aws secret key>"
aws_user_prefix="<prefix to use for named resources>"
apiserver_count = "10"
node_count = "1000"
aws_etcd_type = "i2.8xlarge"
aws_storage_type_etcd = "ephemeral"
aws_apiserver_type = "m4.4xlarge"
```
Alternatively, you can provide these variables as -var 'variable=value' switches to 'terraform' command.

All available variables to override and set are under

    terraform/<cluster type>/variables.tf

## Create cluster.

Once you are done with tools setup and variable settings you should be able to create a cluster:

    terraform apply -input=false -state=terraform/<cluster type>/terraform.tfstate terraform/<cluster type>

For example, to create an AWS cluster:

    terraform apply -input=false -state=terraform/aws/terraform.tfstate terraform/aws

or

    terraform apply -input=false -state=terraform/aws/terraform.tfstate -var 'node_count=10' terraform/aws

If you don't specify the -state switch, terraform will write the current 'state' to pwd - which could be a problem if you are using multiple cluster types.

Overriding the node_count variable.

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

## Using LogEntries.com

1. First, create an account on logentries.com.
2. Create a new log in your Logentries account by clicking + Add New Log.
3. Next, select Manual Configuration.
4. Give your log a name of your choice, select Token TCP, and then click the Register new log button. A token will be displayed in green.
5. Override logentries_token variable for your cluster type with the token value - either through a tfvars file or -var switch

## Create cluster from remote docker container

Instructions are in the [cluster](cluster) subfolder

### Helpful Links
* kubectl user documentation can be found [here](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/kubectl.md)
* kubectl [FAQ](https://github.com/GoogleCloudPlatform/kubernetes/wiki/User-FAQ)
* Kubernetes conformance test logs run after a PR is merged to this repo located at http://e2e.kubeme.io

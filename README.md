# Kraken

## Overview
Deploy a __Kubernetes__ cluster using __Terraform__  and __Ansible__ on top of __CoreOS__. You will also find tools here to build an __etcd__ cluster on __CoreOS__ and a __Docker__ playground all using __Vagrant__.

## Tools setup
 
    git clone git@github.com:Samsung-AG/kraken.git
    cd kraken
 
Quick setup on OSX with [homewbrew](http://brew.sh/):
    
    brew update
    brew tap Homebrew/bundle
    brew bundle
    
This installs Ansible, Terraform, Vagrant, Virtualbox, kubectl and a custom terraform provider 'terraform-provider-execute'

Alternative/non-OSX setup:

* Install [Ansible](https://github.com/ansible/ansible/releases)
* Install [Terraform](https://terraform.io/downloads.html)
* Install [Vagrant](https://www.vagrantup.com/downloads.html) if you will be working with a local cluster
* Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads) if you will be working with a local cluster
* Download/Build terraform-provider-execute. OSX 64bit binary is available [here](https://github.com/Samsung-AG/terraform-provider-execute/releases). Copy the terraform-provider-execute binary to the the folder in which Terraform binary resides in.
* Download and install the latest [kubectl](https://github.com/GoogleCloudPlatform/kubernetes/releases/latest). Make sure 'kubectl' is in your PATH

## Variables setup

Create a terraform.tfvars file under terraform/<cluster type> folder. For example, if you will be working with aws, use terraform/aws/terraform.tfvars

File contents should be vairable pairs:

    vairable_name = variable_value
    
As described [here](https://www.terraform.io/intro/getting-started/variables.html). Local cluster has no required variables. For AWS cluster you __have__ to provide:

    aws_access_key=<your aws key id>
    aws_secret_key=<your aws secret key>
    aws_user_prefix=<prefix to use for named resources>
    
Alternatively, you can provide these variables as -var 'variable=value' switches to 'terraform' command. 

All available variables to override and set are under 

    terraform/<cluster type>/variables.tf

## Create cluster.

Once you are done with tools setup and variable settings you should be able to create a cluster:
    
    terraform apply -input=false -state=terraform/<cluster type>/terraform.tfstate terraform/<cluster type>
    
For example, to create an AWS cluster:

    terraform apply -input=false -state=terraform/local/terraform.tfstate terraform/local
    
or 

    terraform apply -input=false -state=terraform/aws/terraform.tfstate -var 'node_count=10' terraform/aws

If you don't specify the -state switch, terraform will write the current 'state' to pwd - which could be a problem if you are using multiple cluster types. 
    
Overriding the node_count variable.

### Interact with your kubernetes cluster
Terraform will write a kubectl config file for you. To issue cluster commands just use 

    kubectl --cluster=<cluster type> <command>
    
for example

    kubectl --cluster=aws get pods

## Destroy Cluster
Destroy a running cluster by running:

    terraform destroy -input=false -state=terraform/<cluster type>/terraform.tfstate terraform/<cluster type>

## Optional remote setup for Terraform
You could setup [remote state](https://www.terraform.io/intro/getting-started/remote.html) for Terraform, if you want to be able to control your cluster lifecycle from multiple machines (only applies to non-local clusters)

## Using LogEntries.com

1. First, create an account on logentries.com.
2. Create a new log in your Logentries account by clicking + Add New Log.
3. Next, select Manual Configuration.
4. Give your log a name of your choice, select Token TCP, and then click the Register new log button. A token will be displayed in green.
5. Override logentries_token variable for your cluster type with the token value - either through a tfvars file or -var switch

### Helpful Links
* kubectl user documentation can be found [here](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/kubectl.md)
*  kubectl [FAQ](https://github.com/GoogleCloudPlatform/kubernetes/wiki/User-FAQ)

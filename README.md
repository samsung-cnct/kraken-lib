# Kraken
## Overview
Deploy a __Kubernetes__ cluster using __Terraform__  and __Ansible__ on top of __CoreOS__.

## Tools setup
Install [docker toolbox](https://www.docker.com/docker-toolbox), or just docker-machine and docker client separately.  
Then:

    git clone git@github.com:Samsung-AG/kraken.git
    cd kraken

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

### Ludicrous speed

Looking to create a **ludicrous** cluster? Use the following `terraform.tfvars`:

    cluster_name="<your cluster name>"
    aws_access_key="<your aws key id>"
    aws_secret_key="<your aws secret key>"
    aws_user_prefix="<prefix to use for named resources>"
    apiserver_count = "10"
    node_count = "1000"
    aws_etcd_type = "i2.8xlarge"
    aws_storage_type_etcd = "ephemeral"
    aws_apiserver_type = "m4.4xlarge"

Alternatively, you can provide these variables as -var 'variable=value' switches to 'terraform' command.

All available variables to override and set are under

    terraform/<cluster type>/variables.tf
    
## Create cluster

Easiest way to create a non-local kraken cluster is to use /bin scripts that let you create a kraken cluster from a remote docker container.
Another benefit that these tools offer is allowing you to create a kraken cluster from any OS that is capable of running docker-machine (OSX, Windows, Linux)  

First, the script creates a docker-machine instance in the cloud provider of your choice.  
Then it builds a docker container on that instance, with all the tools required to build a kraken cluster.  
Then the docker container is used to create a Kraken cluster.

    cd bin
    
On a system with a Bash shell:

    ./kraken-up.sh --dmname DOCKER_MACHINE_NAME --clustertype aws --clustername KUBERNETES_CLUSTER_NAME --dmopts "--driver amazonec2 --amazonec2-vpc-id ID_OF_VPC --amazonec2-region EC2_REGION --amazonec2-access-key AWS_KEY_ID --amazonec2-secret-key AWS_SECRET_KEY"
    
On a system with powershell:

    ./kraken-up.ps1 -dmname DOCKER_MACHINE_NAME -clustertype aws -clustername KUBERNETES_CLUSTER_NAME -dmopts "--driver amazonec2 --amazonec2-vpc-id ID_OF_VPC --amazonec2-region EC2_REGION --amazonec2-access-key AWS_KEY_ID --amazonec2-secret-key AWS_SECRET_KEY"
    
The '--dmopts/-dmopts' parameter is a string of driver parameters for docker-machine. You can use any driver you want - info on supported drivers is available in docker-machine help. Also, '--dmopts/-dmopts' is only required the first time you start up a cluster, after that as long as docker-machine is running you don't need to provide the option string again.  

Running kraken-up with '--clustertype/-clustertype aws' should leave you with a kraken aws cluster running, using variables from the terraform.tfvars file you just created.  

## Interact with your kubernetes cluster
On a system with a Bash shell:

    $ ./kraken-kube.sh --dmname DOCKER_MACHINE_NAME
    Machine DOCKER_MACHINE_NAME exists.
        To control your cluster use:
        kubectl --kubeconfig=clusters/ec2/kube_config --cluster=<cluster name> <kubectl commands>
    $ kubectl --kubeconfig=clusters/ec2/kube_config --cluster=KUBERNETES_CLUSTER_NAME get nodes

On a system with powershell:

    PS> ./kraken-kube.ps1 -dmname DOCKER_MACHINE_NAME
    Machine DOCKER_MACHINE_NAME exists.
        To control your cluster use:
        kubectl --kubeconfig=clusters/ec2/kube_config --cluster=<cluster name> <kubectl commands>
    PS> kubectl --kubeconfig=clusters/ec2/kube_config --cluster=KUBERNETES_CLUSTER_NAME get nodes
    
## Destroy Cluster
On a system with a Bash shell:

    $ ./kraken-down.sh --dmname DOCKER_MACHINE_NAME --clustername KUBERNETES_CLUSTER_NAME
    
On a system with powershell:

    PS> ./kraken-down.ps1 -dmname DOCKER_MACHINE_NAME -clustername KUBERNETES_CLUSTER_NAME

## SSH to cluster nodes
On a system with a Bash shell:

    $ ./kraken-ssh.sh --dmname DOCKER_MACHINE_NAME --clustername KUBERNETES_CLUSTER_NAME NODE_NAME
    
On a system with powershell:

    PS> ./kraken-ssh.ps1 -dmname DOCKER_MACHINE_NAME -clustername KUBERNETES_CLUSTER_NAME -node NODE_NAME

For example:

    $ ./kraken-ssh.sh --dmname ec2home --clustername homecluster etcd
    $ ./kraken-ssh.sh --dmname ec2home --clustername homecluster node-005
    $ ./kraken-ssh.sh --dmname ec2 --clustername work master
    PS> ./kraken-ssh.ps1 -dmname ec2home -clustername homecluster -node master
    PS> ./kraken-ssh.ps1 -dmname ec2home -clustername homecluster -node node-001
    PS> ./kraken-ssh.ps1 -dmname ec2 -clustername work -node node-009
    
Other .sh and .ps1 scripts in cluster subfolder let you:
* kraken-ansible - get the remote ansible inventory and ssh keys

## Using LogEntries.com
1. First, create an account on logentries.com.
2. Create a new log in your Logentries account by clicking + Add New Log.
3. Next, select Manual Configuration.
4. Give your log a name of your choice, select Token TCP, and then click the Register new log button. A token will be displayed in green.
5. Override logentries_token variable for your cluster type with the token value - either through a tfvars file or -var switch    

### Helpful Links
* kubectl user documentation can be found [here](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/kubectl.md)
* kubectl [FAQ](https://github.com/GoogleCloudPlatform/kubernetes/wiki/User-FAQ)
* Kubernetes conformance test logs run after a PR is merged to this repo located at http://e2e.kubeme.io

### Setting up without docker machine / setting up local cluster
Alternative setup readme is [here](README-NO-DOCKERMACHINE.md)
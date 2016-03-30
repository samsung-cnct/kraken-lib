# Kraken
## Overview
Deploy a __Kubernetes__ cluster to AWS or Virtualbox using __Terraform__  and __Ansible__ on top of __CoreOS__.

## Tools setup
Install [docker toolbox](https://www.docker.com/docker-toolbox), or just docker-machine and docker client separately.  
Then:

    git clone git@github.com:Samsung-AG/kraken.git
    cd kraken

## Variables setup

Create a terraform.tfvars file under the `kraken/terraform/cluster_type/cluster_name` folder.  
For example, for aws cluster named "my_neato_cluster", the file will be:

    kraken/terraform/aws/my_neato_cluster/terraform.tfvars

File contents should be vairable pairs:

    variable_name = variable_value

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

    aws_access_key="<your aws key id>"
    aws_secret_key="<your aws secret key>"
    aws_user_prefix="<prefix to use for named resources>"
    apiserver_count = "10"
    node_count = "1000"
    aws_etcd_type = "i2.8xlarge"
    aws_storage_type_etcd = "ephemeral"
    aws_apiserver_type = "m4.4xlarge"


All available variables to override and set are under

    terraform/<cluster type>/variables.tf

### Cluster Services

Kraken supports turnkey deployment of a number of useful cluster services, via the [kraken-services](https://github.com/samsung-ag/kraken-services) repository.  Don't see a service you want in our repo?  You can use your own!

    kraken_services_repo = "git://github.com/your-fork/kraken-services"
    kraken_services_branch = "your-branch"
    kraken_services_dirs = "your-service1 your-service2"

### Third Party Scheduler

Kraken supports optionally deploying a third-party scheduler as a set of Kubernetes resources, and using that instead of the default `kube-scheduler` process.  The third party scheduler is assumed to be a service available for deployment from the services repo specified by `kraken_services_repo`

    kraken_services_repo = "git://github.com/your-fork/kraken-services"
    kraken_services_branch = "your-branch"
    thirdparty_scheduler = "custom-scheduler"
    
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

## Connecting to your cluster with various tools
On a system with a Bash shell:

    $ ./kraken-connect.sh --dmname DOCKER_MACHINE_NAME --clustername KUBERNETES_CLUSTER_NAME
    Machine DOCKER_MACHINE_NAME exists.
        To control your cluster use:
        kubectl --kubeconfig=clusters/ec2/kube_config --cluster=<cluster name> <kubectl commands>
    $ kubectl --kubeconfig=clusters/ec2/kube_config --cluster=KUBERNETES_CLUSTER_NAME get nodes

On a system with powershell:

    PS> ./kraken-connect.ps1 -dmname DOCKER_MACHINE_NAME -clustername KUBERNETES_CLUSTER_NAME
    Machine DOCKER_MACHINE_NAME exists.
        To control your cluster use:
        kubectl --kubeconfig=clusters/ec2/kube_config --cluster=<cluster name> <kubectl commands>
    PS> kubectl --kubeconfig=clusters/ec2/kube_config --cluster=KUBERNETES_CLUSTER_NAME get nodes

Follow the instructions in script output.
    
## Destroy Cluster
On a system with a Bash shell:

    $ ./kraken-down.sh --dmname DOCKER_MACHINE_NAME --clustername KUBERNETES_CLUSTER_NAME
    
On a system with powershell:

    PS> ./kraken-down.ps1 -dmname DOCKER_MACHINE_NAME -clustername KUBERNETES_CLUSTER_NAME


## Using LogEntries.com
1. First, create an account on logentries.com.
2. Create a new log in your Logentries account by clicking + Add New Log.
3. Next, select Manual Configuration.
4. Give your log a name of your choice, select Token TCP, and then click the Register new log button. A token will be displayed in green.
5. Override logentries_token variable for your cluster type with the token value - either through a tfvars file or -var switch.    

## Using SysdigCloud
1. Create an account on sysdigcloud.com
2. Populate the terraform variable sysdigcloud_access_key with your sysdig cloud access key either in your terraform.tfvars file or via the -var switch
3. SysdigCloud is only included in your cluster if you supply the above key value.

Limitations: Currently only works with sysdigcloud, not on premises.  Only works with a single apiserver running, not multiple.

### Helpful Links
* kubectl user documentation can be found [here](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/kubectl.md)
* kubectl [FAQ](https://github.com/GoogleCloudPlatform/kubernetes/wiki/User-FAQ)
* Kubernetes conformance test logs run after a PR is merged to this repo located at http://e2e.kubeme.io

### Setting up without docker machine / setting up local cluster
Alternative setup readme is [here](README-NO-DOCKERMACHINE.md)

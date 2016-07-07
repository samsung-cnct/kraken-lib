# Kraken
## Overview
Deploy a __Kubernetes__ cluster to AWS or Virtualbox using __Terraform__  and __Ansible__ on top of __CoreOS__.

## Tools setup
Install [docker toolbox](https://www.docker.com/docker-toolbox), or just docker-machine and docker client separately.  
Then:

    git clone https://github.com/samsung-cnct/kraken.git
    cd kraken

## Variables setup

Create a terraform.tfvars file under the `kraken/terraform/cluster_type/cluster_name` folder.  
For example, for AWS cluster named "my_neato_cluster", the file will be:

    kraken/terraform/aws/my_neato_cluster/terraform.tfvars

The contents of the file consists of variable-value pairs. For example:

    variable_name = "variable_value"

As described [here](https://www.terraform.io/intro/getting-started/variables.html). For a local cluster you __must__ provide:

    cluster_name=<name of your cluster> 

For an AWS cluster you __must__ provide:

    cluster_name = "<name of your cluster>"
    aws_user_prefix = "<prefix to use for named resources>"

For an AWS cluster you __must__ configure an AWS credentials file as documented [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-config-files)

If the profile in your credential file is not named "default", you can specify 
 different profile name as follows:

    aws_profile = "<profile name>"

The following are some of the other optional parameters which may be specified:

    apiserver_count = "<apiserver pool size>"
    node_count = "<number of kubernetes nodes>"

For better performance, you should consider adding and modifing the following configuration items:

    aws_etcd_type = "<aws instance type for etcd>"
    aws_storage_type_etcd = "<ephemeral>"

### Ludicrous speed

Looking to create a **ludicrous** cluster? Use the following `terraform.tfvars`:

    aws_user_prefix="<prefix to use for named resources>"
    apiserver_count = "10"
    node_count = "1000"
    aws_etcd_type = "i2.8xlarge"
    aws_storage_type_etcd = "ephemeral"
    aws_apiserver_type = "m4.4xlarge"

All available variables to override and set are under

    terraform/<cluster type>/variables.tf

### Cluster Services

Kraken supports turnkey deployment of a number of useful cluster services, via the [kraken-services](https://github.com/samsung-cnct/kraken-services) repository.  Don't see a service you want in our repo?  You can use your own!

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

    ./kraken-up.sh --dmname DOCKER_MACHINE_NAME --clustertype aws --clustername KUBERNETES_CLUSTER_NAME --dmopts "--driver amazonec2 --amazonec2-vpc-id ID_OF_VPC --amazonec2-region EC2_REGION"
    
The '--dmopts/-dmopts' parameter is a string of driver parameters for docker-machine. You can use any driver you want - info on supported drivers is available in docker-machine help. Also, '--dmopts/-dmopts' is only required the first time you start up a cluster, after that as long as docker-machine is running you don't need to provide the option string again.  

If you prefer to store your AWS credentials file in a directory other than ~/.aws, you can pass --provider-credential-directory path, however note that if you are using docker-machine, then you will need to add the appropriate --dmopts as docker-machine can not generally determine atypical credential directory locations. For example, for AWS, you would add "--amazonec2-access-key AWS_KEY_ID --amazonec2-secret-key AWS_SECRET_KEY" to --dmopts.

Running kraken-up with '--clustertype/-clustertype aws' should leave you with a kraken aws cluster running, using variables from the terraform.tfvars file you just created.

## Connecting to your cluster with various tools
On a system with a Bash shell:

    $ ./kraken-connect.sh --dmname DOCKER_MACHINE_NAME --clustername KUBERNETES_CLUSTER_NAME
    Machine DOCKER_MACHINE_NAME exists.
        To control your cluster use:
        kubectl --kubeconfig=clusters/ec2/kube_config --cluster=<cluster name> <kubectl commands>
    $ kubectl --kubeconfig=clusters/ec2/kube_config --cluster=KUBERNETES_CLUSTER_NAME get nodes

Follow the instructions in script output.
    
## Destroy Cluster
On a system with a Bash shell:

    $ ./kraken-down.sh --dmname DOCKER_MACHINE_NAME --clustername KUBERNETES_CLUSTER_NAME
    
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
* kubectl user documentation can be found [here](https://github.com/kubernetes/kubernetes/blob/master/docs/user-guide/kubectl-overview.md)
* Kubernetes [FAQ](https://github.com/GoogleCloudPlatform/kubernetes/wiki/User-FAQ)
* Kubernetes conformance test logs run after a PR is merged to this repo located at http://e2e.kubeme.io

### Setting up without docker machine / setting up local cluster
Alternative setup readme is [here](README-NO-DOCKERMACHINE.md)

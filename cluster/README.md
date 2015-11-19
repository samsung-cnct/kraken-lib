# Creating a cluster remotely

Scripts in this direcotry let you create a kraken cluster from a remote docker container.
Another benefit that these tools offer is allowing you to create a kraken cluster from any OS that is capable of running docker-machine (OSX, Windows, Linux)

## Setup
1. install docker-machine from https://www.docker.com/docker-toolbox
2. Create a terraform.tfvars file under __terraform/aws__
3. From __cluster__ subfolder run:

```bash
./kraken-up.sh --dmname your_docker_machine_name --dmopts "docker machine options"

# for example:

./kraken-up.sh --dmname ec2 --dmopts "--driver amazonec2 --amazonec2-vpc-id vpc-e9cd4a8c"

# subsequently as long as your docker machine is up and running you can skip the '--dmopts' part
```

This should leave you with a kraken aws cluster running, using variables from the terraform.tfvars file you just created.

__NOTE THAT WHATEVER CLUSTER_NAME YOU MIGHT HAVE IN YOUR .TFVARS FILE, IT WILL BE OVERRIDEN TO MATCH CLUSTER TYPE__

First, the script creates a docker-machine instance in the cloud provider of your choice.
Then it builds a docker container on that instance, with all the tools required to build a kraken cluster.
Then the docker container is used to create an AWS Kraken cluster.

Some of the other .sh and .cmd scripts in cluster subfolder let you:

* kraken-down - destroy remotely managed kraken
* kraken-up - create remotely managed kraken
* kraken-kube - grab the remote kubectl config file
* kraken-ssh - ssh to remotely managed kraken nodes
* kraken-ansible - get the remote ansible inventory and ssh keys
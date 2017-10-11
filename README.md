# __kraken-lib__ Deploys a __Kubernetes__ Cluster on top of __CoreOS__ using __Terraform__  and __Ansible__

[![Docker Repository on Quay](https://quay.io/repository/samsung_cnct/k2/status "Docker Repository on Quay")](https://quay.io/repository/samsung_cnct/k2)

Please use [kraken](https://github.com/samsung-cnct/k2cli), the intended user interface to kraken-lib. The
following instructions are intended for developers working on kraken-lib.

## What is kraken-lib?
kraken-lib is an orchestration and cluster-level management system for [Kubernetes](https://kubernetes.io) that creates a production-scale Kubernetes cluster on a range of platforms using default settings. When you're ready to optimize your cluster for your own environment and use case, you can deploy with kraken-lib's rich set of configurable options.  

We (Samsung CNCT) built this tool to aid in our own research into high performance and reliability for the Kubernetes control plane. Realizing this would be a useful tool for the public at large, we released it as [kraken](https://github.com/samsung-cnct/kraken) (now kraken-v1) in mid 2016. This first release was great, but we had developed it quickly and just for research. After using it ourselves for almost a year and identifying some pain points, we deemed it best to build anew, bringing the best parts forward. Thus sprouted kraken-lib our second release. 

It continues to use Ansible and Terraform because of the flexible and powerful abstractions these tools provide at the right layers. kraken-lib provides the same functionality as kraken-v1 but with much cleaner internal abstractions. This more easily facilitates external and internal contributions. It also enables us to quickly improve and evolve with the Kubernetes ecosystem as a whole.

## Who and What is it For?
kraken-lib is targeted at operations teams who support Kubernetes, a practice becoming known as "ClusterOps." It provides a single interface where ClusterOps teams can manage Kubernetes clusters across all environments.

kraken-lib uses a single file to drive cluster configuration, enabling you to check the file into a VCS of your choice and solving two major problems:
1. Use version control for your cluster configuration as you promote changes from dev through production, for either existing cluster configurations or brand-new ones;
2. Enable continuous integration for developer applications against sandboxed and transient Kubernetes clusters. kraken-lib provides a destroy command that cleans up all traces of the temporary infrastructure.

We believe solving these two problems is a baseline for effectively and efficiently nurturing a Kubernetes-based infrastructure.

## Crash Data Collection
To support our efforts to make kraken-lib a fault-tolerant, reliable tool, we collect data if kraken-lib crashes on up, down or update. If you are running it with the [kraken-tools](https://github.com/samsung-cnct/k2-tools) Docker container and the program exits with a failure, the following data will be collected by [kraken-lib crash-app](https://github.com/samsung-cnct/k2-crash-application) 
* Logs
* The failing task

This data remains internal for the Samsung-CNCT team to use for data-driven development. We do not collect personal information from users. 

## Supported Add-ons
kraken-lib also supports a number of Samsung CNCT-supported add-ons in the form of Kubernetes charts. These charts, tested and maintained by Samsung CNCT, can be found in the [kraken-lib Charts repository](https://github.com/samsung-cnct/k2-charts).
*They should work on any Kubernetes cluster.* 

# Getting Started with kraken-lib

## Prerequisites

You will need to have the following:

- A machine that can run Docker
- A text editor
- Amazon credentials with the following privileges:
  - Launch EC2 instances
  - Create VPCs
  - Create ELBs
  - Create EBSs
  - Create Route 53 records
  - Create IAM roles for EC2 instances

### Running without tools Docker image

You will need the following installed on your machine:

- Python 2.x (virtualenv strongly suggested)
  - pip
  - boto
  - netaddr
- Ansible ([see kraken-tools](https://github.com/samsung-cnct/k2-tools/blob/master/requirements.txt) for the version)
- Cloud SDKs
  - AWS cli
  - gcloud SDK
- Terraform and Providers ([see kraken-tools](https://github.com/samsung-cnct/k2-tools/blob/master/Dockerfile) for the versions)
  - Terraform
  - [Terraform Execute Provider](https://github.com/samsung-cnct/terraform-provider-execute/releases)  
  - [Terraform CoreOS Box Provider](https://github.com/samsung-cnct/terraform-provider-coreosbox/releases)
- kubectl
- Helm

For the specific version of Python modules (including Ansible) that are expected, see [kraken-tools](https://github.com/samsung-cnct/k2-tools/blob/master/requirements.txt). For the versions of all other dependecies, see the kraken-tools [Dockerfile](https://github.com/samsung-cnct/k2-tools/blob/master/Dockerfile).

## The kraken-lib Image

The easiest way to get started with kraken-lib directly is to use a kraken-lib container image:

`docker pull quay.io/samsung_cnct/k2:latest`

## Preparing the Environment  

Add/configure the environment variables below; K2OPTS is used to pass Docker the specified Docker volumes (note -v in the K2OPTS variable). Ensure each of these files or directories exist:


```
KRAKEN=${HOME}/.kraken       # This is the default output directory for Kraken
SSH_ROOT=${HOME}/.ssh
AWS_ROOT=${HOME}/.aws
AWS_CONFIG=${AWS_ROOT}/config  # Use these files when using the aws provider
AWS_CREDENTIALS=${AWS_ROOT}/credentials
SSH_KEY=${SSH_ROOT}/id_rsa   # This is the default rsa key configured
SSH_PUB=${SSH_ROOT}/id_rsa.pub
K2OPTS="-v ${KRAKEN}:${KRAKEN}
        -v ${SSH_ROOT}:${SSH_ROOT}
        -v ${AWS_ROOT}:${AWS_ROOT}
        -e HOME=${HOME}
        --rm=true
        -it"
```

### Initial kraken-lib directory

If this is your first time using kraken-lib, use the kraken-lib Docker image to generate a 'sensible defaults' configuration (this assumes AWS is the infrastructure provider):

With the Docker container:

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest ./bin/up.sh --generate
```

With the cloned repo:

```bash
./bin/up.sh --generate
```

This will generate a config.yaml file located here:

```
${KRAKEN}/config.yaml
```

In this section, the variable `YOURCLUSTER` refers to the name you must assign to your cluster at the bottom of the generated `config.yaml` in the deployments section. Once you assign the name, it will look like:

```
deployment:
  clusters:
    - name: YOURCLUSTER
```

Then rename the `config.yaml` file to `YOURCLUSTER.yaml`. This is best practice.

**For the rest of the discussion, we will assume the environmental variable `${CLUSTER}` has been set to the name of your cluster.**

It is particularly useful when trying to create and manage multiple clusters, each of which
**must** have unique names.

## Configure Your Kubernetes Cluster

### Important configuration variables to adjust

While all configuration options are available for a reason, some are more important than others. In addition to the region and subnet selections under provider clauses, some key options include:

- `clusters[x].providerConfig`
- `clusters[x].nodePools[x].count`
- `kubeConfig[x].version`
- `kubeConfig[x].hyperkubeLocation`
- `helmConfigs[x].charts`

For a detailed explanation of all configuration variables, please consult [our configuration documentation](Documentation/kraken-configs/README.md)

### Add a Custom Domain for the Kubernetes API Server 
To add a human-readable domain name to your Kubernetes API server, uncomment `customApiDns` and add the desired domain name to your config.yaml:

```
deployment:
  clusters:
  ...
    customApiDns: YOURDOMAINNAME
```

Configure the custom domain name to point to your cluster's Kubernetes API server ELB. This can be found in the cluster's admin.kubeconfig file under clusters/cluster/server:

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ....
    server: <Kubernetes API server ELB Address>
  name: CLUSTER_NAME
```


### Preparing AWS credentials

_If you already have configured your machine to use AWS, you can skip this step_.

To configure the environment with your AWS credentials, run one of the following commands:

Using a Docker container:

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest bash -c 'aws configure'
```

Using the local AWS CLI tool:

```bash
 aws configure
```

### Creating your cluster

To bring your cluster up, run:
```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest ./bin/up.sh --config $HOME/.kraken/${CLUSTER}.yaml
```

This will take a while and will generate a lot of output.

### kubectl

After creating a cluster, to use the kubectl shipped with kraken-lib, run commands in the following fashion:

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest kubectl --kubeconfig $HOME/.kraken/${CLUSTER}/admin.kubeconfig get nodes
```

With locally installed kubectl:

```bash
`kubectl --kubeconfig ~/.kraken/${CLUSTER}/admin.kubeconfig get nodes`
```

### Helm

After creating a cluster, to use the Helm shipped with kraken-lib, run:

```bash
docker run $K2OPTS -e HELM_HOME=$HOME/.kraken/${CLUSTER}/.helm -e KUBECONFIG=$HOME/.kraken/${CLUSTER}/admin.kubeconfig quay.io/samsung_cnct/k2:latest helm list
```

With locally installed kubectl:

```bash
export KUBECONFIG=~/.kraken/${CLUSTER}/admin.kubeconfig
`helm list --home ~/.kraken/${CLUSTER}/.helm`
```

### SSH

After creating a cluster, you will be able to SSH to various cluster nodes:

```bash
ssh master-3 -F ~/.kraken/${CLUSTER}/ssh_config
```

Cluster creating process generates an SSH config file at:

```bash
 ~/.kraken/${CLUSTER}/ssh_config
```

Host names are based on node pool names from your config file. For example, if you had a config file with a node pool section as below:

```
nodePools:
  - name: etcd
    count: 5
    ...
  - name: etcdEvents
    count: 5
    ...
  - name: master
    count: 3
    ...
  - name: clusterNodes
    count: 3
    ...
  - name: specialNodes
    count: 2
    ...
```

Then, the SSH host names available will be:

- etcd-1 through etcd-5
- etcdEvents-1 through etcdEvents-5
- master-1 through master-3
- clusterNodes-1 through clusterNodes-3
- specialNodes-1 through specialNodes-2


## Starting Your own Kubernetes Cluster

### Normal initial flow

To boot up a cluster per your configuration, execute the following command:

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest ./bin/up.sh --config $HOME/.kraken/${CLUSTER}.yaml
```

Normally kraken-lib will look at your configuration, generate artifacts such as cloud-config files and deploy VMs that will become your cluster. During this time, errors can occur if the configuration file contains unexpected settings. If needed, fix any errors and restart the cluster deployment.

The amount of time for deploying a new cluster varies, but you can expect roughly 5 minutes from starting the command to the cluster becoming available for use.

### Verifying cluster availability

After kraken-lib has run, you will have a working cluster waiting for workloads. To verify it is functional, run the commands described in this section.

#### Getting Kubernetes nodes

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest kubectl --kubeconfig ~/.kraken/${CLUSTER}/admin.kubeconfig get nodes
```

The result should resemble the following:

```bash
NAME                                         STATUS                     AGE
ip-10-0-113-56.us-west-2.compute.internal    Ready,SchedulingDisabled   2m
ip-10-0-164-212.us-west-2.compute.internal   Ready                      2m
ip-10-0-169-86.us-west-2.compute.internal    Ready,SchedulingDisabled   3m
ip-10-0-194-57.us-west-2.compute.internal    Ready                      2m
ip-10-0-23-199.us-west-2.compute.internal    Ready                      3m
ip-10-0-36-28.us-west-2.compute.internal     Ready,SchedulingDisabled   2m
ip-10-0-58-24.us-west-2.compute.internal     Ready                      3m
ip-10-0-65-77.us-west-2.compute.internal     Ready                      2m
```

#### Getting Kubernetes deployments

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest kubectl --kubeconfig ~/.kraken/${CLUSTER}/admin.kubeconfig get deployments --all-namespaces
```

```bash
NAMESPACE     NAME                         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
default       central-fluentd-deployment   3         3         3            3           3m
default       kafka-monitor                1         1         1            1           3m
default       kibana-logging               3         3         3            3           3m
kube-system   heapster-standalone          1         1         1            1           3m
kube-system   kube-dns                     1         1         1            1           3m
kube-system   tiller-deploy                1         1         1            1           3m

```

#### Deploying a new service

_Optional step_

Kraken-lib comes with a lot of built-in services but you can also deploy additional services.

In the past, we used github repositories for our Helm charts. These are deprecated in favor of Quay's app registry. The app registry allows for tagging the latest versions of charts and flexibly pulling up-to-date chart images for dependencies elsewhere. Additionally the registry can grant login-based access for private Helm charts.
[Information on Quay app registry](https://coreos.com/blog/quay-application-registry-for-kubernetes.html)

As an example for using Helm to install a new service, try installing the Kubernetes dashboard:

##### Finding Kubernetes dashboard version

```bash
docker run $K2OPTS -e HELM_HOME=$HOME/.kraken/${CLUSTER}/.helm -e KUBECONFIG=$HOME/.kraken/${CLUSTER}/admin.kubeconfig quay.io/samsung_cnct/k2:latest helm registry list quay.io | grep kubernetes-dashboard

quay.io/samsung_cnct/kubernetes-dashboard      0.1.0-0
```

This indicates the chart to install is `samsung_cnct/kubernetes-dashboard` from the `quay.io` registry.


Or for the legacy repo (deprecated):

```bash
docker run $K2OPTS -e HELM_HOME=$HOME/.kraken/${CLUSTER}/.helm -e KUBECONFIG=$HOME/.kraken/${CLUSTER}/admin.kubeconfig quay.io/samsung_cnct/k2:latest helm search kubernetes-dashboard

NAME                      	VERSION	DESCRIPTION                      
atlas/kubernetes-dashboard	0.1.0  	A kubernetes dashboard Helm chart
```

In this case the chart to install is `kubernetes-dashboard` from the `atlas` repo.

##### Install Kubernetes dashboard

```bash
docker run $K2OPTS -e HELM_HOME=$HOME/.kraken/${CLUSTER}/.helm -e KUBECONFIG=$HOME/.kraken/${CLUSTER}/admin.kubeconfig quay.io/samsung_cnct/k2:latest helm registry install --namespace kube-system samsung_cnct/kubernetes-dashboard
```

```bash
NAME:   innocent-olm
LAST DEPLOYED: Thu May 18 22:04:03 2017
NAMESPACE: kube-system
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME                  CLUSTER-IP     EXTERNAL-IP  PORT(S)       AGE
kubernetes-dashboard  10.46.101.182  <pending>    80:31999/TCP  0s

==> extensions/v1beta1/Deployment
NAME                  DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
kubernetes-dashboard  1        1        1           0          0s
```

The chart has been installed. It will take a moment for AWS ELB DNS to propagate, but you can get the DNS now.

##### Finding the DNS name for Kubernetes dashboard

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest kubectl --kubeconfig ~/.kraken/${CLUSTER}/admin.kubeconfig describe service kubernetes-dashboard --namespace kube-system
```

```bash
Name:			kubernetes-dashboard
Namespace:		kube-system
Labels:			app=kubernetes-dashboard
Selector:		app=kubernetes-dashboard
Type:			LoadBalancer
IP:			10.46.101.182
LoadBalancer Ingress:	ae7a0bae03c1511e78f8f06148e55c0f-1296896684.us-west-2.elb.amazonaws.com
Port:			<unset>	80/TCP
NodePort:		<unset>	31999/TCP
Endpoints:		10.129.84.6:9090
Session Affinity:	None
Events:
  FirstSeen	LastSeen	Count	From			SubobjectPath	Type		Reason			Message
  ---------	--------	-----	----			-------------	--------	------			-------
  3m		3m		1	{service-controller }			Normal		CreatingLoadBalancer	Creating load balancer
  2m		2m		1	{service-controller }			Normal		CreatedLoadBalancer	Created load balancer
```

After a few minutes, you can view the Kubernetes dashboard. In this example, it is located at [here](http://ae7a0bae03c1511e78f8f06148e55c0f-1296896684.us-west-2.elb.amazonaws.com).

#### Storage Class
For AWS clusters, kraken-lib creates a storage class that is assigned the `default` Namespace. GKE clusters come with a GKE-provided storageclass. We are working to add support for storage classes with other providers.

### Debugging

If kraken-lib hangs during deployment, hit CTRL-C to break out of the application and try again. Note that some steps are slow and may give a false indication that the deployment is hung up. In particular, the `TASK [/kraken/ansible/roles/kraken.provider/kraken.provider.aws : Run cluster up] ***` step and the wait for a cluster to come up can take some time.

You can use the AWS console to log into the created VMs. There you will see various items, such as:

- EC2 instances that include the `cluster` value in their name
- Auto-scaling groups that include the `cluster` value in their name
- ELB (for API server) that includes the `cluster` value in its name
- VPC that includes the `cluster` value in its name
- Route 53 Zone that includes the `clusterDomain` value in its name

Using the EC2 instance list, you #can SSH# into VMs and do further debugging.

## Changing Configuration

You can make some changes to the cluster configuration by first making appropriate changes in the config file, and then running the kraken-lib update command as described below. Please be aware of which changes can be safely made to your cluster.

### Things that should not be changed with kraken-lib update

- cluster name
```
clusters:
  - name: YOURCLUSTER
```
- etcd settings (beyond machine type)

### Things that can be changed with kraken-lib update

- Node pools
- Node pool counts and instance types
- Cluster services desired to be run
- Kubernetes version
- Location of the hyperkube container

### Updating node pools

Below we discuss some differences between clusters hosted on AWS versus clusters hosted on GKE.

#### AWS
On AWS, your nodes will still reflect the version they had upon creation. When you run the `update` command, kraken-lib will delete nodes one by one, waiting for updated replacement nodes to come online before deleting the next node. This will ensure no information gets lost and the control plane remains up and running.

You can update all or some of your control plane and cluster nodes (but not etcd nodes, as mentioned above).

#### GKE
On GKE nodes, it is not possible to update the control plane. Cluster node updates are possible. The mechanics of deleting and updating nodes are handled by GKE in this case, not kraken-lib.

#### Running kraken-lib update on node pools
You can specify different versions of Kubernetes in each node pool. This may affect the compatibility of your cluster's kraken-lib services (see below). You can also update node pool counts and instance types. The update action has a required `--nodepools` or `-n` flag followed by a comma-separated list of the names of the node pools you want to update. Please be patient; this process may take a while.

- Step 1: Make appropriate changes to configuration file
- Step 2: Run
```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest ./bin/update.sh --config $HOME/.Kraken/${CLUSTER}.yaml --nodepools clusterNodes,specialNodes
```

### Adding and deleting node pools
If you change your configuration file to add or remove a node pool, kraken-lib's update action can handle this as well. Adding a node pool will create a new one with the number and type of nodes specified in the config file. Removing a node pool will irretrievably delete any nodes in that node pool, and anything scheduled on those nodes will be lost. This process is much faster than updating individual nodes.

- Step 1: Make appropriate changes to configuration file
- Step 2: Run
```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest ./bin/update.sh --config $HOME/.kraken/${CLUSTER}.yaml --addnodepools <nodepools,you,wish,to,add> --rmnodepools <nodepools,you,wish,to,remove>
```

## Kubernetes Versioning for kraken-lib Services
kraken-lib will use the versions of Helm and kubectl appropriate for the Kubernetes version of each cluster. It does so by determining each cluster's currently set Kubernetes minor version. Because node pools can have different versions from each other, the minor version is set according to the version of the control-plane node pool in AWS clusters. For GKE clusters, kraken-lib uses the Kubernetes version of the last node pool in the node pools list.

### Handling unsupported versions of Helm
Currently, and for the foreseeable future, new Helm releases will be shipped after new Kubernetes releases, resulting in Helm possibly not being supported for the latest Kubernetes version. You have two options as detailed below.

#### Option 1: Overriding Helm in kraken-lib config file
In the kraken-lib config file, set the cluster-level key `helmOverride` to `true` if you wish to use the latest version of Helm available. Warning: because this would be using a version of Helm that doesn't support your cluster's Kubernetes version, this may result in unexpected behavior.
Set `helmOverride` to `false` if you would like to run kraken-lib without Helm.

#### Option 2: Overriding Helm via environment variable
This will automatically happen if you are trying to run a cluster with a Kubernetes version that does not have Helm support, and you did not set `helmOverride` in the kraken-lib config file.
kraken-lib will halt and, via a fail message, prompt you to set a cluster-specific Helm override environment variable to true or false.

```bash
export helm_override_<CLUSTER_NAME>=<TRUE/FALSE>
```
Now, run cluster up again, and kraken-lib will use the override condition you specified.

## Destroying a Kubernetes Cluster

To destroy a cluster created with kraken-lib, do the following:

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest ./bin/down.sh --config $HOME/.kraken/${CLUSTER}.yaml
```

#### To create a small research or development cluster (non-HA)
To create a small, low resource-consuming cluster, alter your configuration to the following:

Role | # | Type
--- | ---  | ---
Primary etcd cluster | 1 | t2.small
Events etcd cluster | 1 | t2.small
Master nodes | 1 | m4.large
Cluster nodes | 1 | c4.large
~~Special~~ ~~nodes~~ | ~~2~~ | ~~m4.large~~

yaml:
```deployment:
  clusters:
    - name:
...
      nodePools:
        - name: etcd
          count: 1
...
    - name: etcdEvents
          count: 1
...
        - name: master
          count: 1
...
        - name: clusterNodes
          count: 1
```

Delete 'Special nodes'.

# Docs
You can find further information here:

[kraken-lib documentation](Documentation/README.md)

# Maintainer
This document is maintained by Patrick Christopher (@coffeepac) at Samsung SDS.

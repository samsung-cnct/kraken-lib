# __K2__ deploys a __Kubernetes__ cluster on top of __CoreOS__ using __Terraform__  and __Ansible__.

[![Docker Repository on Quay](https://quay.io/repository/samsung_cnct/k2/status "Docker Repository on Quay")](https://quay.io/repository/samsung_cnct/k2)

Please use [k2cli](https://github.com/samsung-cnct/k2cli), the intended user interface to K2. The
following instructions are intended for developers working on K2.

## What is K2
K2 is an orchestration and cluster level management system for [Kubernetes](https://kubernetes.io). K2 will create a production scale Kubernetes
cluster on a range of platforms using its default settings. This can be especially useful if you are getting
started and don't need a HA production level cluster right away. When you are ready to optimize your cluster for your own environment and use case, K2 provides a rich set of configurable options.  

We (Samsung CNCT) built this tool to aid in our own research into high performance and reliability for the Kubernetes control plane. We realized this would be a useful tool for the public at large and released it as [Kraken](https://github.com/samsung-cnct/kraken). Kraken was great but it was developed quickly for research. After using it ourselves for almost a year and identifying some pain points we decided it was best to build anew, bringing the best parts forward. It continues to use Ansible and
Terraform because we believe those tools provide flexible and powerful abstractions at the right layers.  

K2 provides the same functionality with much cleaner internal abstractions. This makes it easier for both external and internal contributions. It will also allow us to continue to quickly improve and evolve with the Kubernetes ecosystem as a whole.

## What is K2 for
K2 is targeted at operations teams that need to support Kubernetes, a practice becoming known as ClusterOps. K2 provides a single interface where you can manage your Kubernetes clusters across all environments.

K2 uses a single file to drive cluster configuration. This makes it easy to check the file into a VCS of your choice and solve two major problems:
1. use version control for your cluster configuration as you promote changes from dev through to production, for either existing cluster configurations or brand new ones
2. enable Continuous Integration for developer applications against sandboxed and transient Kubernetes clusters. K2 provides a destroy command that will clean up all traces of the temporary infrastructure

We believe solving these two problems is a baseline for effectively and efficiently nurturing a Kubernetes based infrastructure.

## K2 supported addons
K2 also supports a number of Samsung CNCT supported addons in the form of Kubernetes Charts. These charts can be found in the [K2 Charts repository](https://github.com/samsung-cnct/k2-charts).
These charts are tested and maintained by Samsung CNCT. They should work on any Kubernetes cluster.  

# Getting Started with K2

## Prerequisites

You will need to have the following:

- A machine that can run Docker
- A text editor
- Amazon credentials with the following privileges:
  - Launch EC2 instances
  - Create VPCs
  - Create ELBs
  - Create EBSs
  - Create Route 53 Records
  - Create IAM roles for EC2 instances

### Running without tools docker image

You will need the following installed on your machine:

- Python 2.x (virtualenv strongly suggested)
  - pip
  - boto
  - netaddr
- Ansible 2.2.x
- Cloud SDKs
  - aws cli
  - gcloud SDK
- Terraform and providers
  - Terraform 0.8.6
  - Terraform execute provider 0.0.4 (https://github.com/samsung-cnct/terraform-provider-execute/releases)  
  - Terraform coreosbox provider 0.0.3 (https://github.com/samsung-cnct/terraform-provider-coreosbox/releases)
- kubectl 1.3.x
- helm alpha.5 or later


## The K2 image

The easiest way to get started with K2 directly is to use a K2 container image

`docker pull quay.io/samsung_cnct/k2:latest`

## Preparing the environment  

Configure a volume environment variable for use below. Ensure that each of these files or directories exist:

```
KRAKEN=${HOME}/.kraken          # This is the default output directory for K2
SSH_KEY=${HOME}/.ssh/id_rsa     # This is the default rsa key configured
SSH_PUB=${HOME}/.ssh/id_rsa.pub
AWS_CONFIG=${HOME}/.aws/config  # Use these files when using the aws provider
AWS_CREDENTIALS=${HOME}/.aws/credentials
K2OPTS="-v ${KRAKEN}:${KRAKEN}
        -v ${SSH_KEY}:${SSH_KEY}
        -v ${SSH_PUB}:${SSH_PUB}
        -v ${AWS_CONFIG}:${AWS_CONFIG}
        -v ${AWS_CREDENTIALS}:${AWS_CREDENTIALS}
        -e HOME=${HOME}
        --rm=true
        -it"
```

### Initial K2 Directory
If this is your first time using K2, use the K2 Docker image to generate a 'sensible defaults' configuration (this assumes AWS is the infrastructure provider):

With the Docker container:

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest ./up.sh --generate
```

With the cloned repo:

```bash
./up.sh --generate
```

This will generate a config.yaml file located at

```
${KRAKEN}/config.yaml
```

In this section, the variable `YOURCLUSTER` refers to the name you must assign to your cluster at the bottom of the generated `config.yaml` in the deployments section, which once a name has been decided would look like:

```
deployment:
  clusters:
    - name: YOURCLUSTER
```

You should then rename the `config.yaml` file to `YOURCLUSTER.yaml`.  This is best practice.

**For the rest of the discussion, we will assume that the environmental variable `${CLUSTER}` has been set to the name of your cluster.**

It is particularly useful when trying to create and manage multiple clusters, each of which
**must** have unique names.

## Configure your Kubernetes Cluster

### Important configuration variables to adjust

While all configuration options are available for a reason, some are more important than others.  Some key ones include

- `clusters[x].providerConfig`
- `clusters[x].nodePools[x].count`
- `kubeConfig[x].version`
- `kubeConfig[x].hyperkubeLocation`
- `helmConfigs[x].charts`

As well as the region and subnet selections under provider clauses.

For a detailed explanation of all configuration variables, please consult [our configuration documentation](Documentation/kraken-configs/README.md)


### Preparing AWS credentials

_If you already have configured your machine to be able to use AWS, you can skip this step_

To configure the environment with your AWS credentials, run one of the following commands:

using a Docker container:

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest bash -c 'aws configure'
```

using the local awscli tool:

```bash
 aws configure
```

### Creating your cluster

To bring your cluster up, run:
```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest ./up.sh --config $HOME/.kraken/${CLUSTER}.yaml
```

This will take a while, and will generate a lot of output.

### kubectl

After creating a cluster, to use the kubectl shipped with K2, run commands in the following fashion:

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest kubectl --kubeconfig $HOME/.kraken/${CLUSTER}/admin.kubeconfig get nodes
```

with locally installed kubectl:

```bash
`kubectl --kubeconfig ~/.kraken/${CLUSTER}/admin.kubeconfig get nodes`
```

### helm

After creating a cluster, to use the helm shipped with K2, run:

```bash
docker run $K2OPTS -e HELM_HOME=$HOME/.kraken/${CLUSTER}/.helm -e KUBECONFIG=$HOME/.kraken/${CLUSTER}/admin.kubeconfig quay.io/samsung_cnct/k2:latest helm list
```

with locally installed kubectl:

```bash
export KUBECONFIG=~/.kraken/${CLUSTER}/admin.kubeconfig
`helm list --home ~/.kraken/${CLUSTER}/.helm`
```

### ssh

After creating a cluster you should be able to ssh to various cluster nodes

```bash
ssh master-3 -F ~/.kraken/${CLUSTER}/ssh_config
```

Cluster creating process generates an ssh config file at

```bash
 ~/.kraken/${CLUSTER}/ssh_config
```

Host names are based on node pool names from your config file. I.e. if you had a config file with nodepool section like so:

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

Then the ssh hostnames available will be:

- etcd-1 through etcd-5
- etcdEvents-1 through etcdEvents-5
- master-1 through master-3
- clusterNodes-1 through clusterNodes-3
- specialNodes-1 through specialNodes-2


## Starting your own Kubernetes Cluster

### Normal Initial Flow

To boot up a cluster per your configuration, please execute the following command:

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest ./up.sh --config $HOME/.kraken/${CLUSTER}.yaml
```

Normally K2 will take a look at your configuration, generate artifacts like cloud-config files, and deploy VMs that will become your cluster.

During this time errors can happen if the configuration file contains unexpected settings. Please fix any errors and restart the cluster deployment if needed.

The amount of time it will take to deploy a new cluster is variable, but expect about 5 minutes from the time you start the command to when a cluster should be available for use

### Verifying cluster is available

After K2 has run, you should have a working cluster waiting for workloads. To verify it is functional, run the commands described in this section.

#### Getting Kubernetes Nodes

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

#### Getting Kubernetes Deployments

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

#### Deploy a new service

_Optional step_

You can try having helm install a new service, such as the Kubernetes dashboard

##### Find Kubernetes Dashboard Version

```bash
docker run $K2OPTS -e HELM_HOME=$HOME/.kraken/${CLUSTER}/.helm -e KUBECONFIG=$HOME/.kraken/${CLUSTER}/admin.kubeconfig quay.io/samsung_cnct/k2:latest helm search kubernetes-dashboard

NAME                      	VERSION	DESCRIPTION                      
atlas/kubernetes-dashboard	0.1.0  	A kubernetes dashboard Helm chart
```

This indicates that the file to install is `atlas/kubernetes-dashboard`.

##### Install Kubernetes Dashboard

```bash
docker run $K2OPTS -e HELM_HOME=$HOME/.kraken/${CLUSTER}/.helm -e KUBECONFIG=$HOME/.kraken/${CLUSTER}/admin.kubeconfig quay.io/samsung_cnct/k2:latest helm install --namespace kube-system atlas/kubernetes-dashboard
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

##### Finding DNS name for Kubernetes Dashboard

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

After a few minutes, you should be able to view the kubernetes dashboard. In this example it is located at http://ae7a0bae03c1511e78f8f06148e55c0f-1296896684.us-west-2.elb.amazonaws.com.

### Debugging

If K2 hangs during deployment, please hit ctrl-c to break out of the application and try again. Note that some steps are slow and may give a false indication that the deployment is hung.  In particular, the `TASK [/kraken/ansible/roles/kraken.provider/kraken.provider.aws : Run cluster up] ***` step and the wait for a cluster to come up can take some time.

You can use the AWS console to log into the VMs that have been created. There you will see various items, such as:

- EC2 Instances that include the `cluster` value in their name
- Auto Scaling Groups that include the `cluster` value in their name
- ELB (for apiserver) that includes the `cluster` value in its name
- VPC that includes the `cluster` value in its name
- Route 53 Zone that includes the `clusterDomain` value in its name

Using the EC2 instance list you can SSH into VMs and do further debugging.

## Changing configuration

Some changes to the cluster configuration can be made by re-running K2.

### Things that should not be changed by re-running K2

- cluster name
```clusters:
  - name: YOURCLUSTER```
- etcd settings (beyond machine type)

### Things that can be changed (sometimes with some manual intervention)

- nodepools
- nodepool counts and instance types
- cluster services desired to be run
- Kubernetes version
- location of the hyperkube container

If you change these settings, some manuals step may be needed. For example, you may need to terminate existing nodes to have new nodes spun up with updated configurations.

In order to effect these changes, make appropriate adjustments to the configuration file and re-run the command that created the cluster.

In other words:

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest ./up.sh --config $HOME/.kraken/${CLUSTER}.yaml
```

#### Upgrading Kubernetes Version of Master Nodes
As mentioned above, before you can upgrade the Kubernetes version, you will first need to update your configuration file with the intended version and run:

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest ./up.sh --config $HOME/.kraken/${CLUSTER}.yaml
```

Then run:

 ```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest ./upgrade.sh --config $HOME/.kraken/${CLUSTER}.yaml
```

Refer to [Kuberntes release versioning](https://github.com/kubernetes/kubernetes/blob/release-1.5.4/docs/design/versioning.md#supported-releases) for questions about supported versions

## Destroying a Kubernetes Cluster

How zen of you - everything must come to end, including Kubernetes clusters. To destroy a cluster created with K2, please do the following:

```bash
docker run $K2OPTS quay.io/samsung_cnct/k2:latest ./down.sh --config $HOME/.kraken/${CLUSTER}.yaml
```

# Docs
Further information can be found here:

[K2 documentation](Documentation/README.md)

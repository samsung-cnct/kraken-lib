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

## The K2 image

The easiest way to get started with K2 is to use a K2 container image

`docker pull quay.io/samsung_cnct/k2:latest`

## Preparing the environment  
  
### Initial K2 Directory
If this is your first time using kraken, please create a `.kraken` directory in your home directory

`mkdir ~/.kraken`

For ease of use, please copy our [sample configuration](https://raw.githubusercontent.com/venezia/k2/master/Documentation/samples/standard_cluster.yaml) into the `~/.kraken` directory

### Preparing AWS credentials

_If you already have configured your machine to be able to use AWS, you can skip this step_

To setup AWS credentials, please run the following command

`docker run -v ~/:/root -it --rm=true quay.io/samsung_cnct/k2:latest bash -c 'aws configure'`

This will allow you to configure the environment with your AWS credentials

### kubectl

#### Downloading kubectl for mac

_This step is optional if you want to use the kubectl shipped with the container_

To download the latest kubectl for mac, please do the following:

```bash
curl -O https://storage.googleapis.com/kubernetes-release/release/v1.4.0/bin/darwin/amd64/kubectl
chmod a+x kubectl
mv kubectl /usr/local/bin/
```

And to use it, you would type in a command similar to:

`kubectl --kubeconfig ~/.kraken/venezia1/admin.kubeconfig get nodes`

#### Using kubectl from the built in container

_This step is optional if you want to download your own kubectl_

To use the kubectl shipped with k2, run a command similar to:

`docker run -v ~/:/root -it --rm=true quay.io/samsung_cnct/k2:latest bash -c 'kubectl --kubeconfig ~/.kraken/venezia1/admin.kubeconfig get nodes'`

## Configure your Kubernetes Cluster

Earlier, you copied a sample cluster configuration over into `~/.kraken`  Please take a moment to review the sample configuration and make changes if you desire

It may be preferable to save it to a name that is consistent to the `cluster` variable in the configuration.  In other words, if your `cluster` is `foo`, then perhaps your file should be named `foo.yaml`

### Important configuration variables to adjust

While all configuration options are available for a reason, some are more important than others.  Some key ones include

- `cluster`
- `kubeConfig.version`
- `kubeConfig.hyperkubeLocation`
- `providerConfig.region`
- `nodepool[x].count`
- `nodepool[x].providerConfig.type`
- `clusterServices.services`

For a detailed explanation of all configuration variables, please consult [our configuration documentation](kraken-configs/README.md)

## Starting your own Kubernetes Cluster

### Normal Initial Flow

To boot up a cluster per your configuration, please execute the following command:

`docker run --rm=true -it -v ~/:/root quay.io/samsung_cnct/k2:latest bash -c 'cd /kraken && ./up.sh --config foo.yaml'`

Replace `foo.yaml` with the name of the configuration file you intended to use (which should be in `~/.kraken`)

Normally K2 will take a look at your configuration, generate artifacts like cloud-config files, and deploy VMs that will become your cluster.

During this time errors can happen if the configuration file is not as expected.  Please look at the errors and restart the cluster deployment if needed.

The amount of time it will take to deploy a new cluster is variable, but expect about 5 minutes from the time you start the command to when a cluster should be available for use

### Verifying cluster is available

After K2 has run, you should have a working cluster waiting for workloads.  To verify things are good, type in the following commands:

In all cases, assumption is made that `cluster` value in your configuration was `foo`.  Please change `foo` to your value

#### Getting K8s Nodes

`docker run -v ~/:/root -it --rm=true quay.io/samsung_cnct/k2:latest bash -c 'kubectl --kubeconfig ~/.kraken/foo/admin.kubeconfig get nodes'`

This should result in the following:

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

#### Getting K8s Deployments

`docker run -v ~/:/root -it --rm=true quay.io/samsung_cnct/k2:latest bash -c 'kubectl --kubeconfig ~/.kraken/foo/admin.kubeconfig get deployments --all-namespaces'`

```bash
NAMESPACE     NAME            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
kube-system   kube-dns        1         1         1            1           8m
kube-system   tiller-deploy   1         1         1            1           8m
```

#### Deploy a new service

_Optional step_

In order to feel a bit more confident things are working, try having helm install a new service, like the K8S dashboard

##### Find Kubernetes Dashboard Version

`docker run -v ~/:/root -it --rm=true -e HELM_HOME=/root/.kraken/foo/.helm -e KUBECONFIG=/root/.kraken/foo/admin.kubeconfig quay.io/samsung_cnct/k2:latest bash -c 'helm search kubernetes'`

```bash
atlas/kubernetes-dashboard-0.1.0.tgz
```

Now we know that we want `atlas/kubernetes-dashboard-0.1.0`

##### Install Kubernetes Dashboard

`docker run -v ~/:/root -it --rm=true -e HELM_HOME=/root/.kraken/foo/.helm -e KUBECONFIG=/root/.kraken/foo/admin.kubeconfig quay.io/samsung_cnct/k2:latest bash -c 'helm install atlas/kubernetes-dashboard-0.1.0'`

```bash
Fetched atlas/kubernetes-dashboard-0.1.0 to /kraken/kubernetes-dashboard-0.1.0.tgz
foolhardy-scorpion
Last Deployed: Wed Oct  5 16:20:42 2016
Namespace: 
Status: DEPLOYED

Resources:
==> extensions/Deployment
NAME                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
kubernetes-dashboard   1         1         1            0           1s

==> v1/Service
NAME                   CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes-dashboard   10.37.204.191   <pending>     80/TCP    1s
```

The chart has been installed.  It will take a moment for AWS ELB DNS to propagate, but we can get the DNS now

##### Finding DNS name for Kubernetes Dashboard

`docker run -v ~/:/root -it --rm=true quay.io/samsung_cnct/k2:latest bash -c 'kubectl --kubeconfig ~/.kraken/foo/admin.kubeconfig describe service kubernetes-dashboard --namespace kube-system'`

```bash
Name:			kubernetes-dashboard
Namespace:		kube-system
Labels:			app=kubernetes-dashboard
Selector:		app=kubernetes-dashboard
Type:			LoadBalancer
IP:			10.37.204.191
LoadBalancer Ingress:	aa95470398b1711e6b3a706da4d1c1f9-1324035908.us-west-2.elb.amazonaws.com
Port:			<unset>	80/TCP
NodePort:		<unset>	31638/TCP
Endpoints:		10.128.36.2:9090
Session Affinity:	None
Events:
  FirstSeen	LastSeen	Count	From			SubobjectPath	Type		Reason			Message
  ---------	--------	-----	----			-------------	--------	------			-------
  6m		6m		1	{service-controller }			Normal		CreatingLoadBalancer	Creating load balancer
  6m		6m		1	{service-controller }			Normal		CreatedLoadBalancer	Created load balancer
```

After a few minutes, we should feel comfortable going to http://aa95470398b1711e6b3a706da4d1c1f9-1324035908.us-west-2.elb.amazonaws.com and viewing the kubernetes dashboard

### Debugging

If K2 hangs during deployment, please hit ctrl-c to break out of the application and try again.  Note that some steps are slow and may not indicate things are hung.  Particularly `TASK [/kraken/ansible/roles/kraken.provider/kraken.provider.aws : Run cluster up] ***` and while waiting for a cluster to come up

If you desire to log into the VMs that have been created during this process, please use the AWS console.  There you will see various items

- EC2 Instances that include the `cluster` value in their name
- Auto Scaling Groups that include the `cluster` value in their name
- ELB (for apiserver) that includes the `cluster` value in its name
- VPC that includes the `cluster` value in its name
- Route 53 Zone that includes the `clusterDomain` value in its name

Using the EC2 instance list one can SSH into VMs and do further debugging

## Changing configuration

Some changes to the cluster can be done with K2

### Things that can be changed (sometimes with some manual intervention)

- nodepools
- nodepool counts and instance types
- cluster services desired to be run
- Kubernetes version / location of hypekube container

If you change these settings, a manual step may be needed.  For example you may need to terminate existing nodes to have new nodes spun up with updated configurations

### Things that should note be changed right now

- cluster name (`cluster` value in configuration)
- etcd settings (beyond machine type)

In order to effect these changes, make appropriate adjustments to the configuration file and re-run the command that created the cluster.

In other words:

`docker run --rm=true -it -v ~/:/root quay.io/samsung_cnct/k2:latest bash -c 'cd /kraken && ./up.sh --config foo.yaml'`

Replace `foo.yaml` with the name of the configuration file you intended to use (which should be in `~/.kraken`)

## Destroying a Kubernetes Cluster

How zen of you - everything must come to end, including kubernetes clusters.  To destroy a cluster created with K2, please do the following:

`docker run --rm=true -it -v ~/:/root quay.io/samsung_cnct/k2:latest bash -c 'cd /kraken && ./down.sh --config foo.yaml'`

Replace `foo.yaml` with the name of the configuration file you intended to use (which should be in `~/.kraken`)



# kraken

Kubernetes Made Easy(KubME)<sup>tm</sup>
Deploy kubernetes cluster on coreos using vagrant

## Pre-requisites
 
 Bits that you will need to run a Kubernetes + Coreos cluster on your machine.

 * [Virtualbox](https://www.virtualbox.org/) to run VMs
 * `vagrant` get it [here](https://www.vagrantup.com/downloads.html)
 * `kubectl`
 * AWS environment variables for deploying to AWS (optional for deploying to AWS - TODO)

### kubectl

Download and install the latest kubectl into your /opt directory.
You can locate the latest binaries [here](https://github.com/GoogleCloudPlatform/kubernetes/releases/latest)
All other release including archives are found [here](https://github.com/GoogleCloudPlatform/kubernetes/releases)

```bash
cd /opt
curl -L https://github.com/GoogleCloudPlatform/kubernetes/releases/download/v0.11.0/kubernetes.tar.gz | tar xv
```
### Helpful `kubectl` links
* kubectl user documentation can be found [here](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/kubectl.md)
*  kubectl [FAQ](https://github.com/GoogleCloudPlatform/kubernetes/wiki/User-FAQ)

## Download and Deploy
Download __kraken__ into your working directory 
```bash
git clonehttps://github.com/onemorehill/kraken.git
cd kraken
```
Deploy everything by running `vagrant` commands while in the __kraken__ directory

```bash
vagrant up
```
## Validate install
Everything should by operational. To verify run

```bash
kubectl get services
```
Output should look something like
```
NAME                LABELS                                    SELECTOR            IP                  PORT
kubernetes          component=apiserver,provider=kubernetes   <none>              10.100.0.2          443
kubernetes-ro       component=apiserver,provider=kubernetes   <none>              10.100.0.1          801
```

Check on your minion(s) by running
```bash
kubectl get minions
```

You will get back something that looks like
```bash
NAME                LABELS                                    SELECTOR            IP                  PORT
kubernetes          component=apiserver,provider=kubernetes   <none>              10.100.0.2          443
kubernetes-ro       component=apiserver,provider=kubernetes   <none>              10.100.0.1          80
```

## Working with local files
Everything in the __kraken__ directory is shared under the `/vagrant` mount on each node. You have full read write access to that directory allowing easy transfer of files to and from each node.


```bash
vagrant destroy --force
```

## Troubleshooting

On the slim chance that things go awry. Here are some troubleshooting tips to hopefully sort you out.

Verify that `fleet` has set up and can talk to all the nodes in the cluster
```
fleetctl list-machines
```

Output should look something like this
```
MACHINE		IP		METADATA
3dba3ebc...	10.1.1.102	role=kubernetes
625f15c6...	10.1.1.103	role=kubernetes
71b82a1b...	10.1.1.104	role=kubernetes
aab430f9...	10.1.1.101	role=master
```

If you do not see similar IPs and roles, contact <leetchang@gmail.com> and he'll help you sort it out.

### Access to each node can be accomplished through `vagrant`
```bash
vagrant ssh <node-name>
```

You also `ssh` directly by adding the lines from the _ssh_config_ file to `~/.ssh/config`
This will add the correct ssh params and keys to your ssh agent. You can simply run
```bash
ssh node-master
ssh node-01
``` 


_Caveats_
> Auto reboot of coreos after updates is NOT enabled
> Errors are not outputted by kubernetes
> kubectl status reports are not consistent
> Exposing services to the public is a blackart

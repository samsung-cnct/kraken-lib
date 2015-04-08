## Kubenetes cluster on CoreOS

Deploy a __Kubernetes cluster by running `vagrant` commands while in the __kubernetes__ directory.
The default settings will create 4 nodes:
* 1 etcd node
* 1 Kuberenetes API servers and controller
* 2 Kubernetes minions


```bash
vagrant up
```

## Validate
Everything should b operational. Run the following commands within this working directory.

Make sure the API server is avaible to take requests.

```bash
$ kubectl get services
NAME                LABELS                                    SELECTOR            IP                  PORT
kubernetes          component=apiserver,provider=kubernetes   <none>              10.100.0.2          443
kubernetes-ro       component=apiserver,provider=kubernetes   <none>              10.100.0.1          80
```

Check on your minions by running

```bash
kubectl get minions
NAME                LABELS              STATUS
172.16.1.103        <none>              Ready
172.16.1.104        <none>              Ready
```

### Working with local files
Everything in the __kraken__ directory is shared under the `/vagrant` mount on each node. You have full read write access to that directory allowing easy transfer of files to and from each node.

### Shutting down and cleaning up
Once you are down with everything. Shutdown all VirtualBox VMs via `vagrant`

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

If you do not see similar IPs and roles, contact <leetchang@gmail.com* and he'll help you sort it out.

Access to each node can be accomplished through `vagrant`
```bash
vagrant ssh <node-name>
```

You also `ssh` directly by adding the lines from the _ssh_config_ file to `~/.ssh/config`
This will add the correct ssh params and keys to your ssh agent allowing ssh from other environments. You can simply run
```bash
ssh node-master
ssh node-01
``` 
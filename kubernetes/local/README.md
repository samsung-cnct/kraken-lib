## Kubenetes cluster on CoreOS

Deploy a __Kubernetes cluster by running `vagrant` commands while in the __kubernetes__ directory.
The default settings will create 4 nodes:
* 1 etcd node
* 1 Kuberenetes API servers and controller
* 2 Kubernetes minions


```bash
vagrant up
```
### Validate
Spinning up all the nodes may take some time depending on hardware and network. Given ample time, verything should be operational. Run the following commands within this working directory.

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
### Kubernetes UI
The Kubernetes UI is available at http://172.16.1.102:8900.

### Working with local files
Everything in the __kraken/kubernetes__ directory is shared under the `/vagrant` mount on each node. You have full read write access to that directory allowing easy transfer of files to and from each node.

### Shutting down and cleaning up
Once you are down with everything. Shutdown all VirtualBox VMs via `vagrant`

```bash
vagrant destroy --force
```

Access to each node can be accomplished through `vagrant`
```bash
vagrant ssh <node-name>
```

## Troubleshooting

On the slim chance that things go awry. Here are some troubleshooting tips to hopefully sort you out.

Verify that `fleet` has set up the nodes correctly and can commincate with them.
```
fleetctl list-machines
```

Output should look something like this
```
MACHINE		IP		METADATA
46a55004...	172.16.1.102	role=master
69b8310d...	172.16.1.104	role=minion
9b062820...	172.16.1.103	role=minion
f3e10ae7...	172.16.1.101	role=etcd
```

If you do not see similar IPs and roles, contact <leetchang@gmail.com> and he'll help you sort it out. Or even better, file an issue [here](https://github.com/Samsung-AG/kraken/issues)


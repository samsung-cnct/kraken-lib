## Kubenetes cluster on CoreOS / Virtualbox

The default settings create 4 nodes:
* 1 etcd node
* 1 Kubernetes API servers and controller
* 2 Kubernetes nodes

### Kubernetes UI
The Kubernetes UI is available at http://172.16.1.102:8080/static/app (master public ip)

### Working with local files
Everything in the __kraken/kubernetes/local__ directory is shared under the `/vagrant` mount on each node. You have full read write access to that directory allowing easy transfer of files to and from each node.

## Troubleshooting

On the slim chance that things go awry. Here are some troubleshooting tips to hopefully sort you out.

Verify that `fleet` has set up the nodes correctly and can commincate with them (172.16.1.102 being your master node ip).
```
FLEETCTL_ENDPOINT=http://172.16.1.102:4001 fleetctl list-machines
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


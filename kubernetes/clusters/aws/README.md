## Kubenetes cluster on AWS

The default settings create 4 nodes:
* 1 etcd node
* 1 Kubernetes API servers and controller
* 3 Kubernetes nodes

### Kubernetes UI
The Kubernetes UI is available at http://52.24.103.52:8080/static/app (master public ip)


## Troubleshooting

On the slim chance that things go awry. Here are some troubleshooting tips to hopefully sort you out.

Verify that `fleet` has set up the nodes correctly and can commincate with them (52.24.103.52 being your master node ip).
```
FLEETCTL_ENDPOINT=http://52.24.103.52:4001 fleetctl list-machines
```

Output should look something like this
```
MACHINE   IP    METADATA
1fda4620... 52.24.103.52  role=master
348c9b7d... 10.1.104.103  role=node
7b5894d9... 10.1.104.101  role=etcd
b3e12f9a... 10.1.104.104  role=node
fb39062d... 10.1.104.105  role=node
```

If you do not see similar IPs and roles, contact <leetchang@gmail.com> and he'll help you sort it out. Or even better, file an issue [here](https://github.com/Samsung-AG/kraken/issues)


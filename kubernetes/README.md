## Kubenetes clusters

Deploy a __Kubernetes cluster by running `./kraken` commands while in the __kubernetes__ directory.

*  rename [aws settings.sample.yaml](aws/settings.sample.yaml) and [local settings.sample.yaml](local/settings.sample.yaml) to settings.yaml and edit as needed
*  run ./kraken <desired cluster type> up

for example:

```bash
./kraken local up
```
### Validate
Spinning up all the nodes may take some time depending on hardware and network. Given ample time, verything should be operational. Run the following commands within this working directory.

Make sure the API server is avaible to take requests by running './kraken k <desired cluster type> get services'

for example:

```bash
$ kubectl --kubeconfig=./local/.kubeconfig get services
NAME                LABELS                                    SELECTOR            IP                  PORT
kubernetes          component=apiserver,provider=kubernetes   <none>              10.100.0.2          443
kubernetes-ro       component=apiserver,provider=kubernetes   <none>              10.100.0.1          80
```

Check on your nodes by running

```bash
$ kubectl --kubeconfig=./local/.kubeconfig get nodes
NAME                LABELS              STATUS
172.16.1.103        <none>              Ready
172.16.1.104        <none>              Ready
```

### Shutting down and cleaning up
Once you are done with everything - shutdown all VMs

```bash
./kraken local destroy --force
```

or

```bash
./kraken aws destroy --force
```

Access to each node can be accomplished through `vagrant`
```bash
./kraken <cluster> ssh <node name>
```
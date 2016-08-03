# Docker Example of etcd snippets

## Requirements

The etcd for docker snippet requires the functionality of
* docker.service
* networking.service
* ephemeral.mount
* ssl.service (if enabled)

They need to exist in the cloud-config file in order for these snippets to work

## etcd with discovery service, no SSL

If the following has been set:

```yaml
clientPorts: [2379, 4001]
name: etcd
nodepool: etcd
peerPorts: [2380]
ssl: false
version: 3.0.3
discovery: true
```

Then we would expect the following cloud-config snippet

```yaml
[Unit]
Description=etcd
After=docker.service
After=networking.service
After=ephemeral.mount
[Service]
EnvironmentFile=/etc/networking.env
TimeoutStartSec=0
KillMode=none
ExecStartPre=-/usr/bin/docker kill etcd_2379
ExecStartPre=-/usr/bin/docker rm etcd_2379
ExecStartPre=/usr/bin/mkdir -p /ephemeral/etcd
ExecStart=docker run -v /ephemeral/etcd:/ephemeral \ 
 -p 2379:2379 -p 4001:4001 -p 2380:2380 \
 --name etcd_2379 quay.io/coreos/etcd:3.0.3 \
 --data-dir /ephemeral/etcd
 --name etcd \
 --advertise-client-urls http://{$HostIP}:2379 \
 --listen-client-urls http://0.0.0.0:2379 \
 --initial-advertise-peer-urls http://${HostIP}:2380 \
 --listen-peer-urls http://0.0.0.0:2380 \
 --discovery https://discovery.etcd.io/3e86b59982e49066c5d813af1c2e2579cbf573de
ExecStartStop=/usr/bin/docker stop etcd_2379
```

## etcd with DNS Discovery, no SSL

If the following has been set:
 
```yaml
clientPorts: [2381]
clusterToken: myClusterToken
name: etcd2
nodepool: etcd2
peerPorts: [2382]
ssl: false
version: 3.0.3
dns: etcd2.testcluster.io
```

Then we would expect the following cloud-config snippet

```yaml
[Unit]
Description=etcd2
After=docker.service
After=networking.service
After=ephemeral.mount
[Service]
EnvironmentFile=/etc/networking.env
TimeoutStartSec=0
KillMode=none
ExecStartPre=-/usr/bin/docker kill etcd_2381
ExecStartPre=-/usr/bin/docker rm etcd_2381
ExecStartPre=/usr/bin/mkdir -p /ephemeral/etcd2
ExecStart=docker run -v /ephemeral/etcd2:/ephemeral \ 
 -p 2381:2381 -p 2382:2382 \
 --name etcd_2381 quay.io/coreos/etcd:3.0.3 \
 --data-dir /ephemeral/etcd2
 --name etcd2 \
 --discovery-srv etcd2.testcluster.io \
 --initial-advertise-peer-urls http://{$HostIP}:2382 \
 --initial-cluster-token myClusterToken \
 --initial-cluster-state new \
 --advertise-client-urls http://{$HostIP}:2381 \
 --listen-client-urls http://{$HostIP}:2381 \
 --listen-peer-urls http://{$HostIP}:2382
ExecStartStop=/usr/bin/docker stop etcd_2381
```

## etcd with DNS Discovery, SSL

If the following has been set:

```yaml
clientPorts: [2381]
clusterToken: myClusterToken
name: etcd2
nodepool: etcd2
peerPorts: [2382]
ssl: true
version: 3.0.3
dns: etcd2.testcluster.io
```

Then we would expect the following cloud-config snippet

```yaml
[Unit]
Description=etcd2
After=docker.service
After=ssl.service
After=networking.service
After=ephemeral.mount
[Service]
EnvironmentFile=/etc/networking.env
TimeoutStartSec=0
KillMode=none
ExecStartPre=-/usr/bin/docker kill etcd_2381
ExecStartPre=-/usr/bin/docker rm etcd_2381
ExecStartPre=/usr/bin/mkdir -p /ephemeral/etcd2
ExecStartPre=/usr/bin/mkdir -p /etcd/ssl/etcd
ExecStart=docker run -v /etc/ssl/etcd/:/etc/ssl/etcd -v /ephemeral/etcd2:/ephemeral \ 
 -p 2381:2381 -p 2382:2382 \
 --name etcd_2381 quay.io/coreos/etcd:3.0.3 \
 --data-dir /ephemeral/etcd2
 --name etcd2 \
 --peer-client-cert-auth \
 --peer-trusted-ca-file=/etc/ssl/etcd/ca.crt \
 --peer-cert-file=/etc/ssl/etcd/client.crt \
 --peer-key-file=/etc/ssl/etcd/client.key \
 --discovery-srv etcd2.testcluster.io \
 --initial-advertise-peer-urls https://{$HostIP}:2382 \
 --initial-cluster-token myClusterToken \
 --initial-cluster-state new \
 --advertise-client-urls https://{$HostIP}:2381 \
 --listen-client-urls https://{$HostIP}:2381 \
 --listen-peer-urls https://{$HostIP}:2382
ExecStartStop=/usr/bin/docker stop etcd_2381
```
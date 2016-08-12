# Flannel Configuration

## Requirements

Flannel needs to start after etcd

## Native


### Flannel on non ssl-enabled etcd

* Cluster CIDR is 192.168.0.0/16
* Encapsulation vxlan

```yaml
    - name: flanneld.service
      command: start
      drop-ins:
        - name: 50-network-config.conf
          content: |
            [Unit]
            Requires=etcd2.service
            [Service]
            ExecStartPre=/usr/bin/etcdctl set /coreos.com/network/config '{"Network":"192.168.0.0/16", "Backend": {"Type": "vxlan"}
      command: start
```

### Flannel on non ssl-enabled etcd

* Cluster CIDR is 192.168.0.0/16
* Encapsulation vxlan

```yaml
    - name: flanneld.service
      command: start
      drop-ins:
        - name: 50-network-config.conf
          content: |
            [Unit]
            Requires=etcd2.service
            [Service]
            ExecStartPre=/usr/bin/etcdctl --cert-file /etc/ssl/etcd/client.crt --key-file /etc/ssl/etcd/client.key --ca-file /etc/ssl/etcd/ca.crt set /coreos.com/network/config '{"Network":"192.168.0.0/16", "Backend": {"Type": "vxlan"}
          command: start
```

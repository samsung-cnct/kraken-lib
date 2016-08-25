## snippet structure

Under snippets are generated under 'generated' folder, with following structure:

```
generated:
  cluster name:
    master.units.unitname.part
    master.write_files.writefilename.part
    master.ssh_authorized_keys.key.part
    master.etcd.part
    master.flannel.part
    master.update.part

    etcd.etcdcluster.units.unitname.part
    etcd.etcdcluster.write_files.writefilename.part
    etcd.etcdcluster.ssh_authorized_keys.key.part
    etcd.etcdcluster.etcd.part
    etcd.etcdcluster.flannel.part
    etcd.etcdcluster.update.part
    
    node.nodepool.units.unitname.part
    node.nodepool.write_files.writefilename.part
    node.nodepool.ssh_authorized_keys.key.part
    node.nodepool.etcd.part
    node.nodepool.flannel.part
    node.nodepool.update.part
```

Then assembled into a cloud config user data files, like so:


[master | etcd | node].[nodepool name | etcd cluster name].yaml

Contents:

```
#cloud-config
---
write_files:
  {{[master | etcd | node].[nodepool name | etcd cluster name].units.*}}
ssh_authorized_keys:
  {{[master | etcd | node].[nodepool name | etcd cluster name].ssh_authorized_keys.*}}
coreos:
  units:
    {{[master | etcd | node].[nodepool name | etcd cluster name].units.*}}
  etcd:
    {{[master | etcd | node].[nodepool name | etcd cluster name].etcd.part}}
  [flannel:]
    {{[master | etcd | node].[nodepool name | etcd cluster name].flannel.part}}
  update:
    {{[master | etcd | node].[nodepool name | etcd cluster name].update.part}}
```


## snippet structure

Under snippets are generated under 'generated' folder, with following structure:

```
generated:
  cluster name:
    master.units.unitname.part
    master.write_files.writefilename.part
    master.ssh_authorized_keys.key.part
    master.coreos.etcd.part
    master.coreos.flannel.part
    master.coreos.update.part

    etcd.etcdcluster.units.unitname.part
    etcd.etcdcluster.write_files.writefilename.part
    etcd.etcdcluster.ssh_authorized_keys.key.part
    etcd.etcdcluster.coreos.etcd.part
    etcd.etcdcluster.coreos.flannel.part
    etcd.etcdcluster.coreos.update.part
    
    node.nodepool.units.unitname.part
    node.nodepool.write_files.writefilename.part
    node.nodepool.ssh_authorized_keys.key.part
    node.nodepool.coreos.etcd.part
    node.nodepool.coreos.flannel.part
    node.nodepool.coreos.update.part
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
    {{[master | etcd | node].[nodepool name | etcd cluster name].coreos.etcd.part}}
  [flannel:]
    {{[master | etcd | node].[nodepool name | etcd cluster name].coreos.flannel.part}}
  update:
    {{[master | etcd | node].[nodepool name | etcd cluster name].coreos.update.part}}
```


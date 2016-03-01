[master]
master ansible_ssh_host=${master_public_ip}

[etcd]
etcd ansible_ssh_host=${etcd_public_ip}

[apiserver]
${apiservers_inventory_info}

[local]
localhost

[cluster:children]
master
etcd
apiserver
node

[node]
${nodes_inventory_info}

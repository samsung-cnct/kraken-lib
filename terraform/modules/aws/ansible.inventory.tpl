[master]
${master_public_ip}

[etcd]
${etcd_public_ip}

[nodes]
${node_public_ips}

[cluster:children]
master
etcd
nodes

[cluster:vars]
ansible_ssh_user=core
ansible_python_interpreter="PATH=/home/core/bin:$PATH python"
master_private_ip=${master_private_ip}

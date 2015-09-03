[nodes]
${nodes_inventory_info}

[local]
localhost

[local:vars]
ansible_connection=local
ansible_ssh_private_key_file=${ansible_ssh_private_key_file}
etcd_public_ip=${etcd_public_ip}
master_public_ip=${master_public_ip}

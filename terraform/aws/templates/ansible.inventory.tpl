[nodes]
${nodes_inventory_info}

[local]
localhost ansible_connection=local

[local:vars]
cluster_name=${cluster_name}
cluster_master_record=${cluster_master_record}
ansible_ssh_private_key_file=${ansible_ssh_private_key_file}
etcd_public_ip=${etcd_public_ip}
master_public_ip=${master_public_ip}

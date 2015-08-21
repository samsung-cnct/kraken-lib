[master]
master ansible_ssh_host=${master_public_ip}

[etcd]
etcd ansible_ssh_host=${etcd_public_ip}

[nodes]
${nodes_inventory_info}

[cluster:children]
master
etcd
nodes

[local]
localhost ansible_connection=local

[cluster:vars]
ansible_ssh_user=core
ansible_python_interpreter="PATH=/home/core/bin:$PATH python"
master_private_ip=${master_private_ip}
master_public_ip=${master_public_ip}
etcd_private_ip=${etcd_private_ip}
etcd_public_ip=${etcd_public_ip}
node_01_public_ip=${node_01_public_ip}
node_01_private_ip=${node_01_private_ip}
cluster_name=${cluster_name}
cluster_master_record=${cluster_master_record}
kraken_services_repo=${kraken_services_repo}
kraken_services_branch=${kraken_services_branch}
dns_domain=${dns_domain}
dns_ip=${dns_ip}
dockercfg_base64=${dockercfg_base64}
hyperkube_image=${hyperkube_image}
kubernetes_version=${kubernetes_version}
kubernetes_api_version=${kubernetes_api_version}
kube_apiserver_v=${kube_apiserver_v}
kube_controller_manager_v=${kube_controller_manager_v}
kube_scheduler_v=${kube_scheduler_v}
kubelet_v=${kubelet_v}
kube_proxy_v=${kube_proxy_v}
kraken_services_dirs=${kraken_services_dirs}
logentries_token=${logentries_token}
logentries_url=${logentries_url}
interface_name=${interface_name}

[local:vars]
cluster_name=${cluster_name}
master_public_ip=${master_public_ip}
etcd_public_ip=${etcd_public_ip}
ansible_ssh_private_key_file=${ansible_ssh_private_key_file}

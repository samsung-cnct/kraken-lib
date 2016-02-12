[master]
master ansible_ssh_host=${master_public_ip}

[apiservers]
${apiservers_inventory_info}

[specialnodes]
${nodes_inventory_info}

[local]
localhost

[local:vars]
ansible_connection=local
ansible_ssh_private_key_file=${ansible_ssh_private_key_file}
cluster_master_record=${cluster_master_record}
cluster_name=${cluster_name}
cluster_user=${cluster_user}
etcd_public_ip=${etcd_public_ip}
kubernetes_cert_dir=${kubernetes_cert_dir}
master_public_ip=${master_public_ip}

[cluster:vars]
ansible_connection=ssh
ansible_python_interpreter="PATH=/home/core/bin:$PATH python"
ansible_ssh_private_key_file=${ansible_ssh_private_key_file}
ansible_ssh_user=core
apiserver_ip_pool=${apiserver_ip_pool}
apiserver_nginx_pool=${apiserver_nginx_pool}
cluster_master_record=${cluster_master_record}
cluster_name=${cluster_name}
cluster_proxy_record=${cluster_proxy_record}
cluster_user=${cluster_user}
command_passwd=${command_passwd}
dns_domain=${dns_domain}
dns_ip=${dns_ip}
dockercfg_base64=${dockercfg_base64}
etcd_private_ip=${etcd_private_ip}
etcd_public_ip=${etcd_public_ip}
hyperkube_deployment_mode=${hyperkube_deployment_mode}
hyperkube_image=${hyperkube_image}
interface_name=${interface_name}
kraken_local_dir=${kraken_local_dir}
kraken_services_branch=${kraken_services_branch}
kraken_services_dirs=${kraken_services_dirs}
kraken_services_repo=${kraken_services_repo}
kubernetes_api_version=${kubernetes_api_version}
kubernetes_binaries_uri=${kubernetes_binaries_uri}
kubernetes_cert_dir=${kubernetes_cert_dir}
logentries_token=${logentries_token}
logentries_url=${logentries_url}
master_port="${master_port}""
master_private_ip=${master_private_ip}
master_public_ip=${master_public_ip}
master_scheme=${master_scheme}
sysdigcloud_access_key=${sysdigcloud_access_key}

[cluster:children]
master
apiservers
specialnodes

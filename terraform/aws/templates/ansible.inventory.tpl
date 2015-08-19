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
kubernetes_version=${kubernetes_version}
kubernetes_api_version=${kubernetes_api_version}
kubernetes_verbosity=${kubernetes_verbosity}
kraken_services_dirs=${kraken_services_dirs}
logentries_token=${logentries_token}
logentries_url=${logentries_url}
interface_name=${interface_name}

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

format_docker_storage_mnt=/dev/xvdf
kraken_services_repo=git://github.com/samsung-ag/kraken-services
kraken_services_branch=stable
update_group=alpha
reboot_strategy=off
dns_domain=kubernetes.local
dockercfg_base64=""
kubernetes_version=1.0.1
kubernetes_api_version=v1
kubernetes_verbosity=2
kraken_services_dirs="heapster influxdb-grafana kube-ui loadtest prometheus skydns podpincher"
logentries_token=
logentries_url=api.logentries.com:20000

---
ansible_connection: ssh
ansible_python_interpreter: "PATH=/home/core/bin:$PATH python"
apiserver_ip_pool: ${apiserver_ip_pool}
apiserver_nginx_pool: ${apiserver_nginx_pool}
proxy_record: ${proxy_record}
command_passwd: ${command_passwd}
dns_domain: ${dns_domain}
dns_ip: ${dns_ip}
dockercfg_base64: ${dockercfg_base64}
etcd_private_ip: ${etcd_private_ip}
deployment_mode: ${deployment_mode}
hyperkube_image: ${hyperkube_image}
interface_name: ${interface_name}
kraken_services_branch: ${kraken_services_branch}
kraken_services_dirs: ${kraken_services_dirs}
kraken_services_repo: ${kraken_services_repo}
thirdparty_scheduler: ${thirdparty_scheduler}
kubernetes_api_version: ${kubernetes_api_version}
kubernetes_binaries_uri: ${kubernetes_binaries_uri}
logentries_token: ${logentries_token}
logentries_url: ${logentries_url}
access_port: ${access_port}
master_private_ip: ${master_private_ip}
access_scheme: ${access_scheme}
sysdigcloud_access_key: ${sysdigcloud_access_key}
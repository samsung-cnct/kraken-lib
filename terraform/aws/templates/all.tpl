---
ansible_ssh_user: core
ansible_ssh_private_key_file: ${ansible_ssh_private_key_file}
master_record: ${master_record}
cluster_name: ${cluster_name}
kubernetes_basic_auth_user:
  name: ${cluster_user}
  password: ${cluster_passwd}
etcd_public_ip: ${etcd_public_ip}
kubernetes_cert_dir: ${kubernetes_cert_dir}
master_public_ip: ${master_public_ip}
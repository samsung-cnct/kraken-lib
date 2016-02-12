#!/bin/bash -
#title           :kraken-ssh.sh
#description     :ssh to a remotely managed cluster node
#author          :Samsung SDSRA
#==============================================================================

#set -o errexit
#set -o nounset
#set -o pipefail

# kraken root folder
KRAKEN_ROOT=$(dirname "${BASH_SOURCE}")/..

source "${KRAKEN_ROOT}/bin/utils.sh"

kraken_container_name="kraken_cluster_${KRAKEN_CLUSTER_NAME}"
src_cluster_dir="/kraken_data/${KRAKEN_CLUSTER_NAME}"
containerfiles=(
  kraken_data:${src_cluster_dir}/ssh_config
  kraken_data:${src_cluster_dir}/ansible.inventory
  kraken_data:${src_cluster_dir}/terraform.tfstate
  kraken_data:${src_cluster_dir}/kube_config
  ${kraken_container_name}:/root/.ssh/id_rsa
  ${kraken_container_name}:/root/.ssh/id_rsa.pub
  ${kraken_container_name}:/opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/${KRAKEN_CLUSTER_NAME}/terraform.tfvars
)

is_running=$(docker inspect -f '{{ .State.Running }}' ${kraken_container_name})
if [ ${is_running} == "true" ];  then
  warn "Cluster build is currently running. Will only copy SSH keys.\n Run\n  \
    'docker logs --follow ${kraken_container_name}'\n to see the current log."
  
  containerfiles=(
    ${kraken_container_name}:/root/.ssh/id_rsa
    ${kraken_container_name}:/root/.ssh/id_rsa.pub
  )
fi

target_cluster_dir=$(cd $(dirname ${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}); pwd) 
mkdir -p "${target_cluster_dir}"

for containerfile in "${containerfiles[@]}"; do
  docker cp $containerfile ${target_cluster_dir}
done

if [ ${is_running} == "true" ];  then
  inf "Parameters for ssh:\n   \
    ssh -i ${target_cluster_dir}/id_rsa <node ip address>\n"

  exit 0
fi

# ssh_config comes with IdentityFile hardcoded to path of key in docker instance
# so use sed to translate to path of key we just copied out
sed -e "s|~/.ssh/id_rsa|${target_cluster_dir}/id_rsa|" ${target_cluster_dir}/ssh_config > ${target_cluster_dir}/ssh_config.tmp
mv ${target_cluster_dir}/ssh_config{.tmp,}

inf "Parameters for ssh:\n   \
  ssh -F ${target_cluster_dir}/ssh_config <node-name>\n"
inf "Alternatively: \n"
inf "   eval \$(docker-machine env ${KRAKEN_DOCKER_MACHINE_NAME})\n   \
  docker run -it --volumes-from kraken_data samsung_ag/kraken ssh -F \
  ${src_cluster_dir}/ssh_config <other ssh options> <node-name>"

inf "\n\nParameters for ansible:\n   \
  --inventory-file ${target_cluster_dir}/ansible.inventory\n   \
  --private-key ${target_cluster_dir}/id_rsa"

inf "\n\nParameters for terraform:\n   \
  -state=${target_cluster_dir}/terraform.tfstate\n   \
  -var-file=${target_cluster_dir}/terraform.tfvars\n   \
  -var 'cluster_name=${KRAKEN_CLUSTER_NAME}'"

inf "\n\nTo control your cluster use:\n  \
  kubectl --kubeconfig=${target_cluster_dir}/kube_config \
  --cluster=${KRAKEN_CLUSTER_NAME} <kubectl commands>"

#!/bin/bash -
#title           :kraken-ssh.sh
#description     :ssh to a remotely managed cluster node
#author          :Samsung SDSRA
#==============================================================================

set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/utils.sh"

src_cluster_dir="/kraken_data/${KRAKEN_CLUSTER_NAME}"
containerfiles=(
  kraken_data:${src_cluster_dir}/ssh_config
  kraken_data:${src_cluster_dir}/hosts
  kraken_data:${src_cluster_dir}/terraform.tfstate
  kraken_data:${src_cluster_dir}/kube_config
  ${KRAKEN_CONTAINER_NAME}:/root/.ssh/id_rsa
  ${KRAKEN_CONTAINER_NAME}:/root/.ssh/id_rsa.pub
  ${KRAKEN_CONTAINER_NAME}:/opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/${KRAKEN_CLUSTER_NAME}/terraform.tfvars
)

container_var_files=(
  kraken_data:${src_cluster_dir}/group_vars/cluster
  kraken_data:${src_cluster_dir}/group_vars/all
)

is_running=$(docker inspect -f '{{ .State.Running }}' ${KRAKEN_CONTAINER_NAME})
if [ ${is_running} == "true" ];  then
  warn "Cluster build is currently running. Some of the state files might not yet be available.\n Run\n  \
    'docker logs --follow ${KRAKEN_CONTAINER_NAME}'\n to see the current log."
    containerfiles=(
      ${KRAKEN_CONTAINER_NAME}:/root/.ssh/config_${KRAKEN_CLUSTER_NAME}
      ${KRAKEN_CONTAINER_NAME}:/opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/rendered/hosts
      kraken_data:${src_cluster_dir}/terraform.tfstate
      kraken_data:${src_cluster_dir}/kube_config
      ${KRAKEN_CONTAINER_NAME}:/root/.ssh/id_rsa
      ${KRAKEN_CONTAINER_NAME}:/root/.ssh/id_rsa.pub
      ${KRAKEN_CONTAINER_NAME}:/opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/${KRAKEN_CLUSTER_NAME}/terraform.tfvars
    )

    container_var_files=(
      ${KRAKEN_CONTAINER_NAME}:/opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/rendered/group_vars/cluster
      ${KRAKEN_CONTAINER_NAME}:/opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/rendered/group_vars/all
    )
fi

target_cluster_dir="${KRAKEN_ROOT}/bin/clusters/${KRAKEN_CLUSTER_NAME}"
mkdir -p "${target_cluster_dir}/group_vars"

# kill off the old ssh config, since we want to be doing post processing on a new one only
rm ${target_cluster_dir}/ssh_config 2>/dev/null || true

# kill off the old ssh config, since we want to be doing post processing on a new one only
rm ${target_cluster_dir}/ssh_config 2>/dev/null || true

for containerfile in "${containerfiles[@]}"; do
  if ! docker cp $containerfile ${target_cluster_dir}; then
    warn "Failed docker cp $containerfile ${target_cluster_dir}. Not available yet?"
  fi
done

if [ ${is_running} == "true" ];  then
  mv -f ${target_cluster_dir}/config_${KRAKEN_CLUSTER_NAME} ${target_cluster_dir}/ssh_config 2>/dev/null || true
fi

for containervarfile in "${container_var_files[@]}"; do
  if ! docker cp $containervarfile ${target_cluster_dir}/group_vars; then
    warn "Failed docker cp $containervarfile ${target_cluster_dir}/group_vars. Not available yet?"
  fi
done

inf "Useful environment variables:\n   \
  export DIR=${target_cluster_dir}\n"

# ssh_config comes with IdentityFile hardcoded to path of key in docker instance
# so use sed to translate to path of key we just copied out
if ! sed -e "s|~/.ssh/id_rsa|${target_cluster_dir}/id_rsa|" ${target_cluster_dir}/ssh_config > ${target_cluster_dir}/ssh_config.tmp; then
  warn "Post processing ${target_cluster_dir}/ssh_config failed. Not present yet?"
  inf "Parameters for ssh:\n   \
    ssh -i ${target_cluster_dir}/id_rsa <node ip address>"
else
  mv ${target_cluster_dir}/ssh_config{.tmp,}
  inf "Parameters for ssh:\n   \
    ssh -F ${target_cluster_dir}/ssh_config <node-name>\n"
  inf "Alternatively: \n"
  inf "   eval \$(docker-machine env ${KRAKEN_DOCKER_MACHINE_NAME})\n   docker run -it --volumes-from kraken_data samsung_ag/kraken ssh -F ${src_cluster_dir}/ssh_config <other ssh options> <node-name>"
fi

inf "\n\nParameters for ansible:\n   \
  ansible-playbook --inventory-file ${target_cluster_dir}/hosts --extra-vars 'ansible_ssh_private_key_file=${target_cluster_dir}/id_rsa' --ssh-common-args '-o StrictHostKeyChecking=no' <playbook>"


inf "\n\nParameters for terraform:\n   \
  -state=${target_cluster_dir}/terraform.tfstate -var-file=${target_cluster_dir}/terraform.tfvars -var 'cluster_name=${KRAKEN_CLUSTER_NAME}'"

inf "\n\nTo control your cluster use:\n  \
  kubectl --kubeconfig=${target_cluster_dir}/kube_config --cluster=${KRAKEN_CLUSTER_NAME} <kubectl commands>"
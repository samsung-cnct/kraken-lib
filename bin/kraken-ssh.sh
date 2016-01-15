#!/bin/bash -
#title           :kraken-ssh.sh
#description     :ssh to a remotely managed cluster node
#author          :Samsung SDSRA
#==============================================================================

set -o errexit
set -o nounset
set -o pipefail

# kraken root folder
KRAKEN_ROOT=$(dirname "${BASH_SOURCE}")/..

source "${KRAKEN_ROOT}/bin/utils.sh"

if [ -z ${KRAKEN_DOCKER_MACHINE_NAME+x} ]; then
  error "--dmname not specified. Docker Machine name is required."
  exit 1
fi

if [ -z ${KRAKEN_CLUSTER_NAME+x} ]; then
  error "--clustername not specified. Cluster name is required."
  exit 1
fi

if docker-machine ls -q | grep --silent "${KRAKEN_DOCKER_MACHINE_NAME}"; then
  inf "Machine ${KRAKEN_DOCKER_MACHINE_NAME} exists."
else
  error "Machine ${KRAKEN_DOCKER_MACHINE_NAME} does not exist."
  exit 1
fi
eval "$(docker-machine env ${KRAKEN_DOCKER_MACHINE_NAME})"

mkdir -p "clusters/${KRAKEN_DOCKER_MACHINE_NAME}/${KRAKEN_CLUSTER_NAME}"
docker cp kraken_data:/kraken_data/${KRAKEN_CLUSTER_NAME}/ssh_config "clusters/${KRAKEN_DOCKER_MACHINE_NAME}/${KRAKEN_CLUSTER_NAME}/ssh_config"
docker cp kraken_cluster:/root/.ssh/id_rsa "clusters/${KRAKEN_DOCKER_MACHINE_NAME}/id_rsa"
docker cp kraken_cluster:/root/.ssh/id_rsa.pub "clusters/${KRAKEN_DOCKER_MACHINE_NAME}/id_rsa.pub"

inf "Parameters for ssh:\n   ssh -F clusters/${KRAKEN_DOCKER_MACHINE_NAME}/${KRAKEN_CLUSTER_NAME}/ssh_config -i clusters/${KRAKEN_DOCKER_MACHINE_NAME}/id_rsa <node-name>\n"
inf "Alternatively: \n"
inf "   eval \$(docker-machine env ${KRAKEN_DOCKER_MACHINE_NAME})\n   docker run -it --volumes-from kraken_data samsung_ag/kraken ssh -F /kraken_data/${KRAKEN_CLUSTER_NAME}/ssh_config <other ssh options> <node-name>"

if [ -z ${1+x} ]; then
  inf "Specify SSH target to connect directly. I.e. master, etcd, node-001, etc."
  exit 0
fi

docker run -it --volumes-from kraken_data samsung_ag/kraken ssh -F /kraken_data/${KRAKEN_CLUSTER_NAME}/ssh_config $1
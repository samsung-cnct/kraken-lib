#!/bin/bash -
#title           :kraken-down.sh
#description     :use docker-machine to bring down a kraken cluster manager instance.
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

# kraken root folder
KRAKEN_ROOT=$(dirname "${BASH_SOURCE}")/..

source "${KRAKEN_ROOT}/cluster/utils.sh"

if [ -z ${KRAKEN_DOCKER_MACHINE_NAME+x} ]; then
  error "--dmname not specified. Docker Machine name is required."
  exit 1
fi

if [ -z ${KRAKEN_CLUSTER_TYPE+x} ]; then
  warn "--clustertype not specified. Assuming 'aws'"
  KRAKEN_CLUSTER_TYPE="aws"
fi

if docker-machine ls -q | grep --silent "${KRAKEN_DOCKER_MACHINE_NAME}"; then
  inf "Machine ${KRAKEN_DOCKER_MACHINE_NAME} exists."
else
  error "Machine ${KRAKEN_DOCKER_MACHINE_NAME} does not exist."
  exit 1
fi

eval "$(docker-machine env ${KRAKEN_DOCKER_MACHINE_NAME})"

# shut down cluster
if docker inspect kraken_cluster &> /dev/null; then
  inf "Removing old kraken_cluster container:\n   'docker rm -f kraken_cluster'"
  docker rm -f kraken_cluster
fi

if ! docker inspect kraken_data &> /dev/null; then
  warn "No terraform state available. Cluster is either not running, or kraken_data container has been removed."
  exit 0;
fi

inf "Tearing down kraken cluster:\n  'docker run --volumes-from kraken_data samsung_ag/kraken terraform destroy -force -input=false -state=/kraken_data/terraform.tfstate /opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}'"
docker run -d --name kraken_cluster --volumes-from kraken_data \
  samsung_ag/kraken bash -c \
  "until terraform destroy -force -input=false -var-file=/opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}/terraform.tfvars \
    -state=/kraken_data/terraform.tfstate /opt/kraken/terraform/${KRAKEN_CLUSTER_TYPE}; do echo 'Retrying...'; sleep 5; done"

inf "Following docker logs now. Ctrl-C to cancel."
docker logs --follow kraken_cluster

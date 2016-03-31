#!/bin/bash -
#title           :kraken-down.sh
#description     :use docker-machine to bring down a kraken cluster manager instance.
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/utils.sh"

# Defaults for optional arguments
TERRAFORM_RETRIES=${TERRAFORM_RETRIES:-10}

# shut down cluster
if docker inspect ${KRAKEN_CONTAINER_NAME} &> /dev/null; then
  run_command "docker rm -f ${KRAKEN_CONTAINER_NAME}"
fi

if ! docker inspect kraken_data &> /dev/null; then
  warn "No terraform state available. Cluster is either not running, \
    or kraken_data container has been removed."
  exit 0;
fi

run_command "docker run -d --name ${KRAKEN_CONTAINER_NAME} --volumes-from kraken_data ${KRAKEN_CONTAINER_IMAGE_NAME}
  bash -c \"/opt/kraken/terraform-down.sh --clustertype ${KRAKEN_CLUSTER_TYPE} --clustername ${KRAKEN_CLUSTER_NAME} --terraform-retries ${TERRAFORM_RETRIES}\""

follow ${KRAKEN_CONTAINER_NAME}

kraken_error_code=$(docker inspect -f {{.State.ExitCode}} ${KRAKEN_CONTAINER_NAME})
if [ ${kraken_error_code} -eq 0 ]; then
  inf "Exiting with ${kraken_error_code}"
else
  error "Exiting with ${kraken_error_code}"
fi

exit ${kraken_error_code}

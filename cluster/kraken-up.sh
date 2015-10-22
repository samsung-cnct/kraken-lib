#!/bin/bash -
#title           :kraken-up.sh
#description     :use docker-machine to bring up a kraken cluster manager instance.
#author          :Samsung SDSRA
#==============================================================================
set -o errexit
set -o nounset
set -o pipefail

function warn {
  echo -e "\033[1;33mWARNING: $1\033[0m"
}

function error {
  echo -e "\033[0;31mERROR: $1\033[0m"
}

function inf {
  echo -e "\033[0;32m$1\033[0m"
}

function setup_dockermachine {
  local dm_command="docker-machine create ${KRAKEN_DOCKER_MACHINE_OPTIONS} ${KRAKEN_DOCKER_MACHINE_NAME}"
  inf "Starting docker-machine with:\n  '${dm_command}'"

  eval ${dm_command}
}


while [[ $# > 1 ]]
do
key="$1"

case $key in
    --clustertype)
    KRAKEN_CLUSTER_TYPE="$2"
    shift 
    ;;
    --dmopts)
    KRAKEN_DOCKER_MACHINE_OPTIONS="$2"
    shift 
    ;;
    --dmname)
    KRAKEN_DOCKER_MACHINE_NAME="$2"
    shift 
    ;;
    *)
      # unknown option
    ;;
esac
shift # past argument or value
done

# kraken root folder
KRAKEN_ROOT=$(dirname "${BASH_SOURCE}")/..

if [ -z ${KRAKEN_DOCKER_MACHINE_NAME+x} ]; then 
  error "--dmname not specified. Docker Machine name is required."
  exit 1
fi

if [ -z ${KRAKEN_DOCKER_MACHINE_OPTIONS+x} ]; then 
  error "--dmopts not specified. Docker Machine option string is required."
  exit 1
fi

if [ -z ${KRAKEN_CLUSTER_TYPE+x} ]; then 
  warn "--clustertype not specified. Assuming 'aws'"
  KRAKEN_CLUSTER_TYPE="aws"
fi

if [ ! -f "${KRAKEN_ROOT}/terraform/${KRAKEN_CLUSTER_TYPE}/terraform.tfvars" ]; then 
  error "${KRAKEN_ROOT}/terraform/${KRAKEN_CLUSTER_TYPE}/terraform.tfvars is not present."
  exit 1
fi

if [ ! -f "${KRAKEN_ROOT}/terraform/${KRAKEN_CLUSTER_TYPE}/Dockerfile" ]; then 
  error "${KRAKEN_ROOT}/terraform/${KRAKEN_CLUSTER_TYPE}/Dockerfile is not present."
  exit 1
fi

if docker-machine ls -q | grep --silent "${KRAKEN_DOCKER_MACHINE_NAME}"; then 
  warn "Machine ${KRAKEN_DOCKER_MACHINE_NAME} already exists."
else
  setup_dockermachine
fi

eval "$(docker-machine env ${KRAKEN_DOCKER_MACHINE_NAME})"

# now build the docker container
docker build -t samsung_ag/kraken -f "${KRAKEN_ROOT}/terraform/${KRAKEN_CLUSTER_TYPE}/Dockerfile" "${KRAKEN_ROOT}"




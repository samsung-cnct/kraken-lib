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
fi

eval "$(docker-machine env ${KRAKEN_DOCKER_MACHINE_NAME})"

# shut down cluster
inf "Building down kraken cluster:\n  'docker run --volumes-from kraken_data samsung_ag/kraken terraform destroy -force -input=false -state=/kraken_data/terraform.tfstate /opt/kraken/terraform/aws'"
docker run --volumes-from kraken_data samsung_ag/kraken bash -c 'until terraform destroy -force -input=false -var-file=/opt/kraken/terraform/aws/terraform.tfvars -state=/kraken_data/terraform.tfstate /opt/kraken/terraform/aws; do echo "Retrying..."; sleep 5; done' 




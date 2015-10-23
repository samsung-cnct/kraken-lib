#!/bin/bash -
#title           :kraken-kube.sh
#description     :get the remote kubectl config
#author          :Samsung SDSRA
#==============================================================================

set -o errexit
set -o nounset
set -o pipefail

# kraken root folder
KRAKEN_ROOT=$(dirname "${BASH_SOURCE}")/..
source "${KRAKEN_ROOT}/cluster/utils.sh"

KUBEARGS=""
while [[ $# > 1 ]]
do
key="$1"

case $key in
    --dmname)
    KRAKEN_DOCKER_MACHINE_NAME="$2"
    shift
    ;;
    *)
      KUBEARGS="${KUBEARGS}$1 "
    ;;
esac
shift # past argument or value
done

if [ -z ${KRAKEN_DOCKER_MACHINE_NAME+x} ]; then
  error "--dmname not specified. Docker Machine name is required."
  exit 1
fi

if [ -z ${1+x} ]; then
  error "One or more of kubectl commands are required."
  exit 1
fi

if docker-machine ls -q | grep --silent "${KRAKEN_DOCKER_MACHINE_NAME}"; then
  inf "Machine ${KRAKEN_DOCKER_MACHINE_NAME} exists."
else
  error "Machine ${KRAKEN_DOCKER_MACHINE_NAME} does not exist."
  exit 1
fi
eval "$(docker-machine env ${KRAKEN_DOCKER_MACHINE_NAME})"

mkdir -p "clusters/${KRAKEN_DOCKER_MACHINE_NAME}"
docker cp kraken_data:/kraken_data/kube_config "clusters/${KRAKEN_DOCKER_MACHINE_NAME}/kube_config"

inf "To control your cluster use:\n  kubectl --kubeconfig=clusters/${KRAKEN_DOCKER_MACHINE_NAME}/kube_config --cluster=<cluster name> <kubectl commands>"
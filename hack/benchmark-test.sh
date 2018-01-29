#!/bin/bash
#
# This script gets and executes kube-bench on a cluster node.
# 
# References:
#   [1]: https://github.com/aquasecurity/kube-bench#installation
#
# Example: ./benchmark-test.sh master-1

set -o errexit
set -o nounset
set -o pipefail

# setup kube-bench params
NODE_NAME=${1:?NODE_NAME must be set}
if [[ $NODE_NAME == master* ]]; then
  NODE_TYPE=master
else
  NODE_TYPE=node
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KUBE_BENCHMARK_RESULTS=${SCRIPT_DIR}/kube-bench-${NODE_NAME}-results.txt
KRAKEN_BENCHMARK_CONF=${SCRIPT_DIR}/kraken-conf
PATH=$PATH:${SCRIPT_DIR}

printf "Getting kubectl\n"
K8S_VERSION=v1.9.0
K8S_SHA256=9150691c3c9d0c3d6c0c570a81221f476e107994b35e33c193b1b90b7b7c0cb5
KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl 

wget -q ${KUBECTL_URL}
echo "${K8S_SHA256}  kubectl" | sha256sum -c -
chmod a+x kubectl

printf "Checking K8S version\n"
export KUBECONFIG=/etc/kubernetes/kubeconfig.yaml
kubectl --kubeconfig ${KUBECONFIG} version --short

printf "Getting kube-bench\n" #[1]
docker run --rm -v $(pwd):/host aquasec/kube-bench:latest
sudo chown core:core kube-bench
sudo rm -rf ./cfg
cp -r ${KRAKEN_BENCHMARK_CONF} cfg/

printf "Executing kube-bench\n"
kube-bench ${NODE_TYPE} > ${KUBE_BENCHMARK_RESULTS}

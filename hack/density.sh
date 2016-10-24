#!/bin/bash
set -x

my_dir=$( cd $(dirname "${BASH_SOURCE}") && pwd )

KUBE_DENSITY_KUBECONFIG=${KUBE_DENSITY_KUBECONFIG:-"$HOME/krakenCluster/admin.kubeconfig"}
KUBE_DENSITY_OUTPUT_DIR=${KUBE_DENSITY_OUTPUT_DIR:-"$(pwd)/output/density"}
KUBE_DENSITY_SSH_USER=${KUBE_DENSITY_SSH_USER:-"core"}
KUBE_DENSITY_SSH_KEY=${KUBE_DENSITY_SSH_KEY:-"${HOME}/.ssh/id_rsa"}

if [[ $# < 2 ]]; then
  echo "Usage: $0 kubernetes_install_dir pods_per_node"
  echo "Run density test from specified dir with the specified densities"
  echo "  eg: $0 ~/sandbox/kubernetes-1.3.7 3 30"
  exit 1
fi

KUBE_ROOT=$1
shift
DENSITIES=$*

pushd "${KUBE_ROOT}"

# XXX: evil monkey patch: replace "aws" with a modified "skeleton" provider,
#      since multiple places in the code are hardcoded to assume that aws
#      allows ssh access.  would like to pr back to allow "skeleton" to be
#      used, but will flesh out skeleton via this monkey patch for now
mkdir -p cluster/aws.bak
mv cluster/aws/* cluster/aws.bak/
cp ${my_dir}/kubernetes-skeleton-provider.sh cluster/aws/util.sh

echo "Density test run start date: $(date -u)"
echo "Density test dir: ${KUBE_ROOT}"
echo "Density test kubeconfig: ${KUBE_DENSITY_KUBECONFIG}"

function run_hack_e2e_go() {
  # XXX: e2e-internal scripts will default to KUBERNETES_PROVIDER=gce if it's unset;
  #      that provider assumes gcloud is present and configured; instead use the
  #      "aws" provider that we just monkeypatched
  export KUBERNETES_PROVIDER=aws

  # XXX: e2e-internal scripts require USER to be set
  export USER=${USER:-$(whoami)}

  # specify which cluster to talk to, and what credentials to use
  export KUBECONFIG=${KUBE_DENSITY_KUBECONFIG}

  common_test_args=()
  common_test_args+=("--ginkgo.v=true")
  common_test_args+=("--ginkgo.noColor=true")

  density_regex=$(echo "${DENSITIES}" | tr ' ' '|')
  test_args=()
  test_args+=("--ginkgo.focus=should\sallow\sstarting\s(${density_regex})\spods\sper\snode")
  test_args+=("--e2e-output-dir=${KUBE_DENSITY_OUTPUT_DIR}")
  test_args+=("--report-dir=${KUBE_DENSITY_OUTPUT_DIR}")

  # the KUBERNETES_PROVIDER env var doesn't tell e2e.test to use the monkeypatched aws provider, so use a flag
  test_args+=("--provider=aws")
  # and yes, the aws provider requires the aws region be stuffed into an argument called gce-zone
  test_args+=("--gce-zone=us-west-2")

  # assuming a valid kubectl/kubeconfig; get the uri for the kubernetes server we're pointed at
  context=$(kubectl --kubeconfig=$KUBECONFIG config view -o jsonpath="{.current-context}")
  cluster=$(kubectl --kubeconfig=$KUBECONFIG config view -o jsonpath="{.contexts[?(@.name == \"${context}\")].context.cluster}")
  server_uri=$(kubectl --kubeconfig=$KUBECONFIG config view -o jsonpath="{.clusters[?(@.name == \"${cluster}\")].cluster.server}")

  # export the environment variables the monkeypatched aws provider requires
  export MASTER_NAME=$(echo ${server_uri} | sed -E -e 's|https?://||' | head -n1)
  export KUBE_MASTER=${MASTER_NAME}
  # XXX: We can't pass an IP address because ELB addresses can change. However,
  # since the current tests only use the IP to construct an http url, we can
  # get away with passing the FQDN instead.
  export KUBE_MASTER_IP=${MASTER_NAME}
  # turn multi-line output into array
  OLDIFS=$IFS
  IFS=$'\n'
  nodes=$(kubectl --kubeconfig=$KUBECONFIG get nodes --no-headers | awk '{print $1}')
  IFS=$OLDIFS
  # since these are arrays they can't be exported, hence the declare -p / BASH_ENV trick
  NODE_NAMES=($nodes)
  KUBE_NODE_IP_ADDRESSES=($nodes)
  # !? declare -p NODE_NAMES KUBE_NODE_IP_ADDRESS > $(pwd)/.bash_arrays

  # e2e.test uses this instead of SSH_USER
  export KUBE_SSH_USER=${KUBE_DENSITY_SSH_USER}
  # export the environment variables cluster/log-dump assumes for ssh access in the AWS case
  export SSH_USER=${KUBE_SSH_USER}
  export AWS_SSH_KEY=${KUBE_DENSITY_SSH_KEY}

  export BASH_ENV=$(pwd)/.bash_arrays
  go run hack/e2e.go --v --test --test_args="${common_test_args[*]} ${test_args[*]}" --check_version_skew=false
  e2e_result=$?
  rm ${BASH_ENV} && unset BASH_ENV

  return $e2e_result
}

echo
echo "Running density test..."
run_hack_e2e_go
density_result=$?

# XXX: undo evil monkey patch
mv cluster/aws.bak/* cluster/aws/
rm -rf cluster/aws.bak

popd

echo
echo "Density test run stop date: $(date -u)"
exit $density_result

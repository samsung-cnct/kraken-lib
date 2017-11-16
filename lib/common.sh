#!/bin/bash -
#title           :common.sh
#description     :common
#author          :Samsung SDSRA
#==============================================================================

# set KRAKEN_ROOT to absolute path for use in other scripts
readonly KRAKEN_ROOT=$(cd "${my_dir}/.."; pwd)

KRAKEN_FORCE=${KRAKEN_FORCE:-false}
KRAKEN_VERBOSE=${KRAKEN_VERBOSE:-false}
K2_VERBOSE=''
KRAKEN_TF_LOG=k2_tf_debug.log
VERBOSE=false
POSITIONAL=()
KRAKEN_HELP=false

UPDATE_NODEPOOLS=''
ADD_NODEPOOLS=''
REMOVE_NODEPOOLS=''
K8S_ENDPOINT=''

# set RANDFILE to prevent creation of ${HOME}/.rnd by openssl
export RANDFILE=$(mktemp)

function warn {
  echo -e "\033[1;33mWARNING: $1\033[0m"
}

function error {
  echo -e "\033[0;31mERROR: $1\033[0m"
}

function inf {
  echo -e "\033[0;32m$1\033[0m"
}

function run_command {
  inf "Running:\n $1"
  eval $1
}

function generate_config {
  inf "Generating config file at: $1"
  mkdir -p "${1%/*}"
  cp "${KRAKEN_ROOT}/ansible/roles/kraken.config/files/config.yaml" "${1}"
  exit 0
}

function show_help {
  inf "Usage: \n"
  inf "[up|down].sh --generate <path to file> - Generate a sensible defaults config at <path to file>"
  inf "[up|down].sh --output <path to cluster state output> --config <path to cluster config file> --tags <only run roles tagged with>"
  inf "[update].sh --nodepools <comma,separated,nodepools>"

  inf "\nFor example:"
  inf "[up].sh --generate"
  inf "[up].sh --generate \${HOME}/.kraken/myconfig.yaml"
  inf ""
  inf "[up].sh --output \${HOME}/.kraken/myclusterstate --config \${HOME}/.kraken/myclusterconfig.yaml --tags config,services"
  inf "[up].sh --config \${HOME}/.kraken/myclusterconfig.yaml"

}

function show_post_cluster {
  if [ -f ${KRAKEN_BASE}/help.txt ]; then
      inf "$(< ${KRAKEN_BASE}/help.txt)"
  else
      inf "To use kubectl: "
      inf "kubectl --kubeconfig=${KRAKEN_BASE}/<your cluster name>/admin.kubeconfig <kubctl command>\n"
      inf "For example: \nkubectl --kubeconfig=${KRAKEN_BASE}/krakenCluster/admin.kubeconfig get services --all-namespaces"
      inf "To use helm:"
      inf "KUBECONFIG=${KRAKEN_BASE}/<your cluster name>/admin.kubeconfig helm <helm command> --home ${KRAKEN_BASE}/<your cluster name>/.helm"
      inf "For example: \nKUBECONFIG=${KRAKEN_BASE}/krakenCluster/admin.kubeconfig helm list --home ${KRAKEN_BASE}/krakenCluster/.helm\n"
      inf "To ssh:"
      inf "ssh <node pool name>-<number> -F ${KRAKEN_BASE}/<your cluster name>/ssh_config"
      inf "For example: \nssh masterNodes-3 -F ${KRAKEN_BASE}/krakenCluster/ssh_config"
  fi
}

function show_post_cluster_error {
  warn "Some of the cluster state MAY be available:"
  show_post_cluster
  exit 1
}

function show_update {
  inf "Node versions have all been successfully updated."
}

function show_update_error {
  warn "The cluster has not been completely updated.  Some nodes may still be in the previous version."
  exit 1
}

# check if ansible return failure on up
# if failure, send to crash app
function crash_test_up {
  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    if [ -f "$K2_CRASH_APP" ]; then
      ${K2_CRASH_APP} ${LOG_FILE}
    else 
      echo "k2-crash-application not found, to capture the data from k2 failures, please install"
    fi
    show_post_cluster_error 
  else
    show_post_cluster
  fi
  exit $RESULT
}

# check if ansible return failure on down
# if failure, send to crash app
function crash_test_down {
  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    if [ -f "$K2_CRASH_APP" ]; then
      ${K2_CRASH_APP} ${LOG_FILE}
    else 
      echo "k2-crash-application not found, to capture the data from k2 failures, please install"
    fi
  fi
  exit $RESULT
}

# check if ansible return failure on update
# if failure, send to crash app
function crash_test_update {
  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    if [ -f "$K2_CRASH_APP" ]; then
      ${K2_CRASH_APP} ${LOG_FILE}
    else 
      echo "k2-crash-application not found, to capture the data from k2 failures, please install"
    fi
    show_update_error
  else
    show_update
  fi
  exit $RESULT
}

function control_c() {
  warn "Interrupted!"
  show_post_cluster_error
}
#!/bin/bash

# Copies logs useful for debugging kubernetes, container, or system problems to a
# directory of your choosing. Assumes the cluster was built using kraken.

set -o errexit
set -o nounset
set -o pipefail

die () {
    echo >&2 "$@"
    exit 1
}

while [[ $# > 1 ]]
do
key="$1"

case $key in
  --clustername)
  CLUSTER_NAME="$2"
  shift
  ;;
  --log-directory)
  LOG_DIRECTORY="$2"
  shift
  ;;
  *)
    # unknown option
  ;;
esac
shift # past argument or value
done

[[ -n "${CLUSTER_NAME-}" ]] || die "The --clustername parameter is required"
LOG_DIRECTORY=${LOG_DIRECTORY:-"$(pwd)/_artifacts"}

KRAKEN_ROOT=${KRAKEN_ROOT:-"$(pwd)"}
KRAKEN_CLUSTER_DIR="${KRAKEN_ROOT}/bin/clusters/${CLUSTER_NAME}"
KRAKEN_CLUSTER_SSH_CONFIG="${KRAKEN_CLUSTER_DIR}/ssh_config"
KRAKEN_CLUSTER_ANSIBLE_HOSTS="${KRAKEN_CLUSTER_DIR}/hosts"

SSH_CMD="ssh -F ${KRAKEN_CLUSTER_SSH_CONFIG}"
SCP_CMD="scp -F ${KRAKEN_CLUSTER_SSH_CONFIG}"

# Saves the output of running a given command ($2) on a given node ($1)
# into a given local file ($3). Does not fail if the ssh command fails for any
# reason, just prints an error to stderr.
function save_log() {
  local -r node_name="${1}"
  local -r cmd="${2}"
  local -r output_file="${3}"

  if ! ${SSH_CMD} "${node_name}" "${cmd}" > "${output_file}"; then
      echo "WARN: ${SSH_CMD} ${node_name} ${cmd} > ${output_file}" >&2
  fi
}

# Copies a remote directory ${2} from a given node ${1} and stores it in the
# destination directory ${3}. Does not fail if the ssh command fails for any
# reason, just prints an error to stderr.
function save_directory() {
  local -r node_name="${1}"
  local -r remote_directory="${2}"
  local -r destination_directory="${3}"

  if ! ${SCP_CMD} -r "${node_name}":"${remote_directory}" "${destination_directory}";
 then
    echo "WARN: ${SCP_CMD} -r ${node_name}:${remote_directory} ${destination_directory}" >&2
  fi
}

# Retrives logs from node ($1) and stores them in files under directory ($2).
function save_common_logs() {
    local -r node_name="${1}"
    local -r node_prefix="${2}"

    echo "Dumping common logs for ${node_name}"

    save_log "${node_name}" "journalctl --output=cat -k" "${node_prefix}/kern.log"
    save_log "${node_name}" "journalctl --output=cat -u docker" "${node_prefix}/docker.log"
    save_log "${node_name}" "journalctl --output=cat -u k8s-binary-kubelet.service" "${node_prefix}/kubelet.log"
    save_directory "${node_name}" "/var/log/k8s" "${node_prefix}"
}

function save_master_logs() {
  node_names=$(awk 'sub(/\[master\]/,""){f=1} /^\[[^\]\r\n]+/{f=0} {if (f) print $1}' ${KRAKEN_CLUSTER_ANSIBLE_HOSTS})

  for node_name in ${node_names}; do
    node_prefix="${LOG_DIRECTORY}/${node_name}"
    mkdir -p "${node_prefix}"

    echo "Dumping logs for master ${node_name}"

    save_log "${node_name}" "journalctl --output=cat -u k8s-binary-controller-manager.service" "${node_prefix}/kube-controller-manager.log"
    save_log "${node_name}" "journalctl --output=cat -u kube-scheduler.log" "${node_prefix}/kube-scheduler.log"
    save_common_logs "${node_name}" "${node_prefix}"
  done
}

function save_api_server_logs() {
  node_names=$(awk 'sub(/\[apiserver\]/,""){f=1} /^\[[^\]\r\n]+/{f=0} {if (f) print $1}' ${KRAKEN_CLUSTER_ANSIBLE_HOSTS})

  for node_name in ${node_names}; do
    node_prefix="${LOG_DIRECTORY}/${node_name}"
    mkdir -p "${node_prefix}"

    echo "Dumping logs for apiserver ${node_name}"

    save_log "${node_name}" "journalctl --output=cat -u k8s-binary-apiserver.service" "${node_prefix}/kube-apiserver.log"
    save_common_logs "${node_name}" "${node_prefix}"
  done
}

function save_etcd_logs() {
  node_names=$(awk 'sub(/\[etcd\]/,""){f=1} /^\[[^\]\r\n]+/{f=0} {if (f) print $1}' ${KRAKEN_CLUSTER_ANSIBLE_HOSTS})

  for node_name in ${node_names}; do
    node_prefix="${LOG_DIRECTORY}/${node_name}"
    mkdir -p "${node_prefix}"

    echo "Dumping logs for etcd ${node_name}"

    save_log "${node_name}" "journalctl --output=cat -u etcd2.service" "${node_prefix}/kube-etcd.log"
    save_common_logs "${node_name}" "${node_prefix}"
  done
}

function save_minion_logs() {
  node_names=$(awk 'sub(/\[node\]/,""){f=1} /^\[[^\]\r\n]+/{f=0} {if (f) print $1}' ${KRAKEN_CLUSTER_ANSIBLE_HOSTS})

  for node_name in ${node_names}; do
    node_prefix="${LOG_DIRECTORY}/${node_name}"
    mkdir -p "${node_prefix}"

    echo "Dumping logs for minion ${node_name}"

    save_common_logs "${node_name}" "${node_prefix}"
  done
}

function main() {
  echo "Dumping all node logs to ${LOG_DIRECTORY}"

  save_master_logs
  save_api_server_logs
  save_etcd_logs
  save_minion_logs
}

main

#!/bin/bash
#title        :common_helper.sh
#description  :Common fuctions and utils used by other scripts
#author       :Samsung SDSRA
#==============================================================================

set -o errexit
set -o nounset
set -o pipefail

etcd_peers=${ETCD_PEERS:-localhost}

wait_for_master()
{
  i=0
  until curl -o /dev/null -sIf ${MASTER}; do
	echo -e "${color_blue}Waiting for kubernetes master server to be available.${color_nc}. Try number $((i+=1)) "
    sleep 3
  done
  echo -e "${color_yellow}Kubernetes master at ${MASTER} is ready${color_nc}"
}

# Helper function to config etcdctl with correct params
# Defaults to using etcd running on localhost
etcdctl_get() {
  local key=$1

  if hash etcdctl 2>/dev/null; then
    etcdctl --endpoint "http://${etcd_peers}:4001" get $key
  else
    echo "ERROR: etcdctl is not installed or is not found in PATH"
  fi
}

etcdctl_set() {
  local key=$1
  local value=$2

  if hash etcdctl 2>/dev/null; then
    etcdctl --endpoint "http://${etcd_peers}:4001" set $key $value
  else
    echo "ERROR: etcdctl is not installed or is not found in PATH"
  fi
}

# scp server crt form master server

# scp user credential file from master server

#

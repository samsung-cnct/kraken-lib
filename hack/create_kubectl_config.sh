#!/bin/bash
# Load certs and tokens from etcd

set -e

MASTER_SERVER=${1:-k}
ETCD_CERT_KEY=${2:-kubernetes/kubernetes-auth}
KUBE_CERT_DIR=${3:-/srv/kubernetes}

if [ $? -ne 0 ]; then
  exit 1
fi

while [[ $# > 1 ]]; do

  case "$1" in
    -c|--cluster)
      CLUSTER_NAME="$2"
      shift;;
    -m|--master)
      MASTER_SERVER="$2"
      shift;;
    -d|--directory)
      KUBE_CERT_DIR="$2"
      shift;;
    -e|--etcd)
      ETCD_IP="$2"
      shift;;
    -k|--key)
      ETCD_CERT_KEY="$2"
      shift;;
    -u|--user)
      USER_LIST="$2"
      shift;;
    -b|--basic)
      AUTH_TYPE="basic-auth"
      ;;
    -t|--token)
      AUTH_TYPE="token"
      ;;
    --)
      shift; break;;
    *)
      echo -e "Not implemented: $1" >&2
      exit 1;;
  esac
  shift
done

# Create the kubeconfig file with /opt/bin/kubectl config
# TODO: path to /opt/bin/kubectl should not be hardcoded
# kube-proxy kubeconfig setup

wait_for_cert() {
  until $(curl --output /dev/null --silent --head --fail http://${ETCD_IP}:4001/v2/keys/${ETCD_CERT_KEY}); do
    printf '.'
    sleep 3
  done
}

wait_for_user() {
  local username=$1
  until $(curl --output /dev/null --silent --head --fail http://${ETCD_IP}:4001/v2/keys/${ETCD_CERT_KEY}/${username}/${AUTH_TYPE}); do
    printf '.'
    sleep 3
  done
}

load_kube_cert_ca() {
  wait_for_cert
  etcdctl --endpoint "http://${ETCD_IP}:4001" get /${ETCD_CERT_KEY}/kube-ca-pem > ${KUBE_CERT_DIR}/kube-ca.pem
}

get_user_creds() {
  local username=$1
  wait_for_user $username
  etcdctl --endpoint "http://${ETCD_IP}:4001" get /${ETCD_CERT_KEY}/${username}/${AUTH_TYPE}
}

create_kube_config() {
  cert_authority=${KUBE_CERT_DIR}/kube-ca.pem
  user_arr=$(echo $USER_LIST | tr "," "\n")

  for u in $user_arr; do
    key=$(get_user_creds $u)
    echo "Creating kubeconfig for ${u} stored at ${KUBE_CERT_DIR}/${u}/kubeconfig"
    /opt/bin/kubectl config set-cluster $CLUSTER_NAME --kubeconfig=${KUBE_CERT_DIR}/${u}/kubeconfig --server=https://${MASTER_SERVER} --certificate-authority=${cert_authority} --embed-certs=true
    /opt/bin/kubectl config set-context $CLUSTER_NAME --kubeconfig=${KUBE_CERT_DIR}/${u}/kubeconfig --cluster=${CLUSTER_NAME} --user=${u}

    if [ "$AUTH_TYPE" == "basic-auth" ]; then
      /opt/bin/kubectl config set-credentials ${u} --kubeconfig=${KUBE_CERT_DIR}/${u}/kubeconfig --username=${u} --password=${key}
    elif [ "$AUTH_TYPE" == "token" ]; then
      /opt/bin/kubectl config set-credentials ${u} --kubeconfig=${KUBE_CERT_DIR}/${u}/kubeconfig --token=${key}
    fi

    /opt/bin/kubectl config use-context $CLUSTER_NAME --kubeconfig=${KUBE_CERT_DIR}/${u}/kubeconfig
  done
}

load_kube_cert_ca
create_kube_config

exit $?

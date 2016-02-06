#!/bin/bash
# Load certs and tokens from etcd

set -o errexit
set -o nounset
#set -o pipefail

if [ $? -ne 0 ]; then
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "Error: Missing options"
  exit 1
fi

while [[ $# > 1 ]]; do

  case "$1" in
    -e|--etcd)
      ETCD_IP="$2"
      shift;;
    -k|--key)
      ETCD_CERT_KEY="$2"
      shift;;
    -d|--directory)
      KUBE_CERT_DIR="$2"
      shift;;
    --)
      shift; break;;
    *)
      echo -e "Not implemented: $1" >&2
      exit 1;;
  esac
  shift
done

wait_for_cert() {
  until $(curl --output /dev/null --silent --head --fail http://${ETCD_IP}:4001/v2/keys/${ETCD_CERT_KEY}); do
    printf '.'
    sleep 3
  done
}

wait_for_cert

# Load server ca from etcd
/usr/bin/etcdctl get /${ETCD_CERT_KEY}/kube-ca-pem > ${KUBE_CERT_DIR}/kube-ca.pem

# Load server ca key from etcd
/usr/bin/etcdctl get /${ETCD_CERT_KEY}/kube-ca-key-pem > ${KUBE_CERT_DIR}/kube-ca-key.pem

exit $?
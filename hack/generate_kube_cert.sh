#!/bin/bash -
#title           :generate-kube-auth.sh
#description     :Generate kubernetes credentials
#author          :Samsung SDSRA
#==============================================================================

set -o errexit
set -o nounset
#set -o pipefail

KRAKEN_ROOT="$(dirname "${BASH_SOURCE[0]}")/../"

if [ $? -ne 0 ]; then
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "Error: Missing options"
  exit 1
fi

while [[ $# > 1 ]]; do

  case "$1" in
    -d|--directory)
      KUBE_CERT_DIR="$2"
      shift;;
    -e|--etcd)
      ETCD_PEERS="$2"
      shift;;
    -k|--key)
      ETCD_KEY_PART="$2"
      shift;;
    --)
      shift; break;;
    *)
      echo -e "Not implemented: $1" >&2
      exit 1;;
  esac
  shift
done

source ${KRAKEN_ROOT}/hack/common_helper.sh

# Use CloudFlares ssl and PKI management tool to create the certs
# using the cfssl docker container from docker hub.
# TODO: We currently only generate one set of certs for all profiles. Need to break this up
# for system users, admin accounts, and end user TLS. This will require a process to programically create the csr and config jsons.
generate_certs() {
  docker run -i -v ${KUBE_CERT_DIR}:/opt/kube-ca -w /opt/kube-ca cfssl/cfssl gencert -initca server-ca-csr.json | \
  docker run -i -v ${KUBE_CERT_DIR}:/opt/kube-ca -w /opt/kube-ca --entrypoint cfssljson cfssl/cfssl -bare kube-ca
}

generate_certs

# Store server ca into etcd
echo "Inserting ${KUBE_CERT_DIR}/kube-ca.pem into /${ETCD_KEY_PART}/kube-ca-pem"
/usr/bin/etcdctl set /${ETCD_KEY_PART}/kube-ca-pem < ${KUBE_CERT_DIR}/kube-ca.pem

# Store server ca key into etcd
# CA key is not world readable thus the need for sudo
echo "Inserting ${KUBE_CERT_DIR}/kube-ca-key.pem into /${ETCD_KEY_PART}/kube-ca-key-pem"
/usr/bin/etcdctl set /${ETCD_KEY_PART}/kube-ca-key-pem < ${KUBE_CERT_DIR}/kube-ca-key.pem

exit $?
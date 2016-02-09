#!/bin/bash -
#title           :load_kube_auth.sh
#description     :Load and write kubernetes auth information from ETCD
#author          :Samsung SDSRA

set -o errexit
set -o nounset
# set -o pipefail

if [ $? -ne 0 ]; then
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "Error: Missing options"
  exit 1
fi

while [[ $# > 1 ]]; do

  case "$1" in
    -c|--cluster)
      CLUSTER_NAME="$2"
      shift;;
    -e|--etcd)
      ETCD_PEERS="$2"
      shift;;
    -k|--key)
      ETCD_CERT_KEY="$2"
      shift;;
    -d|--directory)
      KUBE_CERT_DIR="$2"
      shift;;
    -u|--user)
      USER_LIST="$2"
      shift;;
    -s|--server)
      SERVER="$2"
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

# Create password for a given user and append to the basic_auth file
get_user_creds() {
  local username=$1
  etcdctl --endpoint "http://${ETCD_PEERS}:4001" get /${ETCD_CERT_KEY}/${username}/${AUTH_TYPE}
}

# kubectl is assumed to be in the path.
# TODO: first check for kubectl and if not found use a side loaded kubectl binary
write_kube_auth() {

  user_arr=$(echo $USER_LIST | tr "," "\n")

  for u in $user_arr; do
    key=$(get_user_creds $u)
    echo "Writing auth information to ${KUBE_CERT_DIR} for ${u}"
    if [ $AUTH_TYPE == "basic-auth" ]; then
      echo -e "${key},${u},${u}" >> ${KUBE_CERT_DIR}/${AUTH_FILE}
    else
      echo -e "${key},${u},${u}" >> ${KUBE_CERT_DIR}/${AUTH_FILE}
    fi
  done
}

case ${AUTH_TYPE} in
  'basic-auth')
    AUTH_FILE="basic_auth.csv"
    ;;
  'token')
    AUTH_FILE="known_tokens.csv"
    ;;
  *)
    echo "Invalid auth_type selected"
    exit 1
esac

# Remove previous auth file prior creating one
rm -f ${KUBE_CERT_DIR}/${AUTH_FILE}

write_kube_auth

exit $?
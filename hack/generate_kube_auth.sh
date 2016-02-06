#!/bin/bash -
#title           :generate-kube-auth.sh
#description     :Generate kubernetes credentials
#author          :Samsung SDSRA
#==============================================================================

set -o errexit
set -o nounset
# Disabling pipefail due to it failing on password and token creation
# The known_auth and token files that are created appear to be correct.
#set -o pipefail

KRAKEN_ROOT="$(dirname "${BASH_SOURCE[0]}")/../"

if [ $? -ne 0 ]; then
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "Error: Missing options"
  exit 1
fi

# NOTE: For USER: both a comma seperate list of users or a single user is acceptable
# Should really be USERS vs USER but whatevers.
while [[ $# > 1 ]]; do
  case "$1" in
    -d|--directory)
      KUBE_CERT_DIR="$2"
      shift;;
    -e|--etcd)
      ETCD_PEERS="$2"
      shift;;
    -k|--key)
      ETCD_CERT_KEY="$2"
      shift;;
    -b|--basic-auth)
      AUTH_TYPE="basic-auth"
      ;;
    -t|--token)
      AUTH_TYPE="token"
      ;;
    -u|-user)
      USER_LIST="$2"
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

set_etcd() {
  local username=$1
  local access_key=$2
  local auth_type=$3
  echo "Setting /${ETCD_CERT_KEY}/${username}/${auth_type} into etcd"
  etcdctl_set /${ETCD_CERT_KEY}/${username}/${auth_type} "${access_key}"
}

# Create password for a given user and append to the basic_auth file
create_user_basic() {
  local username=$1
  echo "Username is ${username}"
  local password=$(/usr/bin/cat /dev/urandom | tr -cd 'a-zA-Z0-9_' | head -c 12 | xargs )
  echo "${password},${username},${username}" >> ${KUBE_CERT_DIR}/basic_auth.csv

  set_etcd $username $password "basic-auth"

  docker run --entrypoint htpasswd httpd:2.4 -bn ${username} ${password} >> ${KUBE_CERT_DIR}/.htpasswd
}

# Create a token for a given user and append to the known_tokens file
create_user_token() {
  local username=$1
  echo "Username is ${username}"
  local token=$(/usr/bin/cat /dev/urandom | tr -cd 'a-zA-Z0-9_' | head -c 12 | xargs)
  echo "${token},${username},${username}" >> ${KUBE_CERT_DIR}/known_tokens.csv

  set_etcd $username $token "token"
}

# This is a very dirty way to handle preexisting auth files.
# Truncate it and proceed with creation of accounts anew.
nuke_creds_file() {
  local creds_file=$1
  if [ -f $creds_file ]; then
    :> $creds_file
  fi
}

user_arr=$(echo $USER_LIST | tr "," "\n")

echo "The user array is ${user_arr}"

if [ "$AUTH_TYPE" == "basic-auth" ]; then
  nuke_creds_file ${KUBE_CERT_DIR}/basic_auth.csv
  nuke_creds_file ${KUBE_CERT_DIR}/.htpasswd
  for u in $user_arr; do
    echo "Creating a basic auth account for ${u}"
    create_user_basic $u
  done
elif [ "$AUTH_TYPE" == "token" ]; then
  nuke_creds_file ${KUBE_CERT_DIR}/known_tokens.csv
  for u in $user_arr; do
    echo "Creating a token account for ${u}"
    create_user_token $u
  done
else
  echo "Auth-type ${AUTH_TYPE} not suppported"
  exit 2
fi

exit $?

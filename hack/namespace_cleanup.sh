#!/bin/bash -
#title           :namespace_cleanup.sh
#description     :This script attempt to cleanup leftover test namespaces
#author          :Samsung SDSRA
#==============================================================================

while [[ $# > 1 ]]
do
key="$1"

case $key in
    -e|--etcd)
    ETCD_IP="$2"
    shift # past argument
    ;;
    -p|--prefix)
    NAMESPACE_PREFIX="$2"
    shift # past argument
    ;;
    -c|--config)
    SSH_CONFIG_PATH="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

if [ -z ${ETCD_IP+x} ]; then
  echo "--etcd not specified. Etcd ip address or host name is required."
  exit 1
fi

if [ -z ${SSH_CONFIG_PATH+x} ]; then
  echo "--config not specified. Assuming $ETCD_IP to be an ip address or host name."
else
  echo "--config specified. Assuming $ETCD_IP to be a host name configured in $SSH_CONFIG_PATH."
fi

if [ -z ${NAMESPACE_PREFIX+x} ]; then
  echo "--prefix not specified. Assuming 'e2e-tests'"
  NAMESPACE_PREFIX="e2e-tests"
fi

echo "Removing all namespaces containing '$NAMESPACE_PREFIX' on etcd server $ETCD_IP..."

ssh_command=
if [ -z ${SSH_CONFIG_PATH+x} ]; then
  ssh_command="ssh core@$ETCD_IP"
else
  ssh_command="ssh -F $SSH_CONFIG_PATH $ETCD_IP"
fi

namespaces=( $($ssh_command etcdctl ls /registry/namespaces) )

for i in "${namespaces[@]}"
do
  if [[ "$i" == *"$NAMESPACE_PREFIX"* ]]; then
    eval "$ssh_command etcdctl rm $i"
    echo "Removed namespace $i"
  else
    echo "Skipping namespace $i"
  fi
done
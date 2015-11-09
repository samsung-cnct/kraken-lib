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
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

if [ -z ${ETCD_IP+x} ]; then
  error "--etcd not specified. Etcd ip address is required."
  exit 1
fi

if [ -z ${NAMESPACE_PREFIX+x} ]; then
  echo "--prefix not specified. Assuming 'e2e-tests'"
  NAMESPACE_PREFIX="e2e-tests"
fi

echo "Removing all namespaces containing '$NAMESPACE_PREFIX' on etcd server $ETCD_IP..."

namespaces=( $(ssh core@$ETCD_IP etcdctl ls /registry/namespaces) )

for i in "${namespaces[@]}"
do
  if [[ "$i" == *"$NAMESPACE_PREFIX"* ]]; then
    ssh core@52.33.220.26 etcdctl rm "$i"
    echo "Removed namespace $i"
  else
    echo "Skipping namespace $i"
  fi
done
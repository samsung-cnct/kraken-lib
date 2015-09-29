#!/bin/bash
if [[ $# < 2 ]]
then
  echo "Usage: unprovisioned_nodes.sh -c [cluster type] -e [etcd instance ip] -p [etcd port]"
  echo "./unprovisioned_nodes.sh -c aws -e 52.89.52.19 -p 4001"
  exit 
fi

while [[ $# > 1 ]]
do
key="$1"

case $key in
    -c|--cluster)
    CLUSTER="$2"
    shift # past argument
    ;;
    -e|--etcdip)
    ETCD_IP="$2"
    shift # past argument
    ;;
    -p|--etcdport)
    ETCD_PORT="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

fleet_array=($(fleetctl --endpoint=http://${ETCD_IP}:${ETCD_PORT} list-machines | grep node | awk '{ print $2 }'))
kube_array=($(kubectl --cluster=${CLUSTER} get nodes | tail -n +2 | awk '{ print $1 }'))
delta=(`echo ${fleet_array[@]} ${kube_array[@]} | tr ' ' '\n' | sort | uniq -u `)

echo "Fleet nodes not provisioned with kubernetes:"
echo ${delta[*]}
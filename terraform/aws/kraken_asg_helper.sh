#!/bin/bash -
#title           :kraken_asg_helper.sh
#description     :This script will wait for the count of kubernetes cluster nodes to reach some number,and then query a given AWS Autoscaling Group
#                 And append the public ips of all nodes in the group into a file
#author          :Samsung SDSRA
#==============================================================================

while [[ $# > 1 ]]
do
key="$1"

case $key in
    -c|--cluster)
    CLUSTER="$2"
    shift # past argument
    ;;
    -l|--limit)
    NODE_LIMIT="$2"
    shift # past argument
    ;;
    -n|--name)
    ASG_NAME="$2"
    shift # past argument
    ;;
    -o|--output)
    OUTPUT_FILE="$2"
    shift # past argument
    ;;
    -s|--singlewait)
    SLEEP_TIME="$2"
    shift # past argument
    ;;
    -t|--totalwaits)
    TOTAL_WAITS="$2"
    shift # past argument
    ;;
    -r|--retries)
    RETRIES="$2"
    shift # past argument
    ;;
    -e|--etcd)
    ETCD_IP="$2"
    shift # past argument
    ;;
    -p|--port)
    ETCD_PORT="$2"
    shift # past argument
    ;;
    -o|--offset)
    NUMBERING_OFFSET="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

echo Cluster type is ${CLUSTER}
echo Waiting for ${NODE_LIMIT} EC2 instances
echo Autoscaling group name is ${ASG_NAME}
echo Will append public IPs to ${OUTPUT_FILE}
echo Waiting for ${SLEEP_TIME} between each check
echo $((SLEEP_TIME*TOTAL_WAITS)) seconds total single wait
echo $((SLEEP_TIME*TOTAL_WAITS*RETRIES)) seconds total wait time
echo Host numbering offset is ${NUMBERING_OFFSET}
echo ETCD ip address is ${ETCD_IP}
echo ETCD ip port number is ${ETCD_PORT}

kube_node_count=$(kubectl --cluster=${CLUSTER} get nodes | tail -n +2 | wc -l)
max_loops=$((TOTAL_WAITS-1))
max_retries=$((RETRIES-1))
success=1

while [ ${kube_node_count} -lt ${NODE_LIMIT} ]
do
  if [ ${max_loops} -ge 0 ]; then
    echo Current node count is ${kube_node_count}. Waiting for ${SLEEP_TIME} seconds.
    sleep ${SLEEP_TIME}
    kube_node_count=$(kubectl --cluster=${CLUSTER} get nodes | tail -n +2 | wc -l)
    max_loops=$((max_loops-1))
  elif [ ${max_retries} -ge 0 ]; then
    echo Waited for $((SLEEP_TIME*TOTAL_WAITS)). Will attempt to detect and restart failed autoscaling group nodes.
    fleet_array=($(fleetctl --endpoint=http://${ETCD_IP}:${ETCD_PORT} list-machines | grep node | awk '{ print $2 }'))
    kube_array=($(kubectl --cluster=${CLUSTER} get nodes | tail -n +2 | awk '{ print $1 }'))
    delta=(`echo ${fleet_array[@]} ${kube_array[@]} | tr ' ' '\n' | sort | uniq -u `)
    private_ips=$( IFS=$','; echo "${delta[*]}" )
    echo -e "Etcd nodes not yet present in kubernetes cluster:\n${private_ips}"

    ec2_instances=($(aws --output text \
        --query "Reservations[*].Instances[*].[InstanceId]" \
        ec2 describe-instances --filters "Name=private-ip-address,Values=${private_ips}" --instance-ids \
        `aws --output text --query "AutoScalingGroups[0].Instances[*].InstanceId" \
        autoscaling describe-auto-scaling-groups --auto-scaling-group-names "${ASG_NAME}"`))
    echo -e "Instances to be terminated:\n$( IFS=$','; echo "${ec2_instances[*]}" )"
    aws --output text ec2 terminate-instances --instance-ids $( IFS=$','; echo "${ec2_instances[*]}" )

    # reset max loops and decrement retries
    max_loops=$((TOTAL_WAITS-1))
    max_retries=$((max_retries-1))
  else
    success=0
    echo Maximum wait of $((SLEEP_TIME*TOTAL_WAITS)) seconds reached.
    break
  fi
done

ec2_ips=$(aws --output text \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
    ec2 describe-instances --instance-ids \
    `aws --output text --query "AutoScalingGroups[0].Instances[*].InstanceId" autoscaling describe-auto-scaling-groups --auto-scaling-group-names "${ASG_NAME}"`)

current_node=$((NUMBERING_OFFSET+1))
output="\n[nodes]\n"
for ec2_ip in $ec2_ips; do
  output="${output}$(printf 'node-%03d' ${current_node}) ansible_ssh_host=$ec2_ip\n"
  current_node=$((current_node+1))
done

echo -e $output >> ${OUTPUT_FILE}

if (( success )); then
  echo "Success!"
else
  echo "Failure!"
fi

exit $((!$success))
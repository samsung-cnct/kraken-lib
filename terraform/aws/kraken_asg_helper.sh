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
echo $((SLEEP_TIME*TOTAL_WAITS)) seconds total wait
echo Host numbering offset is ${NUMBERING_OFFSET}

kube_node_count=$(kubectl --cluster=${CLUSTER} get nodes | tail -n +2 | wc -l)
max_loops=$((TOTAL_WAITS-1))
success=1

while [ $kube_node_count -lt ${NODE_LIMIT} ]
do
  if [ $max_loops -ge 0 ]; then
    echo Current node count is ${kube_node_count}. Waiting for ${SLEEP_TIME} seconds.
    sleep ${SLEEP_TIME}
    kube_node_count=$(kubectl --cluster=aws get nodes | tail -n +2 | wc -l)
    max_loops=$((max_loops-1))
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
  output="$output$(printf 'node-%03d' $current_node) ansible_ssh_host=$ec2_ip\n"
  current_node=$((current_node+1))
done 

echo -e $output >> ${OUTPUT_FILE}

if (( success )); then
  echo "Success!"
else 
  echo "Failure!"
fi

exit $((!$success))
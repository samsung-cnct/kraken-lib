#!/bin/bash 
#
# wrapper scipt to run on the master. 
#
# create all the certs/key
# create all the tokens
# create the config files
#
# arg: $1 IP of the Master
#
# 8/18/2015 mikeln
#
set -o errexit
set -o nounset
set -o pipefail

my_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cur_dir=$( pwd )
echo "CUR: ${cur_dir}"

if [ $# -lt 1 -o  $# -gt 3 ]; then
    echo "Usage $0 <Master IP> <DNS IP> [Cert Directory]"
    exit 1
fi
#
# set the needed IP addresses ... assumes the master_IP is in the CIDR
master_ip=$1
low_ip=${master_ip%.*}.1
#
#
dns_ip=$2
pod_low_ip=${dns_ip%.*}.1
pod_high_ip=${dns_ip%.*}.255
#
#
if [ $# -eq 3 ]; then
    tmp_cert_dir=$3
else
    tmp_cert_dir=$(mktemp -d ${cur_dir}/kube-certs)
fi
echo "tmp_cert_dir: ${tmp_cert_dir}"
CERT_DIR=${CERT_DIR:-${tmp_cert_dir}}
CERT_GROUP=${CERT_GROUP:-root}
echo "my_dir: ${my_dir} master: ${master_ip} low: ${low_ip} pod: ${pod_low_ip}:${pod_high_ip} cert_group: ${CERT_GROUP} cert_dir: ${CERT_DIR}"
#
source ${my_dir}/make-ca-cert.sh ${master_ip} IP:${master_ip},IP:${low_ip},IP:${pod_low_ip},IP:${pod_high_ip},DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local

SRV_BASE_DIR=$CERT_DIR
source "${my_dir}/make-token.sh"
#
# wrap up into a tar file
#
tar -C $CERT_DIR --exclude kube-certs.tgz  -cvzf $CERT_DIR/kube-certs.tgz  .

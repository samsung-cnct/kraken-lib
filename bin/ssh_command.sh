#!/bin/bash -
#title          :ssh_command.sh
#description    :runs a command on top of ssh
#author         :Samsung SDSRA
#====================================================================
set -o errexit
set -o nounset
set -o pipefail

# pull in utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/../lib/common.sh"

USE_HOST_NAME=true
PORT=22
SSH_OPTIONS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

function show_help {
    inf "Usage:"
    inf "[ssh_command].sh --verbose --address <ip-address> --port <port> --user <user> <command>"
    inf "[ssh_command].sh -v -a <ip-address> -p <port> -u <user> <command>"
    inf "[ssh_command].sh --verbose --ssh-config <ssh_config> --hostname <host> <command>"
    inf "[ssh_command].sh -v -f <ssh_config> -n <host> <command>"

    inf "\nFor example:"
    inf "[ssh_command].sh --verbose --address 44.198.159.24 --port 7022  --user core docker pull quay.io/coreos/etcd:latest"
    inf "[ssh_command].sh -v -a 44.198.159.24 -p 7022 -u core -c 'docker pull quay.io/coreos/etcd:latest'"
    inf "[ssh_command].sh --verbose --ssh-config /Users/user/.kraken/cluster/ssh_config --hostname etcd-1 docker pull quay.io/coreos/etcd:latest"
    inf "[ssh_command].sh -v -f /Users/user/.kraken/cluster/ssh_config -n etcd-1 docker pull quay.io/coreos/etcd:latest"
}

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -p|--port)
    PORT="$2"
    shift 2
    ;;
    -a|--address)
    ADDRESS="$2"
    shift 2
    ;;
    -u|--user)
    USER_NAME="$2"
    shift 2
    ;;
    -n|--hostname)
    HOST_NAME="$2"
    shift 2
    ;;
    -h|--help)
    KRAKEN_HELP=true
    shift 1
    ;;
    -f|--ssh-config)
    SSH_CONFIG="-F $2"
    shift 2
    ;;
    -v|--verbose)
    VERBOSE=true
    shift 1
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

if [ ${#POSITIONAL[@]} -eq 0 ]; then
    error "please enter a valid command"
    exit 1
fi

set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "${KRAKEN_HELP}" == true ]; then
    show_help
    exit 0
fi

re='^[0-9]+$'
if ! [[ ${PORT} =~ $re ]] ; then
    error "the port value entered: ${PORT} must be a number"
    exit 1
fi

if [ -n "${ADDRESS+x}" ]  && [ -n "${USER_NAME+x}" ]; then
    HOST="${USER_NAME}@${ADDRESS} -p ${PORT}"
    USE_HOST_NAME=false
fi

if [ "${USE_HOST_NAME}" == true ]; then
    if [ -n "${HOST_NAME+x}" ]; then
        HOST=${HOST_NAME}
    else
        error "please use a hostname(-h) or user(-u)@address(-a) port(-p)"
        exit 1
    fi
fi

if [ -n "${VERBOSE+x}" ]; then
    echo ssh -tt ${SSH_CONFIG} ${SSH_OPTIONS} ${HOST} $@
fi

ssh -tt ${SSH_CONFIG} ${SSH_OPTIONS} ${HOST} $@

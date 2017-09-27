#!/usr/bin/env bash

USE_HOST_NAME=true

function error {
  echo -e "\033[0;31mERROR: $1\033[0m"
}

function inf {
  echo -e "\033[0;32m$1\033[0m"
}

function show_help {
  inf "Usage:"
  inf "[ssh_command].sh --verbose --address <ip-address> --port <port> --user <user> --command '<command>'"
  inf "[ssh_command].sh -v -a <ip-address> -p <port> -u <user> -c '<command>'"
  inf "[ssh_command].sh --verbose --ssh-config <ssh_config> --hostname <host> --command '<command>'"
  inf "[ssh_command].sh -v -c <ssh_config> -n <host> -c '<command>'"

  inf "\nFor example:"
  inf "[ssh_command].sh --verbose --address 44.198.159.24 --port 7022  --user core --command 'docker pull quay.io/coreos/etcd:latest'"
  inf "[ssh_command].sh -v -a 44.198.159.24 -p 7022 -u core -c 'docker pull quay.io/coreos/etcd:latest'"
  inf "[ssh_command].sh --verbose --ssh-config /Users/user/.kraken/cluster/ssh_config --hostname etcd-1 --command 'docker pull quay.io/coreos/etcd:latest'"
  inf "[ssh_command].sh -v -f /Users/user/.kraken/cluster/ssh_config -n etcd-1 -c 'docker pull quay.io/coreos/etcd:latest'"
}

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
  -c|--command)
  COMMAND="$2"
  shift
  ;;
  -p|--port)
  PORT="$2"
  shift
  ;;
  -a|--address)
  ADDRESS="$2"
  shift
  ;;
  -u|--user)
  USER_NAME="$2"
  shift
  ;;
  -n|--hostname)
  HOST_NAME="$2"
  shift
  ;;
  -h|--help)
  HELP=true
  ;;
  *)
  HELP=true
  ;;
  -f|--ssh-config)
  SSH_CONFIG="$2"
  shift
  ;;
  -v|--verbose)
  VERBOSE=false
  ;;
  *)
  VERBOSE=false
  ;;
esac
shift # past argument or value
done

if [ -n "${HELP+x}" ]; then
  show_help
  exit 0
fi

if [ -n "${SSH_CONFIG+x}" ]; then
  SSH_CONFIG="-F ${SSH_CONFIG}"
fi

# set default if need be.
if [ -z "${PORT+x}" ]; then
  PORT=22
fi

re='^[0-9]+$'
if ! [[ ${PORT} =~ $re ]] ; then
   error "the port value entered: ${PORT} must be a number"
   exit 1
fi

if [ -z "${COMMAND+x}" ]; then
  error "please enter a valid command"
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
  echo "to run: "
  echo "ssh -tt ${SSH_CONFIG} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${HOST} ${COMMAND}"
fi

ssh -tt ${SSH_CONFIG} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${HOST} ${COMMAND}

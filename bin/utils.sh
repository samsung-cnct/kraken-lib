#!/bin/bash -
#title           :utils.sh
#description     :utils
#author          :Samsung SDSRA
#==============================================================================

my_dir=$(dirname "${BASH_SOURCE}")

# set KRAKEN_ROOT to absolute path for use in other scripts
readonly KRAKEN_ROOT=$(cd "${my_dir}/.."; pwd)
KRAKEN_VERBOSE=${KRAKEN_VERBOSE:-false}

function warn {
  echo -e "\033[1;33mWARNING: $1\033[0m"
}

function error {
  echo -e "\033[0;31mERROR: $1\033[0m"
}

function inf {
  echo -e "\033[0;32m$1\033[0m"
}

function run_command {
  inf "Running:\n $1"
  eval $1
}

function generate_config {
  inf "Generating config file at: $1"
  mkdir -p "${1%/*}"
  cp "${KRAKEN_ROOT}/ansible/roles/kraken.config/files/config.yaml" "${1}"
  exit 0
}

function show_help {
  inf "Usage: \n"
  inf "[up|down].sh --generate <path to file> - Generate a sensible defaults config at <path to file>"
  inf "[up|down].sh --output <path to cluster state output> --config <path to cluster config file> --tags <only run roles tagged with>"

  inf "\nFor example:"
  inf "[up|down].sh --generate"
  inf "[up|down].sh --generate ~/.kraken/myconfig.yaml"
  inf ""
  inf "[up|down].sh --output ~/.kraken/myclusterstate --config ~/.kraken/myclusterconfig.yaml --tags config"
  inf "[up|down].sh --config ~/.kraken/myclusterconfig.yaml"
}

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
  -c|--config)
  KRAKEN_CONFIG="$2"
  shift
  ;;
  -g|--generate)
  KRAKEN_GENERATE_PATH="${2-"${HOME}/.kraken/config.yaml"}"
  if [ -n "${2+x}" ]; then
    shift
  fi
  ;;
  -o|--output)
  KRAKEN_BASE="$2"
  shift
  ;;
  -t|--tags)
  KRAKEN_TAGS="$2"
  shift
  ;;
  -h|--help)
  KRAKEN_HELP=true
  ;;
  *)
  KRAKEN_HELP=true
  ;;
esac
shift # past argument or value
done

if [ -n "${KRAKEN_HELP+x}" ]; then
  show_help
  exit 0
fi

if [ -n "${KRAKEN_GENERATE_PATH+x}" ]; then
  generate_config "${KRAKEN_GENERATE_PATH}"
fi

if [ -z ${KRAKEN_CONFIG+x} ]; then
  warn "--config not specified. Using ~/.kraken/config.yml as location"
  KRAKEN_CONFIG="~/.kraken/config.yml"
fi

if [ -z ${KRAKEN_BASE+x} ]; then
  warn "--output not specified. Using ~/.kraken as location"
  KRAKEN_BASE="~/.kraken"
fi

if [ -z ${KRAKEN_TAGS+x} ]; then
  KRAKEN_TAGS="all" 
fi

KRAKEN_EXTRA_VARS="config_path=${KRAKEN_CONFIG} config_base=${KRAKEN_BASE} "
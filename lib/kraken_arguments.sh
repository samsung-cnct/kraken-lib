#!/bin/bash -
#title           :kraken_arguments.sh
#description     :common argument parsing
#author          :Samsung SDSRA
#==============================================================================

# pull in common utils
my_dir=$(dirname "${BASH_SOURCE}")
source "${my_dir}/common.sh"


while [[ $# -gt 0 ]]
do
key="$1"

case $key in
  -c|--config)
  KRAKEN_CONFIG="$2"
  shift
  ;;
  -f|--force)
  KRAKEN_FORCE=true
  ;;
  -n|--nodepools)
  UPDATE_NODEPOOLS="$2"
  shift
  ;;
  -a|--addnodepools)
  ADD_NODEPOOLS="$2"
  shift
  ;;
  -r|--rmnodepools)
  REMOVE_NODEPOOLS="$2"
  shift
  ;;
  -g|--generate)
  KRAKEN_GENERATE_PATH="${HOME}/.kraken/config.yaml"
  ;;
  -o|--output)
  KRAKEN_BASE="$2"
  shift
  ;;
  -t|--tags)
  KRAKEN_TAGS="$2"
  shift
  ;;
  -k|--kubernetesendpoint)
  K8S_ENDPOINT="$2"
  shift
  ;;
  -v|--verbose)
  K2_VERBOSE="-vvv"
  ;;
  -p|--provider)
  KRAKEN_PROVIDER="$2"
  shift
  ;;
  -h|--help)
  KRAKEN_HELP=true
  shift
  ;;
  *)
  ;;
esac
shift # past argument or value
done

if [ "${KRAKEN_HELP}" == true ]; then
  show_help
  exit 0
fi

if [ -z ${KRAKEN_CONFIG+x} ]; then
  warn "--config not specified. Using ${HOME}/.kraken/config.yaml as location"
  KRAKEN_CONFIG="${HOME}/.kraken/config.yaml"
fi

if [ -n "${KRAKEN_GENERATE_PATH+x}" ]; then
  KRAKEN_GENERATE_PATH=${KRAKEN_CONFIG}

  if [[ -n ${KRAKEN_PROVIDER+x} ]]; then
    if [ $KRAKEN_PROVIDER == "GKE" ]; then
        generate_config "${KRAKEN_GENERATE_PATH}" GKE
    fi
  fi

  generate_config "${KRAKEN_GENERATE_PATH}" AWS
fi

if [ -z ${KRAKEN_BASE+x} ]; then
  warn "--output not specified. Using ${HOME}/.kraken as location"
  KRAKEN_BASE="${HOME}/.kraken"
fi

if [ -z ${KRAKEN_TAGS+x} ]; then
  KRAKEN_TAGS="all"
  warn "$KRAKEN_TAGS not specified. Using 'all' as tags"
else
  warn "Using '${KRAKEN_TAGS}' as tags "
fi

if [[ ${KRAKEN_TAGS} == *dryrun* ]]; then
    KRAKEN_DRYRUN=true
else
    KRAKEN_DRYRUN=false
fi

if [[ ${KRAKEN_TAGS} == *dns_only* ]]; then
    DNS_ONLY=true
else
    DNS_ONLY=false
fi

KRAKEN_EXTRA_VARS="${KRAKEN_EXTRA_VARS:-""} \
                   config_path=${KRAKEN_CONFIG} \
                   config_base=${KRAKEN_BASE} \
                   config_forced=${KRAKEN_FORCE} \
                   dryrun=${KRAKEN_DRYRUN} \
                   update_nodepools=${UPDATE_NODEPOOLS} \
                   add_nodepools=${ADD_NODEPOOLS} \
                   remove_nodepools=${REMOVE_NODEPOOLS} \
                   dns_only=${DNS_ONLY} \
                   kubernetes_endpoint=${K8S_ENDPOINT}"

if [ ! -z ${BUILD_TAG+x} ]; then
    K2_VERBOSE='-vvv'
fi

if [ ! -z ${K2_VERBOSE+x} ]; then
   TF_LOG_PATH="${KRAKEN_ROOT}/${KRAKEN_TF_LOG}"
   TF_LOG=DEBUG
fi

#!/bin/sh

# to run locally
# export CI_PROJECT_DIR=$"<local_directory>"

PROVIDER=$( echo "$1" | tr -s '[:lower:]' '[:upper:]')
K8S_MINOR_VERSION=$( echo "$2" | cut -d . -f 1,2)

./bin/up.sh --generate --provider $PROVIDER --config $CI_PROJECT_DIR/cluster/$1-$2/config.yaml --verbose "-vvv"

build-scripts/update-generated-config.sh $CI_PROJECT_DIR/cluster/$1-$2/config.yaml krakenlib-$CI_PIPELINE_ID-$2 $K8S_MINOR_VERSION
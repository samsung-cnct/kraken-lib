#!/bin/sh

# to run locally
# export CI_PROJECT_DIR=$"<local_directory>"

PROVIDER=$( echo "$1" | tr -s '[:lower:]' '[:upper:]')

./bin/up.sh --generate --provider $PROVIDER --config $CI_PROJECT_DIR/cluster/$1/config.yaml --verbose "-vvv"

build-scripts/update-generated-config.sh $CI_PROJECT_DIR/cluster/$1/config.yaml krakenlib-$CI_PIPELINE_ID
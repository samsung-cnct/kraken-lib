#!/bin/bash

export DOCKER_HOST=tcp://192.168.10.10:2376
export DOCKER_CERT_PATH=$PWD/tls
export DOCKER_TLS_VERIFY=true

#!/usr/bin/env sh
# Disable Docker TLS for development and testing purposes
sudo tee /var/lib/boot2docker/profile <<EOF
DOCKER_TLS="no"
EXTRA_ARGS="--insecure-registry dockerrepo.nl.novamedia.com "
EOF
sudo /etc/init.d/docker restart
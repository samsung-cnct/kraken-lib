#!/usr/bin/env sh
# Regenerate docker certs so we can us it in our client
sudo /etc/init.d/docker restart
sudo cp -R /var/lib/boot2docker/tls /vagrant/
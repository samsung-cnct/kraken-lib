#!/usr/bin/env sh
# Regenerate docker certs so we can us it in our client
sudo rm -rf /vagrant/tls
sudo /etc/init.d/docker restart
sudo cp -R /var/lib/boot2docker/tls /vagrant/

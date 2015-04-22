#!/usr/bin/env sh
# Regenerate docker certs so we can us it in our client
# For some reason need to run it twice to allow external access. 
# TODO: figure out ^^ why
sudo rm -rf /vagrant/tls
sudo /usr/local/bin/generate_cert --host=boot2docker,127.0.0.1,10.0.2.15,192.168.10.10 --ca=/var/lib/boot2docker/tls/ca.pem --ca-key=/var/lib/boot2docker/tls/cakey.pem --cert=/var/lib/boot2docker/tls/server.pem --key=/var/lib/boot2docker/tls/serverkey.pem
sudo /etc/init.d/docker restart
sudo cp -R /var/lib/boot2docker/tls /vagrant/
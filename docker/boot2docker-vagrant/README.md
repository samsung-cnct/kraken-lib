#Boot2docker using Vagrant

##useage
To get a docker daemon running on your desktop using vagrant run the following commands.

```bash
cd <path that this README is located>
vagrant up
export DOCKER_HOST=tcp://192.168.10.10:2376
export DOCKERCERT_PATH=$PWD/tls
export DOCKER_TLS_VERIFY=true
```


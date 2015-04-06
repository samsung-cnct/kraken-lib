#Boot2docker using Vagrant

Getting a docker daemon running on your desktop using vagrant

```bash
cd <path that this README is located>
vagrant up
export DOCKER_HOST=tcp://192.168.10.10:2376
export DOCKERCERT_PATH=$PWD/tls
export DOCKER_TLS_VERIFY=true
```


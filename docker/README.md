#Boot2docker using Vagrant

##Useage
To get a docker daemon running on your machine:


###Step one
Run the following commands

```bash
cd <path that this README is located>
vagrant up
. export.sh
docker ps
```
You should see an empty list of docker containers with no errors

###External access to the Docker VM
If you are using Mac 10.9 or above, you can use pfctl to enable external access to locally running services. Run the followiing to enable access to Docker

```bash
echo "
rdr pass on lo0 inet proto tcp from any to any port 2375 -> 127.0.0.1 port 2375
" | sudo pfctl -f - > /dev/null 2>&1
```

###Step two
Start hacking away

###Step three
__Profit!!!__

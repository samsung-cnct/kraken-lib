#!/bin/bash

DEX_URI=https://auth.keyolk.cluster.io:30443
DEX_CLIENT_REDIRECT_URI=http://auth.keyolk.cluster.io:30080/callback
DEX_CLIENT_ID=example-app
DEX_AUTH_CONNECTOR=ldap
KUBE_CONFIG=~/.kraken/keyolk/admin.kubeconfig
KUBE_CLUSTER=keyolk
KUBE_NAMESPACE=cnct
KUBE_USER=keyolk

request=/auth
params="client_id=$DEX_CLIENT_ID"
params="$params redirect_uri=$DEX_CLIENT_REDIRECT_URI"
params="$params response_type=code"
params="$params scope=groups+openid+profile+email+offline_access"
params=($params)
params=`printf "%s&" "${params[@]}"`

echo -e "\nYour token request is :"
echo ${DEX_URI}${request}?${params}

api=`curl -skL ${DEX_URI}${request}?${params} \
  | grep req | grep -i $DEX_AUTH_CONNECTOR \
  | awk -F'=' -F'"' '{print $2}'`

echo -e "\nInput your login info."
read -p 'Username: ' username
read -sp 'Password: ' password

echo -e "\nYour token is : "
token=`curl -skL \
  --data "login=$username&password=$password" \
  ${DEX_URI}${api} \
  | grep "<p> Token:" \
  | awk -F'code>' '{print $2}' | cut -d '<' -f 1`

echo $token

echo -e "\nSet the token to given kubeConfig file : $KUBE_CONFIG"

kubectl --kubeconfig $KUBE_CONFIG config set-credentials $KUBE_USER --token=$token
kubectl --kubeconfig $KUBE_CONFIG config set-context $KUBE_USER --cluster=$KUBE_CLUSTER --namespace=$KUBE_NAMESPACE --user=$KUBE_USER
kubectl --kubeconfig $KUBE_CONFIG config use-context $KUBE_USER

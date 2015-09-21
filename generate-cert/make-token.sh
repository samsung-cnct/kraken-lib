#!/bin/bash 

set -o errexit
set -o nounset
set -o pipefail



function load-cert-vars() {
   CA_CERT_FILE=${SRV_BASE_DIR}/ca.crt
   if [ ! -e "${CA_CERT_FILE}" ]; then
        echo "CA Cert File Missing! ${CA_CERT_FILE}"
        CA_CERT_BASE64="INVALID"
   else
        CA_CERT_BASE64=$(cat "${SRV_BASE_DIR}/ca.crt" | base64 | tr -d '\r\n')
    fi
}
#
# create config files for kubelet and kube-proxy
#
function create-kubelet-auth() {
  local -r kubelet_kubeconfig_file="${SRV_BASE_DIR}/kubelet/kubeconfig"
  if [ ! -e "${kubelet_kubeconfig_file}" ]; then
    mkdir -p "${SRV_BASE_DIR}/kubelet"
    (umask 077;
      cat > "${kubelet_kubeconfig_file}" <<EOF
apiVersion: v1
kind: Config
users:
- name: kubelet
  user:
    token: ${KUBELET_TOKEN}
clusters:
- name: local
  cluster:
    certificate-authority-data: ${CA_CERT_BASE64}
contexts:
- context:
    cluster: local
    user: kubelet
  name: service-account-context
current-context: service-account-context
EOF
)
  fi
}

# This should happen both on cluster initialization and node upgrades.
#
#  - Uses the CA_CERT and KUBE_PROXY_TOKEN to generate a kubeconfig file for
#    the kube-proxy to securely connect to the apiserver.
function create--kubeproxy-auth() {
  local -r kube_proxy_kubeconfig_file="${SRV_BASE_DIR}/kube-proxy/kubeconfig"
  if [ ! -e "${kube_proxy_kubeconfig_file}" ]; then
    mkdir -p "${SRV_BASE_DIR}/kube-proxy"
    (umask 077;
        cat > "${kube_proxy_kubeconfig_file}" <<EOF
apiVersion: v1
kind: Config
users:
- name: kube-proxy
  user:
    token: ${KUBE_PROXY_TOKEN}
clusters:
- name: local
  cluster:
    certificate-authority-data: ${CA_CERT_BASE64}
contexts:
- context:
    cluster: local
    user: kube-proxy
  name: service-account-context
current-context: service-account-context
EOF
)
  fi
}

SRV_BASE_DIR=${SRV_BASE_DIR:-/srv/kubernetes}
TOKEN_FILE_NAME=${TOKEN_FILE_NAME:-known_tokens.csv}

known_tokens_file=${SRV_BASE_DIR}/${TOKEN_FILE_NAME}

if [[ ! -f "${known_tokens_file}" ]]; then
    echo "Token file does not exist...creating: ${known_tokens_file}"
    # generate apiserver and proxy tokens
    KUBELET_TOKEN=$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)
    KUBE_PROXY_TOKEN=$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)
    KUBE_USER_TOKEN=$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)
    SDSRA_USER_TOKEN=$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)
    (umask u=rw,go= ;
     echo "$KUBELET_TOKEN,kubelet,kubelet" > $known_tokens_file;
     echo "$KUBE_PROXY_TOKEN,kube_proxy,kube_proxy" >> $known_tokens_file;
     echo "$KUBE_USER_TOKEN,kube_user,kube_user" >> $known_tokens_file;
     echo "$SDSRA_USER_TOKEN,samsung_ag:user,samsung_ag:user" >> $known_tokens_file)
    
    # Generate tokens for other "service accounts".  Append to known_tokens.
    #
    # NB: If this list ever changes, this script actually has to
    # change to detect the existence of this file, kill any deleted
    # old tokens and add any new tokens (to handle the upgrade case).
    service_accounts=("system:scheduler" "system:controller_manager" "system:logging" "system:monitoring" "system:dns")
    for account in "${service_accounts[@]}"; do
        token=$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)
        echo "${token},${account},${account}" >> "${known_tokens_file}"
    done
else
    echo "Token file already exists...reusing: ${known_tokens_file}"
    KUBELET_TOKEN=$( grep kubelet ${known_tokens_file} | cut -d ',' -f1 )
    KUBE_PROXY_TOKEN=$( grep kube_proxy ${known_tokens_file}| cut -d ',' -f1 )
    KUBE_USER_TOKEN=$( grep kube_user ${known_tokens_file}| cut -d ',' -f1 )
    SDSRA_USER_TOKEN=$( grep "samsung_ag:user" ${known_tokens_file}| cut -d ',' -f1 )
fi

echo "=========== token file ============="
cat ${known_tokens_file}
echo "=========== token file end ========="
load-cert-vars
echo "KUBELET_TOKEN: ${KUBELET_TOKEN}"
create-kubelet-auth
echo "KUBE_PROXY_TOKEN: ${KUBE_PROXY_TOKEN}"
create--kubeproxy-auth
echo "=========== finished ==============="

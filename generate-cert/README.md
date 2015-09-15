
Genereates Minimum Kubernetes self-signed cert and 2 key pairs for the master.

Generate all needed system Tokens and create file for master.

Create kube-proxy and kublet config files for all nodes with the correnct cert, keys, and tokens

````
      usage: ./make-cert-tokens.sh {{master_public_ip}} {{location directory for generated data}}

       make-certs-tokens.sh
   
           make-ca-cert.sh  (copied and slightly modified from kubernetes/cluster/ubuntu dir) Uses a modified version (brendan) of easyrsa.

           make-token.sh   creates all system tokens into a file.  creates the correct kubeconfig for node kube-proxy and kubelet.


       Terraform setup stores data in this directory:
          aws-cluster-certs/
             ca.crt
             known_tokens.csv       - list of all known tokens (useful only on master)  All services use tokens.
             kube-proxy/kubeconfig  - for the nodes (not needed on the master)
             kubecfg.crt            - currently not used. can be used for kubecfg
             kubecfg.key
             kubelet/kubeconfig     - for the nodes ( not needed on the master)
             server.cert            - apiserver private key
             server.key             - apiserver public key (controller/manager also needs this).
   
          local-cluster-certs/
````

Whole directory needs to be place at /srv/kubernertes on the master.

The kube-proxy/kubeconfig kubelet/kubeconfig should also go on /srv/kuberentes on each node.  (this is a non-default location, but we specifiy the full path anyway, so not relying on any inconsistent default paths)



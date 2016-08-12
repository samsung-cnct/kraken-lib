# Calico

## Needs to be updated soon / TODO

* Right now these scripts pull calico binaries for calico and calico-ipam, this seems to be [going away](https://github.com/projectcalico/calico-containers/issues/1037) in favor of a container appraoch
* Move from downloading calicoctl to a container native approach

## Caveats

* Calico is going to create a manifest file on the master node to run as a static pod, this means that kubelet needs to read in /etc/kubernetes/manifests when it starts)
* Calico assumes that writing things to /opt/cni/bin is sufficient for CNI plugins, again this may be problematic for hyperkube containers (but OK if properly mapped)

## Assumptions in examples

* Assumes K8S API is SSL-enabled called api-endpoint.testcluster.io
* etcd is running on 127.0.0.1 at port 2379

## Native

### Shared Snippets

#### Environment Files

##### non-SSL etcd

In a non SSL setup, the requirements are easier:

```yaml
  - path: /etc/calico-setup.env
    owner: root
    permissions: 0755
    content: |
      ETCD_AUTHORITY=127.0.0.1:2379
```

##### SSL etcd

In an SSL setup we need to provide the certificates as well

```yaml
  - path: /etc/calico-setup.env
    owner: root
    permissions: 0755
    content: |
      ETCD_AUTHORITY=127.0.0.1:2379
      ETCD_SCHEME=https
      ETCD_CA_CERT_FILE=/etc/ssl/etcd/ca.pem
      ETCD_CERT_FILE=/etc/ssl/etcd/client.pem
      ETCD_KEY_FILE=/etc/ssl/etcd/client-key.pem
```

#### Units

```yaml
    - name: calico-node.service
      runtime: true
      command: start
      content: |
        [Unit]
        Description=calicoctl node
        After=docker.service
        Requires=docker.service
        
        [Service]
        User=root
        EnvironmentFile=/etc/calico-setup.env
        EnvironmentFile=/etc/networking.env
        PermissionsStartOnly=true
        ExecStartPre=/usr/bin/wget -N -P /opt/bin http://www.projectcalico.org/builds/calicoctl
        ExecStartPre=/usr/bin/chmod +x /opt/bin/calicoctl
        ExecStartPre=/usr/bin/wget -N -P /opt/cni/bin https://github.com/projectcalico/calico-cni/releases/download/v1.3.1/calico 
        ExecStartPre=/usr/bin/chmod +x /opt/cni/bin/calico
        ExecStartPre=/usr/bin/wget -N -P /opt/cni/bin https://github.com/projectcalico/calico-cni/releases/download/v1.3.1/calico-ipam 
        ExecStartPre=/usr/bin/chmod +x /opt/cni/bin/calico-ipam
        ExecStart=/opt/bin/calicoctl node --ip=${DEFAULT_IPV4} --detach=false
        Restart=always
        RestartSec=10
        [Install]
        WantedBy=multi-user.target
```

### Nodes

#### Within write_files:

In addition to the calico-setup.env (appropriate for SSL/non-SSL etcd) we need the following

```yaml
  - path: /etc/cni/net.d/10-calico.conf 
    owner: root
    permissions: 0755
    content: |
      {
          "name": "calico-k8s-network",
          "type": "calico",
          "etcd_authority": "127.0.0.1:2379",
          "log_level": "info",
          "ipam": {
              "type": "calico-ipam"
          },
          "policy": {
              "type": "k8s",
              "k8s_api_root": "https://api-endpoint.testcluster.io:8080/api/v1/"
          }
      }
```

### API Master

#### Within write_files:

##### Within write_files:

In addition to the calico-setup.env (appropriate for SSL/non-SSL etcd) we need the following

```yaml
  - path: /etc/kubernetes/manifests/policy-controller.manifest
    owner: root
    permissions: 0755
    content: |
      apiVersion: v1
      kind: Pod 
      metadata:
        name: policy-controller
        namespace: kube-system 
        labels:
          version: "latest"
          projectcalico.org/app: "policy-controller"
      spec:
        hostNetwork: true
        containers:
          # The Calico policy controller.
          - name: policy-controller 
            image: calico/kube-policy-controller:v0.2.0
            env:
              - name: ETCD_ENDPOINTS
                value: "http://127.0.0.1:2379"
              - name: K8S_API
                value: "http://127.0.0.1:8080"
              - name: LEADER_ELECTION 
                value: "false"
```





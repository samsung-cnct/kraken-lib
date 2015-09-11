#cloud-config

---
coreos:
  etcd2:
    proxy: on
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    advertise-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    initial-cluster: etcd=http://${etcd_private_ip}:2380
  fleet:
    etcd-servers: http://$private_ipv4:4001
    public-ip: $public_ipv4
    metadata: "role=apiserver"
  flannel:
    etcd-endpoints: http://${etcd_private_ip}:4001
    interface: $private_ipv4
  units:
    - name: docker-tcp.socket
      command: start
      enable: true
      content: |
        [Unit]
        Description=Docker TCP Socket for the API

        [Socket]
        ListenStream=0.0.0.0:4243
        BindIPv6Only=both
        Service=docker.service

        [Install]
        WantedBy=sockets.target
    - name: etcd2.service
      command: start
    - name: setup-network-environment.service
      command: start
      content: |
        [Unit]
        Description=Setup Network Environment
        Requires=network-online.target
        After=network-online.target
        Before=flanneld.service

        [Service]
        ExecStartPre=-/usr/bin/mkdir -p /opt/bin
        ExecStartPre=/usr/bin/wget -N -P /opt/bin https://github.com/kelseyhightower/setup-network-environment/releases/download/v1.0.0/setup-network-environment
        ExecStartPre=/usr/bin/chmod +x /opt/bin/setup-network-environment
        ExecStart=/opt/bin/setup-network-environment
        RemainAfterExit=yes
        Type=oneshot
    - name: flanneld.service
      command: start
      drop-ins:
        - name: 50-network-config.conf
          content: |
            [Unit]
            After=flannelconfig.service
            Before=docker.service

            [Service]
            ExecStartPre=-/usr/bin/etcdctl set /coreos.com/network/config '{"Network":"10.244.0.0/14", "Backend": {"Type": "vxlan"}}' 
    - name: fleet.service
      command: start
    - name: systemd-journal-gatewayd.socket
      command: start
      enable: yes
      content: |
        [Unit] 
        Description=Journal Gateway Service Socket
        [Socket] 
        ListenStream=/var/run/journald.sock
        Service=systemd-journal-gatewayd.service
        [Install] 
        WantedBy=sockets.target
  update:
    group: ${coreos_update_channel}
    reboot-strategy: ${coreos_reboot_strategy}

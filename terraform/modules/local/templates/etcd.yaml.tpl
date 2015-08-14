#cloud-config

---
coreos:
  etcd2:
    name: etcd
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    initial-cluster: etcd=http://$private_ipv4:2380
    initial-advertise-peer-urls: http://$private_ipv4:2380
    listen-peer-urls: http://$private_ipv4:2380,http://$private_ipv4:7001
    advertise-client-urls: http://$private_ipv4:2379,http://$private_ipv4:4001
    initial-cluster-state: new
  fleet:
    etcd-servers: http://0.0.0.0:4001
    public-ip: $private_ipv4
    metadata: "role=etcd"
  units:
    - name: fleet.service
      command: start
    - name: etcd2.service
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
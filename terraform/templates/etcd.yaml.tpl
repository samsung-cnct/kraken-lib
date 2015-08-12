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
    - name: format-ebs.service
      command: start
      content: |
        [Unit]
        Description=Formats the EBS drive
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/usr/sbin/wipefs -f ${format_docker_storage_mnt}
        ExecStart=/usr/sbin/mkfs.ext4 -F ${format_docker_storage_mnt}
    - name: var-lib-docker.mount
      command: start
      content: |
        [Unit]
        Description=Mount EBS to /var/lib/docker
        Requires=format-ebs.service
        After=format-ebs.service
        Before=docker.service
        [Mount]
        What=${format_docker_storage_mnt}
        Where=/var/lib/docker
        Type=ext4
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
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
    - name: format-storage.service
      command: start
      content: |
        [Unit]
        Description=Formats a drive
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/usr/sbin/wipefs -f ${format_docker_storage_mnt}
        ExecStart=/usr/sbin/mkfs.ext4 -F ${format_docker_storage_mnt}
    - name: var-lib-etcd2.mount
      command: start
      content: |
        [Unit]
        Description=Mount to /var/lib/etcd2
        Requires=format-storage.service
        After=format-storage.service
        Before=etcd2.service
        [Mount]
        What=${format_docker_storage_mnt}
        Where=/var/lib/etcd2
        Type=ext4
    - name: set-etcd2-permissions.service
      command: start
      content: |
        [Unit]
        Before=etcd2.service
        [Service]
        ExecStart=/usr/bin/chown -R etcd:etcd /var/lib/etcd2
    - name: gen-etcd2-envfile.service
      command: start
      content: |
        [Unit]
        Description=generate env file for etcd2.service
        Before=etcd2.service

        [Service]
        ExecStartPre=/usr/bin/bash -c 'mkdir -p /opt/bin'
        ExecStart=/usr/bin/bash -c 'echo "GOMAXPROCS=$(nproc)" > /opt/bin/etcd2.env'
        RemainAfterExit=true
        Type=oneshot
    - name: fleet.service
      command: start
    - name: etcd2.service
      command: start
      drop-ins:
        - name: 30-gomaxprocs.conf
          content: |
            [Unit]
            Requires=gen-etcd2-envfile.service
            [Service]
            EnvironmentFile=/opt/bin/etcd2.env
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

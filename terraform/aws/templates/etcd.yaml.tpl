#cloud-config

---
write_files:
  - path: /etc/inventory.ansible
    content: |
      [etcd]
      etcd ansible_ssh_host=$private_ipv4

      [etcd:vars]
      ansible_connection=ssh
      ansible_python_interpreter="PATH=/home/core/bin:$PATH python"
      ansible_ssh_user=core
      ansible_ssh_private_key_file=/opt/ansible/private_key
      kubernetes_binaries_uri=${kubernetes_binaries_uri}
      logentries_token=${logentries_token}
      logentries_url=${logentries_url}
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
    - name: docker.service
      drop-ins:
        - name: 50-docker-opts.conf
          content: |
            [Service]
            Environment="DOCKER_OPTS=--log-level=warn"
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
    - name: generate-ansible-keys.service
      command: start
      content: |
        [Unit]
        Description=Generates SSH keys for ansible container
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStartPre=-/usr/bin/rm /home/core/.ssh/ansible_rsa*
        ExecStart=/usr/bin/bash -c "ssh-keygen -f /home/core/.ssh/ansible_rsa -N ''"
        ExecStart=/usr/bin/bash -c "cat /home/core/.ssh/ansible_rsa.pub >> /home/core/.ssh/authorized_keys"
    - name: kraken-git-pull.service
      command: start
      content: |
        [Unit]
        Requires=generate-ansible-keys.service
        After=generate-ansible-keys.service
        Description=Fetches kraken repo
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/usr/bin/rm -rf /opt/kraken
        ExecStart=/usr/bin/git clone -b ${kraken_branch} ${kraken_repo} /opt/kraken
    - name: write-sha-file.service
      command: start
      content: |
        [Unit]
        Requires=kraken-git-pull.service
        After=kraken-git-pull.service
        Description=writes optional sha to a file
        [Service]
        Type=oneshot
        ExecStart=/usr/bin/bash -c '/usr/bin/echo "${kraken_commit}" > /opt/kraken/commit.sha'
    - name: fetch-kraken-commit.service
      command: start
      content: |
        [Unit]
        Requires=write-sha-file.service
        After=write-sha-file.service
        Description=fetches an optional commit
        ConditionFileNotEmpty=/opt/kraken/commit.sha
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        WorkingDirectory=/opt/kraken
        ExecStart=/usr/bin/git fetch ${kraken_repo} +refs/pull/*:refs/remotes/origin/pr/*
        ExecStart=/usr/bin/git checkout -f ${kraken_commit}
    - name: ansible-in-docker.service
      command: start
      content: |
        [Unit]
        Requires=write-sha-file.service
        After=fetch-kraken-commit.service
        Description=Runs a prebaked ansible container
        [Service]
        Type=simple
        Restart=on-failure
        RestartSec=5
        ExecStartPre=-/usr/bin/docker rm -f ansible-docker
        ExecStart=/usr/bin/docker run --name ansible-docker -v /etc/inventory.ansible:/etc/inventory.ansible -v /opt/kraken:/opt/kraken -v /home/core/.ssh/ansible_rsa:/opt/ansible/private_key -v /var/run:/ansible -e ANSIBLE_HOST_KEY_CHECKING=False ${ansible_docker_image} /sbin/my_init --skip-startup-files --skip-runit -- ${ansible_playbook_command} ${ansible_playbook_file}
  update:
    group: ${coreos_update_channel}
    reboot-strategy: ${coreos_reboot_strategy}

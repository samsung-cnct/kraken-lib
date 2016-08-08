# Networking Setup

To determine the networking environment we run Kelsey Hightower's script

# TODO

* Convert to container

# Unit File
```yaml
[Unit]
Description=Setup Network Environment
Documentation=https://github.com/kelseyhightower/setup-network-environment
Requires=network-online.target
After=network-online.target

[Service]
ExecStartPre=-/usr/bin/mkdir -p /opt/bin
ExecStartPre=/usr/bin/wget -N -P /opt/bin https://github.com/kelseyhightower/setup-network-environment/releases/download/v1.0.0/setup-network-environment

ExecStartPre=/usr/bin/chmod +x /opt/bin/setup-network-environment
ExecStart=/opt/bin/setup-network-environment
RemainAfterExit=yes
Type=oneshot
```
#!/bin/bash
set -e

PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "================================="
echo "=== Setting up the HashiStack ==="
echo "================================="

echo "=============="
echo "=== Docker ==="
echo "=============="

echo "=== Getting Docker ==="

sleep 30
sudo apt-get -yqq update
sudo apt-get -yqq install apt-transport-https ca-certificates curl gnupg-agent software-properties-common unzip
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -yqq update
sudo apt-get -yqq install docker-ce

echo "=============="
echo "=== Consul ==="
echo "=============="

echo "=== Fetching Consul ==="
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip

echo "=== Installing Consul ==="
unzip consul.zip >/dev/null
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul


echo "=== Setting up Consul ==="
sudo mkdir -p /mnt/consul
sudo mkdir -p /etc/consul.d

sudo tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "datacenter": "${datacenter}",
  "log_level": "INFO",
  "server": true,
  "ui": true,
  "data_dir": "/mnt/consul",
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": "$PRIVATE_IP",
  "bootstrap_expect": ${min_servers},
  "service": {
    "name": "consul"
  }
}
EOF

sudo tee /etc/systemd/system/consul.service > /dev/null <<"EOF"
[Unit]
Description=Consul Agent
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
Environment=CONSUL_ALLOW_PRIVILEGED_PORTS=true
ExecStart=/usr/local/bin/consul agent -config-dir="/etc/consul.d"
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

echo "============="
echo "=== Nomad ==="
echo "============="

echo "=== Fetching Nomad ==="
cd /tmp
curl -sLo nomad.zip https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip

echo "=== Installing Nomad ==="
unzip nomad.zip >/dev/null
sudo chmod +x nomad
sudo mv nomad /usr/local/bin/nomad

echo "=== Setting up Nomad ==="

sudo mkdir -p /mnt/nomad
sudo mkdir -p /etc/nomad.d

sudo tee /etc/nomad.d/config.hcl > /dev/null <<EOF
datacenter = "${datacenter}"
region     = "${region}"
data_dir   = "/mnt/nomad"

bind_addr = "0.0.0.0"

server {
  enabled = true,
  bootstrap_expect = ${min_servers}
}

client {
  enabled = true
  options = {
    "driver.raw_exec.enable" = "1"
  }
}

consul {
  address = "127.0.0.1:8500"
}
EOF

sudo tee /etc/systemd/system/nomad.service > /dev/null <<"EOF"
[Unit]
Description=Nomad Agent
Documentation=https://nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

Wants=consul.service
After=consul.service

[Service]
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=infinity
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
StartLimitIntervalSec=10
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

echo "=== Starting Consul and Nomad ==="
sudo systemctl daemon-reload
sudo systemctl enable nomad.service
sudo systemctl enable consul.service

sudo systemctl start nomad.service
sudo systemctl start consul.service

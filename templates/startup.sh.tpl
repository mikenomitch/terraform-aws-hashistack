#!/bin/bash
set -e

echo "================================="
echo "=== Setting up the HashiStack ==="
echo "================================="

echo "=== Confirming variable interpolation ==="
touch ${to_touch}
echo ${to_echo} > ${to_touch}
echo ${nomad_version} > ${to_touch}

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

# TO CONFIRM:
echo "=== Fetching Consul ==="
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip

# TO CONFIRM:
echo "=== Installing Consul ==="
unzip consul.zip >/dev/null
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul

# TODO:
echo "=== Setting up Consul ==="
echo "TODO"

echo "=== Starting Consul ==="
echo "TODO"

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
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

sudo mkdir -p /mnt/nomad
sudo mkdir -p /etc/nomad.d
# TODO: Extract into a template file
sudo tee /etc/nomad.d/config.hcl > /dev/null <<EOF
Bytes
datacenter = "${datacenter}"
region     = "${region}"
data_dir   = "/mnt/nomad"

bind_addr = "0.0.0.0"

advertise {
  # Defaults to the node's hostname. If the hostname resolves to a loopback
  # address you must manually configure advertise addresses.
  http = "$PRIVATE_IP"
  rpc  = "$PRIVATE_IP"
  serf = "$PRIVATE_IP"
}
server {
    enabled = true
    bootstrap_expect = ${min_servers}
}
EOF

# TODO: Extract into a template file
sudo tee /etc/systemd/system/nomad.service > /dev/null <<"EOF"
[Unit]
Description = "Nomad"

[Service]
# Stop consul will not mark node as failed but left
KillSignal=INT
ExecStart=/usr/local/bin/nomad agent -config="/etc/nomad.d"
Restart=always
ExecStopPost=sleep 5
EOF

echo "=== Starting Nomad ==="
sudo systemctl daemon-reload
sudo systemctl enable nomad.service
sudo systemctl start nomad.service

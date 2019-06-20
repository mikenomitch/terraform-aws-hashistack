PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

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

if [ $${is_server} ]; then
  echo "=== Setting up Consul as Server ==="

  sudo tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "datacenter": "${datacenter}",
  "log_level": "INFO",
  "server": true,
  "ui": true,
  "data_dir": "/mnt/consul",
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": "$PRIVATE_IP:8500",
  "bootstrap_expect": ${min_servers},
  "retry_join": ["provider=${retry_provider} tag_key=${retry_tag_key} tag_value=${retry_tag_value} region=${region}"]
  "service": {
    "name": "consul"
  }
}
EOF
else
  echo "=== Setting up Consul as Client ==="

  sudo tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "datacenter": "${datacenter}",
  "log_level": "INFO",
  "ui": true,
  "data_dir": "/mnt/consul",
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "advertise_addr": "$PRIVATE_IP:8500",
  "retry_join": ["provider=${retry_provider} tag_key=${retry_tag_key} tag_value=${retry_tag_value} region=${region}"]
}
EOF
fi

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

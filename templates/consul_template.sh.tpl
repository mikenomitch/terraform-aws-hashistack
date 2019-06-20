echo "=== Fetching Consul Template ==="

echo "=== Setting up Consul Template ==="
sudo mkdir -p /mnt/consul-template
sudo mkdir -p /etc/consul-template.d

sudo tee /etc/consul-template.d/consul-template.hcl > /dev/null <<EOF
syslog {
  enabled = true
  facility = "LOCAL5"
}
EOF

sudo tee /etc/systemd/system/consul-template.service > /dev/null <<"EOF"
[Unit]
Description=Consul Template Agent
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/consul-template -config="/etc/consul-template.d/consul-template.hcl"
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

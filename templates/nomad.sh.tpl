PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "=== Fetching Nomad ==="
cd /tmp
curl -sLo nomad.zip https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip

echo "=== Installing Nomad ==="
unzip nomad.zip >/dev/null
sudo chmod +x nomad
sudo mv nomad /usr/local/bin/nomad

sudo mkdir -p /mnt/nomad
sudo mkdir -p /etc/nomad.d

if [ ${is_server} == true ] || [ ${is_server} == 1 ]; then
  echo "=== Setting up Nomad as Server ==="

  sudo tee /etc/nomad.d/config.hcl > /dev/null <<EOF
datacenter = "${datacenter}"
region     = "${region}"
data_dir   = "/mnt/nomad"

bind_addr = "0.0.0.0"

server {
  enabled = true,
  bootstrap_expect = ${min_servers}
}

server_join {
  retry_join = ["provider=${retry_provider} tag_key=${retry_tag_key} tag_value=${retry_tag_value}"]
}

consul {
  address = "$PRIVATE_IP:8500"
  auto_advertise = true

  server_service_name = "nomad"
  server_auto_join    = true

  client_service_name = "nomad-client"
  client_auto_join    = true
}
EOF
else
  echo "=== Setting up Nomad as Client ==="

  sudo tee /etc/nomad.d/config.hcl > /dev/null <<EOF
datacenter = "${datacenter}"
region     = "${region}"
data_dir   = "/mnt/nomad"

bind_addr = "0.0.0.0"

client {
  enabled = true

  options = {
    "driver.raw_exec.enable" = "1"
  }
}

server_join {
  retry_join = ["provider=${retry_provider} tag_key=${retry_tag_key} tag_value=${retry_tag_value}"]
}

consul {
  address = "$PRIVATE_IP:8500"
}
EOF
fi

sudo tee /etc/systemd/system/nomad.service > /dev/null <<"EOF"
${nomad_service_config}
EOF

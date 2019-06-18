#!/bin/bash
set -e

PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "================================="
echo "=== Setting up the HashiStack ==="
echo "================================="

echo "=============="
echo "=== Docker ==="
echo "=============="

${docker_config}

echo "=============="
echo "=== Consul ==="
echo "=============="

${consul_config}

echo "============="
echo "=== Nomad ==="
echo "============="

${nomad_config}

echo "======================="
echo "=== Consul Template ==="
echo "======================="

${consul_template_config}

echo "=== Starting Consul and Nomad ==="

sudo systemctl daemon-reload
sudo systemctl enable nomad.service
sudo systemctl enable consul.service
sudo systemctl enable consul-template.service

sudo systemctl start nomad.service
sudo systemctl start consul.service
sudo systemctl start consul-template.service

#!/usr/bin/env bash
set -ex pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# make..."
sudo apt-get install -y \
        make

echo "# Install Nomad..." 
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update
sudo apt-get install nomad -y
sudo curl -o /etc/nomad.d/nomad.hcl https://raw.githubusercontent.com/scotty-c/lxc-builds/main/sources/conf/nomad.hcl
sudo curl -o /etc/systemd/system/nomad.service https://raw.githubusercontent.com/scotty-c/lxc-builds/main/sources/conf/nomad
sudo systemctl enable nomad.service

echo "# Install Consul..."
sudo apt install consul -y
sudo curl -o /etc/consul.d/consul.hcl https://raw.githubusercontent.com/scotty-c/lxc-builds/main/sources/conf/consul.hcl
sudo curl -o /etc/systemd/system/consul.service https://raw.githubusercontent.com/scotty-c/lxc-builds/main/sources/conf/consul
sudo chown chown -R consul:consul /opt/consul
systemctl enable consul.service

echo "# complete!"

#!/usr/bin/env bash
set -ex pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# make..."
sudo apt update 
sudo apt install -y \
         make \
         uidmap
        
echo "# path..."
sudo tee -a /etc/profile.d/nerdctl.sh <<'EOF'
export PATH="$PATH:/usr/local/nerdctl/bin"
EOF
sudo chmod a+x /etc/profile.d/nerdctl.sh

echo "# nerdctl..."
curl -OL https://github.com/containerd/nerdctl/releases/download/v0.11.1/nerdctl-full-0.11.1-linux-amd64.tar.gz
sudo mkdir -p /usr/local/nerdctl
sudo tar -C /usr/local/nerdctl -xzf nerdctl-full-0.11.1-linux-amd64.tar.gz
sudo mkdir -p /opt/cni/bin/
sudo ln -s /usr/local/nerdctl/libexec/cni/* /opt/cni/bin/

echo "# rootless ..."
sudo chown ubuntu:ubuntu /usr/local/nerdctl/bin/containerd-rootless-setuptool.sh
sudo su ubuntu /bin/bash -l '/usr/local/nerdctl/bin/containerd-rootless-setuptool.sh install'
sudo su ubuntu /bin/bash -l '/usr/local/nerdctl/bin/containerd-rootless-setuptool.sh install-buildkit'
sudo su ubuntu /bin/bash -l '/usr/local/nerdctl/bin/containerd-rootless-setuptool.sh install-stargz'

echo "# complete!"
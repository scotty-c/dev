#!/usr/bin/env bash
set -ex pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# make..."
sudo apt-get install -y \
        make

echo "# nerdctl..."
curl -OL https://github.com/containerd/nerdctl/releases/download/v0.11.1/nerdctl-full-0.11.1-linux-arm64.tar.gz
sudo tar -xzf nerdctl-full-0.11.1-linux-arm64.tar.gz


echo "# complete!"
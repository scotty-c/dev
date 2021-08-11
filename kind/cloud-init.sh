#!/usr/bin/env bash
set -ex pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# make..."
sudo apt-get install -y \
        make

echo "# kubectl..."
sudo snap install kubectl --classic --channel=1.21

tee -a ~/.bash_aliases <<'EOF'
source <(kubectl completion bash)
source <(kind completion bash)

EOF
source ~/.bash_aliases

echo "# golang..."
VERSION='1.15.11'
OS='linux'
ARCH='amd64'

curl -OL https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz
sudo tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
rm go$VERSION.$OS-$ARCH.tar.gz

echo "# kind..."
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
sudo chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

echo "# complete!"
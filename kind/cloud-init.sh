#!/usr/bin/env bash
set -ex pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# make..."
sudo apt-get install -y \
        make

echo "# microk8s..."
sudo snap install microk8s --classic --channel=1.19
mkdir -p $HOME/.kube/
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
sudo microk8s config > $HOME/.kube/config

tee -a ~/.bash_aliases <<'EOF'
function kubectl {
        sudo microk8s kubectl "$@"
}
PATH="$PATH:/usr/local/go/bin:'$HOME'/go/bin"

source <(kubectl completion bash)
source <(kind completion bash)

EOF
source ~/.bash_aliases

echo "# lazygit..."
sudo add-apt-repository --yes ppa:lazygit-team/release
sudo apt-get update
sudo apt-get install -y lazygit

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
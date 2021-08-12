#!/usr/bin/env bash
set -ex pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# make..."
sudo apt-get install -y \
        make

echo "# bash_aliases..."
tee -a ~/.bash_aliases <<'EOF'
function kubectl {
        sudo microk8s kubectl "$@"
}

source <(kubectl completion bash)

EOF
source ~/.bash_aliases

echo "# microk8s..."
sudo snap install microk8s --classic --channel=1.22
mkdir -p $HOME/.kube/
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
sudo microk8s config > $HOME/.kube/config

microk8s enable dns       

microk8s enable kata

echo "# complete!"
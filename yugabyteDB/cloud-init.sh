#!/usr/bin/env bash
set -ex pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# make..."
sudo apt-get install -y \
        make

echo "# microk8s..."
sudo snap install microk8s --classic --channel=1.22
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

EOF
source ~/.bash_aliases

echo "# lazygit..."
sudo add-apt-repository --yes ppa:lazygit-team/release
sudo apt-get update
sudo apt-get install -y lazygit

echo "# golang..."
kubectl create -f https://raw.githubusercontent.com/yugabyte/yugabyte-operator/master/deploy/crds/yugabyte.com_ybclusters_crd.yaml
kubectl create -f https://raw.githubusercontent.com/yugabyte/yugabyte-operator/master/deploy/operator.yaml
curl  https://raw.githubusercontent.com/yugabyte/yugabyte-operator/master/deploy/crds/yugabyte.com_v1alpha1_ybcluster_full_cr.yaml | sed 's/tag: .*$/tag: latest/g' | kubectl  create -f -

echo "# complete!"
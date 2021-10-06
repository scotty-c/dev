#!/usr/bin/env bash
set -ex pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# make..."
sudo apt-get install -y \
        make \
        gcc

tee -a ~/.bash_aliases <<'EOF'
PATH="$PATH:/usr/local/go/bin:'$HOME'/go/bin"
EOF
source ~/.bash_aliases

echo "# golang..."
VERSION='1.15.11'
OS='linux'
ARCH='amd64'

curl -OL https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz
sudo tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
rm go$VERSION.$OS-$ARCH.tar.gz
mkdir $HOME/go
sudo chown -f -R $USER $HOME/go

echo "# dlx..."
git clone https://github.com/bketelsen/dlx.git
chown -R ubuntu:ubuntu dlx
cd dlx/bin
./lxd.sh
./distrobuilder.sh
./debootstrap.sh
./subuid.sh
cd .. && make install
echo 'source <(dlx completion bash)' >>~/.bash_aliases


echo "# complete!"
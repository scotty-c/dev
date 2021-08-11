#!/usr/bin/env bash
set -ex pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# make..."
sudo apt-get install -y \
        make
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

echo "# complete!"
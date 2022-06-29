#!/usr/bin/env bash
set -ex pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# build tools..."
sudo apt-get install -y \
        build-essential 


echo "# rust..."
su ubuntu -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
sudo chown -R ubuntu:ubuntu /home/ubuntu/.cargo/
rustup target add wasm32-wasi

echo "# spin..."
wget https://github.com/fermyon/spin/releases/download/v0.3.0/spin-v0.3.0-linux-amd64.tar.gz
tar -xzf spin-v0.3.0-linux-amd64.tar.gz
sudo mv spin /usr/local/bin/spin


echo "# Install Nomad..." 
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update
sudo apt-get install nomad -y
sudo rm /etc/nomad.d/nomad.hcl
sudo tee -a /etc/nomad.d/nomad.hcl <<'EOF'
datacenter = "dc1" 
data_dir = "/opt/nomad"  
bind_addr  = "0.0.0.0"

server { 
  enabled = true 
  bootstrap_expect = 1 
}
consul {
  server_service_name = "nomad"
  server_auto_join    = true
  client_service_name = "nomad-client"
  client_auto_join    = true
  auto_advertise      = true
}
client {
  enabled = true
  servers = ["127.0.0.1:4646"]
}  
plugin "raw_exec" {
    config {
      enabled = true
     }
}
EOF

sudo tee -a /etc/systemd/system/nomad.service <<'EOF'
[Unit]
Description="HashiCorp Nomad"
Documentation=https://nomadproject.io/docs/
Wants=network-online.target
After=network-online.target
StartLimitIntervalSec=10

[Service]
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/bin/nomad agent -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=infinity
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload  
sudo systemctl enable nomad.service
sudo systemctl start nomad.service

echo "# Install Consul..."
sudo apt install consul -y
sudo tee -a /etc/consul.d/consul.hcl <<'EOF'
datacenter  = "dc1"
data_dir    = "/opt/consul"
client_addr = "0.0.0.0"
ui          = true
server      = true

bootstrap_expect = 1
EOF

sudo tee -a /etc/systemd/system/consul.service <<'EOF'
[Unit]
Description="HashiCorp Consul"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
ExecStart=/usr/bin/consul agent -bind 127.0.0.1 -config-dir=/etc/consul.d/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
sudo chown -R consul:consul /opt/consul
sudo systemctl daemon-reload  
sudo systemctl enable consul.service
sudo systemctl start consul.service

echo "#env..."
tee -a /home/ubuntu/.bashrc <<'EOF'
export CONSUL_HTTP_ADDR=http://localhost:8500
export NOMAD_ADDR=http://localhost:4646
export BINDLE_URL=http://bindle.local.fermyon.link/v1
export HIPPO_URL=http://hippo.local.fermyon.link
EOF

echo "installer..."
git clone https://github.com/fermyon/installer.git
nomad run installer/local/job/traefik.nomad
nomad run -var="os=linux" -var="arch=amd64" installer/local/job/bindle.nomad
nomad run -var="os=linux" installer/local/job/hippo.nomad

echo "# complete!"

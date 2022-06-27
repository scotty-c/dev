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
sudo tee -a /etc/nomad.d/nomad.hcl <<'EOF'
datacenter = "dc1" 
data_dir = "/opt/nomad"  
bind_addr  = "0.0.0.0"

server { 
  enabled = true 
  bootstrap_expect = 1 
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

sudo systemctl enable nomad.service
sudo systemctl start nomad.service

echo "# Install Consul..."
sudo apt install consul -y
sudo tee -a /etc/consul.d/consul.hcl <<'EOF'
datacenter  = "wopr1"
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
Type=notify
User=consul
Group=consul
ExecStart=/usr/bin/consul agent -dev -bind 127.0.0.1 -config-dir=/etc/consul.d/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
sudo chown chown -R consul:consul /opt/consul
systemctl enable consul.service
systemctl start consul.service

echo "# complete!"

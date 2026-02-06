#!/bin/bash
sudo apt update
sudo apt install -y tiny-dfr

sudo tee /etc/systemd/system/tiny-dfr.service <<EOF
[Unit]
Description=Tiny Apple T2 Touch Bar daemon
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/tiny-dfr
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable tiny-dfr
sudo systemctl start tiny-dfr


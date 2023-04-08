[Unit]
Description=Mastodon running under docker-compose
Requires=docker.service
After=docker.service

[Service]
Type=exec
RemainAfterExit=yes
WorkingDirectory=/
ExecStart=/root/bin/setup
ExecStop=killall -v setup
TimeoutStartSec=0
User=root
Restart=no

[Install]
WantedBy=multi-user.target

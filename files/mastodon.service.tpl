[Unit]
Description=Mastodon running under docker-compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/mnt/mastodon/mastodon
ExecStart=/usr/bin/docker-compose --file docker-compose-alt.yml up --detach --remove-orphans
ExecStop=/usr/bin/docker-compose --file docker-compose-alt.yml down
TimeoutStartSec=0
User=ubuntu
Group=ubuntu

[Install]
WantedBy=multi-user.target

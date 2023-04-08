#cloud-config

fs_setup:
  - filesystem: ext4
    device: ${block_device}
    label: mastodon
    partition: auto

mounts:
  - [ "${block_device}", "/mnt/mastodon", "ext4", "defaults,noatime,_netdev,nofail", "0", "0" ]

ssh_authorized_keys:
  - ${ssh_pubkey}

package_update: true
package_upgrade: true
packages:
  - certbot
  - cron
  - curl
  - dnsutils
  - docker-compose
  - docker.io
  - git
  - jq
  - net-tools
  - nginx
  - python3-certbot-nginx
  - sysstat
  - unattended-upgrades
  - unzip
  - vim
  - wget

write_files:
  - path: /root/ubuntu/.env.production
    permissions: 0o640
    owner: root:root
    encoding: gzip+base64
    content: ${dot_file_contents_gz_b64}
  - path: /root/ubuntu/docker-compose-alt.yml
    owner: root:root
    permissions: 0o644
    encoding: gzip+base64
    content: ${docker_compose_contents_gz_b64}
  - path: /etc/systemd/system/mastodon.service
    permissions: 0o644
    owner: root:root
    encoding: gzip+base64
    content: ${systemd_unit_contents_gz_b64}
  - path: /root/bin/setup
    owner: root:root
    permissions: 0o750
    encoding: gzip+base64
    content: ${setup_contents_gz_b64}
  - path: /etc/rc.local
    owner: root:root
    permissions: 0o755
    content: |
      #!/bin/sh -e
      /root/bin/setup
      exit 0
  - path: /root/ubuntu/admin_runner.rb
    owner: root:root
    permissions: 0o777
    encoding: gzip+base64
    content: ${admin_runner_contents_gz_b64}
  - path: /root/ssl/private.pem
    owner: root:root
    permissions: 0o640
    encoding: gzip+base64
    content: ${ssl_private_contents_gz_b64}
  - path: /root/ssl/cert.pem
    owner: root:root
    permissions: 0o640
    encoding: gzip+base64
    content: ${ssl_cert_contents_gz_b64}
  - path: /root/nginx.conf
    owner: root:root
    permissions: 0o644
    encoding: gzip+base64
    content: ${nginx_conf_contents_gz_b64}
  - path: /root/bin/certbot_setup
    owner: root:root
    permissions: 0o750
    encoding: gzip+base64
    content: ${certbot_setup_contents_gz_b64}

runcmd:
  - [ systemctl, enable, rc-local ]

power_state:
  mode: reboot
  timeout: 30
  delay: "+1"
  message: Rebooting in one minute...

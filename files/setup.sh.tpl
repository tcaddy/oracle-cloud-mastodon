#!/usr/bin/env bash

echo "hello from setup script at $(date)" > /root/hi.txt
echo "begin running setup script..."

until findmnt /mnt/mastodon > /dev/null; do
  echo "mastodon is not mounted. attempting to mount /mnt/mastodon ..."
  result=$((mount /mnt/mastodon) 2>&1)
  if findmnt /mnt/mastodon > /dev/null; then
    echo "/mnt/mastodon is mounted OK"
  else
    echo "mastodon is still not mounted"
    if [[ $result =~ "wrong fs type, bad option, bad superblock" ]]; then
      echo "cloud-init didn't setup the filesystem for us so we're doing it manually..."
      mkfs.ext4 /dev/oracleoci/oraclevdb
    else
      echo " sleep for 30 seconds..."
      sleep 30
    fi
  fi
done

echo "Add ubuntu user to docker group..."
usermod -a -G docker ubuntu

echo "Remove any folders/files at /mnt/mastodon/mastodon"
rm -Rfv /mnt/mastodon/mastodon

echo "Clone mastodon git repo..."
git clone --branch "${mastodon_version}" --single-branch https://github.com/mastodon/mastodon.git /mnt/mastodon/mastodon

echo "Move files and setup permissions..."
mv -v /root/ubuntu/.env.production /mnt/mastodon/mastodon/.env.production
mv -v /root/ubuntu/docker-compose-alt.yml /mnt/mastodon/mastodon/docker-compose-alt.yml
mkdir -p /mnt/mastodon/mastodon/public/system
mv -v /root/ubuntu/admin_runner.rb /mnt/mastodon/mastodon/public/system
mkdir -p /etc/letsencrypt/fake/${local_domain}
mv -v /root/ssl/private.pem /etc/letsencrypt/fake/${local_domain}/privkey.pem
mv -v /root/ssl/cert.pem /etc/letsencrypt/fake/${local_domain}/fullchain.pem
chmod a+r /etc/letsencrypt/fake/${local_domain}/fullchain.pem
chmod a+rx /mnt/mastodon/mastodon/public/system/admin_runner.rb
chown -R ubuntu:ubuntu /mnt/mastodon
mv -v /etc/nginx/nginx.conf /etc/nginx/nginx.conf.dist
mv -v /root/nginx.conf /etc/nginx

echo "Make sure mastodon.service is not running..."
systemctl daemon-reload
systemctl disable mastodon.service
systemctl stop mastodon.service

echo "Running rake db:setup..."
cd /mnt/mastodon/mastodon
sudo -u ubuntu docker-compose --file docker-compose-alt.yml run --rm web bundle exec rake db:setup

echo "Running rails assets:precompile..."
sudo -u ubuntu docker-compose --file docker-compose-alt.yml run --rm web bundle exec rails assets:precompile

echo "Generating vapid key and appending variables to .env.production file..."
sudo -u ubuntu docker-compose --file docker-compose-alt.yml run --rm web bundle exec rake mastodon:webpush:generate_vapid_key >> /mnt/mastodon/mastodon/.env.production

echo "Copying .env.production file to /root for a backup..."
cp -va /mnt/mastodon/mastodon/.env.production /root/env.production

echo "Fix /mnt/mastodon/mastodon/public/system folder with correct ownership..."
mastodon_uid=$(sudo -u ubuntu docker-compose -f docker-compose-alt.yml run --rm web id -u)
mastodon_gid=$(sudo -u ubuntu docker-compose -f docker-compose-alt.yml run --rm web id -g)
clean_mastodon_uid=$(echo $mastodon_uid | tr -d '\r')
clean_mastodon_gid=$(echo $mastodon_gid | tr -d '\r')
chown -R $${clean_mastodon_uid}:$${clean_mastodon_gid} /mnt/mastodon/mastodon/public/system

echo "Running a Rails runner to add an admin user..."
sudo -u ubuntu ADMIN_EMAIL=${admin_email} ADMIN_PASSWORD=${admin_password} ADMIN_USERNAME=${admin_username} docker-compose --file docker-compose-alt.yml run --rm web bundle exec rails runner /mastodon/public/system/admin_runner.rb

echo "Enable mastodon.service to start on boot..."
systemctl enable mastodon.service

echo "Enable nginx.service to start on boot..."
systemctl enable nginx.service

echo "Setting up firewall rule..."
sed -i "s/-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT/-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT\n-A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW -j ACCEPT/" /etc/iptables/rules.v4

echo "Restart nginx.service for certbot SSL setup..."
systemctl restart nginx.service

echo "Setting up SSL with Let's Encrypt..."
if /root/bin/certbot_setup; then
  echo "Remove /etc/rc.local to prevent this setup script from running on boot..."
  rm -fv /etc/rc.local
else
  echo "Setup of Let's Encrypt failed. Will attempt again at next reboot."
  echo "#!/bin/sh -e" > /etc/rc.local
  echo "/root/bin/certbot_setup" >> /etc/rc.local
  echo "exit 0" >> /etc/rc.local
fi

echo "goodbye from setup script at $(date).  rebooting" > /root/bye.txt
echo "finished setup script. rebooting..."
reboot

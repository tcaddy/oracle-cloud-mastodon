#!/usr/bin/env bash

# get public ip address of virtual machine
pat='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' # weak ipv4 regex
s=$(curl ifconfig.co) # lame way to get public ip address
[[ $s =~ $pat ]] # see https://riptutorial.com/bash/example/19469/regex-matching
PUBLIC_IP="$${BASH_REMATCH[0]}"
echo "PUBLIC_IP: $PUBLIC_IP"

# make sure our public IP matches the DNS record for ${local_domain}
IP_FOR_DOMAIN=$(dig +short ${local_domain})
echo "IP_FOR_DOMAIN: $IP_FOR_DOMAIN"

if [[ "$PUBLIC_IP" != "$IP_FOR_DOMAIN" ]]; then
  echo "IP addresses do not match, exiting..."
  exit 1
fi

certbot --nginx -m ${admin_email} -d ${local_domain} --agree-tos -n || exit 1

echo "#!/bin/sh" > /etc/cron.weekly/lets_encrypt_auto_renew
echo "certbot renew" >> /etc/cron.weekly/lets_encrypt_auto_renew
chmod a+x /etc/cron.weekly/lets_encrypt_auto_renew

# cleanup leftovers from setup
rm -fv /etc/rc.local
rm -Rfv /etc/letsencrypt/fake

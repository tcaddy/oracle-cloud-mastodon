events {
  worker_connections 768;
  # multi_accept on;
}

http {
  map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
  }

  server {
    listen 80;
    listen [::]:80;
    server_name ${local_domain};

    # Useful for Let's Encrypt
    location /.well-known/acme-challenge/ {
      alias /mnt/mastodon/mastodon/public/.well-known/acme-challenge/;
    }

    location / { return 301 https://$host$request_uri; }
  }

  server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${local_domain};

    ssl_protocols TLSv1.2;
    ssl_ciphers HIGH:!MEDIUM:!LOW:!aNULL:!NULL:!SHA;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;

    ssl_certificate     /etc/letsencrypt/fake/${local_domain}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/fake/${local_domain}/privkey.pem;

    keepalive_timeout    70;
    sendfile             on;
    client_max_body_size 8m;

    root /mnt/mastodon/mastodon/public;

    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location / {
      try_files $uri @proxy;
    }

    location ~ ^/(emoji|packs|system/accounts/avatars|system/media_attachments/files) {
      add_header Cache-Control "public, max-age=31536000, immutable";
      try_files $uri @proxy;
    }

    location /sw.js {
      add_header Cache-Control "public, max-age=0";
      try_files $uri @proxy;
    }

    location @proxy {
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto https;
      proxy_set_header Proxy "";
      proxy_pass_header Server;

      proxy_pass http://127.0.0.1:3000;
      proxy_buffering off;
      proxy_redirect off;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;

      tcp_nodelay on;
    }

    location /api/v1/streaming {
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto https;
      proxy_set_header Proxy "";

      proxy_pass http://127.0.0.1:4000;
      proxy_buffering off;
      proxy_redirect off;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;

      tcp_nodelay on;
    }

    error_page 500 501 502 503 504 /500.html;
  }
}

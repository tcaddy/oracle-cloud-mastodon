# This is a sample configuration file. You can generate your configuration
# with the `rake mastodon:setup` interactive setup wizard, but to customize
# your setup even further, you'll need to edit it manually. This sample does
# not demonstrate all available configuration options. Please look at
# https://docs.joinmastodon.org/admin/config/ for the full documentation.

# Note that this file accepts slightly different syntax depending on whether
# you are using `docker-compose` or not. In particular, if you use
# `docker-compose`, the value of each declared variable will be taken verbatim,
# including surrounding quotes.
# See: https://github.com/mastodon/mastodon/issues/16895

# Federation
# ----------
# This identifies your server and cannot be changed safely later
# ----------
LOCAL_DOMAIN=${local_domain}

# Redis
# -----
REDIS_HOST=redis
REDIS_PORT=6379

# PostgreSQL
# ----------
DB_HOST=db
DB_USER=postgres
DB_NAME=mastodon_production
DB_PASS=
DB_PORT=5432

# Elasticsearch (optional)
# ------------------------
# ES_ENABLED=true
# ES_HOST=localhost
# ES_PORT=9200
# Authentication for ES (optional)
# ES_USER=elastic
# ES_PASS=password

# Secrets
# -------
# Make sure to use `rake secret` to generate secrets
# -------
SECRET_KEY_BASE=${secret_key_base}
OTP_SECRET=${otp_secret}

# Web Push
# --------
# Generate with `rake mastodon:webpush:generate_vapid_key`
# --------
# VAPID_PRIVATE_KEY=
# VAPID_PUBLIC_KEY=

# Sending mail
# ------------
SMTP_SERVER=
SMTP_PORT=587
SMTP_LOGIN=
SMTP_PASSWORD=
SMTP_FROM_ADDRESS=notifications@example.com

# File storage (optional)
# -----------------------
# S3_ENABLED=true
# S3_BUCKET=files.example.com
# AWS_ACCESS_KEY_ID=
# AWS_SECRET_ACCESS_KEY=
# S3_ALIAS_HOST=files.example.com

# IP and session retention
# -----------------------
# Make sure to modify the scheduling of ip_cleanup_scheduler in config/sidekiq.yml
# to be less than daily if you lower IP_RETENTION_PERIOD below two days (172800).
# -----------------------
IP_RETENTION_PERIOD=31556952
SESSION_RETENTION_PERIOD=31556952
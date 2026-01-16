#!/usr/bin/env bash
set -euo pipefail

# Log everything (important for userdata)
exec > >(tee /var/log/nginx-install.log) 2>&1

echo "==> Installing prerequisites"
apt-get update -y
apt-get install -y \
  curl \
  gnupg2 \
  ca-certificates \
  lsb-release \
  ubuntu-keyring

NGINX_KEYRING="/usr/share/keyrings/nginx-archive-keyring.gpg"
NGINX_LIST="/etc/apt/sources.list.d/nginx.list"

echo "==> Adding NGINX signing key (idempotent)"
if [ ! -f "$NGINX_KEYRING" ]; then
  curl -fsSL https://nginx.org/keys/nginx_signing.key \
    | gpg --dearmor \
    | tee "$NGINX_KEYRING" > /dev/null
else
  echo "NGINX keyring already exists, skipping"
fi

echo "==> Verifying NGINX signing key"
gpg --dry-run --quiet --no-keyring \
  --import --import-options import-show "$NGINX_KEYRING"

echo "==> Adding NGINX APT repository (idempotent)"
if [ ! -f "$NGINX_LIST" ]; then
  echo "deb [signed-by=$NGINX_KEYRING] \
https://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" \
    | tee "$NGINX_LIST" > /dev/null
else
  echo "NGINX repo already exists, skipping"
fi

echo "==> Updating package index"
apt-get update -y

echo "==> Installing NGINX"
apt-get install -y nginx

echo "==> Enabling and starting NGINX"
systemctl enable nginx
systemctl start nginx

echo "==> Verifying NGINX installation"
nginx -v

echo "=== NGINX INSTALL COMPLETED SUCCESSFULLY ==="



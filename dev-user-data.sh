#!/bin/bash
set -euo pipefail

# Redirect output to log file
exec > >(tee /var/log/user-data.log) 2>&1

echo "=== Starting User Data Script ==="

echo "==> Updating system and installing base dependencies..."
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    unzip \
    zip \
    curl \
    wget \
    gnupg \
    acl \
    cron \
    imagemagick \
    git


# Define script URLs - REPLACE THESE WITH YOUR ACTUAL REPO URLs
DOCKER_SCRIPT_URL="https://raw.githubusercontent.com/abhish3k07/magento-248-setup/refs/heads/main/install-docker.sh"
NGINX_SCRIPT_URL="https://raw.githubusercontent.com/abhish3k07/magento-248-setup/refs/heads/main/nginx-install.sh"
PHP_SCRIPT_URL="https://raw.githubusercontent.com/abhish3k07/magento-248-setup/refs/heads/main/php84-install.sh"
VARNISH_SCRIPT_URL="https://raw.githubusercontent.com/abhish3k07/magento-248-setup/refs/heads/main/varnish77-install.sh"
MARIADB_SCRIPT_URL="https://raw.githubusercontent.com/abhish3k07/magento-248-setup/refs/heads/main/mariadb-install.sh"

# Directory to clone repo
REPO_DIR="/root/magento-248-setup"
REPO_URL="https://github.com/abhish3k07/magento-248-setup.git"

echo "==> Cloning repository..."
git clone "$REPO_URL" "$REPO_DIR"

echo "==> Setting up /backup directory..."
mkdir -p /backup
if [ -d "$REPO_DIR/backup" ]; then
    cp -r "$REPO_DIR/backup/"* /backup/
    echo "Backup templates copied to /backup"
else
    echo "Warning: backup directory not found in repository"
fi

# Directory to download scripts to (keeping legacy flow for individual scripts if needed, but we have the repo now)
DOWNLOAD_DIR="/root/setup-scripts"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

echo "==> Downloading scripts..."

# Download scripts
wget -O install-docker.sh "$DOCKER_SCRIPT_URL"
wget -O nginx-install.sh "$NGINX_SCRIPT_URL"
wget -O php84-install.sh "$PHP_SCRIPT_URL"
wget -O varnish77-install.sh "$VARNISH_SCRIPT_URL"
wget -O mariadb-install.sh "$MARIADB_SCRIPT_URL"

# Make scripts executable
chmod +x install-docker.sh nginx-install.sh php84-install.sh varnish77-install.sh mariadb-install.sh

echo "==> Executing scripts..."

echo "-> Running install-docker.sh"
./install-docker.sh

echo "-> Running nginx-install.sh"
./nginx-install.sh

echo "-> Running php84-install.sh"
./php84-install.sh

echo "-> Running varnish77-install.sh"
./varnish77-install.sh

echo "-> Running mariadb-install.sh"
./mariadb-install.sh

echo "-> Installing n98-magerun2"
wget https://files.magerun.net/n98-magerun2.phar -O /usr/bin/magerun2
chmod a+x /usr/bin/magerun2

echo "=== User Data Script Completed ==="

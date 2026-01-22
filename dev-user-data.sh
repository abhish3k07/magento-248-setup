#!/bin/bash
set -euo pipefail

# Redirect output to log file
exec > >(tee /var/log/user-data.log) 2>&1

echo "=== Starting User Data Script ==="

# Define script URLs - REPLACE THESE WITH YOUR ACTUAL REPO URLs
DOCKER_SCRIPT_URL="https://raw.githubusercontent.com/abhish3k07/magento-248-setup/refs/heads/main/install-docker.sh"
NGINX_SCRIPT_URL="https://raw.githubusercontent.com/abhish3k07/magento-248-setup/refs/heads/main/nginx-install.sh"
PHP_SCRIPT_URL="https://raw.githubusercontent.com/abhish3k07/magento-248-setup/refs/heads/main/php84-install.sh"
VARNISH_SCRIPT_URL="https://raw.githubusercontent.com/abhish3k07/magento-248-setup/refs/heads/main/varnish77-install.sh"

# Directory to download scripts to
DOWNLOAD_DIR="/root/setup-scripts"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

echo "==> Downloading scripts..."

# Download scripts
wget -O install-docker.sh "$DOCKER_SCRIPT_URL"
wget -O nginx-install.sh "$NGINX_SCRIPT_URL"
wget -O php84-install.sh "$PHP_SCRIPT_URL"
wget -O varnish77-install.sh "$VARNISH_SCRIPT_URL"

# Make scripts executable
chmod +x install-docker.sh nginx-install.sh php84-install.sh varnish77-install.sh

echo "==> Executing scripts..."

echo "-> Running install-docker.sh"
./install-docker.sh

echo "-> Running nginx-install.sh"
./nginx-install.sh

echo "-> Running php84-install.sh"
./php84-install.sh

echo "-> Running varnish77-install.sh"
./varnish77-install.sh

echo "=== User Data Script Completed ==="

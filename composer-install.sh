#!/bin/bash
set -euo pipefail

echo "=== Installing Composer (Magento compatible) ==="

# Install dependencies Composer needs
apt-get update
apt-get install -y curl git unzip

# Verify installer signature
EXPECTED_SIGNATURE="$(curl -fsSL https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    echo "ERROR: Invalid Composer installer signature"
    rm composer-setup.php
    exit 1
fi

# Install Composer globally
php composer-setup.php \
  --install-dir=/usr/local/bin \
  --filename=composer

rm composer-setup.php

# Verify version
composer --version

echo "=== Composer installation complete ==="

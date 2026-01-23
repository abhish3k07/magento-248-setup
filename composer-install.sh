#!/bin/bash
set -euo pipefail


# Check if running as root
if [ "$EUID" -eq 0 ]; then
  echo "Please do not run this script as root. Run as a normal user with sudo privileges."
  exit 1
fi

echo "=== Installing Composer (Magento compatible) ==="

# Install dependencies Composer needs
sudo apt-get update
sudo apt-get install -y curl git unzip

# Verify installer signature
EXPECTED_SIGNATURE="$(curl -fsSL https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    echo "ERROR: Invalid Composer installer signature"
    rm composer-setup.php
    exit 1
fi

# Install Composer (generate composer.phar locally)
php composer-setup.php

# Move to global path with sudo
sudo mv composer.phar /usr/local/bin/composer

rm composer-setup.php

# Verify version
composer --version

echo "=== Composer installation complete ==="

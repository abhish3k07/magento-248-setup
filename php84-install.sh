#!/usr/bin/env bash
set -euo pipefail

exec > >(tee /var/log/install-php84-dev.log) 2>&1

echo "=== Installing PHP 8.4 (DEV profile) on Ubuntu 22.04 ==="

# --------------------------------------------------
# 1. Prerequisites + PHP repo
# --------------------------------------------------
apt-get update -y
apt-get install -y \
    ca-certificates \
    apt-transport-https \
    software-properties-common

if ! grep -R "^deb .*ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d/* >/dev/null 2>&1; then
    add-apt-repository -y ppa:ondrej/php
fi

apt-get update -y

# --------------------------------------------------
# 2. PHP 8.4 core + FPM
# --------------------------------------------------
apt-get install -y \
    php8.4 \
    php8.4-cli \
    php8.4-common \
    php8.4-fpm

# --------------------------------------------------
# 3. PHP extensions (same functional scope as legacy script)
# --------------------------------------------------
apt-get install -y \
    php8.4-bcmath \
    php8.4-ctype \
    php8.4-curl \
    php8.4-dom \
    php8.4-gd \
    php8.4-iconv \
    php8.4-intl \
    php8.4-mbstring \
    php8.4-mysql \
    php8.4-soap \
    php8.4-xml \
    php8.4-xsl \
    php8.4-zip \
    php8.4-simplexml \
    php8.4-opcache \
    php8.4-sockets \
    php8.4-gmp \
    php8.4-amqp \
    php8.4-igbinary \
    php8.4-redis \
    php8.4-oauth \
    php8.4-apcu

# --------------------------------------------------
# 4. Enable & start PHP-FPM (no tuning)
# --------------------------------------------------
systemctl enable php8.4-fpm
systemctl start php8.4-fpm

# --------------------------------------------------
# 5. Validation (DEV-friendly)
# --------------------------------------------------
php -v
php --ini
php -m | grep -E "bcmath|curl|intl|mbstring|mysql|soap|zip|opcache"

echo "=== PHP 8.4 DEV installation complete ==="


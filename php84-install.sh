#!/usr/bin/env bash
set -euo pipefail

exec > >(tee /var/log/install-php84-dev.log) 2>&1

echo "=== Installing PHP 8.4 (DEV) with php.ini-aligned tuning ==="

# --------------------------------------------------
# 1. Prerequisites + repo
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
# 3. Extensions (same scope as legacy script)
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
  php8.4-xmlrpc \
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
# 4. DEV php.ini tuning (from provided php.ini)
# --------------------------------------------------
echo "==> Applying DEV php.ini overrides"

for SAPI in fpm cli; do
  INI_DIR="/etc/php/8.4/${SAPI}/conf.d"
  INI_FILE="${INI_DIR}/99-dev.ini"

  cat > "${INI_FILE}" <<'EOF'
short_open_tag = Off
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off

zend.enable_gc = On
zend.exception_ignore_args = On
zend.exception_string_param_max_len = 0

expose_php = On

max_execution_time = 30
max_input_time = 60
memory_limit = -1

error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On

variables_order = "GPCS"
request_order = "GP"
register_argc_argv = Off
auto_globals_jit = On

post_max_size = 8M
upload_max_filesize = 2M
file_uploads = On

allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60

session.use_strict_mode = 0
session.use_only_cookies = 1
session.gc_probability = 0
session.gc_divisor = 1000
session.gc_maxlifetime = 1440

zend.assertions = -1
EOF
done

# --------------------------------------------------
# 5. Enable & restart PHP-FPM
# --------------------------------------------------
systemctl enable php8.4-fpm
systemctl restart php8.4-fpm

# --------------------------------------------------
# 6. Validation
# --------------------------------------------------
php -v
php --ini
php -i | grep -E "memory_limit|max_execution_time|post_max_size|upload_max_filesize|display_errors"

echo "=== PHP 8.4 DEV installation & tuning completed ==="

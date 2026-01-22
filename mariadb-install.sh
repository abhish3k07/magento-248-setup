#!/bin/bash
set -euo pipefail

echo "=== Installing MariaDB 11.4 LTS on Ubuntu 24.04 ==="

# Ensure system is up to date
apt-get update
apt-get install -y \
  curl \
  ca-certificates \
  gnupg \
  lsb-release \
  software-properties-common

# Import MariaDB signing key
curl -fsSL https://mariadb.org/mariadb_release_signing_key.asc | \
  gpg --dearmor -o /usr/share/keyrings/mariadb-keyring.gpg

# Add MariaDB 11.4 repository for Ubuntu 24.04 (noble)
cat <<EOF >/etc/apt/sources.list.d/mariadb.list
deb [signed-by=/usr/share/keyrings/mariadb-keyring.gpg] \
https://mirror.mariadb.org/repo/11.4/ubuntu \
noble main
EOF

# Refresh package index
apt-get update

# Install MariaDB server & client (non-interactive)
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  mariadb-server \
  mariadb-client

# Enable and start MariaDB
systemctl enable mariadb
systemctl start mariadb

# Sanity check
mysql -u root -e "SELECT VERSION();" >/dev/null

echo "=== MariaDB 11.4 installation complete ==="

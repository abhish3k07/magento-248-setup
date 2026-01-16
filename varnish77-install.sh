#!/usr/bin/env bash
set -euo pipefail

exec > >(tee /var/log/install-varnish77.log) 2>&1

echo "=== Installing Varnish Cache 7.7 (Magento compatible) ==="

# --------------------------------------------------
# 1. Add Varnish 7.7 repository (packagecloud)
# --------------------------------------------------
echo "==> Adding Varnish 7.7 repository"

if [ ! -f /etc/apt/sources.list.d/varnishcache_varnish77.list ]; then
  curl -s https://packagecloud.io/install/repositories/varnishcache/varnish77/script.deb.sh | bash
else
  echo "Varnish 7.7 repository already present, skipping"
fi

# --------------------------------------------------
# 2. Install Varnish 7.7.3 (pinned)
# --------------------------------------------------
echo "==> Installing Varnish 7.7.3"

apt-get update -y

apt-get install -y varnish=7.7.3-1~noble

# --------------------------------------------------
# 3. Enable & start Varnish
# --------------------------------------------------
echo "==> Enabling and starting Varnish"

systemctl enable varnish
systemctl start varnish

# --------------------------------------------------
# 4. Validation
# --------------------------------------------------
echo "==> Validating Varnish installation"

varnishd -V
systemctl status varnish --no-pager

echo "=== Varnish 7.7 installation completed successfully ==="

#!/usr/bin/env bash
set -euo pipefail

exec > >(tee /var/log/install-docker.log) 2>&1

echo "=== Installing Docker (official repository) ==="

# --------------------------------------------------
# 1. Remove old / conflicting Docker packages
# --------------------------------------------------
echo "==> Removing old Docker-related packages (if any)"

OLD_PACKAGES=$(dpkg --get-selections \
  docker.io docker-compose docker-compose-v2 docker-doc \
  podman-docker containerd runc 2>/dev/null | cut -f1 || true)

if [ -n "$OLD_PACKAGES" ]; then
  apt remove -y $OLD_PACKAGES
else
  echo "No old Docker packages found, skipping removal"
fi

# --------------------------------------------------
# 2. Install prerequisites
# --------------------------------------------------
echo "==> Installing prerequisites"

apt update -y
apt install -y \
  ca-certificates \
  curl

# --------------------------------------------------
# 3. Add Docker official GPG key (idempotent)
# --------------------------------------------------
echo "==> Adding Docker GPG key"

install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
else
  echo "Docker GPG key already exists, skipping"
fi

# --------------------------------------------------
# 4. Add Docker APT repository
# --------------------------------------------------
echo "==> Adding Docker APT repository"

cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# --------------------------------------------------
# 5. Install Docker Engine & plugins
# --------------------------------------------------
echo "==> Installing Docker Engine and components"

apt update -y

apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# --------------------------------------------------
# 6. Enable & start Docker
# --------------------------------------------------
echo "==> Enabling and starting Docker"

systemctl enable docker
systemctl start docker

# --------------------------------------------------
# 7. Validation
# --------------------------------------------------
echo "==> Validating Docker installation"

docker --version

echo "=== Docker installation completed successfully ==="

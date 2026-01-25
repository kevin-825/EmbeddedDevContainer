#!/usr/bin/env bash
set -euo pipefail

echo "[CLEAN-DOCKER] Starting full Docker cleanup…"

echo "[CLEAN-DOCKER] Stopping Docker services if running…"
sudo systemctl stop docker.service 2>/dev/null || true
sudo systemctl stop docker.socket 2>/dev/null || true
sudo service docker stop 2>/dev/null || true
sudo pkill dockerd 2>/dev/null || true

echo "[CLEAN-DOCKER] Removing all Docker-related packages…"
sudo apt-get remove -y \
    docker.io \
    docker-ce \
    docker-ce-cli \
    docker-ce-rootless-extras \
    docker-buildx-plugin \
    docker-compose-plugin \
    containerd.io \
    moby-engine \
    moby-cli \
    moby-buildx \
    moby-compose \
    moby-containerd \
    moby-runc \
    moby-buildkit \
    moby-tini \
    || true

echo "[CLEAN-DOCKER] Autoremoving leftovers…"
sudo apt-get autoremove -y || true

echo "[CLEAN-DOCKER] Removing old Docker directories…"
sudo rm -rf /etc/docker || true
sudo rm -rf /var/lib/docker || true
sudo rm -rf /var/lib/containerd || true

echo "[CLEAN-DOCKER] Removing old systemd units…"
sudo rm -rf /etc/systemd/system/docker.service.d || true
sudo rm -f /etc/systemd/system/docker.service || true
sudo rm -f /etc/systemd/system/docker.socket || true
sudo rm -f /lib/systemd/system/docker.service || true
sudo rm -f /lib/systemd/system/docker.socket || true

echo "[CLEAN-DOCKER] Reloading systemd…"
sudo systemctl daemon-reload || true

echo "[CLEAN-DOCKER] Removing old binaries if present…"
sudo rm -f /usr/bin/dockerd || true
sudo rm -f /usr/bin/docker || true
sudo rm -f /usr/bin/docker-init || true
sudo rm -f /usr/bin/docker-proxy || true
sudo rm -f /usr/bin/containerd || true
sudo rm -f /usr/bin/containerd-shim* || true
sudo rm -f /usr/bin/runc || true

echo "[CLEAN-DOCKER] Adding official Docker APT repository…"
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

echo "[CLEAN-DOCKER] Installing official Docker CE…"
sudo apt-get update -y
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "[CLEAN-DOCKER] Enabling and starting Docker…"
sudo systemctl enable docker.service || true
sudo systemctl enable docker.socket || true
sudo systemctl start docker.service || true

echo "[CLEAN-DOCKER] Verifying installation…"
docker --version
dockerd --version
docker info

echo "[CLEAN-DOCKER] Docker CE installation complete."
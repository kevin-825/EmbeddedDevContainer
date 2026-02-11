#!/usr/bin/env bash
set -e

# -----------------------------
# User-configurable metadata
# -----------------------------
NameSpace="kflyn825"
ImageRepositoryName="template_old"
ImageVerTag="latest"

# Build target: baremetal or linux
# Default = baremetal
Target="${1:-baremetal}"

# -----------------------------
# Version arguments (override if needed)
# -----------------------------
SPIKE_VERSION="v1.1.1"
QEMU_VERSION="v10.2.0"
RISCV_PK_VERSION="v1.0.0"

RV_ELF_URL="https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2026.01.09/riscv64-elf-ubuntu-24.04-gcc.tar.xz"
RV_GLIBC_URL="https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2026.01.09/riscv64-glibc-ubuntu-24.04-gcc.tar.xz"

# -----------------------------
# Derived values
# -----------------------------
ImageTag="${NameSpace}/${ImageRepositoryName}:${ImageVerTag}"
Dockerfile="Dockerfile"

echo ""
echo "=============================================="
echo " Building target: ${Target}"
echo " Image: ${ImageTag}"
echo "=============================================="
echo ""

# -----------------------------
# Docker build
# -----------------------------
docker build \
    -f "$Dockerfile" \
    --target "$Target" \
    --build-arg HOST_UID=$(id -u) \
    --build-arg HOST_GID=$(id -g) \
    --build-arg SPIKE_VERSION="$SPIKE_VERSION" \
    --build-arg QEMU_VERSION="$QEMU_VERSION" \
    --build-arg RISCV_PK_VERSION="$RISCV_PK_VERSION" \
    --build-arg RV_ELF_URL="$RV_ELF_URL" \
    --build-arg RV_GLIBC_URL="$RV_GLIBC_URL" \
    -t "$ImageTag" \
    .

echo ""
echo "=============================================="
echo " Build complete!"
echo "=============================================="
echo ""

echo "Re-tag the image with the following command:"
echo "  docker image tag $ImageTag $NameSpace/$ImageRepositoryName:NewVersion"
echo ""
echo "Push the image with the following command:"
echo "  docker push $ImageTag"
echo ""

echo "Done."

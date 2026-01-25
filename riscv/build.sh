#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------
# User-configurable metadata
# ---------------------------------------------
NameSpace="kflyn825"
ImageRepositoryName="rvdev"

# Build target: baremetal or linux
#Target="${1:-baremetal}"

ImageVerTag="latest"

# ---------------------------------------------
# Load configuration from build.env (optional)
# ---------------------------------------------
if [ -f build.env ]; then
    echo "Loading configuration from build.env"
    # shellcheck disable=SC1091
    source build.env
else
    echo "No build.env found, using environment defaults"
fi

# ---------------------------------------------
# Tool paths (empty = skip)
# ---------------------------------------------
QEMU_PATH="${QEMU_PATH:-}"
SPIKE_PATH="${SPIKE_PATH:-}"
RISCV_PK_PATH="${RISCV_PK_PATH:-}"
RV_NEWLIB_PATH="${RV_NEWLIB_PATH:-}"
RV_GLIBC_PATH="${RV_GLIBC_PATH:-}"

# ---------------------------------------------
# Derived values
# ---------------------------------------------
ImageTag="${NameSpace}/${ImageRepositoryName}:${ImageVerTag}"
Dockerfile="Dockerfile"

echo ""
echo "=============================================="
echo " Building RISC-V Dev Container"
echo "----------------------------------------------"
#echo " Target:            ${Target}"
echo " Image:             ${ImageTag}"
echo ""
echo " Tool Paths:"
echo "   QEMU_PATH:       ${QEMU_PATH:-<empty>}"
echo "   SPIKE_PATH:      ${SPIKE_PATH:-<empty>}"
echo "   RISCV_PK_PATH:   ${RISCV_PK_PATH:-<empty>}"
echo "   RV_NEWLIB_PATH:  ${RV_NEWLIB_PATH:-<empty>}"
echo "   RV_GLIBC_PATH:   ${RV_GLIBC_PATH:-<empty>}"
echo "=============================================="
echo ""

# ---------------------------------------------
# Persistent BuildKit cache
# ---------------------------------------------
CACHE_DIR="/mnt/wsl/disk2/.buildkit-cache"
mkdir -p "$CACHE_DIR"


# ---------------------------------------------
# Ensure buildx builder exists (persistent)
# ---------------------------------------------
#WIN_GATEWAY=$(ip route | awk '/default/ {print $3}')
#PROXY_PORT=10808   # example

PROXY_OPTS=()

if [[ -n "$WIN_GATEWAY" && -n "$PROXY_PORT" ]]; then
  PROXY_OPTS+=(--driver-opt "env.http_proxy=http://$WIN_GATEWAY:$PROXY_PORT")
  PROXY_OPTS+=(--driver-opt "env.https_proxy=http://$WIN_GATEWAY:$PROXY_PORT")
  PROXY_OPTS+=(--driver-opt "env.no_proxy=localhost")
  PROXY_OPTS+=(--driver-opt "env.no_proxy=127.0.0.1")
  PROXY_OPTS+=(--driver-opt "env.no_proxy=::1")
  PROXY_OPTS+=(--driver-opt "env.no_proxy=192.168.0.0/16")
fi

#docker buildx rm mybuilder 2>/dev/null || true

if ! docker buildx inspect mybuilder >/dev/null 2>&1; then
    echo "Creating buildx builder 'mybuilder'..."
    docker buildx create \
      --name mybuilder \
      --driver docker-container \
      --driver-opt image=moby/buildkit:v0.12.5 \
      "${PROXY_OPTS[@]}" \
      --use

else
    echo "Using existing buildx builder 'mybuilder'"
    docker buildx use mybuilder
fi



# ---------------------------------------------
# Docker build
# ---------------------------------------------
docker buildx build \
    --pull=false \
    --progress=plain \
    --load \
    --cache-from type=local,src="$CACHE_DIR" \
    --cache-to type=local,dest="$CACHE_DIR",mode=max \
    -f "$Dockerfile" \
    --build-arg QEMU_PATH="$QEMU_PATH" \
    --build-arg SPIKE_PATH="$SPIKE_PATH" \
    --build-arg RISCV_PK_PATH="$RISCV_PK_PATH" \
    --build-arg RV_NEWLIB_PATH="$RV_NEWLIB_PATH" \
    --build-arg RV_GLIBC_PATH="$RV_GLIBC_PATH" \
    -t "$ImageTag" \
    .

#    --target "$Target" \


echo ""
echo "=============================================="
echo " Build complete!"
echo "=============================================="
echo ""
echo "Re-tag the image with:"
echo "  docker image tag $ImageTag $NameSpace/$ImageRepositoryName:NewVersion"
echo ""
echo "Push the image with:"
echo "  docker push $ImageTag"
echo ""
echo "Done."

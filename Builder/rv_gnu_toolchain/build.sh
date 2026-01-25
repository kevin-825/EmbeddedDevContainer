#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------
# User-configurable metadata
# ---------------------------------------------
NameSpace="kflyn825"
ImageRepositoryName="rv_gnu_toolchain_builder"
ImageVerTag="latest"

# Build target: baremetal or linux
#Target="${1:-baremetal}"

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
# Argument to pass
# ---------------------------------------------
ARG1="${ARG1:-}"

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
# Derived values
# ---------------------------------------------
ImageTag="${NameSpace}/${ImageRepositoryName}:${ImageVerTag}"
Dockerfile="Dockerfile"


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
    --build-arg ARG1="$ARG1" \
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

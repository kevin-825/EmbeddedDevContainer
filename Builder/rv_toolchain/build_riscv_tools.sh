#!/usr/bin/env bash
set -euo pipefail
umask 022

###############################################
# Base Path (single source of truth)
###############################################

BASE_PATH_PREFIX="${BASE_PATH_PREFIX:-/hst_root/mnt/wsl/vhd0/opt}"

# All tools go under:  $BASE_PATH_PREFIX/riscv/<tool>
RISCV_ROOT="${BASE_PATH_PREFIX}/riscv"

SPIKE_PREFIX="${RISCV_ROOT}/spike"
QEMU_PREFIX="${RISCV_ROOT}/qemu"
NEWLIB_PREFIX="${RISCV_ROOT}/newlib"
GLIBC_PREFIX="${RISCV_ROOT}/glibc}"
PK_PREFIX="${RISCV_ROOT}/pk"

###############################################
# Versions
###############################################

SPIKE_VERSION="${SPIKE_VERSION:-master}"
QEMU_VERSION="${QEMU_VERSION:-v10.2.0}"
RISCV_PK_VERSION="${RISCV_PK_VERSION:-master}"

###############################################
# Toolchain URLs
###############################################

NEWLIB_URL="${NEWLIB_URL:-https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2026.01.09/riscv64-elf-ubuntu-24.04-gcc.tar.xz}"
GLIBC_URL="${GLIBC_URL:-https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2026.01.09/riscv64-glibc-ubuntu-24.04-gcc.tar.xz}"

###############################################
# Proxy (optional)
###############################################

WIN_GATEWAY="${WIN_GATEWAY:-172.26.176.1}"
PROXY_PORT="${PROXY_PORT:-10808}"
USE_PROXY="${USE_PROXY:-1}"

###############################################
# Cleanup toggle
###############################################

CLEANUP="${CLEANUP:-0}"

###############################################
# Print Effective Configuration
###############################################

echo "=============================================="
echo " RISC-V Build Configuration"
echo "----------------------------------------------"
echo " BASE_PATH_PREFIX: ${BASE_PATH_PREFIX}"
echo " RISCV_ROOT:       ${RISCV_ROOT}"
echo
echo " SPIKE_PREFIX:     ${SPIKE_PREFIX}"
echo " QEMU_PREFIX:      ${QEMU_PREFIX}"
echo " NEWLIB_PREFIX:    ${NEWLIB_PREFIX}"
echo " GLIBC_PREFIX:     ${GLIBC_PREFIX}"
echo " PK_PREFIX:        ${PK_PREFIX}"
echo
echo " SPIKE_VERSION:    ${SPIKE_VERSION}"
echo " QEMU_VERSION:     ${QEMU_VERSION}"
echo " RISCV_PK_VERSION: ${RISCV_PK_VERSION}"
echo
echo " NEWLIB_URL:       ${NEWLIB_URL}"
echo " GLIBC_URL:        ${GLIBC_URL}"
echo
echo " USE_PROXY:        ${USE_PROXY}"
echo " CLEANUP:          ${CLEANUP}"
echo "=============================================="
echo

###############################################
# Ensure directory structure exists
###############################################

mkdir -p "${RISCV_ROOT}"

###############################################
# Proxy Setup
###############################################

if [[ "${USE_PROXY}" == "1" ]]; then
    export http_proxy="http://${WIN_GATEWAY}:${PROXY_PORT}"
    export https_proxy="http://${WIN_GATEWAY}:${PROXY_PORT}"
    export all_proxy="http://${WIN_GATEWAY}:${PROXY_PORT}"
    echo "[INFO] Proxy enabled"
else
    unset http_proxy https_proxy all_proxy
    echo "[INFO] Proxy disabled"
fi

###############################################
# 0.1 — Build Spike
###############################################

echo "[BUILD] Spike"
[ ! -d riscv-isa-sim ] && git clone git@github.com:riscv-software-src/riscv-isa-sim.git
cd riscv-isa-sim
git checkout "${SPIKE_VERSION}"
mkdir -p build && cd build
../configure --prefix="${SPIKE_PREFIX}"
make -j"$(nproc)"
make install
cd ../..
[[ "${CLEANUP}" == "1" ]] && rm -rf riscv-isa-sim
echo "[DONE] Spike installed to ${SPIKE_PREFIX}"
echo

###############################################
# 0.2 — Build QEMU
###############################################

echo "[BUILD] QEMU"
[ ! -d qemu ] && git clone git@gitlab.com:qemu-project/qemu.git
cd qemu
git checkout "${QEMU_VERSION}"
mkdir -p build && cd build
../configure \
    --target-list=riscv64-softmmu,riscv32-softmmu \
    --prefix="${QEMU_PREFIX}"
make -j"$(nproc)"
make install
cd ../..
[[ "${CLEANUP}" == "1" ]] && rm -rf qemu
echo "[DONE] QEMU installed to ${QEMU_PREFIX}"
echo

###############################################
# 0.3 — Download NEWLIB (ELF) Toolchain
###############################################

echo "[DOWNLOAD] NEWLIB (ELF) toolchain"
mkdir -p "${NEWLIB_PREFIX}"
wget -O /tmp/riscv-newlib.tar.xz "${NEWLIB_URL}"
tar -xf /tmp/riscv-newlib.tar.xz -C "${NEWLIB_PREFIX}"
rm /tmp/riscv-newlib.tar.xz
echo "[DONE] NEWLIB toolchain extracted to ${NEWLIB_PREFIX}"
echo

export PATH="${NEWLIB_PREFIX}/riscv/bin:${PATH}"

###############################################
# 0.4 — Download GLIBC Toolchain
###############################################

echo "[DOWNLOAD] GLIBC toolchain"
mkdir -p "${GLIBC_PREFIX}"
wget -O /tmp/riscv-glibc.tar.xz "${GLIBC_URL}"
tar -xf /tmp/riscv-glibc.tar.xz -C "${GLIBC_PREFIX}"
rm /tmp/riscv-glibc.tar.xz
echo "[DONE] GLIBC toolchain extracted to ${GLIBC_PREFIX}"
echo

###############################################
# 0.5 — Build riscv-pk
###############################################

echo "[BUILD] riscv-pk"
[ ! -d riscv-pk ] && git clone --depth=1 git@github.com:riscv-software-src/riscv-pk.git
cd riscv-pk
git checkout "${RISCV_PK_VERSION}"
mkdir -p build && cd build
../configure \
    --prefix="${PK_PREFIX}" \
    --host=riscv64-unknown-elf
make -j"$(nproc)"
make install
cd ../..
[[ "${CLEANUP}" == "1" ]] && rm -rf riscv-pk
echo "[DONE] riscv-pk installed to ${PK_PREFIX}"
echo

echo "=============================================="
echo " All RISC-V tools built successfully"
echo "=============================================="

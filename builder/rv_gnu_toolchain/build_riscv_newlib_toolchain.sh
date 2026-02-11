#!/bin/bash
set -e
WORKDIR=/mnt/wsl/disk2
RISCV=${WORKDIR}/opt/riscv
sudo mkdir -p ${RISCV}
cd /mnt/wsl/ramdisk0
pwd
# Clone only if riscv-gnu-toolchain doesn't already exist
if [ ! -d "riscv-gnu-toolchain" ]; then
  echo "Cloning riscv-gnu-toolchain..."
  git clone https://github.com/riscv-collab/riscv-gnu-toolchain
else
  echo "riscv-gnu-toolchain already exists, skipping clone."
fi
cd riscv-gnu-toolchain
git submodule update --init gcc

RISCV_NEWLIB=${RISCV}/gnu_toolchain_newlib
mkdir -p build-newlib && cd build-newlib

GDB_NATIVE_FLAGS_EXTRA="--with-python=/usr --with-expat --with-system-readline"
GDB_TARGET_FLAGS_EXTRA="--with-python=/usr --with-expat --with-system-readline"

#sudo ../configure \
#  --prefix=$RISCV_NEWLIB \
#  --disable-linux \
#  --enable-multilib \
#  --with-arch=rv64gc \
#  --with-abi=lp64d \
#  --with-cmodel=medany \
#  --with-languages=c,c++

#sudo make -j$(nproc)


cd ..




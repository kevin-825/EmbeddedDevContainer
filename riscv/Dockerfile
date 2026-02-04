###############################################
# Unified Embedded Development Image
# FreeRTOS + Linux kernel + QEMU + GDB + Python
###############################################
FROM ubuntu:24.04

LABEL maintainer="kevin@riscv.dev"

ENV DEBIAN_FRONTEND=noninteractive

# --------------------------------------------
# Configurable username
# --------------------------------------------
ENV ContainerUSER=ubuntu
ENV HOME=/home/$ContainerUSER

# -------------------------------------------------------
# Base + Embedded Development Dependencies
# -------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    libpixman-1-0 \
    libslirp0 \
    libaio1t64 \
    liburing2 \
    build-essential \
    ninja-build \
    cmake \
    python3 python3-pip \
    jq \
    git \
    openssh-client \
    gdb-multiarch \
    libncurses-dev \
    libssl-dev \
    libelf-dev \
    bc \
    flex \
    bison \
    kmod \
    rsync \
    device-tree-compiler \
    pkg-config \
    vim \
    nano \
    udev \
    usbutils \
    openocd \
    curl \
    zsh \
    fzf \
    fonts-powerline \
    fonts-noto-cjk \
    locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
# -------------------------------------------------------
# arm qemu Dependencies (for GUI applications inside container)
# -------------------------------------------------------
RUN apt-get update && apt-get install -y \
    libjpeg8 \
    libepoxy0 \
    libgtk-3-0 \
    libgdk-pixbuf-2.0-0 \
    libcairo2 \
    libx11-6 \
    libsdl2-2.0-0 \
    && rm -rf /var/lib/apt/lists/*
# -------------------------------------------------------
# Configurable RISC-V Toolchain Paths
# -------------------------------------------------------
ARG QEMU_PATH=""
ARG SPIKE_PATH=""
ARG RISCV_PK_PATH=""
ARG RV_NEWLIB_PATH=""
ARG RV_GLIBC_PATH=""

ENV PATH="${QEMU_PATH}:${SPIKE_PATH}:${RISCV_PK_PATH}:${RV_NEWLIB_PATH}:${RV_GLIBC_PATH}:${PATH}"


# --------------------------------------------
# Create user
# --------------------------------------------
RUN id -u $ContainerUSER >/dev/null 2>&1 || useradd --create-home -s /bin/bash -m $ContainerUSER \
  && echo "$ContainerUSER:$ContainerUSER" | chpasswd \
  && usermod -aG sudo $ContainerUSER \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# --------------------------------------------
# Create workspaces folder (separate block)
# --------------------------------------------
RUN mkdir -p /home/$ContainerUSER/workspaces \
  && chown -R $ContainerUSER:$ContainerUSER /home/$ContainerUSER/workspaces

# --------------------------------------------
# Install Oh-My-Zsh + Plugins + Themes
# --------------------------------------------
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/home/$ContainerUSER/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
 && git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-/home/$ContainerUSER/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
 && git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-/home/$ContainerUSER/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-/home/$ContainerUSER/.oh-my-zsh/custom}/themes/powerlevel10k \
 && git clone https://github.com/sindresorhus/pure.git \
    ${ZSH_CUSTOM:-/home/$ContainerUSER/.oh-my-zsh/custom}/themes/pure

# --------------------------------------------
# Copy .zshrc BEFORE switching user
# --------------------------------------------
COPY .zshrc /home/$ContainerUSER/.zshrc
RUN chown -R $ContainerUSER:$ContainerUSER /home/$ContainerUSER/.oh-my-zsh /home/$ContainerUSER/.zshrc

# --------------------------------------------
# Set default login shell to Zsh
# --------------------------------------------
RUN usermod -s /usr/bin/zsh $ContainerUSER

# --------------------------------------------
# Switch to non-root user
# --------------------------------------------
USER $ContainerUSER
WORKDIR /home/$ContainerUSER

CMD ["/usr/bin/zsh"]

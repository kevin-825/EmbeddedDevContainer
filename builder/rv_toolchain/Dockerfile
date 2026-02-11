###############################################
# Stage 1 — Bare-metal / FreeRTOS image
###############################################
FROM ubuntu:24.04

LABEL maintainer="kevin@riscv.dev"

ENV DEBIAN_FRONTEND=noninteractive
ENV $ContainerUSER=ubuntu
ENV HOME=/home/$ContainerUSER

# -------------------------------
# Configurable tool paths
# -------------------------------
ARG ARG1=""

# -------------------------------
# Base dependencies
# -------------------------------
RUN apt-get update
RUN apt-get install -y --no-install-recommends sudo \
    git \
    openssh-client \
    build-essential \
    g++ \
    autoconf \
    automake \
    libtool \
    device-tree-compiler \
    ninja-build \
    cmake \
    python3 python3-pip \
    meson \
    pkg-config \
    libglib2.0-dev \
    libpixman-1-dev \
    zlib1g-dev \
    libslirp-dev \
    libaio-dev \
    liburing-dev \
    libncurses-dev \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    flex \
    bison \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*



# -------------------------------
# Create user + workspace
# -------------------------------
ARG USER_ID=1000
ARG GROUP_ID=1000

# 1. Force the existing user to match the host's UID/GID
# 2. Fix the home directory permissions
# 3. Enable passwordless sudo
RUN groupmod -g ${GROUP_ID} $ContainerUSER || true \
    && usermod -u ${USER_ID} -g ${GROUP_ID} $ContainerUSER \
    && echo "$ContainerUSER:$ContainerUSER" | chpasswd \
    && usermod -aG sudo $ContainerUSER \
    && echo "$ContainerUSER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-cloud-init-users \
    && chown -R ${USER_ID}:${GROUP_ID} /home/$ContainerUSER

USER $ContainerUSER
WORKDIR $HOME

RUN mkdir -p /home/ubuntu/workspaces \
    && chown -R ubuntu:ubuntu /home/ubuntu

COPY ./build_riscv_tools.sh /home/ubuntu/

RUN echo  "if [ -f $HOME/workspaces/.bash_aliases ]; then" >> ~/.bashrc \
  && echo "    . $HOME/workspaces/.bash_aliases" >> ~/.bashrc \
  && echo "fi" >> ~/.bashrc \
  && echo  "if [ -f $HOME/workspaces/.bash_aliases_1 ]; then" >> ~/.bashrc \
  && echo "    . $HOME/workspaces/.bash_aliases_1" >> ~/.bashrc \
  && echo "fi" >> ~/.bashrc

CMD ["/bin/bash"]

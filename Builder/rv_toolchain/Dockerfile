###############################################
# Stage 1 — Bare-metal / FreeRTOS image
###############################################
FROM ubuntu:24.04

LABEL maintainer="kevin@riscv.dev"

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=ubuntu
ENV HOME=/home/$USER

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
RUN id -u $USER >/dev/null 2>&1 || useradd --create-home -s /bin/bash -m $USER \
  && echo "$USER:$USER" | chpasswd \
  && usermod -aG sudo $USER \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && chown -R $USER:$USER /home/$USER \
  && chown -R $USER:$USER /opt

USER $USER
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

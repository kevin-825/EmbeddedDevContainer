###############################################
#  toolchain builder (gcc, gdb, qemu, spike, pk)
###############################################
FROM ubuntu:24.04

LABEL maintainer="kevin@riscv.dev"

ENV DEBIAN_FRONTEND=noninteractive

# --------------------------------------------
# Configurable username
# --------------------------------------------
ENV ContainerUSER=ubuntu
ENV HOME=/home/$ContainerUSER
# -------------------------------
# Base dependencies
# -------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
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
    python3-dev \
    python3-setuptools \
    meson \
    pkg-config \
    libglib2.0-dev \
    libpixman-1-dev \
    zlib1g-dev \
    libslirp-dev \
    libaio-dev \
    liburing-dev \
    libncurses-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libsource-highlight-dev \
    libbabeltrace-dev \
    libelf-dev \
    liblzma-dev \
    libedit-dev \
    guile-3.0-dev \
    bc \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    libisl-dev \
    libexpat1-dev \
    libzstd-dev \
    libreadline-dev \
    libffi-dev \
    libgdbm-dev \
    texinfo \
    texlive \
    texlive-fonts-recommended \
    texlive-plain-generic \
    flex \
    bison \
    gawk \
    rsync \
    patch \
    file \
    dejagnu \
    expect \
    tcl \
    wget \
    curl \
    xz-utils \
    vim \
    htop \
    ccache \
    nano \
    ca-certificates \
    zsh \
    fzf \
    fonts-powerline \
    fonts-noto-cjk \
    locales \
    libsdl2-dev \
    libipt-dev \
    libcap-ng-dev \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# --------------------------------------------
# Create user
# --------------------------------------------
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


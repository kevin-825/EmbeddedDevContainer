FROM ubuntu:24.04

LABEL maintainer="kevin@riscv.dev"
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
# -------------------------------------------------------
# Base + Embedded Development Dependencies
# -------------------------------------------------------
RUN <<EOF
        set -e
        apt-get update
        apt-get install -y --no-install-recommends \
        sudo \
        wget \
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
        guile-3.0-dev \
        libyaml-dev \
        python3-yaml \
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
        locales

    # Configure locales
    locale-gen en_US.UTF-8
    update-locale LANG=en_US.UTF-8
    # Inside your RUN <<EOF block:
      
    # Install yq for YAML processing
    ARCH=$(dpkg --print-architecture)
    wget "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}" -O /usr/bin/yq
    chmod +x /usr/bin/yq
    # Clean up APT cache to reduce image size
    rm -rf /var/lib/apt/lists/*
EOF
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

# Define user build arguments and environment
ARG UID=1000
ARG GID=1000
ARG USERNAME="kevin"
ENV HOME=/home/$USERNAME

# Create non-root user and configure sudo permissions
RUN <<EOF
  set -e
  if id "ubuntu" &>/dev/null; then
    echo ">>> Removing default 'ubuntu' user to free up UID 1000"
    userdel -r ubuntu || true
    echo " userdel returned with code $?"
  fi
  #userdel -r ubuntu || true
  echo ">>> Creating user '$USERNAME' with UID $UID and GID $GID"
  groupadd -g ${GID} -o ${USERNAME}
  useradd -u ${UID} -m -g ${USERNAME} -G sudo,plugdev -s /usr/bin/zsh ${USERNAME}

  echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}
  chmod 0440 /etc/sudoers.d/${USERNAME}
EOF

# Setup workspace and entrypoint script
WORKDIR /workdir

COPY --chown=${USERNAME}:${GID} ./entrypoint.sh /home/entrypoint.sh
RUN chmod +x /home/entrypoint.sh

# Set final environment variables and volume
USER $USERNAME

ENV LANG=en_US.UTF-8
ENV TERM=xterm-256color
ENV MyENV=devcontainer

RUN <<EOF
  set -e
  # Install Oh-My-Zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # Define Custom Directory for readability
  ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

  # Install Plugins
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM}/plugins/zsh-history-substring-search

  # Install Themes
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k
  git clone --depth=1 https://github.com/sindresorhus/pure.git ${ZSH_CUSTOM}/themes/pure
EOF
COPY --chown=${USERNAME}:${GID} ./.zshrc ${HOME}/.zshrc

VOLUME ["/workdir"]

ENTRYPOINT ["/home/entrypoint.sh"]
#EXPOSE 5900
CMD ["zsh"]


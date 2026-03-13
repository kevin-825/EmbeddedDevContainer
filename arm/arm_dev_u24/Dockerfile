# STAGE 1: Asset downloader
FROM ubuntu:24.04 AS downloader

RUN apt-get update && apt-get install -y git curl ca-certificates zsh

# Setup a temporary directory to collect ZSH assets
WORKDIR /assets
# Force OMZ to install into our assets folder instead of /root
ENV ZSH=/assets/.oh-my-zsh

RUN <<EOF
  ls -l /assets

  set -e
  # Install Oh-My-Zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # Define Custom Directory using the variable
  ZSH_CUSTOM="$ZSH/custom"

  # Install Plugins
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM}/plugins/zsh-history-substring-search

  # Install Themes
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k
  git clone --depth=1 https://github.com/sindresorhus/pure.git ${ZSH_CUSTOM}/themes/pure
  ls -l /assets
EOF

# ---

# STAGE 2: Final Image
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
        cpio file lz4 zstd liblz4-tool \
        sudo wget curl git build-essential python3 python3-pip python-is-python3 \
        jq bc flex bison kmod rsync device-tree-compiler pkg-config \
        vim nano udev usbutils openocd zsh fzf locales

    # --- Shared Library/App Dependencies ---
    apt-get install -y --no-install-recommends \
        libpixman-1-0 libslirp0 libaio1t64 liburing2 \
        libncurses-dev guile-3.0-dev libyaml-dev python3-yaml \
        libssl-dev libelf-dev ninja-build cmake gdb-multiarch 

    # --- GUI/QEMU Display Dependencies ---
    apt-get install -y --no-install-recommends \
        libjpeg8 libepoxy0 libgtk-3-0 libgdk-pixbuf-2.0-0 \
        libcairo2 libx11-6 libsdl2-2.0-0

    # --- NEW: Lab-Specific Yocto Dependencies ---
    apt-get install -y --no-install-recommends \
        gawk diffstat unzip texinfo gcc-multilib chrpath socat \
        u-boot-tools iputils-ping net-tools libsdl1.2-dev xterm

    # Configure locales
    locale-gen en_US.UTF-8
    update-locale LANG=en_US.UTF-8

    # Install yq for YAML processing
    ARCH=$(dpkg --print-architecture)
    wget "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}" -O /usr/bin/yq
    chmod +x /usr/bin/yq

    # Install repo utility required by Lab [cite: 55-56]
    curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
    chmod a+x /usr/local/bin/repo

    # Clean up APT cache
    rm -rf /var/lib/apt/lists/*
EOF

# -------------------------------------------------------
# Configurable arm Toolchain Paths
# -------------------------------------------------------
ARG QEMU_PATH=""
ARG AARCH64_NON_ELF_PATH=""
ARG AARCH64_NON_LINUX_GNU_PATH=""
ARG ARM_NON_eABI_PATH=""
ARG ARM_NON_LINUX_GNUeABIhf_PATH=""

ENV PATH="${QEMU_PATH}:${AARCH64_NON_ELF_PATH}:${AARCH64_NON_LINUX_GNU_PATH}:${ARM_NON_eABI_PATH}:${ARM_NON_LINUX_GNUeABIhf_PATH}:${PATH}"

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

# Copy Assets from Stage 1
COPY --from=downloader --chown=${USERNAME}:${GID} /assets/.oh-my-zsh ${HOME}/.oh-my-zsh
COPY --chown=${USERNAME}:${GID} ./.zshrc ${HOME}/.zshrc
COPY --chown=${USERNAME}:${GID} ./entrypoint.sh /home/entrypoint.sh
RUN chmod +x /home/entrypoint.sh

# Set final environment variables and volume
USER $USERNAME

ENV LANG=en_US.UTF-8
ENV TERM=xterm-256color
ENV MyENV=devcontainer


VOLUME ["/workdir"]

ENTRYPOINT ["/home/entrypoint.sh"]
#EXPOSE 5900
CMD ["zsh"]


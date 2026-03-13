# STAGE 1: Asset downloader
FROM ubuntu:24.04 AS downloader

# Add zsh here so the OMZ installer can run in this stage
RUN apt-get update && apt-get install -y git curl ca-certificates zsh

WORKDIR /assets
ENV ZSH=/assets/.oh-my-zsh

RUN <<EOF
  set -e
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  ZSH_CUSTOM="$ZSH/custom"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM}/plugins/zsh-history-substring-search
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k
  git clone --depth=1 https://github.com/sindresorhus/pure.git ${ZSH_CUSTOM}/themes/pure
EOF

# ---

# STAGE 2: Final Image
FROM ubuntu:14.04

LABEL maintainer="kevin@riscv.dev"
ENV DEBIAN_FRONTEND=noninteractive

# Essential Mirror Fix for Ubuntu 14.04
RUN <<EOF
    rm -rf /etc/apt/sources.list.d/*
    echo "deb http://mirrors.kernel.org/ubuntu/ trusty main restricted universe multiverse" > /etc/apt/sources.list
    echo "deb http://mirrors.kernel.org/ubuntu/ trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list
    echo "deb http://mirrors.kernel.org/ubuntu/ trusty-security main restricted universe multiverse" >> /etc/apt/sources.list
EOF

# Install system dependencies (restored to your original list, updated for 14.04 compatibility)
RUN <<EOF
    set -e
    apt-get update || true
    # Note: Added --force-yes for legacy gpg keys and updated pkg names for 14.04
    apt-get install -y --force-yes --no-install-recommends \
        sudo wget curl git build-essential python python-pip python-dev \
        jq bc flex bison kmod rsync device-tree-compiler pkg-config \
        vim nano udev usbutils openocd zsh locales \
        libpixman-1-dev libaio-dev libncurses5-dev libyaml-dev \
        libssl-dev libelf-dev ninja-build cmake \
        gawk diffstat unzip texinfo gcc-multilib chrpath socat \
        u-boot-tools iputils-ping net-tools xterm

    # Configure locales
    locale-gen en_US.UTF-8
    update-locale LANG=en_US.UTF-8

    # Install yq (using static binary side-load logic)
    ARCH=$(dpkg --print-architecture)
    wget "https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_${ARCH}" -O /usr/bin/yq
    chmod +x /usr/bin/yq

    # Install repo utility
    curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
    chmod a+x /usr/local/bin/repo

    rm -rf /var/lib/apt/lists/*
EOF

# -------------------------------------------------------
# Configurable arm Toolchain Paths (Identical to your original)
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

# Create non-root user (Identical to your original)
RUN <<EOF
  set -e
  # 14.04 doesn't usually have an 'ubuntu' user, but the check remains for safety
  if id "ubuntu" &>/dev/null; then
    userdel -r ubuntu || true
  fi
  groupadd -g ${GID} -o ${USERNAME}
  useradd -u ${UID} -m -g ${USERNAME} -G sudo -s /usr/bin/zsh ${USERNAME}
  echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}
  chmod 0440 /etc/sudoers.d/${USERNAME}
EOF

WORKDIR /workdir

# Copy Assets from Stage 1
COPY --from=downloader --chown=${USERNAME}:${GID} /assets/.oh-my-zsh ${HOME}/.oh-my-zsh
COPY --chown=${USERNAME}:${GID} ./.zshrc ${HOME}/.zshrc
COPY --chown=${USERNAME}:${GID} ./entrypoint.sh /home/entrypoint.sh
RUN chmod +x /home/entrypoint.sh

USER $USERNAME
ENV LANG=en_US.UTF-8
ENV TERM=xterm-256color
ENV MyENV=devcontainer

VOLUME ["/workdir"]
ENTRYPOINT ["/home/entrypoint.sh"]
CMD ["zsh"]

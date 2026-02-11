FROM ubuntu:24.04

LABEL maintainer="kevin@riscv.dev"
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN <<EOF
        set -e
        apt-get update
        apt-get install -y --no-install-recommends \
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
        libsdl2-dev \
        libipt-dev \
        libcap-ng-dev \
        ca-certificates \
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


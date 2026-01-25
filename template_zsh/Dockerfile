###############################################
# Minimal Zsh Template (Themes + Plugins + fzf)
###############################################
FROM ubuntu:24.04

LABEL maintainer="kevin@riscv.dev"

ENV DEBIAN_FRONTEND=noninteractive

# --------------------------------------------
# Configurable username
# --------------------------------------------
ENV ContainerUSER=ubuntu
ENV HOME=/home/$ContainerUSER

# --------------------------------------------
# Minimal dependencies for Zsh environment
# --------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    git \
    nano \
    curl \
    ca-certificates \
    zsh \
    fonts-powerline \
    fzf \
    && rm -rf /var/lib/apt/lists/*

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

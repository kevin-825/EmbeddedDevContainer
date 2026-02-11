###############################################
# Dockerfile Template
###############################################
FROM ubuntu:24.04

LABEL maintainer="kevin@riscv.dev"

ENV DEBIAN_FRONTEND=noninteractive
ENV ContainerUSER=ubuntu
ENV HOME=/home/$ContainerUSER


# -------------------------------
# Base dependencies
# -------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    git \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# Configurable args
# -------------------------------
ARG ARG1=""
# --------------------------------------------
# Create user with Dynamic UID/GID
# -------------------------------------------

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
# -------------------------------
# Create user + workspace
# -------------------------------

USER $ContainerUSER
WORKDIR $HOME

RUN mkdir -p $HOME/workspaces && chown -R $ContainerUSER:$ContainerUSER $HOME/workspaces

RUN echo  "if [ -f $HOME/workspaces/.bash_aliases ]; then" >> ~/.bashrc \
  && echo "    . $HOME/workspaces/.bash_aliases" >> ~/.bashrc \
  && echo "fi" >> ~/.bashrc \
  && echo  "if [ -f $HOME/workspaces/.bash_aliases_1 ]; then" >> ~/.bashrc \
  && echo "    . $HOME/workspaces/.bash_aliases_1" >> ~/.bashrc \
  && echo "fi" >> ~/.bashrc

CMD ["/bin/bash"]

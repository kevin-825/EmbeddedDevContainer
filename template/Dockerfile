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

# -------------------------------
# Create user + workspace
# -------------------------------
RUN id -u $ContainerUSER >/dev/null 2>&1 || useradd --create-home -s /bin/bash -m $ContainerUSER \
  && echo "$ContainerUSER:$ContainerUSER" | chpasswd \
  && usermod -aG sudo $ContainerUSER \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && chown -R $ContainerUSER:$ContainerUSER /home/$ContainerUSER 

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

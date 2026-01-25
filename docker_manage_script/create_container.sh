#!/bin/bash

set -eu

source ~/.bash_aliases_1

container_name=$3
ContainerUSER=ubuntu
if [ -z "$container_name" ]; then
    echo error in container name
fi
#docker ps -a
#docker stop $container_name
#docker rm $container_name
#docker ps -a
#docker images
repo=$1
tag=$2
img=$repo-$tag

mkdir -p ~/Containers

curdir="$(pwd)"
host_dir_for_container=~/Containers/$img

# sudo docker run --name $container_name \
# -v $host_dir_for_container/workspace:/workspace \
# -v $host_dir_for_container/root:/root \
# -v $host_dir_for_container/root/.bash_history:/root/.bash_history \
# -v $host_dir_for_container/opt:/opt \
# -v $host_dir_for_container/home:/home \
# -v /home/kevin/toolchain/officialRiscvToolchain:/home/kevin/tools \
# -v /home/kevin/officialRepos:/home/kevin/officialRepos \
# -v /home/kevin/kflyn825Repos:/home/kevin/kflyn825Repos \
# -v /opt/riscv-gnu-toolchain-u22:/opt/riscv-gnu-toolchain-u22 \
# -it -p 2222:22  $repo:$tag

echo "xxxxxxxxxxxxxxx"
#echo $dockerVolumes
echo "xxxxxxxxxxxxxxx"

# $dockerVolumes define in .bash_aliases_1 file and expands as 
# -v /mnt/wsl/vhd0:/mnt/wsl/vhd0 -v /mnt/wsl/vhd1:/mnt/wsl/vhd1 -v /mnt/wsl/disk1:/mnt/wsl/disk1 -v /mnt/wsl/disk2:/mnt/wsl/disk2 -v /mnt/wsl/ramdisk5:/mnt/wsl/ramdisk5

create_run_container="docker run -it --name $container_name \
-v $host_dir_for_container/workspaces:/home/$ContainerUSER/workspaces \
-v $host_dir_for_container/workspaces:/home/$ContainerUSER/workspaces \
-v $host_dir_for_container/root/.bash_history:/root/.bash_history \
-v /home/$USER/.ssh:/home/$ContainerUSER/.ssh \
-v /:/hst_root \
$dockerVolumes \
-P $repo:$tag "

#echo create_run_container:$create_run_container

$create_run_container

# Check exit status
if [ $? -ne 0 ]; then
  echo "❌ Container failed to start."
  read -p "Do you want to delete and re-create it? [y/N]: " choice
  case "$choice" in
    y|Y )
      echo "🧨 Removing existing container (if any)..."
      docker rm -f $container_name 2>/dev/null
      echo "🔄 Recreating container..."
      $create_run_container
      ;;
    * )
      echo "🚪 Exit without re-creating container."
      exit 1
      ;;
  esac
else
  echo "✅ Container started successfully."
fi





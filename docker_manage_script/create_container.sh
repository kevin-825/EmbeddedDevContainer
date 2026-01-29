#!/bin/bash

set -u



container_name=$2
ContainerUSER=ubuntu
if [ -z "$container_name" ]; then
    echo error in container name
fi
#docker ps -a
#docker stop $container_name
#docker rm $container_name
#docker ps -a
#docker images

img_name=$1
img_name_path="${img_name//:/_}"

mkdir -p ~/Containers

curdir="$(pwd)"
host_dir_for_container=~/Containers/$img_name_path



# $dockerVolumes define in .bash_aliases_1 file and expands as 
# -v /mnt/wsl/vhd0:/mnt/wsl/vhd0 -v /mnt/wsl/vhd1:/mnt/wsl/vhd1 -v /mnt/wsl/disk1:/mnt/wsl/disk1 -v /mnt/wsl/disk2:/mnt/wsl/disk2 -v /mnt/wsl/ramdisk5:/mnt/wsl/ramdisk5
source ~/.bash_aliases_1

echo "xxxxxxxxxxxxxxx"
#echo $dockerVolumes
echo "xxxxxxxxxxxxxxx"

create_run_container="docker run -it --name $container_name \
-v $host_dir_for_container/workspaces:/home/$ContainerUSER/workspaces \
-v $host_dir_for_container/workspaces:/home/$ContainerUSER/workspaces \
-v $host_dir_for_container/root/.bash_history:/root/.bash_history \
-v /home/$USER/.ssh:/home/$ContainerUSER/.ssh \
-v /:/hst_root \
-v /home/$USER/.ssh/agent/sock:/ssh-agent \
-e SSH_AUTH_SOCK=/ssh-agent \
$dockerVolumes \
-P $img_name "

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





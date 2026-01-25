container_name=$1
image_name=$2
image_ver=$3
if [ -z "$container_name" ]; then
    echo error in container name
fi
if [ -z "$image_name" ]; then
    echo error in image_name
fi

if [ -z "$image_ver" ]; then
    echo error in image_ver
fi
echo container_name:$container_name
echo given image_name_and-tag: $image_name:$image_ver
sudo docker stop $container_name
sudo docker ps -a
cont_id=$(sudo docker ps -a --filter "name=$container_name" --format "{{.ID}}")

echo cont_id:$cont_id
sudo docker commit --change "ENV DEBUG=false" $cont_id $image_name:$image_ver
sudo docker images
sudo docker ps -a
sudo docker rm $container_name
sudo docker ps -a

# Prompt the user for input
read -p "Enter Y if you want to compress the Docker image: " user_input
# Handle user input
if [[ "$user_input" == "Y" || "$user_input" == "y" ]]; then
    echo "Compressing the Docker image..."
    # Add your Docker image compression command here
    docker save -o ${image_name}_${image_ver}.tar $image_name:$image_ver
    gzip ${image_name}_${image_ver}.tar
    echo "Docker image compressed successfully."
else
    echo "Skipping Docker image compression."
fi

./start_docker.sh $image_name $image_ver $container_name
#usage:
#docker load -i embdevubuntu_24.04.tar.gz


#start_docker.sh

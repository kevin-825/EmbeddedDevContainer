
image_name=$1
image_ver=$2

if [ -z "$image_name" ]; then
    echo error in image_name
fi

if [ -z "$image_ver" ]; then
    echo error in image_ver
fi

echo given image_name_and-tag: $image_name:$image_ver


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


#usage:
#docker load -i embdevubuntu_24.04.tar.gz


#start_docker.sh

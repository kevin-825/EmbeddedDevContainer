
#!/bin/bash

container_name="$1"

if [ -z "$container_name" ]; then
    echo "❌ Error: container name not provided."
    exit 1
fi
#sudo chown -R user0:user0 /home/user0/workspaces
# Get container status
status=$(docker inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null)

if [ "$status" = "running" ]; then
    echo "🔗 Attaching to running container '$container_name'..."
    docker exec -it $container_name /bin/bash
    # docker attach "$container_name"
elif [ "$status" = "exited" ]; then
    echo "🚀 Starting and attaching to stopped container '$container_name'..."
    docker start -ia "$container_name"
elif [ -z "$status" ]; then
    echo "🚫 Container '$container_name' does not exist."
    exit 1
else
    echo "🤷 Unknown container state: $status"
    exit 1
fi

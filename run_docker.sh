#!/usr/bin/env bash

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Build docker image if not already built
source "${SCRIPT_DIR}/build_docker.sh"

# Initialize options for docker run
source "${SCRIPT_DIR}/init_docker.sh"

CONTAINER_NAME="compiler-dev-$(basename "$PWD")"

# Check if container already exists
if [ "$(docker ps -a -q -f name=^${CONTAINER_NAME}$)" ]; then
    echo "Container '${CONTAINER_NAME}' already exists."
    
    # Check if container is running
    if [ "$(docker ps -q -f name=^${CONTAINER_NAME}$)" ]; then
        echo "Container is running. Attaching to it..."
        docker exec -it "${CONTAINER_NAME}" bash
    else
        echo "Container is stopped. Starting and attaching to it..."
        docker start "${CONTAINER_NAME}"
        docker exec -it "${CONTAINER_NAME}" bash
    fi
else
    echo "Creating new container '${CONTAINER_NAME}'..."
    # Bind mounts for the following:
    # - current directory to same dir in the container
    # - user's HOME directory (useful for .bash*, .gitconfig, .cache etc)
    # https://rocm.docs.amd.com/projects/install-on-linux/en/latest/how-to/docker.html#accessing-gpus-in-containers
    docker run -it \
               --name "${CONTAINER_NAME}" \
               -v "${PWD}":"${PWD}" \
               -v "${HOME}":"${HOME}" \
               ${DOCKER_RUN_DEVICE_OPTS} \
               --security-opt seccomp=unconfined \
               compiler-dev-ubuntu-24.04:latest
fi

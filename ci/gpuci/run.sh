#!/bin/bash
set -e

# Overwrite HOME to WORKSPACE
export HOME="$WORKSPACE"

# Install gpuCI tools
rm -rf .gpuci
git clone https://github.com/rapidsai/gpuci-tools.git .gpuci
chmod +x .gpuci/tools/*
export PATH="$PWD/.gpuci/tools:$PATH"

# Show env
gpuci_logger "Exposing current environment..."
env

# Login to docker
gpuci_logger "Logging into Docker..."
echo $DH_TOKEN | docker login --username $DH_USER --password-stdin &> /dev/null

DOCKER_FILE="${WORKSPACE}/Dockerfile"
BUILD_IMAGE="gpuci/dask"
BUILD_TAG="${RAPIDS_VER}-cuda${CUDA_VER}-devel-${LINUX_VER}-py${PYTHON_VER}"

# Setup BUILD_ARGS
BUILD_ARGS="--squash --build-arg RAPIDS_VER=$RAPIDS_VER --build-arg CUDA_VER=$CUDA_VER --build-arg LINUX_VER=$LINUX_VER --build-arg PYTHON_VER=$PYTHON_VER"

# Ouput build config
gpuci_logger "Build config info..."
echo "Build image and tag: ${BUILD_IMAGE}:${BUILD_TAG}"
echo "Build args: ${BUILD_ARGS}"
gpuci_logger "Docker build command..."
echo "docker build --pull -t ${BUILD_IMAGE}:${BUILD_TAG} ${BUILD_ARGS} -f ${DOCKER_FILE} ${IMAGE_NAME}/"

# Build image
gpuci_logger "Starting build..."
GPUCI_RETRY_MAX=1
GPUCI_RETRY_SLEEP=120
gpuci_retry docker build --pull -t ${BUILD_IMAGE}:${BUILD_TAG} ${BUILD_ARGS} -f ${IMAGE_NAME}/${DOCKER_FILE} ${IMAGE_NAME}/

# List image info
gpuci_logger "Displaying image info..."
docker images ${BUILD_IMAGE}:${BUILD_TAG}

# Upload image
gpuci_logger "Starting upload..."
GPUCI_RETRY_MAX=5
GPUCI_RETRY_SLEEP=120
gpuci_retry docker push ${BUILD_IMAGE}:${BUILD_TAG}

# Logout of docker
gpuci_logger "Logout of Docker..."
docker logout

# Clean up build
gpuci_logger "Clean up docker builds on system..."
docker system df
docker system prune --volumes -f
docker system df
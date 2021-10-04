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

BUILD_TAG="${RAPIDS_VER}-cuda${CUDA_VER}-devel-${LINUX_VER}-py${PYTHON_VER}"

# Setup BUILD_ARGS
case $RAPIDS_VER in
  "21.10")
    UCX_PY_VER="0.22"
    ;;
  "21.12")
    UCX_PY_VER="0.23"
    ;;
  *)
    echo "Unrecognized RAPIDS_VER: ${RAPIDS_VER}"
    exit 1
    ;;
esac
DOCKER_FILE="${BUILD_NAME}.Dockerfile"
BUILD_IMAGE="gpuci/${BUILD_NAME}"
BUILD_ARGS="--squash --build-arg RAPIDS_VER=$RAPIDS_VER --build-arg UCX_PY_VER=$UCX_PY_VER --build-arg CUDA_VER=$CUDA_VER --build-arg LINUX_VER=$LINUX_VER --build-arg PYTHON_VER=$PYTHON_VER"

# Output build config
gpuci_logger "Build config info..."
echo "Build image and tag: ${BUILD_IMAGE}:${BUILD_TAG}"
echo "Build args: ${BUILD_ARGS}"
gpuci_logger "Docker build command..."
echo "docker build --pull -t ${BUILD_IMAGE}:${BUILD_TAG} ${BUILD_ARGS} -f ${DOCKER_FILE} ${WORKSPACE}"

# Build image
gpuci_logger "Starting build..."
GPUCI_RETRY_MAX=1
GPUCI_RETRY_SLEEP=120
gpuci_retry docker build --pull -t ${BUILD_IMAGE}:${BUILD_TAG} ${BUILD_ARGS} -f ${DOCKER_FILE} ${WORKSPACE}

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

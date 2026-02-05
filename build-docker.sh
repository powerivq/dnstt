#!/bin/bash

# Build script for multi-architecture Docker images
# Supports arm64 and amd64 platforms

set -e

# Configuration
IMAGE_NAME="${IMAGE_NAME:-dnstt}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
PUSH="${PUSH:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== DNSTT Multi-Architecture Docker Build ===${NC}"
echo ""
echo "Configuration:"
echo "  Image Name: $IMAGE_NAME"
echo "  Image Tag: $IMAGE_TAG"
echo "  Platforms: $PLATFORMS"
echo "  Push: $PUSH"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed or not in PATH${NC}"
    exit 1
fi

# Check if buildx is available
if ! docker buildx version &> /dev/null; then
    echo -e "${RED}Error: Docker buildx is not available${NC}"
    echo "Please install Docker buildx or use Docker 19.03+"
    exit 1
fi

# Setup buildx builder if needed
BUILDER_NAME="dnstt-builder"
if ! docker buildx inspect $BUILDER_NAME &> /dev/null; then
    echo -e "${YELLOW}Creating buildx builder: $BUILDER_NAME${NC}"
    docker buildx create --name $BUILDER_NAME --use
fi

# Use the builder
docker buildx use $BUILDER_NAME
docker buildx inspect --bootstrap

# Build function
build_image() {
    local target=$1
    local image_suffix=$2
    local full_image_name="${IMAGE_NAME}-${image_suffix}:${IMAGE_TAG}"
    
    echo ""
    echo -e "${GREEN}Building $target image: $full_image_name${NC}"
    echo "Platforms: $PLATFORMS"
    
    local build_args="--platform $PLATFORMS --target $target -t $full_image_name"
    
    if [ "$PUSH" = "true" ]; then
        echo "Will push to registry after build"
        build_args="$build_args --push"
    else
        # For local builds, we can only load single platform
        if [[ "$PLATFORMS" == *","* ]]; then
            echo -e "${YELLOW}Warning: Multi-platform images cannot be loaded to local Docker.${NC}"
            echo -e "${YELLOW}Use PUSH=true to push to a registry, or specify single platform.${NC}"
            build_args="$build_args --output type=image"
        else
            build_args="$build_args --load"
        fi
    fi
    
    docker buildx build $build_args .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Successfully built $full_image_name${NC}"
    else
        echo -e "${RED}✗ Failed to build $full_image_name${NC}"
        exit 1
    fi
}

# Build server image
build_image "server" "server"

# Build client image
build_image "client" "client"

echo ""
echo -e "${GREEN}=== Build Complete ===${NC}"
echo ""
echo "Server image: ${IMAGE_NAME}-server:${IMAGE_TAG}"
echo "Client image: ${IMAGE_NAME}-client:${IMAGE_TAG}"
echo ""

if [ "$PUSH" = "true" ]; then
    echo -e "${GREEN}Images have been pushed to the registry${NC}"
else
    echo "To push images to a registry, run:"
    echo "  PUSH=true ./build-docker.sh"
    echo ""
    echo "Or use:"
    echo "  make docker-build-multiarch"
fi

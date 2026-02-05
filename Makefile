.PHONY: help build build-server build-client docker-build docker-build-server docker-build-client \
        docker-build-multiarch docker-push clean test

# Docker image configuration
DOCKER_REGISTRY ?= 
IMAGE_NAME ?= dnstt
IMAGE_TAG ?= latest
PLATFORMS ?= linux/amd64,linux/arm64

# Full image names
SERVER_IMAGE = $(DOCKER_REGISTRY)$(IMAGE_NAME)-server:$(IMAGE_TAG)
CLIENT_IMAGE = $(DOCKER_REGISTRY)$(IMAGE_NAME)-client:$(IMAGE_TAG)

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: build-server build-client ## Build both server and client binaries

build-server: ## Build server binary
	cd dnstt-server && go build -o ../bin/dnstt-server

build-client: ## Build client binary
	cd dnstt-client && go build -o ../bin/dnstt-client

docker-build: docker-build-server docker-build-client ## Build both Docker images for current platform

docker-build-server: ## Build server Docker image for current platform
	docker build --target server -t $(SERVER_IMAGE) .

docker-build-client: ## Build client Docker image for current platform
	docker build --target client -t $(CLIENT_IMAGE) .

docker-build-multiarch: ## Build and push multi-architecture images (amd64 and arm64)
	@echo "Building multi-architecture images for platforms: $(PLATFORMS)"
	docker buildx build --platform $(PLATFORMS) \
		--target server \
		-t $(SERVER_IMAGE) \
		--push .
	docker buildx build --platform $(PLATFORMS) \
		--target client \
		-t $(CLIENT_IMAGE) \
		--push .

docker-build-multiarch-local: ## Build multi-architecture images locally without pushing
	@echo "Building multi-architecture images for platforms: $(PLATFORMS)"
	docker buildx build --platform $(PLATFORMS) \
		--target server \
		-t $(SERVER_IMAGE) \
		--load .
	docker buildx build --platform $(PLATFORMS) \
		--target client \
		-t $(CLIENT_IMAGE) \
		--load .

docker-push: ## Push Docker images to registry
	docker push $(SERVER_IMAGE)
	docker push $(CLIENT_IMAGE)

test: ## Run tests
	go test -v ./...

clean: ## Clean build artifacts
	rm -rf bin/
	docker rmi -f $(SERVER_IMAGE) $(CLIENT_IMAGE) 2>/dev/null || true

# Setup Docker buildx for multi-arch builds
setup-buildx: ## Setup Docker buildx for multi-architecture builds
	docker buildx create --name dnstt-builder --use || docker buildx use dnstt-builder
	docker buildx inspect --bootstrap

# dnstt

DNS Tunnel with Docker support for arm64 and amd64 architectures.

## Features

- DNS tunnel server and client
- Multi-architecture Docker images (arm64 and amd64)
- Simple build system with Makefile
- Automated multi-arch builds with Docker buildx

## Building

### Local Go Binaries

Build both server and client:
```bash
make build
```

Build individual components:
```bash
make build-server
make build-client
```

### Docker Images

#### Single Architecture (current platform)

Build for your current platform:
```bash
make docker-build
```

Or build individual images:
```bash
make docker-build-server
make docker-build-client
```

#### Multi-Architecture (arm64 and amd64)

Build for both arm64 and amd64:
```bash
make docker-build-multiarch
```

Or use the build script:
```bash
./build-docker.sh
```

To push to a registry:
```bash
PUSH=true IMAGE_NAME=myregistry/dnstt ./build-docker.sh
```

### Setup Docker Buildx

If you haven't set up Docker buildx for multi-architecture builds:
```bash
make setup-buildx
```

## Running

### Server

Using Docker:
```bash
docker run -p 5300:5300/udp dnstt-server:latest -domain example.com
```

Using binary:
```bash
./bin/dnstt-server -domain example.com -udp :5300
```

### Client

Using Docker:
```bash
docker run -p 7000:7000 dnstt-client:latest -domain example.com
```

Using binary:
```bash
./bin/dnstt-client -domain example.com -listen 127.0.0.1:7000
```

## Build Configuration

### Environment Variables

- `IMAGE_NAME`: Docker image name (default: `dnstt`)
- `IMAGE_TAG`: Docker image tag (default: `latest`)
- `PLATFORMS`: Target platforms (default: `linux/amd64,linux/arm64`)
- `DOCKER_REGISTRY`: Docker registry prefix (optional)

### Examples

Build with custom image name:
```bash
IMAGE_NAME=my-dnstt make docker-build-multiarch
```

Build for specific platform:
```bash
PLATFORMS=linux/arm64 ./build-docker.sh
```

## Makefile Targets

- `make help` - Show all available targets
- `make build` - Build both server and client binaries
- `make docker-build` - Build Docker images for current platform
- `make docker-build-multiarch` - Build and push multi-arch images
- `make setup-buildx` - Setup Docker buildx
- `make clean` - Clean build artifacts
- `make test` - Run tests

## License

This project is provided as-is for educational and development purposes.
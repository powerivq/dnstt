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

### Using Docker Compose

The easiest way to run both server and client:

```bash
# Edit docker-compose.yml to configure your domain
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Server

Using Docker:
```bash
docker run -p 5300:5300/udp dnstt-server:latest -domain example.com -udp :5300
```

Using binary:
```bash
./bin/dnstt-server -domain example.com -udp :5300
```

### Client

Using Docker:
```bash
docker run -p 7000:7000 dnstt-client:latest -domain example.com -listen 0.0.0.0:7000
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

## CI/CD Integration

The repository includes a GitHub Actions workflow (`.github/workflows/docker-build.yml`) that automatically:
- Builds multi-architecture Docker images for both arm64 and amd64
- Pushes images to GitHub Container Registry (ghcr.io)
- Tags images based on branch, PR, or semantic version
- Runs on every push to main/master branches or on tags

To use it:
1. Enable GitHub Actions in your repository
2. Images will be published to `ghcr.io/OWNER/REPO-server:TAG` and `ghcr.io/OWNER/REPO-client:TAG`

## Docker Image Details

### Architecture Support
- **amd64** (x86_64): Intel/AMD 64-bit processors
- **arm64** (aarch64): ARM 64-bit processors (Raspberry Pi 4, Apple Silicon, AWS Graviton, etc.)

### Image Size
Both server and client images are approximately **1.88MB** each, built using multi-stage builds with a scratch base for minimal footprint.

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
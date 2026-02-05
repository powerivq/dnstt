# Multi-stage Dockerfile for dnstt-server and dnstt-client
# Supports both arm64 and amd64 architectures

# Build stage
FROM --platform=$BUILDPLATFORM golang:1.21-alpine AS builder

# Set working directory
WORKDIR /build

# Copy go mod files (go.sum may not exist if there are no external dependencies)
COPY go.mod go.sum* ./

# Download dependencies (if any)
RUN go mod download || true

# Copy source code
COPY . .

# Build arguments for cross-compilation
ARG TARGETARCH
ARG TARGETOS

# Build both server and client
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -ldflags="-w -s" -o /dnstt-server ./dnstt-server

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -ldflags="-w -s" -o /dnstt-client ./dnstt-client

# Final stage - server
FROM scratch AS server

COPY --from=builder /dnstt-server /dnstt-server

EXPOSE 5300/udp

ENTRYPOINT ["/dnstt-server"]

# Final stage - client
FROM scratch AS client

COPY --from=builder /dnstt-client /dnstt-client

EXPOSE 7000

ENTRYPOINT ["/dnstt-client"]

## Container Deployment with Docker


**Containerization Advantages** Go applications compile to single static binaries, eliminating dependency management complexities in containerized environments. This characteristic enables the creation of minimal container images, often based on scratch or distroless base images, resulting in significantly reduced attack surfaces and faster deployment times.

**Multi-stage Docker Builds** The standard approach involves multi-stage builds where Go compilation occurs in a builder stage with the full Go toolkit, while the final runtime stage contains only the compiled binary. This pattern reduces final image sizes from hundreds of megabytes to single-digit megabytes.

```dockerfile
# Builder stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Runtime stage
FROM scratch
COPY --from=builder /app/main /
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
EXPOSE 8080
CMD ["/main"]
```

**Container Optimization Techniques** Static linking ensures Go binaries run without external dependencies. The `CGO_ENABLED=0` flag prevents dynamic linking to C libraries, creating truly portable binaries. Build flags like `-ldflags="-s -w"` strip debug information, further reducing binary size.

**Security Considerations** Distroless images provide minimal runtime environments with essential libraries while excluding package managers and shells that could be exploited. Alpine-based images offer a middle ground with slightly larger sizes but additional debugging capabilities when needed.


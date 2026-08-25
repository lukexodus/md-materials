## Building Images


```bash
# Basic build (uses Dockerfile in current directory)
docker build -t myapp:1.0 .

# Specify a different Dockerfile
docker build -f Dockerfile.prod -t myapp:prod .

# Pass build arguments
docker build --build-arg APP_VERSION=2.0 -t myapp:2.0 .

# Target a specific stage in a multi-stage build
docker build --target builder -t myapp-builder .

# Build with no cache
docker build --no-cache -t myapp:fresh .

# Build for a specific platform (cross-compilation)
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:multi --push .
```

---


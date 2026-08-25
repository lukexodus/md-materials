## BuildKit and Buildx


BuildKit is the modern build backend for Docker. It is enabled by default in recent Docker versions and provides faster builds, better caching, and additional features.

### Enable BuildKit (older Docker versions)

```bash
DOCKER_BUILDKIT=1 docker build -t myapp .
```

### Buildx for Multi-Platform Builds

Buildx is a CLI plugin that extends `docker build` with BuildKit features, including cross-platform builds:

```bash
# Create a builder that supports multi-platform builds
docker buildx create --use --name multibuilder

# Build for multiple platforms and push
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t yourusername/myapp:1.0 \
  --push .
```

### Cache Mounts in BuildKit

BuildKit supports mounting a cache directory across builds, which can dramatically speed up dependency installation:

```dockerfile
# syntax=docker/dockerfile:1
RUN --mount=type=cache,target=/root/.npm \
    npm ci
```

### Secret Mounts

Pass secrets into a build without including them in the image:

```dockerfile
# syntax=docker/dockerfile:1
RUN --mount=type=secret,id=mysecret \
    cat /run/secrets/mysecret
```

```bash
docker build --secret id=mysecret,src=./secret.txt .
```

---


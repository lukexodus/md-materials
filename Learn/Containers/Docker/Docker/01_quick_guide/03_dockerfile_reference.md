## Dockerfile Reference


### Basic Structure

```dockerfile
# Use an official base image
FROM node:20-alpine

# Set working directory inside the container
WORKDIR /app

# Copy dependency manifests first (for layer caching)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --omit=dev

# Copy application source
COPY . .

# Expose the port the app listens on
EXPOSE 3000

# Default command to run
CMD ["node", "server.js"]
```

### Key Instructions

**FROM** — sets the base image. Every Dockerfile must start with `FROM` (except multi-stage builds which can have multiple).

```dockerfile
FROM ubuntu:22.04
FROM python:3.12-slim
FROM scratch   # empty base, for statically compiled binaries
```

**RUN** — executes a shell command during build time and commits the result as a new layer.

```dockerfile
RUN apt-get update && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*
```

Chaining commands with `&&` in one `RUN` instruction keeps them in a single layer, which reduces image size.

**COPY** — copies files from the build context (your local machine) into the image.

```dockerfile
COPY src/ /app/src/
COPY --chown=node:node . .
```

**ADD** — similar to `COPY` but also supports URLs and auto-extracts `.tar` archives. Prefer `COPY` for clarity unless you specifically need `ADD`'s extra features.

**ENV** — sets environment variables available at both build time and runtime.

```dockerfile
ENV NODE_ENV=production
ENV PORT=3000
```

**ARG** — defines build-time variables passed with `--build-arg`. Not available at runtime.

```dockerfile
ARG APP_VERSION=1.0.0
RUN echo "Building version $APP_VERSION"
```

**WORKDIR** — sets (and creates if needed) the working directory for subsequent instructions.

**EXPOSE** — documents which port the container listens on. It does not publish the port; that is done with `-p` at runtime.

**CMD** — the default command run when the container starts. It can be overridden at `docker run` time. Only the last `CMD` takes effect.

```dockerfile
CMD ["python", "app.py"]          # exec form (preferred)
CMD python app.py                  # shell form
```

**ENTRYPOINT** — sets the executable that always runs. Arguments from `CMD` (or from `docker run`) are appended to it.

```dockerfile
ENTRYPOINT ["gunicorn"]
CMD ["--workers=4", "app:app"]
```

**USER** — sets the user for subsequent instructions and the container runtime. Running as a non-root user is a security best practice.

```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

**VOLUME** — declares a mount point for external storage. Data written here persists beyond the container lifecycle if a named volume or bind mount is attached.

```dockerfile
VOLUME ["/data"]
```

**HEALTHCHECK** — instructs Docker to periodically test whether the container is healthy.

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

**LABEL** — adds metadata to an image.

```dockerfile
LABEL maintainer="you@example.com"
LABEL version="1.0"
```

### Multi-Stage Builds

Multi-stage builds let you use one image to compile or build artifacts and a separate, smaller image to run them. Only the final stage is included in the output image.

```dockerfile
# Stage 1: build
FROM golang:1.22 AS builder
WORKDIR /src
COPY . .
RUN go build -o /app/server .

# Stage 2: run
FROM alpine:3.19
COPY --from=builder /app/server /usr/local/bin/server
EXPOSE 8080
CMD ["server"]
```

This pattern is common for compiled languages (Go, Rust, Java, C++) where the build toolchain is not needed at runtime.

### .dockerignore

A `.dockerignore` file at the root of the build context excludes files from being sent to the daemon. This speeds up builds and prevents secrets from being inadvertently included.

```
.git
node_modules
*.log
.env
__pycache__
```

---


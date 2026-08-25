## Writing a Dockerfile


The `Dockerfile` is the source of truth for how an image is built. It is a plain-text file containing a sequence of instructions.

### Common Instructions

```dockerfile
# Base image — always pin to a specific tag in production
FROM node:20-alpine

# Set a working directory inside the container
WORKDIR /app

# Copy dependency manifests first to leverage layer caching
COPY package*.json ./

# Install dependencies
RUN npm ci --omit=dev

# Copy the rest of the source code
COPY . .

# Expose the port the app listens on (documentation only — does not publish the port)
EXPOSE 3000

# Default command to run when the container starts
CMD ["node", "src/index.js"]
```

### Multi-Stage Builds

Multi-stage builds allow you to use a heavier image for building/compiling and copy only the final artifact into a lean runtime image. This keeps production images small and free of build tools.

```dockerfile
# Stage 1: Build
FROM golang:1.22-alpine AS builder
WORKDIR /build
COPY . .
RUN go build -o app ./cmd/server

# Stage 2: Runtime
FROM alpine:3.19
WORKDIR /app
COPY --from=builder /build/app .
CMD ["./app"]
```

### Layer Caching Best Practices

Place instructions that change infrequently (installing system packages, copying dependency manifests) before instructions that change often (copying source code). This maximizes cache reuse and speeds up rebuilds.

### .dockerignore

A `.dockerignore` file works like `.gitignore` and prevents files from being sent to the build context, which speeds up builds and prevents secrets from leaking into images.

```
node_modules
.git
*.env
dist
```

### Base Image Selection

- Use official images from Docker Hub as a starting point.
- Alpine-based images are smaller but use `musl libc`, which can cause compatibility issues with some binaries.
- `slim` variants of Debian/Ubuntu-based images are a middle ground.
- Scratch or distroless images are used for compiled binaries when minimal attack surface is a priority.

Always pin base image tags (e.g., `node:20.11.0-alpine3.19`) in production Dockerfiles. Floating tags like `latest` can introduce unexpected changes.

---


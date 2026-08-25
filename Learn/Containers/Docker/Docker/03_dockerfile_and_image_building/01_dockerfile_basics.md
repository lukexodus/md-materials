## Dockerfile Basics


### Introduction to Dockerfiles

A Dockerfile is a text file containing a series of instructions that define how a Docker image should be built. It serves as a blueprint for creating containers, ensuring consistency across development, testing, and production environments. Each instruction in a Dockerfile creates a new layer in the image, making the build process incremental and efficient.

**Key Points**:

- Dockerfiles automate the process of creating Docker images
- They follow a specific syntax that Docker understands
- Each instruction creates a new layer in the resulting image
- Dockerfiles are the foundation of Docker's build system

### Dockerfile Syntax and Structure

Dockerfiles use a simple, declarative syntax. Each line typically contains a single instruction followed by arguments. Instructions are executed in order, from top to bottom.

```dockerfile
# Comment
INSTRUCTION arguments
```

Instructions are case-insensitive but conventionally written in uppercase to distinguish them from arguments. Comments begin with `#` and can appear on their own line or after an instruction.

**Example**:

```dockerfile
# Base image
FROM ubuntu:22.04

# Set working directory
WORKDIR /app

# Copy application files
COPY . .

# Set environment variable
ENV PORT=8080

# Run command
RUN apt-get update && apt-get install -y python3

# Command to run when container starts
CMD ["python3", "app.py"]
```

### Common Dockerfile Instructions

#### FROM Instruction

FROM specifies the base image from which you are building. It's typically the first instruction in a Dockerfile (except when using ARG before FROM).

```dockerfile
FROM <image>[:<tag>] [AS <name>]
```

**Example**:

```dockerfile
FROM node:18-alpine
```

The FROM instruction initializes a new build stage and sets the base image. You can use multiple FROM instructions to create multi-stage builds, which can significantly reduce the final image size.

#### RUN Instruction

RUN executes commands in a new layer on top of the current image and commits the results. It's used for installing packages, compiling code, or any other command-line operations.

```dockerfile
RUN <command>
# or
RUN ["executable", "param1", "param2"]
```

**Example**:

```dockerfile
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

Best practice is to combine related commands into a single RUN instruction using `&&` and `\` line continuations to reduce the number of layers and image size.

#### COPY and ADD Instructions

Both COPY and ADD instructions add files from the build context to the image.

```dockerfile
COPY <src>... <dest>
ADD <src>... <dest>
```

**Example**:

```dockerfile
COPY package.json package-lock.json ./
COPY src/ ./src/
```

COPY is simpler and preferred for most cases. ADD has additional features:

- It can handle URL sources
- It automatically extracts local tar archives

```dockerfile
ADD https://example.com/file.tar.gz /opt/
```

#### WORKDIR Instruction

WORKDIR sets the working directory for any subsequent RUN, CMD, ENTRYPOINT, COPY, and ADD instructions.

```dockerfile
WORKDIR /path/to/directory
```

**Example**:

```dockerfile
WORKDIR /app
```

Using WORKDIR instead of complex `cd` commands makes Dockerfiles cleaner and more readable. Each WORKDIR instruction creates a new layer if the directory doesn't exist.

#### ENV Instruction

ENV sets environment variables that persist when a container is run from the resulting image.

```dockerfile
ENV <key>=<value> ...
```

**Example**:

```dockerfile
ENV NODE_ENV=production \
    PORT=3000
```

Environment variables can be referenced in subsequent instructions using `$variable_name` or `${variable_name}`.

#### ARG Instruction

ARG defines variables that users can pass at build-time using the `--build-arg` flag.

```dockerfile
ARG <name>[=<default value>]
```

**Example**:

```dockerfile
ARG VERSION=latest
FROM node:${VERSION}
```

Unlike ENV, ARG values are not available after the image is built. ARG is the only instruction that can precede FROM.

#### EXPOSE Instruction

EXPOSE informs Docker that the container listens on specified network ports at runtime.

```dockerfile
EXPOSE <port> [<port>/<protocol>...]
```

**Example**:

```dockerfile
EXPOSE 80/tcp 443/tcp
```

EXPOSE doesn't actually publish the ports. It functions as documentation for which ports are intended to be published. You still need to use `-p` or `-P` when running the container.

#### VOLUME Instruction

VOLUME creates a mount point and marks it as holding externally mounted volumes.

```dockerfile
VOLUME ["/data"]
```

**Example**:

```dockerfile
VOLUME /var/log /var/db
```

Volumes help with data persistence, sharing data between containers, and separating data from the container lifecycle.

#### ENTRYPOINT Instruction

ENTRYPOINT configures a container to run as an executable.

```dockerfile
ENTRYPOINT ["executable", "param1", "param2"]
# or
ENTRYPOINT command param1 param2
```

**Example**:

```dockerfile
ENTRYPOINT ["nginx", "-g", "daemon off;"]
```

The executable form (using JSON array) is preferred as it doesn't invoke a command shell, which can avoid shell string munging.

#### CMD Instruction

CMD provides defaults for executing a container. There can only be one CMD in a Dockerfile.

```dockerfile
CMD ["executable","param1","param2"]
# or
CMD command param1 param2
```

**Example**:

```dockerfile
CMD ["node", "server.js"]
```

When used with ENTRYPOINT, CMD provides default arguments:

```dockerfile
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
```

### Building Images with Docker Build

The `docker build` command builds an image from a Dockerfile and a context (usually the current directory).

```bash
docker build [OPTIONS] PATH | URL | -
```

**Example**:

```bash
docker build -t myapp:1.0 .
```

**Key Options**:

- `-t, --tag`: Name and optionally tag the image
- `-f, --file`: Specify the Dockerfile (default is PATH/Dockerfile)
- `--no-cache`: Don't use cache when building
- `--build-arg`: Set build-time variables

**Output**:

```
Sending build context to Docker daemon  2.048kB
Step 1/7 : FROM node:18-alpine
 ---> 5890f49fb1c9
Step 2/7 : WORKDIR /app
 ---> Using cache
 ---> 8d1da34b20ec
Step 3/7 : COPY package*.json ./
 ---> Using cache
 ---> e5c891b7e7b7
Step 4/7 : RUN npm install
 ---> Using cache
 ---> 4d92f4ce4dad
Step 5/7 : COPY . .
 ---> a7bda54c29da
Step 6/7 : EXPOSE 3000
 ---> Running in 32f87f9c7a21
Removing intermediate container 32f87f9c7a21
 ---> 6e5a7c0b14a2
Step 7/7 : CMD ["npm", "start"]
 ---> Running in 8f875d78c0c6
Removing intermediate container 8f875d78c0c6
 ---> 0773ae9b49e0
Successfully built 0773ae9b49e0
Successfully tagged myapp:1.0
```

### Dockerfile Best Practices

#### Minimize Layers

Docker builds images layer by layer, where each layer adds to the size of the image. Minimize the number of layers by combining related commands.

```dockerfile
# Inefficient - creates multiple layers
RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get clean

# Better - creates a single layer
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

#### Use Multi-stage Builds

Multi-stage builds allow you to use multiple FROM statements in your Dockerfile. Each FROM instruction can use a different base image, and begins a new stage of the build.

```dockerfile
# Build stage
FROM golang:1.18 AS builder
WORKDIR /app
COPY . .
RUN go build -o main .

# Final stage
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/main .
CMD ["./main"]
```

This approach results in a much smaller final image without the build tools.

#### Leverage Build Cache

Docker caches intermediate layers to speed up builds. Order your instructions from least to most frequently changing to maximize cache usage.

```dockerfile
# Put dependency installation before code copy
COPY package.json package-lock.json ./
RUN npm install
# Only after dependencies are installed, copy the code
COPY . .
```

This way, if your code changes but dependencies don't, Docker can reuse the cached layers for dependency installation.

#### Use .dockerignore File

Create a `.dockerignore` file to exclude files and directories from the build context, similar to `.gitignore`.

```
node_modules
npm-debug.log
.git
.gitignore
.env
```

This reduces the build context size and prevents unnecessary files from being included in the image.

#### Set Default Environment Variables and Arguments

Provide sensible defaults for environment variables and build arguments.

```dockerfile
ARG NODE_VERSION=18
FROM node:${NODE_VERSION}-alpine

ENV NODE_ENV=production \
    PORT=3000
```

#### Use Specific Tags for Base Images

Avoid using `latest` tags for base images, which can lead to unexpected changes. Use specific version tags instead.

```dockerfile
# Not recommended
FROM ubuntu:latest

# Better
FROM ubuntu:22.04
```

#### Minimize Number of RUN Instructions

Each RUN instruction creates a new layer. Combine commands to reduce the number of layers and make the Dockerfile more maintainable.

#### Use Proper Permissions

Avoid running containers as root. Use the USER instruction to switch to a non-root user.

```dockerfile
RUN useradd -r appuser
USER appuser
```

#### Use ENTRYPOINT for Executable Containers

Use ENTRYPOINT for containers that should behave like executables, and CMD for providing default arguments.

```dockerfile
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
```

#### Keep Images Small

Choose minimal base images like alpine or distroless images when possible.

```dockerfile
FROM node:18-alpine
# vs
FROM node:18
```

The alpine version is typically much smaller than the full distribution.

### Advanced Dockerfile Concepts

#### Health Checks

The HEALTHCHECK instruction tells Docker how to test a container to check if it's still working.

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1
```

#### Shell and Exec Form

Most Dockerfile instructions that take arguments have two forms:

- Shell form: `RUN apt-get update`
- Exec form: `RUN ["apt-get", "update"]`

The exec form is preferred as it:

- Doesn't invoke a shell
- Allows for precise control over the executable and arguments
- Processes signals properly

#### Using Build Arguments for Flexibility

Build arguments make your Dockerfile more flexible:

```dockerfile
ARG VERSION=3.9
FROM python:${VERSION}

ARG USER_ID=1000
RUN useradd -m -u ${USER_ID} appuser
```

Build with: `docker build --build-arg VERSION=3.10 --build-arg USER_ID=1001 -t myapp .`

### Related Topics

- Docker Compose for multi-container applications
- Docker Swarm and Kubernetes for container orchestration
- Container security best practices
- Docker image optimization techniques
- Continuous Integration/Continuous Deployment with Docker

---


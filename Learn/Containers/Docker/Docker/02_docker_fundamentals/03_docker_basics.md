## Docker Basics


### Running Your First Container

Docker containers are launched using the `docker run` command, which creates and starts a container from a Docker image.

**Syntax:**

```
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

**Basic Example:**

```bash
docker run hello-world
```

This command pulls the hello-world image from Docker Hub (if not available locally) and runs it, displaying a welcome message.

**Common Options:**

- `-d, --detach`: Run container in background
- `-p, --publish`: Map container ports to host
- `-v, --volume`: Mount a volume
- `-e, --env`: Set environment variables
- `--name`: Assign a name to the container
- `--rm`: Automatically remove container when it exits

**Interactive Containers:**

```bash
docker run -it ubuntu bash
```

The `-it` flags combine:

- `-i`: Keep STDIN open (interactive)
- `-t`: Allocate a pseudo-TTY

This launches an Ubuntu container with an interactive bash shell.

**Port Mapping:**

```bash
docker run -p 8080:80 nginx
```

Maps port 80 in the container to port 8080 on the host, making the Nginx server accessible at http://localhost:8080.

**Volume Mounting:**

```bash
docker run -v $(pwd):/app node:16 node /app/server.js
```

Mounts the current directory to /app inside the container.

**Environment Variables:**

```bash
docker run -e DATABASE_URL=postgres://localhost postgres
```

**Resource Constraints:**

```bash
docker run --memory=512m --cpus=2 redis
```

**Key Points:**

- `docker run` combines `docker create` and `docker start` operations
- Each container gets a unique ID and an optional name
- Containers are isolated but can connect to the host via ports and volumes
- Without `-d`, the terminal attaches to the container's standard output

### Container Lifecycle Management

Docker containers follow a well-defined lifecycle from creation to removal, with several possible states along the way.

#### Container States

- **Created**: Container is created but not started
- **Running**: Container is executing
- **Paused**: Container execution is temporarily suspended
- **Stopped**: Container execution has stopped
- **Deleted**: Container is removed from the system

#### Lifecycle Commands

- `docker create`: Create a container without starting it
- `docker start`: Start a created/stopped container
- `docker stop`: Gracefully stop a running container
- `docker kill`: Force stop a container immediately
- `docker pause`: Suspend all processes in a container
- `docker unpause`: Resume a paused container
- `docker restart`: Restart a container
- `docker rm`: Remove a stopped container

**Example Lifecycle:**

```bash
# Create a container
docker create --name mycontainer nginx

# Start the container
docker start mycontainer

# Pause the container
docker pause mycontainer

# Resume the container
docker unpause mycontainer

# Stop the container
docker stop mycontainer

# Remove the container
docker rm mycontainer
```

#### Stop vs Kill

- `docker stop`: Sends SIGTERM signal, allowing graceful shutdown (default timeout: 10s)
- `docker kill`: Sends SIGKILL signal, forcing immediate termination

**Viewing Container Status:**

```bash
docker ps        # List running containers
docker ps -a     # List all containers (including stopped)
```

**Container Exit Codes:**

- Exit code 0: Success
- Non-zero exit code: Error or application-specific code

**Auto-Restart Policies:**

```bash
docker run --restart=always redis
```

Restart policies:

- `no`: Default - never restart automatically
- `on-failure[:max-retries]`: Restart if container exits with non-zero code
- `always`: Always restart regardless of exit status
- `unless-stopped`: Always restart unless explicitly stopped

**Key Points:**

- Containers are ephemeral by design
- Data in containers is lost when removed unless volumes are used
- Proper lifecycle management is essential for robust containerized applications
- Use restart policies for service reliability

### Managing Images

Docker images are read-only templates used to create containers. They contain the application code, runtime, libraries, and dependencies needed to run the application.

#### Pulling Images

`docker pull` downloads images from a registry (Docker Hub by default).

**Syntax:**

```bash
docker pull [OPTIONS] NAME[:TAG|@DIGEST]
```

**Examples:**

```bash
docker pull ubuntu             # Latest Ubuntu image
docker pull ubuntu:20.04       # Specific version via tag
docker pull redis@sha256:a4...  # Specific version via digest
docker pull myregistry.com/myimage # From custom registry
```

**Pull Options:**

- `--all-tags`: Pull all tagged images
- `--platform`: Specify platform (e.g., linux/amd64, linux/arm64)
- `--quiet`: Suppress verbose output

#### Building Images

`docker build` creates new images from a Dockerfile.

**Syntax:**

```bash
docker build [OPTIONS] PATH | URL | -
```

**Examples:**

```bash
docker build -t myapp:1.0 .    # Build from current directory
docker build -f Dockerfile.dev . # Specify alternate Dockerfile
docker build --no-cache .      # Force rebuild without cache
```

**Build Context:** The PATH argument defines the build context - files accessible during build.

**Build Options:**

- `-t, --tag`: Name and optionally tag the image
- `--no-cache`: Don't use cache during build
- `--build-arg`: Set build-time variables
- `--target`: Build specific stage in multi-stage builds

#### Pushing Images

`docker push` uploads images to a registry.

**Syntax:**

```bash
docker push [OPTIONS] NAME[:TAG]
```

**Examples:**

```bash
docker tag myapp:1.0 username/myapp:1.0  # Tag for Docker Hub
docker push username/myapp:1.0           # Push to Docker Hub

docker tag myapp:1.0 registry.example.com/myapp:1.0  # Tag for private registry
docker push registry.example.com/myapp:1.0           # Push to private registry
```

**Authentication:**

```bash
docker login [SERVER]  # Log in to registry before pushing
```

#### Removing Images

`docker rmi` (or `docker image rm`) removes images from the local system.

**Syntax:**

```bash
docker rmi [OPTIONS] IMAGE [IMAGE...]
```

**Examples:**

```bash
docker rmi nginx                 # Remove by name
docker rmi 3f8a00f137a0          # Remove by ID
docker rmi $(docker images -q)   # Remove all images
docker rmi -f myapp:1.0          # Force removal
```

**Key Points:**

- Images are referenced by repository:tag or by SHA256 digest
- Default tag is "latest" if not specified
- Images can't be deleted if used by containers
- Use `-f` to force removal (use with caution)

#### Image Management Commands

```bash
docker images           # List all images
docker image ls         # List all images (alternative)
docker image prune      # Remove unused images
docker image history    # Show image layer history
docker image inspect    # Display detailed image information
```

**Tag Management:**

```bash
docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
```

**Image Size Optimization:**

- Use smaller base images (alpine vs ubuntu)
- Combine RUN commands to reduce layers
- Use multi-stage builds
- Clean up package caches

**Key Points:**

- Images are immutable; changes create new layers
- Layers are cached and reused for efficiency
- Properly tagging images is essential for versioning
- Registries store and distribute images

### Working with Containers

Once containers are running, Docker provides multiple commands to manage and interact with them.

#### Starting and Stopping Containers

```bash
# Start one or more stopped containers
docker start container1 [container2...]

# Stop one or more running containers (graceful shutdown)
docker stop container1 [container2...]
docker stop $(docker ps -q)  # Stop all running containers

# Restart containers
docker restart container1 [container2...]
```

**Options:**

- `-t, --time`: Seconds to wait for stop before killing (default: 10)
- `-a, --attach`: Attach STDOUT/STDERR when using start

#### Removing Containers

```bash
# Remove stopped containers
docker rm container1 [container2...]

# Force remove running containers
docker rm -f container1 [container2...]

# Remove all stopped containers
docker container prune

# Run and automatically remove when done
docker run --rm alpine echo "hello world"
```

**Options:**

- `-f, --force`: Force removal of running containers
- `-v, --volumes`: Remove associated anonymous volumes

#### Executing Commands in Running Containers

`docker exec` runs a command in a running container.

**Syntax:**

```bash
docker exec [OPTIONS] CONTAINER COMMAND [ARG...]
```

**Examples:**

```bash
# Run interactive bash shell
docker exec -it my_container bash

# Execute a command and return
docker exec my_container ls -la /app

# Run as different user
docker exec -u postgres my_container psql
```

**Common Options:**

- `-i, --interactive`: Keep STDIN open
- `-t, --tty`: Allocate a pseudo-TTY
- `-e, --env`: Set environment variables
- `-w, --workdir`: Working directory inside container
- `-u, --user`: Username or UID

#### Copying Files Between Container and Host

```bash
# Copy from host to container
docker cp ./local/file.txt container_name:/path/in/container/

# Copy from container to host
docker cp container_name:/path/in/container/file.txt ./local/
```

#### Renaming Containers

```bash
docker rename old_name new_name
```

#### Managing Container Resources

```bash
# Update container configuration
docker update --memory 512m --cpus 0.5 container_name
```

**Key Points:**

- Container names must be unique on a host
- Use meaningful container names for easier management
- Killing containers may lead to data loss if not properly managed
- Exec is helpful for debugging but shouldn't replace proper logging

### Container Inspection and Logs

Docker provides several tools to monitor and troubleshoot containers.

#### Viewing Container Information

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Show container details in JSON format
docker inspect container_name

# Get specific information using format
docker inspect --format='{{.NetworkSettings.IPAddress}}' container_name
```

**Common `docker ps` Options:**

- `-a, --all`: Show all containers (default shows just running)
- `-q, --quiet`: Only display container IDs
- `-s, --size`: Display total file sizes
- `--format`: Format output using Go template
- `-n, --last`: Show n last created containers

**Example Custom Format:**

```bash
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
```

#### Accessing Container Logs

`docker logs` fetches logs from a container.

**Syntax:**

```bash
docker logs [OPTIONS] CONTAINER
```

**Examples:**

```bash
# View all logs
docker logs my_container

# Follow log output (like tail -f)
docker logs -f my_container

# Show only last 100 lines
docker logs --tail 100 my_container

# Show logs since timestamp or relative time
docker logs --since 2023-01-01T10:00:00 my_container
docker logs --since 30m my_container
```

**Options:**

- `-f, --follow`: Follow log output
- `--since`: Show logs since timestamp or relative time
- `--until`: Show logs before timestamp or relative time
- `--tail`: Number of lines to show from the end
- `-t, --timestamps`: Show timestamps

#### Monitoring Container Stats

```bash
# Display live stream of container resource usage statistics
docker stats [container_name]

# Display stats for all containers
docker stats
```

**Example Output:**

```
CONTAINER ID   NAME            CPU %     MEM USAGE / LIMIT   MEM %     NET I/O         BLOCK I/O        PIDS
3f2d4d7c924e   my_container    0.10%     15.54MiB / 7.772GiB 0.20%     1.2kB / 0B      0B / 8.19kB      1
```

#### Viewing Container Processes

```bash
# Show running processes in a container
docker top my_container
```

#### Events and Health Checks

```bash
# Stream real-time events from the Docker daemon
docker events --filter 'container=my_container'

# Define health check when running container
docker run --health-cmd="curl -f http://localhost/ || exit 1" nginx
```

#### Container Diff

View changes to files and directories in a container's filesystem:

```bash
docker diff my_container
```

Output prefixes:

- A: Added
- D: Deleted
- C: Changed

**Key Points:**

- Logs stored in `/var/lib/docker/containers/<container-id>` on host
- Container log drivers can be configured (json-file, syslog, etc.)
- Large log files can impact performance
- Use log rotation in production environments

### Container Networking Basics

```bash
# List networks
docker network ls

# Inspect network
docker network inspect bridge

# Create a custom network
docker network create my_network

# Connect container to network
docker network connect my_network my_container

# Run container in specific network
docker run --network=my_network nginx
```

**Network Types:**

- `bridge`: Default network for containers
- `host`: Container uses host's network stack
- `none`: No networking
- `overlay`: Multi-host networking
- Custom networks: User-defined bridge networks

**Key Points:**

- Containers on the same network can communicate by name
- Custom networks provide better isolation
- Expose ports to make services available to the host
- Each container has its own IP address

### Related Topics

- Docker Volume Management: Persistent data storage
- Docker Networking In-depth: Advanced networking concepts
- Docker Compose: Managing multi-container applications
- Dockerfile Creation: Building custom images
- Docker Security Best Practices: Securing containers

---


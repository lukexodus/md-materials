## Container Management


### Container Resource Constraints (CPU, Memory)

Docker allows you to control the amount of system resources containers can use, which is crucial for stable performance in multi-container environments and preventing resource starvation.

**Key Points:**

- Resource constraints can be set at container creation with `docker run` flags
- Memory limits are hard constraints that can cause container termination if exceeded
- CPU limits act as relative weights in contention scenarios
- Both runtime constraints and default resource allocation can be configured
- Container orchestrators like Kubernetes build on these basic constraints

Memory constraints are specified in bytes or with suffixes (k, m, g, etc.) and include:

```bash
# Limit memory to 512MB
docker run --memory="512m" nginx

# Set memory reservation (soft limit) to 256MB
docker run --memory-reservation="256m" nginx

# Limit swap usage to 1GB
docker run --memory-swap="1g" nginx
```

CPU constraints include:

```bash
# Limit to use of 1.5 CPUs
docker run --cpus="1.5" nginx

# Set relative CPU priority weight (default is 1024)
docker run --cpu-shares="512" nginx

# Restrict container to specific CPUs/cores
docker run --cpuset-cpus="0,2" nginx
```

**Example:** For a production web application with a database:

```bash
# Web server with moderate CPU priority but limited memory
docker run --cpu-shares=768 --memory=256m --restart=always -d nginx

# Database with higher memory limits and CPU priority
docker run --cpu-shares=1280 --memory=1g --memory-reservation=512m --restart=always -d postgres
```

### Container Networking Basics

Docker provides several networking options to enable containers to communicate with each other and with external networks.

**Key Points:**

- Docker creates three default networks: bridge, host, and none
- Bridge is the default network mode for containers
- Custom networks can be created for better isolation and DNS resolution
- Port mapping exposes container services to the host
- Docker manages DNS resolution between containers on the same network
- Containers on the same network can communicate by container name

Network types:

- **Bridge**: Isolated network on the host, containers can communicate (default)
- **Host**: Container shares host's network stack, no isolation
- **None**: Disables networking for container
- **Overlay**: Multi-host networking for Docker Swarm
- **Macvlan**: Assigns MAC address to container, appears as physical device

**Example:** Creating a custom network and connecting containers:

```bash
# Create a custom network
docker network create myapp-network

# Start containers on this network
docker run --name db --network myapp-network -d postgres
docker run --name web --network myapp-network -d nginx

# The web container can now connect to the db using the hostname "db"
```

Port mapping:

```bash
# Map container port 80 to host port 8080
docker run -p 8080:80 nginx

# Map UDP port
docker run -p 53:53/udp dns-server

# Map to specific host interface
docker run -p 127.0.0.1:8080:80 nginx
```

### Environment Variables

Environment variables provide a way to pass configuration to containers at runtime, allowing for flexible deployments across different environments.

**Key Points:**

- Set with `-e` or `--env` flags in `docker run`
- Can be loaded from a file using `--env-file`
- Often used to configure applications without rebuilding images
- Docker Compose allows setting variables in `docker-compose.yml`
- Sensitive data should be handled with Docker secrets or external vaults
- Default environment variables can be defined in Dockerfile with `ENV`

**Example:** Setting individual variables:

```bash
docker run -e DB_HOST=postgres -e DB_PASSWORD=secret -d myapp
```

Using an environment file:

```bash
# content of env-file
DB_HOST=postgres
DB_USER=admin
DB_PASSWORD=secret
DEBUG=false

# Run with env file
docker run --env-file ./env-file -d myapp
```

In a Dockerfile:

```dockerfile
FROM node:14
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE $PORT
# ...
```

### Working with Shell Inside Containers

Interacting with running containers through a shell is essential for debugging, monitoring, and performing administrative tasks.

**Key Points:**

- Use `docker exec` to run commands in running containers
- Interactive shells require the `-i` and `-t` flags
- You can specify a different user with `-u` flag
- Default shell is often `/bin/sh` or `/bin/bash` if available
- For some minimal containers, you may need to install a shell first
- One-off commands can be run without interactive mode

**Example:** Accessing an interactive shell:

```bash
# Bash shell (if available in the container)
docker exec -it my-container bash

# If bash isn't available, try sh
docker exec -it my-container sh
```

Running specific commands:

```bash
# Check running processes
docker exec my-container ps aux

# View log files
docker exec my-container cat /var/log/nginx/error.log

# Run as a specific user
docker exec -u postgres my-database psql
```

Installing tools in minimal containers:

```bash
# For Alpine-based images
docker exec -it alpine-container sh
/ # apk add --no-cache bash curl
/ # bash
```

### Container Monitoring and Inspection

Monitoring container performance and inspecting their configuration is critical for troubleshooting issues and optimizing resource usage.

**Key Points:**

- Real-time statistics with `docker stats`
- Detailed configuration with `docker inspect`
- Log access with `docker logs`
- Container events with `docker events`
- Process list with `docker top`
- More advanced monitoring through external tools
- Health checks can be configured to automatically monitor container status

Basic monitoring commands:

```bash
# Show running processes in container
docker top my-container

# Display resource usage statistics
docker stats my-container

# Get container logs
docker logs my-container
docker logs --tail=100 my-container  # Last 100 lines
docker logs --follow my-container     # Stream logs

# Show detailed container info (JSON format)
docker inspect my-container
```

**Example:** Extracting specific information with inspect:

```bash
# Get IP address
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' my-container

# Check restart policy
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' my-container

# Check environment variables
docker inspect -f '{{.Config.Env}}' my-container
```

### Container Lifecycle Management

Understanding and controlling container lifecycle is fundamental to effective container management.

**Key Points:**

- Containers have distinct states: created, running, paused, stopped, deleted
- Restart policies determine behavior on failure or host restart
- Container exit codes provide information about termination reasons
- Containers can be configured for auto-removal after stopping
- Cleanup commands help manage stopped containers
- Container naming helps with identification and reference

Basic lifecycle commands:

```bash
# Create but don't start
docker create --name web nginx

# Start container
docker start web

# Stop container (SIGTERM, then SIGKILL after grace period)
docker stop web

# Forcefully stop (immediate SIGKILL)
docker kill web

# Pause/unpause container processes
docker pause web
docker unpause web

# Restart container
docker restart web

# Remove container (must be stopped)
docker rm web

# Remove running container
docker rm -f web
```

**Example:** Setting restart policies:

```bash
# Always restart, even after system reboot
docker run --restart=always nginx

# Restart only on failure, max 5 times
docker run --restart=on-failure:5 nginx

# Never restart automatically (default)
docker run --restart=no nginx
```

### Data Management in Containers

Managing data persistence and sharing is essential for stateful applications running in containers.

**Key Points:**

- Containers have ephemeral storage by default
- Volumes provide persistent storage managed by Docker
- Bind mounts map host directories into containers
- tmpfs mounts exist only in memory
- Volume drivers enable cloud storage integration
- Data can be shared between containers
- Docker CP can copy files between host and containers

Volume management:

```bash
# Create named volume
docker volume create mydata

# Use volume with container
docker run -v mydata:/app/data nginx

# Bind mount from host
docker run -v $(pwd)/config:/etc/nginx/conf.d nginx

# Temporary in-memory mount
docker run --tmpfs /tmp:rw,size=100M nginx
```

**Example:** Data sharing between containers:

```bash
# Create data container
docker create --name datastore -v /shared-data alpine

# Mount volumes from datastore in other containers
docker run --volumes-from datastore webapp
```

Copying files:

```bash
# Copy from host to container
docker cp config.json mycontainer:/app/

# Copy from container to host
docker cp mycontainer:/var/log/app.log ./logs/
```

### Container Security Best Practices

Implementing security measures for containers is crucial to protect your applications and infrastructure.

**Key Points:**

- Run containers with least privileges
- Use non-root users inside containers
- Limit capabilities and system calls
- Implement read-only filesystems where possible
- Scan images for vulnerabilities regularly
- Use content trust for image verification
- Apply resource limits to prevent DoS attacks
- Keep host and container runtime updated

**Example:** Security-focused container run command:

```bash
docker run \
  --user nobody \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --security-opt no-new-privileges \
  --read-only \
  --tmpfs /tmp \
  -v data:/data:ro \
  myapp
```

Setting up a non-root user in a Dockerfile:

```dockerfile
FROM node:14-alpine
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser
USER appuser
# rest of Dockerfile
```

### Docker Compose for Multi-Container Management

Docker Compose simplifies managing multi-container applications by defining services in a YAML file.

**Key Points:**

- Define multiple containers and their relationships in a single file
- Manages networks, volumes, and dependencies automatically
- Can be used for development, testing, and simple production deployments
- Supports environment variable substitution
- Allows scaling services (multiple instances)
- Compose files can be extended and reused

**Example:** Basic docker-compose.yml:

```yaml
version: '3'
services:
  web:
    image: nginx:alpine
    ports:
      - "8000:80"
    volumes:
      - ./site:/usr/share/nginx/html
    depends_on:
      - api
  api:
    build: ./api
    environment:
      - DB_HOST=db
      - DB_PASSWORD=password
    depends_on:
      - db
  db:
    image: postgres:13
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=password

volumes:
  db-data:
```

Common Compose commands:

```bash
# Start all services
docker-compose up -d

# Scale a specific service
docker-compose up -d --scale api=3

# View logs from all services
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Related Topics

- Docker Swarm for container orchestration
- Kubernetes for production-grade container management
- CI/CD pipelines with containers
- Container storage solutions and patterns
- Service discovery in container environments
- Container logging strategies
- Microservices architecture with containers

---


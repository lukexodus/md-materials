## Running Containers


### docker run

`docker run` creates and starts a new container from an image.

```bash
# Run and remove container when it exits
docker run --rm ubuntu echo "hello"

# Run in detached (background) mode
docker run -d --name myapp myapp:1.0

# Map host port 8080 to container port 3000
docker run -p 8080:3000 myapp:1.0

# Run interactively with a terminal
docker run -it ubuntu bash

# Set environment variables
docker run -e NODE_ENV=production myapp:1.0

# Mount a bind mount (host path:container path)
docker run -v /host/data:/app/data myapp:1.0

# Mount a named volume
docker run -v mydata:/app/data myapp:1.0

# Limit resources
docker run --memory=512m --cpus=1.5 myapp:1.0

# Set a restart policy
docker run -d --restart=unless-stopped myapp:1.0
```

### Restart Policies

| Policy           | Behavior                               |
| ---------------- | -------------------------------------- |
| `no`             | Never restart (default)                |
| `always`         | Always restart regardless of exit code |
| `on-failure`     | Restart only on non-zero exit code     |
| `unless-stopped` | Always restart unless manually stopped |

### Common docker Commands

```bash
# List running containers
docker ps

# List all containers including stopped ones
docker ps -a

# Stop a running container gracefully (SIGTERM, then SIGKILL after timeout)
docker stop myapp

# Kill a container immediately (SIGKILL)
docker kill myapp

# Remove a stopped container
docker rm myapp

# Remove a running container forcefully
docker rm -f myapp

# View container logs
docker logs myapp
docker logs -f myapp          # follow (like tail -f)
docker logs --tail 100 myapp  # last 100 lines

# Execute a command inside a running container
docker exec -it myapp bash
docker exec myapp ls /app

# Copy files between container and host
docker cp myapp:/app/config.json ./config.json
docker cp ./config.json myapp:/app/config.json

# View resource usage
docker stats

# Inspect container details (JSON)
docker inspect myapp

# View container processes
docker top myapp
```

---


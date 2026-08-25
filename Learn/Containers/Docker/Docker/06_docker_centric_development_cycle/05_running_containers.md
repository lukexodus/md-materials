## Running Containers


### Basic Run

```bash
docker run -d -p 3000:3000 --name myapp-dev myapp:1.0.0
```

- `-d`: Detached mode (runs in background)
- `-p host:container`: Publishes a port
- `--name`: Assigns a name instead of a random one

### Environment Variables

```bash
docker run -e DATABASE_URL=postgres://... myapp:1.0.0
# Or from a file:
docker run --env-file .env myapp:1.0.0
```

### Volumes

Volumes persist data beyond the container lifecycle. Bind mounts map a host directory into the container, useful during development.

```bash
# Named volume (managed by Docker)
docker run -v myapp-data:/data myapp:1.0.0

# Bind mount (maps host path to container path)
docker run -v $(pwd)/src:/app/src myapp:1.0.0
```

### Resource Limits

```bash
docker run --memory="512m" --cpus="1.5" myapp:1.0.0
```

### Stopping and Removing

```bash
docker stop myapp-dev      # Sends SIGTERM, waits, then SIGKILL
docker rm myapp-dev        # Remove the stopped container
docker rm -f myapp-dev     # Force stop and remove
```

---


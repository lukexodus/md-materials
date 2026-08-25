## Volumes and Data Persistence


By default, container filesystems are ephemeral. Three mechanisms exist for persisting or sharing data.

### Named Volumes

Docker manages the storage location (typically under `/var/lib/docker/volumes/`). Named volumes survive container removal and can be shared between containers.

```bash
# Create a volume
docker volume create mydata

# List volumes
docker volume ls

# Inspect a volume
docker volume inspect mydata

# Remove a volume
docker volume rm mydata

# Remove all unused volumes
docker volume prune

# Use a named volume at runtime
docker run -v mydata:/app/data myapp:1.0
```

### Bind Mounts

A bind mount maps a specific path on the host into the container. Changes are reflected immediately in both directions.

```bash
# Mount current directory into /app
docker run -v $(pwd):/app myapp:1.0

# Read-only bind mount
docker run -v $(pwd)/config:/app/config:ro myapp:1.0
```

Bind mounts are convenient for development (live code reloading) but are tightly coupled to the host path.

### tmpfs Mounts

Stored in the host's memory only. Not persisted to disk. Useful for sensitive temporary data.

```bash
docker run --tmpfs /tmp myapp:1.0
```

---


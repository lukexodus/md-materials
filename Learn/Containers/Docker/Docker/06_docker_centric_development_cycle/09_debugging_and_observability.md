## Debugging and Observability


### Logs

```bash
docker logs myapp-dev               # Print all logs
docker logs -f myapp-dev            # Follow (tail) logs
docker logs --since 5m myapp-dev    # Logs from the last 5 minutes
docker compose logs -f              # Follow all Compose service logs
```

### Exec Into a Running Container

```bash
docker exec -it myapp-dev sh        # Alpine / minimal images
docker exec -it myapp-dev bash      # Debian/Ubuntu-based images
```

### Inspecting Container State

```bash
docker inspect myapp-dev            # Full JSON metadata
docker stats                        # Live CPU/memory/network usage
docker top myapp-dev                # Running processes inside the container
```

### Ephemeral Debug Containers

If a production image has no shell, run a debug container sharing the same network or PID namespace:

```bash
docker run -it --rm \
  --network container:myapp-dev \
  nicolaka/netshoot
```

---


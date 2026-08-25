## Cleanup and Maintenance


Docker accumulates stopped containers, unused images, dangling volumes, and stale networks over time. Regular cleanup prevents disk exhaustion.

```bash
docker system prune          # Remove stopped containers, dangling images, unused networks
docker system prune -a       # Also remove unused images (not just dangling)
docker system prune --volumes # Also remove unused volumes (data loss risk — use with care)
docker image prune -a        # Remove all unused images
docker volume prune          # Remove all unused volumes
docker container prune       # Remove all stopped containers
```

Check disk usage:

```bash
docker system df
```

---


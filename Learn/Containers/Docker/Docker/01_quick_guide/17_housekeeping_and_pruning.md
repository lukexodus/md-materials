## Housekeeping and Pruning


Docker accumulates unused images, containers, networks, and volumes over time. Regular pruning keeps disk usage under control.

```bash
# Remove all stopped containers, unused networks, dangling images, and build cache
docker system prune

# Also remove unused volumes (use with caution)
docker system prune --volumes

# Remove all unused images, not just dangling ones
docker system prune -a

# Disk usage summary
docker system df

# Detailed disk usage
docker system df -v
```

---


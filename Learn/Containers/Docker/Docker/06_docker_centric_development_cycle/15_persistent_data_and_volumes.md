## Persistent Data and Volumes


### Volume Drivers

The default volume driver stores data in a Docker-managed directory on the host. For production, you may use remote volume drivers (e.g., for NFS, AWS EFS, or cloud block storage) to make data available across nodes.

### Backup and Restore

Back up named volumes by running a temporary container that reads the volume and writes to an archive:

```bash
docker run --rm \
  -v myapp-data:/data \
  -v $(pwd)/backup:/backup \
  alpine \
  tar czf /backup/myapp-data-$(date +%Y%m%d).tar.gz -C /data .
```

Restore with the reverse process:

```bash
docker run --rm \
  -v myapp-data:/data \
  -v $(pwd)/backup:/backup \
  alpine \
  tar xzf /backup/myapp-data-20240101.tar.gz -C /data
```

---


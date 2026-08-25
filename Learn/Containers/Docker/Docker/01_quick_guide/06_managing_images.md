## Managing Images


```bash
# List local images
docker images

# Pull an image from a registry
docker pull nginx:1.25

# Push an image to a registry (must be tagged with registry prefix)
docker tag myapp:1.0 myregistry.example.com/myapp:1.0
docker push myregistry.example.com/myapp:1.0

# Remove an image
docker rmi myapp:1.0

# Remove all dangling (untagged) images
docker image prune

# Remove all unused images
docker image prune -a

# View image layers and history
docker history myapp:1.0

# Inspect image metadata
docker inspect myapp:1.0

# Save image to a tar archive
docker save -o myapp.tar myapp:1.0

# Load image from a tar archive
docker load -i myapp.tar
```

---


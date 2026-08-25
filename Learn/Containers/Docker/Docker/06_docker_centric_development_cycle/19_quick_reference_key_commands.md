## Quick Reference: Key Commands


```bash
# Build
docker build -t name:tag .
docker buildx build --platform linux/amd64,linux/arm64 -t name:tag --push .

# Run
docker run -d -p 8080:8080 --name myapp name:tag
docker exec -it myapp sh

# Compose
docker compose up -d --build
docker compose down -v
docker compose logs -f

# Images
docker images
docker pull name:tag
docker push name:tag
docker rmi name:tag

# Registry
docker login myregistry.com
docker tag myapp:local myregistry.com/myapp:1.0.0

# Cleanup
docker system prune -a
docker system df

# Inspect
docker inspect myapp
docker stats
docker logs -f myapp
```

---


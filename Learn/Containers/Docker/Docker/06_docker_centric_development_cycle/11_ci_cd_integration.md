## CI/CD Integration


### General Pattern

A typical CI pipeline performs these steps in order:

1. Check out source code
2. Build the Docker image
3. Run tests inside the container
4. Push the image to a registry (on success, for the target branch)
5. Deploy

### Tagging Strategy

A consistent tagging strategy is important. Common approaches:

- Tag with the full Git commit SHA for traceability: `myapp:a3f9c2d`
- Tag with semantic version for releases: `myapp:1.4.0`
- Tag with branch name for preview environments: `myapp:feature-login`
- Avoid using `latest` as the sole tag in automated pipelines

### Registry Authentication in CI

Most CI platforms support injecting registry credentials as environment variables or secrets. Example for Docker Hub:

```bash
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
```

### Build Caching in CI

Without cache, every CI run rebuilds all layers from scratch. Options to speed this up:

- **Registry cache**: Push cache layers to the registry using `--cache-from` and `--cache-to` with BuildKit.
- **GitHub Actions cache**: The `docker/build-push-action` supports the `cache-from: type=gha` backend.
- **Layer cache in self-hosted runners**: Persistent runners retain the local image cache between runs.

```bash
docker buildx build \
  --cache-from type=registry,ref=myregistry/myapp:buildcache \
  --cache-to type=registry,ref=myregistry/myapp:buildcache,mode=max \
  -t myregistry/myapp:$GIT_SHA \
  --push .
```

---


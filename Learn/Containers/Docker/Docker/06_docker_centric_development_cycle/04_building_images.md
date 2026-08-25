## Building Images


### Basic Build

```bash
docker build -t myapp:1.0.0 .
```

The `-t` flag tags the image. The `.` at the end specifies the build context — the directory whose contents are sent to the daemon.

### Build Arguments

Build arguments (`ARG`) allow values to be passed in at build time without baking them into the final image layer permanently. Do not use `ARG` for secrets; use Docker BuildKit secrets instead.

```dockerfile
ARG APP_ENV=production
ENV APP_ENV=$APP_ENV
```

```bash
docker build --build-arg APP_ENV=staging -t myapp:staging .
```

### BuildKit

BuildKit is Docker's modern build backend. It is enabled by default in recent Docker versions and provides faster builds, better caching, and secret mounting. You can verify it is active by checking for `BuildKit` in `docker info` output.

```bash
DOCKER_BUILDKIT=1 docker build -t myapp:1.0.0 .
```

### Inspecting Images

```bash
docker images                        # List local images
docker inspect myapp:1.0.0           # Full image metadata in JSON
docker history myapp:1.0.0           # Show layers and sizes
docker image prune                   # Remove dangling (untagged) images
```

---


## Advanced Patterns


### Init Processes

PID 1 inside a container has special responsibilities (signal handling, zombie reaping). Some application processes are not designed to run as PID 1. Use `--init` to run a minimal init process (Tini) as PID 1, or use a multi-process supervisor like s6-overlay for containers that genuinely need multiple processes.

```bash
docker run --init myapp:1.0.0
```

### Entrypoint vs. CMD

`ENTRYPOINT` defines the executable; `CMD` defines default arguments. When both are present, `CMD` is passed as arguments to `ENTRYPOINT`. This combination is useful for images that act like commands:

```dockerfile
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["serve"]
```

The entrypoint script can perform setup tasks (waiting for dependencies, running migrations) before handing off to the main process.

### Graceful Shutdown

Applications should handle `SIGTERM` and complete in-flight requests before exiting. Docker sends `SIGTERM` when a container is stopped, then `SIGKILL` after the stop timeout (default 10 seconds). Set `stop_grace_period` in Compose or pass `--stop-timeout` to `docker stop` if your application needs more time.

### Docker Buildx and Multi-Platform Images

`docker buildx` allows building images for multiple CPU architectures (e.g., `linux/amd64` and `linux/arm64`) from a single machine using QEMU emulation or remote builders. This is important for supporting Apple Silicon Macs and ARM-based cloud instances.

```bash
docker buildx create --use
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t myregistry/myapp:1.0.0 \
  --push .
```

### Docker Extensions and Docker Desktop

Docker Desktop supports extensions that add functionality: database GUIs, log viewers, resource monitoring, and more. These are useful during development but are not part of the production workflow.

---


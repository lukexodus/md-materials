## Common Patterns


### Health Checks with depends_on

In Compose, use `condition: service_healthy` to delay dependent services until a dependency passes its healthcheck:

```yaml
depends_on:
  db:
    condition: service_healthy
```

### Sidecar Containers

A sidecar is a secondary container in the same pod (Kubernetes) or task (Swarm) that provides auxiliary functionality (logging agents, proxies, config sync). In Compose, sidecars share the same network namespace if configured appropriately.

### Init Containers

Some orchestrators support init containers that run to completion before the main container starts. In plain Docker, this pattern can be approximated with a startup script or by using `depends_on` with healthchecks in Compose.

### Graceful Shutdown

Containers receive SIGTERM when stopped. Applications should listen for SIGTERM and shut down cleanly. The default grace period before Docker sends SIGKILL is 10 seconds. Adjust with:

```bash
docker stop --time 30 myapp
```

In the Dockerfile, use exec form (`CMD ["node", "server.js"]`) rather than shell form so the process receives the signal directly rather than through a shell intermediary.

---


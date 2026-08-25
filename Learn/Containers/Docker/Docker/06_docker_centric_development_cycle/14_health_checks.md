## Health Checks


Define a `HEALTHCHECK` in the Dockerfile or in Compose to let Docker monitor whether the application inside the container is functioning correctly. A container can be running (process is alive) but unhealthy (the application is not responding to requests).

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

In Compose:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
  interval: 30s
  timeout: 5s
  retries: 3
  start_period: 10s
```

The `start_period` grace period avoids false positives during application startup.

---


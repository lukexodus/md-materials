## Testing in Docker


### Running Tests Inside the Container

Tests should run against the same image used in production to catch environment-specific failures. A common pattern is to override the container's command:

```bash
docker run --rm \
  --env-file .env.test \
  myapp:1.0.0 \
  npm test
```

### Compose-Based Test Environment

Define a separate Compose file or override file for testing:

```bash
docker compose -f compose.yaml -f compose.test.yaml up --abort-on-container-exit
```

The `--abort-on-container-exit` flag stops all services when any container exits, allowing CI to capture the exit code of the test runner.

### Integration Tests with Ephemeral Services

Use the `depends_on` health check condition to wait for dependent services (databases, caches) to be ready before the test runner starts. This avoids flaky tests caused by race conditions at startup.

---


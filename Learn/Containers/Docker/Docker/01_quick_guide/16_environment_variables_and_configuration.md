## Environment Variables and Configuration


### Passing Variables at Runtime

```bash
docker run -e MY_VAR=value myapp:1.0
docker run --env-file .env myapp:1.0
```

### Accessing Variables in the Container

Environment variables set with `-e` or `--env-file` are available to the container process as standard Unix environment variables.

### Config Files via Volumes

For complex configuration, mount config files via bind mounts or volumes rather than baking them into the image:

```bash
docker run -v ./config/app.yaml:/app/config/app.yaml:ro myapp:1.0
```

---


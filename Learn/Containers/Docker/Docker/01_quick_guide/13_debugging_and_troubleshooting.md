## Debugging and Troubleshooting


### Shell into a Running Container

```bash
docker exec -it myapp bash
# or for minimal images without bash
docker exec -it myapp sh
```

### Shell into a Stopped or Crashed Container

Override the entrypoint to get a shell:

```bash
docker run -it --entrypoint bash myapp:1.0
```

### Inspect Container State

```bash
docker inspect myapp
docker inspect --format '{{.State.Status}}' myapp
docker inspect --format '{{.NetworkSettings.Networks}}' myapp
```

### Check Container Exit Codes

A non-zero exit code signals a failure. Some common codes:

|Code|Meaning|
|---|---|
|`0`|Success|
|`1`|General error|
|`125`|Docker daemon error|
|`126`|Command not executable|
|`127`|Command not found|
|`137`|OOM kill (SIGKILL)|
|`143`|SIGTERM (graceful shutdown)|

### View Events

```bash
docker events
docker events --filter type=container --filter event=die
```

### Analyze Image Layers

```bash
docker history myapp:1.0

# Third-party tool: dive
dive myapp:1.0
```

### Networking Troubleshooting

```bash
# Inspect a network
docker network inspect mynet

# Test connectivity from inside a container
docker exec -it myapp ping db
docker exec -it myapp curl http://db:5432

# Check port bindings
docker port myapp
```

---


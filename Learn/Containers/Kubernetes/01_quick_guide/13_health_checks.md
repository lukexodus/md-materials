## Health Checks


### Liveness Probe

If the liveness probe fails, the container is restarted:

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 10
  failureThreshold: 3
```

### Readiness Probe

If the readiness probe fails, the Pod is removed from Service endpoints (no traffic is sent to it) but the container is not restarted:

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

### Startup Probe

For slow-starting containers. Disables liveness and readiness probes until the startup probe succeeds:

```yaml
startupProbe:
  httpGet:
    path: /started
    port: 8080
  failureThreshold: 30
  periodSeconds: 10
```

### Probe Types

```yaml
# HTTP GET
httpGet:
  path: /healthz
  port: 8080
  httpHeaders:
    - name: Authorization
      value: Bearer token123

# TCP socket
tcpSocket:
  port: 5432

# Exec command (zero exit code = healthy)
exec:
  command:
    - cat
    - /tmp/healthy

# gRPC (K8s >= 1.24)
grpc:
  port: 50051
```

---


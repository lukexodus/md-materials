## Security


### Run as Non-Root

Containers run as root by default. Create and use a non-root user:

```dockerfile
RUN addgroup -S app && adduser -S app -G app
USER app
```

### Read-Only Root Filesystem

Prevents writes to the container filesystem at runtime:

```bash
docker run --read-only myapp:1.0
```

Combine with `--tmpfs` for writable temporary directories:

```bash
docker run --read-only --tmpfs /tmp myapp:1.0
```

### Drop Capabilities

Linux capabilities can be dropped to limit what a container process can do:

```bash
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE myapp:1.0
```

### Secrets Management

Do not store secrets in environment variables or image layers in production. Use a secrets manager (Docker Swarm secrets, Kubernetes secrets, HashiCorp Vault, AWS Secrets Manager) and inject at runtime. For Compose-based development, `.env` files can work but must be kept out of version control.

### Image Scanning

Scan images for known CVEs with tools such as Docker Scout, Trivy, or Grype:

```bash
docker scout cves myapp:1.0

# Trivy (third-party)
trivy image myapp:1.0
```

### Limit Resources

Always set memory and CPU limits in production to prevent a container from starving the host or other containers:

```bash
docker run --memory=512m --memory-swap=512m --cpus=1 myapp:1.0
```

In Compose:

```yaml
services:
  web:
    deploy:
      resources:
        limits:
          memory: 512m
          cpus: "1.0"
```

### Seccomp and AppArmor

Docker applies a default seccomp profile that restricts certain syscalls. Custom profiles can be applied:

```bash
docker run --security-opt seccomp=my-profile.json myapp:1.0
```

---


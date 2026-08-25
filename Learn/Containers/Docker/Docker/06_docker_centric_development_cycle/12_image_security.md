## Image Security


### Scanning for Vulnerabilities

Scan images for known CVEs before pushing to production. Tools include:

- `docker scout cve myapp:1.0.0` (Docker Scout, integrated into Docker Desktop and Hub)
- Trivy (`trivy image myapp:1.0.0`)
- Snyk (`snyk container test myapp:1.0.0`)
- Grype (`grype myapp:1.0.0`)

Integrate scanning into the CI pipeline and decide on a policy for what severity level blocks a deployment.

### Running as a Non-Root User

By default, processes inside containers run as root. This is a security risk if a process is compromised. Create and use a non-root user in the Dockerfile:

```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

### Read-Only Filesystems

Where possible, run containers with a read-only root filesystem and mount specific writable paths explicitly:

```bash
docker run --read-only --tmpfs /tmp myapp:1.0.0
```

### Minimal Images

Smaller images have a smaller attack surface. Multi-stage builds and distroless base images reduce the number of packages present in the final image.

### Signing Images

Docker Content Trust (DCT) and Sigstore/cosign can be used to sign images and verify their integrity before deployment.

```bash
cosign sign --key cosign.key myregistry/myapp:1.0.0
cosign verify --key cosign.pub myregistry/myapp:1.0.0
```

---


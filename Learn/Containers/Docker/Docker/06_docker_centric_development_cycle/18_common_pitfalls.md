## Common Pitfalls


**Not pinning base image tags.** Using `FROM node:latest` means a future build may pull a different major version, breaking the build silently. Always pin to a specific tag.

**Baking secrets into image layers.** Passing secrets via `ENV` or `RUN` commands embeds them in the image layer history, even if they are later deleted. Use BuildKit secrets or multi-stage builds to avoid this.

**Running as root.** Containers running as root are a security risk. Always create and use a non-root user unless there is a specific, documented reason not to.

**Not setting resource limits.** Without memory and CPU limits, a container can consume all host resources. Set limits in production.

**Large build contexts.** Without a `.dockerignore`, the entire project directory (including `node_modules`, `.git`, and other large directories) is sent to the daemon on every build. This slows builds significantly.

**Conflating image size with image security.** A smaller image is not necessarily more secure — what matters is whether it contains packages with known vulnerabilities. Scan images regardless of size.

**Not handling startup ordering.** `depends_on` in Compose waits for the container to start, not for the application inside it to be ready. Use health checks with `condition: service_healthy` to express readiness correctly.

---


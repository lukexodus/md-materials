## Image Optimization


### Use a Slim or Minimal Base Image

|Base|Typical Size|Notes|
|---|---|---|
|`ubuntu:22.04`|~77 MB|Full Ubuntu userland|
|`debian:bookworm-slim`|~75 MB|Slimmed Debian|
|`alpine:3.19`|~7 MB|musl libc; may need workarounds|
|`distroless/base`|~20 MB|No shell; Google-maintained|
|`scratch`|0 MB|Empty; for static binaries only|

### Minimize Layers

Combine related `RUN` commands and clean up in the same layer:

```dockerfile
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
```

### Leverage Build Cache

Put instructions that change infrequently (like installing system dependencies) before instructions that change often (like copying source code). Docker caches each layer and reuses it if the instruction and all preceding layers are unchanged.

```dockerfile
# Install deps first (rarely changes)
COPY package.json package-lock.json ./
RUN npm ci

# Copy source last (changes frequently)
COPY . .
```

### Use Multi-Stage Builds

As described earlier, this removes build tools from the final image, substantially reducing its size and attack surface.

---


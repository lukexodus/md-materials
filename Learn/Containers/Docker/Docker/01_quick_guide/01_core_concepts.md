## Core Concepts


### Containers

A container is an isolated process (or group of processes) that shares the host OS kernel but has its own filesystem, networking, and process space. Containers are not virtual machines — they do not include a full OS; they share the kernel of the host system. This makes them significantly lighter and faster to start than VMs.

Each container is created from an **image** and is ephemeral by default: any data written inside the container is lost when the container is removed, unless persisted via volumes.

### Images

An image is a read-only, layered filesystem snapshot. It contains everything needed to run an application: the OS base layer, runtime, dependencies, application code, and configuration. Images are built from a `Dockerfile` and are stored in a registry.

Images are composed of **layers**. Each instruction in a Dockerfile produces one layer. Layers are cached and reused across builds and across images that share a common base, which saves disk space and speeds up builds.

### Dockerfile

A `Dockerfile` is a plain-text script that defines how to build an image. Docker reads it top to bottom, executing each instruction and committing a new layer.

### Registry

A registry is a storage and distribution service for Docker images. Docker Hub is the default public registry. Private registries can be self-hosted (e.g., with `registry:2`) or provided by cloud vendors (Amazon ECR, Google Artifact Registry, GitHub Container Registry, etc.).

### Docker Engine

Docker Engine is the daemon (`dockerd`) that manages containers, images, networks, and volumes on a host. The Docker CLI (`docker`) communicates with the daemon via a REST API over a Unix socket or TCP.

### Docker Desktop

Docker Desktop is a GUI application for macOS and Windows that bundles Docker Engine, Docker CLI, Docker Compose, and other tools. On Linux, Docker Engine is installed directly without Docker Desktop.

---


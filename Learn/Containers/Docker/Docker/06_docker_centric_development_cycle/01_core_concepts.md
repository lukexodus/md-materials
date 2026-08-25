## Core Concepts


### Containers vs. Virtual Machines

A container packages an application and its dependencies into a single runnable unit that shares the host operating system's kernel. Unlike a virtual machine, a container does not include a full OS image. This makes containers faster to start and smaller in size, though the isolation model is different: containers share the kernel, while VMs have fully separate kernels.

### Images

A Docker image is a read-only template used to create containers. Images are built in layers, where each instruction in a `Dockerfile` produces a new layer. Layers are cached, so rebuilds only re-execute changed steps and everything after them.

### The Docker Daemon and CLI

The Docker daemon (`dockerd`) runs as a background service and manages containers, images, networks, and volumes. The Docker CLI (`docker`) communicates with the daemon via a socket. Most day-to-day commands go through the CLI.

### Registries

A registry stores and distributes images. Docker Hub is the default public registry. Private registries (e.g., AWS ECR, GCP Artifact Registry, GitHub Container Registry, or a self-hosted Harbor instance) are common in organizational workflows.

---


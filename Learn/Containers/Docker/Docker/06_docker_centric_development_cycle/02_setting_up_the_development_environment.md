## Setting Up the Development Environment


### Installing Docker

Docker Desktop is the standard installation for macOS and Windows. On Linux, Docker Engine is installed directly via the distribution's package manager. Docker Desktop bundles the daemon, CLI, Docker Compose, and related tooling.

After installation, confirm the daemon is running:

```bash
docker version
docker info
```

### User Permissions on Linux

On Linux, the Docker daemon socket is owned by the `docker` group. Add your user to that group to run Docker commands without `sudo`:

```bash
sudo usermod -aG docker $USER
```

Log out and back in for the change to take effect.

### Docker Context

A Docker context defines which daemon the CLI connects to. This matters when you want to switch between a local daemon, a remote host, or a Kubernetes cluster. List and switch contexts with:

```bash
docker context ls
docker context use <context-name>
```

---


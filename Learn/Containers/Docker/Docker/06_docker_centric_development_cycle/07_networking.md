## Networking


### Default Compose Network

Compose automatically creates a network for each project. Services within the same project can reach each other by service name, which acts as a DNS hostname. In the example above, the app service connects to the database using `db` as the hostname.

### Network Types

Docker supports several network drivers:

- `bridge` (default for standalone containers): Containers on the same bridge network can communicate. External traffic reaches them only through published ports.
- `host`: The container shares the host's network stack directly. Available on Linux only.
- `none`: No networking.
- `overlay`: Used in Docker Swarm for multi-host networking.

### Exposing vs. Publishing Ports

`EXPOSE` in a Dockerfile documents which port a container listens on but does not make it reachable from the host. `-p` or `ports:` in Compose actually publishes the port to the host interface.

---


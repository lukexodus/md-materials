## Networking


### Network Drivers

|Driver|Use Case|
|---|---|
|`bridge`|Default for standalone containers; isolated network on the host|
|`host`|Container shares the host network stack directly|
|`none`|No networking|
|`overlay`|Multi-host networking (Swarm or Kubernetes)|
|`macvlan`|Assigns a MAC address; container appears as a physical device on the network|

### Working with Networks

```bash
# List networks
docker network ls

# Create a custom bridge network
docker network create mynet

# Connect a container to a network at run time
docker run --network mynet myapp:1.0

# Connect a running container to a network
docker network connect mynet myapp

# Disconnect a container from a network
docker network disconnect mynet myapp

# Inspect a network
docker network inspect mynet

# Remove a network
docker network rm mynet
```

### Container DNS

Containers on the same user-defined bridge network can resolve each other by container name. For example, if a container named `db` is on `mynet`, other containers on that network can reach it at hostname `db`.

The default bridge network does not provide automatic DNS resolution between containers — this is a key reason to use user-defined networks.

---


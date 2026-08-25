## Networking Fundamentals


### Introduction to Docker Networking

Docker networking enables communication between Docker containers and the outside world. It provides isolation, service discovery, load balancing, and secure communication between containerized applications. Understanding Docker networking is essential for designing distributed applications and microservices architectures.

**Key Points**:

- Docker creates a virtual network environment for containers
- Each container gets its own network namespace with a unique IP address
- Docker's networking subsystem is pluggable using drivers
- Networking can be configured at container runtime or via Docker Compose/Swarm

### Docker Network Drivers

Docker networking is based on a pluggable architecture that uses drivers to implement different networking capabilities. Each driver provides specific functionality for different use cases.

#### Built-in Network Drivers

Docker includes several built-in network drivers:

1. **Bridge**: The default network driver for standalone containers
2. **Host**: Removes network isolation between container and host
3. **Overlay**: Connect multiple Docker daemons across hosts (Swarm mode)
4. **Macvlan**: Assign MAC addresses to containers, making them appear as physical devices
5. **None**: Disables networking for containers
6. **IPvlan**: Similar to macvlan but uses Layer 3 routing instead of Layer 2 bridging

#### Third-party Network Drivers

Docker supports third-party network plugins through the Container Network Interface (CNI), including:

- **Weave**: Creates a virtual network that connects Docker containers across multiple hosts
- **Calico**: Provides secure network connectivity for containers and virtual machines
- **Flannel**: Designed for Kubernetes, creates a flat network across a cluster
- **Cilium**: Provides security visibility and control using eBPF

**Example** of checking available network drivers:

```bash
docker info | grep -A 4 "Network"
```

**Output**:

```
 Network: bridge host ipvlan macvlan null overlay
```

### Network Types

#### Bridge Networks

Bridge networks are the default network type in Docker. They create a private internal network on the host where containers can communicate with each other.

**Key characteristics**:

- Containers on the same bridge network can communicate via IP addresses
- Containers on different bridge networks cannot communicate directly
- External access requires port mapping
- Uses a Linux bridge (virtual switch)

**Example** of inspecting the default bridge network:

```bash
docker network inspect bridge
```

**Output** (partial):

```json
[
    {
        "Name": "bridge",
        "Id": "f7ab26d71dbd6f557852c3732ac4c3a0f32b9457cd9cf244646bad65d3e2ed0f",
        "Created": "2023-05-09T10:37:39.385479904Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```

#### Host Networks

Host networks remove network isolation between the container and the Docker host, allowing containers to use the host's networking directly.

**Key characteristics**:

- Container shares the host's network namespace
- No need for port mapping (uses host ports directly)
- Higher performance but reduced security isolation
- Limited to ports available on the host

**Example** of creating a container with host networking:

```bash
docker run --network host nginx
```

**Example** of a container using host networking in a Dockerfile:

```dockerfile
FROM nginx:latest
EXPOSE 80
# Note that EXPOSE is just documentation when using host networking
```

#### Overlay Networks

Overlay networks enable communication between containers across multiple Docker hosts, primarily used in Docker Swarm mode.

**Key characteristics**:

- Spans multiple Docker daemon hosts
- Uses VXLAN encapsulation for container-to-container traffic
- Built-in encryption options
- Used for multi-host deployments and Swarm services

**Example** of creating an overlay network (requires Swarm mode):

```bash
# Initialize swarm mode first
docker swarm init
# Create an overlay network
docker network create --driver overlay --attachable my-overlay-network
```

**Example** of using overlay network in a Docker Compose file:

```yaml
version: '3.8'
services:
  web:
    image: nginx
    networks:
      - my-overlay-net
  db:
    image: postgres
    networks:
      - my-overlay-net

networks:
  my-overlay-net:
    driver: overlay
    attachable: true
```

#### Macvlan Networks

Macvlan networks allow containers to have their own MAC addresses, making them appear as physical devices on the network.

**Key characteristics**:

- Assigns a unique MAC address to each container
- Container appears as a physical device on the network
- Direct communication with external resources without port mapping
- Requires promiscuous mode on the host interface

**Example** of creating a macvlan network:

```bash
docker network create --driver macvlan \
  --subnet=192.168.0.0/24 \
  --gateway=192.168.0.1 \
  -o parent=eth0 my-macvlan-net
```

**Example** of connecting a container to a macvlan network:

```bash
docker run --network my-macvlan-net --ip=192.168.0.10 -d nginx
```

### Creating Custom Networks

Custom networks provide better isolation, automatic DNS resolution between containers, and the ability to connect and disconnect containers on the fly.

#### Creating a Bridge Network

```bash
docker network create --driver bridge my-bridge-network
```

**Example** with subnet and gateway configuration:

```bash
docker network create \
  --driver bridge \
  --subnet=172.20.0.0/16 \
  --gateway=172.20.0.1 \
  my-custom-network
```

#### Attaching Containers to Networks

You can connect containers to networks at creation time or later:

```bash
# At creation time
docker run --network my-custom-network --name container1 -d nginx

# Connect an existing container
docker network connect my-custom-network container2
```

#### Disconnecting Containers from Networks

```bash
docker network disconnect my-custom-network container1
```

#### Network Configuration Options

When creating networks, you can specify various options:

```bash
docker network create \
  --driver bridge \
  --subnet=172.28.0.0/16 \
  --ip-range=172.28.5.0/24 \
  --gateway=172.28.5.254 \
  --aux-address="my-router=172.28.1.5" \
  -o "com.docker.network.bridge.enable_icc=true" \
  -o "com.docker.network.bridge.enable_ip_masquerade=true" \
  my-network
```

**Key network create options**:

- `--subnet`: Subnet in CIDR format for network
- `--ip-range`: Range of IPs from the subnet
- `--gateway`: IPv4 or IPv6 gateway for the network
- `--aux-address`: Auxiliary IPv4/IPv6 addresses for network driver
- `-o, --opt`: Driver-specific options

### Container DNS and Service Discovery

Docker provides built-in DNS resolution for containers on user-defined networks, enabling service discovery.

#### Automatic DNS Resolution

When containers are on the same user-defined network, they can reach each other using container names:

```bash
# Create a network
docker network create my-app-net

# Run containers on the network
docker run --network my-app-net --name web-app -d nginx
docker run --network my-app-net --name database -d postgres

# Now 'web-app' can communicate with 'database' using the hostname 'database'
docker exec -it web-app ping database
```

**Output**:

```
PING database (172.20.0.3) 56(84) bytes of data.
64 bytes from database.my-app-net (172.20.0.3): icmp_seq=1 ttl=64 time=0.066 ms
```

#### DNS Resolution in Docker Swarm

Docker Swarm provides advanced service discovery:

- Automatic DNS entries for services
- Round-robin DNS for load balancing
- VIP (Virtual IP) for services

**Example** of service discovery in Swarm:

```bash
# Create a service
docker service create --name web --replicas 3 --network my-overlay-net nginx
```

Now any container on the `my-overlay-net` network can reach the service using `web` hostname, which Docker will load balance across the service replicas.

#### Custom DNS Settings

You can customize DNS settings for containers:

```bash
docker run --dns=8.8.8.8 --dns-search=example.com nginx
```

In a Dockerfile:

```dockerfile
FROM ubuntu:20.04
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

### Port Mapping and Exposure

Containers can expose ports to the host or other containers through port mapping and exposure.

#### Exposing Ports in Dockerfile

The `EXPOSE` instruction in a Dockerfile documents which ports a container listens on:

```dockerfile
FROM nginx:latest
EXPOSE 80 443
```

Note that `EXPOSE` alone doesn't publish ports to the host; it's documentation and helps with automatic port publishing when using `docker run -P`.

#### Publishing Ports at Runtime

To make container ports accessible from the host:

```bash
# Publish container port 80 to host port 8080
docker run -p 8080:80 nginx

# Publish container port 80 to a random available host port
docker run -P nginx

# Publish to specific host interface
docker run -p 127.0.0.1:8080:80 nginx
```

#### Port Publishing in Docker Compose

Example Docker Compose file with port publishing:

```yaml
version: '3.8'
services:
  web:
    image: nginx
    ports:
      - "8080:80"    # HOST:CONTAINER format
      - "443"        # Just the container port (random host port)
      - "127.0.0.1:8081:80" # Specific interface
```

#### Checking Published Ports

To see which ports are published:

```bash
docker port container_name
```

**Output**:

```
80/tcp -> 0.0.0.0:8080
```

#### Host Port Ranges

You can publish a range of container ports to the host:

```bash
docker run -p 8000-8005:8000-8005 my-image
```

### Network Troubleshooting

#### Inspecting Networks

To get detailed information about a network:

```bash
docker network inspect my-network
```

#### Container Network Information

To inspect container networking details:

```bash
docker inspect --format '{{json .NetworkSettings}}' container_name | jq
```

#### Testing Connectivity

From within a container:

```bash
docker exec -it container_name ping other_container
docker exec -it container_name curl http://service_name:port
```

#### Network Diagnostics Tools

Common network diagnostic tools for containers:

```bash
# Install tools in a container
docker exec -it container_name sh -c "apt-get update && apt-get install -y iputils-ping net-tools curl dnsutils"

# Check container's network interfaces
docker exec container_name ip addr

# Check routing table
docker exec container_name route -n

# Check DNS resolution
docker exec container_name nslookup other_container
```

### Advanced Networking Concepts

#### Network Namespaces

Docker uses Linux network namespaces to isolate container networking:

```bash
# Get container's process ID
CID=$(docker inspect --format '{{.State.Pid}}' container_name)

# Enter container's network namespace (requires root)
nsenter -t $CID -n ip addr
```

#### Custom DNS Servers and Search Domains

```bash
docker run --dns=8.8.8.8 --dns=8.8.4.4 --dns-search=example.com nginx
```

#### IPvlan Networks

IPvlan is similar to macvlan but uses Layer 3 routing instead of Layer 2 bridging:

```bash
docker network create -d ipvlan \
  --subnet=192.168.0.0/24 \
  --gateway=192.168.0.1 \
  -o ipvlan_mode=l2 \
  -o parent=eth0 \
  my-ipvlan-net
```

#### Container Network Model (CNM)

Docker's Container Network Model consists of:

- **Sandbox**: Network stack configuration (interfaces, routes, DNS)
- **Endpoint**: Virtual network interface connected to a network
- **Network**: Collection of endpoints with a way to route between them

### Related Topics

- Docker Swarm networking and service discovery
- Kubernetes networking and service models
- Network security best practices for containers
- Service meshes (like Istio, Linkerd) for advanced networking controls
- Network monitoring and performance tuning for containerized applications

---


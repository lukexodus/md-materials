## Setting up a Swarm


### Swarm Mode Overview

Docker Swarm is Docker's native clustering and orchestration solution that transforms a group of Docker hosts into a single virtual Docker host. It enables deploying and managing containerized applications across multiple machines while providing high availability, load balancing, and scaling capabilities.

Docker Swarm mode was integrated directly into the Docker Engine in version 1.12, providing a built-in solution for container orchestration without requiring additional software.

**Key Points:**

- Native clustering for Docker
- Declarative service model
- Desired state reconciliation
- Secure by default with TLS mutual authentication
- Rolling updates and scaling support
- Load balancing and service discovery

### Initializing a Swarm

The first step in creating a Docker Swarm is to initialize it on a node that will become the first manager node.

**Basic Initialization:**

```bash
docker swarm init
```

When run on a machine with a single network interface, this command:

- Creates a swarm manager node
- Generates a token for joining worker nodes
- Generates a token for joining manager nodes
- Configures the node as a manager
- Sets up the overlay network for services
- Creates TLS certificates for secure communication

**Specifying Advertise Address:**

```bash
docker swarm init --advertise-addr 192.168.1.10
```

This explicitly defines the IP address that other nodes will use to connect to this manager.

**Custom Port:**

```bash
docker swarm init --advertise-addr 192.168.1.10:2377
```

Port 2377 is the default for encrypted cluster management communications.

**Setting Certificate Expiry:**

```bash
docker swarm init --cert-expiry 48h
```

**Viewing Join Tokens:**

```bash
# Get token for adding worker nodes
docker swarm join-token worker

# Get token for adding manager nodes
docker swarm join-token manager
```

**Sample Output:**

```
Swarm initialized: current node (dxn1zf6l61qsb1josjja83ngz) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-49nj1cmql0jkz5s954yi3oex3nedyz0fb0xx14ie39trti4wxv-8vxv8rssmk743ojnwacrr2e7c 192.168.99.100:2377

To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-61ztec5kyafptydic6jfc1i33t37flcl4nuipzcusor96k7kby-5vy9t8u35tuqm7vh67lrz9xp6 192.168.99.100:2377
```

**Rotating Join Tokens:**

```bash
# Create new worker token
docker swarm join-token --rotate worker

# Create new manager token
docker swarm join-token --rotate manager
```

**Key Points:**

- Always specify the advertise address on multi-interface hosts
- Join tokens are security-sensitive; rotate them periodically
- The first node becomes the leader manager
- Certificate rotation and security are handled automatically

### Adding Manager and Worker Nodes

Once you've initialized the swarm, you can add additional nodes as either managers or workers.

#### Adding Worker Nodes

Worker nodes are execution instances that run services but don't participate in the Raft consensus for managing the swarm.

**Join Command:**

```bash
docker swarm join --token SWMTKN-1-49nj1cmql0jkz5s954yi3oex3nedyz0fb0xx14ie39trti4wxv-8vxv8rssmk743ojnwacrr2e7c 192.168.99.100:2377
```

The token identifies this node as a worker, and the IP/port combination specifies the manager to connect to.

**Custom Join Options:**

```bash
# Specify a different listen address
docker swarm join --token WORKER_TOKEN --listen-addr 192.168.1.15 MANAGER_IP:2377

# Specify both listen and advertise addresses
docker swarm join --token WORKER_TOKEN --listen-addr 192.168.1.15 --advertise-addr 192.168.1.15 MANAGER_IP:2377
```

#### Adding Manager Nodes

Manager nodes participate in the Raft distributed consensus algorithm to maintain the cluster state. They can also run services like worker nodes.

**Join Command:**

```bash
docker swarm join --token SWMTKN-1-61ztec5kyafptydic6jfc1i33t37flcl4nuipzcusor96k7kby-5vy9t8u35tuqm7vh67lrz9xp6 192.168.99.100:2377
```

**Availability Options:**

```bash
docker swarm join --token MANAGER_TOKEN --availability drain MANAGER_IP:2377
```

Setting `--availability drain` prevents the new manager from receiving tasks.

#### Viewing Swarm Nodes

```bash
# List all nodes
docker node ls

# Example output:
ID                            HOSTNAME            STATUS    AVAILABILITY    MANAGER STATUS    ENGINE VERSION
dxn1zf6l61qsb1josjja83ngz *  manager1            Ready     Active          Leader            19.03.13
7ns9qc4s912lkajwecmov7gh9    worker1             Ready     Active                            19.03.13
9j3phul9cgp92n29v4xsi9nhb    worker2             Ready     Active                            19.03.13
```

The asterisk (*) indicates the node you're currently connected to.

#### Recommended Manager-Worker Configurations

Raft consensus requires an odd number of managers to maintain quorum:

|Cluster Size|Managers|Workers|Fault Tolerance|
|---|---|---|---|
|Small|3|2+|1 manager|
|Medium|5|10+|2 managers|
|Large|7|100+|3 managers|

**Key Points:**

- More than 7 managers can decrease performance
- Manager nodes can also run services (active availability)
- Use an odd number of managers to maintain quorum
- A majority of managers must be available for the swarm to function

### Node Roles and Promotion/Demotion

Docker Swarm supports dynamic changes to node roles and availability states, allowing flexible management of the cluster.

#### Node Roles

Nodes in a swarm have one of two roles:

**Manager Nodes:**

- Participate in the Raft distributed state store
- Handle orchestration and cluster management
- Can deploy and manage services
- Accept commands from client API
- Dispatch tasks to worker nodes

**Worker Nodes:**

- Execute containers
- Cannot view or modify cluster state
- Cannot deploy services
- Report status back to managers

#### Leader Election

Manager nodes use the Raft consensus algorithm to maintain a consistent state:

- One manager is elected as the "leader"
- The leader handles all orchestration decisions
- If the leader fails, a new leader is automatically elected
- Requires a majority of managers (quorum) to elect a leader

```bash
# View managers and leader status
docker node ls
```

Manager status values:

- `Leader`: The primary manager node directing the swarm
- `Reachable`: Manager nodes participating in the Raft consensus
- `Unavailable`: Manager node that can't communicate with the leader

#### Promoting Workers to Managers

```bash
# Promote a worker to manager role
docker node promote worker1

# Alternatively:
docker node update --role manager worker1
```

This adds the worker to the Raft consensus group and grants it management privileges.

#### Demoting Managers to Workers

```bash
# Demote a manager to worker role
docker node demote manager2

# Alternatively:
docker node update --role worker manager2
```

**Important:** Never demote the last manager node, as this would leave the swarm without management capabilities.

#### Changing Node Availability

Nodes have three availability states:

**Active:**

```bash
docker node update --availability active node1
```

The node can receive and execute tasks (default state).

**Pause:**

```bash
docker node update --availability pause node1
```

The node continues running existing tasks but won't receive new ones.

**Drain:**

```bash
docker node update --availability drain node1
```

The node won't accept new tasks, and existing tasks are rescheduled to other nodes.

**Use Cases for Changing Availability:**

- `drain`: For node maintenance or decommissioning
- `pause`: For temporary removal from the scheduling pool
- `active`: To restore normal operation

#### Node Labels

Add metadata to nodes for task placement constraints:

```bash
# Add labels to nodes
docker node update --label-add zone=east node1
docker node update --label-add type=gpu node2

# Multiple labels
docker node update --label-add zone=west --label-add disk=ssd node3
```

**Key Points:**

- Maintain an odd number of managers for proper quorum
- Minimum of 3 managers recommended for production
- Use drain mode before performing maintenance
- Worker nodes can't access the Raft store or modify the cluster state

### Swarm Networking

Docker Swarm implements several networking concepts to enable communication between services across the cluster.

#### Network Types in Swarm Mode

**Overlay Networks:**

- Span multiple nodes in the swarm
- Allow containers on different hosts to communicate securely
- Use VXLAN encapsulation by default

**Ingress Network:**

- Special overlay network created automatically
- Handles routing of swarm service traffic
- Provides the routing mesh for published ports

**Docker_gwbridge:**

- Bridge network connecting overlay networks to host network
- Created automatically when joining a swarm
- Provides outbound connectivity for containers

#### Creating and Managing Overlay Networks

```bash
# Create an overlay network
docker network create --driver overlay my-network

# Create with encryption for all traffic (not just control)
docker network create --driver overlay --opt encrypted my-secure-network

# Scope limited to swarm (not for standalone containers)
docker network create --driver overlay --attachable my-attachable-network
```

**Options:**

- `--attachable`: Allows standalone containers to connect to this network
- `--subnet`: Specify the subnet for the network
- `--opt encrypted`: Encrypt data plane traffic (control plane is always encrypted)

#### Listing and Inspecting Networks

```bash
# List all networks
docker network ls

# Inspect network details
docker network inspect my-network
```

#### Connecting Services to Networks

```bash
# Create service with network
docker service create --name my-service --network my-network nginx

# Multi-network service
docker service create --name multi-net-service \
  --network first-network \
  --network second-network \
  redis
```

#### Internal Load Balancing

Services within the same overlay network can communicate with each other using service names as DNS entries:

```bash
# Create backend service
docker service create --name backend \
  --network app-network \
  --replicas 3 \
  mybackend:latest

# Create frontend service that connects to backend
docker service create --name frontend \
  --network app-network \
  --env BACKEND_URL=http://backend:8080 \
  myfrontend:latest
```

In this example, `http://backend:8080` automatically load balances requests across all backend service replicas.

#### External Load Balancing (Routing Mesh)

The ingress network provides a routing mesh that routes traffic from published ports to service containers on any node:

```bash
# Create a service with published port
docker service create --name web \
  --publish 8080:80 \
  --replicas 3 \
  nginx
```

Traffic to port 8080 on any swarm node is routed to port 80 on an nginx container, even if that container is running on a different node.

#### Publishing Ports

**Default (Ingress Mode):**

```bash
docker service create --name web --publish 8080:80 nginx
```

**Host Mode (Node-specific):**

```bash
docker service create --name web --publish mode=host,target=80,published=8080 nginx
```

Host mode restricts the service to running on the node where the port is available.

#### Network Security

```bash
# Create an isolated network for a specific application
docker network create --driver overlay --opt encrypted --attachable app-secure-net

# Use placement constraints to control where services run
docker service create --name secure-app \
  --network app-secure-net \
  --constraint node.labels.security==high \
  myapp:latest
```

**Key Points:**

- Overlay networks provide container-to-container communication across hosts
- The routing mesh enables service discovery and load balancing
- Control plane traffic is encrypted by default
- Data plane encryption is optional with performance impact
- Service discovery works automatically using DNS

### Service Discovery

Service discovery allows containers and services to locate and communicate with each other without hardcoding hostnames or IP addresses.

#### DNS-Based Service Discovery

Docker Swarm provides automatic service discovery through DNS:

- Each service gets a DNS entry matching its name
- Requests to a service name are load-balanced across replicas
- DNS returns a virtual IP (VIP) that maps to all service tasks
- Internal round-robin load balancing handles request distribution

```bash
# Create services
docker service create --name api --network app-net --replicas 3 my-api:latest
docker service create --name web --network app-net my-web:latest

# Web container can access API using hostname "api"
# e.g., http://api:8000/
```

#### Virtual IPs and Direct Container Discovery

Docker Swarm uses two methods for service discovery:

**Virtual IP (VIP) Mode:**

- Default mode
- Service has a single virtual IP
- Internal load balancing to service tasks
- Simple to use – just use the service name

**DNS Round Robin Mode:**

```bash
docker service create --name search \
  --network app-net \
  --endpoint-mode dnsrr \
  elasticsearch:7
```

DNS returns IPs of all containers directly, putting load balancing responsibility on the client.

#### Service Discovery Lifecycle

1. Service is created and assigned a name
2. Internal DNS service registers the name
3. Service tasks (containers) are started
4. Containers connect to their assigned networks
5. Other services resolve the service name via DNS
6. Request is routed to a task via VIP or DNS round-robin

#### Inspecting Service Endpoints

```bash
# View service details including endpoints
docker service inspect --pretty my-service

# View virtual IPs and endpoints
docker service inspect --format="{{json .Endpoint.VirtualIPs}}" my-service
```

#### Cross-Service Communication Example

```bash
# Create a backend database service
docker service create --name db \
  --network app-network \
  --env MYSQL_ROOT_PASSWORD=secret \
  mysql:5.7

# Create a web service that connects to the database
docker service create --name web \
  --network app-network \
  --env DB_HOST=db \
  --env DB_PASSWORD=secret \
  --publish 80:80 \
  my-web-app:latest
```

The web application can connect to the database using the hostname `db`, which Docker's service discovery automatically resolves.

#### External Service Registration

For external service discovery systems:

```bash
# Add labels for external discovery
docker service create --name api \
  --label traefik.enable=true \
  --label traefik.http.routers.api.rule="Host(`api.example.com`)" \
  my-api:latest
```

#### Troubleshooting Service Discovery

```bash
# Check if services are on the same network
docker service inspect --format="{{.Spec.TaskTemplate.Networks}}" service1
docker service inspect --format="{{.Spec.TaskTemplate.Networks}}" service2

# Test DNS resolution from inside a container
docker exec -it <container_id> ping other-service

# Check if service is running properly
docker service ps service-name
```

**Key Points:**

- DNS-based discovery is built into Docker Swarm
- Service names automatically resolve to VIPs
- Load balancing happens transparently
- Services must be on the same overlay network to communicate
- External tools can integrate via labels or the Docker API

### Putting It All Together: Complete Swarm Setup

Let's walk through a complete example of setting up a Docker Swarm with multiple services:

#### 1. Initialize the Swarm

On the first manager node:

```bash
docker swarm init --advertise-addr 192.168.1.10
```

#### 2. Add Manager Nodes

On additional manager nodes, using the token from the first manager:

```bash
docker swarm join --token MANAGER_TOKEN 192.168.1.10:2377
```

#### 3. Add Worker Nodes

On worker nodes, using the worker token:

```bash
docker swarm join --token WORKER_TOKEN 192.168.1.10:2377
```

#### 4. Create Overlay Networks

```bash
# Frontend network
docker network create --driver overlay frontend

# Backend network (encrypted)
docker network create --driver overlay --opt encrypted backend
```

#### 5. Deploy Database Service

```bash
docker service create --name db \
  --network backend \
  --mount type=volume,source=db-data,target=/var/lib/postgresql/data \
  --env POSTGRES_PASSWORD=secret \
  --env POSTGRES_USER=app \
  --constraint 'node.role==worker' \
  --replicas 1 \
  postgres:13
```

#### 6. Deploy Backend API Service

```bash
docker service create --name api \
  --network backend \
  --network frontend \
  --env DB_HOST=db \
  --env DB_USER=app \
  --env DB_PASSWORD=secret \
  --replicas 3 \
  --update-delay 10s \
  --update-parallelism 1 \
  --health-cmd "curl -f http://localhost:8000/health || exit 1" \
  --health-interval 30s \
  my-api:latest
```

#### 7. Deploy Frontend Web Service

```bash
docker service create --name web \
  --network frontend \
  --publish 80:80 \
  --env API_URL=http://api:8000 \
  --replicas 5 \
  my-web:latest
```

#### 8. Verify Services

```bash
# List all services
docker service ls

# Check service tasks
docker service ps web
docker service ps api
docker service ps db

# View logs
docker service logs web
```

**Key Points:**

- Separate frontend and backend networks improve security
- Placement constraints ensure services run on appropriate nodes
- Health checks verify service functionality
- Update configuration enables seamless rolling updates

### Related Topics

- Docker Swarm Services: Creating and managing services in detail
- Swarm Secrets and Configs: Managing sensitive data and configuration
- Swarm Stack Deployment: Deploying applications with docker stack
- High Availability in Swarm: Ensuring cluster resilience
- Swarm vs. Kubernetes: Comparing container orchestration systems

---


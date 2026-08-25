## Swarm Services


### Understanding Docker Swarm Services

Services are the fundamental building blocks of applications in Docker Swarm. A service defines the desired state of a containerized application component, including the container image, number of replicas, network settings, volumes, and update behavior.

**Key Points**

- Services define the desired state of containers in declarative syntax
- Swarm manager nodes maintain the desired state by creating tasks (containers)
- Services can run as multiple replicas or in global mode
- Services automatically recover from failures
- Services provide built-in load balancing and service discovery
- Services support zero-downtime updates and rollbacks
- Services can be constrained to run on specific nodes

### Creating and Managing Services

#### Creating a Basic Service

```bash
# Create a simple web service with 3 replicas
docker service create \
  --name web-server \
  --replicas 3 \
  --publish 80:80 \
  nginx:latest
```

#### Listing Services

```bash
# List all services in the swarm
docker service ls

# Sample output:
# ID            NAME        MODE        REPLICAS    IMAGE         PORTS
# 7be6iu8ayoxx  web-server  replicated  3/3         nginx:latest  *:80->80/tcp
```

#### Inspecting Service Details

```bash
# Get detailed information about a service
docker service inspect web-server

# Display service information in a more readable format
docker service inspect --pretty web-server

# Get specific information using format
docker service inspect --format='{{.Spec.TaskTemplate.ContainerSpec.Image}}' web-server
```

#### Viewing Service Tasks

```bash
# List the tasks (containers) of a service
docker service ps web-server

# Sample output:
# ID            NAME            IMAGE         NODE      DESIRED STATE  CURRENT STATE
# 8d9auw5x7k9x  web-server.1    nginx:latest  node1     Running        Running 10 min
# f8x4hul9xon1  web-server.2    nginx:latest  node2     Running        Running 10 min
# d93h9tjnu7i9  web-server.3    nginx:latest  node3     Running        Running 10 min
```

#### Viewing Service Logs

```bash
# View logs from all service tasks
docker service logs web-server

# Follow log output
docker service logs --follow web-server

# View logs with timestamps
docker service logs --timestamps web-server

# Show logs from specific time
docker service logs --since 2023-05-20T10:00:00 web-server

# Show only last 100 lines
docker service logs --tail=100 web-server
```

#### Removing a Service

```bash
# Remove a service
docker service rm web-server
```

### Service Replicas and Global Mode

Docker Swarm supports two service deployment modes:

1. **Replicated mode**: Runs a specified number of replica tasks distributed across the cluster
2. **Global mode**: Runs exactly one task on every eligible node in the cluster

#### Creating a Replicated Service

```bash
# Create a replicated service (default mode)
docker service create \
  --name api-service \
  --replicas 5 \
  --publish 8080:8080 \
  mycompany/api:latest
```

#### Scaling a Replicated Service

```bash
# Change the number of replicas
docker service scale api-service=10

# Scale multiple services at once
docker service scale api-service=8 web-server=6
```

#### Creating a Global Service

Global services are ideal for infrastructure services like monitoring agents, where you want exactly one instance per node.

```bash
# Create a global service that runs on every node
docker service create \
  --name monitoring-agent \
  --mode global \
  --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
  --mount type=bind,source=/proc,target=/host/proc,readonly \
  --mount type=bind,source=/sys,target=/host/sys,readonly \
  prom/node-exporter:latest
```

### Service Configuration Options

#### Environment Variables

```bash
# Set environment variables in a service
docker service create \
  --name backend \
  --replicas 3 \
  --env NODE_ENV=production \
  --env DB_HOST=db.example.com \
  --env DB_PORT=5432 \
  mycompany/backend:latest
```

#### Mounts and Volumes

```bash
# Mount a volume
docker service create \
  --name db \
  --replicas 1 \
  --mount type=volume,source=db-data,target=/var/lib/postgresql/data \
  postgres:latest

# Mount a bind mount
docker service create \
  --name nginx \
  --replicas 3 \
  --mount type=bind,source=/configs/nginx.conf,target=/etc/nginx/nginx.conf \
  nginx:latest

# Use a tmpfs mount
docker service create \
  --name app \
  --replicas 3 \
  --mount type=tmpfs,destination=/tmp,tmpfs-size=100M \
  mycompany/app:latest
```

#### Networks

```bash
# Create an overlay network
docker network create --driver overlay backend-network

# Attach a service to a network
docker service create \
  --name api \
  --replicas 3 \
  --network backend-network \
  mycompany/api:latest

# Connect to multiple networks
docker service create \
  --name gateway \
  --replicas 2 \
  --network frontend-network \
  --network backend-network \
  nginx:latest
```

#### Service Resource Constraints

```bash
# Set CPU and memory limits
docker service create \
  --name worker \
  --replicas 5 \
  --limit-cpu 0.5 \
  --limit-memory 512M \
  --reserve-cpu 0.2 \
  --reserve-memory 256M \
  mycompany/worker:latest
```

### Rolling Updates

Rolling updates allow you to update service configurations without downtime by gradually replacing old containers with new ones.

#### Creating a Service with Update Config

```bash
# Create a service with specific update configuration
docker service create \
  --name web \
  --replicas 5 \
  --publish 80:80 \
  --update-delay 30s \
  --update-parallelism 2 \
  --update-failure-action rollback \
  --update-max-failure-ratio 0.2 \
  --update-order start-first \
  nginx:1.21
```

Update parameters explained:

- `--update-delay`: Time between updates of individual tasks (containers)
- `--update-parallelism`: Number of tasks to update simultaneously
- `--update-failure-action`: Action to take if update fails (continue, pause, rollback)
- `--update-max-failure-ratio`: Failure ratio that triggers update failure
- `--update-order`: Update order (start-first or stop-first)

#### Performing a Rolling Update

```bash
# Update the image of an existing service
docker service update \
  --image nginx:1.22 \
  web

# Update multiple parameters
docker service update \
  --image nginx:1.22 \
  --publish-add 443:443 \
  --replicas 10 \
  web
```

#### Monitoring Update Progress

```bash
# Watch the update progress
docker service ps web

# Sample output during update:
# ID            NAME        IMAGE         NODE      DESIRED STATE  CURRENT STATE
# a83v6f3lk9s2  web.1       nginx:1.22    node1     Running        Running 30 sec
# 7bdu38fh5ls9   \_ web.1   nginx:1.21    node1     Shutdown       Shutdown 35 sec
# b72x9vsk4e21  web.2       nginx:1.22    node2     Running        Running 1 min
# 83msp6v74nsk   \_ web.2   nginx:1.21    node2     Shutdown       Shutdown 1 min
# k85hd7r9dk42  web.3       nginx:1.21    node3     Running        Running 10 min
# ...
```

#### Rolling Back an Update

```bash
# Rollback to the previous version
docker service update --rollback web
```

#### Update Configurations

Full update configuration example:

```bash
docker service create \
  --name app \
  --replicas 10 \
  --update-parallelism 2 \
  --update-delay 20s \
  --update-failure-action rollback \
  --update-max-failure-ratio 0.1 \
  --update-monitor 30s \
  --update-order start-first \
  --rollback-parallelism 3 \
  --rollback-delay 10s \
  --rollback-failure-action pause \
  --rollback-max-failure-ratio 0.2 \
  --rollback-monitor 20s \
  --rollback-order stop-first \
  mycompany/app:1.0
```

### Service Health Checks

Health checks ensure that only healthy containers receive traffic and enable automatic replacement of unhealthy containers.

```bash
# Create a service with health check
docker service create \
  --name web \
  --replicas 5 \
  --publish 80:80 \
  --health-cmd "curl -f http://localhost/ || exit 1" \
  --health-interval 30s \
  --health-timeout 10s \
  --health-retries 3 \
  --health-start-period 60s \
  nginx:latest
```

Health check parameters:

- `--health-cmd`: Command to check container health
- `--health-interval`: Time between health checks
- `--health-timeout`: Timeout for health check commands
- `--health-retries`: Number of consecutive failures before considering unhealthy
- `--health-start-period`: Initial grace period before starting health checks

### Service Constraints and Placement

Placement constraints and preferences control where service tasks run within the swarm.

#### Node Constraints

```bash
# Run only on manager nodes
docker service create \
  --name registry \
  --constraint "node.role==manager" \
  --publish 5000:5000 \
  registry:2

# Run only on worker nodes
docker service create \
  --name worker \
  --constraint "node.role==worker" \
  mycompany/worker:latest

# Use multiple constraints (AND logic)
docker service create \
  --name db \
  --constraint "node.role==worker" \
  --constraint "node.labels.storage==ssd" \
  postgres:latest
```

#### Placement based on Node Labels

First, add labels to nodes:

```bash
# Add labels to nodes
docker node update --label-add region=east node1
docker node update --label-add region=west node2
docker node update --label-add tier=frontend node3
docker node update --label-add tier=backend node4
```

Then use labels in constraints:

```bash
# Place service on nodes with specific labels
docker service create \
  --name api \
  --constraint "node.labels.region==east" \
  --constraint "node.labels.tier==backend" \
  mycompany/api:latest
```

#### Placement Preferences

Preferences try to place tasks according to a strategy but don't guarantee it:

```bash
# Spread tasks across different availability zones
docker service create \
  --name web \
  --replicas 9 \
  --placement-pref "spread=node.labels.zone" \
  nginx:latest
```

#### Full Placement Configuration

```bash
docker service create \
  --name complex-app \
  --replicas 10 \
  --constraint "node.role==worker" \
  --constraint "node.labels.tier==backend" \
  --placement-pref "spread=node.labels.zone" \
  --placement-pref "spread=node.labels.rack" \
  mycompany/app:latest
```

### Load Balancing

Docker Swarm provides automatic load balancing for services through its built-in routing mesh.

#### Internal Load Balancing

Services within the same overlay network can communicate using service names, which act as virtual IPs (VIPs) that load balance requests across all service tasks.

```bash
# Create backend service
docker service create \
  --name backend \
  --replicas 5 \
  --network app-network \
  mycompany/backend:latest

# Create frontend service that connects to backend
docker service create \
  --name frontend \
  --replicas 3 \
  --network app-network \
  --env BACKEND_URL=http://backend:8080 \
  mycompany/frontend:latest
```

The frontend containers can connect to `http://backend:8080`, and the requests will be automatically load-balanced across all backend tasks.

#### External Load Balancing

For external access, Swarm provides ingress load balancing through published ports.

```bash
# Publish a port
docker service create \
  --name web \
  --replicas 5 \
  --publish published=80,target=80,mode=ingress \
  nginx:latest
```

When you access port 80 on any swarm node, the request is automatically routed to one of the service tasks, even if that task is running on a different node.

#### Publishing Modes

```bash
# Ingress mode (default) - accessible on all nodes
docker service create \
  --name web \
  --replicas 3 \
  --publish mode=ingress,published=80,target=80 \
  nginx:latest

# Host mode - only accessible on nodes running the task
docker service create \
  --name api \
  --replicas 3 \
  --publish mode=host,published=8080,target=8080 \
  mycompany/api:latest
```

#### Load Balancing with Multiple Ports

```bash
# Publish multiple ports
docker service create \
  --name web \
  --replicas 3 \
  --publish 80:80 \
  --publish 443:443 \
  nginx:latest
```

### Advanced Service Configurations

#### Service Networks with DNS Round Robin

By default, a service name resolves to a VIP that load-balances across all tasks. You can also enable DNS round-robin mode:

```bash
# Enable DNS round robin
docker service create \
  --name search \
  --replicas 3 \
  --network app-network \
  --endpoint-mode dnsrr \
  elasticsearch:latest
```

#### Restart Policies

Configure how services recover from failures:

```bash
# Set restart policy
docker service create \
  --name worker \
  --replicas 5 \
  --restart-condition any \
  --restart-delay 5s \
  --restart-max-attempts 3 \
  --restart-window 120s \
  mycompany/worker:latest
```

Restart policy options:

- `--restart-condition`: When to restart (none, on-failure, any)
- `--restart-delay`: Delay between restart attempts
- `--restart-max-attempts`: Maximum restart attempts before giving up
- `--restart-window`: Window to consider for max-attempts

#### Working with Secrets

```bash
# Create a secret
echo "mydbpassword" | docker secret create db_password -

# Use the secret in a service
docker service create \
  --name db \
  --secret db_password \
  --env POSTGRES_PASSWORD_FILE=/run/secrets/db_password \
  postgres:latest
```

#### Working with Configs

```bash
# Create a config from a file
docker config create nginx_conf ./nginx.conf

# Use the config in a service
docker service create \
  --name web \
  --config source=nginx_conf,target=/etc/nginx/nginx.conf \
  nginx:latest
```

### Complex Service Example

This example demonstrates a comprehensive service configuration with many advanced features:

```bash
docker service create \
  --name api-service \
  --replicas 10 \
  --update-parallelism 2 \
  --update-delay 30s \
  --update-failure-action rollback \
  --update-monitor 60s \
  --restart-condition any \
  --restart-delay 10s \
  --restart-max-attempts 5 \
  --limit-cpu 0.5 \
  --limit-memory 512M \
  --reserve-cpu 0.2 \
  --reserve-memory 256M \
  --mount type=volume,source=api-data,target=/data \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
  --network backend \
  --network frontend \
  --publish published=8080,target=8080,mode=ingress \
  --constraint "node.role==worker" \
  --constraint "node.labels.environment==production" \
  --placement-pref "spread=node.labels.zone" \
  --health-cmd "curl -f http://localhost:8080/health || exit 1" \
  --health-interval 30s \
  --health-retries 3 \
  --health-start-period 60s \
  --health-timeout 10s \
  --secret source=api_key,target=app_api_key \
  --config source=app_config,target=/app/config.yml \
  --env NODE_ENV=production \
  --env LOG_LEVEL=info \
  --with-registry-auth \
  mycompany/api:1.0
```

### Service Monitoring and Troubleshooting

#### Monitoring Service Status

```bash
# View service status
docker service ls

# View detailed service information
docker service inspect --pretty api-service

# View service tasks
docker service ps api-service

# View task distribution
docker service ps --filter "desired-state=running" \
  --format "table {{.Name}}\t{{.Node}}" api-service
```

#### Troubleshooting Service Issues

```bash
# Check if tasks are failing
docker service ps --filter "desired-state=running" api-service

# View logs for a service
docker service logs api-service

# View logs for a specific task
docker service logs api-service.3

# View logs for failed tasks
docker service logs --filter "failed" api-service
```

### Best Practices for Swarm Services

**Key Points**

- Use named volumes for persistent data
- Implement proper health checks for all services
- Configure appropriate restart policies
- Define resource constraints to prevent resource starvation
- Use overlay networks for service isolation
- Set reasonable update configurations for zero-downtime deployments
- Use service labels for organization and automation
- Implement proper logging solutions
- Consider using stacks for managing related services
- Set appropriate placement constraints for critical services

### Service Label Strategy

Use labels to organize and manage your services:

```bash
docker service create \
  --name api \
  --label com.example.description="API Service" \
  --label com.example.department="Engineering" \
  --label com.example.environment="Production" \
  mycompany/api:latest
```

Filter services by label:

```bash
docker service ls --filter "label=com.example.environment=Production"
```

### Service Deployment Patterns

#### Blue-Green Deployment

```bash
# Deploy new version (green)
docker service create \
  --name web-green \
  --replicas 5 \
  --network app-network \
  mycompany/web:2.0

# Verify the new version works correctly
# Then update the proxy to point to the green version

# Remove old version (blue)
docker service rm web-blue
```

#### Canary Deployment

```bash
# Deploy majority with stable version
docker service create \
  --name web \
  --replicas 8 \
  --publish 80:80 \
  mycompany/web:1.0

# Update a small subset to canary version
docker service update \
  --image mycompany/web:2.0 \
  --update-parallelism 2 \
  --update-max-failure-ratio 0 \
  --update-monitor 5m \
  --update-delay 1m \
  web
```

### Related Topics

- Using Docker Stacks to deploy multi-service applications
- Service discovery patterns
- Advanced networking configurations
- High availability for stateful services
- Integration with external load balancers
- Monitoring solutions for Swarm services
- Implementing CI/CD pipelines for service deployment

---


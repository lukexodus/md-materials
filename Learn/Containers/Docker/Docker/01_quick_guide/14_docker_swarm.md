## Docker Swarm


Docker Swarm is Docker's built-in clustering and orchestration mode. It groups multiple Docker hosts into a swarm and deploys services across them.

### Initialize and Manage a Swarm

```bash
# Initialize a swarm (on the manager node)
docker swarm init --advertise-addr <MANAGER-IP>

# Get the join token for worker nodes
docker swarm join-token worker

# Join as a worker (run on worker nodes)
docker swarm join --token <TOKEN> <MANAGER-IP>:2377

# List nodes
docker node ls
```

### Deploy a Stack

Compose files are used as stack definitions:

```bash
docker stack deploy -c compose.yaml mystack

# List stacks
docker stack ls

# List services in a stack
docker stack services mystack

# List tasks (containers) in a stack
docker stack ps mystack

# Remove a stack
docker stack rm mystack
```

### Services

```bash
# Create a service
docker service create --name web --replicas 3 -p 80:80 nginx

# Scale a service
docker service scale web=5

# Update a service (rolling update)
docker service update --image nginx:1.25 web

# Inspect a service
docker service inspect web

# View service logs
docker service logs -f web
```

---


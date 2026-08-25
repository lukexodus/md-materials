## Production Deployment Options


### Docker Swarm

Docker Swarm is Docker's built-in orchestrator. It uses Compose-like YAML (stack files) and supports multi-node deployments, rolling updates, and service scaling. It is simpler to operate than Kubernetes but has a smaller ecosystem.

```bash
docker stack deploy -c stack.yaml myapp
docker service ls
docker service scale myapp_app=3
```

### Kubernetes

Kubernetes (K8s) is the dominant container orchestration platform for production. Docker images run on Kubernetes without modification; the difference is in how they are described and scheduled. Workloads are defined as `Deployment`, `StatefulSet`, `DaemonSet`, and other resource types in YAML manifests.

Docker Compose files can be converted to Kubernetes manifests using tools like Kompose, though the output typically requires manual adjustment.

### Single-Host Deployments

For smaller deployments, a single server running Docker with Compose is a practical option. Tools like Kamal (from 37signals) automate deploying Compose-based apps to a fleet of servers over SSH, handling rolling deploys and zero-downtime restarts.

### Managed Container Services

Cloud providers offer managed services that run Docker containers without requiring you to manage the underlying infrastructure: AWS ECS/Fargate, Google Cloud Run, Azure Container Apps, Fly.io, and Render, among others. These services consume standard Docker images from a registry.

---


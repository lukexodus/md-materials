## What is Kubernetes?


Kubernetes (commonly abbreviated K8s) is an open-source container orchestration platform originally developed by Google and donated to the Cloud Native Computing Foundation (CNCF) in 2014. It automates the deployment, scaling, scheduling, networking, and lifecycle management of containerized applications.

Kubernetes does not build or run containers directly — it orchestrates them. It typically works with container runtimes such as containerd or CRI-O, and most commonly with Docker-built images.

### Core Problems Kubernetes Solves

- Running many containers across many machines without manual placement
- Restarting containers that crash
- Scaling up or down based on load
- Rolling out updates with zero downtime
- Service discovery and load balancing between containers
- Managing configuration and secrets separately from application code
- Persistent storage for stateful workloads

---


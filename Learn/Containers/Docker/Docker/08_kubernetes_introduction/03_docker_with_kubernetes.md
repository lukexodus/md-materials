## Docker with Kubernetes


### Introduction to Docker and Kubernetes Integration

Kubernetes and Docker complement each other in the container ecosystem. While Docker provides the container technology for packaging applications and their dependencies, Kubernetes orchestrates these containers across a cluster of machines, handling deployment, scaling, and management.

**Key Points**:

- Docker packages applications as containers
- Kubernetes orchestrates and manages containerized applications at scale
- Both technologies work together but serve different purposes
- Kubernetes supports multiple container runtimes, not just Docker

### Using Docker Images with Kubernetes

Kubernetes uses Docker images as the building blocks for deploying applications. The process involves creating Docker images and then referencing them in Kubernetes manifests.

#### Creating Docker Images for Kubernetes

When creating Docker images for Kubernetes deployments, follow these best practices:

- Build minimal images to reduce attack surface and improve performance
- Use multi-stage builds to keep images small
- Include health checks that Kubernetes can leverage
- Properly handle signals for graceful shutdown

```dockerfile
FROM node:16-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:16-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./
RUN npm ci --only=production
EXPOSE 3000
USER node
CMD ["node", "dist/main.js"]
```

#### Using Private Docker Registries

To use images from private Docker registries in Kubernetes:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: regcred
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-docker-config>
---
apiVersion: v1
kind: Pod
metadata:
  name: private-image-pod
spec:
  containers:
  - name: private-image-container
    image: private-registry.example.com/my-app:1.0.0
  imagePullSecrets:
  - name: regcred
```

To create the dockerconfigjson secret:

```bash
kubectl create secret docker-registry regcred \
  --docker-server=<your-registry-server> \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email>
```

#### Image Pull Policies

Kubernetes offers different image pull policies:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
  - name: app
    image: my-app:1.0.0
    imagePullPolicy: Always  # Always, IfNotPresent, or Never
```

- `Always`: Always pull the image
- `IfNotPresent`: Only pull if not already present
- `Never`: Never pull the image (must exist locally)

#### Image Tag Best Practices

- Avoid using the `:latest` tag in production
- Use semantic versioning or git SHA for immutable references
- Consider using image digests for absolute immutability

```yaml
containers:
- name: app
  image: myregistry.com/myapp@sha256:12345abcdef...
```

### Docker Desktop Kubernetes

Docker Desktop includes a Kubernetes distribution that allows developers to run a single-node Kubernetes cluster directly on their development machine.

#### Enabling Kubernetes in Docker Desktop

1. Open Docker Desktop preferences/settings
2. Navigate to the Kubernetes tab
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"

#### Accessing the Kubernetes Dashboard

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl proxy
```

Then access the dashboard at: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

#### Context Switching

Docker Desktop adds its context automatically:

```bash
# List available contexts
kubectl config get-contexts

# Switch to Docker Desktop Kubernetes
kubectl config use-context docker-desktop
```

#### Resource Limitations

Docker Desktop Kubernetes has resource constraints based on what you've allocated to Docker Desktop:

```bash
# Check node capacity
kubectl describe node docker-desktop
```

You can adjust these in Docker Desktop's Resources settings.

#### Persistent Volumes with Docker Desktop

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /Users/username/data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### Minikube for Local Development

Minikube is a tool that runs a single-node Kubernetes cluster in a virtual machine on your laptop, providing a lightweight way to run Kubernetes locally.

#### Installing Minikube

```bash
# macOS with Homebrew
brew install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Windows with Chocolatey
choco install minikube
```

#### Starting Minikube

```bash
# Start with default configuration
minikube start

# Start with specific Kubernetes version
minikube start --kubernetes-version=v1.24.0

# Start with more resources
minikube start --cpus=4 --memory=8192mb
```

#### Using Docker CLI with Minikube

Minikube runs its own Docker daemon which is separate from your host Docker:

```bash
# Configure your terminal to use Minikube's Docker daemon
eval $(minikube docker-env)

# Build images directly in Minikube
docker build -t my-app:local .

# Use the image in Kubernetes without pushing to a registry
kubectl run my-app --image=my-app:local --image-pull-policy=Never
```

#### Minikube Addons

Minikube offers built-in addons to enhance functionality:

```bash
# List available addons
minikube addons list

# Enable dashboard
minikube addons enable dashboard

# Open dashboard in browser
minikube dashboard

# Enable metrics-server
minikube addons enable metrics-server
```

#### Accessing Services

```bash
# Create a service
kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4
kubectl expose deployment hello-node --type=NodePort --port=8080

# Get the URL to access the service
minikube service hello-node --url
```

#### Minikube vs Docker Desktop Kubernetes

|Feature|Minikube|Docker Desktop Kubernetes|
|---|---|---|
|Installation|Separate tool|Included with Docker Desktop|
|VM Required|Yes|No (on Mac/Windows)|
|Drivers|Multiple (VirtualBox, HyperKit, Docker)|Docker Engine|
|Custom Resources|Adjustable|Limited by Docker Desktop allocation|
|Kubernetes Versions|Multiple versions available|Fixed version per Docker Desktop release|

### Container Runtimes in Kubernetes

Kubernetes supports multiple container runtimes through the Container Runtime Interface (CRI). Docker was the default runtime historically, but Kubernetes is moving towards other runtimes.

#### Evolution of Container Runtimes in Kubernetes

- Pre-v1.20: Docker was the default runtime
- v1.20+: Docker support via dockershim deprecated
- v1.24+: dockershim removed, Docker Engine requires CRI compatible layer (like cri-dockerd)

#### Available Container Runtimes

##### containerd

The most common runtime in Kubernetes today, extracted from Docker as a standalone project:

```bash
# Check if containerd is running
systemctl status containerd

# Configure Kubernetes to use containerd
kubelet --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock
```

##### CRI-O

A lightweight container runtime specifically for Kubernetes:

```bash
# Install CRI-O on Ubuntu
. /etc/os-release
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key | apt-key add -
apt-get update
apt-get install cri-o cri-o-runc
```

##### Docker with cri-dockerd

For clusters that need to continue using Docker Engine:

```bash
# Install cri-dockerd
git clone https://github.com/Mirantis/cri-dockerd.git
cd cri-dockerd
make
make install

# Configure kubelet to use cri-dockerd
kubelet --container-runtime=remote --container-runtime-endpoint=unix:///var/run/cri-dockerd.sock
```

#### Runtime Classes

Kubernetes allows specifying different runtimes for different workloads:

```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc
---
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  runtimeClassName: gvisor
  containers:
  - name: my-container
    image: my-app:1.0.0
```

#### Selecting a Container Runtime

Factors to consider when choosing a container runtime:

- Production readiness and stability
- Performance characteristics
- Security features (e.g., gVisor, Kata Containers)
- Operational complexity
- Team familiarity

**Example**:

Testing container runtime performance:

```bash
# Install cri-tools
VERSION="v1.25.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin

# Configure crictl to use containerd
cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
EOF

# List containers
crictl ps
```

### Deploying Docker Applications to Kubernetes

Converting Docker Compose applications to Kubernetes configurations is a common migration path.

#### Docker Compose to Kubernetes

Tools like Kompose can help convert Docker Compose files to Kubernetes manifests:

```bash
# Install Kompose
curl -L https://github.com/kubernetes/kompose/releases/download/v1.26.1/kompose-linux-amd64 -o kompose
chmod +x kompose
sudo mv ./kompose /usr/local/bin/kompose

# Convert docker-compose.yml to Kubernetes resources
kompose convert -f docker-compose.yml
```

#### Helm Charts for Docker Applications

Helm simplifies deploying complex Docker applications to Kubernetes:

```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add a repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Install a chart
helm install my-release bitnami/wordpress
```

#### Managing ConfigMaps and Secrets

In Docker Compose, environment variables and config files are handled differently than in Kubernetes:

```yaml
# Kubernetes ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_URL: "postgresql://user:password@db:5432/mydb"
  CACHE_ENABLED: "true"
---
# Using the ConfigMap
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    envFrom:
    - configMapRef:
        name: app-config
```

### Kubernetes and Docker Security

Security considerations when using Docker with Kubernetes:

#### Image Security

```bash
# Scan Docker images for vulnerabilities
docker scan myapp:1.0

# Configure Kubernetes admission controllers
kubectl apply -f - <<EOF
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: ImagePolicyWebhook
  configuration:
    imagePolicy:
      kubeConfigFile: /path/to/kubeconfig
      allowTTL: 50
      denyTTL: 50
      retryBackoff: 500
      defaultAllow: false
EOF
```

#### Pod Security

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: secure-container
    image: myapp:1.0
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

#### Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-network-policy
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: database
    ports:
    - protocol: TCP
      port: 5432
```

### Troubleshooting Docker in Kubernetes

Common issues and how to resolve them:

#### Image Pull Errors

```bash
# Check pod status
kubectl get pods

# Describe pod for detailed information
kubectl describe pod <pod-name>

# Check if image exists in registry
docker pull <image-name>

# Verify image pull secrets
kubectl get secret <secret-name> -o yaml
```

#### Container Crash Issues

```bash
# Check container logs
kubectl logs <pod-name>

# Check previous container logs if restarted
kubectl logs <pod-name> --previous

# Debug with an ephemeral container
kubectl debug -it <pod-name> --image=busybox
```

#### Resource Constraints

```bash
# Check node resource usage
kubectl top nodes

# Check pod resource usage
kubectl top pods

# Describe node to see resource allocation
kubectl describe node <node-name>
```

**Conclusion**:

Docker and Kubernetes create a powerful combination for containerized application development and deployment. Docker provides the container technology for packaging applications while Kubernetes offers the orchestration layer for running these containers at scale. Understanding how these technologies interact, from local development environments like Docker Desktop and Minikube to production-grade container runtimes, enables developers and operators to build robust, scalable systems. By following best practices for image creation, runtime selection, and security configuration, you can harness the full potential of Docker within the Kubernetes ecosystem.

---


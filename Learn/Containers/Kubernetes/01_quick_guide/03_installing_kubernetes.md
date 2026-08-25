## Installing Kubernetes


### Local Development

**minikube** runs a single-node Kubernetes cluster locally inside a VM or container:

```bash
# Install minikube (macOS)
brew install minikube

# Start a cluster
minikube start

# Start with a specific Kubernetes version
minikube start --kubernetes-version=v1.29.0

# Stop the cluster
minikube stop

# Delete the cluster
minikube delete
```

**kind** (Kubernetes in Docker) runs cluster nodes as Docker containers:

```bash
# Install kind
brew install kind

# Create a cluster
kind create cluster

# Create a named cluster
kind create cluster --name my-cluster

# Delete a cluster
kind delete cluster --name my-cluster
```

**k3d** wraps k3s (a lightweight Kubernetes distribution) in Docker:

```bash
brew install k3d
k3d cluster create my-cluster
```

### kubectl — The CLI

`kubectl` is the primary CLI for interacting with Kubernetes clusters.

```bash
# macOS
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/
```

### Cloud-Managed Clusters

Major cloud providers offer managed Kubernetes:

- **GKE** (Google Kubernetes Engine): `gcloud container clusters create`
- **EKS** (Amazon Elastic Kubernetes Service): `eksctl create cluster`
- **AKS** (Azure Kubernetes Service): `az aks create`

Managed clusters handle control plane provisioning, upgrades, and availability for you.

---


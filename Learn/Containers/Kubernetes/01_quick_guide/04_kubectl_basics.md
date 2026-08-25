## kubectl Basics


### Configuring Context

kubectl uses a `kubeconfig` file (default: `~/.kube/config`) to store cluster connection information.

```bash
# View current context
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context my-cluster

# Set a namespace for the current context
kubectl config set-context --current --namespace=my-namespace
```

### Common Commands

```bash
# Get resources
kubectl get pods
kubectl get pods -n kube-system          # In a specific namespace
kubectl get pods --all-namespaces        # Across all namespaces
kubectl get pods -o wide                 # More columns (node, IP)
kubectl get pods -o yaml                 # Full YAML output
kubectl get pods -o json                 # Full JSON output
kubectl get pods --watch                 # Watch for changes

# Describe a resource (detailed view with events)
kubectl describe pod my-pod
kubectl describe node my-node

# Delete resources
kubectl delete pod my-pod
kubectl delete -f deployment.yaml

# Apply a manifest
kubectl apply -f deployment.yaml
kubectl apply -f ./manifests/           # Apply all files in directory

# Execute a command in a running container
kubectl exec -it my-pod -- /bin/bash
kubectl exec -it my-pod -c my-container -- /bin/sh

# View logs
kubectl logs my-pod
kubectl logs my-pod -c my-container     # Specific container
kubectl logs my-pod --previous          # Previous (crashed) container
kubectl logs my-pod -f                  # Follow (stream)
kubectl logs my-pod --tail=100          # Last 100 lines

# Port forward to a Pod
kubectl port-forward pod/my-pod 8080:80
kubectl port-forward svc/my-service 8080:80

# Copy files to/from a Pod
kubectl cp my-pod:/etc/config ./local-config
kubectl cp ./local-file my-pod:/tmp/

# Get resource usage
kubectl top pods
kubectl top nodes
```

### Imperative Commands

Quick resource creation without YAML:

```bash
kubectl run my-pod --image=nginx
kubectl create deployment my-deploy --image=nginx --replicas=3
kubectl expose deployment my-deploy --port=80 --type=ClusterIP
kubectl create namespace my-namespace
kubectl create secret generic my-secret --from-literal=key=value
kubectl create configmap my-config --from-file=./config.properties
```

---


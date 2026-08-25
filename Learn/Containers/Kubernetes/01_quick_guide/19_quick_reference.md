## Quick Reference


### Object Abbreviations

|Full Name|Short|API Group|
|---|---|---|
|pods|po|core|
|services|svc|core|
|deployments|deploy|apps|
|replicasets|rs|apps|
|statefulsets|sts|apps|
|daemonsets|ds|apps|
|configmaps|cm|core|
|secrets|—|core|
|namespaces|ns|core|
|nodes|no|core|
|persistentvolumes|pv|core|
|persistentvolumeclaims|pvc|core|
|ingresses|ing|networking.k8s.io|
|horizontalpodautoscalers|hpa|autoscaling|
|cronjobs|cj|batch|
|serviceaccounts|sa|core|

### kubectl Cheat Sheet

```bash
# Apply
kubectl apply -f file.yaml
kubectl delete -f file.yaml

# Get
kubectl get <resource>
kubectl get <resource> -n <namespace>
kubectl get <resource> -o yaml
kubectl get <resource> -o wide
kubectl get <resource> --watch

# Describe
kubectl describe <resource> <name>

# Logs
kubectl logs <pod> [-c <container>] [-f] [--previous]

# Exec
kubectl exec -it <pod> -- <command>

# Scale
kubectl scale deployment <name> --replicas=<n>

# Rollout
kubectl rollout status deployment/<name>
kubectl rollout history deployment/<name>
kubectl rollout undo deployment/<name>

# Port forward
kubectl port-forward <pod|svc>/<name> <local>:<remote>

# Resource usage
kubectl top pods
kubectl top nodes

# Dry run (validate without applying)
kubectl apply -f file.yaml --dry-run=client
kubectl apply -f file.yaml --dry-run=server
```

---


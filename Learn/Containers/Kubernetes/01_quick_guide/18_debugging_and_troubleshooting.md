## Debugging and Troubleshooting


### Pod Not Starting

```bash
kubectl describe pod my-pod         # Events section shows scheduling/pull errors
kubectl logs my-pod                 # Application logs
kubectl logs my-pod --previous      # Logs from crashed previous container
kubectl get events --sort-by='.lastTimestamp'
```

Common causes:

- `ImagePullBackOff` / `ErrImagePull` — image name wrong, tag missing, or registry credentials absent
- `CrashLoopBackOff` — container starts and crashes repeatedly; check logs
- `Pending` — no node can satisfy the Pod's resource requests, affinity, or tolerations
- `OOMKilled` — container exceeded memory limit

### Exec into a Pod

```bash
kubectl exec -it my-pod -- /bin/bash
kubectl exec -it my-pod -c sidecar -- /bin/sh
```

### Ephemeral Debug Containers (K8s >= 1.23)

Add a temporary debug container to a running Pod without modifying the original spec:

```bash
kubectl debug -it my-pod --image=busybox --target=my-container
```

### Copy Files

```bash
kubectl cp my-pod:/var/log/app.log ./app.log
```

### Node Issues

```bash
kubectl describe node my-node
kubectl get events --field-selector involvedObject.name=my-node
kubectl top node
```

### Network Debugging

```bash
# Run a temporary Pod for network testing
kubectl run debug --image=nicolaka/netshoot --rm -it -- /bin/bash

# Test DNS
nslookup my-service.default.svc.cluster.local

# Test connectivity
curl http://my-service:80/healthz
```

---


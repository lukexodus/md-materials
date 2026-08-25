## Services and Networking


### Service

A Service provides a stable network endpoint for a set of Pods. Pods are ephemeral and their IPs change; Services provide a consistent DNS name and IP.

Services select Pods using label selectors.

#### ClusterIP (default)

Exposes the Service on an internal IP only accessible within the cluster:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80        # Port the Service listens on
      targetPort: 8080 # Port on the Pod
  type: ClusterIP
```

#### NodePort

Exposes the Service on a static port on each node's IP (range 30000–32767):

```yaml
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 8080
      nodePort: 30080  # Optional; auto-assigned if omitted
```

Access via `<NodeIP>:<NodePort>`.

#### LoadBalancer

Provisions a cloud load balancer (on supported cloud providers):

```yaml
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 8080
```

#### ExternalName

Maps the Service to an external DNS name:

```yaml
spec:
  type: ExternalName
  externalName: api.example.com
```

#### Headless Service

A Service with `clusterIP: None` returns the individual Pod IPs via DNS instead of a single virtual IP. Required by StatefulSets for stable DNS:

```yaml
spec:
  clusterIP: None
  selector:
    app: my-db
```

### DNS in Kubernetes

Every Service gets a DNS entry: `<service-name>.<namespace>.svc.cluster.local`

Pods can reach services in the same namespace by name alone: `my-service`. Cross-namespace: `my-service.other-namespace`.

### Ingress

An Ingress manages external HTTP/HTTPS access to Services. It provides host-based and path-based routing, TLS termination, and more. It requires an **Ingress Controller** (e.g. nginx-ingress, Traefik, AWS ALB Ingress Controller).

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - myapp.example.com
      secretName: tls-secret
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 80
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend-service
                port:
                  number: 80
```

### NetworkPolicy

NetworkPolicies define rules for how Pods communicate with each other and with external endpoints. By default, all Pods in a cluster can communicate with all other Pods.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
spec:
  podSelector: {}       # Applies to all Pods in namespace
  policyTypes:
    - Ingress
```

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-api
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 8080
```

NetworkPolicies require a CNI plugin that supports them (e.g. Calico, Cilium, Weave).

---


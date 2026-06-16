## Kubernetes Deployment Basics

Deploying a Fastify application to Kubernetes involves packaging the app as a container image, defining Kubernetes resources, and configuring the cluster to handle traffic, scaling, and restarts. This module covers the full deployment cycle from image to running Pod.

---

### Why Kubernetes for Fastify

Kubernetes provides a declarative, self-healing infrastructure layer that complements Fastify's lightweight, production-ready design. Rather than managing individual servers, you describe the desired state and let Kubernetes reconcile it continuously.

**Key Points:**
- Fastify's fast startup and low memory footprint map well to container workloads
- Kubernetes handles restart-on-crash, rolling updates, and horizontal scaling
- Health check endpoints (`/healthz`, `/readyz`) integrate directly with Kubernetes probes
- Graceful shutdown behavior (covered in the shutdown module) is essential for zero-downtime pod termination

---

### Containerizing a Fastify Application

Before deploying to Kubernetes, the app must be packaged as a Docker image.

**Example — `Dockerfile`:**

```dockerfile
# Stage 1: build dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: runtime image
FROM node:20-alpine
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

EXPOSE 3000
ENV NODE_ENV=production
CMD ["node", "server.js"]
```

**Key Points:**
- Multi-stage builds keep the final image lean — development tooling is excluded
- `npm ci --only=production` omits devDependencies
- `EXPOSE 3000` is documentation; actual port binding is controlled by Kubernetes
- The app should bind to `0.0.0.0`, not `127.0.0.1`, so the container network interface is reachable

**Example — `server.js` binding:**

```js
import Fastify from 'fastify'

const app = Fastify({ logger: true })

app.get('/healthz', async () => ({ status: 'ok' }))
app.get('/readyz', async () => ({ status: 'ready' }))

await app.listen({ port: 3000, host: '0.0.0.0' })
```

---

### Core Kubernetes Resources

#### Deployment

A `Deployment` declares the desired number of Pod replicas and the container spec. Kubernetes continuously reconciles the actual state toward this declaration.

**Example — `deployment.yaml`:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastify-app
  labels:
    app: fastify-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fastify-app
  template:
    metadata:
      labels:
        app: fastify-app
    spec:
      containers:
        - name: fastify-app
          image: your-registry/fastify-app:1.0.0
          ports:
            - containerPort: 3000
          env:
            - name: NODE_ENV
              value: production
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "256Mi"
          livenessProbe:
            httpGet:
              path: /healthz
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /readyz
              port: 3000
            initialDelaySeconds: 3
            periodSeconds: 5
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh", "-c", "sleep 5"]
      terminationGracePeriodSeconds: 30
```

**Key Points:**
- `replicas: 3` runs three Pod instances; traffic is distributed across them
- `resources.requests` guides the scheduler; `limits` caps consumption
- `livenessProbe` triggers a restart if the app becomes unhealthy
- `readinessProbe` gates traffic routing — Pods only receive traffic when ready
- `preStop` sleep gives the load balancer time to drain connections before SIGTERM is sent [Inference — actual drain timing depends on cloud provider and ingress controller behavior]
- `terminationGracePeriodSeconds` sets the maximum window for graceful shutdown

#### Service

A `Service` provides a stable virtual IP and DNS name for the set of Pods matched by the selector.

**Example — `service.yaml`:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: fastify-app-svc
spec:
  selector:
    app: fastify-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: ClusterIP
```

**Key Points:**
- `ClusterIP` exposes the Service only within the cluster — external access requires an Ingress or LoadBalancer
- `port: 80` is the Service port; `targetPort: 3000` is the container port
- Kubernetes automatically load-balances requests across healthy, ready Pods

#### Ingress

An `Ingress` routes external HTTP/HTTPS traffic to Services by hostname or path. Requires an Ingress controller (nginx-ingress, Traefik, etc.) to be installed.

**Example — `ingress.yaml`:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fastify-app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: fastify-app-svc
                port:
                  number: 80
  tls:
    - hosts:
        - api.example.com
      secretName: api-tls-secret
```

**Key Points:**
- TLS termination at the Ingress is common; the Fastify app then communicates internally over plain HTTP
- `secretName` references a Kubernetes `Secret` of type `kubernetes.io/tls` containing the certificate and key
- Annotations are controller-specific; behavior varies across nginx, Traefik, Istio, etc. [Unverified — always consult the specific controller's documentation]

---

### ConfigMaps and Secrets

Environment-specific configuration should not be baked into the image. Use `ConfigMap` for non-sensitive data and `Secret` for credentials.

**Example — `configmap.yaml`:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fastify-config
data:
  LOG_LEVEL: "info"
  PORT: "3000"
```

**Example — `secret.yaml`:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: fastify-secrets
type: Opaque
stringData:
  DATABASE_URL: "postgres://user:pass@db:5432/mydb"
  JWT_SECRET: "supersecretvalue"
```

**Referencing in the Deployment:**

```yaml
containers:
  - name: fastify-app
    envFrom:
      - configMapRef:
          name: fastify-config
      - secretRef:
          name: fastify-secrets
```

**Key Points:**
- `stringData` in Secrets is base64-encoded automatically by Kubernetes on apply
- For production, prefer external secret managers (AWS Secrets Manager, HashiCorp Vault, Sealed Secrets) over plain Kubernetes Secrets, which are only base64-encoded at rest by default [Inference]
- `envFrom` bulk-injects all keys; individual `env[].valueFrom` entries allow selective injection

---

### Liveness and Readiness Probes in Fastify

Probes are central to Kubernetes reliability. Fastify makes implementing them straightforward.

**Example — dedicated health plugin:**

```js
// plugins/health.js
import fp from 'fastify-plugin'

export default fp(async function health(app) {
  let isReady = false

  app.addHook('onReady', async () => {
    isReady = true
  })

  app.get('/healthz', { logLevel: 'silent' }, async (req, reply) => {
    // Liveness: is the process alive and responsive?
    reply.send({ status: 'ok' })
  })

  app.get('/readyz', { logLevel: 'silent' }, async (req, reply) => {
    // Readiness: is the app ready to serve traffic?
    if (!isReady) {
      return reply.code(503).send({ status: 'not ready' })
    }
    reply.send({ status: 'ready' })
  })
})
```

**Key Points:**
- `logLevel: 'silent'` suppresses probe log noise in high-frequency polling environments
- The `onReady` hook fires after all plugins are registered and the server is listening — making it a reliable readiness signal
- Liveness and readiness serve different purposes: liveness restarts a broken process; readiness removes it from the load balancer temporarily

---

### Rolling Updates and Deployment Strategy

Kubernetes performs rolling updates by default when the Deployment spec changes (e.g., a new image tag).

**Example — explicit strategy in `deployment.yaml`:**

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

**Key Points:**
- `maxUnavailable: 0` prevents any Pod from being terminated before a replacement is ready — important for zero-downtime deploys
- `maxSurge: 1` allows one extra Pod above the desired replica count during the rollout
- Combined with a solid `readinessProbe`, this pattern avoids routing traffic to Pods that are still initializing [Inference — actual behavior depends on cluster state and probe timing]

**Triggering a rollout:**

```bash
# Update the image tag
kubectl set image deployment/fastify-app fastify-app=your-registry/fastify-app:1.1.0

# Monitor rollout status
kubectl rollout status deployment/fastify-app

# Rollback if needed
kubectl rollout undo deployment/fastify-app
```

---

### Resource Requests and Limits

Kubernetes uses resource requests for scheduling and limits for enforcement.

| Field | Purpose | Effect if exceeded |
|---|---|---|
| `requests.cpu` | Scheduling guarantee | Pod may be placed on a node with sufficient headroom |
| `limits.cpu` | CPU throttle cap | Process is throttled, not killed |
| `requests.memory` | Scheduling guarantee | Pod is placed on a node with sufficient memory |
| `limits.memory` | Memory hard cap | Pod is OOMKilled and restarted |

**Key Points:**
- Set `requests` conservatively based on observed Fastify idle consumption (~30–60 MB for a basic app) [Unverified — measure your own application]
- Set `limits` high enough to absorb traffic spikes without OOMKill
- CPU throttling on Node.js can degrade event loop throughput more than memory pressure — monitor `process.hrtime` or APM event loop lag metrics [Inference]

---

### Namespace and Labels Best Practices

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
```

```bash
kubectl apply -f . -n production
```

**Key Points:**
- Namespaces provide isolation between environments (development, staging, production) within the same cluster
- Consistent labels (`app`, `version`, `env`) enable targeted queries: `kubectl get pods -l app=fastify-app,env=production`
- Labels are also used by monitoring tools (Prometheus, Datadog) for metric aggregation

---

### Full Deployment Flow Diagram

<svg viewBox="0 0 780 520" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Background -->
  <rect width="780" height="520" fill="#0f1117" rx="12"/>

  <!-- Title -->
  <text x="390" y="36" text-anchor="middle" fill="#e2e8f0" font-size="15" font-weight="bold">Fastify → Kubernetes Deployment Flow</text>

  <!-- Step boxes -->
  <!-- 1: Source -->
  <rect x="30" y="70" width="140" height="52" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="100" y="91" text-anchor="middle" fill="#38bdf8" font-weight="bold">Source Code</text>
  <text x="100" y="110" text-anchor="middle" fill="#94a3b8" font-size="11">server.js / plugins</text>

  <!-- Arrow 1→2 -->
  <line x1="170" y1="96" x2="210" y2="96" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- 2: Docker Build -->
  <rect x="210" y="70" width="140" height="52" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="280" y="91" text-anchor="middle" fill="#38bdf8" font-weight="bold">docker build</text>
  <text x="280" y="110" text-anchor="middle" fill="#94a3b8" font-size="11">Dockerfile (multi-stage)</text>

  <!-- Arrow 2→3 -->
  <line x1="350" y1="96" x2="390" y2="96" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- 3: Registry -->
  <rect x="390" y="70" width="140" height="52" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="460" y="91" text-anchor="middle" fill="#38bdf8" font-weight="bold">docker push</text>
  <text x="460" y="110" text-anchor="middle" fill="#94a3b8" font-size="11">Container Registry</text>

  <!-- Arrow 3→4 -->
  <line x1="530" y1="96" x2="570" y2="96" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- 4: kubectl apply -->
  <rect x="570" y="70" width="150" height="52" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="645" y="91" text-anchor="middle" fill="#38bdf8" font-weight="bold">kubectl apply</text>
  <text x="645" y="110" text-anchor="middle" fill="#94a3b8" font-size="11">Deployment + Service</text>

  <!-- Kubernetes Cluster Box -->
  <rect x="30" y="170" width="720" height="310" rx="10" fill="#0f172a" stroke="#334155" stroke-width="1.5" stroke-dasharray="6,3"/>
  <text x="50" y="195" fill="#64748b" font-size="12">Kubernetes Cluster</text>

  <!-- Ingress -->
  <rect x="60" y="210" width="140" height="52" rx="8" fill="#1e2d40" stroke="#818cf8" stroke-width="1.5"/>
  <text x="130" y="231" text-anchor="middle" fill="#818cf8" font-weight="bold">Ingress</text>
  <text x="130" y="250" text-anchor="middle" fill="#94a3b8" font-size="11">api.example.com</text>

  <!-- Arrow Ingress→Service -->
  <line x1="200" y1="236" x2="240" y2="236" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- Service -->
  <rect x="240" y="210" width="140" height="52" rx="8" fill="#1e2d40" stroke="#818cf8" stroke-width="1.5"/>
  <text x="310" y="231" text-anchor="middle" fill="#818cf8" font-weight="bold">Service</text>
  <text x="310" y="250" text-anchor="middle" fill="#94a3b8" font-size="11">ClusterIP :80</text>

  <!-- Arrows Service→Pods -->
  <line x1="380" y1="236" x2="420" y2="260" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>
  <line x1="380" y1="236" x2="420" y2="320" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>
  <line x1="380" y1="236" x2="420" y2="380" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- Pod 1 -->
  <rect x="420" y="240" width="140" height="52" rx="8" fill="#14291f" stroke="#4ade80" stroke-width="1.5"/>
  <text x="490" y="261" text-anchor="middle" fill="#4ade80" font-weight="bold">Pod 1</text>
  <text x="490" y="280" text-anchor="middle" fill="#94a3b8" font-size="11">fastify-app :3000</text>

  <!-- Pod 2 -->
  <rect x="420" y="300" width="140" height="52" rx="8" fill="#14291f" stroke="#4ade80" stroke-width="1.5"/>
  <text x="490" y="321" text-anchor="middle" fill="#4ade80" font-weight="bold">Pod 2</text>
  <text x="490" y="340" text-anchor="middle" fill="#94a3b8" font-size="11">fastify-app :3000</text>

  <!-- Pod 3 -->
  <rect x="420" y="360" width="140" height="52" rx="8" fill="#14291f" stroke="#4ade80" stroke-width="1.5"/>
  <text x="490" y="381" text-anchor="middle" fill="#4ade80" font-weight="bold">Pod 3</text>
  <text x="490" y="400" text-anchor="middle" fill="#94a3b8" font-size="11">fastify-app :3000</text>

  <!-- ConfigMap + Secret -->
  <rect x="590" y="240" width="130" height="52" rx="8" fill="#1e1a2e" stroke="#c084fc" stroke-width="1.5"/>
  <text x="655" y="261" text-anchor="middle" fill="#c084fc" font-weight="bold">ConfigMap</text>
  <text x="655" y="280" text-anchor="middle" fill="#94a3b8" font-size="11">LOG_LEVEL, PORT</text>

  <rect x="590" y="310" width="130" height="52" rx="8" fill="#1e1a2e" stroke="#c084fc" stroke-width="1.5"/>
  <text x="655" y="331" text-anchor="middle" fill="#c084fc" font-weight="bold">Secret</text>
  <text x="655" y="350" text-anchor="middle" fill="#94a3b8" font-size="11">DB_URL, JWT_SECRET</text>

  <!-- Probe labels -->
  <text x="420" y="430" fill="#64748b" font-size="11">↑ livenessProbe: /healthz   readinessProbe: /readyz</text>

  <!-- Legend external traffic -->
  <text x="40" y="500" fill="#64748b" font-size="11">External traffic → Ingress → Service (ClusterIP) → Pods (load balanced)</text>

  <!-- Arrow marker -->
  <defs>
    <marker id="arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#475569"/>
    </marker>
  </defs>
</svg>

---

### Applying the Manifests

```bash
# Apply all manifests in a directory
kubectl apply -f k8s/ -n production

# Verify Deployment rollout
kubectl rollout status deployment/fastify-app -n production

# Watch Pods come up
kubectl get pods -n production -w

# Inspect a specific Pod's logs
kubectl logs -f deployment/fastify-app -n production

# Describe a Pod for event history
kubectl describe pod <pod-name> -n production
```

---

### Common Pitfalls

#### App Binding to localhost

Fastify must bind to `0.0.0.0` inside a container. Binding to `127.0.0.1` (the Node.js default for some configurations) means the container's network interface is not reachable and the Pod will fail readiness checks.

#### Missing Graceful Shutdown

Without handling `SIGTERM`, Fastify will exit immediately when Kubernetes sends the termination signal, dropping in-flight requests. Always call `app.close()` on `SIGTERM`. [See the graceful shutdown module for the full pattern.]

#### Image Tag `latest`

Using `latest` as an image tag disables Kubernetes's ability to detect changes. Always use a specific versioned tag (e.g., a Git SHA or semantic version) for deterministic rollouts.

#### Insufficient `terminationGracePeriodSeconds`

If your Fastify app takes longer than `terminationGracePeriodSeconds` to drain connections, Kubernetes will send SIGKILL, bypassing graceful shutdown entirely. Set this value to exceed your p99 request duration plus the `preStop` sleep duration [Inference].

---

### Recommended Directory Structure

```
project/
├── src/
│   └── server.js
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── Dockerfile
└── package.json
```

---

**Related Topics:**
- Horizontal Pod Autoscaler (HPA) for CPU/memory-based scaling
- Kubernetes resource quotas and LimitRanges per namespace
- Helm charts for templated, reusable Kubernetes manifests
- Kustomize for environment-specific overlay management
- Persistent Volumes and StatefulSets for stateful Fastify workloads
- Pod Disruption Budgets (PDB) for availability guarantees during node maintenance
- Service mesh integration (Istio, Linkerd) for mTLS and advanced traffic management
- CI/CD pipeline integration (GitHub Actions, ArgoCD, Flux) for automated Kubernetes deploys
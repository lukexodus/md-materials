## Service Discovery Patterns

### What is Service Discovery

Service discovery is the mechanism by which services in a distributed system locate each other at runtime without hardcoded addresses. In a microservices architecture, service instances start, stop, scale, and move across hosts dynamically — static configuration cannot track this. Service discovery automates address resolution.

**Key Points**

- Service discovery has two halves: **registration** (a service announces itself) and **resolution** (a caller finds the service's current address)
- Discovery can be **client-side** (the caller resolves the address) or **server-side** (a load balancer or proxy resolves it on the caller's behalf)
- Fastify has no built-in service discovery; it is composed from plugins, environment configuration, and external infrastructure
- [Inference] The correct discovery pattern depends on the deployment platform — Kubernetes, bare-metal VMs, and Docker Swarm each have different native capabilities

---

### Discovery Pattern Taxonomy

Service DiscoveryPatternsClient-Side DiscoveryServer-Side DiscoveryConsulEurekaetcdKubernetes DNS +ServicesCloud Load Balancers(ALB, GCP LB)Service Mesh(Istio, Linkerd)Hybrid / DNS-BasedCoreDNSRoute 53 / Cloud DNS

---

### DNS-Based Discovery (Kubernetes)

The most common pattern for Fastify services on Kubernetes. The platform maintains DNS records for every Service object automatically — no discovery library is needed in application code.

#### How It Works

When a Kubernetes `Service` is created, CoreDNS assigns it a stable DNS name:

```
<service-name>.<namespace>.svc.cluster.local
```

All pods in the cluster resolve this name to the Service's ClusterIP, which then load-balances across healthy pod endpoints.

#### Fastify Configuration

js

```js
// config.js
export const config = {
  usersServiceUrl: process.env.USERS_SERVICE_URL
    ?? 'http://users-service.default.svc.cluster.local:4001',

  ordersServiceUrl: process.env.ORDERS_SERVICE_URL
    ?? 'http://orders-service.default.svc.cluster.local:3001',

  paymentsServiceUrl: process.env.PAYMENTS_SERVICE_URL
    ?? 'http://payments-service.payments.svc.cluster.local:5001'
}
```

js

```js
// plugins/serviceClients.js
import fp from 'fastify-plugin'
import { request } from 'undici'
import { config } from '../config.js'

async function serviceClientsPlugin(app, opts) {
  app.decorate('services', {
    users: makeClient(config.usersServiceUrl, app),
    orders: makeClient(config.ordersServiceUrl, app),
    payments: makeClient(config.paymentsServiceUrl, app)
  })
}

function makeClient(baseUrl, app) {
  return {
    async get(path, headers = {}) {
      const { statusCode, body } = await request(`${baseUrl}${path}`, {
        method: 'GET',
        headers: { 'content-type': 'application/json', ...headers }
      })
      if (statusCode >= 400) {
        throw Object.assign(new Error(`Upstream error: ${statusCode}`), { statusCode })
      }
      return body.json()
    },

    async post(path, payload, headers = {}) {
      const { statusCode, body } = await request(`${baseUrl}${path}`, {
        method: 'POST',
        headers: { 'content-type': 'application/json', ...headers },
        body: JSON.stringify(payload)
      })
      if (statusCode >= 400) {
        throw Object.assign(new Error(`Upstream error: ${statusCode}`), { statusCode })
      }
      return body.json()
    }
  }
}

export default fp(serviceClientsPlugin)
```

**Key Points**

- DNS TTL in Kubernetes is typically very short (5–30 seconds) — clients that cache DNS responses aggressively may route to stale pod IPs [Inference]
- `undici` does not cache DNS by default; each connection resolves the name fresh [Inference — verify with undici version]
- Cross-namespace calls require the full DNS name including namespace; same-namespace calls can use just `<service-name>`
- Headless Services (`clusterIP: None`) return individual pod IPs instead of a virtual IP — useful for client-side load balancing or stateful services like databases

---

### Kubernetes Service Manifest

yaml

```yaml
# users-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: users-service
  namespace: default
  labels:
    app: users-service
spec:
  selector:
    app: users-service     # Routes to pods with this label
  ports:
    - name: http
      port: 4001
      targetPort: 4001
  type: ClusterIP           # Internal only — not exposed outside cluster
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: users-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: users-service
  template:
    metadata:
      labels:
        app: users-service
    spec:
      containers:
        - name: users-service
          image: myregistry/users-service:1.2.0
          ports:
            - containerPort: 4001
          env:
            - name: PORT
              value: "4001"
          readinessProbe:
            httpGet:
              path: /readyz
              port: 4001
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /livez
              port: 4001
            initialDelaySeconds: 10
            periodSeconds: 30
```

**Key Points**

- The `readinessProbe` controls whether a pod receives traffic — Fastify's `/readyz` endpoint must return a non-2xx status when the service is not ready (e.g., DB connection not established)
- Kubernetes removes an unready pod from the Service endpoints list within seconds [Inference] — callers retry or fail over automatically
- `ClusterIP` services are unreachable from outside the cluster; `LoadBalancer` or `Ingress` objects expose services externally

---

### Consul-Based Client-Side Discovery

Consul is a dedicated service registry and health-checking system. Services register themselves and query the registry to find peers.

#### Installing

bash

```bash
npm install consul
```

#### Registration Plugin

js

```js
// plugins/consulRegister.js
import fp from 'fastify-plugin'
import Consul from 'consul'
import { randomUUID } from 'crypto'
import os from 'os'

async function consulRegisterPlugin(app, opts) {
  const consul = new Consul({
    host: process.env.CONSUL_HOST ?? 'localhost',
    port: process.env.CONSUL_PORT ?? 8500,
    promisify: true
  })

  const serviceId = `${opts.serviceName}-${randomUUID()}`
  const host = opts.host ?? os.hostname()
  const port = opts.port ?? 3000

  // Register this service instance with Consul
  await consul.agent.service.register({
    id: serviceId,
    name: opts.serviceName,
    address: host,
    port,
    tags: [`version:${opts.version ?? '1.0.0'}`, 'fastify'],
    check: {
      http: `http://${host}:${port}/health`,
      interval: '10s',
      deregistercriticalserviceafter: '1m'
    }
  })

  app.log.info(
    { serviceId, host, port },
    `Registered with Consul as ${opts.serviceName}`
  )

  // Deregister on shutdown
  app.addHook('onClose', async () => {
    await consul.agent.service.deregister(serviceId)
    app.log.info({ serviceId }, 'Deregistered from Consul')
  })

  app.decorate('consul', consul)
  app.decorate('serviceId', serviceId)
}

export default fp(consulRegisterPlugin)
```

#### Discovery Plugin with Round-Robin Load Balancing

js

```js
// plugins/consulDiscover.js
import fp from 'fastify-plugin'

async function consulDiscoverPlugin(app, opts) {
  // Per-service round-robin counters
  const counters = new Map()

  app.decorate('discover', async (serviceName) => {
    const instances = await app.consul.health.service({
      service: serviceName,
      passing: true    // Only healthy instances
    })

    if (!instances.length) {
      throw new Error(`No healthy instances of "${serviceName}" found in Consul`)
    }

    // Round-robin selection
    const count = (counters.get(serviceName) ?? 0) % instances.length
    counters.set(serviceName, count + 1)

    const { Service } = instances[count]
    return `http://${Service.Address}:${Service.Port}`
  })
}

export default fp(consulDiscoverPlugin)
```

#### Using Discovery in a Route

js

```js
app.get('/checkout/:orderId', async (request, reply) => {
  const orderId = request.params.orderId

  // Resolve address at call time — not at startup
  const paymentsUrl = await app.discover('payments-service')
  const usersUrl    = await app.discover('users-service')

  const [order, user] = await Promise.all([
    app.db.getOrder(orderId),
    app.services.users.get(`/users/${request.user.id}`)
  ])

  const payment = await request(`${paymentsUrl}/payments`, {
    method: 'POST',
    body: JSON.stringify({ orderId, amount: order.total })
  })

  return { order, user, payment }
})
```

**Key Points**

- Consul health checks run independently of the caller — a failed instance is removed from the registry within one check interval
- Round-robin is a simple load balancing strategy; weighted round-robin or least-connections requires additional logic [Inference]
- Querying Consul on every request adds latency — caching results with a short TTL (e.g., 5 seconds) is a common optimization [Inference — cache invalidation correctness depends on TTL vs. check interval alignment]
- `deregistercriticalserviceafter` automatically removes instances that fail health checks for the specified duration, preventing stale registrations from crashed pods

---

### Consul Discovery with Result Caching

js

```js
// plugins/consulDiscoverCached.js
import fp from 'fastify-plugin'

const CACHE_TTL_MS = 5000

async function consulDiscoverCachedPlugin(app, opts) {
  // { serviceName -> { instances, expiresAt, counter } }
  const cache = new Map()

  app.decorate('discover', async (serviceName) => {
    const now = Date.now()
    const cached = cache.get(serviceName)

    let instances
    if (cached && cached.expiresAt > now) {
      instances = cached.instances
    } else {
      instances = await app.consul.health.service({
        service: serviceName,
        passing: true
      })

      if (!instances.length) {
        // Fall back to stale cache if available — prefer stale over error
        if (cached?.instances?.length) {
          app.log.warn(
            { serviceName },
            'Consul returned no healthy instances — using stale cache'
          )
          instances = cached.instances
        } else {
          throw new Error(`No instances of "${serviceName}" available`)
        }
      }

      cache.set(serviceName, {
        instances,
        expiresAt: now + CACHE_TTL_MS,
        counter: cached?.counter ?? 0
      })
    }

    const entry = cache.get(serviceName)
    const idx = entry.counter % instances.length
    entry.counter++

    const { Service } = instances[idx]
    return `http://${Service.Address}:${Service.Port}`
  })
}

export default fp(consulDiscoverCachedPlugin)
```

**Key Points**

- Stale-on-error behavior (returning cached results when Consul is temporarily unavailable) improves resilience at the cost of potentially routing to a recently failed instance [Inference]
- Cache TTL must be shorter than the Consul check interval to limit the window where a failed instance remains in cache
- This cache is in-process — multiple Fastify instances do not share it; each maintains its own view of the registry [Inference]

---

### etcd-Based Discovery

etcd is a distributed key-value store used by Kubernetes internally and as a standalone service registry.

bash

```bash
npm install etcd3
```

js

```js
// plugins/etcdDiscover.js
import fp from 'fastify-plugin'
import { Etcd3 } from 'etcd3'

async function etcdPlugin(app, opts) {
  const etcd = new Etcd3({
    hosts: (process.env.ETCD_HOSTS ?? 'localhost:2379').split(',')
  })

  const serviceName = opts.serviceName
  const serviceKey  = `/services/${serviceName}/${app.serviceId}`
  const serviceValue = JSON.stringify({
    host: opts.host,
    port: opts.port,
    version: opts.version
  })

  // Register with a lease — auto-expires if process dies
  const lease = etcd.lease(10)  // 10-second TTL
  await lease.put(serviceKey).value(serviceValue)

  // Keep-alive renews the lease while the process is healthy
  lease.on('lost', async () => {
    app.log.warn('etcd lease lost — attempting to re-register')
    await lease.put(serviceKey).value(serviceValue)
  })

  // Discover peers
  app.decorate('discover', async (targetService) => {
    const prefix = `/services/${targetService}/`
    const instances = await etcd.getAll().prefix(prefix).strings()

    const addrs = Object.values(instances).map(v => JSON.parse(v))
    if (!addrs.length) {
      throw new Error(`No instances of "${targetService}" in etcd`)
    }

    const picked = addrs[Math.floor(Math.random() * addrs.length)]
    return `http://${picked.host}:${picked.port}`
  })

  app.addHook('onClose', async () => {
    await lease.revoke()
    await etcd.close()
  })

  app.decorate('etcd', etcd)
}

export default fp(etcdPlugin)
```

**Key Points**

- etcd leases expire automatically if the process crashes without revoking — stale registrations are cleaned up by TTL, not by explicit deregistration
- Watch API on etcd enables push-based discovery (react to registry changes) rather than polling [Inference — watch support depends on etcd3 library version]
- etcd is strongly consistent (Raft consensus); Consul offers eventual consistency by default with optional strong consistency mode

---

### Server-Side Discovery via Kubernetes Ingress and Load Balancer

For external traffic or inter-cluster communication, Kubernetes Ingress controllers (Nginx, Traefik, Envoy) act as server-side discovery proxies.

yaml

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /users
            pathType: Prefix
            backend:
              service:
                name: users-service
                port:
                  number: 4001
          - path: /orders
            pathType: Prefix
            backend:
              service:
                name: orders-service
                port:
                  number: 3001
```

In this pattern, Fastify services have no discovery logic — the Ingress controller handles routing. Services are addressed by path prefix; clients call a single stable hostname.

---

### Service Mesh Discovery (Istio / Linkerd)

A service mesh injects a sidecar proxy (Envoy for Istio, a Rust proxy for Linkerd) into every pod. The sidecar intercepts all network traffic and handles discovery, load balancing, retries, and mTLS transparently.

**From Fastify's perspective, no discovery code is needed:**

js

```js
// Fastify code looks identical to single-service code
// The sidecar resolves addresses, balances load, and retries failures

const { body } = await request('http://users-service/users/1')
// Sidecar intercepts, resolves, load balances, adds mTLS — transparently
```

**Key Points**

- Service mesh offloads discovery, load balancing, circuit breaking, and observability from application code entirely [Inference — specific capabilities depend on the mesh and its configuration]
- The tradeoff is operational complexity: running a mesh requires managing the control plane (Istiod, Linkerd control plane), sidecar injection policies, and mTLS certificates
- Fastify application code becomes simpler but the infrastructure layer becomes more complex
- Metrics (latency, error rate, throughput) are emitted by the sidecar, not by Fastify — Fastify's own metrics and the mesh metrics cover different layers [Inference]

---

### Diagram: Client-Side vs. Server-Side Discovery

Target ServiceService Registry(Consul / etcd)Caller (Fastify)Target ServiceService Registry(Consul / etcd)Caller (Fastify)Client-Side DiscoveryServer-Side DiscoveryLoad balancer / proxyresolves and routeslookup("users-service")[10.0.1.5:4001, 10.0.1.6:4001]HTTP request → 10.0.1.5:4001HTTP request → users-service (DNS / VIP)Response

---

### Comparing Discovery Approaches

| Approach | Complexity | Latency Added | Works Without K8s | Dynamic Updates |
| --- | --- | --- | --- | --- |
| DNS (Kubernetes) | Low | Negligible | No | Yes (via endpoint controller) |
| Consul | Medium | ~1–5ms per lookup | Yes | Yes |
| etcd | Medium | ~1–5ms per lookup | Yes | Yes (watch API) |
| Ingress / LB | Low (infra only) | Negligible | Partial | Yes |
| Service Mesh | High (infra) | ~1ms sidecar overhead [Inference] | No (complex) | Yes |
| Hardcoded ENV | None | None | Yes | No — requires redeployment |

---

### Self-Registration vs. Third-Party Registration

#### Self-Registration

The service registers itself on startup and deregisters on shutdown (examples above). Simple to implement; registration logic lives in the service.

**Drawback:** if the process crashes before the `onClose` hook runs, the registration remains until the health check TTL expires.

#### Third-Party Registration (Kubernetes Operator or Registrar Sidecar)

A separate process monitors service health and manages registry entries:

yaml

```yaml
# Kubernetes: the kubelet monitors pod health and updates Endpoints automatically
# No registration code in Fastify is needed
```

For non-Kubernetes environments, a registrar sidecar (e.g., `registrator`) watches Docker events and registers/deregisters containers automatically.

**Key Points**

- Third-party registration decouples registration logic from service code — services do not need discovery SDKs
- Self-registration is simpler for small teams; third-party registration scales better operationally [Inference]
- In Kubernetes, the endpoint controller is the canonical third-party registrar — it watches pod readiness and updates Service endpoints accordingly

---

### Retry and Timeout Configuration for Discovered Services

Discovery resolves an address; resilient calling requires retry and timeout policies:

js

```js
// plugins/resilientClient.js
import fp from 'fastify-plugin'
import { request } from 'undici'

async function resilientClientPlugin(app, opts) {
  app.decorate('resilientGet', async (url, options = {}) => {
    const {
      retries = 3,
      timeoutMs = 5000,
      retryOn = [503, 429],
      correlationId
    } = options

    let lastError
    for (let attempt = 1; attempt <= retries; attempt++) {
      try {
        const { statusCode, body } = await request(url, {
          method: 'GET',
          headersTimeout: timeoutMs,
          bodyTimeout: timeoutMs,
          headers: {
            'x-correlation-id': correlationId,
            'x-retry-attempt': String(attempt)
          }
        })

        if (retryOn.includes(statusCode)) {
          lastError = new Error(`Retryable status: ${statusCode}`)
          // Exponential backoff
          await sleep(Math.min(100 * 2 ** attempt, 2000))
          continue
        }

        return { statusCode, data: await body.json() }
      } catch (err) {
        lastError = err
        app.log.warn({ err, attempt, url }, 'Request failed — retrying')
        await sleep(Math.min(100 * 2 ** attempt, 2000))
      }
    }

    throw lastError
  })
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms))
}

export default fp(resilientClientPlugin)
```

**Key Points**

- Retry on `503` (service unavailable) and `429` (rate limited) is appropriate; retrying `400` or `500` is generally not [Inference]
- Exponential backoff with jitter reduces thundering herd — adding random jitter to the backoff delay distributes retries across time [Inference — jitter implementation omitted above for clarity]
- The `x-retry-attempt` header lets downstream services log and distinguish original requests from retries
- Retries amplify load on a struggling downstream — combine with circuit breakers to avoid compounding failures

---

### Testing Discovery Logic

js

```js
import { test } from 'node:test'
import assert from 'node:assert'
import Fastify from 'fastify'
import consulDiscoverPlugin from '../plugins/consulDiscover.js'

test('discover returns address of healthy instance', async (t) => {
  const app = Fastify()

  // Stub the consul decorator before registering the plugin
  app.decorate('consul', {
    health: {
      service: async ({ service }) => {
        if (service === 'users-service') {
          return [
            { Service: { Address: '10.0.0.1', Port: 4001 } },
            { Service: { Address: '10.0.0.2', Port: 4001 } }
          ]
        }
        return []
      }
    }
  })

  await app.register(consulDiscoverPlugin)
  t.after(() => app.close())

  const addr = await app.discover('users-service')
  assert.match(addr, /^http:\/\/10\.0\.0\.[12]:4001$/)
})

test('discover throws when no instances available', async (t) => {
  const app = Fastify()

  app.decorate('consul', {
    health: { service: async () => [] }
  })

  await app.register(consulDiscoverPlugin)
  t.after(() => app.close())

  await assert.rejects(
    () => app.discover('missing-service'),
    /No healthy instances/
  )
})
```

---

**Related Topics**

- Load balancing strategies: round-robin, least-connections, consistent hashing
- mTLS between services with Istio and Fastify
- Consul Connect for service-to-service authorization
- etcd watch API for push-based discovery in Fastify
- gRPC service discovery with name resolvers
- Kubernetes EndpointSlices vs. Endpoints for large-scale service discovery
- Chaos engineering: testing discovery resilience with pod failure injection
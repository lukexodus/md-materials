## Fastify in a Microservices Architecture

### What is a Microservices Architecture

A microservices architecture decomposes an application into small, independently deployable services, each owning a bounded domain and communicating over a network. Fastify is well-suited for this pattern due to its low overhead, plugin encapsulation model, and structured logging — all relevant at the per-service level.

This topic covers how Fastify services are structured, how they communicate, how they are observed, and how they are deployed in a microservices context.

**Key Points**

- Each Fastify instance is one service — there is no built-in microservices framework; patterns are composed from plugins and conventions
- Communication between services can be synchronous (HTTP, gRPC) or asynchronous (message queues)
- Fastify's plugin system maps naturally to bounded domain encapsulation within a single service
- [Inference] The operational complexity of microservices (networking, deployment, observability) is independent of Fastify itself; Fastify reduces per-service overhead but does not address orchestration

---

### Service Boundaries and Fastify Plugin Encapsulation

Within a single Fastify service, the plugin system enforces domain encapsulation. Each plugin owns its routes, decorators, and hooks without leaking into siblings.

js

```js
// services/orders/index.js
import Fastify from 'fastify'
import ordersPlugin from './plugins/orders.js'
import dbPlugin from './plugins/db.js'
import authPlugin from './plugins/auth.js'

const app = Fastify({ logger: true })

// Shared infrastructure — registered at root scope
await app.register(dbPlugin)
await app.register(authPlugin)

// Domain logic — encapsulated
await app.register(ordersPlugin, { prefix: '/orders' })

await app.listen({ port: 3001, host: '0.0.0.0' })
```

js

```js
// plugins/orders.js
import fp from 'fastify-plugin'

async function ordersPlugin(app, opts) {
  // Only routes, hooks, and decorators scoped here
  app.get('/', async (request, reply) => {
    return app.db.getOrders()
  })

  app.post('/', async (request, reply) => {
    return app.db.createOrder(request.body)
  })
}

// fp() — fastify-plugin — breaks encapsulation intentionally
// Do NOT use fp() here; this plugin should stay scoped
export default ordersPlugin
```

**Key Points**

- `fastify-plugin` (`fp`) makes a plugin's decorators and hooks visible to the parent scope — use it for shared infrastructure (DB, auth), not for domain logic
- Domain plugins should remain encapsulated (not wrapped in `fp`) to avoid coupling between service domains
- A single Fastify process can host multiple domain plugins behind a prefix — this is a **modular monolith** pattern, not microservices, but the same plugin structure applies when splitting into separate services

---

### Service-to-Service HTTP Communication

The simplest inter-service communication mechanism is HTTP. Fastify services call each other via an HTTP client.

#### Using `undici` (Node.js Built-in HTTP Client)

js

```js
import { request } from 'undici'

async function getUserById(userId) {
  const { statusCode, body } = await request(
    `http://users-service:4001/users/${userId}`,
    {
      method: 'GET',
      headers: {
        'content-type': 'application/json',
        'x-service-name': 'orders-service'
      }
    }
  )

  if (statusCode !== 200) {
    throw new Error(`users-service returned ${statusCode}`)
  }

  return body.json()
}
```

#### Encapsulating the Client as a Fastify Plugin

js

```js
// plugins/usersClient.js
import fp from 'fastify-plugin'
import { request } from 'undici'

async function usersClientPlugin(app, opts) {
  const baseUrl = opts.usersServiceUrl ?? process.env.USERS_SERVICE_URL

  app.decorate('usersClient', {
    async getUser(id) {
      const { statusCode, body } = await request(`${baseUrl}/users/${id}`)
      if (statusCode !== 200) throw new Error(`users-service: ${statusCode}`)
      return body.json()
    },

    async getUsersByIds(ids) {
      const { statusCode, body } = await request(`${baseUrl}/users/batch`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ ids })
      })
      if (statusCode !== 200) throw new Error(`users-service batch: ${statusCode}`)
      return body.json()
    }
  })
}

export default fp(usersClientPlugin)
```

js

```js
// In the orders service
await app.register(usersClientPlugin, {
  usersServiceUrl: process.env.USERS_SERVICE_URL
})

app.get('/orders/:id', async (request) => {
  const order = await app.db.getOrder(request.params.id)
  const user = await app.usersClient.getUser(order.userId)
  return { order, user }
})
```

**Key Points**

- Wrapping HTTP clients in `fp` plugins makes them available on the Fastify instance, enabling injection in tests
- Service URLs should come from environment variables, not hardcoded values
- [Inference] Connection pooling in `undici` reduces overhead for high-frequency inter-service calls; default pool settings may need tuning under load

---

### Service Discovery

In dynamic environments (Kubernetes, Docker Swarm), service addresses are not static. Service discovery resolves a service name to a current address.

#### DNS-Based Discovery (Kubernetes)

In Kubernetes, each service gets a DNS name automatically:

js

```js
// Kubernetes DNS: <service-name>.<namespace>.svc.cluster.local
const USERS_SERVICE_URL = process.env.USERS_SERVICE_URL
  ?? 'http://users-service.default.svc.cluster.local:4001'
```

No additional library is needed — Kubernetes handles DNS resolution. This is the most common pattern for Fastify microservices on Kubernetes. [Inference]

#### Consul-Based Discovery

bash

```bash
npm install consul
```

js

```js
import fp from 'fastify-plugin'
import Consul from 'consul'

async function consulPlugin(app, opts) {
  const consul = new Consul({ host: process.env.CONSUL_HOST })

  app.decorate('discover', async (serviceName) => {
    const services = await consul.health.service({
      service: serviceName,
      passing: true
    })

    if (!services.length) throw new Error(`No healthy instances of ${serviceName}`)

    // Simple round-robin [Inference] — production use may require more sophisticated load balancing
    const instance = services[Math.floor(Math.random() * services.length)]
    const { Address, Port } = instance.Service
    return `http://${Address}:${Port}`
  })
}

export default fp(consulPlugin)
```

---

### Asynchronous Communication with Message Queues

Synchronous HTTP between services creates temporal coupling — if the downstream service is unavailable, the upstream request fails. Message queues decouple services in time.

#### RabbitMQ with `amqplib`

bash

```bash
npm install amqplib
```

js

```js
// plugins/rabbitmq.js
import fp from 'fastify-plugin'
import amqplib from 'amqplib'

async function rabbitmqPlugin(app, opts) {
  const connection = await amqplib.connect(process.env.RABBITMQ_URL)
  const channel = await connection.createChannel()

  app.decorate('mq', {
    async publish(exchange, routingKey, message) {
      channel.publish(
        exchange,
        routingKey,
        Buffer.from(JSON.stringify(message)),
        { persistent: true, contentType: 'application/json' }
      )
    },

    async subscribe(queue, handler) {
      await channel.assertQueue(queue, { durable: true })
      channel.consume(queue, async (msg) => {
        if (!msg) return
        try {
          const content = JSON.parse(msg.content.toString())
          await handler(content)
          channel.ack(msg)
        } catch (err) {
          app.log.error({ err }, 'Message processing failed')
          // Negative acknowledgement — requeue for retry
          channel.nack(msg, false, true)
        }
      })
    }
  })

  app.addHook('onClose', async () => {
    await channel.close()
    await connection.close()
  })
}

export default fp(rabbitmqPlugin)
```

js

```js
// Publishing an event from the orders service
app.post('/orders', async (request, reply) => {
  const order = await app.db.createOrder(request.body)

  await app.mq.publish('orders', 'order.created', {
    orderId: order.id,
    userId: order.userId,
    total: order.total,
    createdAt: new Date().toISOString()
  })

  reply.code(201)
  return order
})

// Consuming events in the notifications service
await app.mq.subscribe('notifications.order.created', async (event) => {
  await sendOrderConfirmationEmail(event.userId, event.orderId)
})
```

#### Kafka with `kafkajs`

bash

```bash
npm install kafkajs
```

js

```js
// plugins/kafka.js
import fp from 'fastify-plugin'
import { Kafka } from 'kafkajs'

async function kafkaPlugin(app, opts) {
  const kafka = new Kafka({
    clientId: opts.clientId,
    brokers: (process.env.KAFKA_BROKERS ?? 'localhost:9092').split(',')
  })

  const producer = kafka.producer()
  await producer.connect()

  app.decorate('kafka', {
    producer,
    async send(topic, messages) {
      await producer.send({
        topic,
        messages: messages.map(m => ({
          key: m.key,
          value: JSON.stringify(m.value)
        }))
      })
    }
  })

  app.addHook('onClose', async () => {
    await producer.disconnect()
  })
}

export default fp(kafkaPlugin)
```

**Key Points**

- Message queues introduce at-least-once delivery semantics — consumers must handle duplicate messages idempotently
- Persistent messages (`persistent: true` in RabbitMQ) survive broker restarts; in-memory queues do not
- Dead letter queues (DLQ) capture messages that fail processing repeatedly — configure these in production [Inference]
- Kafka retains messages in a log; RabbitMQ removes messages after acknowledgement — this affects replay and audit capabilities

---

### Correlation IDs and Distributed Request Tracing

In microservices, a single client request may touch multiple services. Correlation IDs propagate a single identifier across the entire chain for log correlation.

js

```js
// plugins/correlationId.js
import fp from 'fastify-plugin'
import { randomUUID } from 'crypto'

async function correlationIdPlugin(app, opts) {
  app.addHook('onRequest', async (request) => {
    request.correlationId =
      request.headers['x-correlation-id'] ?? randomUUID()
  })

  app.addHook('onSend', async (request, reply) => {
    reply.header('x-correlation-id', request.correlationId)
  })
}

export default fp(correlationIdPlugin)
```

Forward the correlation ID on every outgoing inter-service call:

js

```js
async function callDownstream(url, correlationId) {
  const { body } = await request(url, {
    headers: {
      'x-correlation-id': correlationId,
      'x-service-name': 'orders-service'
    }
  })
  return body.json()
}

app.get('/orders/:id', async (request) => {
  const order = await app.db.getOrder(request.params.id)
  const user = await callDownstream(
    `${USERS_URL}/users/${order.userId}`,
    request.correlationId
  )
  return { order, user }
})
```

With Fastify's structured logger (Pino), correlation IDs appear in every log line:

js

```js
const app = Fastify({
  logger: true,
  genReqId: (req) => req.headers['x-correlation-id'] ?? randomUUID()
})
```

---

### Health Checks

Every microservice must expose health endpoints for orchestrators (Kubernetes, ECS) to determine readiness and liveness.

bash

```bash
npm install @fastify/under-pressure
```

js

```js
import underPressure from '@fastify/under-pressure'

await app.register(underPressure, {
  maxEventLoopDelay: 1000,    // ms — flag as unhealthy if exceeded
  maxHeapUsedBytes: 200_000_000,
  maxRssBytes: 300_000_000,
  healthCheck: async (app) => {
    // Custom check — verify DB connectivity
    try {
      await app.db.query('SELECT 1')
      return true
    } catch {
      return false
    }
  },
  healthCheckInterval: 5000,
  exposeStatusRoute: {
    url: '/health',
    routeResponseSchemaOpts: {
      version: { type: 'string' },
      status: { type: 'string' }
    }
  }
})

// Liveness probe — is the process alive?
app.get('/livez', async () => ({ status: 'ok' }))

// Readiness probe — is the service ready to accept traffic?
app.get('/readyz', async (request, reply) => {
  try {
    await app.db.query('SELECT 1')
    return { status: 'ready' }
  } catch (err) {
    reply.code(503)
    return { status: 'not ready', reason: 'db unavailable' }
  }
})
```

**Key Points**

- Kubernetes uses liveness probes to decide whether to restart a container, and readiness probes to decide whether to route traffic to it — these are distinct concerns requiring separate endpoints
- `@fastify/under-pressure` monitors Node.js event loop lag and memory pressure — elevated values indicate a saturated service
- Health checks should verify actual dependencies (DB, queue broker) not just process liveness

---

### Circuit Breaker Pattern

A circuit breaker stops calling a failing downstream service, preventing cascading failures across services.

bash

```bash
npm install opossum
```

js

```js
import CircuitBreaker from 'opossum'

function createBreaker(fn, opts = {}) {
  const breaker = new CircuitBreaker(fn, {
    timeout: 3000,           // ms — call is considered failed if it takes longer
    errorThresholdPercentage: 50,  // Open circuit if 50% of calls fail
    resetTimeout: 10000,     // ms — try again after 10s in open state
    ...opts
  })

  breaker.on('open', () =>
    app.log.warn('Circuit breaker opened — downstream unavailable')
  )
  breaker.on('halfOpen', () =>
    app.log.info('Circuit breaker half-open — testing downstream')
  )
  breaker.on('close', () =>
    app.log.info('Circuit breaker closed — downstream recovered')
  )

  return breaker
}

// Wrap the downstream call
const getUserBreaker = createBreaker(getUserById)

app.get('/orders/:id', async (request, reply) => {
  const order = await app.db.getOrder(request.params.id)

  let user = null
  try {
    user = await getUserBreaker.fire(order.userId)
  } catch (err) {
    // Circuit is open or call failed — degrade gracefully
    app.log.warn({ err }, 'User fetch failed — returning order without user data')
  }

  return { order, user }
})
```

**Key Points**

- Three circuit states: **Closed** (normal), **Open** (failing fast), **Half-Open** (testing recovery)
- Graceful degradation — returning partial data — is preferable to propagating failures to clients
- [Inference] Circuit breaker thresholds depend on the service's SLA and traffic pattern; default values require tuning for production

---

### Rate Limiting Per Service

bash

```bash
npm install @fastify/rate-limit
```

js

```js
import rateLimit from '@fastify/rate-limit'
import Redis from 'ioredis'

const redis = new Redis(process.env.REDIS_URL)

await app.register(rateLimit, {
  global: true,
  max: 100,
  timeWindow: '1 minute',
  redis,                      // Shared state across multiple instances
  keyGenerator: (request) =>
    request.headers['x-api-key'] ??
    request.ip,
  errorResponseBuilder: (request, context) => ({
    statusCode: 429,
    error: 'Too Many Requests',
    message: `Rate limit exceeded. Retry after ${context.after}`,
    retryAfter: context.after
  })
})
```

**Key Points**

- Without a shared store (Redis), rate limits are per-instance and ineffective when the service scales horizontally
- `keyGenerator` determines what is rate-limited — per IP, per API key, per user ID, or per service name
- Rate limits at the service level complement (not replace) gateway-level rate limiting

---

### Diagram: Microservices Communication Patterns

ObservabilityHTTPHTTPHTTPHTTPHTTP + Circuit BreakerPublishes: order.createdSubscribesLogs + TracesLogs + TracesLogs + TracesClientAPI Gateway:3000Orders Service:3001Users Service:4001Notifications Service:5001Message BrokerRabbitMQ / KafkaOrders DBPostgreSQLUsers DBPostgreSQLNotifications DBMongoDBOpenTelemetryCollectorJaeger(Traces)Loki(Logs)

---

### Structured Logging Across Services

Pino (Fastify's default logger) emits newline-delimited JSON, making log aggregation straightforward.

js

```js
const app = Fastify({
  logger: {
    level: process.env.LOG_LEVEL ?? 'info',
    formatters: {
      bindings: (bindings) => ({
        service: process.env.SERVICE_NAME,
        version: process.env.SERVICE_VERSION,
        pid: bindings.pid,
        host: bindings.hostname
      })
    },
    serializers: {
      req(request) {
        return {
          method: request.method,
          url: request.url,
          correlationId: request.correlationId
        }
      }
    }
  }
})
```

Every log line carries `service`, `version`, and `correlationId` — enabling cross-service log correlation in tools like Grafana Loki, Datadog, or ELK.

---

### Graceful Shutdown

In containerized deployments, services receive `SIGTERM` before being stopped. Fastify must finish in-flight requests before closing.

js

```js
async function shutdown(signal) {
  app.log.info({ signal }, 'Shutdown signal received')

  try {
    // Stop accepting new connections
    await app.close()

    // Close downstream connections
    await app.db.end()
    await app.mq?.close?.()

    app.log.info('Graceful shutdown complete')
    process.exit(0)
  } catch (err) {
    app.log.error({ err }, 'Error during shutdown')
    process.exit(1)
  }
}

process.on('SIGTERM', () => shutdown('SIGTERM'))
process.on('SIGINT',  () => shutdown('SIGINT'))
```

**Key Points**

- `app.close()` calls all `onClose` hooks registered by plugins — DB pools, message queue connections, and other resources registered via `onClose` are cleaned up automatically
- Kubernetes sends `SIGTERM` and waits `terminationGracePeriodSeconds` (default 30s) before `SIGKILL` — the shutdown must complete within this window
- In-flight HTTP requests should complete before `app.close()` returns [Inference] — behavior depends on whether keep-alive connections are drained

---

### Environment Configuration Pattern

js

```js
// config.js
import { cleanEnv, str, port, url, num } from 'envalid'

export const config = cleanEnv(process.env, {
  NODE_ENV:           str({ choices: ['development', 'production', 'test'] }),
  PORT:               port({ default: 3000 }),
  SERVICE_NAME:       str(),
  DATABASE_URL:       url(),
  USERS_SERVICE_URL:  url(),
  RABBITMQ_URL:       url({ default: 'amqp://localhost' }),
  LOG_LEVEL:          str({ default: 'info' }),
  JWT_SECRET:         str(),
  REDIS_URL:          url({ default: 'redis://localhost:6379' }),
  MAX_POOL_SIZE:      num({ default: 10 })
})
```

**Key Points**

- `envalid` validates and documents environment variables at startup, failing fast with clear messages if required variables are missing
- Centralizing config in one module prevents scattered `process.env` reads throughout the codebase
- Secrets (JWT keys, DB passwords) should come from a secrets manager (Vault, AWS Secrets Manager, Kubernetes Secrets) rather than plain environment variables in production [Inference]

---

### Testing Microservices with `fastify.inject`

Fastify's `inject` method performs in-process HTTP without a network socket — ideal for unit and integration tests:

js

```js
import { test } from 'node:test'
import assert from 'node:assert'
import buildApp from '../app.js'

test('GET /orders/:id returns order with user', async (t) => {
  const app = await buildApp({
    // Override the users client with a stub
    usersClient: {
      getUser: async (id) => ({ id, name: 'Alice', email: 'alice@example.com' })
    }
  })

  t.after(() => app.close())

  const response = await app.inject({
    method: 'GET',
    url: '/orders/order-123',
    headers: { authorization: 'Bearer test-token' }
  })

  assert.strictEqual(response.statusCode, 200)
  const body = response.json()
  assert.ok(body.order)
  assert.strictEqual(body.user.name, 'Alice')
})
```

**Key Points**

- The app factory pattern (`buildApp(opts)`) enables dependency injection — pass stub clients, mock DBs, or test config at construction time
- `inject` does not open a port — tests run faster and do not require network cleanup
- Integration tests that test the full stack (real DB, real queue) should run in a separate test suite with Docker Compose or Testcontainers

---

**Related Topics**

- API gateway patterns with Fastify: authentication, rate limiting, routing
- gRPC service-to-service communication with `@grpc/grpc-js`
- Event sourcing and CQRS with Fastify and Kafka
- Distributed transactions and the Saga pattern
- Service mesh integration (Istio, Linkerd) with Fastify services
- Kubernetes deployment: Deployment manifests, HPA, and pod disruption budgets for Fastify services
- Testcontainers for integration testing Fastify microservices
## Event-Driven Patterns with NATS

NATS is a high-performance, lightweight messaging system designed for cloud-native and distributed architectures. It supports publish/subscribe, request/reply, and persistent streaming patterns, making it a strong fit for event-driven microservices built with Fastify.

---

### What NATS Is

NATS is an open-source messaging server written in Go. Client libraries exist for most languages, including Node.js. It operates on a subject-based addressing model — producers publish to subjects, consumers subscribe to subjects.

**Key Points:**
- Core NATS is at-most-once delivery (fire-and-forget)
- NATS JetStream adds persistence, at-least-once and exactly-once delivery, and consumer tracking
- Subjects use dot-notation and support wildcards (`*` for single token, `>` for remainder)
- No broker configuration required for basic pub/sub — subjects are dynamic

---

### Installing the NATS Client

```bash
npm install nats
```

A NATS server must be running. For local development:

```bash
docker run -d -p 4222:4222 nats:latest
```

For JetStream support, start with JetStream enabled:

```bash
docker run -d -p 4222:4222 nats:latest -js
```

---

### Core Concepts

#### Subjects

Subjects are string addresses using dot notation. They are not pre-declared — any client can publish or subscribe to any subject.

```
orders.created
orders.fulfilled
payments.processed
user.registered
```

Wildcards:
- `orders.*` matches `orders.created`, `orders.fulfilled`, but not `orders.eu.created`
- `orders.>` matches any subject starting with `orders.`

#### Connection

```ts
import { connect, StringCodec } from 'nats';

const nc = await connect({ servers: 'nats://127.0.0.1:4222' });
const sc = StringCodec();
```

The `StringCodec` encodes/decodes message payloads as UTF-8 strings. For structured data, `JSONCodec()` is the standard choice.

---

### Fastify NATS Plugin

Registering NATS as a Fastify plugin makes the connection available application-wide via decoration.

```ts
// plugins/nats.ts
import fp from 'fastify-plugin';
import { connect, JSONCodec, NatsConnection } from 'nats';

declare module 'fastify' {
  interface FastifyInstance {
    nats: NatsConnection;
    nc: ReturnType<typeof JSONCodec>;
  }
}

async function natsPlugin(fastify) {
  const nc = await connect({ servers: process.env.NATS_URL ?? 'nats://127.0.0.1:4222' });
  const jc = JSONCodec();

  fastify.decorate('nats', nc);
  fastify.decorate('nc', jc);

  fastify.addHook('onClose', async () => {
    await nc.drain(); // flush pending messages before closing
  });
}

export default fp(natsPlugin);
```

`drain()` waits for all in-flight publishes and subscriptions to complete before the connection closes.

---

### Publish / Subscribe

#### Publishing from a Route

```ts
// routes/orders.ts
export async function orderRoutes(fastify) {
  fastify.post('/orders', async (request, reply) => {
    const order = await fastify.db.orders.create(request.body);

    // Publish event after successful creation
    fastify.nats.publish(
      'orders.created',
      fastify.nc.encode({ orderId: order.id, userId: order.userId })
    );

    return reply.code(201).send({ id: order.id });
  });
}
```

The route publishes immediately and does not wait for any subscriber to process the event.

#### Subscribing to Events

```ts
// subscribers/orderSubscriber.ts
import { connect, JSONCodec } from 'nats';

const nc = await connect({ servers: 'nats://127.0.0.1:4222' });
const jc = JSONCodec();

const sub = nc.subscribe('orders.created');

(async () => {
  for await (const msg of sub) {
    const data = jc.decode(msg.data);
    console.log('Order created:', data);
    await notifyFulfillmentService(data);
  }
})();
```

Subscribers can run in the same process as Fastify or in separate services.

---

### Request / Reply

NATS supports synchronous-style request/reply over the async transport. The client publishes to a subject and waits for a response on a temporary reply subject.

```ts
// Requester (Fastify route acting as client)
fastify.get('/inventory/:productId', async (request, reply) => {
  const { productId } = request.params;

  const response = await fastify.nats.request(
    'inventory.check',
    fastify.nc.encode({ productId }),
    { timeout: 3000 }
  );

  const result = fastify.nc.decode(response.data);
  return result;
});
```

```ts
// Responder (inventory microservice)
const sub = nc.subscribe('inventory.check');

for await (const msg of sub) {
  const { productId } = jc.decode(msg.data);
  const stock = await db.inventory.find(productId);

  msg.respond(jc.encode({ productId, stock }));
}
```

**Key Points:**
- If no responder is available and the timeout elapses, the request throws a `NatsError` with code `TIMEOUT`
- Multiple responders on the same subject form a load-balanced group — NATS delivers each request to only one [Inference: based on NATS queue group semantics; see queue groups below]

---

### Queue Groups

Queue groups enable competing-consumer load balancing. Multiple subscribers on the same subject and queue group name share incoming messages rather than each receiving every message.

```ts
// Instance A of fulfillment service
nc.subscribe('orders.created', {
  queue: 'fulfillment-workers',
  callback: (err, msg) => {
    const data = jc.decode(msg.data);
    processFulfillment(data);
  },
});

// Instance B of fulfillment service (same queue group)
nc.subscribe('orders.created', {
  queue: 'fulfillment-workers',
  callback: (err, msg) => {
    const data = jc.decode(msg.data);
    processFulfillment(data);
  },
});
```

Each published message is delivered to exactly one member of the `fulfillment-workers` group. [Inference: based on NATS queue group documentation; behavior depends on NATS server version and connection state]

---

### Architecture Diagram

<svg viewBox="0 0 780 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#38bdf8"/>
    </marker>
    <marker id="arr2" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#4ade80"/>
    </marker>
  </defs>

  <!-- Fastify Publisher -->
  <rect x="20" y="130" width="150" height="70" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="95" y="158" text-anchor="middle" fill="#38bdf8" font-weight="bold">Fastify App</text>
  <text x="95" y="176" text-anchor="middle" fill="#94a3b8">Publisher</text>

  <!-- Arrow to NATS -->
  <line x1="170" y1="165" x2="295" y2="165" stroke="#38bdf8" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="232" y="158" text-anchor="middle" fill="#94a3b8">publish</text>

  <!-- NATS Server -->
  <rect x="295" y="100" width="170" height="130" rx="8" fill="#1e293b" stroke="#f472b6" stroke-width="1.5"/>
  <text x="380" y="128" text-anchor="middle" fill="#f472b6" font-weight="bold">NATS Server</text>
  <text x="380" y="148" text-anchor="middle" fill="#94a3b8">orders.created</text>
  <text x="380" y="166" text-anchor="middle" fill="#94a3b8">inventory.check</text>
  <text x="380" y="184" text-anchor="middle" fill="#94a3b8">payments.processed</text>
  <text x="380" y="204" text-anchor="middle" fill="#64748b" font-size="11">subject routing</text>

  <!-- Arrow to Subscriber A -->
  <line x1="465" y1="140" x2="560" y2="100" stroke="#4ade80" stroke-width="1.5" marker-end="url(#arr2)"/>
  <!-- Arrow to Subscriber B -->
  <line x1="465" y1="165" x2="560" y2="185" stroke="#4ade80" stroke-width="1.5" marker-end="url(#arr2)"/>
  <!-- Arrow to Subscriber C -->
  <line x1="465" y1="190" x2="560" y2="265" stroke="#4ade80" stroke-width="1.5" marker-end="url(#arr2)"/>

  <!-- Subscriber A -->
  <rect x="560" y="60" width="170" height="60" rx="8" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="645" y="85" text-anchor="middle" fill="#4ade80" font-weight="bold">Fulfillment Svc</text>
  <text x="645" y="103" text-anchor="middle" fill="#94a3b8">orders.created</text>

  <!-- Subscriber B -->
  <rect x="560" y="155" width="170" height="60" rx="8" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="645" y="180" text-anchor="middle" fill="#4ade80" font-weight="bold">Inventory Svc</text>
  <text x="645" y="198" text-anchor="middle" fill="#94a3b8">inventory.check</text>

  <!-- Subscriber C -->
  <rect x="560" y="235" width="170" height="60" rx="8" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="645" y="260" text-anchor="middle" fill="#4ade80" font-weight="bold">Notification Svc</text>
  <text x="645" y="278" text-anchor="middle" fill="#94a3b8">orders.created</text>

  <text x="390" y="310" text-anchor="middle" fill="#475569" font-size="11">One publish → multiple independent subscribers receive the event</text>
</svg>

---

### JetStream: Persistent Messaging

Core NATS offers no persistence — if no subscriber is active when a message is published, it is lost. JetStream adds durable streams and consumers.

#### Creating a Stream

```ts
import { connect, JSONCodec } from 'nats';

const nc = await connect({ servers: 'nats://127.0.0.1:4222' });
const js = nc.jetstream();
const jsm = await nc.jetstreamManager();

// Create a stream that captures all orders.* subjects
await jsm.streams.add({
  name: 'ORDERS',
  subjects: ['orders.>'],
});
```

#### Publishing to JetStream

```ts
const jc = JSONCodec();

const ack = await js.publish(
  'orders.created',
  jc.encode({ orderId: 'abc123', userId: 'u1' })
);

console.log('Sequence:', ack.seq); // server-assigned sequence number
```

JetStream publish returns an acknowledgement, confirming the message was persisted. [Inference: based on JetStream documentation; network partitions or misconfiguration may affect ack delivery]

#### Durable Consumer

```ts
await jsm.consumers.add('ORDERS', {
  durable_name: 'fulfillment-consumer',
  ack_policy: 'explicit', // must ack each message
  deliver_subject: 'fulfillment.deliver',
});

const consumer = await js.consumers.get('ORDERS', 'fulfillment-consumer');
const messages = await consumer.consume();

for await (const msg of messages) {
  const data = jc.decode(msg.data);
  await processFulfillment(data);
  msg.ack(); // acknowledge after successful processing
}
```

**Key Points:**
- Durable consumers retain their position across restarts — redelivery picks up where it left off
- `ack_policy: 'explicit'` requires each message to be acknowledged; unacknowledged messages are redelivered after the ack wait window elapses [Inference: behavior subject to JetStream server configuration]

---

### Event-Driven Patterns

#### Pattern 1: Event Notification

Fastify publishes a lightweight event. Subscribers fetch details themselves if needed.

```ts
// Thin event — just an ID
fastify.nats.publish('user.registered', jc.encode({ userId: user.id }));
```

Subscribers that need full user data query the database or call the user service. Reduces coupling between producer and consumer.

#### Pattern 2: Event-Carried State Transfer

The full state snapshot is included in the event payload. Subscribers do not need to call back.

```ts
fastify.nats.publish('user.registered', jc.encode({
  userId: user.id,
  email: user.email,
  plan: user.plan,
  createdAt: user.createdAt,
}));
```

Increases message size but eliminates round-trips. Appropriate when consumer latency is critical.

#### Pattern 3: Command via Request/Reply

Fastify sends a command to another service and expects a result before responding to the HTTP client.

```ts
fastify.post('/checkout', async (request, reply) => {
  const { cartId, userId } = request.body;

  // Request payment processing from payment service
  const response = await fastify.nats.request(
    'payments.process',
    jc.encode({ cartId, userId }),
    { timeout: 5000 }
  );

  const result = jc.decode(response.data);

  if (!result.success) {
    return reply.code(402).send({ error: result.reason });
  }

  return reply.send({ orderId: result.orderId });
});
```

#### Pattern 4: Saga Choreography

Each service publishes the next event after completing its step. No central orchestrator — services react to each other's events.

```
orders.created        → Inventory Svc reserves stock → inventory.reserved
inventory.reserved    → Payment Svc charges card     → payments.charged
payments.charged      → Fulfillment Svc ships order  → order.shipped
```

```ts
// Inventory service
nc.subscribe('orders.created', { queue: 'inventory' }, async (err, msg) => {
  const { orderId } = jc.decode(msg.data);
  await reserveStock(orderId);
  nc.publish('inventory.reserved', jc.encode({ orderId }));
});
```

**Key Points:**
- Choreography distributes responsibility — no single point of failure for orchestration
- Compensating transactions (rollback events) must be explicitly designed for failure cases
- Tracing across services requires correlation IDs propagated through each event payload [Inference: NATS does not inject correlation IDs automatically]

---

### Correlation IDs and Tracing

Propagating a correlation ID through event chains enables distributed tracing.

```ts
import { randomUUID } from 'crypto';

// Producer
const correlationId = randomUUID();
fastify.nats.publish('orders.created', jc.encode({
  orderId: order.id,
  correlationId,
}));

// Consumer
for await (const msg of sub) {
  const { orderId, correlationId } = jc.decode(msg.data);
  fastify.log.info({ correlationId }, `Processing order ${orderId}`);
  // pass correlationId forward to next published event
}
```

---

### Error Handling

Core NATS has no built-in dead-letter or retry mechanism. Error handling must be implemented at the application level.

```ts
for await (const msg of sub) {
  try {
    const data = jc.decode(msg.data);
    await processEvent(data);
  } catch (err) {
    // Publish to an error subject for observability
    nc.publish('orders.created.error', jc.encode({
      error: err.message,
      originalPayload: jc.decode(msg.data),
    }));
  }
}
```

With JetStream, failed messages that are not acknowledged are redelivered automatically up to the configured `max_deliver` limit.

---

### Graceful Shutdown in Fastify

```ts
fastify.addHook('onClose', async () => {
  await fastify.nats.drain();
});
```

`drain()` stops accepting new messages, processes all buffered messages, and then closes the connection. This is preferred over `close()` in production.

---

### Core NATS vs JetStream Comparison

| Capability | Core NATS | JetStream |
|---|---|---|
| Delivery guarantee | At-most-once | At-least-once / exactly-once |
| Persistence | None | Configurable retention |
| Consumer tracking | None | Durable consumers |
| Replay | Not supported | Supported |
| Acknowledgement | None | Explicit / cumulative |
| Suitable for | Low-latency fire-and-forget | Critical event pipelines |

---

**Related Topics:**
- NATS JetStream key-value store as a lightweight config/state store
- Combining NATS with BullMQ (NATS for events, BullMQ for job queues)
- Service mesh patterns with NATS and Fastify
- Distributed tracing with OpenTelemetry across NATS events
- NATS authentication and TLS configuration
- NATS clustering and fault tolerance
- Schema validation for NATS message payloads
- Comparing NATS with Kafka and RabbitMQ for Fastify microservices
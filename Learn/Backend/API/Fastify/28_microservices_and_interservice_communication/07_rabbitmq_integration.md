## RabbitMQ Integration

RabbitMQ is a widely deployed open-source message broker implementing the Advanced Message Queuing Protocol (AMQP). It provides flexible routing, durable queuing, acknowledgement-based delivery guarantees, and a rich ecosystem of plugins, making it a common choice for Fastify-based microservice architectures.

---

### What RabbitMQ Is

RabbitMQ decouples producers and consumers through a broker that receives, routes, and delivers messages. Unlike NATS, RabbitMQ's routing model is explicit — producers publish to exchanges, exchanges route to queues via bindings, and consumers read from queues.

**Key Points:**
- Messages are published to **exchanges**, not queues directly
- Exchanges route messages to queues based on **bindings** and **routing keys**
- Queues buffer messages until a consumer acknowledges them
- Unacknowledged messages are redelivered after the consumer disconnects or a timeout elapses [Inference: based on AMQP specification behavior; actual redelivery depends on broker and consumer configuration]
- RabbitMQ supports durable queues, persistent messages, dead-letter exchanges, and consumer priorities

---

### Installing the AMQP Client

`amqplib` is the standard Node.js AMQP 0-9-1 client for RabbitMQ:

```bash
npm install amqplib
npm install -D @types/amqplib
```

For a higher-level abstraction with reconnection handling, `amqp-connection-manager` is commonly used alongside `amqplib`:

```bash
npm install amqp-connection-manager amqplib
```

A RabbitMQ server for local development:

```bash
docker run -d \
  -p 5672:5672 \
  -p 15672:15672 \
  --name rabbitmq \
  rabbitmq:3-management
```

The management UI is available at `http://localhost:15672` (default credentials: `guest` / `guest`).

---

### Core Concepts

#### Exchanges

Exchanges receive messages from producers and route them to queues. Exchange types determine routing behavior:

| Type | Routing behavior |
|---|---|
| `direct` | Routes to queues whose binding key exactly matches the routing key |
| `topic` | Routes using pattern matching (`*` = one word, `#` = zero or more words) |
| `fanout` | Routes to all bound queues, ignoring routing key |
| `headers` | Routes based on message header attributes instead of routing key |

#### Queues

Queues store messages until consumed. Key properties:

- `durable: true` — queue survives broker restart
- `exclusive` — queue is deleted when the connection closes
- `autoDelete` — queue is deleted when the last consumer unsubscribes

#### Bindings

A binding connects an exchange to a queue, optionally with a routing key pattern.

#### Message Acknowledgement

AMQP uses explicit acknowledgement. A consumer calls `ack()` after successful processing. If the consumer crashes before acking, the broker redelivers to another consumer. `nack()` rejects a message, optionally requeueing it.

---

### Fastify RabbitMQ Plugin

The plugin establishes a connection, creates a channel, and decorates Fastify with both.

```ts
// plugins/rabbitmq.ts
import fp from 'fastify-plugin';
import amqplib, { Connection, Channel } from 'amqplib';

declare module 'fastify' {
  interface FastifyInstance {
    rabbit: {
      connection: Connection;
      channel: Channel;
    };
  }
}

async function rabbitmqPlugin(fastify) {
  const connection = await amqplib.connect(
    process.env.RABBITMQ_URL ?? 'amqp://guest:guest@localhost:5672'
  );
  const channel = await connection.createChannel();

  // Declare exchange and queue at startup
  await channel.assertExchange('events', 'topic', { durable: true });
  await channel.assertQueue('orders.created', { durable: true });
  await channel.bindQueue('orders.created', 'events', 'orders.created');

  fastify.decorate('rabbit', { connection, channel });

  fastify.addHook('onClose', async () => {
    await channel.close();
    await connection.close();
  });
}

export default fp(rabbitmqPlugin);
```

**Key Points:**
- `assertExchange` and `assertQueue` are idempotent — they create the resource if absent or verify it matches if present
- Channel creation is cheap; a single channel per plugin is typical for low-to-medium throughput [Inference: for high-throughput scenarios, channel-per-consumer patterns are common but add complexity]

---

### Publishing Messages from a Route

```ts
// routes/orders.ts
export async function orderRoutes(fastify) {
  fastify.post('/orders', async (request, reply) => {
    const order = await fastify.db.orders.create(request.body);

    const payload = Buffer.from(JSON.stringify({
      orderId: order.id,
      userId: order.userId,
      createdAt: new Date().toISOString(),
    }));

    fastify.rabbit.channel.publish(
      'events',           // exchange
      'orders.created',   // routing key
      payload,
      {
        persistent: true,           // message survives broker restart
        contentType: 'application/json',
        messageId: order.id,
      }
    );

    return reply.code(201).send({ id: order.id });
  });
}
```

`persistent: true` combined with `durable: true` on the queue provides message durability across broker restarts. [Inference: durability still depends on broker disk flush behavior; broker crashes between write and flush may result in loss under some configurations]

---

### Consuming Messages

Consumers are typically set up at application startup, in a separate worker process, or within the Fastify plugin itself.

```ts
// consumers/orderConsumer.ts
import amqplib from 'amqplib';

const connection = await amqplib.connect('amqp://guest:guest@localhost:5672');
const channel = await connection.createChannel();

await channel.assertQueue('orders.created', { durable: true });
channel.prefetch(10); // process up to 10 unacknowledged messages at a time

channel.consume('orders.created', async (msg) => {
  if (!msg) return;

  try {
    const data = JSON.parse(msg.content.toString());
    await processFulfillment(data);
    channel.ack(msg);
  } catch (err) {
    // nack without requeue after unrecoverable error
    channel.nack(msg, false, false);
  }
});
```

**Key Points:**
- `channel.prefetch(n)` sets Quality of Service — limits how many unacknowledged messages the broker sends to this consumer at once
- `nack(msg, false, false)` rejects without requeueing — message goes to the dead-letter exchange if one is configured
- `nack(msg, false, true)` requeues — use cautiously to avoid infinite redelivery loops

---

### Exchange Types in Practice

#### Direct Exchange

Routes messages to queues whose binding key exactly matches the routing key. Suitable for task dispatch.

```ts
await channel.assertExchange('tasks', 'direct', { durable: true });
await channel.assertQueue('email-tasks', { durable: true });
await channel.bindQueue('email-tasks', 'tasks', 'email');

// Publish
channel.publish('tasks', 'email', Buffer.from(JSON.stringify({ to: 'a@b.com' })));
```

#### Topic Exchange

Routes using dot-separated patterns. Suitable for event streams with namespaced subjects.

```ts
await channel.assertExchange('events', 'topic', { durable: true });

// Queue receives all order events
await channel.assertQueue('all-order-events', { durable: true });
await channel.bindQueue('all-order-events', 'events', 'orders.#');

// Queue receives only payment events for EU region
await channel.assertQueue('eu-payments', { durable: true });
await channel.bindQueue('eu-payments', 'events', 'payments.eu.*');
```

#### Fanout Exchange

Broadcasts to all bound queues regardless of routing key. Suitable for notifications sent to multiple independent services.

```ts
await channel.assertExchange('broadcast', 'fanout', { durable: false });

// All bound queues receive every message
channel.publish('broadcast', '', Buffer.from(JSON.stringify({ event: 'system.maintenance' })));
```

---

### Architecture Diagram

<svg viewBox="0 0 800 360" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#38bdf8"/>
    </marker>
    <marker id="arrg" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#4ade80"/>
    </marker>
  </defs>

  <!-- Fastify Producer -->
  <rect x="20" y="140" width="140" height="70" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="90" y="168" text-anchor="middle" fill="#38bdf8" font-weight="bold">Fastify App</text>
  <text x="90" y="186" text-anchor="middle" fill="#94a3b8">channel.publish()</text>

  <!-- Arrow to Exchange -->
  <line x1="160" y1="175" x2="240" y2="175" stroke="#38bdf8" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Exchange -->
  <rect x="240" y="140" width="130" height="70" rx="8" fill="#1e293b" stroke="#f472b6" stroke-width="1.5"/>
  <text x="305" y="168" text-anchor="middle" fill="#f472b6" font-weight="bold">Exchange</text>
  <text x="305" y="186" text-anchor="middle" fill="#94a3b8">topic / direct</text>

  <!-- Arrow to Queue A -->
  <line x1="370" y1="160" x2="450" y2="100" stroke="#f472b6" stroke-width="1.5" marker-end="url(#arr)"/>
  <!-- Arrow to Queue B -->
  <line x1="370" y1="175" x2="450" y2="185" stroke="#f472b6" stroke-width="1.5" marker-end="url(#arr)"/>
  <!-- Arrow to Queue C -->
  <line x1="370" y1="190" x2="450" y2="270" stroke="#f472b6" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Queue A -->
  <rect x="450" y="65" width="140" height="55" rx="6" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
  <text x="520" y="88" text-anchor="middle" fill="#fbbf24" font-weight="bold">Queue A</text>
  <text x="520" y="106" text-anchor="middle" fill="#94a3b8">orders.created</text>

  <!-- Queue B -->
  <rect x="450" y="155" width="140" height="55" rx="6" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
  <text x="520" y="178" text-anchor="middle" fill="#fbbf24" font-weight="bold">Queue B</text>
  <text x="520" y="196" text-anchor="middle" fill="#94a3b8">payments.#</text>

  <!-- Queue C -->
  <rect x="450" y="245" width="140" height="55" rx="6" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
  <text x="520" y="268" text-anchor="middle" fill="#fbbf24" font-weight="bold">Queue C</text>
  <text x="520" y="286" text-anchor="middle" fill="#94a3b8">notifications.#</text>

  <!-- Arrows to Consumers -->
  <line x1="590" y1="92" x2="660" y2="92" stroke="#4ade80" stroke-width="1.5" marker-end="url(#arrg)"/>
  <line x1="590" y1="182" x2="660" y2="182" stroke="#4ade80" stroke-width="1.5" marker-end="url(#arrg)"/>
  <line x1="590" y1="272" x2="660" y2="272" stroke="#4ade80" stroke-width="1.5" marker-end="url(#arrg)"/>

  <!-- Consumers -->
  <rect x="660" y="65" width="120" height="55" rx="6" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="720" y="88" text-anchor="middle" fill="#4ade80" font-weight="bold">Fulfillment</text>
  <text x="720" y="106" text-anchor="middle" fill="#94a3b8">consumer</text>

  <rect x="660" y="155" width="120" height="55" rx="6" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="720" y="178" text-anchor="middle" fill="#4ade80" font-weight="bold">Payments</text>
  <text x="720" y="196" text-anchor="middle" fill="#94a3b8">consumer</text>

  <rect x="660" y="245" width="120" height="55" rx="6" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="720" y="268" text-anchor="middle" fill="#4ade80" font-weight="bold">Notify</text>
  <text x="720" y="286" text-anchor="middle" fill="#94a3b8">consumer</text>

  <text x="400" y="340" text-anchor="middle" fill="#475569" font-size="11">Producer → Exchange → Queues (via bindings) → Independent Consumers</text>
</svg>

---

### Dead-Letter Exchanges

A dead-letter exchange (DLX) receives messages that are rejected, expired, or exceed the queue's max-length. This provides a safety net for failed messages.

```ts
// Declare DLX and dead-letter queue
await channel.assertExchange('dlx', 'direct', { durable: true });
await channel.assertQueue('orders.dead-letter', { durable: true });
await channel.bindQueue('orders.dead-letter', 'dlx', 'orders.created');

// Declare main queue with DLX configured
await channel.assertQueue('orders.created', {
  durable: true,
  arguments: {
    'x-dead-letter-exchange': 'dlx',
    'x-dead-letter-routing-key': 'orders.created',
    'x-message-ttl': 60000,   // messages expire after 60s if unprocessed
  },
});
```

When a consumer calls `nack(msg, false, false)`, the message is routed to the DLX instead of being discarded.

---

### Retry Pattern with DLX

A common pattern uses DLX to implement delayed retries without a dedicated retry library.

```ts
// Retry queue: messages wait here before being requeued
await channel.assertExchange('retry-exchange', 'direct', { durable: true });
await channel.assertQueue('orders.retry', {
  durable: true,
  arguments: {
    'x-dead-letter-exchange': 'events',         // back to main exchange after TTL
    'x-dead-letter-routing-key': 'orders.created',
    'x-message-ttl': 5000,                      // wait 5s before retry
  },
});
await channel.bindQueue('orders.retry', 'retry-exchange', 'orders.created');

// In the consumer: on failure, publish to retry queue instead of nacking
channel.consume('orders.created', async (msg) => {
  try {
    await processOrder(JSON.parse(msg.content.toString()));
    channel.ack(msg);
  } catch (err) {
    const retryCount = (msg.properties.headers?.['x-retry-count'] ?? 0) + 1;
    if (retryCount >= 3) {
      channel.nack(msg, false, false); // send to DLX after max retries
    } else {
      channel.publish('retry-exchange', 'orders.created', msg.content, {
        headers: { 'x-retry-count': retryCount },
        persistent: true,
      });
      channel.ack(msg); // ack original to remove from main queue
    }
  }
});
```

---

### Reconnection with amqp-connection-manager

`amqplib` does not reconnect automatically. `amqp-connection-manager` wraps it with reconnection logic and channel buffering.

```ts
import amqp from 'amqp-connection-manager';

const connection = amqp.connect(['amqp://localhost']);

const channelWrapper = connection.createChannel({
  setup: async (channel) => {
    await channel.assertExchange('events', 'topic', { durable: true });
    await channel.assertQueue('orders.created', { durable: true });
    await channel.bindQueue('orders.created', 'events', 'orders.created');
    await channel.prefetch(10);
  },
});

// Publish — buffered if connection is temporarily down
await channelWrapper.publish(
  'events',
  'orders.created',
  Buffer.from(JSON.stringify({ orderId: '123' })),
  { persistent: true }
);
```

**Key Points:**
- Messages published during a disconnection are buffered in memory and sent upon reconnection [Inference: buffer size is finite; large backlogs during prolonged outages may exhaust memory]
- The `setup` function re-runs on every reconnection, re-asserting topology

---

### Request/Reply with RabbitMQ

RabbitMQ supports RPC-style request/reply using a reply-to queue and correlation ID.

```ts
import { randomUUID } from 'crypto';

async function rpcCall(channel, queue, payload) {
  const correlationId = randomUUID();
  const replyQueue = await channel.assertQueue('', { exclusive: true });

  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => reject(new Error('RPC timeout')), 5000);

    channel.consume(replyQueue.queue, (msg) => {
      if (msg?.properties.correlationId === correlationId) {
        clearTimeout(timeout);
        resolve(JSON.parse(msg.content.toString()));
      }
    }, { noAck: true });

    channel.sendToQueue(queue, Buffer.from(JSON.stringify(payload)), {
      correlationId,
      replyTo: replyQueue.queue,
      persistent: false,
    });
  });
}

// Usage in a Fastify route
fastify.get('/product/:id/price', async (request) => {
  const result = await rpcCall(
    fastify.rabbit.channel,
    'pricing.calculate',
    { productId: request.params.id }
  );
  return result;
});
```

---

### Competing Consumers

Multiple instances of the same consumer service can consume from one queue. RabbitMQ distributes messages in round-robin fashion by default. Combined with `prefetch`, this provides load balancing without application-level coordination.

```ts
// Instance A and Instance B both run this same code
channel.prefetch(5);
channel.consume('orders.created', async (msg) => {
  await processOrder(JSON.parse(msg.content.toString()));
  channel.ack(msg);
});
```

Each instance processes up to 5 messages concurrently. RabbitMQ does not send more until previous messages are acknowledged. [Inference: actual throughput balance depends on processing time variance across instances]

---

### Publisher Confirms

By default, `channel.publish()` is fire-and-forget at the AMQP level. Publisher confirms enable the broker to acknowledge that a message was received and persisted.

```ts
await channel.confirmSelect(); // enable confirm mode on the channel

channel.publish(
  'events',
  'orders.created',
  Buffer.from(JSON.stringify(payload)),
  { persistent: true },
  (err, ok) => {
    if (err) {
      fastify.log.error('Message not confirmed by broker:', err);
    } else {
      fastify.log.info('Message confirmed');
    }
  }
);
```

Publisher confirms add latency but provide stronger delivery assurance. [Inference: the performance impact depends on broker load and network characteristics; behavior is not guaranteed under all failure modes]

---

### Comparison: RabbitMQ vs NATS vs BullMQ

| Capability | RabbitMQ | NATS Core | NATS JetStream | BullMQ |
|---|---|---|---|---|
| Protocol | AMQP 0-9-1 | Custom TCP | Custom TCP | Redis commands |
| Persistence | Durable queues | None | Configurable | Redis |
| Delivery | At-least-once | At-most-once | At-least-once | At-least-once |
| Routing | Exchange/binding | Subject matching | Subject matching | Named queues |
| Dead-lettering | Native DLX | Manual | Limited | Manual |
| Retry | Manual / DLX | Manual | Via redelivery | Built-in |
| UI | Management plugin | NATS surveyor | NATS surveyor | Bull Board |
| Best for | Complex routing, enterprise | Low-latency events | Persistent streams | Background jobs |

---

### Graceful Shutdown

```ts
fastify.addHook('onClose', async () => {
  // Cancel all consumers first to stop receiving new messages
  await fastify.rabbit.channel.cancel('consumer-tag');
  await fastify.rabbit.channel.close();
  await fastify.rabbit.connection.close();
});
```

In consumer processes:

```ts
process.on('SIGTERM', async () => {
  await channel.cancel('consumer-tag');
  // Wait for in-flight processing to complete before closing
  await channel.close();
  await connection.close();
  process.exit(0);
});
```

---

**Related Topics:**
- RabbitMQ Streams as an alternative to classic queues for high-throughput log-style workloads
- Shovel and Federation plugins for cross-cluster message routing
- RabbitMQ quorum queues vs classic durable queues
- Schema registry and message validation with JSON Schema or Avro
- Combining RabbitMQ with Fastify's plugin lifecycle for multi-tenant queue isolation
- Monitoring RabbitMQ with Prometheus and Grafana
- Testing RabbitMQ consumers with testcontainers
- Transactional outbox pattern with Fastify, PostgreSQL, and RabbitMQ
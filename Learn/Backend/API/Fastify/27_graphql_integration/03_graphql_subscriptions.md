## GraphQL Subscriptions

### What GraphQL Subscriptions Are

GraphQL subscriptions are a long-lived operation type that pushes data from server to client when events occur. Unlike queries (request → single response) and mutations (request → single response with side effect), a subscription establishes a persistent channel and delivers multiple results over time — one per matching event.

Subscriptions are defined in the schema like queries and mutations, but their resolver contract is different: instead of returning a value, a subscription resolver returns an async iterable that the GraphQL execution engine consumes and pushes to the client.

**Key Points:**

- Subscriptions are part of the GraphQL specification — the transport layer is not
- Mercurius uses WebSocket as the subscription transport, implemented via the `graphql-ws` protocol
- The `graphql-ws` protocol superseded the older `subscriptions-transport-ws` protocol — [Unverified] verify which protocol your client library expects
- Every subscription result passes through the same GraphQL execution engine as a query — field selection, resolvers, and type validation all apply per event

---

### Transport Architecture

```
Client                          Mercurius (Fastify)
  |                                     |
  |--- HTTP GET /graphql (Upgrade) ---->|
  |<-- 101 Switching Protocols ---------|  WebSocket handshake
  |                                     |
  |--- { type: "connection_init" } ---->|  graphql-ws protocol
  |<-- { type: "connection_ack" } ------|
  |                                     |
  |--- { type: "subscribe",             |
  |     id: "1",                        |
  |     payload: { query: "..." } } --->|  Subscription start
  |                                     |
  |<-- { type: "next",                  |
  |     id: "1",                        |
  |     payload: { data: {...} } } ------|  Event pushed
  |<-- { type: "next", ... } -----------|
  |                                     |
  |--- { type: "complete", id: "1" } -->|  Client unsubscribes
  |                                     |
  |--- { type: "connection_close" } --->|  Optional
```

**Key Points:**

- The WebSocket connection is established to the same `/graphql` endpoint used for HTTP queries — Mercurius detects the Upgrade header and routes accordingly
- A single WebSocket connection supports multiple concurrent subscriptions, each identified by a client-assigned `id`
- The `graphql-ws` protocol frames are JSON — not binary WebSocket frames
- [Inference] Mercurius handles the protocol framing internally — application code only interacts with the pub/sub layer and resolver contract

---

### Schema Definition

Subscriptions are defined under a `Subscription` root type:

javascript

```javascript
const schema = `
  type Message {
    id: ID!
    content: String!
    author: String!
    createdAt: String!
  }

  type Notification {
    id: ID!
    kind: NotificationKind!
    body: String!
    recipientId: ID!
  }

  enum NotificationKind {
    MENTION
    REPLY
    SYSTEM
  }

  type Query {
    messages: [Message!]!
  }

  type Mutation {
    sendMessage(content: String!, author: String!): Message!
  }

  type Subscription {
    messageSent: Message!
    notificationReceived(userId: ID!): Notification!
  }
`;
```

**Key Points:**

- Each field in `Subscription` defines a separate subscribable event stream
- Subscription fields can accept arguments — used for filtering (e.g., `notificationReceived(userId: ID!)`)
- The return type of a subscription field is the type of each individual event payload, not a list
- [Inference] Subscription field arguments are evaluated at subscribe time, not per-event — they configure the subscription, not filter individual events after the fact

---

### Enabling Subscriptions in Mercurius

Subscription support is not enabled by default. Pass `subscription: true` at registration:

javascript

```javascript
import Fastify from 'fastify';
import mercurius from 'mercurius';

const fastify = Fastify({ logger: true });

await fastify.register(mercurius, {
  schema,
  resolvers,
  subscription: true,
  graphiql: true,
});

await fastify.listen({ port: 3000 });
```

**Key Points:**

- `subscription: true` activates the WebSocket handler on the `/graphql` endpoint
- Mercurius internally registers `@fastify/websocket` — [Inference] if your application also registers `@fastify/websocket` independently, verify there is no conflict in your Mercurius version
- `graphiql: true` with subscription support enabled allows testing subscriptions directly in the GraphiQL UI

---

### The Built-in Pub/Sub

Mercurius provides an in-memory pub/sub accessible via `fastify.graphql.pubsub` after registration:

javascript

```javascript
// Publish an event
await fastify.graphql.pubsub.publish({
  topic: 'MESSAGE_SENT',
  payload: {
    messageSent: {
      id: '1',
      content: 'Hello',
      author: 'Luke',
      createdAt: new Date().toISOString(),
    },
  },
});

// Subscribe to a topic (returns an async iterator)
const iterator = await fastify.graphql.pubsub.subscribe('MESSAGE_SENT');
```

**Key Points:**

- The built-in pub/sub is in-memory — events do not persist and are not shared across processes
- [Inference] The built-in pub/sub is suitable for development and single-instance deployments only — multi-instance deployments require an external pub/sub (see Redis section below)
- The `payload` object must contain a key matching the subscription field name — `messageSent` for a `Subscription { messageSent }` field
- Topic names are arbitrary strings — they are application-defined and must match between `publish` and `subscribe` calls

---

### Subscription Resolvers

Subscription resolvers have a different structure from query and mutation resolvers. Each subscription field requires a `subscribe` function (and optionally a `resolve` function):

javascript

```javascript
const TOPICS = {
  MESSAGE_SENT: 'MESSAGE_SENT',
  NOTIFICATION: (userId) => `NOTIFICATION_${userId}`,
};

const resolvers = {
  Mutation: {
    sendMessage: async (parent, args, context) => {
      const message = {
        id: String(Date.now()),
        content: args.content,
        author: args.author,
        createdAt: new Date().toISOString(),
      };

      // Publish triggers all active subscribers to this topic
      await fastify.graphql.pubsub.publish({
        topic: TOPICS.MESSAGE_SENT,
        payload: { messageSent: message },
      });

      return message;
    },
  },

  Subscription: {
    messageSent: {
      // subscribe returns an async iterable
      subscribe: async (parent, args, context) => {
        return fastify.graphql.pubsub.subscribe(TOPICS.MESSAGE_SENT);
      },
    },

    notificationReceived: {
      subscribe: async (parent, args, context) => {
        // Per-user topic — args.userId filters the stream at subscribe time
        const topic = TOPICS.NOTIFICATION(args.userId);
        return fastify.graphql.pubsub.subscribe(topic);
      },
    },
  },
};
```

**Key Points:**

- `subscribe` is called once per subscription — when the client sends a `subscribe` message over WebSocket
- The async iterable returned by `subscribe` is consumed by Mercurius — each yielded value is executed as a GraphQL result and pushed to the client
- `resolve` is an optional second property on a subscription resolver — if present, it transforms the raw pub/sub payload before GraphQL field execution. If absent, the raw payload is used directly
- [Inference] The `context` passed to `subscribe` is the same context built by the `context` function — auth, user identity, and services are available here

---

### The `resolve` Function

The optional `resolve` function transforms the raw payload before it reaches field-level resolvers:

javascript

```javascript
Subscription: {
  messageSent: {
    subscribe: async (parent, args, context) => {
      return fastify.graphql.pubsub.subscribe(TOPICS.MESSAGE_SENT);
    },

    // resolve receives the raw payload from publish()
    resolve: async (payload, args, context) => {
      // payload = { messageSent: { id, content, author, createdAt } }
      // Must return the value for the messageSent field
      return payload.messageSent;
    },
  },
},
```

**Key Points:**

- Without `resolve`, Mercurius looks for a key on the payload matching the subscription field name — the payload `{ messageSent: {...} }` is mapped to the `messageSent` field automatically
- With `resolve`, the return value becomes the parent for any field-level resolvers on the `Message` type
- [Inference] `resolve` is useful when the raw pub/sub payload requires transformation, enrichment from a database, or authorization filtering before delivery

---

### Authorization in Subscriptions

Authorization must be applied in the `subscribe` function — not in `resolve`. By the time `resolve` runs, the subscription is already established:

javascript

```javascript
Subscription: {
  notificationReceived: {
    subscribe: async (parent, args, context) => {
      // context.user is populated by the context() function
      if (!context.user) {
        throw new mercurius.ErrorWithProps('Unauthorized', { code: 'UNAUTHORIZED' }, 401);
      }

      // Prevent subscribing to another user's notifications
      if (context.user.id !== args.userId) {
        throw new mercurius.ErrorWithProps('Forbidden', { code: 'FORBIDDEN' }, 403);
      }

      return fastify.graphql.pubsub.subscribe(
        TOPICS.NOTIFICATION(args.userId)
      );
    },
  },
},
```

**Key Points:**

- Throwing in `subscribe` terminates the subscription before it is established — the client receives an error frame
- [Inference] The WebSocket connection context is established during the HTTP upgrade handshake — token-based auth must be passed via query parameter, subprotocol, or initial `connection_init` payload since WebSocket headers cannot be set by the browser directly
- [Inference] Mercurius may support reading auth from the `connection_init` payload — verify against your version for the exact mechanism

---

### WebSocket Context for Subscriptions

The `context` function receives the HTTP request during the WebSocket upgrade. This is where auth headers or cookies can be extracted:

javascript

```javascript
await fastify.register(mercurius, {
  schema,
  resolvers,
  subscription: true,
  context: (request, reply) => {
    // For HTTP queries/mutations: request is the Fastify request
    // For WebSocket subscriptions: request is the HTTP upgrade request
    const token = request.headers.authorization?.split(' ')[1]
      ?? new URL(request.url, 'http://localhost').searchParams.get('token');

    const user = token ? verifyToken(token) : null;

    return { user, db: fastify.db };
  },
});
```

[Inference] The `context` function is called once per WebSocket connection, not per subscription within that connection. Context is shared across all subscriptions on the same WebSocket connection. Behavior may vary across Mercurius versions — verify.

---

### Custom Pub/Sub with `mqemitter`

For more control over the pub/sub mechanism without external dependencies, Mercurius accepts an `mqemitter`-compatible pub/sub:

bash

```bash
npm install mqemitter
```

javascript

```javascript
import mqemitter from 'mqemitter';
import { PubSub } from 'mercurius';

const emitter = mqemitter({ concurrency: 100 });

await fastify.register(mercurius, {
  schema,
  resolvers,
  subscription: {
    emitter, // Custom emitter replaces the default
  },
});
```

[Unverified] The exact API for passing a custom emitter to Mercurius subscriptions varies by version. Verify the `subscription` option shape against your installed version's documentation.

---

### Redis-Backed Pub/Sub for Multi-Instance Deployments

The built-in pub/sub does not share events across multiple Fastify instances. For horizontal scaling, events must be routed through an external broker:

bash

```bash
npm install mqemitter-redis ioredis
```

javascript

```javascript
import mqemitterRedis from 'mqemitter-redis';

const emitter = mqemitterRedis({
  host: process.env.REDIS_HOST ?? 'localhost',
  port: 6379,
  // [Unverified] Additional ioredis options may be passed here — verify the API
});

await fastify.register(mercurius, {
  schema,
  resolvers,
  subscription: {
    emitter,
  },
});
```

**Multi-instance event flow:**

```
Instance A                    Redis                    Instance B
  |                             |                           |
  | Client 1 subscribes         |    Client 2 subscribes    |
  | topic: MESSAGE_SENT         |    topic: MESSAGE_SENT    |
  |                             |                           |
  | Mutation: sendMessage       |                           |
  |-- publish(MESSAGE_SENT) --->|                           |
  |                             |-- fan-out ---------------->|
  |<-- Client 1 receives event  |    Client 2 receives event|
```

**Key Points:**

- `mqemitter-redis` subscribes to Redis pub/sub channels per topic — [Inference] topic names become Redis channel names
- [Inference] All Fastify instances must connect to the same Redis instance or cluster for fan-out to work correctly
- [Unverified] `mqemitter-redis` serialization format and compatibility with recent Redis versions — verify before use in production
- The publish call can be made from any instance — Redis distributes to all subscribers on that topic

---

### Subscription Lifecycle

<svg viewBox="0 0 760 520" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="760" height="520" fill="#0f1117" rx="12"/>
<text x="380" y="28" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">GraphQL Subscription Lifecycle — Mercurius</text>
<!-- Columns -->

<text x="80" y="55" text-anchor="middle" fill="`#7dd3fc`" font-size="11" font-weight="bold">Client</text>
<text x="260" y="55" text-anchor="middle" fill="`#86efac`" font-size="11" font-weight="bold">Mercurius</text>
<text x="450" y="55" text-anchor="middle" fill="`#a78bfa`" font-size="11" font-weight="bold">subscribe()</text>
<text x="640" y="55" text-anchor="middle" fill="`#fbbf24`" font-size="11" font-weight="bold">Pub/Sub</text>

<line x1="80" y1="60" x2="80" y2="500" stroke="#7dd3fc" stroke-width="1" stroke-dasharray="3,3"/>
<line x1="260" y1="60" x2="260" y2="500" stroke="#86efac" stroke-width="1" stroke-dasharray="3,3"/>
<line x1="450" y1="60" x2="450" y2="500" stroke="#a78bfa" stroke-width="1" stroke-dasharray="3,3"/>
<line x1="640" y1="60" x2="640" y2="500" stroke="#fbbf24" stroke-width="1" stroke-dasharray="3,3"/>
<!-- Step 1: WS connect -->
<line x1="80" y1="85" x2="250" y2="85" stroke="#7dd3fc" stroke-width="1.5" marker-end="url(#sa)"/>
<text x="165" y="78" text-anchor="middle" fill="#7dd3fc" font-size="10">WS connect + connection_init</text>
<!-- Step 2: ack -->
<line x1="260" y1="105" x2="90" y2="105" stroke="#86efac" stroke-width="1.5" marker-end="url(#sa)"/>
<text x="175" y="98" text-anchor="middle" fill="#86efac" font-size="10">connection_ack</text>
<!-- Step 3: subscribe message -->
<line x1="80" y1="135" x2="250" y2="135" stroke="#7dd3fc" stroke-width="1.5" marker-end="url(#sa)"/>
<text x="165" y="128" text-anchor="middle" fill="#7dd3fc" font-size="10">{ type: subscribe, query }</text>
<!-- Step 4: parse + validate -->
<rect x="200" y="148" width="120" height="28" rx="4" fill="#1e293b" stroke="#86efac" stroke-width="1"/>
<text x="260" y="167" text-anchor="middle" fill="#86efac" font-size="10">parse + validate SDL</text>
<!-- Step 5: call subscribe() -->
<line x1="260" y1="176" x2="440" y2="176" stroke="#86efac" stroke-width="1.5" marker-end="url(#sa)"/>
<text x="350" y="169" text-anchor="middle" fill="#86efac" font-size="10">invoke subscribe(args, ctx)</text>
<!-- Step 6: subscribe to topic -->
<line x1="450" y1="196" x2="625" y2="196" stroke="#a78bfa" stroke-width="1.5" marker-end="url(#sa)"/>
<text x="537" y="189" text-anchor="middle" fill="#a78bfa" font-size="10">pubsub.subscribe(topic)</text>
<!-- Step 7: async iterable returned -->
<line x1="640" y1="216" x2="465" y2="216" stroke="#fbbf24" stroke-width="1" stroke-dasharray="4,2" marker-end="url(#sa)"/>
<text x="552" y="209" text-anchor="middle" fill="#fbbf24" font-size="10">async iterable</text>
<!-- Connection open label -->
<rect x="165" y="232" width="180" height="22" rx="4" fill="#0f172a" stroke="#334155"/>
<text x="255" y="247" text-anchor="middle" fill="#94a3b8" font-size="10">↻ subscription open — waiting for events</text>
<!-- Step 8: mutation publishes -->
<line x1="640" y1="275" x2="465" y2="275" stroke="#fbbf24" stroke-width="1.5" marker-end="url(#sa)"/>
<text x="552" y="268" text-anchor="middle" fill="#fbbf24" font-size="10">pubsub.publish(topic, payload)</text>
<!-- Step 9: iterable yields -->
<line x1="450" y1="295" x2="275" y2="295" stroke="#a78bfa" stroke-width="1.5" marker-end="url(#sa)"/>
<text x="362" y="288" text-anchor="middle" fill="#a78bfa" font-size="10">iterable yields payload</text>
<!-- Step 10: execute + resolve -->
<rect x="200" y="308" width="120" height="28" rx="4" fill="#1e293b" stroke="#86efac" stroke-width="1"/>
<text x="260" y="327" text-anchor="middle" fill="#86efac" font-size="10">execute resolver(s)</text>
<!-- Step 11: push to client -->
<line x1="260" y1="336" x2="95" y2="336" stroke="#86efac" stroke-width="1.5" marker-end="url(#sa)"/>
<text x="177" y="329" text-anchor="middle" fill="#86efac" font-size="10">{ type: next, payload }</text>
<!-- Step 12: client unsubscribes -->
<line x1="80" y1="390" x2="250" y2="390" stroke="#7dd3fc" stroke-width="1" stroke-dasharray="4,2" marker-end="url(#sa)"/>
<text x="165" y="383" text-anchor="middle" fill="#7dd3fc" font-size="10">{ type: complete, id }</text>
<!-- Step 13: cleanup -->
<line x1="260" y1="410" x2="440" y2="410" stroke="#86efac" stroke-width="1" stroke-dasharray="4,2" marker-end="url(#sa)"/>
<text x="350" y="403" text-anchor="middle" fill="#86efac" font-size="10">iterable.return() — cleanup</text>
<line x1="450" y1="430" x2="625" y2="430" stroke="#a78bfa" stroke-width="1" stroke-dasharray="4,2" marker-end="url(#sa)"/>
<text x="537" y="423" text-anchor="middle" fill="#a78bfa" font-size="10">pubsub.unsubscribe(topic)</text>
<!-- Done -->
<rect x="165" y="455" width="180" height="26" rx="4" fill="#0f172a" stroke="#334155"/>
<text x="255" y="472" text-anchor="middle" fill="#94a3b8" font-size="10">subscription closed — resources freed</text>
<defs>
<marker id="sa" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#475569"/>
</marker>
</defs>
</svg>

---

### Filtering Events Per Subscriber

Not all subscribers should receive all events. Filtering can happen at the topic level (preferred) or in `resolve`:

#### Topic-Level Filtering (Preferred)

javascript

```javascript
// Each user subscribes to their own topic — no cross-contamination
const NOTIFICATION_TOPIC = (userId) => `NOTIFICATION:${userId}`;

Subscription: {
  notificationReceived: {
    subscribe: async (parent, args, context) => {
      return fastify.graphql.pubsub.subscribe(
        NOTIFICATION_TOPIC(args.userId)
      );
    },
  },
},

// In mutation — publish only to the intended recipient's topic
Mutation: {
  sendNotification: async (parent, args, context) => {
    const notification = buildNotification(args);
    await fastify.graphql.pubsub.publish({
      topic: NOTIFICATION_TOPIC(args.recipientId),
      payload: { notificationReceived: notification },
    });
    return notification;
  },
},
```

#### Resolve-Level Filtering

javascript

```javascript
// All subscribers share one topic; resolve filters per subscriber
Subscription: {
  messageSent: {
    subscribe: async (parent, args, context) => {
      return fastify.graphql.pubsub.subscribe(TOPICS.MESSAGE_SENT);
    },

    resolve: async (payload, args, context) => {
      // Return null to suppress delivery to this subscriber
      // [Inference] Mercurius may or may not suppress null payloads —
      // verify behavior with your version before relying on this pattern
      if (payload.messageSent.author === context.user?.blockedAuthor) {
        return null;
      }
      return payload.messageSent;
    },
  },
},
```

[Inference] Returning `null` from `resolve` for a non-null subscription field may produce a GraphQL error rather than silently skipping the event. Topic-level filtering is more reliable and should be preferred where possible.

---

### Using Async Generators as Event Sources

Custom async generators can replace the pub/sub entirely for simple or computed event streams:

javascript

```javascript
Subscription: {
  serverTime: {
    subscribe: async function* (parent, args, context) {
      // Yield events directly — no pub/sub required
      while (true) {
        yield { serverTime: new Date().toISOString() };
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    },
  },
},
```

**Key Points:**

- The generator yields values directly — each yielded value is executed as a GraphQL event result
- [Inference] When the client unsubscribes, Mercurius calls `.return()` on the async iterator — the generator's `finally` block can be used for cleanup
- This pattern is useful for time-based streams, computed data, or integration with Node.js event emitters without a full pub/sub setup
- [Inference] Infinite generators require a termination signal — relying on client disconnect and generator cleanup via `.return()` is the standard approach, but verify this behavior in your Mercurius version

**With cleanup:**

javascript

```javascript
subscribe: async function* (parent, args, context) {
  const emitter = buildEventEmitter(); // e.g., from an external system

  try {
    for await (const event of emitter) {
      yield { serverTime: event.timestamp };
    }
  } finally {
    // Called when client unsubscribes or connection drops
    emitter.destroy();
  }
},
```

---

### Client-Side Subscription (Browser)

Using `graphql-ws` on the client:

bash

```bash
npm install graphql-ws
```

javascript

```javascript
import { createClient } from 'graphql-ws';

const client = createClient({
  url: 'ws://localhost:3000/graphql',
  connectionParams: {
    // Passed as connection_init payload — readable server-side
    authToken: localStorage.getItem('token'),
  },
});

const unsubscribe = client.subscribe(
  {
    query: `
      subscription {
        messageSent {
          id
          content
          author
          createdAt
        }
      }
    `,
  },
  {
    next: (data) => console.log('Event:', data),
    error: (err) => console.error('Error:', err),
    complete: () => console.log('Subscription complete'),
  }
);

// Unsubscribe when done
unsubscribe();
```

**Key Points:**

- `connectionParams` is sent in the `connection_init` message — Mercurius can expose this in the subscription context
- [Unverified] Exactly how Mercurius exposes `connectionParams` from the `connection_init` payload — verify against the installed version
- `unsubscribe()` sends a `complete` message to the server, allowing it to clean up the async iterable
- [Inference] If the client drops without sending `complete` (e.g., browser tab closed), Mercurius detects the WebSocket close event and cleans up — verify cleanup reliability under your Mercurius version

---

### Testing Subscriptions

`fastify.inject()` does not support WebSocket connections. Integration tests require a real server:

javascript

```javascript
import { createClient } from 'graphql-ws';
import WebSocket from 'ws';
import { test } from 'node:test';
import assert from 'node:assert/strict';

test('messageSent subscription receives events', async (t) => {
  await fastify.listen({ port: 0 }); // Port 0 = random available port
  const { port } = fastify.server.address();

  const client = createClient({
    url: `ws://localhost:${port}/graphql`,
    webSocketImpl: WebSocket, // Node.js needs an explicit WS implementation
  });

  const received = [];

  const unsubscribe = client.subscribe(
    { query: `subscription { messageSent { id content author } }` },
    { next: (data) => received.push(data), error: assert.fail, complete: () => {} }
  );

  // Allow subscription to establish
  await new Promise(resolve => setTimeout(resolve, 50));

  // Trigger a mutation to publish an event
  await fastify.inject({
    method: 'POST',
    url: '/graphql',
    payload: {
      query: `mutation { sendMessage(content: "hello", author: "test") { id } }`,
    },
  });

  // Allow event delivery
  await new Promise(resolve => setTimeout(resolve, 50));

  unsubscribe();
  assert.equal(received.length, 1);
  assert.equal(received[0].data.messageSent.content, 'hello');

  await fastify.close();
});
```

**Key Points:**

- `port: 0` asks the OS to assign a free port — avoids port conflicts in test suites
- `setTimeout` delays are brittle — [Inference] a more robust approach uses a Promise that resolves when the first event is received
- [Inference] The `ws` package must be installed explicitly for Node.js environments where a native WebSocket is not available — Node.js 22+ includes a native `WebSocket` global

---

**Related Topics:**

- Redis pub/sub with `mqemitter-redis` for clustered Mercurius deployments
- Subscription authorization patterns (connection_init token, cookie auth)
- Filtering subscription events at topic level vs resolve level
- Async generators as Mercurius subscription sources
- `graphql-ws` protocol in depth (connection lifecycle, error codes)
- Mercurius subscription context and connectionParams access
- Real-time collaborative features with subscriptions and optimistic UI
- Combining SSE and GraphQL subscriptions in a single Fastify instance
- Load testing WebSocket subscriptions in Fastify
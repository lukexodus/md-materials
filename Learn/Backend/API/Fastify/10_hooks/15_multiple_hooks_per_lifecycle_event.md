## Fastify Hooks — Multiple Hooks per Lifecycle Event

### Overview

Fastify allows registering more than one hook for the same lifecycle event. This is a deliberate design feature that enables composable, layered behavior — each hook handles a single responsibility, and multiple hooks chain together to form a processing pipeline. Understanding how multiple hooks interact, execute, and handle errors is critical for building maintainable applications.

---

### Registration

Multiple hooks for the same event are registered by calling `addHook` multiple times with the same event name:

```js
fastify.addHook('onRequest', async (request, reply) => {
  request.log.info('Hook 1: onRequest');
});

fastify.addHook('onRequest', async (request, reply) => {
  request.log.info('Hook 2: onRequest');
});

fastify.addHook('onRequest', async (request, reply) => {
  request.log.info('Hook 3: onRequest');
});
```

All three hooks are registered for the same `onRequest` event and will all execute for every incoming request.

---

### Execution Order — FIFO

Multiple hooks for the same lifecycle event execute in **first-in, first-out (FIFO)** order — the order in which they were registered.

```js
fastify.addHook('preHandler', async (request, reply) => {
  console.log('Step 1: Authenticate');
});

fastify.addHook('preHandler', async (request, reply) => {
  console.log('Step 2: Authorize');
});

fastify.addHook('preHandler', async (request, reply) => {
  console.log('Step 3: Rate limit check');
});
```

**Output:**
```
Step 1: Authenticate
Step 2: Authorize
Step 3: Rate limit check
```

> **Disclaimer:** Execution order applies within the same scope. Hooks registered at different scope levels (root vs plugin) execute root hooks first, then child hooks, which may interleave with same-event hooks registered at deeper levels.

---

### Execution Pipeline Visualization

Each lifecycle event forms a sequential pipeline when multiple hooks are registered. Each hook must complete before the next begins:

<svg viewBox="0 0 700 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <!-- Pipeline background -->
  <rect x="20" y="60" width="660" height="60" rx="8" fill="#f1f5f9" stroke="#e2e8f0" stroke-width="1.5"/>

  <!-- Request arrow in -->
  <line x1="0" y1="90" x2="30" y2="90" stroke="#64748b" stroke-width="2" marker-end="url(#arr)"/>
  <text x="2" y="82" fill="#64748b" font-size="11">req</text>

  <!-- Hook boxes -->
  <rect x="30" y="65" width="120" height="50" rx="6" fill="#4f46e5" opacity="0.15" stroke="#4f46e5" stroke-width="1.5"/>
  <text x="90" y="87" text-anchor="middle" fill="#4f46e5" font-weight="bold">Hook 1</text>
  <text x="90" y="103" text-anchor="middle" fill="#4f46e5" font-size="11">authenticate</text>

  <line x1="150" y1="90" x2="190" y2="90" stroke="#64748b" stroke-width="2" marker-end="url(#arr)"/>

  <rect x="190" y="65" width="120" height="50" rx="6" fill="#4f46e5" opacity="0.15" stroke="#4f46e5" stroke-width="1.5"/>
  <text x="250" y="87" text-anchor="middle" fill="#4f46e5" font-weight="bold">Hook 2</text>
  <text x="250" y="103" text-anchor="middle" fill="#4f46e5" font-size="11">authorize</text>

  <line x1="310" y1="90" x2="350" y2="90" stroke="#64748b" stroke-width="2" marker-end="url(#arr)"/>

  <rect x="350" y="65" width="120" height="50" rx="6" fill="#4f46e5" opacity="0.15" stroke="#4f46e5" stroke-width="1.5"/>
  <text x="410" y="87" text-anchor="middle" fill="#4f46e5" font-weight="bold">Hook 3</text>
  <text x="410" y="103" text-anchor="middle" fill="#4f46e5" font-size="11">rate limit</text>

  <line x1="470" y1="90" x2="510" y2="90" stroke="#64748b" stroke-width="2" marker-end="url(#arr)"/>

  <!-- Handler box -->
  <rect x="510" y="65" width="140" height="50" rx="6" fill="#059669" opacity="0.15" stroke="#059669" stroke-width="1.5"/>
  <text x="580" y="87" text-anchor="middle" fill="#059669" font-weight="bold">Route Handler</text>
  <text x="580" y="103" text-anchor="middle" fill="#059669" font-size="11">business logic</text>

  <!-- Output arrow -->
  <line x1="650" y1="90" x2="690" y2="90" stroke="#64748b" stroke-width="2" marker-end="url(#arr)"/>
  <text x="656" y="82" fill="#64748b" font-size="11">res</text>

  <!-- Error path -->
  <text x="90" y="145" text-anchor="middle" fill="#dc2626" font-size="11">throws → pipeline stops</text>
  <line x1="90" y1="115" x2="90" y2="138" stroke="#dc2626" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#errArr)"/>

  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#64748b"/>
    </marker>
    <marker id="errArr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#dc2626"/>
    </marker>
  </defs>
</svg>

---

### Stopping the Pipeline — Throwing an Error

If any hook in the chain throws an error or sends a reply, the remaining hooks and the route handler are **not executed**. The pipeline halts at the point of failure.

```js
fastify.addHook('preHandler', async (request, reply) => {
  console.log('Hook 1: runs');
});

fastify.addHook('preHandler', async (request, reply) => {
  console.log('Hook 2: runs, then throws');
  throw new Error('Unauthorized');
});

fastify.addHook('preHandler', async (request, reply) => {
  // This never executes
  console.log('Hook 3: never reached');
});
```

**Output:**
```
Hook 1: runs
Hook 2: runs, then throws
```

The error is then handled by Fastify's error handler, producing an error response to the client.

---

### Stopping the Pipeline — Sending a Reply Early

Calling `reply.send()` inside a hook also halts the pipeline. The remaining hooks and handler are skipped.

```js
fastify.addHook('onRequest', async (request, reply) => {
  if (request.headers['x-maintenance'] === 'true') {
    reply.code(503).send({ error: 'Service under maintenance' });
    // Pipeline stops here — no further hooks or handler execute
  }
});

fastify.addHook('onRequest', async (request, reply) => {
  // Only reached if maintenance header is absent
  request.log.info('Proceeding with request');
});
```

> **Disclaimer:** Behavior when `reply.send()` is called inside a hook may vary slightly depending on the hook type and Fastify version. Always verify with the version in use.

---

### Multiple Hooks Across Scopes

When hooks are registered at multiple scope levels — root and plugin — all applicable hooks execute, with parent (outer) hooks running before child (inner) hooks.

```js
// Root-level hook — runs for all routes
fastify.addHook('onRequest', async (request) => {
  console.log('Root Hook 1');
});

fastify.addHook('onRequest', async (request) => {
  console.log('Root Hook 2');
});

fastify.register(async function plugin(instance) {
  instance.addHook('onRequest', async (request) => {
    console.log('Plugin Hook 1');
  });

  instance.addHook('onRequest', async (request) => {
    console.log('Plugin Hook 2');
  });

  instance.get('/scoped', async () => ({ ok: true }));
});
```

**Output for `GET /scoped`:**
```
Root Hook 1
Root Hook 2
Plugin Hook 1
Plugin Hook 2
```

The full execution order is: all root hooks in FIFO order, then all plugin-level hooks in FIFO order.

---

### Mixing Async and Callback Styles

Multiple hooks for the same event can mix async and callback styles. Fastify handles both transparently.

```js
// Async style
fastify.addHook('preValidation', async (request, reply) => {
  request.enrichedData = await fetchEnrichment(request.ip);
});

// Callback style
fastify.addHook('preValidation', function (request, reply, done) {
  if (!request.enrichedData) {
    return done(new Error('Enrichment failed'));
  }
  done();
});
```

> **Disclaimer:** Mixing styles works but may reduce readability. Prefer a consistent style within a codebase where possible.

---

### Practical Patterns

#### Pattern 1 — Decomposed Authentication and Authorization

Separate distinct concerns into individual hooks rather than combining them into one large hook:

```js
// Hook 1: Verify the token exists and is well-formed
fastify.addHook('onRequest', async (request, reply) => {
  const token = request.headers.authorization?.split(' ')[1];
  if (!token) {
    reply.code(401).send({ error: 'Missing token' });
    return;
  }
  request.token = token;
});

// Hook 2: Decode the token and attach user
fastify.addHook('onRequest', async (request, reply) => {
  try {
    request.user = await decodeToken(request.token);
  } catch {
    reply.code(401).send({ error: 'Invalid token' });
  }
});

// Hook 3: Check user permissions
fastify.addHook('preHandler', async (request, reply) => {
  if (!request.user.roles.includes('admin')) {
    reply.code(403).send({ error: 'Forbidden' });
  }
});
```

**Key Points:**
- Each hook has a single responsibility
- Failures in any hook stop the pipeline immediately
- State (`request.token`, `request.user`) is passed between hooks via the `request` object

#### Pattern 2 — Request Enrichment Pipeline

Build up request context progressively across multiple hooks:

```js
fastify.addHook('preHandler', async (request) => {
  request.requestedAt = Date.now();
});

fastify.addHook('preHandler', async (request) => {
  request.geoData = await resolveGeo(request.ip);
});

fastify.addHook('preHandler', async (request) => {
  request.featureFlags = await getFlags(request.user?.id);
});
```

Each hook adds one piece of context. By the time the route handler runs, `request` carries all enriched data.

#### Pattern 3 — Layered Response Transformation with onSend

```js
// Wrap response in an envelope
fastify.addHook('onSend', async (request, reply, payload) => {
  const parsed = JSON.parse(payload);
  return JSON.stringify({ data: parsed, requestId: request.id });
});

// Compress or annotate further
fastify.addHook('onSend', async (request, reply, payload) => {
  reply.header('x-response-size', Buffer.byteLength(payload));
  return payload;
});
```

> **Disclaimer:** Chaining `onSend` hooks that re-serialize JSON adds overhead. For high-throughput routes, evaluate the performance impact.

---

### Error Propagation Across Multiple Hooks

When a hook throws, Fastify routes the error to `onError` hooks (if registered) and then to the global error handler. Subsequent same-event hooks do not execute.

```js
fastify.addHook('onError', async (request, reply, error) => {
  request.log.error({ err: error }, 'Caught by onError hook');
});

fastify.addHook('preHandler', async (request, reply) => {
  throw new Error('Something went wrong');
});

// This preHandler hook never runs
fastify.addHook('preHandler', async (request, reply) => {
  console.log('Skipped due to prior error');
});
```

---

### Execution Summary Table

| Scenario | Behavior |
|---|---|
| Multiple hooks, same event, same scope | Execute in FIFO registration order |
| Multiple hooks, same event, root + plugin scope | Root hooks first (FIFO), then plugin hooks (FIFO) |
| Hook throws an error | Pipeline halts; remaining hooks and handler skipped |
| Hook sends reply early | Pipeline halts; remaining hooks and handler skipped |
| `onClose` with multiple hooks | Executes in LIFO order (reverse of registration) |
| Mix of async and callback hooks | Both supported; Fastify normalizes execution |

---

### Common Pitfalls

**Pitfall 1 — Assuming hooks are independent:**
Multiple hooks for the same event are not independent — they form a chain. An error or early reply in hook N stops hooks N+1, N+2, and the route handler.

**Pitfall 2 — Mutating payload in onSend without returning it:**
In `onSend`, the modified payload must be returned. Forgetting to return it results in the original unmodified payload being sent.

```js
// Incorrect
fastify.addHook('onSend', async (request, reply, payload) => {
  payload = JSON.stringify({ wrapped: JSON.parse(payload) });
  // Missing return — original payload sent instead
});

// Correct
fastify.addHook('onSend', async (request, reply, payload) => {
  return JSON.stringify({ wrapped: JSON.parse(payload) });
});
```

**Pitfall 3 — Relying on inter-hook state without null checks:**
If an earlier hook fails to set `request.user` and a later hook reads it without a null check, a runtime error may cascade unpredictably.

**Pitfall 4 — Registering the same hook logic multiple times unintentionally:**
In hot-reload or plugin re-registration scenarios, `addHook` calls may accumulate duplicates. [Inference: Fastify does not deduplicate hooks automatically.]

---

**Conclusion:**
Multiple hooks per lifecycle event are a core mechanism for building composable Fastify applications. They execute sequentially in FIFO order within the same scope, with parent scope hooks running before child scope hooks. Any hook can halt the pipeline by throwing or sending a reply early. This predictable, ordered execution model enables clean separation of concerns — authentication, authorization, enrichment, transformation, and logging can each live in their own hook, chained together into a coherent processing pipeline.
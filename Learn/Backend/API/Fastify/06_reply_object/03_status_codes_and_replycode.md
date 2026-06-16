### Fastify Reply — Status Codes and `reply.code`

#### Overview

HTTP status codes communicate the outcome of a request to the client. Fastify provides `reply.code()` as the primary chainable method for setting the response status code, alongside the directly assignable `reply.statusCode` property. Both target the same internal state. Fastify applies sensible defaults automatically, but explicit status code management is essential for accurate API semantics.

---

#### `reply.code(statusCode)`

Sets the HTTP status code for the response. Returns `reply` for chaining.

js

```
fastify.post('/resource', async (request, reply) => {
  const item = await db.create(request.body);
  return reply.code(201).send(item);
});
```

**Key Points:**

- Accepts any integer. Fastify does not restrict input to standard HTTP codes, though sending non-standard codes may confuse clients and intermediaries.
- Returns `reply`, making it suitable for chaining with `reply.header()`, `reply.type()`, and `reply.send()`.
- Does not send the response on its own — `reply.send()` or a return value still dispatches it.

---

#### `reply.statusCode`

A readable and writable property equivalent to `reply.code()`.

js

```
reply.statusCode = 202;
return { queued: true };
```

**Key Points:**

- Direct assignment does not return `reply`, so it cannot be chained.
- Useful when the status code needs to be set conditionally without interrupting a later chain.
- Reading `reply.statusCode` returns the currently set value, defaulting to `200` until changed.

---

#### Default Status Codes

Fastify sets status codes automatically in certain conditions without requiring explicit configuration.

| Condition | Default Status Code |
| --- | --- |
| Successful handler completion | `200` |
| Unhandled thrown error | `500` |
| Route not found | `404` |
| Method not allowed | `405` |
| Payload too large | `413` |
| Invalid `Content-Type` | `415` |
| Request body validation failure | `400` |

**Key Points:**

- The `400` on validation failure is produced by Fastify's schema validation pipeline, not by application code.
- The `500` on unhandled errors can be overridden by a custom error handler registered with `fastify.setErrorHandler()`.

---

#### Common Status Code Patterns

##### `201 Created` — Resource creation

js

```
fastify.post('/users', async (request, reply) => {
  const user = await db.createUser(request.body);
  return reply
    .code(201)
    .header('Location', `/users/${user.id}`)
    .send(user);
});
```

##### `204 No Content` — Successful operation with no response body

js

```
fastify.delete('/users/:id', async (request, reply) => {
  await db.deleteUser(request.params.id);
  return reply.code(204).send();
});
```

**Key Points:**

- `204` responses must not include a body per the HTTP specification. Sending a body with `204` is a protocol violation, though behavior in clients and proxies when this occurs is not guaranteed to be consistent. [Unverified for all environments]
- Calling `reply.send()` with no argument or with `null` produces an empty body.

##### `202 Accepted` — Async processing accepted but not yet complete

js

```
fastify.post('/jobs', async (request, reply) => {
  const jobId = await queue.enqueue(request.body);
  return reply.code(202).send({ jobId });
});
```

##### `400 Bad Request` — Application-level input rejection

js

```
fastify.post('/transfer', async (request, reply) => {
  if (request.body.amount <= 0) {
    return reply.code(400).send({ error: 'Amount must be positive' });
  }
  // ...
});
```

**Key Points:**

- Fastify's schema validation produces its own `400` response before the handler runs. This pattern applies when business-rule validation occurs inside the handler itself.

##### `401 Unauthorized` — Missing or invalid authentication

js

```
fastify.addHook('preHandler', async (request, reply) => {
  const token = request.headers.authorization;
  if (!token || !isValid(token)) {
    return reply.code(401).send({ error: 'Unauthorized' });
  }
});
```

##### `403 Forbidden` — Authenticated but insufficient permissions

js

```
fastify.get('/admin', async (request, reply) => {
  if (request.user.role !== 'admin') {
    return reply.code(403).send({ error: 'Forbidden' });
  }
  return { panel: true };
});
```

##### `404 Not Found` — Resource does not exist

js

```
fastify.get('/users/:id', async (request, reply) => {
  const user = await db.findUser(request.params.id);
  if (!user) {
    return reply.code(404).send({ error: 'User not found' });
  }
  return user;
});
```

Alternatively, use `reply.callNotFound()` to delegate to Fastify's registered not-found handler:

js

```
if (!user) return reply.callNotFound();
```

##### `409 Conflict` — State conflict (e.g., duplicate resource)

js

```
fastify.post('/users', async (request, reply) => {
  const exists = await db.userExists(request.body.email);
  if (exists) {
    return reply.code(409).send({ error: 'Email already registered' });
  }
  // ...
});
```

##### `422 Unprocessable Entity` — Semantically invalid input

js

```
return reply.code(422).send({ error: 'Start date must precede end date' });
```

**Key Points:**

- `400` and `422` are frequently confused. `400` typically signals malformed or unparseable input; `422` signals that the input was parsed correctly but fails semantic validation. The distinction is a convention, not enforced by HTTP. [Inference]

##### `429 Too Many Requests` — Rate limiting

js

```
fastify.addHook('onRequest', async (request, reply) => {
  const allowed = await rateLimit(request.ip);
  if (!allowed) {
    return reply
      .code(429)
      .header('Retry-After', '60')
      .send({ error: 'Too many requests' });
  }
});
```

##### `500 Internal Server Error` — Unhandled failure

Typically produced automatically by Fastify when a handler throws. Can be sent explicitly for known but unrecoverable conditions.

js

```
fastify.get('/dangerous', async (request, reply) => {
  try {
    await riskyOperation();
  } catch (err) {
    request.log.error(err);
    return reply.code(500).send({ error: 'Internal error' });
  }
});
```

---

#### Setting Status Code Conditionally

js

```
fastify.put('/users/:id', async (request, reply) => {
  const { created, user } = await db.upsertUser(
    request.params.id,
    request.body
  );

  reply.statusCode = created ? 201 : 200;
  return user;
});
```

**Key Points:**

- Assigning `reply.statusCode` before returning a value is a clean pattern when the status depends on runtime logic but the response body is uniform.

---

#### Using `http-errors` Compatible Objects

Fastify recognizes error objects with a `statusCode` property and uses it to set the response status automatically. The `@fastify/sensible` plugin exposes a convenient set of these.

js

```
await fastify.register(require('@fastify/sensible'));

fastify.get('/secure', async (request, reply) => {
  if (!request.headers.authorization) {
    throw reply.httpErrors.unauthorized('Missing token');
  }
  return { data: true };
});
```

**Key Points:**

- `@fastify/sensible` is a separate plugin and must be installed and registered. It is not part of Fastify core.
- Throwing an error object with a `statusCode` property is the idiomatic pattern for error responses in async handlers — it keeps handler logic linear and avoids explicit `reply.send()` calls on error paths.

---

#### Custom Error Handler and Status Codes

`fastify.setErrorHandler()` intercepts all errors before they are serialized, allowing global control over status codes derived from errors.

js

```
fastify.setErrorHandler((error, request, reply) => {
  const statusCode = error.statusCode ?? 500;
  request.log.error(error);
  reply.code(statusCode).send({
    error: error.name,
    message: error.message,
    statusCode,
  });
});
```

**Key Points:**

- `error.statusCode` is set by `http-errors`-compatible objects and by Fastify's own validation errors.
- Plain `Error` objects thrown without a `statusCode` will default to `500` in this pattern.
- The custom error handler does not run for errors that bypass the Fastify pipeline (e.g., errors written directly to `reply.raw`).

---

#### Status Codes and Response Schema

When a route defines a response schema, the schema is keyed by status code. This enables `fast-json-stringify` to use the correct schema for the actual status sent.

js

```
fastify.get('/users/:id', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          id:   { type: 'integer' },
          name: { type: 'string' },
        },
      },
      404: {
        type: 'object',
        properties: {
          error: { type: 'string' },
        },
      },
    },
  },
  async handler(request, reply) {
    const user = await db.find(request.params.id);
    if (!user) return reply.code(404).send({ error: 'Not found' });
    return user;
  },
});
```

**Key Points:**

- Properties absent from the schema for a given status code are stripped from the serialized response.
- If no schema is defined for the actual status code sent, Fastify falls back to `JSON.stringify`. [Inference: verify fallback behavior for the version in use.]
- A `2xx` wildcard key can be used to cover all successful status codes under one schema, depending on the Fastify version.

---

#### `reply.code` vs `reply.statusCode` — Comparison

|  | `reply.code(n)` | `reply.statusCode = n` |
| --- | --- | --- |
| Returns | `reply` (chainable) | `undefined` |
| Style | Method call | Property assignment |
| Use case | Inline chaining | Conditional assignment before return |
| Behavior | Identical | Identical |

---
### Fastify Reply — Sending Responses with `reply.send`

#### Overview

`reply.send(payload)` is the primary mechanism for dispatching an HTTP response in Fastify. It accepts a range of payload types, delegates to Fastify's serialization pipeline when appropriate, sets headers automatically based on payload type, and integrates with the full lifecycle hook chain before the response is written to the socket.

In `async` handlers, returning a value is functionally equivalent to calling `reply.send()` with that value. Both paths converge into the same internal dispatch logic.

---

#### Basic Usage

js

```
fastify.get('/hello', async (request, reply) => {
  reply.send({ message: 'hello' });
});
```

Equivalent using return:

js

```
fastify.get('/hello', async (request, reply) => {
  return { message: 'hello' };
});
```

**Key Points:**

- Both forms are valid and produce identical responses.
- Mixing both in the same handler — returning a value after calling `reply.send()` — can produce unexpected behavior. [Inference: Fastify may warn or ignore the return value; behavior may vary by version.]
- In callback-style (non-async) handlers, `reply.send()` must be called explicitly since there is no return value to intercept.

---

#### Payload Types and Automatic Behavior

Fastify inspects the payload type at dispatch time and adjusts serialization and `Content-Type` accordingly.

---

##### Objects and Arrays

Serialized using Fastify's JSON serialization pipeline. If a response schema is defined for the route, `fast-json-stringify` is used. Otherwise, `JSON.stringify` is the fallback.

js

```
fastify.get('/obj', async (request, reply) => {
  return { id: 1, name: 'Luke' };
});
```

`Content-Type` is set to `application/json; charset=utf-8` automatically.

**Key Points:**

- Defining a response schema significantly improves serialization throughput because `fast-json-stringify` generates optimized code at startup rather than introspecting at runtime. [Inference: based on documented rationale; actual throughput gain depends on payload size and shape.]
- Properties not declared in the response schema are stripped from the output when a schema is active. This is by design.

---

##### Strings

Sent as-is without JSON encoding.

js

```
fastify.get('/text', async (request, reply) => {
  reply.type('text/plain').send('plain text response');
});
```

`Content-Type` defaults to `text/plain; charset=utf-8` when no explicit type is set and the payload is a string.

**Key Points:**

- A string payload that resembles JSON is not re-encoded — it is written directly to the response body.
- If the intent is to send a JSON string, `reply.type('application/json')` should be set explicitly.

---

##### Buffers

Sent as raw binary data.

js

```
const { readFileSync } = require('fs');

fastify.get('/image', async (request, reply) => {
  const img = readFileSync('./photo.png');
  reply.type('image/png').send(img);
});
```

`Content-Type` defaults to `application/octet-stream` when no type is explicitly set and the payload is a `Buffer`.

---

##### Streams

A Node.js `Readable` stream is piped directly to the response.

js

```
const { createReadStream } = require('fs');

fastify.get('/file', async (request, reply) => {
  const stream = createReadStream('./large-file.csv');
  reply.type('text/csv').send(stream);
});
```

**Key Points:**

- Fastify pipes the stream to `reply.raw` and handles cleanup.
- `Content-Length` is not set automatically for streams since the total size is typically unknown at send time.
- Stream errors should be handled on the stream itself before passing to `reply.send()`, or they may surface as unhandled errors. [Inference: verify error propagation behavior for the Fastify version in use.]

---

##### Errors

When an `Error` object is passed to `reply.send()`, Fastify routes it through the error handling pipeline rather than serializing it as a payload.

js

```
fastify.get('/fail', async (request, reply) => {
  reply.send(new Error('something went wrong'));
});
```

Equivalent to throwing inside an async handler:

js

```
fastify.get('/fail', async (request, reply) => {
  throw new Error('something went wrong');
});
```

**Key Points:**

- The default error response shape is `{ statusCode, error, message }`.
- Custom error handlers registered via `fastify.setErrorHandler()` intercept errors before they are serialized.
- HTTP-Errors-compatible objects (e.g., from the `http-errors` package or `@fastify/sensible`) carry a `statusCode` property that Fastify uses to set the response status automatically.

**Example using `@fastify/sensible`:**

js

```
fastify.get('/not-found', async (request, reply) => {
  throw reply.notFound('Resource does not exist');
});
```

---

##### `null` and `undefined`

Sending `null` produces an empty response body with status `200`.

js

```
reply.send(null); // empty body, 200
```

Returning `undefined` from an async handler has the same effect as returning `null` in most cases — Fastify sends an empty body. [Inference: exact behavior for `undefined` may differ by version; verify.]

---

#### Payload Flow Through Hooks

When `reply.send()` is called, the payload does not go directly to the socket. It passes through the `onSend` hook chain first.

YesNoreply.send called / valuereturnedonSend hooks runpayload modified?Use modified payloadUse original payloadSerializationWrite to reply.raw / socketonResponse hooks run

**Key Points:**

- Each `onSend` hook receives `(request, reply, payload, done)` and may replace the payload by passing a new value to `done` or returning it.
- The payload at the `onSend` stage is already a string or `Buffer` if serialization has occurred, or still the raw object if it has not yet been serialized. [Inference: exact serialization timing relative to `onSend` may vary by Fastify version.]
- `onResponse` hooks run after the response is fully written and cannot alter the response.

---

#### Chaining with `reply.code()` and `reply.type()`

`reply.send()` is typically the terminal call in a chain. Methods that return `reply` can precede it.

js

```
fastify.post('/resource', async (request, reply) => {
  const created = await db.insert(request.body);
  reply
    .code(201)
    .header('Location', `/resource/${created.id}`)
    .type('application/json')
    .send(created);
});
```

**Key Points:**

- `reply.send()` itself does not return a useful value for chaining — it returns `reply` but the response dispatch has been initiated.
- In async handlers, once `reply.send()` is called, the function should return immediately or ensure no further response-altering code runs.

---

#### Sending a Response Early from a Hook

Hooks can call `reply.send()` to short-circuit the normal handler execution. This is common for authentication or caching layers.

js

```
fastify.addHook('preHandler', async (request, reply) => {
  if (!request.headers.authorization) {
    reply.code(401).send({ error: 'Unauthorized' });
  }
});
```

**Key Points:**

- When `reply.send()` is called inside a hook, Fastify skips remaining hooks of the same type and the route handler. [Inference: verify exact behavior for the specific hook stage and Fastify version in use.]
- The `onSend` and `onResponse` hooks still run after an early send.

---

#### `reply.sent` Guard

After `reply.send()` has been called, `reply.sent` is `true`. Attempting to send again after this point should be avoided.

js

```
fastify.addHook('onSend', async (request, reply, payload) => {
  if (reply.sent) return payload; // already dispatched
  // modify payload
  return payload;
});
```

---

#### Async Handler Return vs. Explicit `reply.send` — When to Choose

| Scenario | Recommended |
| --- | --- |
| Simple JSON response | `return value` |
| Setting status code and headers before responding | `reply.code().header().send()` |
| Streaming response | `reply.send(stream)` — return not suitable |
| Early exit in conditional logic | `return reply.send(value)` to terminate clearly |
| Non-async (callback) handler | `reply.send()` required |

**Example — explicit early return pattern:**

js

```
fastify.get('/item/:id', async (request, reply) => {
  const item = await db.find(request.params.id);

  if (!item) {
    return reply.code(404).send({ error: 'Not found' });
  }

  return item;
});
```

Using `return reply.send(...)` on the early exit path communicates intent clearly and stops further execution in the handler.

---
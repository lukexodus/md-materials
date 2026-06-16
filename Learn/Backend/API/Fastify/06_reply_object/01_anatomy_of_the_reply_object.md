### Fastify Reply Object — Anatomy

#### Overview

The Fastify `reply` object is the server-side abstraction for constructing and sending HTTP responses. It wraps Node.js's native `http.ServerResponse` (accessible as `reply.raw`) and provides a structured, chainable API for setting status codes, headers, cookies, and response bodies. Every route handler and hook that participates in the response pipeline receives this object as its second argument.

---

#### Internal Structure

Fastify constructs a new reply instance for every incoming request. The reply object is an instance of `FastifyReply`, which is built on a shared prototype for performance. Key internal state includes:

- The raw Node.js response (`reply.raw`)
- A reference back to the Fastify server instance (`reply.server`)
- The associated request object (`reply.request`)
- Internal flags for whether the response has been sent
- The current status code, headers map, and serialization context

[Inference: the exact internal fields and their names are implementation details subject to change across Fastify versions. The publicly documented API surface is stable; internal properties prefixed with `_` are not part of the public contract.]

---

#### `reply.raw`

Provides direct access to the underlying Node.js `http.ServerResponse` object.

js

```
fastify.get('/raw', async (request, reply) => {
  reply.raw.setHeader('X-Custom', 'value');
  reply.raw.end('direct response');
});
```

**Key Points:**

- Bypassing `reply` and writing directly to `reply.raw` skips Fastify's serialization, hook pipeline, and logging.
- If `reply.raw.end()` is called directly, Fastify may still attempt further processing unless the response is properly signaled as complete. [Inference]
- Direct use of `reply.raw` is generally discouraged unless integrating with middleware or libraries that require the native response object.

---

#### `reply.server`

A reference to the enclosing Fastify instance. Useful within reply contexts when access to decorators, configuration, or other plugins registered on the instance is needed.

js

```
fastify.decorate('config', { version: '1.0.0' });

fastify.get('/version', async (request, reply) => {
  return { version: reply.server.config.version };
});
```

---

#### `reply.request`

A back-reference to the associated `FastifyRequest` object for the current request-response cycle.

js

```
fastify.get('/echo-ip', async (request, reply) => {
  return { ip: reply.request.ip };
});
```

**Key Points:**

- Primarily useful inside hooks or utility functions that receive only the `reply` object and need request context.

---

#### Status Code

##### `reply.statusCode`

A readable and writable property reflecting the current HTTP status code for the response.

js

```
fastify.get('/status', async (request, reply) => {
  reply.statusCode = 202;
  return { accepted: true };
});
```

##### `reply.code(statusCode)`

The chainable method form for setting the status code. Equivalent to assigning `reply.statusCode` but returns `reply` for chaining.

js

```
fastify.get('/created', async (request, reply) => {
  return reply.code(201).send({ id: 99 });
});
```

**Key Points:**

- `reply.code()` and `reply.statusCode =` are functionally equivalent for setting the status.
- Default status code is `200` unless explicitly changed.
- Fastify automatically sets `500` when an unhandled error occurs during the handler.

---

#### Headers

##### `reply.header(key, value)`

Sets a single response header. Chainable.

js

```
reply.header('Content-Type', 'application/json').header('X-Request-Id', '123');
```

##### `reply.headers(object)`

Sets multiple headers at once from a plain object.

js

```
reply.headers({
  'Cache-Control': 'no-store',
  'X-Frame-Options': 'DENY',
});
```

##### `reply.getHeader(key)`

Returns the current value of a previously set header. Returns `undefined` if not set.

js

```
const ct = reply.getHeader('content-type');
```

##### `reply.getHeaders()`

Returns a shallow copy of all headers currently set on the reply.

js

```
const all = reply.getHeaders();
```

##### `reply.removeHeader(key)`

Removes a previously set header.

js

```
reply.removeHeader('X-Powered-By');
```

##### `reply.hasHeader(key)`

Returns a boolean indicating whether the named header has been set.

js

```
if (!reply.hasHeader('x-request-id')) {
  reply.header('x-request-id', generateId());
}
```

---

#### `reply.send(payload)`

Sends the response. The `payload` argument determines what is written to the response body.

js

```
fastify.get('/hello', async (request, reply) => {
  reply.send({ message: 'hello' });
});
```

Accepted payload types and their behavior:

| Payload Type | Behavior |
| --- | --- |
| Plain object or Array | Serialized via Fastify's serialization pipeline (fast-json-stringify if schema defined, otherwise `JSON.stringify`) |
| `string` | Sent as-is; `Content-Type` defaults to `text/plain` |
| `Buffer` | Sent as binary; `Content-Type` defaults to `application/octet-stream` |
| `stream` (Node.js Readable) | Piped to the response |
| `null` | Sends an empty body with status `200` |
| `Error` | Triggers Fastify's error handling pipeline |

**Key Points:**

- When using `async` handlers, returning a value from the handler is equivalent to calling `reply.send()` with that value. Both approaches are valid.
- Calling `reply.send()` more than once in the same request lifecycle will throw or be ignored depending on the Fastify version. Behavior is not guaranteed to be silent. [Inference]

---

#### `reply.type(contentType)`

Sets the `Content-Type` header. Chainable.

js

```
reply.type('application/xml').send('<result>ok</result>');
```

**Key Points:**

- Fastify infers `Content-Type` automatically based on payload type when `reply.type()` is not called.
- Explicitly setting it overrides the inferred value.

---

#### `reply.serializer(fn)`

Overrides the default serialization function for this specific response. The function receives the payload and must return a string.

js

```
fastify.get('/custom-serial', async (request, reply) => {
  reply.serializer((payload) => JSON.stringify(payload, null, 2));
  return { formatted: true };
});
```

**Key Points:**

- This bypasses `fast-json-stringify` and any route-level response schema for this response only.
- Useful for one-off serialization needs, debugging, or non-JSON formats.

---

#### `reply.sent`

A boolean property indicating whether the response has already been sent.

js

```
fastify.get('/check', async (request, reply) => {
  reply.send('first');
  if (reply.sent) {
    // safe — won't attempt to send again
  }
});
```

**Key Points:**

- Once `reply.sent` is `true`, any further calls to `reply.send()` should be avoided.
- Useful in hooks that may run after a response has already been dispatched.

---

#### `reply.hijack()`

Signals to Fastify that the response will be managed entirely by the caller. Fastify will stop processing the request through its normal pipeline after this call.

js

```
fastify.get('/hijack', async (request, reply) => {
  reply.hijack();
  reply.raw.write('chunked data');
  reply.raw.end();
});
```

**Key Points:**

- After `reply.hijack()`, no Fastify `onSend` or `onResponse` hooks will run. [Inference: based on documented behavior; verify against version in use.]
- Used for WebSocket upgrades, server-sent events, or other long-lived connections managed outside Fastify's response model.

---

#### Redirect

##### `reply.redirect(url [, statusCode])`

Sends an HTTP redirect response.

js

```
reply.redirect('/new-location');
reply.redirect(301, '/permanent-location');
// or in newer Fastify versions:
reply.redirect('/permanent-location', 301);
```

**Key Points:**

- The argument order for `statusCode` has changed between Fastify versions. Verify against the version in use.
- Default redirect status code is `302` unless specified.

---

#### `reply.callNotFound()`

Invokes Fastify's not-found handler programmatically from within a route handler.

js

```
fastify.get('/resource/:id', async (request, reply) => {
  const item = await db.find(request.params.id);
  if (!item) return reply.callNotFound();
  return item;
});
```

---

#### Trailer Headers

Fastify supports HTTP trailers — headers sent after the response body — for streaming responses.

js

```
reply.trailer('Server-Timing', () => 'total;dur=123');
```

**Key Points:**

- Trailers require the `Transfer-Encoding: chunked` mechanism, which is automatically used for streamed responses.
- Not all HTTP clients and proxies support trailers. [Unverified for specific proxy behavior]

---

#### Reply Lifecycle Position

Handler returns /reply.send calledonSend hookSerializationWrite to reply.rawonResponse hook

**Key Points:**

- `onSend` hooks can modify the payload before it is written.
- `onResponse` hooks run after the response is fully delivered and cannot modify the response.
- Serialization occurs between `onSend` and the actual write to the socket.

---

#### TypeScript: Augmenting the Reply Type

ts

```
declare module 'fastify' {
  interface FastifyReply {
    sendError(message: string, code: number): void;
  }
}
```

As with `FastifyRequest`, module augmentation is a compile-time declaration only. It does not register any runtime behavior.

---

#### Summary of Key Properties and Methods

| Member | Type | Purpose |
| --- | --- | --- |
| `reply.raw` | Property | Underlying `http.ServerResponse` |
| `reply.server` | Property | Fastify instance reference |
| `reply.request` | Property | Associated request object |
| `reply.statusCode` | Property (r/w) | Current HTTP status code |
| `reply.sent` | Property (r) | Whether response has been sent |
| `reply.code(n)` | Method | Set status code, chainable |
| `reply.header(k, v)` | Method | Set single header, chainable |
| `reply.headers(obj)` | Method | Set multiple headers |
| `reply.getHeader(k)` | Method | Read a set header |
| `reply.getHeaders()` | Method | Read all set headers |
| `reply.removeHeader(k)` | Method | Remove a header |
| `reply.hasHeader(k)` | Method | Check header existence |
| `reply.type(ct)` | Method | Set Content-Type, chainable |
| `reply.send(payload)` | Method | Send the response |
| `reply.serializer(fn)` | Method | Override serializer |
| `reply.redirect(url)` | Method | Send redirect |
| `reply.hijack()` | Method | Take manual control |
| `reply.callNotFound()` | Method | Trigger 404 handler |
| `reply.trailer(k, fn)` | Method | Attach HTTP trailer |

---
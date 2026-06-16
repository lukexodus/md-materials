### Reply Object — Setting and Managing Headers

Headers are key-value metadata sent alongside HTTP responses. Fastify provides methods on the `reply` object to set, append, check, and remove response headers before the response is sent to the client.

---

#### Setting a Single Header

Use `reply.header(name, value)` to set a response header.

js

```
fastify.get('/example', async (request, reply) => {
  reply.header('Content-Type', 'application/json');
  reply.header('X-Custom-Header', 'my-value');
  return { message: 'hello' };
});
```

- Header names are case-insensitive in HTTP/1.1, but Fastify normalizes them to lowercase internally.
- Calling `reply.header()` on the same name more than once replaces the previous value, except for headers that support multiple values (see below).

---

#### Setting Multiple Headers at Once

Use `reply.headers(object)` to set several headers in a single call.

js

```
fastify.get('/multi', async (request, reply) => {
  reply.headers({
    'Content-Type': 'text/plain',
    'Cache-Control': 'no-store',
    'X-Request-Id': request.id,
  });
  return reply.send('ok');
});
```

This is equivalent to calling `reply.header()` for each key individually.

---

#### Reading a Header Value

Use `reply.getHeader(name)` to retrieve a header that has already been set on the reply.

js

```
fastify.get('/check', async (request, reply) => {
  reply.header('X-Powered-By', 'Fastify');
  const value = reply.getHeader('X-Powered-By');
  // value === 'Fastify'
  return { value };
});
```

This only reads headers set on the **reply object**. It does not read headers from the incoming request.

---

#### Reading All Headers

Use `reply.getHeaders()` to retrieve a shallow copy of all headers currently set on the reply object.

js

```
fastify.get('/all-headers', async (request, reply) => {
  reply.header('X-Foo', 'bar');
  reply.header('X-Baz', 'qux');

  const headers = reply.getHeaders();
  console.log(headers);
  // { 'x-foo': 'bar', 'x-baz': 'qux' }

  return headers;
});
```

---

#### Removing a Header

Use `reply.removeHeader(name)` to delete a previously set header before the response is sent.

js

```
fastify.get('/remove', async (request, reply) => {
  reply.header('X-Internal', 'secret');
  reply.removeHeader('X-Internal');
  return { done: true };
});
```

> [Inference] This is useful in hooks or plugins that set default headers, where specific routes need to opt out. Actual behavior depends on execution order and may vary.

---

#### Checking if a Header Exists

Use `reply.hasHeader(name)` to check whether a specific header has been set.

js

```
fastify.get('/has', async (request, reply) => {
  reply.header('X-Trace-Id', 'abc123');

  if (reply.hasHeader('X-Trace-Id')) {
    // proceed with trace logic
  }

  return reply.send('traced');
});
```

Returns `true` if the header exists, `false` otherwise.

---

#### Headers with Multiple Values

Some HTTP headers accept multiple values. You can pass an array as the value.

js

```
fastify.get('/multi-value', async (request, reply) => {
  reply.header('Set-Cookie', ['sessionId=abc; Path=/', 'theme=dark; Path=/']);
  return { ok: true };
});
```

> [Inference] When an array is passed, Fastify serializes multiple header values appropriately for the HTTP protocol. Behavior for specific headers may vary depending on the Node.js `http` module version in use.

---

#### The `Content-Type` Header

Fastify sets `Content-Type` automatically based on what `reply.send()` receives:

| Sent value | Auto `Content-Type` |
| --- | --- |
| Plain string | `text/plain; charset=utf-8` |
| Object or Array | `application/json; charset=utf-8` |
| Buffer | `application/octet-stream` |
| Stream | `application/octet-stream` |

You can override this by explicitly calling `reply.header('Content-Type', '...')` before sending.

js

```
fastify.get('/html', async (request, reply) => {
  reply.header('Content-Type', 'text/html; charset=utf-8');
  return reply.send('<h1>Hello</h1>');
});
```

> [Inference] Explicitly setting `Content-Type` before `reply.send()` takes precedence over Fastify's automatic detection. This behavior is expected based on documented method ordering but may vary in edge cases.

---

#### Setting Headers in Hooks

Headers are commonly set in `onRequest` or `onSend` hooks to apply them globally across routes.

js

```
fastify.addHook('onSend', async (request, reply, payload) => {
  reply.header('X-Response-Time', Date.now());
  return payload;
});
```

The `onSend` hook runs after the route handler and before the response is written to the socket, making it a suitable place to add or modify headers at a late stage.

> [Inference] Modifying headers in `onSend` should work in most cases, but headers modified after serialization has begun may not apply. Behavior may vary.

---

#### Immutability After Send

Once `reply.send()` has been called and the response has been flushed, headers can no longer be modified.

js

```
fastify.get('/late', async (request, reply) => {
  await reply.send('done');
  reply.header('X-Too-Late', 'yes'); // [Unverified] — may silently fail or throw
});
```

> [Unverified] Attempting to set headers after the response has been sent may produce an error or be silently ignored depending on the Node.js version and Fastify internals. Behavior is not guaranteed.

---

#### Common Practical Patterns

**CORS headers (manual):**

js

```
fastify.addHook('onSend', async (request, reply, payload) => {
  reply.header('Access-Control-Allow-Origin', '*');
  reply.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  return payload;
});
```

> Note: For production CORS handling, consider the `@fastify/cors` plugin.

**Cache control:**

js

```
fastify.get('/static-data', async (request, reply) => {
  reply.header('Cache-Control', 'public, max-age=3600');
  return { data: 'cached content' };
});
```

**Security headers:**

js

```
fastify.addHook('onSend', async (request, reply, payload) => {
  reply.headers({
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  });
  return payload;
});
```

> Note: For comprehensive security headers, consider the `@fastify/helmet` plugin.

---

#### Summary of Reply Header Methods

| Method | Purpose |
| --- | --- |
| `reply.header(name, value)` | Set a single header |
| `reply.headers(object)` | Set multiple headers at once |
| `reply.getHeader(name)` | Read a single header value |
| `reply.getHeaders()` | Read all currently set headers |
| `reply.hasHeader(name)` | Check if a header is set |
| `reply.removeHeader(name)` | Remove a header |
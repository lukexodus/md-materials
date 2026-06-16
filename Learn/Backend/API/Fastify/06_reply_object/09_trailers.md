### Reply Object — Trailers

HTTP trailers are headers sent *after* the response body, as part of the final chunk in a chunked transfer-encoded response. Fastify provides a dedicated API for declaring and sending trailers on the `reply` object.

---

#### What Trailers Are

In standard HTTP responses, headers precede the body. Trailers are a special class of headers that follow the body. They are only possible when:

- The response uses **chunked transfer encoding** (HTTP/1.1)
- The `Trailer` header is declared before the body is sent
- The client and server both support trailers

A common use case is sending a checksum or hash of the response body after the body has been fully written — information that cannot be known until the body is complete.

> [Inference] HTTP/2 has its own trailer mechanism. Fastify's trailer API targets HTTP/1.1 chunked responses. Behavior under HTTP/2 may differ and should be verified against your Fastify version and Node.js HTTP/2 support.

---

#### Declaring a Trailer with `reply.trailer()`

Use `reply.trailer(key, fn)` to declare a trailer. The second argument is a function that returns the trailer value. Fastify calls this function after the body has been sent.

js

```
fastify.get('/with-trailer', async (request, reply) => {
  reply.trailer('X-Response-Hash', (reply, payload) => {
    return computeHash(payload); // called after body is complete
  });

  return reply.send({ data: 'some content' });
});
```

**Parameters of the trailer function:**

| Parameter | Description |
| --- | --- |
| `reply` | The Fastify reply object |
| `payload` | The serialized response payload |

> [Inference] The trailer function receives the final serialized payload, making it suitable for computing checksums or content digests. Actual payload format passed to the function may vary depending on serialization and Fastify version.

---

#### Async Trailer Functions

The trailer callback can be asynchronous.

js

```
import { createHash } from 'crypto';

fastify.get('/checksum', async (request, reply) => {
  reply.trailer('X-Content-MD5', async (reply, payload) => {
    const hash = createHash('md5').update(payload).digest('hex');
    return hash;
  });

  return reply.send({ result: 'ok' });
});
```

> [Inference] Using an async function here allows for operations such as database lookups or external service calls to determine the trailer value. Actual timing and payload availability depend on Fastify internals and may vary.

---

#### Checking if a Trailer Is Set

Use `reply.hasTrailer(key)` to check whether a trailer has been declared.

js

```
fastify.get('/check-trailer', async (request, reply) => {
  reply.trailer('X-Checksum', () => 'abc123');

  console.log(reply.hasTrailer('X-Checksum')); // true
  console.log(reply.hasTrailer('X-Other'));     // false

  return reply.send('ok');
});
```

---

#### Removing a Trailer

Use `reply.removeTrailer(key)` to remove a previously declared trailer before the response is sent.

js

```
fastify.get('/conditional-trailer', async (request, reply) => {
  reply.trailer('X-Debug-Hash', () => 'debug-value');

  if (process.env.NODE_ENV === 'production') {
    reply.removeTrailer('X-Debug-Hash');
  }

  return reply.send({ ok: true });
});
```

---

#### The `Trailer` Header

When trailers are declared, Fastify adds a `Trailer` header to the response listing the trailer field names. This informs the client which trailers to expect after the body.

> [Inference] Fastify is expected to set the `Trailer` header automatically when `reply.trailer()` is used. Whether this is handled entirely by Fastify or requires manual declaration depends on the version in use. Verify against your installed version.

A response with trailers declared might look like:

```
HTTP/1.1 200 OK
Transfer-Encoding: chunked
Trailer: X-Content-MD5
Content-Type: application/json

[chunked body]

X-Content-MD5: d41d8cd98f00b204e9800998ecf8427e
```

---

#### Trailers and Transfer Encoding

Trailers require chunked transfer encoding. Fastify handles this automatically when trailers are declared, since the response body size is not known ahead of time.

> [Inference] If a `Content-Length` header is set explicitly, chunked encoding may not be used, potentially preventing trailers from being sent. Avoid setting `Content-Length` manually when using trailers. Behavior may vary.

---

#### Practical Use Cases

**Content integrity verification:**

js

```
import { createHash } from 'crypto';

fastify.get('/integrity', async (request, reply) => {
  reply.trailer('X-SHA256', async (reply, payload) => {
    return createHash('sha256').update(payload).digest('hex');
  });

  return reply.send({ records: await db.getAll() });
});
```

**Timing metadata:**

js

```
fastify.get('/timed', async (request, reply) => {
  const start = Date.now();

  reply.trailer('Server-Timing', () => {
    return `total;dur=${Date.now() - start}`;
  });

  return reply.send(await expensiveOperation());
});
```

> [Inference] The `Server-Timing` trailer is recognized by some browser developer tools when present in responses. Support varies by client.

---

#### Limitations and Constraints

- Trailers are only supported in HTTP/1.1 with chunked transfer encoding and in HTTP/2
- Not all HTTP clients support or process trailers; some may silently ignore them
- Trailers cannot be used to send headers that affect the response semantics already established (e.g., `Content-Type`, `Content-Length`, `Transfer-Encoding`)
- The trailer value function is called after serialization — the trailer value cannot modify the body

> [Inference] The list of headers forbidden in trailers is defined by the HTTP specification (RFC 7230). Fastify does not necessarily validate that declared trailer names are legal trailer fields. Behavior is not guaranteed.

---

#### Summary of Trailer Methods

| Method | Purpose |
| --- | --- |
| `reply.trailer(key, fn)` | Declare a trailer with a sync or async value function |
| `reply.hasTrailer(key)` | Check if a trailer has been declared |
| `reply.removeTrailer(key)` | Remove a previously declared trailer |

---

#### Summary

- Trailers are HTTP headers sent after the response body in chunked responses
- Declare them with `reply.trailer(key, fn)` before calling `reply.send()`
- The callback receives the finalized `reply` and `payload`, making it suitable for checksums and digests
- Use `reply.hasTrailer()` and `reply.removeTrailer()` to inspect and manage declared trailers
- Avoid setting `Content-Length` manually when using trailers
- Not all clients support trailers; design systems that do not depend on clients processing them
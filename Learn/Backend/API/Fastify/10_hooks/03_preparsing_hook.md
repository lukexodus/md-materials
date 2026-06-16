## Fastify Hooks — preParsing Hook

The `preParsing` hook fires after all `onRequest` hooks have completed and before Fastify parses the request body. It provides access to the raw payload as a stream, allowing interception, transformation, or replacement of the incoming data before any deserialization occurs.

---

### Position in the Lifecycle

```
Incoming Request
      │
      ▼
 onRequest
      │
      ▼
 preParsing       ← fires here (raw stream, body not yet parsed)
      │
      ▼
 preValidation
      │
      ▼
 preHandler
      │
      ▼
 Route Handler
      │
      ▼
 onSend
      │
      ▼
 onResponse
```

At the `preParsing` stage:

- `request.body` is still `null`
- The raw payload is available as a Node.js `Readable` stream
- The stream can be replaced by returning a new stream from the hook
- Headers, method, URL, and request ID are all available

---

### Hook Signature

The `preParsing` hook receives a third argument — `payload` — which is the raw incoming stream.

```js
fastify.addHook('preParsing', async (request, reply, payload) => {
  // return a new stream to replace the payload, or return nothing to pass through
  return payload
})
```

Callback style:

```js
fastify.addHook('preParsing', (request, reply, payload, done) => {
  done(null, payload)
})
```

**Key Points:**
- Unlike most other hooks, `preParsing` passes a `payload` argument as the third parameter.
- In the callback style, `done` receives two arguments: an optional error and the (optionally replaced) payload stream.
- If you do not return or pass a payload, Fastify uses the original stream. [Inference — consistent with Fastify's documented behavior for this hook; verify against your version.]

---

### What Is Available at This Stage

| Property | Available | Notes |
|---|---|---|
| `request.headers` | ✅ | Full request headers |
| `request.method` | ✅ | HTTP method string |
| `request.url` | ✅ | Raw URL string |
| `request.query` | ✅ | Parsed query string |
| `request.params` | ✅ | Route parameters |
| `request.body` | ❌ | Still `null` — not yet parsed |
| `request.id` | ✅ | Unique request ID |
| `request.log` | ✅ | Pino logger instance |
| `payload` (3rd arg) | ✅ | Raw `Readable` stream of the request body |

---

### Passing Through Without Modification

To observe the request without altering the payload, return the original stream unchanged.

```js
fastify.addHook('preParsing', async (request, reply, payload) => {
  request.log.info('preParsing hook reached')
  return payload
})
```

---

### Common Use Cases

#### Payload Decompression (Custom)

Fastify has built-in support for content encoding via `@fastify/compress`, but `preParsing` allows implementing custom decompression logic when needed.

```js
const zlib = require('node:zlib')
const { pipeline } = require('node:stream')
const { promisify } = require('node:util')

fastify.addHook('preParsing', async (request, reply, payload) => {
  const encoding = request.headers['content-encoding']

  if (encoding === 'gzip') {
    const gunzip = zlib.createGunzip()
    payload.pipe(gunzip)
    return gunzip
  }

  return payload
})
```

**Key Points:**
- When replacing the payload stream, the returned stream must be a valid Node.js `Readable`. Fastify will use it in place of the original for the parsing phase.
- Error handling within piped streams requires careful attention. Unhandled stream errors may not propagate to Fastify's error handler automatically. [Inference — standard Node.js stream behavior applies; verify in your environment.]

#### Payload Decryption

```js
const crypto = require('node:crypto')

fastify.addHook('preParsing', async (request, reply, payload) => {
  const isEncrypted = request.headers['x-encrypted'] === 'true'

  if (!isEncrypted) return payload

  const decipher = crypto.createDecipheriv(
    'aes-256-cbc',
    Buffer.from(process.env.ENCRYPTION_KEY, 'hex'),
    Buffer.from(request.headers['x-iv'], 'hex')
  )

  payload.pipe(decipher)
  return decipher
})
```

#### Payload Size Limiting (Manual)

Although Fastify provides a `bodyLimit` option at the server and route level, `preParsing` can be used to enforce custom limits before parsing begins.

```js
fastify.addHook('preParsing', async (request, reply, payload) => {
  let size = 0
  const limit = 1024 * 100 // 100 KB

  for await (const chunk of payload) {
    size += chunk.length
    if (size > limit) {
      reply.code(413).send({ error: 'Payload Too Large' })
      return
    }
  }
})
```

**Key Points:**
- Consuming the stream inside the hook means the original stream is exhausted. If you consume it and do not return a new stream containing the data, Fastify will have nothing to parse. [Inference — based on Node.js stream consumption semantics; test thoroughly.]
- For most payload size enforcement needs, the built-in `bodyLimit` option is preferable and more reliable.

#### Logging Payload Metadata

```js
fastify.addHook('preParsing', async (request, reply, payload) => {
  request.log.info({
    contentType: request.headers['content-type'],
    contentLength: request.headers['content-length'],
  }, 'payload metadata')

  return payload
})
```

---

### Replacing the Payload Stream

The key capability of `preParsing` is stream replacement. The returned value becomes the stream that Fastify's body parser will read from.

```js
const { Readable } = require('node:stream')

fastify.addHook('preParsing', async (request, reply, payload) => {
  // Replace the incoming stream with a static JSON body
  // [Speculation] — this pattern may be useful for testing or mocking; validate in production use
  const replacement = Readable.from(
    [Buffer.from(JSON.stringify({ injected: true }))]
  )
  return replacement
})
```

**Key Points:**
- The replacement stream should emit data in a format that the registered body parser for the route's `Content-Type` can handle.
- Mismatches between stream content and `Content-Type` may cause parsing errors downstream. [Inference — behavior depends on the body parser implementation.]

---

### Error Handling

Throwing in an async `preParsing` hook or calling `done(error)` aborts the lifecycle and invokes Fastify's error handler.

```js
fastify.addHook('preParsing', async (request, reply, payload) => {
  const contentType = request.headers['content-type']

  if (!contentType || !contentType.startsWith('application/json')) {
    throw fastify.httpErrors.unsupportedMediaType('Only JSON payloads accepted')
  }

  return payload
})
```

---

### Multiple preParsing Hooks

Multiple `preParsing` hooks execute in registration order. Each hook receives the payload returned by the previous hook.

```js
fastify.addHook('preParsing', async (request, reply, payload) => {
  request.log.info('preParsing hook 1')
  return payload
})

fastify.addHook('preParsing', async (request, reply, payload) => {
  request.log.info('preParsing hook 2')
  return payload
})
```

**Key Points:**
- Each hook in the chain receives the stream output of the previous hook. This allows composing transformations across multiple hooks. [Inference — consistent with Fastify's documented chaining behavior for `preParsing`; verify for your version.]
- If any hook throws or calls `done(error)`, subsequent hooks do not execute.

---

### Scoped Registration

Like all Fastify hooks, `preParsing` respects plugin encapsulation boundaries.

```js
fastify.register(async function (instance) {
  instance.addHook('preParsing', async (request, reply, payload) => {
    // only applies to routes in this scope
    return payload
  })

  instance.post('/upload', async (request, reply) => {
    return { received: true }
  })
})
```

---

### Diagram — preParsing Stream Flow

```mermaid
flowchart LR
    A[Raw Request Stream] --> B[preParsing Hook 1]
    B -->|returns stream| C[preParsing Hook 2]
    C -->|returns stream| D[Body Parser]
    D --> E[request.body populated]
```

---

### Caveats and Behavioral Notes

- `preParsing` only fires for requests that have a body. [Inference — for methods like `GET` or `HEAD` where no body is expected, hook behavior may differ; verify with your Fastify version and route configuration.]
- Manipulating streams incorrectly (not handling backpressure, not forwarding errors) can cause hanging requests or silent failures. [Inference — standard Node.js stream caveats apply.]
- This hook is not commonly needed in typical application code. Most applications do not require raw stream interception. Use it only when standard body parsing is insufficient.
- Using `@fastify/compress` or similar plugins is preferable to manual compression handling in `preParsing` for production use. [Inference — plugin solutions are more thoroughly tested for edge cases.]

---

**Conclusion:**
The `preParsing` hook provides low-level access to the raw request payload stream before any deserialization. Its primary use cases are payload transformation — decompression, decryption, or stream wrapping — that must occur before the body parser runs. For most applications, this hook is not required. When it is used, correct stream handling and careful attention to return values are essential, as errors here directly affect whether `request.body` will be populated correctly downstream.

**Next Steps:**
After `preParsing`, the request body is parsed according to the registered content type parser. The next hook in the lifecycle is `preValidation`, which fires after parsing and allows inspection or modification of `request.body` before schema validation occurs.
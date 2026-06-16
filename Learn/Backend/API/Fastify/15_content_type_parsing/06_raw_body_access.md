## Raw Body Access in Fastify

Fastify parses incoming request bodies automatically based on the registered content type parsers. However, there are scenarios where you need access to the raw, unparsed body — for example, when verifying cryptographic signatures (such as webhook payloads from Stripe or GitHub), computing checksums, or logging the exact bytes received.

This article covers how raw body access works in Fastify, how to configure it, and how to use it safely.

---

### Why Raw Body Access Is Needed

When Fastify parses a request body, it consumes the underlying stream and produces a JavaScript object. The original buffer or string is discarded unless explicitly preserved. If you attempt to re-read the stream after parsing, [Inference] it will be empty, because Node.js streams are single-read by default — behavior may vary depending on framework version and plugin configuration.

Common use cases for raw body access:

- **Webhook signature verification** — providers such as Stripe sign the raw payload; verifying the signature requires the exact bytes sent, not a re-serialized object
- **Checksum or hash validation** — computing a hash over the body requires the original bytes
- **Audit logging** — storing the verbatim request for debugging or compliance
- **Proxying or forwarding** — passing the original payload downstream without transformation

---

### How Fastify Handles Body Parsing

Fastify uses content type parsers to determine how to parse the body. The parsed result is placed on `request.body`. The raw stream is not exposed by default.

To access raw bytes, you have two main approaches:

1. Use the `rawBody` option via the `@fastify/raw-body` plugin
2. Implement a custom content type parser that captures the buffer manually

---

### Approach 1 — Using `@fastify/raw-body`

The `@fastify/raw-body` plugin is the recommended approach for most use cases. It attaches the raw body to `request.rawBody` after parsing, without replacing the normal `request.body`.

#### Installation

```bash
npm install @fastify/raw-body
```

#### Registration

```js
import Fastify from 'fastify'
import rawBody from '@fastify/raw-body'

const fastify = Fastify()

await fastify.register(rawBody, {
  field: 'rawBody',      // default field name on request
  global: false,         // if true, applies to all routes
  encoding: 'utf8',      // encoding for the raw body string; use false for Buffer
  runFirst: true,        // parse raw body before other parsers
  routes: []             // specify route paths if global is false
})
```

**Key Points:**
- `field` — the property name added to the `request` object; defaults to `rawBody`
- `global: false` — scopes raw body collection to routes that opt in, which avoids overhead on routes that do not need it
- `encoding: false` — returns a `Buffer` instead of a string; use this when computing binary hashes
- `runFirst: true` — [Inference] ensures the raw body is captured before body parsing runs; behavior may vary depending on plugin registration order

#### Route-Level Usage

When `global` is `false`, opt individual routes in using the `config` option:

```js
fastify.post('/webhook', {
  config: {
    rawBody: true
  },
  handler: async (request, reply) => {
    const raw = request.rawBody     // string (or Buffer if encoding: false)
    const parsed = request.body     // parsed JSON object

    console.log('Raw payload:', raw)
    console.log('Parsed body:', parsed)

    return { received: true }
  }
})
```

#### Global Usage

When `global: true`, all routes receive `request.rawBody` automatically. Use this only if most routes require it, since buffering every request body adds memory overhead.

```js
await fastify.register(rawBody, {
  global: true,
  encoding: 'utf8'
})

fastify.post('/any-route', async (request, reply) => {
  console.log(request.rawBody)
  return {}
})
```

---

### Approach 2 — Custom Content Type Parser with Manual Buffering

If you need full control — or if you want to avoid an additional plugin dependency — you can register a custom content type parser that collects the stream into a buffer before returning the parsed result.

```js
import Fastify from 'fastify'

const fastify = Fastify()

fastify.addContentTypeParser(
  'application/json',
  { parseAs: 'buffer' },
  (req, body, done) => {
    // body is a Buffer here because parseAs: 'buffer'
    req.rawBody = body

    try {
      const parsed = JSON.parse(body.toString('utf8'))
      done(null, parsed)
    } catch (err) {
      err.statusCode = 400
      done(err, undefined)
    }
  }
)

fastify.post('/verify', async (request, reply) => {
  const raw = request.rawBody       // Buffer
  const parsed = request.body       // JavaScript object

  return { length: raw.length }
})

fastify.listen({ port: 3000 })
```

**Key Points:**
- `parseAs: 'buffer'` — instructs Fastify to collect the stream into a `Buffer` and pass it to your parser function; `'string'` is also a valid option
- You are responsible for both attaching `rawBody` and calling `done` with the parsed result
- Errors thrown in the parser should include a `statusCode` so Fastify returns an appropriate HTTP error

---

### Approach 3 — Accessing the Raw Stream Directly (Advanced)

In rare cases, you may need to process the stream before it is consumed — for example, to pipe it or to compute a rolling hash as bytes arrive. This requires working with the Node.js readable stream before any parser runs.

[Inference] This is achievable using an `onRequest` or `preParsing` hook. The `preParsing` hook receives the raw stream before content type parsers are invoked. Behavior may vary by Fastify version; verify against current documentation.

```js
import { createHash } from 'crypto'

fastify.addHook('preParsing', async (request, reply, payload) => {
  const chunks = []

  for await (const chunk of payload) {
    chunks.push(chunk)
  }

  const raw = Buffer.concat(chunks)
  request.rawBody = raw

  // Return a new readable stream from the buffer so Fastify can still parse it
  const { Readable } = await import('stream')
  const newStream = Readable.from(raw)
  newStream.headers = payload.headers  // preserve headers if present
  return newStream
})
```

**Key Points:**
- You **must** return a new readable stream from `preParsing` if you consume the original; otherwise Fastify will attempt to parse an empty stream
- [Inference] Attaching `headers` from the original payload to the new stream may be necessary for content type detection — this is an inference based on stream behavior and should be verified against Fastify source or documentation
- This approach is lower-level and more error-prone than using `@fastify/raw-body`

---

### Webhook Signature Verification Example

A practical end-to-end example verifying a Stripe-style HMAC signature using the raw body:

```js
import Fastify from 'fastify'
import rawBody from '@fastify/raw-body'
import { createHmac, timingSafeEqual } from 'crypto'

const fastify = Fastify()
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET

await fastify.register(rawBody, {
  global: false,
  encoding: false    // Buffer, not string
})

fastify.post('/stripe/webhook', {
  config: { rawBody: true },
  handler: async (request, reply) => {
    const signature = request.headers['x-stripe-signature']

    if (!signature) {
      return reply.code(400).send({ error: 'Missing signature header' })
    }

    const expectedSig = createHmac('sha256', WEBHOOK_SECRET)
      .update(request.rawBody)
      .digest('hex')

    const expectedBuf = Buffer.from(expectedSig, 'utf8')
    const receivedBuf = Buffer.from(signature, 'utf8')

    if (
      expectedBuf.length !== receivedBuf.length ||
      !timingSafeEqual(expectedBuf, receivedBuf)
    ) {
      return reply.code(401).send({ error: 'Invalid signature' })
    }

    const event = request.body
    console.log('Verified event:', event.type)

    return { received: true }
  }
})
```

**Key Points:**
- `timingSafeEqual` is used to compare signatures to reduce timing attack surface — [Inference] this is consistent with standard HMAC verification practice, though the exact vulnerability profile depends on the deployment environment
- `encoding: false` is critical here; a string body may alter whitespace or encoding and cause hash mismatches
- Real Stripe signature verification involves timestamp extraction from the header; the above is a simplified illustration

---

### Comparison of Approaches

| Approach | Raw as | Control Level | Effort | Best For |
|---|---|---|---|---|
| `@fastify/raw-body` plugin | `string` or `Buffer` | Low | Low | Most use cases |
| Custom content type parser | `string` or `Buffer` | Medium | Medium | Custom parsing logic |
| `preParsing` hook | `Buffer` (manual) | High | High | Stream-level access |

---

### Common Pitfalls

**Registering `rawBody` after route definitions**
Plugin registration order matters in Fastify. [Inference] If `@fastify/raw-body` is registered after a route is defined, that route may not have access to `request.rawBody` — behavior may vary.

**Using `encoding: 'utf8'` for binary hash computation**
String encoding may normalize or alter bytes. Always use `encoding: false` when computing cryptographic hashes over binary data.

**Forgetting to return a stream from `preParsing`**
Consuming the stream in `preParsing` without returning a replacement will [Inference] cause Fastify to attempt parsing an empty body, likely resulting in a parse error or empty `request.body`.

**Double-parsing overhead**
When using `@fastify/raw-body` alongside Fastify's built-in parser, the body is effectively read twice — once into a buffer for `rawBody`, and once parsed. [Inference] For very large payloads this may have memory implications; measure under realistic load if this is a concern.

---

**Related Topics:**
- Content type parsers — registering and overriding parsers per MIME type
- Body size limits — configuring `bodyLimit` for raw and parsed bodies
- `preParsing` and `preValidation` hooks — lifecycle hooks around parsing
- Schema validation on parsed bodies — combining raw access with JSON Schema validation
- Multipart raw access — using `@fastify/multipart` with raw field buffers
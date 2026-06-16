### Raw Request Object

Fastify's `request` object is a wrapper around Node.js's native `http.IncomingMessage`. In most cases, Fastify's abstractions are sufficient — but there are scenarios where direct access to the underlying Node.js object is necessary. That object is exposed as `request.raw`.

---

#### What `request.raw` Is

js

```
fastify.get('/example', async (request, reply) => {
  const raw = request.raw
  // raw is an instance of http.IncomingMessage
})
```

`request.raw` is the unmodified Node.js `IncomingMessage` instance created by the HTTP server before Fastify processes it. It is a readable stream with additional properties attached by Node.js.

**Key Points:**

- `request.raw` is always present regardless of route, method, or plugin
- It is the same object passed to Node.js's native `http.createServer` callback as the first argument
- Fastify does not copy or clone it — `request.raw` is a direct reference

---

#### Properties on `request.raw`

These are Node.js `IncomingMessage` properties, not Fastify additions. Their availability and behavior are governed by Node.js, not Fastify.

##### `request.raw.method`

The HTTP method as an uppercase string.

js

```
request.raw.method // 'GET', 'POST', etc.
```

Equivalent to `request.method` on the Fastify wrapper.

##### `request.raw.url`

The raw URL string including path and query string, exactly as received by the server.

js

```
// Incoming: GET /search?q=hello
request.raw.url // '/search?q=hello'
```

Equivalent to `request.url` on the Fastify wrapper.

##### `request.raw.headers`

The parsed headers object, lowercased. This is the same reference Fastify exposes as `request.headers`.

js

```
request.raw.headers['authorization'] // 'Bearer abc123'
```

##### `request.raw.rawHeaders`

A flat array of header name-value pairs in their original form, preserving casing and insertion order. Duplicate headers appear as separate entries.

js

```
fastify.get('/raw-headers', async (request, reply) => {
  return { rawHeaders: request.raw.rawHeaders }
})
```

**Output (example):**

json

```
{
  "rawHeaders": [
    "Host", "localhost:3000",
    "Content-Type", "application/json",
    "X-Request-ID", "abc-123"
  ]
}
```

**Key Points:**

- Useful when header casing or ordering matters — for example, signature verification that is case-sensitive
- Duplicate header names appear as separate consecutive pairs
- Not available on `request.headers`, which deduplicates and lowercases

##### `request.raw.httpVersion` and `request.raw.httpVersionMajor`

The HTTP version string and its major component.

js

```
request.raw.httpVersion      // '1.1' or '2.0'
request.raw.httpVersionMajor // 1 or 2
```

> [Inference] When using Fastify with HTTP/2 (`fastify({ http2: true })`), the underlying request object is `http2.Http2ServerRequest` rather than `http.IncomingMessage`. The API surface is largely compatible but not identical — verify property availability when using HTTP/2.

##### `request.raw.socket`

The underlying `net.Socket` (or `tls.TLSSocket` for HTTPS) for the connection.

js

```
fastify.get('/socket-info', async (request, reply) => {
  const socket = request.raw.socket
  return {
    remoteAddress: socket.remoteAddress,
    remotePort:    socket.remotePort,
    localAddress:  socket.localAddress,
    localPort:     socket.localPort,
    encrypted:     !!socket.encrypted
  }
})
```

**Key Points:**

- `socket.encrypted` is `true` for TLS connections, `undefined` otherwise — use `!!socket.encrypted` for a reliable boolean
- Direct socket access is rarely needed in application code — prefer `request.ip` and `request.protocol` from Fastify's wrapper
- Manipulating the socket directly can interfere with Fastify's connection management

##### `request.raw.trailers`

HTTP trailers — headers sent after the body in chunked transfer encoding.

js

```
request.raw.trailers // {} in most cases
```

> [Unverified] HTTP trailers are rarely used in practice and may not be populated in all environments or Node.js versions. Treat as unreliable unless your specific use case requires them.

##### `request.raw.complete`

A boolean indicating whether the request body has been fully received and parsed.

js

```
request.raw.complete // true if body fully received, false otherwise
```

> [Inference] By the time a Fastify handler executes, `request.raw.complete` is typically `true` because Fastify consumes the body stream during parsing. Behavior may vary if you are reading the raw stream manually or if body parsing was skipped.

##### `request.raw.aborted` (deprecated) and `request.raw.destroyed`

`aborted` was a Node.js property indicating whether the request was aborted by the client. It was deprecated in Node.js v17 and removed in later versions.

`destroyed` is the stream-level property indicating whether the stream has been destroyed.

js

```
request.raw.destroyed // true if the stream has been destroyed
```

> [Unverified] The availability of `aborted` depends on your Node.js version. Use `request.raw.destroyed` or listen to the `close` event on the socket for connection termination detection in current Node.js versions. Verify against your runtime.

---

#### Reading the Raw Body Stream

Fastify consumes and parses the request body stream before the handler runs. If you bypass Fastify's body parser — for example, on a route with no content type parser — you can read the raw stream directly from `request.raw`.

js

```
fastify.addContentTypeParser(
  'application/octet-stream',
  (request, payload, done) => {
    const chunks = []

    payload.on('data', chunk => chunks.push(chunk))
    payload.on('end', () => done(null, Buffer.concat(chunks)))
    payload.on('error', done)
  }
)
```

Alternatively, using the `parseAs` option:

js

```
fastify.addContentTypeParser(
  'text/plain',
  { parseAs: 'buffer' },
  (request, body, done) => {
    done(null, body)
  }
)
```

> **Important:** Do not read `request.raw` as a stream directly in a handler for routes where Fastify has already parsed the body. The stream will already be consumed and will emit no further data. Reading an already-consumed stream will hang or produce empty results.

---

#### When to Use `request.raw`

| Use Case | Access Pattern |
| --- | --- |
| Original header casing or ordering | `request.raw.rawHeaders` |
| HTTP version detection | `request.raw.httpVersion` |
| Socket-level metadata | `request.raw.socket` |
| Custom stream consumption | Read `request.raw` as a stream (before Fastify parses) |
| Signature verification requiring raw headers | `request.raw.rawHeaders` |
| Checking connection encryption | `request.raw.socket.encrypted` |

For everything else — method, URL, headers, body — prefer Fastify's wrapper properties. They are safer, more consistent across HTTP versions, and integrate with Fastify's validation and lifecycle.

---

#### Comparing Fastify Wrapper vs `request.raw`

| Property | Fastify Wrapper | `request.raw` Equivalent |
| --- | --- | --- |
| HTTP method | `request.method` | `request.raw.method` |
| URL with query | `request.url` | `request.raw.url` |
| Headers (lowercased) | `request.headers` | `request.raw.headers` |
| Headers (original casing) | — | `request.raw.rawHeaders` |
| Client IP | `request.ip` | `request.raw.socket.remoteAddress` |
| Protocol | `request.protocol` | `!!request.raw.socket.encrypted ? 'https' : 'http'` |
| Parsed body | `request.body` | — (must parse stream manually) |
| Logger | `request.log` | — |

---

#### Cautions

**Do not replace `request.raw`.**
Reassigning `request.raw` to another object is not a supported pattern and may produce undefined behavior across Fastify's internal lifecycle.

**Do not read the stream after Fastify has consumed it.**
Once Fastify's body parser has run, the stream on `request.raw` is exhausted. Attempting to read it again in a handler will not yield the original body data.

**HTTP/2 compatibility.**
Properties on `request.raw` differ when using HTTP/2. The `http2.Http2ServerRequest` class does not expose `socket` directly in all configurations and omits some HTTP/1.1-specific properties.

---

#### Related Topics

- Custom content type parsers and raw stream consumption
- `request.headers` and header validation
- HTTP/2 support in Fastify
- `reply.raw` — the equivalent for the response side
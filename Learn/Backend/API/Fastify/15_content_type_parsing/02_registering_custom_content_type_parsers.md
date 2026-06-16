## Registering Custom Content Type Parsers

Fastify has built-in support for `application/json` and `text/plain` out of the box. For any other content type — such as `application/xml`, `application/msgpack`, or custom binary formats — you must register a parser manually using `fastify.addContentTypeParser()`.

---

### Why Custom Parsers Are Needed

When Fastify receives a request, it inspects the `Content-Type` header to determine how to parse the body. If no parser is registered for the incoming content type, Fastify rejects the request with a `415 Unsupported Media Type` error by default.

**Key Points:**
- Parsers are registered per content type string or regex pattern
- A parser receives the raw request stream or buffer and must produce a usable value
- Parsers are scoped: they can be registered globally or within a plugin scope

---

### API Signature

```js
fastify.addContentTypeParser(contentType, options, parserFn)
```

| Parameter | Type | Description |
|---|---|---|
| `contentType` | `string` \| `RegExp` \| `string[]` | The content type(s) to match |
| `options` | `object` | Optional. Controls body handling (see below) |
| `parserFn` | `function` | The parsing logic |

The parser function signature depends on whether you use streaming or buffered mode.

---

### Buffered Parsing (parseAs)

The most common approach. Fastify reads the entire body into memory first, then calls your parser.

```js
fastify.addContentTypeParser(
  'application/xml',
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      const parsed = myXmlParser(body)
      done(null, parsed)
    } catch (err) {
      done(err)
    }
  }
)
```

`parseAs` accepts:
- `'string'` — body delivered as a UTF-8 string
- `'buffer'` — body delivered as a `Buffer`

**Key Points:**
- `done(err, result)` follows the Node.js error-first callback convention
- Throwing inside the parser without catching will result in unhandled behavior; always wrap in try/catch
- [Inference] Using `parseAs: 'buffer'` is preferable for binary formats where string encoding could corrupt data; behavior may vary by use case

---

### Async Parser Functions

You may use an `async` function instead of the callback style:

```js
fastify.addContentTypeParser(
  'application/msgpack',
  { parseAs: 'buffer' },
  async function (req, body) {
    return msgpack.decode(body)
  }
)
```

**Key Points:**
- Throwing inside an async parser propagates the error to Fastify's error handler
- Do not mix `done()` callback with `async`; use one or the other

---

### Stream-Based Parsing

Omitting `parseAs` gives you access to the raw request stream. This is appropriate for large payloads or when you want to avoid buffering entirely.

```js
fastify.addContentTypeParser(
  'application/octet-stream',
  function (req, payload, done) {
    let data = []
    payload.on('data', chunk => data.push(chunk))
    payload.on('end', () => done(null, Buffer.concat(data)))
    payload.on('error', done)
  }
)
```

**Key Points:**
- `payload` here is the raw Node.js `IncomingMessage` stream
- You are responsible for consuming the stream completely; leaving it unconsumed may hang the request
- [Inference] Stream-based parsing may offer lower peak memory usage for large payloads compared to buffered mode, but this is workload-dependent and not guaranteed

---

### Matching Multiple Content Types

You can register a single parser for multiple content types:

```js
fastify.addContentTypeParser(
  ['application/xml', 'text/xml'],
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      done(null, myXmlParser(body))
    } catch (err) {
      done(err)
    }
  }
)
```

Or use a `RegExp` for pattern-based matching:

```js
fastify.addContentTypeParser(
  /^application\/.+\+json$/,
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      done(null, JSON.parse(body))
    } catch (err) {
      done(err)
    }
  }
)
```

**Key Points:**
- The regex above matches any `application/*+json` variant (e.g., `application/ld+json`, `application/vnd.api+json`)
- String matching is exact; regex matching applies the pattern against the full content type value

---

### Overriding Built-in Parsers

You can override the default `application/json` parser by passing `{ parseAs: 'string' }` along with your own logic, but you must first call `removeAllContentTypeParsers()` or use the `override` option:

```js
fastify.removeAllContentTypeParsers()

fastify.addContentTypeParser(
  'application/json',
  { parseAs: 'buffer' },
  function (req, body, done) {
    try {
      const json = JSON.parse(body)
      done(null, json)
    } catch (err) {
      done(err)
    }
  }
)
```

**Key Points:**
- `removeAllContentTypeParsers()` clears all registered parsers including built-ins
- Alternatively, `removeContentTypeParser('application/json')` removes only the specified one
- [Inference] Overriding the built-in JSON parser is rarely needed unless you require custom reviver logic, a different JSON library, or special error handling; behavior of the override is not guaranteed to be identical to the default

---

### Plugin Scoping

Parsers registered inside a plugin are scoped to that plugin and its children unless you register them on the root instance.

```js
fastify.register(async function (instance) {
  instance.addContentTypeParser(
    'application/xml',
    { parseAs: 'string' },
    async function (req, body) {
      return parseXml(body)
    }
  )

  instance.post('/xml-endpoint', async (request, reply) => {
    return { received: request.body }
  })
})
```

Routes outside this plugin scope will not use the `application/xml` parser registered inside it.

**Key Points:**
- To share a parser across all plugins, register it before any `fastify.register()` calls on the root instance
- [Inference] Scoping parsers to plugins follows the same encapsulation model as Fastify decorators and hooks; consult the encapsulation documentation for the full behavior

---

### Body Limit Interaction

The `bodyLimit` option (set globally or per-route) applies before the parser receives the body. If the incoming payload exceeds the limit, Fastify rejects it with a `413 Payload Too Large` error and the parser is never invoked.

```js
const fastify = Fastify({ bodyLimit: 1048576 }) // 1 MB global limit
```

Per-route override:

```js
fastify.post('/upload', {
  bodyLimit: 10485760 // 10 MB for this route only
}, async (request, reply) => {
  return { size: request.body.length }
})
```

**Key Points:**
- Custom parsers do not bypass `bodyLimit`
- The limit applies to the raw bytes received, before parsing

---

### hasContentTypeParser and hasReplyContentTypeParser

You can check whether a parser is already registered before adding one:

```js
if (!fastify.hasContentTypeParser('application/xml')) {
  fastify.addContentTypeParser(
    'application/xml',
    { parseAs: 'string' },
    async (req, body) => parseXml(body)
  )
}
```

This is useful in plugins that may be registered multiple times or alongside other plugins that register the same content type.

---

### Common Mistakes

| Mistake | Effect |
|---|---|
| Not handling stream errors | Request may hang or produce unhandled errors |
| Using `async` + calling `done()` | Undefined behavior; pick one style |
| Forgetting `parseAs` for binary data | Body may be corrupted by string encoding |
| Registering inside a scoped plugin expecting global availability | Parser is not available outside the plugin scope |
| Not wrapping synchronous parse logic in try/catch | Parse errors may surface as unhandled exceptions |

---

### Practical Example: YAML Body Parser

```js
import Fastify from 'fastify'
import yaml from 'js-yaml'

const fastify = Fastify()

fastify.addContentTypeParser(
  'application/yaml',
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      const parsed = yaml.load(body)
      done(null, parsed)
    } catch (err) {
      err.statusCode = 400
      done(err)
    }
  }
)

fastify.post('/config', async (request, reply) => {
  return { received: request.body }
})

await fastify.listen({ port: 3000 })
```

**Output** (when sending a YAML body with `Content-Type: application/yaml`):

```json
{
  "received": {
    "key": "value"
  }
}
```

**Key Points:**
- Setting `err.statusCode` on a caught error controls the HTTP response status sent to the client
- `js-yaml` is a third-party library; install it separately with `npm install js-yaml`

---

**Conclusion:**
Custom content type parsers give you precise control over how non-standard request bodies are handled. The key decisions are: whether to use buffered or stream mode, how to scope the parser, and how to handle errors consistently. Combining parsers with Fastify's `bodyLimit` and plugin encapsulation model allows you to build robust, format-specific ingestion logic without coupling it to route handlers.
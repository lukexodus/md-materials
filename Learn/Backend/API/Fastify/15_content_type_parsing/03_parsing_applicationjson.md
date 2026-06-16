## Parsing application/json

Fastify registers an `application/json` content type parser automatically at startup. Understanding how it works internally — and how to customize or replace it — is important when you need non-default JSON handling, custom error responses, or performance tuning.

---

### Default Behavior

Out of the box, Fastify parses any request with `Content-Type: application/json` using the native `JSON.parse()`. You do not need to register anything for basic JSON ingestion.

```js
fastify.post('/items', async (request, reply) => {
  console.log(request.body) // already parsed object
  return { received: request.body }
})
```

**Key Points:**
- The parsed result is available on `request.body`
- If `JSON.parse()` throws, Fastify responds with `400 Bad Request` and a structured error
- The default parser uses `parseAs: 'string'` internally, meaning the body is buffered as a string before parsing

---

### Content-Type Matching Behavior

Fastify's built-in JSON parser matches `application/json` exactly by default. It also matches variants that include parameters, such as:

```
Content-Type: application/json; charset=utf-8
```

**Key Points:**
- Fastify strips parameters from the content type before matching, so `application/json; charset=utf-8` resolves to the `application/json` parser
- [Inference] Other `*+json` subtypes such as `application/vnd.api+json` are not matched by the built-in parser unless you register an additional parser for them; verify against your Fastify version

---

### Inspecting the Default Parser

Fastify exposes `hasContentTypeParser()` to confirm the built-in parser is present:

```js
console.log(fastify.hasContentTypeParser('application/json')) // true
```

This is useful before conditionally overriding or removing it.

---

### Overriding the Default JSON Parser

To replace the built-in parser, first remove it, then register your own:

```js
import Fastify from 'fastify'

const fastify = Fastify()

fastify.removeContentTypeParser('application/json')

fastify.addContentTypeParser(
  'application/json',
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      const parsed = JSON.parse(body)
      done(null, parsed)
    } catch (err) {
      err.statusCode = 400
      done(err)
    }
  }
)
```

**Key Points:**
- If you do not call `removeContentTypeParser` first, Fastify will throw because a parser for `application/json` is already registered
- Setting `err.statusCode` on the caught error controls the HTTP status code returned to the client
- This pattern is the baseline for any custom JSON parser

---

### Using a Custom JSON Library

A common reason to override the default parser is to substitute a faster or more capable JSON library, such as `fast-json-parse` or `@ungap/structured-clone`-based alternatives. A frequent real-world choice is using Fastify's own `@fastify/fast-json-stringify` on the serialization side while swapping in a custom deserializer on the parsing side.

**Example: using `secure-json-parse` to guard against prototype pollution**

```js
import Fastify from 'fastify'
import secureJson from 'secure-json-parse'

const fastify = Fastify()

fastify.removeContentTypeParser('application/json')

fastify.addContentTypeParser(
  'application/json',
  { parseAs: 'buffer' },
  function (req, body, done) {
    try {
      const parsed = secureJson.parse(body)
      done(null, parsed)
    } catch (err) {
      err.statusCode = 400
      done(err)
    }
  }
)
```

**Key Points:**
- `parseAs: 'buffer'` is used here because `secure-json-parse` accepts a `Buffer` directly
- `secure-json-parse` is a third-party library; install with `npm install secure-json-parse`
- [Inference] Whether `secure-json-parse` meaningfully reduces prototype pollution risk depends on your application's object handling downstream; it is not a complete mitigation on its own, and behavior is not guaranteed

---

### Using an Async Parser

The async style is equivalent and often cleaner:

```js
fastify.removeContentTypeParser('application/json')

fastify.addContentTypeParser(
  'application/json',
  { parseAs: 'string' },
  async function (req, body) {
    return JSON.parse(body)
  }
)
```

**Key Points:**
- A thrown error inside an async parser is caught by Fastify and forwarded to the error handler
- Do not mix the `async` function style with the `done` callback

---

### Customizing the JSON Parser via Fastify Constructor

Fastify accepts `jsonShorthand`, `jsonBodyLimit`, and — most relevantly — a custom `jsonParser` function at the instance level:

```js
const fastify = Fastify({
  jsonShorthand: true // default: true
})
```

For a fully custom JSON parser at construction time, use the `rewriteUrl` and `genReqId` options in combination with a replaced content type parser. There is no `jsonParser` constructor option in current stable Fastify releases — replacement is done via `removeContentTypeParser` + `addContentTypeParser` as shown above.

**Key Points:**
- [Unverified] Some community resources reference a `jsonParser` constructor option; as of Fastify v4/v5, this is not present in the official API — verify against your installed version's changelog before relying on any such reference

---

### Handling JSON Parse Errors

When `JSON.parse()` fails, the error reaches Fastify's error handler. You can customize the response by using `setErrorHandler`:

```js
fastify.setErrorHandler(function (err, request, reply) {
  if (err.statusCode === 400) {
    reply.status(400).send({
      error: 'Bad Request',
      message: 'Invalid JSON payload',
      statusCode: 400
    })
    return
  }
  reply.send(err)
})
```

**Key Points:**
- This approach applies to all `400` errors, not only JSON parse failures; scope it carefully if other sources of `400` exist
- [Inference] Distinguishing a JSON parse error from other `400`s can be done by inspecting `err.message` for known `JSON.parse` error strings, but this is fragile and depends on the JavaScript runtime; behavior may vary

---

### Registering a Parser for `application/json` Variants

If your API receives `application/vnd.api+json` or similar structured subtypes, register a separate parser:

```js
fastify.addContentTypeParser(
  'application/vnd.api+json',
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      done(null, JSON.parse(body))
    } catch (err) {
      err.statusCode = 400
      done(err)
    }
  }
)
```

Or use a regex to cover an entire family:

```js
fastify.addContentTypeParser(
  /^application\/.+\+json$/,
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      done(null, JSON.parse(body))
    } catch (err) {
      err.statusCode = 400
      done(err)
    }
  }
)
```

**Key Points:**
- This does not replace the built-in `application/json` parser; both coexist
- Fastify resolves parser precedence by specificity: exact string matches take priority over regex matches

---

### bodyLimit and JSON Payloads

The global or per-route `bodyLimit` applies to JSON bodies the same as any other content type. Oversized payloads are rejected before parsing:

```js
const fastify = Fastify({ bodyLimit: 524288 }) // 512 KB
```

**Key Points:**
- The limit is measured in raw bytes before parsing, not after
- Clients exceeding the limit receive `413 Payload Too Large`; the parser is never invoked

---

### Disabling Body Parsing Per Route

For routes that do not need a parsed body, you can disable parsing entirely:

```js
fastify.post('/raw', {
  config: { rawBody: true }
}, async (request, reply) => {
  // request.body is undefined; stream available via request.raw
})
```

More explicitly, pass `false` to the route's schema or use:

```js
fastify.post('/raw', {
  attachValidation: false,
  schema: { body: false }
}, handler)
```

Or when using the content type parser approach, register a passthrough:

```js
fastify.addContentTypeParser(
  'application/json',
  function (req, payload, done) {
    done(null, payload) // pass the stream through unparsed
  }
)
```

**Key Points:**
- [Inference] Passing the stream through as `request.body` means downstream handlers receive a `ReadableStream`, not an object; consuming it incorrectly may cause issues depending on the handler
- The `@fastify/rawbody` plugin is the conventional approach for accessing the raw body alongside the parsed body; it is a separate install

---

### Practical Example: Replacing the JSON Parser with Reviver Support

`JSON.parse` accepts an optional reviver function. The default Fastify parser does not use one. Here is how to add reviver logic:

```js
import Fastify from 'fastify'

const fastify = Fastify()

function dateReviver(key, value) {
  const iso = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$/
  if (typeof value === 'string' && iso.test(value)) {
    return new Date(value)
  }
  return value
}

fastify.removeContentTypeParser('application/json')

fastify.addContentTypeParser(
  'application/json',
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      const parsed = JSON.parse(body, dateReviver)
      done(null, parsed)
    } catch (err) {
      err.statusCode = 400
      done(err)
    }
  }
)

fastify.post('/events', async (request, reply) => {
  const { startsAt } = request.body
  return {
    type: typeof startsAt, // 'object' when reviver fires
    value: startsAt
  }
})

await fastify.listen({ port: 3000 })
```

**Output** (given body `{"startsAt":"2025-01-15T09:00:00Z"}`):

```json
{
  "type": "object",
  "value": "2025-01-15T09:00:00.000Z"
}
```

**Key Points:**
- The reviver converts ISO date strings to `Date` objects at parse time
- This approach applies globally to all routes; route-specific parsing logic requires scoped plugins

---

**Conclusion:**
Fastify's built-in `application/json` parser handles the common case without configuration. When you need control — a different library, a reviver, stricter error messages, or coverage of JSON subtypes — the path is consistent: remove the built-in parser if replacing it, register your own using `addContentTypeParser`, and handle errors explicitly. The same model applies whether you use callback or async style.
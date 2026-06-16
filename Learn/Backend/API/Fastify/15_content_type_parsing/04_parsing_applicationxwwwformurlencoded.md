## Parsing application/x-www-form-urlencoded

Fastify does **not** include a built-in parser for `application/x-www-form-urlencoded`. This is the encoding used by HTML forms and many OAuth flows. To handle it, you must either register a parser manually or use the official `@fastify/formbody` plugin.

---

### What This Content Type Looks Like

When an HTML form submits with `method="POST"` and the default encoding, the body arrives as a percent-encoded string:

```
name=Jane+Doe&age=30&city=New+York
```

The `Content-Type` header is:

```
Content-Type: application/x-www-form-urlencoded
```

**Key Points:**
- Space characters are encoded as `+` or `%20`
- Special characters are percent-encoded
- The structure is flat key-value pairs; nested structures require conventions like `a[b]=1`

---

### Option 1: Using `@fastify/formbody` (Recommended)

The official plugin registers a parser for `application/x-www-form-urlencoded` using the Node.js built-in `querystring` module (or `URLSearchParams` in newer versions).

#### Installation

```bash
npm install @fastify/formbody
```

#### Registration

```js
import Fastify from 'fastify'
import formbody from '@fastify/formbody'

const fastify = Fastify()

await fastify.register(formbody)

fastify.post('/login', async (request, reply) => {
  const { username, password } = request.body
  return { username }
})

await fastify.listen({ port: 3000 })
```

**Key Points:**
- After registration, `request.body` is a plain object parsed from the URL-encoded string
- The plugin is scoped to the instance it is registered on; register it on the root instance for global availability
- [Inference] Because `@fastify/formbody` uses `querystring.parse` or equivalent, all values are strings or arrays of strings by default — no automatic type coercion occurs; validate and coerce explicitly in your schema or handler

---

### Option 2: Manual Parser Registration

If you prefer not to use the plugin, or need custom parsing logic, register the parser directly:

```js
import Fastify from 'fastify'
import { parse } from 'node:querystring'

const fastify = Fastify()

fastify.addContentTypeParser(
  'application/x-www-form-urlencoded',
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      const parsed = parse(body)
      done(null, parsed)
    } catch (err) {
      err.statusCode = 400
      done(err)
    }
  }
)

fastify.post('/submit', async (request, reply) => {
  return { received: request.body }
})

await fastify.listen({ port: 3000 })
```

**Output** (given body `name=Jane&age=30`):

```json
{
  "received": {
    "name": "Jane",
    "age": "30"
  }
}
```

**Key Points:**
- `node:querystring` is a built-in Node.js module; no install required
- All parsed values are strings; `"30"` is not coerced to `30` automatically
- `querystring` is considered legacy in Node.js documentation; `URLSearchParams` is the modern alternative but has a different API surface

---

### Using `URLSearchParams` as the Parser

The WHATWG `URLSearchParams` API is available globally in Node.js without an import:

```js
fastify.addContentTypeParser(
  'application/x-www-form-urlencoded',
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      const params = new URLSearchParams(body)
      const parsed = Object.fromEntries(params.entries())
      done(null, parsed)
    } catch (err) {
      err.statusCode = 400
      done(err)
    }
  }
)
```

**Key Points:**
- `Object.fromEntries(params.entries())` produces a plain object, but **only retains the last value for duplicate keys**
- For multi-value keys (e.g., checkboxes: `color=red&color=blue`), use `params.getAll(key)` explicitly or retain the `URLSearchParams` instance
- [Inference] `querystring.parse` handles duplicate keys as arrays automatically, whereas `URLSearchParams` does not via `Object.fromEntries`; choose based on whether your forms produce multi-value fields

---

### Handling Multi-Value Fields

HTML checkboxes and multi-select inputs produce repeated keys:

```
color=red&color=blue&color=green
```

With `querystring.parse`, this produces:

```json
{ "color": ["red", "blue", "green"] }
```

With `URLSearchParams` + `Object.fromEntries`, this produces:

```json
{ "color": "green" }
```

To handle this correctly with `URLSearchParams`:

```js
fastify.addContentTypeParser(
  'application/x-www-form-urlencoded',
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      const params = new URLSearchParams(body)
      const parsed = {}
      for (const key of params.keys()) {
        const values = params.getAll(key)
        parsed[key] = values.length === 1 ? values[0] : values
      }
      done(null, parsed)
    } catch (err) {
      err.statusCode = 400
      done(err)
    }
  }
)
```

**Output** (given `color=red&color=blue&color=green&name=Jane`):

```json
{
  "color": ["red", "blue", "green"],
  "name": "Jane"
}
```

---

### Nested Object Conventions (qs)

Neither `querystring` nor `URLSearchParams` supports nested key notation like `user[name]=Jane`. If your client sends structured form data, use the `qs` library:

```bash
npm install qs
```

```js
import qs from 'qs'

fastify.addContentTypeParser(
  'application/x-www-form-urlencoded',
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      const parsed = qs.parse(body)
      done(null, parsed)
    } catch (err) {
      err.statusCode = 400
      done(err)
    }
  }
)
```

**Example input:** `user[name]=Jane&user[age]=30&tags[]=red&tags[]=blue`

**Output:**

```json
{
  "user": { "name": "Jane", "age": "30" },
  "tags": ["red", "blue"]
}
```

**Key Points:**
- `qs` is a widely used third-party library; its nesting behavior is configurable via options like `depth` and `allowDots`
- `@fastify/formbody` accepts a `parser` option that lets you substitute `qs.parse` for the default parser

---

### `@fastify/formbody` with Custom Parser

```js
import formbody from '@fastify/formbody'
import qs from 'qs'

await fastify.register(formbody, {
  parser: str => qs.parse(str)
})
```

**Key Points:**
- The `parser` option accepts a synchronous function that receives the raw string and returns a parsed object
- This is the cleanest integration path when using `@fastify/formbody` with `qs`

---

### Schema Validation with Form Data

Because all values arrive as strings, JSON Schema type validation requires care:

```js
fastify.post('/register', {
  schema: {
    body: {
      type: 'object',
      properties: {
        username: { type: 'string' },
        age: { type: 'string' } // not 'number' — values are strings
      },
      required: ['username', 'age']
    }
  }
}, async (request, reply) => {
  const age = parseInt(request.body.age, 10)
  return { username: request.body.username, age }
})
```

**Key Points:**
- Declaring `age` as `type: 'number'` in the schema will cause validation to fail because the parsed value is the string `"30"`, not the number `30`
- Coerce manually in the handler, or use Ajv's `coerceTypes` option
- [Inference] Enabling `coerceTypes` in Ajv causes Fastify to mutate the parsed body to match declared types; this may have side effects on shared references and behavior is not guaranteed to be lossless in all cases

---

### Enabling Ajv `coerceTypes`

To allow Fastify's validator to coerce `"30"` to `30` automatically:

```js
const fastify = Fastify({
  ajv: {
    customOptions: {
      coerceTypes: true
    }
  }
})
```

With this, you can declare:

```js
schema: {
  body: {
    type: 'object',
    properties: {
      age: { type: 'integer' }
    }
  }
}
```

And `request.body.age` will be `30` (integer) after validation.

**Key Points:**
- `coerceTypes` applies globally to all schema validation in the Fastify instance
- [Inference] Enabling `coerceTypes` instance-wide may affect validation behavior elsewhere in ways that are not immediately obvious; test thoroughly across all routes

---

### bodyLimit Applies Here Too

The `bodyLimit` option applies to URL-encoded bodies exactly as it does for JSON:

```js
const fastify = Fastify({ bodyLimit: 102400 }) // 100 KB
```

Large form submissions exceeding the limit receive `413 Payload Too Large` before parsing occurs.

---

### Common Mistakes

| Mistake | Effect |
|---|---|
| Expecting numeric values without coercion | Schema validation fails or wrong type in handler |
| Using `Object.fromEntries` with duplicate keys | Multi-value fields silently lose all but the last value |
| Forgetting to register a parser or plugin | Fastify returns `415 Unsupported Media Type` |
| Registering the parser inside a scoped plugin | Routes outside the plugin scope cannot parse form bodies |
| Not handling the `+` encoding for spaces | Spaces appear as literal `+` if decoded incorrectly |

---

### Practical Example: HTML Login Form Handler

```js
import Fastify from 'fastify'
import formbody from '@fastify/formbody'

const fastify = Fastify()
await fastify.register(formbody)

fastify.post('/login', {
  schema: {
    body: {
      type: 'object',
      properties: {
        username: { type: 'string', minLength: 1 },
        password: { type: 'string', minLength: 8 }
      },
      required: ['username', 'password']
    }
  }
}, async (request, reply) => {
  const { username, password } = request.body
  // authenticate here
  return { status: 'ok', user: username }
})

await fastify.listen({ port: 3000 })
```

**Key Points:**
- `minLength` works correctly here because form values are strings and the schema declares them as `type: 'string'`
- Authentication logic is omitted; never compare passwords in plaintext in production

---

**Conclusion:**
`application/x-www-form-urlencoded` requires explicit setup in Fastify. The `@fastify/formbody` plugin is the most straightforward path and supports a custom parser option for `qs` integration. When registering manually, the primary decisions are which parser to use (`querystring`, `URLSearchParams`, or `qs`), how to handle multi-value fields, and whether to enable Ajv `coerceTypes` for automatic type coercion in schema validation.
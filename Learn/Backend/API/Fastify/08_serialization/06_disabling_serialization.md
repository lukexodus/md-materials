### Disabling Serialization

#### What Disabling Serialization Means

In Fastify, disabling serialization means bypassing the pipeline that converts a response payload — whether through `fast-json-stringify` or a custom serializer — into a string before it is sent. When serialization is disabled or bypassed, the payload reaches the client either as a raw string you construct manually, as a `Buffer`, or through the underlying Node.js `ServerResponse` directly.

There is no single `disableSerialization()` API in Fastify. Disabling serialization is instead achieved through a set of patterns, each with different scope and trade-offs.

---

#### Why Disable Serialization

Common reasons include:

- The payload is already a serialized string (pre-built JSON, cached response body)
- The response is in a format Fastify's serializer cannot handle (binary, streaming, raw text)
- You need to send exactly what you construct — no field stripping, no schema enforcement
- Debugging or inspecting the raw payload before it is transformed
- Performance optimization for a specific route where the payload is pre-computed

---

#### Method 1 — Send a String Directly

If `reply.send()` receives a string, Fastify detects this and skips the serializer entirely. The string is sent as-is.

js

```
fastify.get('/cached', async (request, reply) => {
  const cached = '{"id":1,"name":"Luke"}'
  reply.type('application/json').send(cached)
})
```

**Key Points**

- No schema stripping occurs — the string is sent verbatim.
- No serializer function is invoked.
- You are responsible for correctness and content type.
- `onSend` hooks still run and receive the string as the payload argument.

---

#### Method 2 — reply.serializer with a Pass-Through

Set a no-op serializer that returns the payload unchanged, cast to a string if necessary. This keeps the Fastify lifecycle intact while disabling any transformation.

js

```
fastify.get('/passthrough', async (request, reply) => {
  reply.serializer((payload) => payload)
  return '{"id":1,"name":"Luke"}'
})
```

Or for payloads that are already strings:

js

```
reply.serializer(String)
```

**Key Points**

- The serializer function is still invoked, but performs no transformation.
- If the payload is not already a string, behavior depends on what downstream handling does with a non-string value. [Unverified — verify in your version.]
- `onSend` hooks still run.

---

#### Method 3 — Omit the Response Schema

If no response schema is defined for the matched status code, Fastify falls back to `JSON.stringify` rather than a compiled `fast-json-stringify` serializer.

js

```
fastify.get('/no-schema', async () => {
  return { id: 1, name: 'Luke', extra: 'included' }
})
```

This is not strictly disabling serialization — `JSON.stringify` is still called — but it disables the schema-based serialization pipeline, meaning:

- No field stripping occurs
- No type coercion from the schema
- All fields present on the returned object appear in the output

**Key Points**

- This is the simplest approach when schema enforcement is not needed.
- `JSON.stringify` handles edge cases differently from `fast-json-stringify` — `undefined` values are dropped, `Date` objects are coerced to ISO strings, circular references throw.
- [Inference: omitting response schemas on high-traffic routes may reduce throughput compared to schema-based serialization. Whether this is measurable depends on payload shape and volume.]

---

#### Method 4 — reply.raw

`reply.raw` exposes the underlying Node.js `http.ServerResponse` object. Writing to it bypasses Fastify's entire response pipeline — serialization, hooks, automatic header setting, and lifecycle management.

js

```
fastify.get('/raw', (request, reply) => {
  reply.raw.writeHead(200, { 'Content-Type': 'application/json' })
  reply.raw.end('{"id":1,"name":"Luke"}')
})
```

**Key Points**

- No Fastify serialization occurs.
- No `onSend`, `onResponse`, or other reply lifecycle hooks run for this response.
- Headers set via `reply.header()` before this point may or may not be applied depending on timing. [Unverified — behavior may vary across versions.]
- Fastify does not know the response has been sent via this path in all versions — this can affect connection handling and logging. Verify in your version.
- This approach is generally discouraged except for specific low-level needs (e.g., HTTP upgrades, raw streaming).

---

#### Method 5 — Streaming Responses

For streaming payloads, Fastify accepts a Node.js `Readable` stream as the return value or `reply.send()` argument. Streams bypass the serializer because their content is piped directly to the socket.

js

```
const { Readable } = require('stream')

fastify.get('/stream', async (request, reply) => {
  const stream = Readable.from(['{"id":1,', '"name":"Luke"}'])
  reply.type('application/json').send(stream)
})
```

**Key Points**

- No serializer is invoked when the payload is a stream.
- `onSend` hooks receive the stream object as the payload. Modifying it in a hook is non-trivial.
- You control all content — no field stripping, no schema enforcement.
- For large or long-running responses, streaming avoids buffering the entire payload in memory.

---

#### Method 6 — setSerializerCompiler with a Pass-Through

At the instance level, you can replace the serializer compiler with one that always returns a pass-through serializer, effectively disabling `fast-json-stringify` for all routes.

js

```
fastify.setSerializerCompiler(() => {
  return (payload) => JSON.stringify(payload)
})
```

Or a complete pass-through (no serialization at all — only appropriate if all payloads are already strings):

js

```
fastify.setSerializerCompiler(() => {
  return (payload) => payload
})
```

**Key Points**

- This affects all routes on the instance unless overridden at the route level.
- Using `JSON.stringify` here restores general-purpose serialization without schema enforcement.
- Returning the payload directly only works correctly if every route always returns a string. [Inference: this is brittle in practice unless the codebase strictly enforces this invariant.]

---

#### Interaction with onSend Hook

Regardless of which method is used, the `onSend` hook runs after serialization (or after the pass-through, if serialization is disabled). This means:

```
Handler → preSerialization → Serializer (or bypass) → onSend → Network
```

If you disable serialization by sending a string, `onSend` still receives that string. If you use `reply.raw`, `onSend` does not run.

js

```
fastify.addHook('onSend', async (request, reply, payload) => {
  // payload here is what the serializer returned (a string)
  // or the raw string passed to reply.send()
  console.log(typeof payload) // 'string' in most bypass scenarios
  return payload
})
```

---

#### Interaction with Schema Field Stripping

All methods that bypass the schema-based serializer also bypass field stripping. If a returned object contains fields that should not be exposed, those fields will appear in the output unless you remove them explicitly before sending.

js

```
// Schema-based serializer: 'secret' is stripped
fastify.get('/safe', {
  schema: { response: { 200: { type: 'object', properties: { id: { type: 'integer' } } } } }
}, async () => ({ id: 1, secret: 'hidden' }))
// Output: {"id":1}

// Serialization disabled: 'secret' is included
fastify.get('/unsafe', async (request, reply) => {
  reply.send(JSON.stringify({ id: 1, secret: 'hidden' }))
})
// Output: {"id":1,"secret":"hidden"}
```

[Inference: in security-sensitive contexts, explicitly removing sensitive fields before bypassing serialization is more robust than relying on schema stripping alone.]

---

#### Comparison of Methods

| Method | Serializer invoked | Schema stripping | onSend runs | Hooks intact | Scope |
| --- | --- | --- | --- | --- | --- |
| `reply.send(string)` | No | No | Yes | Yes | Per reply |
| `reply.serializer(pass-through)` | Yes (no-op) | No | Yes | Yes | Per reply |
| No response schema | Yes (`JSON.stringify`) | No | Yes | Yes | Per route |
| `reply.raw` | No | No | No | No | Per reply |
| Stream payload | No | No | Yes (stream) | Yes | Per reply |
| Instance pass-through compiler | Yes (no-op) | No | Yes | Yes | All routes |

---

#### When to Use Each

| Situation | Recommended method |
| --- | --- |
| Sending a cached, pre-built JSON string | `reply.send(string)` |
| Sending binary or streaming data | Stream or `reply.send(Buffer)` |
| Disabling schema stripping for one route | No response schema |
| Replacing serialization globally | `setSerializerCompiler` |
| Low-level HTTP control (upgrades, raw sockets) | `reply.raw` |
| Bypassing serialization for one response while keeping hooks | `reply.serializer(pass-through)` |
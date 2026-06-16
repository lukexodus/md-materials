### Serializer per Content Type

#### Overview

By default, Fastify serializes responses as JSON using `fast-json-stringify`. When a route needs to respond with a different content type — such as `application/msgpack`, `text/csv`, or `application/xml` — the default JSON serialization pipeline is not appropriate. Fastify provides mechanisms to register serializers tied to specific content types, so the correct serialization logic is applied based on what the route is producing.

---

#### How Fastify Determines the Serializer

When Fastify serializes a response, it considers:

1. The `Content-Type` set on the reply (via `reply.type()` or the route default)
2. The serializer compiler in effect (instance-level or route-level)
3. Whether a per-reply override exists (`reply.serializer()`)

If the payload is already a string, Fastify skips serialization entirely and sends it as-is. Otherwise, it invokes the serializer for the content type in effect.

The content-type-to-serializer mapping is not a built-in registry in Fastify — it is implemented through the serializer compiler interface.

---

#### Registering a Serializer for a Content Type

The primary mechanism is `setSerializerCompiler`, where you inspect the `contentType` field of the context object and return the appropriate serializer function.

js

```
import Fastify from 'fastify'
import { stringify as csvStringify } from 'csv-stringify/sync'
import { encode as msgpackEncode } from 'msgpackr'
import { buildSerializer as buildJsonSerializer } from '@fastify/fast-json-stringify-compiler'

const fastify = Fastify()

fastify.setSerializerCompiler(({ schema, contentType }) => {
  switch (contentType) {
    case 'application/msgpack':
      return (payload) => msgpackEncode(payload)

    case 'text/csv':
      return (payload) => csvStringify(payload)

    default:
      // Fall back to fast-json-stringify for JSON
      return buildJsonSerializer({ schema })
  }
})
```

> The import path and API for `buildJsonSerializer` (or equivalent) depends on your version of `@fastify/fast-json-stringify-compiler`. Verify against your installed version. Behavior of third-party encode functions is not guaranteed by Fastify.

---

#### Sending a Non-JSON Response

Once the serializer compiler is configured, a route signals its content type with `reply.type()`. Fastify passes that content type to the compiler when building the serializer.

js

```
fastify.get('/report', {
  schema: {
    response: {
      200: {
        type: 'array',
        items: {
          type: 'object',
          properties: {
            name:  { type: 'string' },
            score: { type: 'integer' }
          }
        }
      }
    }
  }
}, async (request, reply) => {
  reply.type('text/csv')
  return [
    { name: 'Luke', score: 98 },
    { name: 'Ana',  score: 87 }
  ]
})
```

**Output** (sent as `text/csv`)

```
name,score
Luke,98
Ana,87
```

The schema is still passed to the compiler. In this example the CSV serializer ignores it, but you could use it to determine column order or field selection.

---

#### Content Type in the Compiler Context

The `contentType` field in the compiler context reflects what Fastify knows about the route's content type at **compile time** — not necessarily what `reply.type()` is called with at **request time**.

**Key Points**

- If `reply.type()` is called inside the handler (at request time), the compiler has already been called with whatever content type was known at startup.
- [Inference: dynamically changing the content type per request inside the handler may not correctly route to a content-type-specific serializer built at compile time. The per-reply override `reply.serializer()` is more appropriate for fully dynamic content type selection.]
- For routes with a fixed content type, declare it at the route level or via a hook so it is known at compile time.

---

#### Declaring Content Type at Route Level

To ensure the correct serializer is compiled for a route, set the content type as part of the route definition using a `preSerialization` or `onSend` hook, or by using a route-level `serializerCompiler`.

A cleaner approach for fixed content types is to use the route-level `serializerCompiler`:

js

```
fastify.get('/data.msgpack', {
  serializerCompiler: () => {
    return (payload) => msgpackEncode(payload)
  }
}, async () => {
  return { id: 1, value: 42 }
})
```

Combined with setting the reply type in a handler or hook:

js

```
fastify.get('/data.msgpack', {
  serializerCompiler: () => (payload) => msgpackEncode(payload),
  onSend: async (request, reply, payload) => {
    reply.type('application/msgpack')
    return payload
  }
}, async () => ({ id: 1, value: 42 }))
```

[Inference: the `onSend` hook receives the already-serialized payload as a string or Buffer in some Fastify versions. Verify the exact payload type in your version before manipulating it in `onSend`.]

---

#### Per-Reply Content Type Serializer

For fully dynamic scenarios where the content type is determined at request time (e.g., from an `Accept` header), use `reply.serializer()` inside the handler:

js

```
fastify.get('/flexible', async (request, reply) => {
  const accept = request.headers['accept'] || 'application/json'
  const data = { id: 1, name: 'Luke' }

  if (accept === 'application/msgpack') {
    reply
      .type('application/msgpack')
      .serializer((payload) => msgpackEncode(payload))
    return data
  }

  // Default: JSON serialization applies
  return data
})
```

**Key Points**

- `reply.serializer()` overrides the compiled serializer for this response only.
- The schema-based `fast-json-stringify` serializer is bypassed when `reply.serializer()` is used.
- Field exclusion from the response schema does not apply when the schema-based serializer is bypassed.

---

#### Handling Binary Serializers

Some content types produce binary output (e.g., `application/msgpack`, `application/protobuf`). Fastify can send `Buffer` values — if your serializer returns a `Buffer`, set the content type correctly and Fastify will send it without further transformation.

js

```
fastify.get('/binary', {
  serializerCompiler: () => {
    return (payload) => Buffer.from(msgpackEncode(payload))
  }
}, async (request, reply) => {
  reply.type('application/msgpack')
  return { id: 1, value: 42 }
})
```

> Whether Fastify handles a `Buffer` return from the serializer correctly depends on the version. Verify this behavior in your environment — do not assume it is consistent across versions.

---

#### XML Example

js

```
fastify.get('/feed', {
  serializerCompiler: () => {
    return (payload) => {
      const items = payload.items
        .map(i => `<item><title>${i.title}</title></item>`)
        .join('')
      return `<?xml version="1.0"?><feed>${items}</feed>`
    }
  }
}, async (request, reply) => {
  reply.type('application/xml')
  return {
    items: [
      { title: 'First Post' },
      { title: 'Second Post' }
    ]
  }
})
```

**Output**

xml

```
<?xml version="1.0"?><feed><item><title>First Post</title></item><item><title>Second Post</title></item></feed>
```

[Inference: this example constructs XML by string interpolation without escaping. In production, untrusted input in title fields would require proper escaping or a dedicated XML serialization library to avoid malformed output or injection.]

---

#### Content Negotiation Pattern

A common pattern is to inspect the `Accept` header and branch to the appropriate serializer. This is typically implemented as a combination of a hook and `reply.serializer()`:

js

```
fastify.addHook('preSerialization', async (request, reply, payload) => {
  const accept = request.headers['accept'] || 'application/json'

  if (accept === 'application/msgpack') {
    reply
      .type('application/msgpack')
      .serializer((p) => msgpackEncode(p))
  }

  return payload
})
```

**Key Points**

- `preSerialization` runs before the serializer is invoked, making it the correct hook for switching serializers dynamically.
- The hook must return the payload (modified or unmodified).
- This approach applies globally to all routes unless scoped inside a plugin with `fastify.register()`.

---

#### Lifecycle Position of Serialization

```
Handler returns payload
        ↓
preSerialization hook(s)
        ↓
Serializer invoked (schema-based, custom, or reply override)
        ↓
onSend hook(s)  ← payload is now a string or Buffer
        ↓
Response sent
```

**Key Points**

- Modify the payload object in `preSerialization`.
- Modify the serialized string or Buffer in `onSend`.
- Setting `reply.serializer()` in `preSerialization` affects which serializer is invoked in the next step.

---

#### Comparison of Approaches

| Approach | Scope | Content type known at compile time | Schema stripping applies |
| --- | --- | --- | --- |
| Instance `setSerializerCompiler` with `contentType` switch | All routes | Yes, if set at route level | Depends on fallback |
| Route `serializerCompiler` option | Single route | Yes | No (unless implemented manually) |
| `reply.serializer()` in handler | Single response | No | No |
| `reply.serializer()` in `preSerialization` hook | Configurable | No | No |
| Pre-serialized string via `reply.send(string)` | Single response | N/A | No |
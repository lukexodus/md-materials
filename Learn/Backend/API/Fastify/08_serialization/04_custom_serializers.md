### Custom Serializers

#### What Is a Custom Serializer

By default, Fastify compiles a serializer for each route from its response schema using `fast-json-stringify`. A custom serializer replaces or overrides this behavior — either for a specific reply, a specific route, or across the entire Fastify instance — allowing you to control exactly how the response payload is converted to a string before being sent.

Custom serializers can be applied at three levels:

1. **Reply level** — overrides serialization for a single response
2. **Instance level** — replaces the serializer compiler for all routes
3. **Content-type level** — registers serializers for non-JSON content types

---

#### Reply-Level Override

`reply.serializer(fn)` sets a custom serialization function for the current response only. The function receives the payload and must return a string.

js

```
fastify.get('/debug', async (request, reply) => {
  reply.serializer((payload) => JSON.stringify(payload, null, 2))
  return { id: 1, name: 'Luke' }
})
```

**Output**

json

```
{
  "id": 1,
  "name": "Luke"
}
```

**Key Points**

- This bypasses `fast-json-stringify` entirely for this reply.
- The schema defined on the route is ignored for serialization purposes when this is used.
- Any function that accepts a value and returns a string is valid.
- This does not affect other replies on the same route.

---

#### Using reply.send with a Pre-Serialized String

If you pass a string to `reply.send()`, Fastify treats it as already serialized and sends it as-is, without invoking any serializer.

js

```
fastify.get('/preserialized', async (request, reply) => {
  reply.type('application/json').send('{"id":1,"name":"Luke"}')
})
```

**Key Points**

- You are responsible for the correctness of the string.
- The `Content-Type` header must be set manually if it would not otherwise be `application/json`.
- No schema stripping or transformation occurs — the string is sent verbatim.

---

#### Instance-Level Serializer Compiler

Fastify exposes `setSerializerCompiler()` to replace the function responsible for building serializers from schemas across all routes. This is the primary extension point for replacing `fast-json-stringify` with a different serialization library or a custom implementation.

js

```
fastify.setSerializerCompiler(({ schema, method, url, httpStatus, contentType }) => {
  // Return a function that will serialize the payload
  return (payload) => JSON.stringify(payload)
})
```

The compiler receives a context object and must return a serialization function.

**Context object fields**

| Field | Description |
| --- | --- |
| `schema` | The JSON Schema defined for this route and status code |
| `method` | HTTP method of the route |
| `url` | URL pattern of the route |
| `httpStatus` | The status code this serializer is being built for |
| `contentType` | The content type for this serializer |

**Example — integrating a custom library**

js

```
const { stringify } = require('superjson') // hypothetical

fastify.setSerializerCompiler(({ schema }) => {
  return (payload) => stringify(payload)
})
```

> Behavior of third-party serializers integrated this way depends entirely on the library used. Correctness and performance are not guaranteed by Fastify.

---

#### Compiler vs. Serializer: The Distinction

| Term | What it is |
| --- | --- |
| **Serializer compiler** | A function that receives a schema and returns a serializer |
| **Serializer** | A function that receives a payload and returns a string |

`setSerializerCompiler` sets the compiler. The compiler is called once per route/status-code combination at startup. The serializer it returns is called on every matching request.

```
setSerializerCompiler( schema => payload => string )
                       └── compiler ──┘└─ serializer ─┘
```

This two-level structure is what allows Fastify to do compilation work once and apply the result repeatedly.

---

#### Accessing the Current Serializer Compiler

js

```
const compiler = fastify.serializerCompiler
```

This retrieves the currently configured compiler. Useful when wrapping the default compiler to add behavior around it rather than replacing it entirely.

**Example — wrapping the default compiler**

js

```
import { defaultSerializerCompiler } from '@fastify/fast-json-stringify-compiler'

fastify.setSerializerCompiler((context) => {
  const defaultSerializer = defaultSerializerCompiler(context)
  return (payload) => {
    // pre-processing
    const result = defaultSerializer(payload)
    // post-processing
    return result
  }
})
```

[Inference: the import path and API for the default compiler depend on the version of `@fastify/fast-json-stringify-compiler` installed. Verify against your version's documentation.]

---

#### Content-Type Serializers

Fastify's built-in serialization handles `application/json`. For other content types, you register a serializer using `reply.type()` in combination with `fastify.addContentTypeParser` (for request parsing) or by using `reply.serializer()` on a per-reply basis.

For structured content-type serialization at the instance level, the pattern is to use `setSerializerCompiler` in combination with checking `contentType` in the context:

js

```
fastify.setSerializerCompiler(({ schema, contentType }) => {
  if (contentType === 'application/msgpack') {
    return (payload) => msgpack.encode(payload)
  }
  // Fall back to fast-json-stringify for JSON
  return buildFastJsonStringify(schema)
})
```

[Inference: this pattern assumes `contentType` is reliably populated in the compiler context for all routes. Verify against your Fastify version.]

---

#### Per-Route Serializer Compiler

A serializer compiler can also be set at the route level, overriding the instance-level compiler for that route only.

js

```
fastify.get('/custom', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: { id: { type: 'integer' } }
      }
    }
  },
  serializerCompiler: ({ schema }) => {
    return (payload) => JSON.stringify(payload)
  }
}, async () => ({ id: 1 }))
```

**Key Points**

- The `serializerCompiler` option on a route takes precedence over the instance-level compiler set via `setSerializerCompiler`.
- The schema is still passed to the compiler — you can use it or ignore it.
- This does not affect any other route.

---

#### Serialization and Hooks

Custom serializers operate within Fastify's reply lifecycle. The serialization step occurs after `onSend` hooks have run. This means:

- `onSend` hooks receive the payload **before** serialization.
- If an `onSend` hook modifies the payload, the custom serializer receives the modified payload.
- If an `onSend` hook replaces the payload with a string, the serializer may still be called depending on the implementation. [Unverified — behavior may differ across versions.]

```
Handler → onSend hooks → Serializer → Network
```

---

#### Error Response Serialization

Fastify serializes error responses through its own error serialization path, which is separate from the response schema serializer. The default error serializer produces:

json

```
{"statusCode":400,"error":"Bad Request","message":"..."}
```

To customize error serialization, use `fastify.setErrorHandler()` to intercept errors and return a shaped reply, or use `fastify.setReplySerializer()` if available in your version.

[Unverified: `setReplySerializer` availability and API may differ across Fastify versions. Verify against your installed version.]

js

```
fastify.setErrorHandler((error, request, reply) => {
  reply.status(error.statusCode || 500).send({
    ok: false,
    message: error.message
  })
})
```

The `send()` call here goes through the normal serialization pipeline — if the error route has a response schema for that status code, it applies.

---

#### Standalone Serializer (Build-Time)

`fast-json-stringify` supports generating the serializer function as a standalone string that can be written to disk and loaded without the library at runtime. Fastify exposes this via `@fastify/fast-json-stringify-compiler`.

This is relevant for custom serializer workflows because:

- You can pre-generate serializers at build time
- Cold-start overhead is reduced
- The generated function has no runtime dependency on `fast-json-stringify`

[Inference: standalone mode may not support all schema features. Verify supported constructs against the current `fast-json-stringify` documentation.]

---

#### Choosing the Right Level

| Need | Approach |
| --- | --- |
| Override serialization for one response | `reply.serializer(fn)` |
| Send pre-built JSON string | `reply.type(...).send(string)` |
| Replace serializer for one route | `serializerCompiler` route option |
| Replace serializer for all routes | `fastify.setSerializerCompiler()` |
| Wrap default serializer with extra logic | Retrieve and wrap `fastify.serializerCompiler` |
| Handle non-JSON content types | Check `contentType` in custom compiler |
### How Fastify Serializes Responses

Fastify serializes responses differently from most Node.js frameworks. Rather than calling `JSON.stringify` on every response, it compiles a dedicated serialization function from the response schema at startup. This shifts the cost of schema interpretation from runtime to initialization time, producing faster throughput for JSON responses. Understanding the full serialization pipeline — what triggers it, how it works, and what it omits — is essential for predictable response output.

---

#### Serialization vs Validation

These are two separate pipelines in Fastify:

| Concern | Validation | Serialization |
| --- | --- | --- |
| Direction | Inbound (request) | Outbound (response) |
| Compiler | Ajv (default) | `fast-json-stringify` (default) |
| Configured via | `setValidatorCompiler` | `setSerializerCompiler` |
| Triggered by | Schema on `body`, `params`, `query`, `headers` | Schema on `response` |
| Effect on data | Rejects invalid input | Shapes and encodes output |

**Key Points**

- A route with no `response` schema still works — Fastify falls back to `JSON.stringify`.
- A route with a `response` schema uses a compiled serializer, which is faster but only includes fields declared in the schema.

---

#### The Serialization Pipeline

yesnoyesnoyesnoRoute Handler ReturnsValueresponse schemadefined?Compiledfast-json-stringifyfunctionJSON.stringify fallbackStatus code matchesschema?Serialize with compiledschema2xx default defined?Serialize with 2xx schemaJSON.stringify fallbackSet Content-Type:application/jsonSend Response

**Key Points**

- Fastify matches the response schema by status code first, then falls back to a `2xx` wildcard if defined.
- If neither matches, `JSON.stringify` is used — no schema-based stripping or optimization occurs.
- [Inference] The fallback to `JSON.stringify` means undeclared status codes bypass the compiled serializer entirely; this is by design but can be a source of inconsistency if not accounted for.

---

#### Defining a Response Schema

Response schemas are nested under the `response` key in the route schema, keyed by HTTP status code.

js

```
fastify.get('/user/:id', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          id:    { type: 'integer' },
          name:  { type: 'string' },
          email: { type: 'string' }
        }
      }
    }
  }
}, async (request) => {
  return { id: 1, name: 'Ada', email: 'ada@example.com', passwordHash: 'secret' }
})
```

**Output:**

json

```
{ "id": 1, "name": "Ada", "email": "ada@example.com" }
```

**Key Points**

- `passwordHash` is absent from the output because it is not declared in the response schema.
- This is not a security guarantee — it is a side effect of schema-driven serialization. Do not rely on schema omission alone to protect sensitive fields; filter them explicitly in the handler.
- [Inference] Fields present in the returned object but absent from the schema are silently dropped by `fast-json-stringify`. Behavior may vary for deeply nested or array structures — verify output against your schema complexity.

---

#### Status Code Matching

Schemas can be defined for individual status codes or using wildcard patterns.

js

```
fastify.post('/resource', {
  schema: {
    response: {
      201: {
        type: 'object',
        properties: {
          id:      { type: 'integer' },
          created: { type: 'boolean' }
        }
      },
      400: {
        type: 'object',
        properties: {
          error:   { type: 'string' },
          message: { type: 'string' }
        }
      },
      '4xx': {
        type: 'object',
        properties: {
          message: { type: 'string' }
        }
      },
      '2xx': {
        type: 'object',
        properties: {
          ok: { type: 'boolean' }
        }
      }
    }
  }
}, handler)
```

**Resolution order:**

1. Exact status code (`201`, `400`)
2. Range wildcard (`2xx`, `4xx`, `5xx`)
3. `JSON.stringify` fallback

**Key Points**

- An exact code takes precedence over a range wildcard — `201` is used over `2xx` when both are defined.
- Wildcards are string keys: `'2xx'`, `'4xx'`, `'5xx'` — not numbers.

---

#### fast-json-stringify

`fast-json-stringify` is Fastify's default serialization library. It takes a JSON Schema and generates a serialization function optimized for that specific shape.

**Key Points**

- It produces a function rather than interpreting the schema at runtime on each request.
- It handles `type`, `properties`, `items`, `allOf`, `anyOf`, `oneOf`, `$ref`, and `nullable`.
- It does not perform validation — it assumes the data is already correct and serializes it as declared.
- [Inference] Passing data that does not match the declared schema to the serializer may produce incorrect, incomplete, or malformed output without throwing an error. Behavior depends on the specific mismatch and `fast-json-stringify` version.

---

#### Field Omission Behavior

Fields not in the schema are dropped. Fields in the schema but absent from the data are handled according to whether they are declared `required`.

js

```
fastify.get('/status', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          status:  { type: 'string' },
          version: { type: 'string' }
        }
      }
    }
  }
}, async () => {
  // 'uptime' is not in the schema — dropped
  // 'version' is in the schema but not returned — becomes null or absent
  return { status: 'ok', uptime: 999 }
})
```

**Output:**

json

```
{ "status": "ok" }
```

[Inference] The exact output for missing schema fields (`version` in this case) depends on `fast-json-stringify` behavior for that type — string fields may be omitted or serialized as `null` depending on the version and whether `required` is declared. Verify output against your installed version.

---

#### Nullable and Optional Fields

To allow a field to be `null`, use the `nullable` extension or a type array:

js

```
// fast-json-stringify supports 'nullable' as an extension
{
  type: 'object',
  properties: {
    nickname: { type: 'string', nullable: true }
  }
}

// Standard JSON Schema approach using type array
{
  type: 'object',
  properties: {
    nickname: { type: ['string', 'null'] }
  }
}
```

**Key Points**

- `nullable: true` is a `fast-json-stringify` extension, not standard JSON Schema — it may not be recognized by other tools (e.g., OpenAPI generators) without mapping.
- The type array approach (`['string', 'null']`) is standard JSON Schema and more portable.

---

#### Serializing Arrays

js

```
fastify.get('/users', {
  schema: {
    response: {
      200: {
        type: 'array',
        items: {
          type: 'object',
          properties: {
            id:   { type: 'integer' },
            name: { type: 'string' }
          }
        }
      }
    }
  }
}, async () => {
  return [
    { id: 1, name: 'Ada',   role: 'admin' },
    { id: 2, name: 'Grace', role: 'user'  }
  ]
})
```

**Output:**

json

```
[
  { "id": 1, "name": "Ada" },
  { "id": 2, "name": "Grace" }
]
```

**Key Points**

- The `role` field is dropped from every item because it is not declared in `items`.
- The top-level `type: 'array'` is required — omitting it causes the serializer to not recognize the array shape.

---

#### Using $ref in Response Schemas

Response schemas support `$ref` in the same way as validation schemas, resolved from the shared schema registry.

js

```
fastify.addSchema({
  $id: 'User',
  type: 'object',
  properties: {
    id:   { type: 'integer' },
    name: { type: 'string' }
  }
})

fastify.get('/user/:id', {
  schema: {
    response: {
      200: { $ref: 'User#' }
    }
  }
}, async () => ({ id: 1, name: 'Ada', secret: 'hidden' }))
```

**Output:**

json

```
{ "id": 1, "name": "Ada" }
```

---

#### Replacing the Serializer Compiler

`setSerializerCompiler` replaces `fast-json-stringify` with any function that accepts a schema and returns a serialization function.

js

```
fastify.setSerializerCompiler(({ schema, method, url, httpStatus }) => {
  return function serialize(data) {
    return JSON.stringify(data) // naive replacement — no schema optimization
  }
})
```

**Parameters:**

| Parameter | Description |
| --- | --- |
| `schema` | The response schema for this status code |
| `method` | HTTP method |
| `url` | Route URL pattern |
| `httpStatus` | Status code string this schema applies to |

**Key Points**

- The returned function must return a string — Fastify writes it to the response body as-is.
- This replaces the compiler for all routes on the instance unless overridden per-route.

---

#### Per-Route Serializer

A serializer can be scoped to a single route:

js

```
fastify.get('/debug', {
  serializerCompiler: ({ schema }) => {
    return (data) => JSON.stringify(data, null, 2) // pretty-print for this route only
  },
  schema: {
    response: { 200: { type: 'object' } }
  }
}, async () => ({ status: 'ok', ts: Date.now() }))
```

---

#### Sending Non-JSON Responses

When the response is not JSON, bypass the serializer by setting the content type manually and sending a string or buffer directly.

js

```
fastify.get('/plain', async (request, reply) => {
  reply.type('text/plain').send('hello world')
})

fastify.get('/xml', async (request, reply) => {
  reply
    .type('application/xml')
    .send('<status>ok</status>')
})
```

**Key Points**

- `reply.send()` with a non-object value (string, Buffer, stream) bypasses JSON serialization entirely.
- Setting `Content-Type` to anything other than `application/json` signals to Fastify not to apply the JSON serializer.

---

#### Serialization and onSend Hook

The `onSend` hook fires after serialization but before the response is written to the socket. At this point, `payload` is already a string (or stream/buffer).

js

```
fastify.addHook('onSend', async (request, reply, payload) => {
  // payload is already serialized — a string here for JSON responses
  console.log(typeof payload) // 'string'
  return payload              // must return the (possibly modified) payload
})
```

**Key Points**

- Modifying the payload at this stage means working with raw strings — parse and re-stringify if structural changes are needed.
- Returning a different value from `onSend` replaces the response body.
- [Inference] Returning `undefined` from `onSend` may cause unexpected behavior — always return the payload explicitly. Behavior is not guaranteed across versions.

---

#### Performance Characteristics

| Approach | Relative Speed | Notes |
| --- | --- | --- |
| `fast-json-stringify` with schema | Fastest | Compiled at startup; no runtime schema interpretation |
| `JSON.stringify` fallback | Moderate | Standard V8 implementation; no schema overhead |
| Custom serializer (naive `JSON.stringify`) | Moderate | Same as fallback; loses schema optimization |
| Pretty-print or transformation | Slowest | Additional work per response |

[Inference] Performance figures are relative and depend on payload size, schema complexity, and runtime environment. Benchmark under your actual conditions — published benchmarks may not reflect your workload.

---

**Conclusion**

Fastify's serialization pipeline compiles response schemas into optimized functions at startup, producing faster JSON output than a generic `JSON.stringify` call. The pipeline matches status codes to schemas, drops undeclared fields, and falls back gracefully when no matching schema exists. Replacing or augmenting the serializer is straightforward at both instance and route level. The critical behaviors to internalize are field omission by schema, status code resolution order, and the distinction between the serialization and validation pipelines — they are independent systems with separate compilers, configuration points, and failure modes.
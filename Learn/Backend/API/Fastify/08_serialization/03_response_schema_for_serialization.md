### Response Schema for Serialization

#### What Is a Response Schema

In Fastify, a response schema is a JSON Schema definition attached to a route that describes the shape of the response payload for one or more HTTP status codes. When present, Fastify uses it to compile a `fast-json-stringify` serializer for that route, replacing the default `JSON.stringify` call with a purpose-built serialization function.

The response schema serves two distinct roles:

1. **Serialization** — controls how the reply payload is encoded to a JSON string before being sent
2. **Documentation** — drives OpenAPI/Swagger output when using `@fastify/swagger`

This document focuses on the serialization role.

---

#### Defining a Response Schema

Response schemas are declared inside the `schema` option of a route definition, under the `response` key. Each key under `response` is an HTTP status code (or a pattern), and its value is a JSON Schema object.

js

```
fastify.get('/item/:id', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          id:    { type: 'integer' },
          name:  { type: 'string' },
          price: { type: 'number' }
        }
      }
    }
  }
}, async (request, reply) => {
  return { id: 42, name: 'Widget', price: 9.99, internalCost: 3.00 }
})
```

**Output**

json

```
{"id":42,"name":"Widget","price":9.99}
```

`internalCost` is absent from the output because it is not declared in the schema. Behavior may vary depending on Fastify version and serializer configuration.

---

#### Status Code Matching

You can define different schemas for different status codes on the same route.

js

```
fastify.post('/user', {
  schema: {
    response: {
      201: {
        type: 'object',
        properties: {
          id:   { type: 'integer' },
          name: { type: 'string' }
        }
      },
      400: {
        type: 'object',
        properties: {
          error:   { type: 'string' },
          message: { type: 'string' }
        }
      }
    }
  }
}, async (request, reply) => {
  // ...
})
```

Fastify selects the serializer that matches the actual HTTP status code set on the reply at response time.

---

#### Wildcard and Fallback Status Codes

Fastify supports `'2xx'`, `'3xx'`, `'4xx'`, and `'5xx'` as wildcard keys that match any status code in that range, in addition to exact codes.

js

```
schema: {
  response: {
    '2xx': {
      type: 'object',
      properties: {
        status: { type: 'string' }
      }
    },
    '5xx': {
      type: 'object',
      properties: {
        error: { type: 'string' }
      }
    }
  }
}
```

**Key Points**

- An exact status code match takes precedence over a wildcard match.
- If no schema matches the actual status code, Fastify falls back to `JSON.stringify` for that response. This fallback behavior may vary across versions — verify against your installed version.

---

#### The `default` Key

A schema keyed as `'default'` acts as a catch-all for any status code not explicitly matched.

js

```
schema: {
  response: {
    200: { /* ... */ },
    default: {
      type: 'object',
      properties: {
        message: { type: 'string' }
      }
    }
  }
}
```

[Inference: `default` is most useful for routes where error shapes are uniform across many codes.] Verify behavior for your Fastify version, as support and precedence rules for `default` may differ.

---

#### Field Exclusion

Fields present on the returned object but absent from `properties` are excluded from the serialized output. This is a consequence of how `fast-json-stringify` operates — it only encodes declared fields.

js

```
// Schema declares only: id, name
// Handler returns:       id, name, passwordHash, __v

// Serialized output contains only: id, name
```

**Key Points**

- This is not validation — Fastify does not reject the response object for having extra fields.
- This is not a substitute for access control. [Inference: relying solely on schema exclusion to prevent data leakage introduces risk if schema definitions drift from the actual data model.]
- For fields that must never appear in output, defense-in-depth — removing them explicitly before returning — is a more robust approach.

---

#### Required Fields and Missing Data

If a field listed in `required` is missing from the actual response object at runtime, `fast-json-stringify` does not throw by default. Instead, it substitutes a type-dependent default:

| Type | Substituted value |
| --- | --- |
| `string` | `""` |
| `integer` / `number` | `0` |
| `boolean` | `false` |
| `null` | `null` |
| `object` | `{}` |
| `array` | `[]` |

> This behavior is [Unverified] to be consistent across all versions of `fast-json-stringify` and Fastify. Test against your installed versions. Silent substitution can produce incorrect responses without surfacing an error.

---

#### Nullable and Optional Fields

To allow a field to be either its declared type or `null`, use a type array:

js

```
{
  type: 'object',
  properties: {
    nickname: { type: ['string', 'null'] }
  }
}
```

Fastify also accepts the `nullable: true` convention (from OpenAPI 3.0), though this is a Fastify/`@fastify/swagger` extension and not standard JSON Schema Draft 7.

js

```
{
  type: 'object',
  properties: {
    nickname: { type: 'string', nullable: true }
  }
}
```

[Inference: `nullable: true` may not behave identically to `type: ['string', 'null']` in all serializer contexts. Verify against your version.]

For fields that may be entirely absent from the object, omit them from `required`. Whether the serializer outputs the key with an `undefined`-equivalent or omits it entirely is [Unverified] and version-dependent — test explicitly.

---

#### Nested Objects and Arrays

Schemas can be nested to arbitrary depth.

js

```
schema: {
  response: {
    200: {
      type: 'object',
      properties: {
        user: {
          type: 'object',
          properties: {
            id:    { type: 'integer' },
            email: { type: 'string' }
          }
        },
        tags: {
          type: 'array',
          items: { type: 'string' }
        }
      }
    }
  }
}
```

**Example**

js

```
return {
  user: { id: 1, email: 'luke@example.com', password: 'hidden' },
  tags: ['admin', 'user']
}
```

**Output**

json

```
{"user":{"id":1,"email":"luke@example.com"},"tags":["admin","user"]}
```

`password` is excluded because it is not in the nested `user` schema.

---

#### Using `$ref` for Reusable Schemas

For schemas shared across multiple routes, define them once and reference them with `$ref`.

js

```
fastify.addSchema({
  $id: 'UserResponse',
  type: 'object',
  properties: {
    id:   { type: 'integer' },
    name: { type: 'string' }
  }
})

fastify.get('/me', {
  schema: {
    response: {
      200: { $ref: 'UserResponse#' }
    }
  }
}, async () => ({ id: 1, name: 'Luke' }))
```

**Key Points**

- `$id` must be unique within the Fastify instance.
- `$ref` resolution happens at compile time, before the serializer is built.
- Schemas added via `addSchema` are scoped to the enclosing plugin unless added at the root instance.

---

#### Schema Compilation Timing

Fastify compiles serializers during the initialization phase — after all routes are registered and before the server starts accepting requests. This means:

- Compilation errors surface at startup, not at request time.
- There is no per-request compilation overhead.
- Schemas cannot be modified after the server has started.

js

```
await fastify.ready() // serializers are compiled here
await fastify.listen({ port: 3000 })
```

[Inference: schemas registered after `fastify.ready()` or `fastify.listen()` are called may not be compiled. Verify this boundary for your version.]

---

#### Bypassing Serialization

To send a response without applying the schema serializer, use `reply.send()` with a pre-serialized string and set the content type manually, or use `reply.serializer()` to override the serializer for a specific reply.

js

```
fastify.get('/raw', async (request, reply) => {
  reply
    .type('application/json')
    .serializer(JSON.stringify)
    .send({ id: 1, extra: 'included' })
})
```

This bypasses `fast-json-stringify` entirely for that response. `extra` will appear in the output.

Alternatively, `reply.raw` gives direct access to the underlying Node.js `ServerResponse`, bypassing Fastify's serialization pipeline entirely — but also bypassing hooks, error handling, and other Fastify lifecycle features.

---

#### Common Mistakes

| Mistake | Effect |
| --- | --- |
| Schema type mismatch (e.g., field is `integer` but handler returns a string) | Output may be `0` or malformed — no error thrown |
| Forgetting to declare a field in the schema | Field is silently dropped from the response |
| Using `required` without ensuring the field is always present | Silent default substitution in the output |
| Defining the schema but not returning the right structure | Partially correct output with no warning |
| Mutating `addSchema` entries after server start | [Unverified] — behavior is undefined; avoid |

---

#### Relationship to Validation

Response schemas in Fastify are **not** used for validation by default. Fastify uses `@fastify/ajv-compile-with-serialize` (or a configured validation compiler) only for **request** validation — body, querystring, params, headers.

The response schema feeds only the serialization compiler. If you need to validate the shape of your response at runtime (e.g., in development), you must configure a custom serializer compiler or add explicit validation logic.

[Inference: mixing up request validation and response serialization is a common source of confusion — the two pipelines are separate and use different mechanisms.]
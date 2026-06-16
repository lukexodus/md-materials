### Response Validation Schema

#### Overview

Fastify validates outgoing response payloads using JSON Schema (draft-07) under the `schema.response` property of a route options object. Unlike request-side validation — which rejects invalid input with `400` — response validation serves a different dual purpose: it catches unintended data leaks by stripping undeclared properties, and it accelerates serialization by allowing Fastify to use a fast serializer instead of the default `JSON.stringify`.

Response schemas are keyed by HTTP status code, allowing different shapes to be defined for success and error responses on the same route.

---

#### Attaching a Response Schema

js

```
fastify.get('/users/:id', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          id:       { type: 'integer' },
          username: { type: 'string' },
          email:    { type: 'string' }
        }
      }
    }
  }
}, async (request, reply) => {
  return {
    id: 1,
    username: 'alice',
    email: 'alice@example.com',
    passwordHash: 'secret'   // not in schema — stripped from output
  }
})
```

**Key Points**

- Properties not declared in the response schema are stripped from the output before serialization. This is the default behavior when using Fastify's built-in serializer (`fast-json-stringify`).
- This stripping behavior is a serialization concern, not a validation error. No error is thrown for undeclared properties — they are silently omitted.
- `passwordHash` does not appear in the response even though the handler returned it.

---

#### How Response Serialization Differs from Request Validation

| Aspect | Request validation | Response serialization |
| --- | --- | --- |
| Mechanism | Ajv (JSON Schema validation) | `fast-json-stringify` |
| On failure | `400 Bad Request` returned | Varies — see below |
| Extra properties | Rejected (if `additionalProperties: false`) | Silently stripped |
| Purpose | Reject invalid input | Accelerate output + strip sensitive fields |
| Errors visible to client | Yes | Not directly |

> [Inference] The distinction between validation and serialization is important: response schemas primarily drive serialization behavior. Whether a type mismatch in a response causes an error or silent coercion depends on the serializer and configuration. Behavior is not guaranteed to be consistent across versions.

---

#### Status Code Keys

The `response` object is keyed by HTTP status code as a string or number. Each key maps to a schema for that status.

js

```
schema: {
  response: {
    200: {
      type: 'object',
      properties: {
        id:   { type: 'integer' },
        name: { type: 'string' }
      }
    },
    201: {
      type: 'object',
      properties: {
        id:      { type: 'integer' },
        created: { type: 'boolean' }
      }
    },
    404: {
      type: 'object',
      properties: {
        message: { type: 'string' }
      }
    }
  }
}
```

**Key Points**

- Only responses matching a declared status code are serialized using the schema. Responses with undeclared status codes fall back to standard `JSON.stringify`.
- Defining schemas for error status codes (`400`, `404`, `500`) is optional but useful for consistent error shape documentation and serialization.

---

#### The `2xx` Wildcard

Fastify supports `2xx` as a wildcard key that matches any `2xx` status code not explicitly declared.

js

```
schema: {
  response: {
    '2xx': {
      type: 'object',
      properties: {
        success: { type: 'boolean' },
        data:    { type: 'object' }
      }
    },
    400: {
      type: 'object',
      properties: {
        message: { type: 'string' }
      }
    }
  }
}
```

> [Inference] Wildcard matching behavior (`2xx`, `3xx`, etc.) is supported in Fastify but the exact precedence rules when both a wildcard and a specific code are declared should be verified against the version in use.

---

#### Serialization Performance

When a response schema is defined, Fastify uses `fast-json-stringify` instead of `JSON.stringify`. This library generates a serialization function from the schema at startup, which is typically faster than generic JSON serialization for structured objects.

> [Inference] Performance gains from `fast-json-stringify` depend on payload structure, object complexity, and runtime conditions. Actual improvements should be measured under realistic load for the specific use case. Gains are not guaranteed in all scenarios.

---

#### Property Stripping Behavior

Properties not listed in the response schema are removed from the serialized output. This applies recursively to nested objects when their schemas are also declared.

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
            id:   { type: 'integer' },
            name: { type: 'string' }
            // role and passwordHash not declared
          }
        }
      }
    }
  }
}
```

**Handler returns:**

js

```
{
  user: {
    id: 1,
    name: 'alice',
    role: 'admin',         // stripped
    passwordHash: 'secret' // stripped
  }
}
```

**Serialized output:**

json

```
{
  "user": {
    "id": 1,
    "name": "alice"
  }
}
```

> This stripping behavior is a reliable mechanism for preventing accidental data exposure, but it depends on the serializer being active. If a custom serializer or `reply.serialize()` is used differently, behavior may vary.

---

#### Array Responses

The response schema can declare an array at the top level.

js

```
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
```

Each item in the array is serialized according to the `items` schema. Properties not declared in `items` are stripped from each element.

---

#### Nullable Fields

To allow a property to be either a value or `null`, use an array of types or the `nullable` keyword depending on the Fastify and Ajv version in use.

js

```
// JSON Schema draft-07 approach
properties: {
  nickname: { type: ['string', 'null'] }
}
```

js

```
// OpenAPI-style nullable (requires compatible plugin or configuration)
properties: {
  nickname: { type: 'string', nullable: true }
}
```

> [Inference] The `nullable` keyword is not standard JSON Schema draft-07. Its support depends on Ajv plugins or OpenAPI integration (such as `@fastify/swagger`). Use `type: ['string', 'null']` for standard compatibility. Verify behavior against the specific setup in use.

---

#### Using `$ref` in Response Schemas

Shared response shapes can be registered and referenced.

js

```
fastify.addSchema({
  $id: 'UserResponse',
  type: 'object',
  properties: {
    id:       { type: 'integer' },
    username: { type: 'string' },
    email:    { type: 'string' }
  }
})

fastify.get('/users/:id', {
  schema: {
    response: {
      200: { $ref: 'UserResponse#' }
    }
  }
}, async (request, reply) => {
  return { id: 1, username: 'alice', email: 'alice@example.com', passwordHash: 'x' }
})
```

---

#### Response Schema and Error Handlers

Response schemas apply to responses sent by the handler. They do not automatically apply to errors thrown or sent by Fastify's internal error handler (such as validation errors, `404`s, or uncaught exceptions).

To control the shape of error responses, a custom `errorHandler` or dedicated error status schemas can be used.

js

```
fastify.setErrorHandler((error, request, reply) => {
  reply.status(error.statusCode || 500).send({
    message: error.message
  })
})
```

> [Inference] Whether a response schema defined for `400` or `500` applies to errors sent via `setErrorHandler` depends on how the reply is constructed and whether the serializer is invoked. This should be tested against the specific Fastify version in use.

---

#### Disabling Response Serialization per Route

Response serialization can be bypassed on a per-reply basis using `reply.serializer()` or by passing a custom serializer function.

js

```
fastify.get('/raw', async (request, reply) => {
  reply.serializer(JSON.stringify)
  return { anything: true, extra: 'not stripped' }
})
```

This disables schema-based stripping and fast serialization for that response.

---

#### Composing a Full Route Schema

js

```
fastify.post('/articles', {
  schema: {
    body: {
      type: 'object',
      required: ['title', 'content'],
      properties: {
        title:   { type: 'string' },
        content: { type: 'string' },
        tags:    { type: 'array', items: { type: 'string' } }
      }
    },
    response: {
      201: {
        type: 'object',
        properties: {
          id:        { type: 'integer' },
          title:     { type: 'string' },
          createdAt: { type: 'string', format: 'date-time' }
        }
      },
      400: {
        type: 'object',
        properties: {
          message: { type: 'string' }
        }
      }
    }
  }
}, async (request, reply) => {
  const article = await createArticle(request.body)
  reply.status(201).send(article)
})
```

---

#### Flow Summary

```
Handler returns payload
        │
        ▼
  Status code determined
        │
        ▼
  Matching response schema found?
        │
   ┌────┴──────────────────────┐
   │ No                         │ Yes
   ▼                            ▼
JSON.stringify              fast-json-stringify
(standard serialization)    (schema-driven serialization)
                                 │
                                 ▼
                         Undeclared properties stripped
                                 │
                                 ▼
                         Serialized response sent to client
```

---

#### Summary of Key Behaviors

| Behavior | Details |
| --- | --- |
| Undeclared properties | Silently stripped from output |
| Serializer used | `fast-json-stringify` when schema present |
| Fallback (no schema) | `JSON.stringify` |
| On type mismatch in output | Behavior depends on serializer; may coerce or omit |
| Error responses | Not automatically covered; require explicit status code schemas or custom error handler |
| Wildcard status codes | `2xx` and similar wildcards supported |

---

**Conclusion**

Response schemas in Fastify serve two distinct purposes: accelerating serialization via `fast-json-stringify` and stripping undeclared properties to prevent accidental data leakage. Unlike request-side validation, response schema violations do not produce client-visible errors — extra fields are silently removed. Defining schemas per status code gives fine-grained control over response shape for both success and error cases. Understanding the boundary between serialization behavior and validation behavior is essential to using response schemas reliably.
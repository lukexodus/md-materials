### Params Validation Schema

#### Overview

Fastify validates URL path parameters using JSON Schema (draft-07) under the `schema.params` property of a route options object. Path parameters are the named segments of a URL pattern prefixed with `:`, such as `/users/:id` or `/posts/:postId/comments/:commentId`.

Like other schema sections, params schemas are compiled by Ajv at startup. Validation runs before the handler is called.

---

#### Defining URL Parameters

Path parameters are declared in the route URL using `:paramName` syntax. Fastify extracts them and makes them available on `request.params`.

js

```
fastify.get('/users/:id', {
  schema: {
    params: {
      type: 'object',
      required: ['id'],
      properties: {
        id: { type: 'integer' }
      }
    }
  }
}, async (request, reply) => {
  const { id } = request.params
  return { userId: id }
})
```

**Key Points**

- All path parameter values arrive as strings from the URL. Coercion converts them to declared types when Ajv's `coerceTypes` is enabled — which Fastify enables by default.
- `required` is technically redundant for path parameters since they must be present for the route to match at all. It is nevertheless common practice to include them for explicitness and documentation purposes.

---

#### Coercion Behavior

As with query strings, URL segments are inherently strings. Coercion is essential when schemas declare non-string types.

| Raw URL segment | Schema type | Coerced result |
| --- | --- | --- |
| `"42"` | `integer` | `42` |
| `"3.14"` | `number` | `3.14` |
| `"abc"` | `string` | `"abc"` |

**Example** — route with integer ID:

```
GET /users/42     → request.params.id === 42   (integer)
GET /users/abc    → 400 Bad Request (cannot coerce "abc" to integer)
```

> [Inference] Coercion is performed by Ajv based on its documented `coerceTypes` option. Behavior may vary across Ajv versions or when `coerceTypes` is explicitly disabled.

---

#### Multiple Path Parameters

Routes can define multiple named segments, each independently validated.

js

```
fastify.get('/posts/:postId/comments/:commentId', {
  schema: {
    params: {
      type: 'object',
      properties: {
        postId:    { type: 'integer', minimum: 1 },
        commentId: { type: 'integer', minimum: 1 }
      }
    }
  }
}, async (request, reply) => {
  const { postId, commentId } = request.params
  return { postId, commentId }
})
```

All declared parameter constraints are validated simultaneously. If any parameter fails, Fastify returns `400` before the handler runs.

---

#### Validation Failure Response

When a path parameter fails schema validation, Fastify responds with `400 Bad Request`.

**Example** — request to an endpoint expecting an integer:

```
GET /users/not-a-number
```

**Output** — default error response:

json

```
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "params/id must be integer"
}
```

The exact message format depends on Ajv version and any custom error formatting applied.

---

#### String Constraints on Path Parameters

When the parameter is expected to remain a string, constraints such as `pattern`, `minLength`, `maxLength`, and `enum` are applicable.

js

```
fastify.get('/files/:filename', {
  schema: {
    params: {
      type: 'object',
      properties: {
        filename: {
          type: 'string',
          pattern: '^[a-zA-Z0-9_-]+\\.pdf$'
        }
      }
    }
  }
}, async (request, reply) => {
  return { file: request.params.filename }
})
```

**Key Points**

- `pattern` uses a regular expression string (not a regex literal).
- A request to `/files/report.exe` would fail validation because it does not match the pattern.
- Pattern matching behavior is subject to the regex engine used by Ajv.

---

#### Using `enum` to Restrict Parameter Values

`enum` restricts a parameter to a fixed set of allowed values.

js

```
fastify.get('/reports/:type', {
  schema: {
    params: {
      type: 'object',
      properties: {
        type: {
          type: 'string',
          enum: ['summary', 'detailed', 'raw']
        }
      }
    }
  }
}, async (request, reply) => {
  return { reportType: request.params.type }
})
```

A request to `/reports/unknown` returns `400` because `"unknown"` is not in the enum.

> This is an alternative to defining separate routes for each variant, though route-level separation may be preferable when handlers differ significantly.

---

#### Using `$ref` for Reusable Param Schemas

Common parameter definitions such as a numeric ID can be registered once and reused.

js

```
fastify.addSchema({
  $id: 'NumericId',
  type: 'object',
  properties: {
    id: { type: 'integer', minimum: 1 }
  }
})

fastify.get('/users/:id', {
  schema: { params: { $ref: 'NumericId#' } }
}, async (request, reply) => {
  return { userId: request.params.id }
})

fastify.delete('/users/:id', {
  schema: { params: { $ref: 'NumericId#' } }
}, async (request, reply) => {
  return { deleted: request.params.id }
})
```

---

#### Wildcard and Regex Routes

Fastify supports wildcard segments and regex-constrained parameters at the routing level, independently of schema validation.

js

```
// Wildcard — matches /files/any/path/here
fastify.get('/files/*', async (request, reply) => {
  return { path: request.params['*'] }
})
```

For regex-constrained parameters, Fastify uses a `:param(regex)` syntax:

js

```
// Only matches if :id consists of digits
fastify.get('/items/:id(^\\d+$)', async (request, reply) => {
  return { id: request.params.id }
})
```

**Key Points**

- Router-level regex constraints are applied by `find-my-way` (Fastify's router) before schema validation runs.
- Schema validation and router-level constraints serve different purposes and can be used independently or together.
- Combining both provides defense in depth. [Inference]

---

#### Combining `params` with Other Schema Sections

Params schemas compose naturally with `querystring`, `body`, and `response` schemas.

js

```
fastify.put('/users/:id', {
  schema: {
    params: {
      type: 'object',
      properties: {
        id: { type: 'integer', minimum: 1 }
      }
    },
    body: {
      type: 'object',
      required: ['email'],
      properties: {
        email: { type: 'string', format: 'email' },
        name:  { type: 'string' }
      }
    }
  }
}, async (request, reply) => {
  const { id } = request.params
  const { email, name } = request.body
  return { id, email, name }
})
```

All schema sections are validated before the handler is invoked. The order in which Fastify validates sections internally is not guaranteed to be consistent across versions. [Inference]

---

#### Flow Summary

```
Incoming Request URL
        │
        ▼
  Route matched by find-my-way
  (router-level regex applied here, if any)
        │
        ▼
  Path segments extracted → request.params (raw strings)
        │
        ▼
  Ajv validation against schema.params
  (coercion applied for non-string types)
        │
   ┌────┴──────────────────┐
   │ Invalid                │ Valid
   ▼                        ▼
400 Bad Request         Handler called
                        (request.params available,
                         types coerced per schema)
```

---

#### Common Keywords for Params Schemas

| Keyword | Applicable types | Purpose |
| --- | --- | --- |
| `type` | all | Declares expected type after coercion |
| `minimum` / `maximum` | integer, number | Numeric range constraint |
| `enum` | string, integer | Restricts to a fixed set of values |
| `pattern` | string | Regex constraint |
| `minLength` / `maxLength` | string | Length constraint |

---

**Conclusion**

Params validation in Fastify mirrors the approach used for query strings and body validation — JSON Schema defined under `schema.params`, compiled at startup, and enforced by Ajv before the handler runs. The primary practical consideration is coercion: URL segments are always raw strings, so schemas declaring numeric or boolean types depend on `coerceTypes` being active. For reusable patterns like numeric IDs, `$ref` reduces duplication across routes. Router-level regex constraints via `find-my-way` and schema-level validation are complementary tools that can be used together.
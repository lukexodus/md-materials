### Query String Validation Schema

#### Overview

Fastify validates query string parameters using JSON Schema (draft-07), the same mechanism used for body validation. The schema is defined under `schema.querystring` in a route's options object. Like body schemas, query string schemas are compiled by Ajv at startup, not per request.

Query string validation applies to any HTTP method — `GET`, `DELETE`, `POST`, etc. — whenever the route expects parameters passed in the URL after `?`.

---

#### Attaching a Query String Schema

js

```
fastify.get('/search', {
  schema: {
    querystring: {
      type: 'object',
      required: ['q'],
      properties: {
        q:    { type: 'string', minLength: 1 },
        page: { type: 'integer', minimum: 1, default: 1 },
        limit:{ type: 'integer', minimum: 1, maximum: 100, default: 20 }
      },
      additionalProperties: false
    }
  }
}, async (request, reply) => {
  const { q, page, limit } = request.query
  return { q, page, limit }
})
```

**Key Points**

- Validated parameters are accessible via `request.query`.
- `default` values are applied when Ajv's `useDefaults` is enabled — which Fastify enables by default. Behavior may vary depending on configuration.
- `additionalProperties: false` rejects unrecognized query parameters.

---

#### Coercion Is Critical for Query Strings

All query string values arrive as strings after URL parsing. For example, `?page=2&active=true` yields `{ page: "2", active: "true" }` before any processing.

Fastify enables Ajv's `coerceTypes` by default, which converts these strings to their declared types.

| Raw query value | Schema type | Coerced result |
| --- | --- | --- |
| `"2"` | `integer` | `2` |
| `"3.14"` | `number` | `3.14` |
| `"true"` | `boolean` | `true` |
| `"false"` | `boolean` | `false` |

> [Inference] Coercion is performed by Ajv based on its documented `coerceTypes` behavior. Actual results may vary across Ajv versions or custom configurations. This behavior is not guaranteed to be consistent if `coerceTypes` is disabled.

**Without coercion**, a schema declaring `page` as `integer` would reject `"2"` as invalid, since it is a string. If strict typing is required and coercion is undesirable, an alternative is to declare all parameters as `type: 'string'` and convert them manually in the handler.

---

#### Required vs Optional Parameters

js

```
querystring: {
  type: 'object',
  required: ['status'],
  properties: {
    status:   { type: 'string', enum: ['active', 'inactive', 'pending'] },
    sort:     { type: 'string', enum: ['asc', 'desc'], default: 'asc' },
    page:     { type: 'integer', minimum: 1, default: 1 }
  }
}
```

**Key Points**

- Only `status` is required here. Omitting `sort` or `page` results in defaults being applied (when `useDefaults` is active).
- `enum` restricts a parameter to a fixed set of values. Any value outside the enum causes a `400` response.

---

#### Validation Failure Response

When a query string parameter fails validation, Fastify responds with `400 Bad Request` before the handler executes.

**Example** — request with an invalid parameter:

```
GET /search?page=abc
```

**Output** — default error:

json

```
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "querystring/page must be integer"
}
```

The exact message format depends on the Ajv version and Fastify's error serializer configuration.

---

#### Deprecated `query` Key

Earlier Fastify documentation and some examples use `schema.query` instead of `schema.querystring`. Both have been supported, but `schema.querystring` is the current canonical key.

> [Inference] Using `schema.query` may still work in current Fastify versions, but relying on it is not recommended as behavior could change. Verify against the version of Fastify in use.

---

#### Array Parameters in Query Strings

Query strings can represent arrays in several notations depending on how the HTTP client sends them:

```
?tag=node&tag=fastify        → { tag: ['node', 'fastify'] }
?tag[]=node&tag[]=fastify    → depends on parser configuration
```

Fastify uses the `fast-querystring` parser by default. To handle repeated keys as arrays, the schema should declare the property as an array type.

js

```
querystring: {
  type: 'object',
  properties: {
    tag: {
      type: 'array',
      items: { type: 'string' }
    }
  }
}
```

> [Inference] Whether repeated query keys are automatically parsed into arrays depends on the query string parser in use. The default parser behavior should be verified against the specific Fastify version. Behavior is not guaranteed to be consistent across parser configurations.

A custom query string parser can be provided via the `querystringParser` option when instantiating Fastify:

js

```
const fastify = require('fastify')({
  querystringParser: str => require('qs').parse(str)
})
```

---

#### Using `$ref` for Reusable Query Schemas

Shared query string schemas can be registered with `addSchema` and referenced with `$ref`, following the same pattern as body schemas.

js

```
fastify.addSchema({
  $id: 'Pagination',
  type: 'object',
  properties: {
    page:  { type: 'integer', minimum: 1, default: 1 },
    limit: { type: 'integer', minimum: 1, maximum: 100, default: 20 }
  }
})

fastify.get('/posts', {
  schema: {
    querystring: { $ref: 'Pagination#' }
  }
}, async (request, reply) => {
  return request.query
})

fastify.get('/comments', {
  schema: {
    querystring: { $ref: 'Pagination#' }
  }
}, async (request, reply) => {
  return request.query
})
```

---

#### Combining with Other Schema Sections

Query string schemas compose with body, params, headers, and response schemas within the same route.

js

```
fastify.post('/items', {
  schema: {
    querystring: {
      type: 'object',
      properties: {
        dryRun: { type: 'boolean', default: false }
      }
    },
    body: {
      type: 'object',
      required: ['name'],
      properties: {
        name:  { type: 'string' },
        price: { type: 'number' }
      }
    }
  }
}, async (request, reply) => {
  const { dryRun } = request.query
  const { name, price } = request.body
  return { dryRun, name, price }
})
```

---

#### Flow Summary

```
Incoming Request URL
        │
        ▼
  Query string parsed
  (fast-querystring or custom parser)
        │
        ▼
  Ajv validation against schema.querystring
        │
   ┌────┴──────────────────┐
   │ Invalid                │ Valid
   ▼                        ▼
400 Bad Request         Handler called
                        (request.query available,
                         coercion + defaults applied)
```

---

#### Summary of Schema Properties Commonly Used

| Keyword | Purpose |
| --- | --- |
| `type` | Declares expected type after coercion |
| `required` | Lists mandatory parameters |
| `enum` | Restricts to a fixed set of values |
| `default` | Applied when parameter is absent (requires `useDefaults`) |
| `minimum` / `maximum` | Numeric range constraints |
| `minLength` / `maxLength` | String length constraints |
| `pattern` | Regex constraint on string values |
| `additionalProperties` | Controls handling of unrecognized parameters |

---

**Conclusion**

Query string validation in Fastify follows the same JSON Schema pattern as body validation, with one important practical difference: all incoming values are strings until coercion is applied. Understanding coercion behavior, array parsing, and the role of `default` values is essential for writing reliable query string schemas. Reuse via `$ref` and composition with other schema sections keeps route definitions maintainable as an API grows.
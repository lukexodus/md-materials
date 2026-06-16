### Headers Validation Schema

#### Overview

Fastify validates incoming request headers using JSON Schema (draft-07) under the `schema.headers` property of a route options object. Header validation follows the same compilation and enforcement model as body, query string, and params validation — schemas are compiled by Ajv at startup and evaluated before the handler is called.

Header validation is less commonly applied than body or query string validation, but it is useful for enforcing the presence of authentication tokens, API keys, content negotiation headers, and custom application headers.

---

#### Attaching a Headers Schema

js

```
fastify.post('/data', {
  schema: {
    headers: {
      type: 'object',
      required: ['x-api-key'],
      properties: {
        'x-api-key':    { type: 'string', minLength: 32 },
        'x-request-id': { type: 'string' },
        'accept':       { type: 'string' }
      }
    }
  }
}, async (request, reply) => {
  const apiKey = request.headers['x-api-key']
  return { received: true }
})
```

**Key Points**

- Header names in HTTP/1.1 are case-insensitive by specification. Node.js normalizes incoming header names to lowercase before Fastify processes them. Schema property names should therefore be lowercase.
- `required` enforces that listed headers must be present. Missing required headers trigger a `400` response before the handler runs.
- `additionalProperties: false` is generally not recommended for headers schemas — HTTP clients and proxies routinely add standard headers (`host`, `connection`, `content-length`, etc.) that are not application-defined. Blocking them would cause unexpected failures.

---

#### HTTP/2 Header Casing

In HTTP/2, header names are required by the protocol to be lowercase. Node.js also lowercases HTTP/1.1 headers internally. Schema property names should always be lowercase regardless of protocol version.

> [Inference] If a header arrives with mixed casing from a non-compliant client or intermediary, Node.js normalization should still lowercase it before Fastify sees it. Behavior in edge cases involving proxies or custom parsers may vary.

---

#### Validation Failure Response

When a required header is absent or a header value fails its constraint, Fastify returns `400 Bad Request`.

**Example** — missing required header:

```
POST /data
(no x-api-key header)
```

**Output** — default error response:

json

```
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "headers must have required property 'x-api-key'"
}
```

The exact message format depends on Ajv version and any custom error serializer in use.

---

#### Coercion in Headers

Like query strings and params, all header values arrive as strings. Fastify enables Ajv's `coerceTypes` by default, so numeric or boolean header values declared in the schema are coerced from their string representations.

| Raw header value | Schema type | Coerced result |
| --- | --- | --- |
| `"42"` | `integer` | `42` |
| `"true"` | `boolean` | `true` |
| `"3.14"` | `number` | `3.14` |

> [Inference] Coercing header values to non-string types is uncommon in practice since HTTP headers are inherently string-valued. Coercion behavior depends on Ajv's `coerceTypes` configuration and may vary across versions.

In most real-world cases, headers are validated as `type: 'string'` with constraints such as `pattern`, `minLength`, or `enum`.

---

#### Common Header Validation Patterns

##### API Key Enforcement

js

```
headers: {
  type: 'object',
  required: ['x-api-key'],
  properties: {
    'x-api-key': {
      type: 'string',
      minLength: 32,
      maxLength: 64
    }
  }
}
```

##### Bearer Token Presence Check

js

```
headers: {
  type: 'object',
  required: ['authorization'],
  properties: {
    authorization: {
      type: 'string',
      pattern: '^Bearer .+'
    }
  }
}
```

> [Inference] This pattern checks format only — it does not verify the token's authenticity or expiry. Token verification requires additional logic in the handler or a dedicated authentication hook.

##### Content-Type Constraint

js

```
headers: {
  type: 'object',
  required: ['content-type'],
  properties: {
    'content-type': {
      type: 'string',
      enum: [
        'application/json',
        'application/json; charset=utf-8'
      ]
    }
  }
}
```

> [Inference] Fastify handles `Content-Type` parsing independently for body deserialization. Schema-level validation of `content-type` is an additional check and does not replace Fastify's internal content-type handling. Behavior when both mechanisms interact should be verified against the Fastify version in use.

##### Custom Versioning Header

js

```
headers: {
  type: 'object',
  required: ['x-api-version'],
  properties: {
    'x-api-version': {
      type: 'string',
      enum: ['v1', 'v2', 'v3']
    }
  }
}
```

---

#### Why `additionalProperties: false` Is Problematic for Headers

Setting `additionalProperties: false` on a headers schema requires every header sent by the client to be explicitly listed in `properties`. Standard headers appended automatically by HTTP clients, Node.js, load balancers, or proxies — such as `host`, `connection`, `user-agent`, `accept-encoding`, `content-length` — would all cause validation failures unless declared.

This makes `additionalProperties: false` impractical for headers in most deployments.

**Alternatives:**

- Omit `additionalProperties` entirely (defaults to `true`).
- Use only `required` and per-property constraints to validate what matters.
- Apply stricter validation in controlled environments where header sets are known and stable.

---

#### Headers Validation vs Authentication Hooks

Header validation via `schema.headers` confirms that a header is present and matches a structural constraint. It does not:

- Verify token signatures or expiry
- Query a database or external service
- Implement access control logic

For authentication and authorization, Fastify's `onRequest` or `preHandler` hooks are the appropriate mechanism. Schema-level header validation and lifecycle hooks are complementary.

```
schema.headers        →  Is the header present and well-formed?
onRequest hook        →  Is the token valid and the user authenticated?
preHandler hook       →  Is the user authorized for this resource?
```

---

#### Using `$ref` for Reusable Header Schemas

Shared header requirements can be registered once and reused across routes.

js

```
fastify.addSchema({
  $id: 'CommonHeaders',
  type: 'object',
  required: ['x-api-key'],
  properties: {
    'x-api-key':    { type: 'string', minLength: 32 },
    'x-request-id': { type: 'string' }
  }
})

fastify.get('/resource-a', {
  schema: { headers: { $ref: 'CommonHeaders#' } }
}, async (request, reply) => {
  return { resource: 'a' }
})

fastify.get('/resource-b', {
  schema: { headers: { $ref: 'CommonHeaders#' } }
}, async (request, reply) => {
  return { resource: 'b' }
})
```

---

#### Composing Headers with Other Schema Sections

js

```
fastify.post('/orders', {
  schema: {
    headers: {
      type: 'object',
      required: ['x-api-key', 'x-idempotency-key'],
      properties: {
        'x-api-key':        { type: 'string' },
        'x-idempotency-key':{ type: 'string', format: 'uuid' }
      }
    },
    body: {
      type: 'object',
      required: ['product', 'quantity'],
      properties: {
        product:  { type: 'string' },
        quantity: { type: 'integer', minimum: 1 }
      }
    }
  }
}, async (request, reply) => {
  return { order: request.body, key: request.headers['x-idempotency-key'] }
})
```

---

#### Flow Summary

```
Incoming Request
        │
        ▼
  Node.js normalizes header names to lowercase
        │
        ▼
  Ajv validation against schema.headers
        │
   ┌────┴──────────────────┐
   │ Invalid                │ Valid
   ▼                        ▼
400 Bad Request         Proceeds to next
                        validation stage
                        (body, params, querystring)
                        then handler
```

> [Inference] The order in which Fastify internally validates schema sections (headers, params, querystring, body) is not explicitly guaranteed in all documentation. The above reflects commonly observed behavior and may vary across versions.

---

#### Summary of Practical Constraints for Headers

| Constraint | Recommended | Notes |
| --- | --- | --- |
| `required` | Yes | Enforce presence of application-defined headers |
| `type: 'string'` | Yes | Headers are string-valued by nature |
| `pattern` | Yes | Useful for format checks like Bearer tokens |
| `enum` | Yes | Useful for versioning or content-type constraints |
| `minLength` / `maxLength` | Yes | Bounds checking on token or key length |
| `additionalProperties: false` | Avoid | Causes failures on standard HTTP headers |
| `coerceTypes` to non-string | Uncommon | Headers are strings; coercion to other types is rarely needed |

---

**Conclusion**

Headers validation in Fastify uses the same JSON Schema mechanism as other request components, with two important practical distinctions: header names must be lowercase to match Node.js normalization behavior, and `additionalProperties: false` should be avoided due to standard headers added by clients and infrastructure. For most use cases, `schema.headers` is best used to enforce presence and basic format of application-defined headers, while authentication logic belongs in lifecycle hooks.
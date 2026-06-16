### Body Validation Schema in Fastify

#### Overview

Fastify uses JSON Schema (draft-07) to validate incoming request bodies. When a schema is attached to a route, Fastify compiles it into a validator function at startup — not at request time. This means validation overhead is minimized during the request lifecycle.

Body validation applies to routes that accept a request body: typically `POST`, `PUT`, and `PATCH`.

---

#### Attaching a Body Schema to a Route

Body schemas are defined under the `schema.body` property of a route options object.

js

```
fastify.post('/user', {
  schema: {
    body: {
      type: 'object',
      required: ['username', 'email'],
      properties: {
        username: { type: 'string' },
        email:    { type: 'string', format: 'email' },
        age:      { type: 'integer', minimum: 0 }
      },
      additionalProperties: false
    }
  }
}, async (request, reply) => {
  return { received: request.body }
})
```

**Key Points**

- `required` lists fields that must be present.
- `additionalProperties: false` rejects any field not listed in `properties`. This behavior depends on the validator implementation and may vary.
- Fastify uses [Ajv](https://ajv.js.org/) as its default validator.

---

#### What Happens When Validation Fails

When the incoming body does not satisfy the schema, Fastify automatically responds with a `400 Bad Request` before the handler is called.

**Example** — sending an invalid body:

json

```
POST /user
{
  "username": 42,
  "email": "not-an-email"
}
```

**Output** — default error response:

json

```
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "body/username must be string"
}
```

The error message is produced by Ajv and formatted by Fastify's default error handler. The exact message format may vary depending on Ajv version and configuration.

---

#### Required vs Optional Fields

Fields listed in `required` must be present in the body. Fields defined only in `properties` but absent from `required` are optional.

js

```
body: {
  type: 'object',
  required: ['title'],
  properties: {
    title:       { type: 'string' },
    description: { type: 'string' },  // optional
    priority:    { type: 'integer', default: 1 }
  }
}
```

**Key Points**

- `default` values in JSON Schema do not automatically populate `request.body` unless Ajv's `useDefaults` option is enabled. [Inference: this is Ajv's behavior based on its documented options; actual behavior may vary based on configuration]
- Fastify enables `useDefaults: true` by default in its Ajv configuration, so defaults are typically applied.

---

#### Nested Object Validation

Schemas can describe arbitrarily nested structures.

js

```
body: {
  type: 'object',
  required: ['user'],
  properties: {
    user: {
      type: 'object',
      required: ['name'],
      properties: {
        name: { type: 'string' },
        address: {
          type: 'object',
          properties: {
            city:    { type: 'string' },
            country: { type: 'string' }
          }
        }
      }
    }
  }
}
```

---

#### Array Body Validation

The body itself can be typed as an array when the endpoint expects a list.

js

```
fastify.post('/tags', {
  schema: {
    body: {
      type: 'array',
      items: {
        type: 'object',
        required: ['name'],
        properties: {
          name:  { type: 'string' },
          color: { type: 'string' }
        }
      },
      minItems: 1
    }
  }
}, async (request, reply) => {
  return { count: request.body.length }
})
```

---

#### Using `$ref` for Reusable Schemas

Rather than duplicating schema definitions across routes, shared schemas can be registered and referenced with `$ref`.

js

```
fastify.addSchema({
  $id: 'UserBody',
  type: 'object',
  required: ['username', 'email'],
  properties: {
    username: { type: 'string' },
    email:    { type: 'string', format: 'email' }
  }
})

fastify.post('/register', {
  schema: {
    body: { $ref: 'UserBody#' }
  }
}, async (request, reply) => {
  return { ok: true }
})
```

**Key Points**

- `$id` must be unique across all registered schemas.
- The `#` at the end of the `$ref` value refers to the root of the referenced schema.
- Schemas registered with `addSchema` are scoped — availability depends on where in the plugin hierarchy they are registered.

---

#### `additionalProperties` Behavior

| Setting | Behavior |
| --- | --- |
| `additionalProperties: false` | Extra fields cause validation failure |
| `additionalProperties: true` (default) | Extra fields are allowed and passed through |
| `additionalProperties: { type: 'string' }` | Extra fields allowed only if they match the given type |

> Behavior depends on the Ajv version and any custom validator configuration applied. Results may vary.

---

#### Coercion

By default, Fastify enables Ajv's `coerceTypes` option. This means a string `"42"` may be coerced into the integer `42` if the schema specifies `type: integer`.

**Key Points**

- Coercion applies to body fields when the parsed body contains string representations of other types.
- This behavior may be surprising and is worth disabling explicitly if strict type checking is required.
- To disable: pass custom Ajv options when instantiating Fastify.

js

```
const fastify = require('fastify')({
  ajv: {
    customOptions: {
      coerceTypes: false
    }
  }
})
```

> [Inference] Disabling coercion causes stricter validation; actual behavior depends on the Ajv version bundled with your Fastify version.

---

#### Custom Validation Error Messages

Fastify does not natively support per-field custom error messages in JSON Schema. Options include:

- **`ajv-errors`** plugin — allows `errorMessage` keywords in schemas.
- **`setSchemaErrorFormatter`** — a Fastify method to customize the error object returned on validation failure.
- A custom `errorHandler` to intercept and reformat `400` errors.

**Example** — using `setSchemaErrorFormatter`:

js

```
fastify.setSchemaErrorFormatter((errors, dataVar) => {
  return new Error(`Validation failed: ${errors.map(e => e.message).join(', ')}`)
})
```

> [Inference] The exact shape of the `errors` array follows Ajv's error object structure; this may change across versions.

---

#### Content-Type Requirement

Body validation only runs when Fastify successfully parses the request body. Fastify parses `application/json` bodies by default. If the `Content-Type` header is missing or unsupported, the body may not be parsed and validation may not run as expected.

> [Inference] Sending a body without `Content-Type: application/json` may result in an unparsed body or a parsing error rather than a schema validation error.

---

#### Flow Summary

```
Incoming Request
      │
      ▼
Content-Type check → parse body
      │
      ▼
Schema validation (Ajv)
      │
   ┌──┴──────────────┐
   │ Invalid          │ Valid
   ▼                  ▼
400 Bad Request    Handler called
                   (request.body available)
```

---

**Conclusion**

Body validation in Fastify is schema-driven and compiled ahead of time, keeping per-request cost low. Defining schemas under `schema.body` with JSON Schema draft-07 syntax gives control over required fields, types, nesting, and additional property handling. Understanding coercion, `$ref` reuse, and error customization covers most practical needs when building validated API endpoints.
### Reusing Schemas with $ref and $id

Fastify integrates with JSON Schema's `$ref` and `$id` keywords to allow schema reuse across routes. Instead of duplicating schema definitions, you can define a schema once, register it, and reference it anywhere in your application.

---

#### Why Reuse Schemas

Duplicating schemas across routes introduces inconsistency risks and maintenance overhead. Centralizing shared definitions — such as a `User` object or a pagination shape — means changes propagate automatically to every route that references them.

---

#### How $id Works

The `$id` keyword assigns a unique identifier to a JSON Schema. Fastify uses this identifier as a lookup key when resolving `$ref` pointers.

json

```
{
  "$id": "User",
  "type": "object",
  "properties": {
    "id":    { "type": "integer" },
    "name":  { "type": "string" },
    "email": { "type": "string", "format": "email" }
  },
  "required": ["id", "name", "email"]
}
```

**Key Points**

- `$id` is a plain string in Fastify's shared schema registry — it does not need to be a URI, though URI-style values are valid JSON Schema.
- The value must be unique within the Fastify instance's schema registry.
- [Inference] Fastify's schema compiler resolves `$ref` values by matching against registered `$id` strings; behavior may vary depending on the underlying validation library (default: `@fastify/ajv-compiler` with Ajv).

---

#### Registering a Shared Schema

Use `fastify.addSchema()` to register a schema before it is referenced.

js

```
fastify.addSchema({
  $id: 'User',
  type: 'object',
  properties: {
    id:    { type: 'integer' },
    name:  { type: 'string' },
    email: { type: 'string', format: 'email' }
  },
  required: ['id', 'name', 'email']
})
```

**Key Points**

- `addSchema()` must be called before the route that references it is registered.
- A schema with a duplicate `$id` will cause Fastify to throw at startup.
- Schemas added to a parent Fastify instance are available to all child plugins.

---

#### Referencing with $ref

Once a schema is registered, any other schema in the same instance can reference it using `$ref`.

js

```
fastify.get('/user/:id', {
  schema: {
    response: {
      200: { $ref: 'User#' }
    }
  }
}, async (request, reply) => {
  return { id: 1, name: 'Ada', email: 'ada@example.com' }
})
```

The `#` fragment at the end of `'User#'` refers to the root of the `User` schema. You can also point to a nested definition using a JSON Pointer fragment.

js

```
// References only the 'email' property definition
{ $ref: 'User#/properties/email' }
```

---

#### Referencing Nested Definitions with JSON Pointer

JSON Pointer syntax (`/`-separated path) after `#` allows pinpointing a sub-schema within a registered document.

js

```
fastify.addSchema({
  $id: 'CommonFields',
  type: 'object',
  properties: {
    createdAt: { type: 'string', format: 'date-time' },
    updatedAt: { type: 'string', format: 'date-time' }
  }
})

fastify.post('/article', {
  schema: {
    body: {
      type: 'object',
      properties: {
        title:     { type: 'string' },
        createdAt: { $ref: 'CommonFields#/properties/createdAt' }
      },
      required: ['title']
    }
  }
}, async (request, reply) => {
  return { ok: true }
})
```

---

#### Composing Schemas with allOf and $ref

`$ref` can be combined with `allOf` to compose a new schema from multiple existing ones.

js

```
fastify.addSchema({
  $id: 'Timestamps',
  type: 'object',
  properties: {
    createdAt: { type: 'string', format: 'date-time' },
    updatedAt: { type: 'string', format: 'date-time' }
  }
})

fastify.addSchema({
  $id: 'UserWithTimestamps',
  allOf: [
    { $ref: 'User#' },
    { $ref: 'Timestamps#' }
  ]
})

fastify.get('/users', {
  schema: {
    response: {
      200: {
        type: 'array',
        items: { $ref: 'UserWithTimestamps#' }
      }
    }
  }
}, async () => {
  return []
})
```

**Key Points**

- `allOf` merges the constraints of all referenced schemas for validation purposes.
- [Inference] Serialization behavior with `allOf` and `$ref` depends on Fastify's serializer (default: `fast-json-stringify`); complex compositions may not serialize as expected — verify output against your specific version.

---

#### Scoping: Instance vs Plugin

Schema visibility follows Fastify's encapsulation model.

```
Root instance
├── addSchema({ $id: 'User' })     ← visible everywhere below
│
├── Plugin A
│   ├── addSchema({ $id: 'Order' }) ← visible only within Plugin A and its children
│   └── Route /orders               ← can use both 'User' and 'Order'
│
└── Plugin B
    └── Route /profile              ← can use 'User', cannot use 'Order'
```

**Key Points**

- A child plugin can access schemas registered by its ancestors.
- A sibling plugin cannot access schemas registered in another sibling's scope.
- To share a schema globally, register it on the root Fastify instance before plugin registration.

---

#### Retrieving Registered Schemas

Fastify provides `fastify.getSchemas()` to inspect what has been registered.

js

```
const schemas = fastify.getSchemas()
console.log(schemas)
// { User: { $id: 'User', type: 'object', ... }, ... }
```

You can also retrieve a single schema by its `$id`:

js

```
const userSchema = fastify.getSchema('User')
```

---

#### Common Mistakes

**Using $ref before addSchema**

js

```
// ❌ Will throw — 'Product' is not yet registered
fastify.get('/product', {
  schema: { response: { 200: { $ref: 'Product#' } } }
}, handler)

fastify.addSchema({ $id: 'Product', ... })
```

js

```
// ✅ Register first
fastify.addSchema({ $id: 'Product', ... })

fastify.get('/product', {
  schema: { response: { 200: { $ref: 'Product#' } } }
}, handler)
```

---

**Registering duplicate $id values**

js

```
fastify.addSchema({ $id: 'User', ... })
fastify.addSchema({ $id: 'User', ... }) // ❌ Throws at startup
```

---

**Expecting cross-sibling schema access**

js

```
fastify.register(async (instance) => {
  instance.addSchema({ $id: 'Token', ... })
})

fastify.register(async (instance) => {
  // ❌ 'Token' is not visible here — different encapsulation scope
  instance.get('/verify', {
    schema: { body: { $ref: 'Token#' } }
  }, handler)
})
```

Move `addSchema` to the root scope to resolve this.

---

#### Practical File Organization

[Inference] The following structure is a common convention — Fastify does not enforce a specific file layout; behavior depends on how modules are loaded and in what order.

```
src/
├── schemas/
│   ├── user.schema.js
│   ├── order.schema.js
│   └── common.schema.js
├── plugins/
│   └── schemas.js        ← registers all shared schemas on root instance
└── routes/
    └── users.js
```

js

```
// plugins/schemas.js
const fp = require('fastify-plugin')
const userSchema    = require('../schemas/user.schema')
const commonSchema  = require('../schemas/common.schema')

module.exports = fp(async (fastify) => {
  fastify.addSchema(commonSchema)
  fastify.addSchema(userSchema)
})
```

Using `fastify-plugin` bypasses encapsulation, making the schemas available to the entire application.

---

**Conclusion**

`$ref` and `$id` enable a single-source-of-truth approach to schema management in Fastify. Schemas registered with `addSchema()` are resolved by the validation and serialization pipeline wherever `$ref` appears. Understanding Fastify's scoping rules is essential — schemas follow the encapsulation boundary of the instance they are registered on, and must be registered before the routes that reference them.
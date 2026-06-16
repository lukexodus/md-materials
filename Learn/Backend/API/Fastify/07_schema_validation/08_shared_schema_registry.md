### Shared Schema Registry

The shared schema registry is Fastify's internal store for named, reusable JSON Schemas. It is the mechanism that makes `addSchema()`, `$ref` resolution, and cross-route schema reuse possible. Understanding how the registry works — including its lifecycle, scoping rules, and interaction with the validation and serialization pipelines — gives you precise control over schema management in any application size.

---

#### What the Registry Is

When you call `fastify.addSchema()`, Fastify stores the schema object in an internal map keyed by its `$id` value. This map is the shared schema registry. Both the validation compiler (default: Ajv via `@fastify/ajv-compiler`) and the serialization compiler (default: `fast-json-stringify`) consult this registry when they encounter a `$ref` that needs resolving.

**Key Points**

- The registry is per-instance — each Fastify instance (root or plugin) maintains its own registry view.
- Child instances inherit the parent's registered schemas at the time of plugin initialization.
- The registry is populated at startup and is not designed for runtime mutation after the server has started.

---

#### Registry Lifecycle

The registry is active during Fastify's initialization phase. The sequence matters:

```
fastify.addSchema(...)       ← schema enters registry
fastify.register(plugin)     ← plugin inherits current registry state
fastify.get(route, schema)   ← schema compiler resolves $ref against registry
fastify.listen(...)          ← server starts; registry is effectively frozen
```

[Inference] Calling `addSchema()` after `fastify.ready()` or `fastify.listen()` may not produce an error in all versions, but schemas added at that point are unlikely to be picked up by already-compiled validators. Behavior may vary by version — verify against your specific Fastify release.

---

#### How Schemas Are Stored

Internally, the registry is a plain object map. The key is the `$id` string; the value is the schema object itself.

js

```
fastify.addSchema({ $id: 'Address', type: 'object', properties: {
  street: { type: 'string' },
  city:   { type: 'string' }
}})

fastify.addSchema({ $id: 'User', type: 'object', properties: {
  id:      { type: 'integer' },
  name:    { type: 'string' },
  address: { $ref: 'Address#' }
}})

console.log(fastify.getSchemas())
// {
//   Address: { $id: 'Address', type: 'object', ... },
//   User:    { $id: 'User',    type: 'object', ... }
// }
```

`getSchemas()` returns a shallow copy of the registry map for the current instance.

---

#### getSchema and getSchemas

Fastify exposes two methods to inspect the registry:

js

```
// Retrieve all registered schemas for this instance
const all = fastify.getSchemas()

// Retrieve a single schema by $id
const address = fastify.getSchema('Address')

// Returns undefined if not found
const missing = fastify.getSchema('DoesNotExist') // undefined
```

**Key Points**

- `getSchemas()` reflects only the schemas visible to the calling instance, including inherited ones from parent scopes.
- `getSchema(id)` is useful for programmatic composition — you can retrieve a schema, extend it, and re-register it under a new `$id`.

---

#### Inheritance and Scoping

The registry follows Fastify's encapsulation model. When a plugin is registered, it receives a copy of the parent's current registry state. Additions made inside the plugin are not visible to the parent or sibling plugins.

```
Root
├── addSchema('Timestamps')
├── addSchema('User')
│
├── Plugin A  (inherits: Timestamps, User)
│   ├── addSchema('Order')         ← only visible inside Plugin A
│   └── routes can use: Timestamps, User, Order
│
└── Plugin B  (inherits: Timestamps, User)
    └── routes can use: Timestamps, User
        cannot use: Order
```

**Making a schema globally available** requires either:

1. Registering it on the root instance before any plugins that need it, or
2. Wrapping the registration in `fastify-plugin`, which breaks encapsulation intentionally.

js

```
// Option 1 — root-level registration
fastify.addSchema({ $id: 'Timestamps', ... })
fastify.register(pluginA)
fastify.register(pluginB)

// Option 2 — fastify-plugin bypasses encapsulation
const fp = require('fastify-plugin')

module.exports = fp(async function schemaPlugin(fastify) {
  fastify.addSchema({ $id: 'Timestamps', ... })
})
```

---

#### How the Registry Feeds the Compilers

At route registration time, Fastify passes the full set of schemas visible to the current instance into both compilers. This is what enables `$ref` resolution across separately defined schemas.

```
Route registered
    │
    ├── Validation compiler receives:
    │       route schema + all schemas from registry
    │       → Ajv resolves $ref internally
    │
    └── Serialization compiler receives:
            response schema + all schemas from registry
            → fast-json-stringify resolves $ref internally
```

[Inference] The compilers receive the registry snapshot at the time the route is registered, not a live reference. Schemas added after route registration are unlikely to be available to that route's compiled validator. Behavior is not guaranteed and may differ across Fastify versions.

---

#### Programmatic Schema Composition

Because `getSchema()` returns the raw schema object, you can build derived schemas programmatically before registering them.

js

```
fastify.addSchema({
  $id: 'User',
  type: 'object',
  properties: {
    id:   { type: 'integer' },
    name: { type: 'string' }
  },
  required: ['id', 'name']
})

// Derive a partial (all fields optional) variant
const base = fastify.getSchema('User')

fastify.addSchema({
  $id: 'UserPatch',
  type: 'object',
  properties: base.properties,
  required: []   // no required fields for PATCH
})
```

**Key Points**

- This is a manual operation — Fastify has no built-in partial/pick/omit schema utility.
- [Inference] Mutating the object returned by `getSchema()` directly may affect the stored schema, depending on how deeply Fastify copies the object. Clone the schema before modifying it to avoid unintended side effects. Behavior is not guaranteed.

js

```
// Safer pattern — clone before modifying
const base = JSON.parse(JSON.stringify(fastify.getSchema('User')))
```

---

#### Conflict and Error Conditions

**Duplicate $id**

Registering two schemas with the same `$id` on the same instance throws at startup:

js

```
fastify.addSchema({ $id: 'User', ... })
fastify.addSchema({ $id: 'User', ... }) // ❌ FST_ERR_SCH_ALREADY_DEFINED
```

**Unresolvable $ref**

If a route schema contains a `$ref` pointing to an `$id` not in the registry, Fastify throws during route compilation:

js

```
fastify.get('/item', {
  schema: { response: { 200: { $ref: 'Item#' } } } // ❌ 'Item' not registered
}, handler)
```

**Key Points**

- Both errors surface at startup, not at request time — schema issues are caught early.
- The error codes (`FST_ERR_SCH_ALREADY_DEFINED`, etc.) are documented in Fastify's error reference.

---

#### Registry in a Plugin-Based Architecture

A common pattern is to isolate all schema registration in a dedicated plugin loaded first, ensuring the registry is fully populated before any route plugins run.

js

```
// app.js
const fastify = require('fastify')()

fastify.register(require('./plugins/schemas'))   // ← registers all shared schemas
fastify.register(require('./routes/users'))
fastify.register(require('./routes/orders'))

fastify.listen({ port: 3000 })
```

js

```
// plugins/schemas.js
const fp = require('fastify-plugin')

module.exports = fp(async function (fastify) {
  fastify.addSchema(require('../schemas/user.schema'))
  fastify.addSchema(require('../schemas/address.schema'))
  fastify.addSchema(require('../schemas/timestamps.schema'))
})
```

js

```
// schemas/user.schema.js
module.exports = {
  $id: 'User',
  type: 'object',
  properties: {
    id:   { type: 'integer' },
    name: { type: 'string' }
  },
  required: ['id', 'name']
}
```

**Key Points**

- `fastify-plugin` is required here so the schemas registered inside the plugin are visible to sibling route plugins.
- Without `fastify-plugin`, the schemas would be scoped to the plugin and invisible to siblings.

---

#### Visualizing the Registry Flow

Root Instance CreatedaddSchema calledRegistry MapPlugin registeredChild instance inheritsregistry snapshotaddSchema in pluginChild-local registryadditionRoute registered in pluginCompiler receives childregistryResolves $ref → compilesvalidator/serializerServer ready

---

**Conclusion**

The shared schema registry is the backbone of Fastify's schema reuse system. It is a per-instance map, populated at startup, inherited by child plugins, and consumed by both the validation and serialization compilers at route registration time. Knowing when schemas must be registered, how scoping affects visibility, and how to inspect the registry with `getSchemas()` and `getSchema()` enables reliable, maintainable schema architecture across applications of any complexity.
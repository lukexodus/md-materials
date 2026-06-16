### Fast-json-stringify Overview

#### What Is Fast-json-stringify

`fast-json-stringify` is a Node.js library that generates a **dedicated serialization function** from a JSON Schema definition. Instead of using `JSON.stringify()` — which inspects every value at runtime to determine how to serialize it — `fast-json-stringify` uses the schema to know the shape of the data ahead of time and produces optimized serialization code for that exact shape.

Fastify uses `fast-json-stringify` internally as part of its response serialization pipeline. When you define a response schema on a route, Fastify compiles a serializer from it and uses that serializer to convert your reply payload into a JSON string.

---

#### Why Not JSON.stringify

`JSON.stringify()` is a general-purpose function. For every value it encounters, it must:

1. Determine the type dynamically
2. Handle edge cases (circular references throw, `undefined` is dropped, `Date` is coerced, etc.)
3. Apply replacer logic if provided

This flexibility has a cost. For high-throughput servers where the shape of the response is known and consistent, that cost is unnecessary.

`fast-json-stringify` eliminates the runtime type-discovery step by precompiling the logic based on the schema.

> Behavior may vary depending on payload shape, Node.js version, and schema complexity. Performance gains are not guaranteed in all cases.

---

#### How It Works

Given a JSON Schema, `fast-json-stringify` generates a JavaScript function (as a string, then evaluated) that serializes only the fields and types declared in the schema.

**Example**

js

```
const build = require('fast-json-stringify')

const stringify = build({
  type: 'object',
  properties: {
    id:    { type: 'integer' },
    name:  { type: 'string' },
    score: { type: 'number' }
  }
})

console.log(stringify({ id: 1, name: 'Luke', score: 98.5 }))
```

**Output**

```
{"id":1,"name":"Luke","score":98.5}
```

The returned `stringify` function is purpose-built for objects matching that schema. It does not perform general-purpose inspection — it directly encodes each known field.

---

#### What the Generated Function Does

For a schema like the one above, the generated code performs roughly the following logic (conceptually, not literally):

- Write `{`
- Write `"id":` + encode integer
- Write `,"name":` + encode string
- Write `,"score":` + encode number
- Write `}`

No branching on type. No iteration over unknown keys. The shape is fixed at compile time.

---

#### Schema Support

`fast-json-stringify` supports a subset of JSON Schema Draft 7. Supported constructs include:

| Construct | Notes |
| --- | --- |
| `type: 'object'` | With `properties` and optional `required` |
| `type: 'array'` | With `items` schema |
| `type: 'string'` | Plain strings |
| `type: 'integer'` / `'number'` | Numeric types |
| `type: 'boolean'` | `true` / `false` |
| `type: 'null'` | Explicit null |
| `allOf`, `anyOf`, `oneOf` | Partial support; behavior may vary |
| `$ref` | Supported via schema references |
| `if` / `then` / `else` | Supported in recent versions |

**Key Points**

- Fields not declared in `properties` are **excluded** from output by default. This is a deliberate security and performance feature.
- Fields listed in `required` are assumed present. If they are missing at runtime, behavior depends on the type — strings may become `""`, integers `0`. This is not guaranteed and may change across versions.
- `additionalProperties: false` is implied by the serialization behavior, but the library does not validate input — it only serializes.

---

#### Fastify Integration

In Fastify, you do not call `fast-json-stringify` directly. You define a response schema, and Fastify compiles and manages the serializer for you.

js

```
fastify.get('/user/:id', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          id:   { type: 'integer' },
          name: { type: 'string' }
        }
      }
    }
  }
}, async (request, reply) => {
  return { id: 1, name: 'Luke', extra: 'ignored' }
})
```

The `extra` field does not appear in the response because it is not in the schema. Fastify's serializer strips it.

This behavior may vary depending on Fastify version and serializer configuration.

---

#### Field Exclusion Behavior

The field-exclusion behavior has two practical implications:

**Security** — fields that should not be exposed (e.g., `passwordHash`, `internalToken`) are automatically absent from the response if they are not in the schema, even if they exist on the returned object. This is a useful property, but it should not be relied upon as the sole access control mechanism. [Inference: treating serialization as a security boundary without additional controls is a design risk.]

**Performance** — the serializer does not iterate over extra keys. It only encodes what it knows.

---

#### Null and Optional Fields

js

```
const stringify = build({
  type: 'object',
  properties: {
    nickname: { type: ['string', 'null'] }
  }
})

stringify({ nickname: null })  // → {"nickname":null}
stringify({ nickname: 'lu' }) // → {"nickname":"lu"}
stringify({})                 // → {"nickname":undefined behavior — depends on version}
```

To handle optional fields that may be absent, use `nullable` (Fastify convention) or a type array `['string', 'null']`. Behavior when a field is absent and not in `required` is [Unverified] and may differ across `fast-json-stringify` versions — test against your installed version.

---

#### Custom Serializers

`fast-json-stringify` allows attaching a custom serializer for specific fields via the `schema` option. Fastify exposes this through its serializer compiler API.

js

```
const stringify = build({
  type: 'object',
  properties: {
    createdAt: {
      type: 'string',
      format: 'date-time'
    }
  }
})
```

For `format` values like `date-time`, the library serializes the value as a string. It does not validate or convert — if you pass a `Date` object, behavior is [Unverified] and should be tested. Fastify's default behavior is to call `.toISOString()` via its own layer before handing off to the serializer, but this depends on the version.

---

#### Standalone Mode

`fast-json-stringify` supports generating the serialization function as a self-contained string that can be saved to disk and required later — without needing the library at runtime. Fastify exposes this through its `fast-json-stringify-compiler` package.

This is useful for:

- Build-time serializer generation
- Reducing startup cost in cold-start environments

[Inference: standalone mode may not cover all schema features; verify against the current documentation for your version.]

---

#### Performance Characteristics

Benchmarks published by the Fastify team show significant throughput differences between `fast-json-stringify` and `JSON.stringify` for structured payloads, particularly for objects with many fields.

> These figures are [Unverified] in the context of any specific deployment. Actual performance depends on payload size, schema complexity, hardware, and Node.js version. Do not treat published benchmarks as guarantees for your workload.

The performance advantage is most pronounced when:

- The schema is fixed and known ahead of time
- Payloads are large or have many fields
- The route handles high request volume

The advantage narrows or may disappear for:

- Very small payloads (serialization is not the bottleneck)
- Schemas with heavy `anyOf`/`oneOf` branching (introduces runtime conditionals)
- One-off or low-traffic routes

---

#### Limitations

| Limitation | Detail |
| --- | --- |
| No runtime validation | Only serializes — does not validate input against the schema |
| Schema must be accurate | Mismatch between schema and actual data produces incorrect or incomplete output |
| `Date` objects | Not natively handled; must be converted before serialization |
| Circular references | Not handled; will produce errors or incorrect output |
| Dynamic schemas | Schema must be known at compile time; fully dynamic schemas negate the benefit |
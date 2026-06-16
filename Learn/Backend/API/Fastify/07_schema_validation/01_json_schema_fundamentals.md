### JSON Schema Fundamentals

JSON Schema is a vocabulary for describing and validating the structure of JSON data. In Fastify, it is used extensively to validate incoming requests and serialize outgoing responses efficiently.

---

#### What JSON Schema Is

JSON Schema is itself a JSON document that describes the shape, types, and constraints of another JSON document. It is defined by a specification maintained at [json-schema.org](https://json-schema.org).

A schema describes:

- What type a value must be
- What properties an object may or must have
- What constraints apply to values (length, range, pattern, etc.)

---

#### Basic Structure

Every JSON Schema is a JSON object. The simplest valid schema is an empty object, which matches any JSON value.

json

```
{}
```

A schema that matches any value of a specific type:

json

```
{ "type": "string" }
```

---

#### The `type` Keyword

The `type` keyword restricts the value to one or more JSON types.

| `type` value | Matches |
| --- | --- |
| `"string"` | JSON strings |
| `"number"` | JSON numbers (integer or float) |
| `"integer"` | Whole numbers only |
| `"boolean"` | `true` or `false` |
| `"array"` | JSON arrays |
| `"object"` | JSON objects |
| `"null"` | `null` |

json

```
{ "type": "integer" }
```

Multiple types are allowed via an array:

json

```
{ "type": ["string", "null"] }
```

---

#### Object Schemas

The `object` type uses `properties`, `required`, and `additionalProperties` to describe its shape.

json

```
{
  "type": "object",
  "properties": {
    "id": { "type": "integer" },
    "name": { "type": "string" },
    "email": { "type": "string", "format": "email" }
  },
  "required": ["id", "name"],
  "additionalProperties": false
}
```

**Key keywords for objects:**

| Keyword | Purpose |
| --- | --- |
| `properties` | Defines known property schemas |
| `required` | Array of property names that must be present |
| `additionalProperties` | `false` disallows properties not in `properties`; a schema validates extra properties |
| `minProperties` | Minimum number of properties |
| `maxProperties` | Maximum number of properties |
| `patternProperties` | Schemas applied to properties whose names match a regex |

---

#### String Constraints

json

```
{
  "type": "string",
  "minLength": 2,
  "maxLength": 100,
  "pattern": "^[a-zA-Z]+$"
}
```

| Keyword | Description |
| --- | --- |
| `minLength` | Minimum character count (inclusive) |
| `maxLength` | Maximum character count (inclusive) |
| `pattern` | Must match this regular expression |
| `format` | Semantic format hint (e.g. `email`, `date`, `uri`) |
| `enum` | Value must be one of the listed strings |
| `const` | Value must equal this exact string |

---

#### Number and Integer Constraints

json

```
{
  "type": "number",
  "minimum": 0,
  "maximum": 100,
  "multipleOf": 5
}
```

| Keyword | Description |
| --- | --- |
| `minimum` | Value must be ≥ this number |
| `maximum` | Value must be ≤ this number |
| `exclusiveMinimum` | Value must be > this number |
| `exclusiveMaximum` | Value must be < this number |
| `multipleOf` | Value must be a multiple of this number |

---

#### Array Schemas

json

```
{
  "type": "array",
  "items": { "type": "string" },
  "minItems": 1,
  "maxItems": 10,
  "uniqueItems": true
}
```

| Keyword | Description |
| --- | --- |
| `items` | Schema applied to every element |
| `minItems` | Minimum number of elements |
| `maxItems` | Maximum number of elements |
| `uniqueItems` | `true` requires all elements to be distinct |
| `prefixItems` | Per-index schemas for tuple-style arrays (JSON Schema draft 2020-12) |
| `contains` | At least one element must match this schema |

---

#### The `format` Keyword

`format` provides semantic validation hints beyond basic type checking.

| Format value | Expected content |
| --- | --- |
| `"email"` | Email address |
| `"uri"` | URI |
| `"date"` | ISO 8601 date (`YYYY-MM-DD`) |
| `"time"` | ISO 8601 time |
| `"date-time"` | ISO 8601 date-time |
| `"uuid"` | UUID string |
| `"ipv4"` | IPv4 address |
| `"ipv6"` | IPv6 address |
| `"hostname"` | Hostname |

> [Inference] In Fastify, `format` validation is not enforced by default for all validators. Whether `format` is validated depends on the JSON Schema validator (Ajv) configuration in use. Behavior is not guaranteed without explicit configuration.

---

#### Composition Keywords

JSON Schema provides keywords to combine schemas logically.

##### `allOf`

The value must be valid against **all** listed schemas.

json

```
{
  "allOf": [
    { "type": "object" },
    { "required": ["id"] }
  ]
}
```

##### `anyOf`

The value must be valid against **at least one** listed schema.

json

```
{
  "anyOf": [
    { "type": "string" },
    { "type": "number" }
  ]
}
```

##### `oneOf`

The value must be valid against **exactly one** listed schema.

json

```
{
  "oneOf": [
    { "type": "integer" },
    { "type": "boolean" }
  ]
}
```

##### `not`

The value must **not** be valid against the listed schema.

json

```
{
  "not": { "type": "null" }
}
```

---

#### The `$ref` Keyword

`$ref` references another schema by URI or JSON Pointer, enabling schema reuse.

json

```
{
  "$ref": "#/$defs/Address"
}
```

Schemas referenced by `$ref` are typically defined in `$defs` (draft 2019-09+) or `definitions` (draft-07).

json

```
{
  "type": "object",
  "properties": {
    "billing": { "$ref": "#/$defs/Address" },
    "shipping": { "$ref": "#/$defs/Address" }
  },
  "$defs": {
    "Address": {
      "type": "object",
      "properties": {
        "street": { "type": "string" },
        "city": { "type": "string" }
      },
      "required": ["street", "city"]
    }
  }
}
```

---

#### The `$defs` and `definitions` Keywords

Both serve as containers for reusable schema definitions within the same document.

| Keyword | Draft |
| --- | --- |
| `definitions` | Draft-07 and earlier |
| `$defs` | Draft 2019-09 and later |

Fastify uses Ajv, which supports both, but `$defs` is preferred for newer schemas.

---

#### Schema Identification — `$schema` and `$id`

`$schema` declares which draft the schema conforms to.

json

```
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object"
}
```

`$id` assigns a URI identifier to a schema, enabling it to be referenced from other schemas.

json

```
{
  "$id": "https://example.com/schemas/user.json",
  "type": "object",
  "properties": {
    "id": { "type": "integer" }
  }
}
```

> [Inference] Fastify's use of `$schema` and `$id` in route schemas depends on the Ajv version and configuration. Not all draft features are supported by default. Verify against your Fastify and Ajv versions.

---

#### `enum` and `const`

`enum` restricts a value to a fixed set of allowed values.

json

```
{ "enum": ["active", "inactive", "pending"] }
```

`const` restricts a value to a single exact value.

json

```
{ "const": "published" }
```

Both work across any type, not just strings.

---

#### `default` and `examples`

These keywords are informational and do not affect validation in most validators.

json

```
{
  "type": "integer",
  "default": 1,
  "examples": [1, 5, 10]
}
```

> [Inference] In Fastify, `default` values in schemas are not automatically applied to request data unless Ajv's `useDefaults` option is enabled. Behavior depends on configuration.

---

#### Conditional Schemas — `if` / `then` / `else`

Allows applying schemas conditionally based on whether a value matches another schema.

json

```
{
  "if": { "properties": { "type": { "const": "admin" } } },
  "then": { "required": ["adminCode"] },
  "else": { "required": ["userToken"] }
}
```

> [Inference] Support for `if`/`then`/`else` depends on the JSON Schema draft and Ajv version in use. Draft-07 introduced this feature. Confirm support in your environment.

---

#### How Fastify Uses JSON Schema

Fastify integrates JSON Schema at the route level for:

| Purpose | Schema location in route options |
| --- | --- |
| Request body validation | `schema.body` |
| Query string validation | `schema.querystring` |
| Route parameter validation | `schema.params` |
| Request header validation | `schema.headers` |
| Response serialization | `schema.response` |

js

```
fastify.post('/user', {
  schema: {
    body: {
      type: 'object',
      properties: {
        name: { type: 'string' },
        age: { type: 'integer', minimum: 0 }
      },
      required: ['name']
    },
    response: {
      200: {
        type: 'object',
        properties: {
          id: { type: 'integer' },
          name: { type: 'string' }
        }
      }
    }
  }
}, async (request, reply) => {
  return { id: 1, name: request.body.name };
});
```

---

#### Fastify's Validator — Ajv

Fastify uses [Ajv](https://ajv.js.org/) as its default JSON Schema validator. Ajv compiles schemas into optimized validation functions at startup rather than interpreting them at runtime on each request.

> [Inference] Schema compilation at startup means validation overhead per request is reduced compared to interpreted validation. Actual performance characteristics depend on schema complexity, Ajv version, and hardware. Behavior is not guaranteed.

---

#### Draft Compatibility in Fastify

| Ajv version | Supported drafts |
| --- | --- |
| Ajv 6 (Fastify v3 default) | Draft-07 |
| Ajv 8 (Fastify v4 default) | Draft-07, 2019-09, 2020-12 |

> [Inference] Fastify v4 ships with Ajv 8 by default, which broadens draft support. Specific draft features may still require explicit Ajv configuration. Confirm against your installed versions.

---

#### Summary

- JSON Schema describes the structure and constraints of JSON data using keywords
- Core keywords include `type`, `properties`, `required`, `items`, `enum`, `format`, and composition keywords (`allOf`, `anyOf`, `oneOf`, `not`)
- `$ref` and `$defs` enable schema reuse within and across documents
- Fastify uses JSON Schema at the route level for request validation and response serialization
- Fastify's default validator is Ajv, which compiles schemas at startup for efficient per-request validation
- `format` validation, `default` application, and advanced draft features require explicit Ajv configuration to take effect
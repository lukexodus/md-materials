### Ajv Configuration and Custom Keywords

Fastify uses Ajv as its default JSON Schema validator, wired in through `@fastify/ajv-compiler`. While Fastify's defaults cover most use cases, direct Ajv configuration is available for scenarios requiring custom formats, additional vocabularies, strict mode control, or entirely custom validation keywords. Understanding how to reach and configure the underlying Ajv instance gives you precise control over validation behavior.

---

#### How Fastify Wires Ajv

Fastify does not expose the Ajv instance directly. Instead, it accepts configuration through the `ajv` option at instance creation, which is forwarded to the Ajv constructor via `@fastify/ajv-compiler`.

js

```
const fastify = require('fastify')({
  ajv: {
    customOptions: {
      // These are passed directly to the Ajv constructor
      removeAdditional: true,
      useDefaults: true,
      coerceTypes: false,
      allErrors: true
    }
  }
})
```

**Key Points**

- Options under `customOptions` map directly to [Ajv constructor options](https://ajv.js.org/options.html).
- Changes here affect all route validators compiled by this Fastify instance.
- [Inference] The exact set of supported options depends on the version of Ajv bundled with `@fastify/ajv-compiler` — verify against your installed versions, as behavior may differ.

---

#### Commonly Used Ajv Options

##### removeAdditional

Strips properties from the validated object that are not declared in the schema.

js

```
const fastify = require('fastify')({
  ajv: { customOptions: { removeAdditional: true } }
})

fastify.post('/user', {
  schema: {
    body: {
      type: 'object',
      properties: { name: { type: 'string' } },
      additionalProperties: false
    }
  }
}, async (request) => {
  // Input: { name: 'Ada', role: 'admin' }
  // After validation: { name: 'Ada' }  ← 'role' removed
  return request.body
})
```

**Key Points**

- `removeAdditional: true` only strips properties when `additionalProperties: false` is set on the schema.
- `removeAdditional: 'all'` strips regardless of `additionalProperties`.
- [Inference] Mutation of the request body object occurs in-place during validation; downstream code receives the stripped object. Behavior is not guaranteed across all Ajv versions.

---

##### useDefaults

Populates missing properties with their `default` values during validation.

js

```
const fastify = require('fastify')({
  ajv: { customOptions: { useDefaults: true } }
})

fastify.post('/config', {
  schema: {
    body: {
      type: 'object',
      properties: {
        timeout: { type: 'integer', default: 30 },
        retries: { type: 'integer', default: 3 }
      }
    }
  }
}, async (request) => {
  // Input: {}
  // After validation: { timeout: 30, retries: 3 }
  return request.body
})
```

---

##### coerceTypes

Attempts to cast incoming values to the type declared in the schema.

js

```
const fastify = require('fastify')({
  ajv: { customOptions: { coerceTypes: true } }
})
```

**Key Points**

- Useful for query string parameters, which arrive as strings regardless of intent.
- `coerceTypes: 'array'` additionally coerces scalar values to single-element arrays where an array is expected.
- [Inference] Coercion modifies the validated data in-place. This can obscure type errors in some scenarios — use with awareness of your validation intent.

---

##### allErrors

Continues validation after the first error, collecting all violations.

js

```
const fastify = require('fastify')({
  ajv: { customOptions: { allErrors: true } }
})
```

**Key Points**

- By default, Ajv stops at the first error. `allErrors: true` returns the full list.
- Increases validation overhead on malformed input — [Inference] the impact is typically negligible for small payloads but may be measurable for large documents with many violations.

---

##### strict Mode

Ajv v8 (used in newer versions of `@fastify/ajv-compiler`) enables strict mode by default, which rejects unknown keywords and certain schema patterns.

js

```
const fastify = require('fastify')({
  ajv: {
    customOptions: {
      strict: false          // disable all strict checks
      // or granularly:
      // strictSchema: false,
      // strictTypes: false,
      // strictTuples: false
    }
  }
})
```

**Key Points**

- Strict mode catches likely schema authoring mistakes at startup.
- Disabling it may be necessary when integrating third-party schemas that use non-standard keywords.
- [Inference] The available strict sub-options depend on the Ajv version in use — consult the Ajv changelog if you encounter unexpected strict-mode errors after upgrading.

---

#### Adding Ajv Plugins

The `ajv.plugins` option accepts an array of Ajv plugin initializer functions. This is the primary mechanism for adding format vocabularies or extending Ajv's capabilities without replacing the compiler.

js

```
const fastify = require('fastify')({
  ajv: {
    plugins: [
      require('ajv-formats'),         // adds format: 'email', 'date-time', etc.
      require('ajv-keywords')         // adds custom keywords like 'transform'
    ]
  }
})
```

If a plugin requires options, wrap it in an array:

js

```
const fastify = require('fastify')({
  ajv: {
    plugins: [
      [require('ajv-formats'), { mode: 'fast' }]
    ]
  }
})
```

**Key Points**

- `ajv-formats` is not bundled with Ajv v8 by default — if you use `format` keywords in schemas, this plugin is required.
- Plugins are applied to every Ajv instance created by `@fastify/ajv-compiler` for this Fastify instance.

---

#### Custom Formats

Custom formats extend Ajv's `format` keyword with your own validation logic.

js

```
const fastify = require('fastify')({
  ajv: {
    customOptions: { strict: false }
  }
})

// Register a custom format after instance creation via the compiler
// The recommended approach is to use a custom schema compiler (see below)
```

The standard path for custom formats in Fastify is through a custom schema compiler or via an Ajv plugin. The most direct approach:

js

```
const Ajv = require('ajv')
const addFormats = require('ajv-formats')

const fastify = require('fastify')({
  schemaController: {
    compilersFactory: {
      buildValidator(externalSchemas, options) {
        const ajv = new Ajv({
          ...options,
          allErrors: true
        })
        addFormats(ajv)

        ajv.addFormat('uuid-v4', {
          type: 'string',
          validate: (v) => /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(v)
        })

        // Register shared schemas
        for (const schema of Object.values(externalSchemas)) {
          ajv.addSchema(schema)
        }

        return {
          validate(schema) {
            return ajv.compile(schema)
          }
        }
      }
    }
  }
})

fastify.post('/resource', {
  schema: {
    body: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid-v4' }
      }
    }
  }
}, async (request) => request.body)
```

[Inference] The `schemaController` API was introduced in Fastify v4. The exact interface may differ in earlier versions — consult your version's documentation. Behavior is not guaranteed across versions.

---

#### Custom Keywords

Custom keywords extend Ajv's vocabulary beyond what JSON Schema provides. Ajv supports four types of custom keyword implementations.

---

##### Validation Keywords

Return a boolean — pass or fail.

js

```
ajv.addKeyword({
  keyword: 'isPositive',
  type: 'number',
  schemaType: 'boolean',
  validate(schema, data) {
    return schema === true ? data > 0 : true
  },
  errors: false
})
```

**Example** — using it in a route schema:

js

```
fastify.post('/amount', {
  schema: {
    body: {
      type: 'object',
      properties: {
        amount: { type: 'number', isPositive: true }
      }
    }
  }
}, async (request) => request.body)
```

**Output** — sending `{ "amount": -5 }`:

json

```
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "body/amount must pass \"isPositive\" keyword validation"
}
```

---

##### Code-Generating Keywords

Produce inline code for better performance — used when the keyword must integrate with Ajv's compiled output rather than call an external function per validation.

js

```
const { _ } = require('ajv')

ajv.addKeyword({
  keyword: 'range',
  type: 'number',
  schemaType: 'array',
  code(cxt) {
    const { data, schema } = cxt
    const [min, max] = schema
    cxt.fail(_`${data} < ${min} || ${data} > ${max}`)
  },
  errors: false
})
```

**Example**:

js

```
// Schema using the custom 'range' keyword
{
  type: 'number',
  range: [1, 100]
}
```

[Inference] Code-generating keywords require familiarity with Ajv's internal code generation API (`cxt`, `_`, `str`). The API is documented in Ajv's source and may change between major versions — behavior is not guaranteed.

---

##### Async Keywords

Support asynchronous validation logic — for example, checking uniqueness against a database.

js

```
ajv.addKeyword({
  keyword: 'uniqueEmail',
  async: true,
  type: 'string',
  validate: async function checkEmail(schema, data) {
    const exists = await db.emailExists(data)
    if (exists) {
      throw new ajv.constructor.ValidationError([{
        keyword: 'uniqueEmail',
        message: 'email already registered',
        params: { keyword: 'uniqueEmail' }
      }])
    }
    return true
  }
})
```

**Key Points**

- Schemas using async keywords must declare `"$async": true` at the root.
- [Inference] Fastify's default validation pipeline may not support async schemas out of the box — using async keywords typically requires a custom schema compiler. Behavior is not guaranteed without verifying against your setup.
- Async validation at the schema level introduces latency on every validated request — consider whether the validation belongs at the schema layer or in the route handler.

---

##### Macro Keywords

Transform the schema at compile time by expanding into a standard JSON Schema fragment.

js

```
ajv.addKeyword({
  keyword: 'nonEmptyString',
  type: 'string',
  schemaType: 'boolean',
  macro(schema) {
    return schema ? { minLength: 1 } : {}
  }
})
```

**Example**:

js

```
// This schema:
{ type: 'string', nonEmptyString: true }

// Expands at compile time to:
{ type: 'string', minLength: 1 }
```

**Key Points**

- Macro keywords are resolved entirely at compile time — no runtime function call occurs.
- They are the most performant custom keyword type for simple constraint aliases.

---

#### Registering Custom Keywords via schemaController

The recommended pattern for integrating all customizations — formats, keywords, plugins — in one place:

js

```
const Ajv = require('ajv')
const addFormats = require('ajv-formats')

function buildValidator(externalSchemas, options) {
  const ajv = new Ajv({ allErrors: true, ...options })

  addFormats(ajv)

  ajv.addKeyword({
    keyword: 'nonEmptyString',
    type: 'string',
    schemaType: 'boolean',
    macro: (schema) => schema ? { minLength: 1 } : {}
  })

  ajv.addKeyword({
    keyword: 'isPositive',
    type: 'number',
    schemaType: 'boolean',
    validate: (schema, data) => schema === true ? data > 0 : true,
    errors: false
  })

  for (const schema of Object.values(externalSchemas)) {
    ajv.addSchema(schema)
  }

  return {
    validate(schema) {
      return ajv.compile(schema)
    }
  }
}

const fastify = require('fastify')({
  schemaController: {
    compilersFactory: { buildValidator }
  }
})
```

---

#### Error Messages from Custom Keywords

When `errors: false` is set on a keyword, Ajv generates a generic error message. To provide a specific message, populate the `errors` array on the validate function:

js

```
ajv.addKeyword({
  keyword: 'isPositive',
  type: 'number',
  schemaType: 'boolean',
  validate(schema, data) {
    validate.errors = null
    if (schema && data <= 0) {
      validate.errors = [{
        keyword: 'isPositive',
        message: 'must be a positive number',
        params: { value: data }
      }]
      return false
    }
    return true
  },
  errors: true
})
```

---

#### Summary of Custom Keyword Types

| Type | Runs at | Use when |
| --- | --- | --- |
| `validate` function | Runtime | Simple boolean pass/fail logic |
| `macro` | Compile time | Expanding shorthand into standard JSON Schema |
| `code` | Compile time (inline) | Performance-critical custom constraints |
| `async validate` | Runtime (async) | Validation requiring I/O |

---

**Conclusion**

Fastify exposes Ajv configuration through the `ajv.customOptions` and `ajv.plugins` constructor options for common needs, and through the `schemaController` API for full compiler control. Custom keywords extend the validation vocabulary with runtime, compile-time, and async variants — each suited to different performance and complexity trade-offs. All customizations should be applied before route registration, and behavior across Ajv major versions should be verified rather than assumed.
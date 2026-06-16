### Custom Validators

Fastify's validation pipeline is configurable at multiple levels. Beyond Ajv customization, you can replace the entire validation compiler, apply per-route validators, validate parts of the request that schema validation does not cover, and attach custom logic that runs before or after schema validation. This topic covers the full range of custom validation strategies available in Fastify.

---

#### Validation Architecture Overview

Before diving into customization, it helps to understand where validation sits in the request lifecycle:

passfailIncoming RequestonRequest hookspreParsing hooksBody ParsingpreValidation hooksSchema ValidatorpreHandler hooksValidation Error ResponseRoute HandleronSend hooksResponse

**Key Points**

- Schema validation runs after body parsing and after `preValidation` hooks.
- `preValidation` hooks execute before the schema validator — this is where custom pre-validation logic belongs.
- Custom validators can replace the schema compilation step entirely or supplement it.

---

#### Replacing the Schema Compiler

The `setValidatorCompiler` method replaces Fastify's default Ajv-based compiler with any function that accepts a schema and returns a validator function.

js

```
fastify.setValidatorCompiler(({ schema, method, url, httpPart }) => {
  // Return a function that validates data against schema
  return function validate(data) {
    // Must return true (valid) or false (invalid)
    // Attach .errors for error detail
  }
})
```

**Parameters passed to the compiler:**

| Parameter | Description |
| --- | --- |
| `schema` | The JSON Schema object for this route part |
| `method` | HTTP method of the route |
| `url` | URL pattern of the route |
| `httpPart` | Which part: `body`, `params`, `query`, `headers` |

---

#### Using a Different Validation Library

The most common reason to replace the compiler entirely is to use an alternative validator. The following example substitutes [Zod](https://zod.dev) via a thin adapter.

**Key Points**

- Zod is not a JSON Schema validator — this pattern requires manual schema mapping.
- [Inference] This approach bypasses Fastify's `$ref` resolution entirely, since that is handled by Ajv. Shared schema registry features will not function without additional wiring. Behavior is not guaranteed.

js

```
const { z } = require('zod')

const userBodySchema = z.object({
  name:  z.string().min(1),
  email: z.string().email(),
  age:   z.number().int().positive()
})

fastify.post('/user', {
  config: {
    // Store the Zod schema outside the standard 'schema' key
    zodSchema: { body: userBodySchema }
  },
  schema: {
    // Still define a JSON Schema for serialization and documentation
    body: {
      type: 'object',
      properties: {
        name:  { type: 'string' },
        email: { type: 'string' },
        age:   { type: 'integer' }
      }
    }
  }
}, async (request, reply) => {
  return request.body
})
```

For a clean integration, intercept validation in `preValidation`:

js

```
fastify.addHook('preValidation', async (request, reply) => {
  const zodSchema = request.routeOptions?.config?.zodSchema
  if (!zodSchema) return

  if (zodSchema.body) {
    const result = zodSchema.body.safeParse(request.body)
    if (!result.success) {
      return reply.status(400).send({
        statusCode: 400,
        error: 'Bad Request',
        message: result.error.issues.map(i => i.message).join('; ')
      })
    }
    request.body = result.data
  }
})
```

[Inference] `request.routeOptions` availability depends on your Fastify version. In earlier versions, route config may be accessed differently — verify against your release.

---

#### setValidatorCompiler with a Custom Library

For a complete compiler replacement using a library like [Typebox](https://github.com/sinclairzx81/typebox) (which produces JSON Schema-compatible output natively):

js

```
const { TypeCompiler } = require('@sinclair/typebox/compiler')

fastify.setValidatorCompiler(({ schema }) => {
  const compiled = TypeCompiler.Compile(schema)
  return function validate(data) {
    const errors = [...compiled.Errors(data)]
    if (errors.length > 0) {
      validate.errors = errors.map(e => ({
        keyword: 'type',
        message: e.message,
        instancePath: e.path
      }))
      return false
    }
    return true
  }
})
```

**Key Points**

- The returned validator function must attach errors to itself as `.errors` when validation fails — this is how Fastify reads error detail.
- Returning `false` with no `.errors` attached produces a generic validation error message.
- [Inference] TypeBox schemas are JSON Schema-compatible, so `$ref` and `$id` usage may still work if the underlying compiler supports it — verify against TypeBox and Fastify documentation for your versions.

---

#### Per-Route Validator Compiler

`setValidatorCompiler` can be scoped to individual routes rather than the entire instance. This allows mixing validation strategies.

js

```
const defaultValidator = fastify.validatorCompiler

fastify.post('/legacy', {
  validatorCompiler({ schema, httpPart }) {
    // Custom logic only for this route
    return function validate(data) {
      // ... custom validation
      return true
    }
  },
  schema: {
    body: { type: 'object' }
  }
}, handler)
```

**Key Points**

- The `validatorCompiler` property on a route option overrides the instance-level compiler for that route only.
- Other routes continue to use the instance-level compiler.

---

#### preValidation Hook for Custom Logic

`preValidation` hooks run after parsing but before schema validation. They are the appropriate place for:

- Authentication-dependent validation (e.g., field requirements depending on user role)
- Cross-field validation (fields whose validity depends on each other)
- External lookups that influence whether input is valid
- Transforming input before the schema validator sees it

js

```
// Cross-field validation example
fastify.addHook('preValidation', async (request, reply) => {
  const { startDate, endDate } = request.body ?? {}
  if (startDate && endDate && new Date(startDate) >= new Date(endDate)) {
    return reply.status(400).send({
      statusCode: 400,
      error: 'Bad Request',
      message: 'startDate must be before endDate'
    })
  }
})
```

**Key Points**

- `preValidation` can be applied at the instance level (all routes) or per-route.
- Returning a reply from a hook short-circuits the remaining lifecycle — schema validation does not run.
- `request.body` is available here because parsing has already completed.

---

#### postValidation and the Validated Data

There is no dedicated `postValidation` hook in Fastify's lifecycle. Logic that should run after validation succeeds belongs in `preHandler`.

js

```
fastify.addHook('preHandler', async (request, reply) => {
  // At this point, schema validation has already passed
  // request.body, request.params, request.query are validated and (if configured) coerced
  console.log('Validated body:', request.body)
})
```

---

#### Attaching Custom Validation Logic Per Route

For route-scoped validation without a global hook, use the route-level `preValidation` option:

js

```
async function validateOwnership(request, reply) {
  const { id } = request.params
  const userId = request.user?.id
  if (String(id) !== String(userId)) {
    return reply.status(403).send({ message: 'Forbidden' })
  }
}

fastify.get('/account/:id', {
  preValidation: validateOwnership,
  schema: {
    params: {
      type: 'object',
      properties: { id: { type: 'integer' } },
      required: ['id']
    }
  }
}, async (request) => {
  return { account: request.params.id }
})
```

**Key Points**

- `preValidation` at the route level accepts a single function or an array of functions.
- Functions receive `(request, reply)` and must be async or call a callback.

---

#### Disabling Validation for a Route

To skip schema validation entirely for a specific route, omit the `schema` option. If a schema is present but you want to disable validation for a specific `httpPart`, set it to an empty schema or override the compiler:

js

```
// No schema = no validation
fastify.post('/raw', async (request) => {
  return request.body
})

// Disable body validation only — still validate params
fastify.post('/partial/:id', {
  schema: {
    params: {
      type: 'object',
      properties: { id: { type: 'string' } },
      required: ['id']
    }
    // No 'body' key — body is not validated
  }
}, async (request) => request.body)
```

---

#### Customizing the Validation Error Response

By default, Fastify returns a 400 with Ajv's error output when validation fails. To change the format, use `setErrorHandler` or the `attachValidation` option.

##### attachValidation

Setting `attachValidation: true` on a route prevents Fastify from automatically sending a 400 on validation failure. Instead, the validation result is attached to `request.validationError`, and the handler decides what to do.

js

```
fastify.post('/tolerant', {
  attachValidation: true,
  schema: {
    body: {
      type: 'object',
      properties: { name: { type: 'string' } },
      required: ['name']
    }
  }
}, async (request, reply) => {
  if (request.validationError) {
    return reply.status(422).send({
      statusCode: 422,
      issues: request.validationError.validation
    })
  }
  return { ok: true }
})
```

**Key Points**

- `request.validationError` is `null` when validation passes.
- `request.validationError.validation` contains the raw Ajv error array.
- `request.validationError.validationContext` indicates which `httpPart` failed: `body`, `params`, `query`, or `headers`.

---

##### setErrorHandler for Validation Errors

A global error handler can intercept and reformat all validation errors:

js

```
fastify.setErrorHandler(function (error, request, reply) {
  if (error.validation) {
    return reply.status(400).send({
      statusCode: 400,
      error: 'Validation Failed',
      fields: error.validation.map(v => ({
        field:   v.instancePath.replace(/^\//, '') || v.params?.missingProperty,
        message: v.message
      }))
    })
  }
  reply.send(error)
})
```

**Output** — sending `{}` to a route requiring `name`:

json

```
{
  "statusCode": 400,
  "error": "Validation Failed",
  "fields": [
    { "field": "name", "message": "must have required property 'name'" }
  ]
}
```

---

#### Combining Schema Validation with Custom Logic

A layered validation approach uses JSON Schema for structure and type constraints, and `preValidation` or `preHandler` for business-rule constraints:

js

```
fastify.post('/transfer', {
  preValidation: async (request, reply) => {
    // Business rule: cannot transfer to self
    if (request.body?.fromAccount === request.body?.toAccount) {
      return reply.status(400).send({
        message: 'Source and destination accounts must differ'
      })
    }
  },
  schema: {
    body: {
      type: 'object',
      properties: {
        fromAccount: { type: 'string' },
        toAccount:   { type: 'string' },
        amount:      { type: 'number', exclusiveMinimum: 0 }
      },
      required: ['fromAccount', 'toAccount', 'amount']
    }
  }
}, async (request) => {
  return { status: 'queued' }
})
```

**Key Points**

- The `preValidation` hook here runs before schema validation — `request.body` may not yet be coerced or default-populated.
- If coercion or defaults from `useDefaults`/`coerceTypes` are needed before custom logic, move that logic to `preHandler` instead.
- [Inference] Execution order between `preValidation` hook and schema validator means the hook sees raw parsed data, not Ajv-processed data. Behavior depends on Ajv options in effect.

---

**Conclusion**

Fastify's custom validation support spans from fine-grained Ajv tuning to full compiler replacement and hook-based business logic. The key design decision is where in the lifecycle validation belongs: schema validation for structural and type correctness, `preValidation` for pre-schema transformations and rule checks, and `preHandler` for post-validation logic that depends on coerced or defaulted values. These layers are independent and composable, enabling validation strategies that match the complexity of any application domain.
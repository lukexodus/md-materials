### Creating custom error classes

#### Why custom error classes?

Fastify's built-in error handling and `@fastify/sensible` cover standard HTTP semantics well, but production applications often need errors that carry domain-specific context — a validation failure that names which field failed, a business rule violation that includes an error code your frontend maps to a localized message, or a database error that distinguishes "not found" from "connection failure" without leaking internals.

Custom error classes give you:

- A reliable way to identify error type in `setErrorHandler` using `instanceof`
- Structured extra fields beyond `message` and `statusCode`
- Consistent error shape across the entire application
- A clean separation between domain errors and HTTP transport concerns

---

#### Baseline: extending `Error`

The minimal starting point is a plain ES6 class extending `Error`:

js

```
class AppError extends Error {
  constructor(message, statusCode = 500) {
    super(message)
    this.name = this.constructor.name
    this.statusCode = statusCode
  }
}
```

Two details matter here:

- `this.name = this.constructor.name` sets the error name to the class name automatically, so subclasses inherit this without re-declaring it.
- `statusCode` is the property Fastify's error handler pipeline reads when deciding which HTTP status to use.

---

#### The stack trace problem in transpiled environments

In environments that transpile with Babel or older TypeScript configurations, `Error.captureStackTrace` may not point to the subclass correctly. The standard fix:

js

```
class AppError extends Error {
  constructor(message, statusCode = 500) {
    super(message)
    this.name = this.constructor.name
    this.statusCode = statusCode

    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, this.constructor)
    }
  }
}
```

`Error.captureStackTrace` is V8-specific and not present in all environments. The `if` guard makes it safe universally. [Inference: in native ESM on current Node.js without transpilation this is generally unnecessary, but it does no harm.]

---

#### Building a hierarchy

A single base class with subclasses for each error category gives `instanceof` checks clean semantics:

js

```
class AppError extends Error {
  constructor(message, statusCode = 500) {
    super(message)
    this.name = this.constructor.name
    this.statusCode = statusCode
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, this.constructor)
    }
  }
}

class NotFoundError extends AppError {
  constructor(resource, id) {
    super(`${resource} with id '${id}' was not found`, 404)
    this.resource = resource
    this.id = id
  }
}

class ConflictError extends AppError {
  constructor(message, field) {
    super(message, 409)
    this.field = field
  }
}

class ForbiddenError extends AppError {
  constructor(message = 'Access denied') {
    super(message, 403)
  }
}

class ValidationError extends AppError {
  constructor(message, errors = []) {
    super(message, 422)
    this.errors = errors
  }
}

class UnauthorizedError extends AppError {
  constructor(message = 'Authentication required') {
    super(message, 401)
  }
}
```

Each subclass encodes its HTTP status code internally, so call sites never deal with raw numbers:

js

```
throw new NotFoundError('User', request.params.id)
throw new ConflictError('Email already in use', 'email')
throw new ValidationError('Invalid input', [{ field: 'age', message: 'Must be >= 0' }])
```

---

#### Adding structured context

Beyond `statusCode` and `message`, custom classes can carry any domain fields. A useful pattern is an `errorCode` string — a machine-readable identifier your frontend maps to localized messages:

js

```
class BusinessRuleError extends AppError {
  constructor(message, errorCode, context = {}) {
    super(message, 422)
    this.errorCode = errorCode
    this.context = context
  }
}

throw new BusinessRuleError(
  'Cannot transfer funds: insufficient balance',
  'INSUFFICIENT_BALANCE',
  { available: 50, requested: 200 }
)
```

This keeps HTTP status codes decoupled from application logic — the `422` is a transport decision; `INSUFFICIENT_BALANCE` is the domain signal.

---

#### Handling custom errors in `setErrorHandler`

The handler uses `instanceof` to branch on error type and shape responses differently per class:

js

```
fastify.setErrorHandler(function (error, request, reply) {

  if (error instanceof ValidationError) {
    return reply.status(422).send({
      statusCode: 422,
      error: 'Validation Error',
      message: error.message,
      errors: error.errors,
    })
  }

  if (error instanceof NotFoundError) {
    return reply.status(404).send({
      statusCode: 404,
      error: 'Not Found',
      message: error.message,
      resource: error.resource,
    })
  }

  if (error instanceof BusinessRuleError) {
    return reply.status(422).send({
      statusCode: 422,
      error: error.errorCode,
      message: error.message,
      context: error.context,
    })
  }

  if (error instanceof AppError) {
    return reply.status(error.statusCode).send({
      statusCode: error.statusCode,
      error: error.name,
      message: error.message,
    })
  }

  // Unknown / unhandled — log and obscure
  request.log.error({ err: error }, 'Unhandled error')
  reply.status(500).send({
    statusCode: 500,
    error: 'Internal Server Error',
    message: 'An unexpected error occurred',
  })
})
```

**Key Points:**

- Specific subclasses are checked before the base `AppError` catch-all, because `instanceof` walks the prototype chain — a `NotFoundError` is also an `AppError`.
- Unknown errors (not extending `AppError`) fall through to the last branch, where the internal message is suppressed to avoid leaking implementation details.

The check order matters:

<svg width="100%" viewBox="0 0 680 370" role="img" style="" xmlns="http://www.w3.org/2000/svg">
  <title style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">instanceof check order in setErrorHandler</title>
  <desc style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">Flowchart showing that specific subclasses like ValidationError and NotFoundError are checked before the AppError base class, which is checked before the unknown error fallback.</desc>
  <defs>
    <marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  <mask id="imagine-text-gaps-e0adqd" maskUnits="userSpaceOnUse"><rect x="0" y="0" width="680" height="370" fill="white"/><rect x="274.5208435058594" y="42.333335876464844" width="130.95833587646484" height="19.33333396911621" fill="black" rx="2"/><rect x="252.46875" y="118.33333587646484" width="175.0625" height="19.33333396911621" fill="black" rx="2"/><rect x="276.640625" y="137.33334350585938" width="126.71875" height="17.33333396911621" fill="black" rx="2"/><rect x="590.8177490234375" y="122.33333587646484" width="38.36458396911621" height="19.33333396911621" fill="black" rx="2"/><rect x="348" y="169.33334350585938" width="21.354166984558105" height="17.33333396911621" fill="black" rx="2"/><rect x="270.625" y="202.33334350585938" width="138.75" height="19.33333396911621" fill="black" rx="2"/><rect x="283.640625" y="221.33334350585938" width="112.71875" height="17.33333396911621" fill="black" rx="2"/><rect x="590.8177490234375" y="206.33334350585938" width="38.36458396911621" height="19.33333396911621" fill="black" rx="2"/><rect x="348" y="253.33334350585938" width="21.354166984558105" height="17.33333396911621" fill="black" rx="2"/><rect x="291.2552185058594" y="286.3333435058594" width="97.49382019042969" height="19.33333396911621" fill="black" rx="2"/><rect x="257.44793701171875" y="307.3333435058594" width="165.1041717529297" height="17.33333396911621" fill="black" rx="2"/></mask></defs>

  <g style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">
    <rect x="240" y="30" width="200" height="44" rx="8" stroke-width="0.5" style="fill:rgb(68, 68, 65);stroke:rgb(180, 178, 169);color:rgb(255, 255, 255);stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
    <text x="340" y="52" text-anchor="middle" dominant-baseline="central" style="fill:rgb(211, 209, 199);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:14px;font-weight:500;text-anchor:middle;dominant-baseline:central">error enters handler</text>
  </g>

  <line x1="340" y1="74" x2="340" y2="110" marker-end="url(#arrow)" style="fill:none;stroke:rgb(156, 154, 146);color:rgb(255, 255, 255);stroke-width:1.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>

  <g style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">
    <rect x="190" y="110" width="300" height="44" rx="8" stroke-width="0.5" style="fill:rgb(60, 52, 137);stroke:rgb(175, 169, 236);color:rgb(255, 255, 255);stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
    <text x="340" y="128" text-anchor="middle" dominant-baseline="central" style="fill:rgb(206, 203, 246);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:14px;font-weight:500;text-anchor:middle;dominant-baseline:central">instanceof ValidationError?</text>
    <text x="340" y="146" text-anchor="middle" dominant-baseline="central" style="fill:rgb(175, 169, 236);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:central">or NotFoundError, etc.</text>
  </g>

  <line x1="490" y1="132" x2="580" y2="132" stroke="#534AB7" marker-end="url(#arrow)" style="fill:none;stroke:rgb(156, 154, 146);color:rgb(255, 255, 255);stroke-width:1.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
  <g style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">
    <rect x="580" y="108" width="60" height="44" rx="8" stroke-width="0.5" style="fill:rgb(60, 52, 137);stroke:rgb(175, 169, 236);color:rgb(255, 255, 255);stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
    <text x="610" y="132" text-anchor="middle" dominant-baseline="central" style="fill:rgb(206, 203, 246);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:14px;font-weight:500;text-anchor:middle;dominant-baseline:central">send</text>
  </g>

  <line x1="340" y1="154" x2="340" y2="194" marker-end="url(#arrow)" mask="url(#imagine-text-gaps-e0adqd)" style="fill:none;stroke:rgb(156, 154, 146);color:rgb(255, 255, 255);stroke-width:1.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
  <text x="352" y="178" dominant-baseline="central" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:start;dominant-baseline:central">no</text>

  <g style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">
    <rect x="200" y="194" width="280" height="44" rx="8" stroke-width="0.5" style="fill:rgb(8, 80, 65);stroke:rgb(93, 202, 165);color:rgb(255, 255, 255);stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
    <text x="340" y="212" text-anchor="middle" dominant-baseline="central" style="fill:rgb(159, 225, 203);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:14px;font-weight:500;text-anchor:middle;dominant-baseline:central">instanceof AppError?</text>
    <text x="340" y="230" text-anchor="middle" dominant-baseline="central" style="fill:rgb(93, 202, 165);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:central">base class catch-all</text>
  </g>

  <line x1="480" y1="216" x2="580" y2="216" stroke="#0F6E56" marker-end="url(#arrow)" style="fill:none;stroke:rgb(156, 154, 146);color:rgb(255, 255, 255);stroke-width:1.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
  <g style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">
    <rect x="580" y="192" width="60" height="44" rx="8" stroke-width="0.5" style="fill:rgb(8, 80, 65);stroke:rgb(93, 202, 165);color:rgb(255, 255, 255);stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
    <text x="610" y="216" text-anchor="middle" dominant-baseline="central" style="fill:rgb(159, 225, 203);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:14px;font-weight:500;text-anchor:middle;dominant-baseline:central">send</text>
  </g>

  <line x1="340" y1="238" x2="340" y2="278" marker-end="url(#arrow)" mask="url(#imagine-text-gaps-e0adqd)" style="fill:none;stroke:rgb(156, 154, 146);color:rgb(255, 255, 255);stroke-width:1.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
  <text x="352" y="262" dominant-baseline="central" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:start;dominant-baseline:central">no</text>

  <g style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">
    <rect x="190" y="278" width="300" height="52" rx="8" stroke-width="0.5" style="fill:rgb(121, 31, 31);stroke:rgb(240, 149, 149);color:rgb(255, 255, 255);stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
    <text x="340" y="296" text-anchor="middle" dominant-baseline="central" style="fill:rgb(247, 193, 193);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:14px;font-weight:500;text-anchor:middle;dominant-baseline:central">unknown error</text>
    <text x="340" y="316" text-anchor="middle" dominant-baseline="central" style="fill:rgb(240, 149, 149);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:central">log + 500, suppress message</text>
  </g>
</svg>

### Organizing error classes as a module

In a real project, error classes belong in a dedicated file imported wherever they are needed.

```
src/
  errors/
    index.js
  routes/
    users.js
  plugins/
    error-handler.js
```

**`src/errors/index.js`:**

js

```js
export class AppError extends Error {
  constructor(message, statusCode = 500) {
    super(message)
    this.name = this.constructor.name
    this.statusCode = statusCode
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, this.constructor)
    }
  }
}

export class NotFoundError extends AppError {
  constructor(resource, id) {
    super(`${resource} with id '${id}' was not found`, 404)
    this.resource = resource
    this.id = id
  }
}

export class ConflictError extends AppError {
  constructor(message, field) {
    super(message, 409)
    this.field = field
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Access denied') {
    super(message, 403)
  }
}

export class ValidationError extends AppError {
  constructor(message, errors = []) {
    super(message, 422)
    this.errors = errors
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Authentication required') {
    super(message, 401)
  }
}

export class BusinessRuleError extends AppError {
  constructor(message, errorCode, context = {}) {
    super(message, 422)
    this.errorCode = errorCode
    this.context = context
  }
}
```

**`src/routes/users.js`:**

js

```js
import { NotFoundError, ConflictError } from '../errors/index.js'

export default async function userRoutes(fastify) {
  fastify.get('/users/:id', async (request) => {
    const user = await db.findById(request.params.id)
    if (!user) throw new NotFoundError('User', request.params.id)
    return user
  })

  fastify.post('/users', async (request) => {
    const exists = await db.findByEmail(request.body.email)
    if (exists) throw new ConflictError('Email already registered', 'email')
    return db.create(request.body)
  })
}
```

**`src/plugins/error-handler.js`:**

js

```js
import fp from 'fastify-plugin'
import {
  AppError,
  NotFoundError,
  ValidationError,
  BusinessRuleError,
} from '../errors/index.js'

export default fp(function errorHandler(fastify, opts, done) {
  fastify.setErrorHandler(function (error, request, reply) {
    if (error instanceof ValidationError) {
      return reply.status(422).send({
        statusCode: 422,
        error: 'Validation Error',
        message: error.message,
        errors: error.errors,
      })
    }

    if (error instanceof NotFoundError) {
      return reply.status(404).send({
        statusCode: 404,
        error: 'Not Found',
        message: error.message,
        resource: error.resource,
      })
    }

    if (error instanceof BusinessRuleError) {
      return reply.status(422).send({
        statusCode: 422,
        error: error.errorCode,
        message: error.message,
        context: error.context,
      })
    }

    if (error instanceof AppError) {
      return reply.status(error.statusCode).send({
        statusCode: error.statusCode,
        error: error.name,
        message: error.message,
      })
    }

    request.log.error({ err: error }, 'Unhandled error')
    reply.status(500).send({
      statusCode: 500,
      error: 'Internal Server Error',
      message: 'An unexpected error occurred',
    })
  })

  done()
})
```

The handler plugin is wrapped with `fastify-plugin` so it applies globally rather than being encapsulated in its own scope.

---

### TypeScript: typed custom errors

If you are using TypeScript, the same hierarchy applies with type annotations:

ts

```ts
export class AppError extends Error {
  statusCode: number

  constructor(message: string, statusCode = 500) {
    super(message)
    this.name = this.constructor.name
    this.statusCode = statusCode
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, this.constructor)
    }
  }
}

export class NotFoundError extends AppError {
  resource: string
  id: string | number

  constructor(resource: string, id: string | number) {
    super(`${resource} with id '${id}' was not found`, 404)
    this.resource = resource
    this.id = id
  }
}

export class ValidationError extends AppError {
  errors: { field: string; message: string }[]

  constructor(message: string, errors: { field: string; message: string }[] = []) {
    super(message, 422)
    this.errors = errors
  }
}
```

Fastify's `FastifyError` interface extends `Error` with `statusCode`, `code`, and `validation` fields. Custom classes do not need to implement that interface to work with `setErrorHandler` — the handler receives an `Error` and you narrow the type with `instanceof`. [Inference: if you want full type safety in the handler signature, you can cast `error as AppError` after the `instanceof` check.]

---

### Serializing errors safely

A common mistake is letting `JSON.stringify` serialize a full `Error` object — native `Error` properties like `stack` are non-enumerable and will not appear in JSON, but custom properties you add are enumerable and will. This means `stack` is typically safe from accidental leakage, but fields like `context` or `errors` will appear if you call `reply.send(error)` directly.

Prefer always constructing an explicit response object in `setErrorHandler` rather than passing the error directly:

js

```js
// Avoid — sends all enumerable fields of the error, including internals
reply.send(error)

// Prefer — explicit shape, nothing leaks accidentally
reply.status(error.statusCode).send({
  statusCode: error.statusCode,
  message: error.message,
})
```

---

### Summary

| Pattern | Purpose |
| --- | --- |
| Base `AppError` class | Shared `statusCode`, `name`, stack fix |
| Domain subclasses | Typed context fields, readable throw sites |
| `instanceof` in handler | Reliable branching without string matching |
| `errorCode` string field | Machine-readable code for client mapping |
| Dedicated `errors/index.js` | Single source of truth across the project |
| `fastify-plugin` wrapper | Applies handler globally, not per-scope |

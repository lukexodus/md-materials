## Separation of Concerns in Handlers

A Fastify route handler has one job: translate an HTTP request into an HTTP response. When handlers also contain business logic, data access, validation beyond schema, error mapping, and logging decisions, they become difficult to test, hard to reason about, and resistant to change. Separation of concerns in handlers means each layer of the request lifecycle does exactly one thing, and the handler itself stays thin.

---

### What Belongs in a Handler

A handler should only:

- Extract validated input from the request (`req.body`, `req.params`, `req.query`, `req.user`)
- Call an application service or use-case function
- Map the result to an HTTP response (status code, headers, body)
- Propagate errors upward (not catch and re-implement them)

Everything else belongs elsewhere.

```js
// ✅ Thin handler — correct separation
fastify.post('/orders', async (req, reply) => {
  const order = await orderService.createOrder(req.body)
  return reply.code(201).send(order)
})
```

```js
// ❌ Fat handler — mixed concerns
fastify.post('/orders', async (req, reply) => {
  // Input validation (belongs in JSON schema)
  if (!req.body.customerId) {
    return reply.code(400).send({ error: 'customerId is required' })
  }

  // Data access (belongs in repository)
  const customer = await db.query('SELECT * FROM customers WHERE id = $1', [req.body.customerId])
  if (!customer.rows[0]) {
    return reply.code(404).send({ error: 'Customer not found' })
  }

  // Business logic (belongs in domain/service)
  if (customer.rows[0].creditScore < 500) {
    return reply.code(422).send({ error: 'Customer ineligible for orders' })
  }

  // Persistence (belongs in repository)
  const result = await db.query(
    'INSERT INTO orders (customer_id, status) VALUES ($1, $2) RETURNING *',
    [req.body.customerId, 'draft']
  )

  return reply.code(201).send(result.rows[0])
})
```

---

### The Four Layers a Handler Delegates To

```
HTTP Request
     │
     ▼
┌─────────────┐
│   Schema    │  JSON Schema validates and coerces input before handler runs
├─────────────┤
│   Handler   │  Extracts input, calls service, returns response
├─────────────┤
│   Service   │  Orchestrates use case, enforces business rules
├─────────────┤
│ Repository  │  Performs data access, maps DB rows to domain objects
└─────────────┘
     │
     ▼
 Data Store
```

Each layer has a single axis of change. Swapping the database affects only the repository. Changing a business rule affects only the service or domain. Changing the HTTP contract affects only the handler and schema.

---

### Layer 1 — Schema (Input Validation)

JSON schema validation runs before the handler executes. Any request that fails schema validation is rejected automatically with a `400` response. The handler never sees invalid input:

```js
const createOrderSchema = {
  body: {
    type: 'object',
    required: ['customerId'],
    properties: {
      customerId: { type: 'string', format: 'uuid' },
      notes: { type: 'string', maxLength: 500 }
    },
    additionalProperties: false
  },
  response: {
    201: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        customerId: { type: 'string' },
        status: { type: 'string' },
        createdAt: { type: 'string' }
      }
    }
  }
}

fastify.post('/orders', { schema: createOrderSchema }, async (req, reply) => {
  // req.body is guaranteed to have customerId (uuid string)
  // No manual validation needed here
  const order = await orderService.createOrder(req.body)
  return reply.code(201).send(order)
})
```

**Key Points:**
- `additionalProperties: false` strips undeclared fields before the handler sees them.
- The `response` schema serializes output and strips internal fields not declared in the schema.
- Validation errors are handled by Fastify's built-in error handler — no handler code required.

---

### Layer 2 — The Handler

With schema handling input and services handling logic, the handler is reduced to three lines in most cases:

```js
fastify.get('/orders/:id', { schema: getOrderSchema }, async (req, reply) => {
  const order = await orderService.getOrder(req.params.id)
  return order   // Fastify serializes with the response schema
})
```

For mutations, the handler maps the result to the appropriate status code:

```js
fastify.post('/orders/:id/place', async (req, reply) => {
  const order = await orderService.placeOrder(req.params.id)
  return reply.code(200).send(order)
})
```

For deletions:

```js
fastify.delete('/orders/:id', async (req, reply) => {
  await orderService.cancelOrder(req.params.id)
  return reply.code(204).send()
})
```

The handler does not branch on business conditions. If the service throws, the error propagates to the error handler.

---

### Layer 3 — Application Service

The service orchestrates the use case. It coordinates repositories and domain logic without knowing anything about HTTP:

```js
// services/OrderService.js
'use strict'

class OrderService {
  constructor ({ orderRepository, customerRepository }) {
    this.orderRepository = orderRepository
    this.customerRepository = customerRepository
  }

  async createOrder ({ customerId, notes }) {
    const customer = await this.customerRepository.findById(customerId)
    if (!customer) {
      const err = new Error('Customer not found')
      err.statusCode = 404
      throw err
    }

    if (!customer.isEligibleForOrders()) {
      const err = new Error('Customer is not eligible to place orders')
      err.statusCode = 422
      throw err
    }

    const order = new Order({ customerId, notes })
    await this.orderRepository.save(order)
    return order
  }

  async getOrder (id) {
    const order = await this.orderRepository.findById(id)
    if (!order) {
      const err = new Error('Order not found')
      err.statusCode = 404
      throw err
    }
    return order
  }

  async placeOrder (id) {
    const order = await this.orderRepository.findById(id)
    if (!order) {
      const err = new Error('Order not found')
      err.statusCode = 404
      throw err
    }
    order.place()  // domain rule — throws if invalid state
    await this.orderRepository.save(order)
    return order
  }
}

module.exports = OrderService
```

**Key Points:**
- No `req`, `reply`, or `fastify` references anywhere in the service.
- Errors carry `statusCode` so the error handler can map them to HTTP responses.
- Business eligibility logic (`customer.isEligibleForOrders()`) lives on the domain object, not here.

---

### Layer 4 — Repository

The repository abstracts data access. It speaks the language of domain objects, not SQL rows:

```js
// repositories/PgOrderRepository.js
'use strict'

class PgOrderRepository {
  constructor (db) {
    this.db = db
  }

  async findById (id) {
    const { rows } = await this.db.query(
      'SELECT * FROM orders WHERE id = $1',
      [id]
    )
    return rows[0] ? this._toOrder(rows[0]) : null
  }

  async save (order) {
    await this.db.query(
      `INSERT INTO orders (id, customer_id, status, notes, created_at)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (id) DO UPDATE
       SET status = EXCLUDED.status`,
      [order.id, order.customerId, order.status, order.notes, order.createdAt]
    )
  }

  _toOrder (row) {
    return new Order({
      id: row.id,
      customerId: row.customer_id,
      status: row.status,
      notes: row.notes,
      createdAt: row.created_at
    })
  }
}

module.exports = PgOrderRepository
```

The service calls `findById` and receives an `Order` object. It never writes SQL. The repository never applies business rules.

---

### Wiring the Layers in a Fastify Plugin

Dependencies are composed in the route plugin, not inside the handler:

```js
// routes/orders.js
'use strict'

const PgOrderRepository = require('../repositories/PgOrderRepository')
const PgCustomerRepository = require('../repositories/PgCustomerRepository')
const OrderService = require('../services/OrderService')
const { createOrderSchema, getOrderSchema } = require('./schemas/orders')

async function orderRoutes (fastify, opts) {
  // Compose service with infrastructure
  const orderService = new OrderService({
    orderRepository: new PgOrderRepository(fastify.db),
    customerRepository: new PgCustomerRepository(fastify.db)
  })

  // Thin handlers — service reference closed over
  fastify.post('/', { schema: createOrderSchema }, async (req, reply) => {
    const order = await orderService.createOrder(req.body)
    return reply.code(201).send(order)
  })

  fastify.get('/:id', { schema: getOrderSchema }, async (req, reply) => {
    return orderService.getOrder(req.params.id)
  })

  fastify.post('/:id/place', async (req, reply) => {
    return orderService.placeOrder(req.params.id)
  })

  fastify.delete('/:id', async (req, reply) => {
    await orderService.cancelOrder(req.params.id)
    return reply.code(204).send()
  })
}

module.exports = orderRoutes
```

Alternatively, the service can be injected via a Fastify decorator:

```js
// Using fastify decorator instead of local construction
fastify.decorate('orderService', new OrderService({
  orderRepository: new PgOrderRepository(fastify.db),
  customerRepository: new PgCustomerRepository(fastify.db)
}))

// Handler accesses via fastify
fastify.post('/', async (req, reply) => {
  const order = await fastify.orderService.createOrder(req.body)
  return reply.code(201).send(order)
})
```

> [Inference] Constructing the service inside the route plugin (closure approach) vs. via a decorator are both valid patterns. The decorator approach is preferable when the same service instance is needed across multiple route plugins. Behavior and lifetime of the service instance depends on where and how it is constructed.

---

### Handling Authenticated Context

User identity extracted by an auth hook should be passed explicitly to the service rather than the service reaching for `req.user`:

```js
// ✅ Explicit — service does not know about req
fastify.post('/', async (req, reply) => {
  const order = await orderService.createOrder({
    customerId: req.user.id,   // extracted here, passed as plain data
    ...req.body
  })
  return reply.code(201).send(order)
})
```

```js
// ❌ Implicit — service coupled to request shape
class OrderService {
  async createOrder (req) {         // takes request object
    const customerId = req.user.id  // service knows about req.user
  }
}
```

Passing `req.user.id` as a plain value keeps the service decoupled from Fastify's request object entirely.

---

### Error Propagation — Not Catching in Handlers

Handlers should let errors propagate to the centralized error handler:

```js
// ✅ Let it propagate
fastify.get('/orders/:id', async (req, reply) => {
  return orderService.getOrder(req.params.id)
  // If service throws { message: 'Order not found', statusCode: 404 },
  // Fastify's error handler catches it
})
```

```js
// ❌ Re-implementing error handling in every handler
fastify.get('/orders/:id', async (req, reply) => {
  try {
    return await orderService.getOrder(req.params.id)
  } catch (err) {
    if (err.message === 'Order not found') {
      return reply.code(404).send({ error: 'Order not found' })
    }
    return reply.code(500).send({ error: 'Internal error' })
  }
})
```

A centralized error handler maps all service errors once:

```js
// plugins/error-handler.js
const fp = require('fastify-plugin')

module.exports = fp(async function (fastify) {
  fastify.setErrorHandler(async (err, req, reply) => {
    const statusCode = err.statusCode ?? 500
    if (statusCode >= 500) {
      req.log.error({ err }, 'Unhandled error')
    }
    return reply.code(statusCode).send({
      error: err.message,
      statusCode
    })
  })
})
```

---

### Logging — Handler vs. Hook

Request and response logging belongs in hooks, not handlers:

```js
// ✅ Logging in a hook — applies consistently to all routes
fastify.addHook('onResponse', async (req, reply) => {
  req.log.info({
    method: req.method,
    url: req.url,
    statusCode: reply.statusCode,
    responseTime: reply.elapsedTime
  }, 'request completed')
})

// ❌ Logging inside every handler — duplicated, inconsistent
fastify.get('/orders/:id', async (req, reply) => {
  req.log.info('Getting order')       // duplicated in every handler
  const order = await orderService.getOrder(req.params.id)
  req.log.info('Order retrieved')     // also duplicated
  return order
})
```

Business-significant events (e.g., order placed, payment failed) are logged in the service or domain layer where they occur:

```js
// In OrderService
async placeOrder (id) {
  const order = await this.orderRepository.findById(id)
  order.place()
  await this.orderRepository.save(order)
  this.logger.info({ orderId: id }, 'Order placed')   // domain event log
  return order
}
```

> [Inference] Passing a logger (Pino or compatible interface) to the service through its constructor avoids coupling the service to `fastify.log` or `req.log` while preserving structured logging capability.

---

### Response Serialization — Schema, Not Handler Code

Manually constructing response shapes in handlers spreads serialization logic across every route:

```js
// ❌ Manual serialization in handler
fastify.get('/orders/:id', async (req, reply) => {
  const order = await orderService.getOrder(req.params.id)
  return {
    id: order.id,
    customerId: order.customerId,
    status: order.status,
    total: order.total.amount,
    currency: order.total.currency,
    createdAt: order.createdAt.toISOString()
  }
})
```

Declare the shape once in the response schema and return the domain object directly:

```js
// ✅ Schema handles serialization
const getOrderSchema = {
  response: {
    200: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        customerId: { type: 'string' },
        status: { type: 'string' },
        total: { type: 'number' },
        currency: { type: 'string' },
        createdAt: { type: 'string' }
      }
    }
  }
}

fastify.get('/orders/:id', { schema: getOrderSchema }, async (req, reply) => {
  return orderService.getOrder(req.params.id)  // schema strips/serializes automatically
})
```

Fastify's fast-json-stringify uses the response schema to serialize — fields not in the schema are excluded from the response without any handler code.

---

### Composing Handlers from Smaller Functions

For handlers that have legitimate complexity — multiple steps, conditional responses — extract named functions rather than inlining everything:

```js
// ❌ Inline complexity
fastify.post('/orders/:id/checkout', async (req, reply) => {
  const order = await orderService.getOrder(req.params.id)
  if (order.customerId !== req.user.id) {
    return reply.code(403).send({ error: 'Forbidden' })
  }
  const result = await paymentService.charge({
    orderId: order.id,
    amount: order.total,
    method: req.body.paymentMethod
  })
  if (!result.success) {
    return reply.code(402).send({ error: 'Payment failed' })
  }
  await orderService.markPaid(order.id)
  return reply.code(200).send({ charged: result.transactionId })
})
```

```js
// ✅ Extracted use-case function
async function checkoutOrder (orderService, paymentService, { orderId, userId, paymentMethod }) {
  const order = await orderService.getOrder(orderId)
  if (order.customerId !== userId) {
    const err = new Error('Forbidden')
    err.statusCode = 403
    throw err
  }
  const result = await paymentService.charge({ orderId, amount: order.total, paymentMethod })
  if (!result.success) {
    const err = new Error('Payment failed')
    err.statusCode = 402
    throw err
  }
  await orderService.markPaid(orderId)
  return { charged: result.transactionId }
}

// Handler is thin again
fastify.post('/orders/:id/checkout', async (req, reply) => {
  const result = await checkoutOrder(orderService, paymentService, {
    orderId: req.params.id,
    userId: req.user.id,
    paymentMethod: req.body.paymentMethod
  })
  return reply.code(200).send(result)
})
```

The extracted function is independently testable without Fastify.

---

### Testing Each Layer Independently

#### Schema validation (no Fastify needed):

```js
const { test } = require('node:test')
const Ajv = require('ajv')
const addFormats = require('ajv-formats')
const { createOrderSchema } = require('../routes/schemas/orders')

test('createOrderSchema rejects missing customerId', (t) => {
  const ajv = new Ajv()
  addFormats(ajv)
  const validate = ajv.compile(createOrderSchema.body)
  const valid = validate({ notes: 'hello' })
  t.assert.equal(valid, false)
})
```

#### Service (no Fastify, no DB):

```js
test('createOrder throws 404 when customer not found', async (t) => {
  const service = new OrderService({
    orderRepository: { save: async () => {} },
    customerRepository: { findById: async () => null }
  })
  await t.assert.rejects(
    () => service.createOrder({ customerId: 'x' }),
    (err) => err.statusCode === 404
  )
})
```

#### Handler (via Fastify injection):

```js
test('POST /orders returns 201', async (t) => {
  const app = await build(t)
  const res = await app.inject({
    method: 'POST',
    url: '/orders',
    payload: { customerId: 'uuid-here' },
    headers: { authorization: 'Bearer valid-token' }
  })
  t.assert.equal(res.statusCode, 201)
})
```

---

### Summary: What Lives Where

| Concern | Location |
|---|---|
| Input validation (type, format, required) | JSON Schema |
| Business rule enforcement | Domain entity or service |
| Use case orchestration | Application service |
| Data access | Repository |
| HTTP status code selection | Handler |
| Error-to-HTTP mapping | Centralized error handler |
| Request/response logging | Hooks |
| Response serialization | Response schema |
| Authentication | Auth hook / preHandler |
| Authorization (resource ownership) | Application service or preHandler |

---

**Related Topics:**
- Fastify JSON Schema validation and `ajv` configuration
- `fast-json-stringify` and response schema serialization
- Centralized error handling with `setErrorHandler`
- Fastify lifecycle hooks for cross-cutting concerns
- Dependency injection via Fastify decorators
- Repository pattern and data mapper hydration
- Testing services and repositories without Fastify
- `preHandler` hooks for authorization logic
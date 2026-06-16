## Domain-Driven Design with Fastify

Domain-Driven Design (DDD) is a software design approach that structures code around business domains — the core concepts, rules, and processes of the problem being solved — rather than around technical concerns. Applied to Fastify, DDD means the application's directory structure, module boundaries, and object model reflect the business language and domain logic, while Fastify itself is treated as a delivery mechanism sitting at the edge of the domain, not at its center.

---

### Core DDD Concepts Relevant to Fastify

Before mapping DDD to Fastify structure, the key concepts:

| Concept | Description |
|---|---|
| **Domain** | The business problem space — e.g., e-commerce, logistics, billing |
| **Bounded Context** | An explicit boundary within which a domain model applies consistently |
| **Entity** | An object with a unique identity that persists over time (e.g., `User`, `Order`) |
| **Value Object** | An immutable object defined by its attributes, not identity (e.g., `Money`, `Address`) |
| **Aggregate** | A cluster of entities and value objects treated as a single unit with one root |
| **Repository** | Abstraction over data access for an aggregate |
| **Domain Service** | Stateless logic that does not belong to a single entity |
| **Application Service** | Orchestrates use cases; coordinates domain objects and infrastructure |
| **Domain Event** | A record of something that happened in the domain (e.g., `OrderPlaced`) |
| **Ubiquitous Language** | Shared vocabulary used consistently in code, tests, and conversation |

In Fastify terms: Fastify handles HTTP. The domain handles business rules. Application services connect the two.

---

### Layered Architecture

DDD typically maps to a layered architecture:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │  Fastify routes, request/response
├─────────────────────────────────────┤
│         Application Layer           │  Use case orchestration (App Services)
├─────────────────────────────────────┤
│           Domain Layer              │  Entities, Value Objects, Domain Services
├─────────────────────────────────────┤
│        Infrastructure Layer         │  DB, external APIs, messaging
└─────────────────────────────────────┘
```

Dependencies flow inward — the domain layer has no knowledge of Fastify, databases, or HTTP. Infrastructure and presentation depend on the domain, never the reverse.

---

### Directory Structure

A Fastify application organized by bounded context with DDD layering:

```
src/
├── app.js                        ← Fastify root plugin
├── plugins/                      ← Global infrastructure (db, config, auth)
│   ├── 00-env.js
│   ├── 01-db.js
│   └── 02-auth.js
│
└── contexts/                     ← One directory per bounded context
    ├── ordering/
    │   ├── index.js              ← Fastify plugin entry, mounts this context
    │   ├── presentation/
    │   │   ├── routes.js         ← HTTP handlers (thin, delegates to app service)
    │   │   └── schemas.js        ← JSON schemas for request/response
    │   ├── application/
    │   │   └── OrderService.js   ← Use case orchestration
    │   ├── domain/
    │   │   ├── Order.js          ← Aggregate root (entity)
    │   │   ├── OrderLine.js      ← Entity within aggregate
    │   │   ├── Money.js          ← Value object
    │   │   └── OrderRepository.js ← Repository interface (abstract contract)
    │   └── infrastructure/
    │       └── PgOrderRepository.js ← Concrete repository (PostgreSQL)
    │
    ├── inventory/
    │   ├── index.js
    │   ├── presentation/
    │   ├── application/
    │   ├── domain/
    │   └── infrastructure/
    │
    └── identity/
        ├── index.js
        ├── presentation/
        ├── application/
        ├── domain/
        └── infrastructure/
```

---

### Domain Layer

The domain layer contains pure business logic. It has zero dependencies on Fastify, databases, or any infrastructure library.

#### Entity

An entity has identity and lifecycle. Business rules that govern its state live here:

```js
// contexts/ordering/domain/Order.js
'use strict'

const { randomUUID } = require('node:crypto')
const Money = require('./Money')
const OrderLine = require('./OrderLine')

class Order {
  constructor ({ id, customerId, lines = [], status = 'draft', createdAt } = {}) {
    this.id = id ?? randomUUID()
    this.customerId = customerId
    this.lines = lines.map(l => new OrderLine(l))
    this.status = status
    this.createdAt = createdAt ?? new Date()
  }

  addLine ({ productId, quantity, unitPrice }) {
    if (this.status !== 'draft') {
      throw new Error('Cannot modify a non-draft order')
    }
    if (quantity <= 0) {
      throw new Error('Quantity must be positive')
    }
    this.lines.push(new OrderLine({ productId, quantity, unitPrice }))
  }

  place () {
    if (this.lines.length === 0) {
      throw new Error('Cannot place an empty order')
    }
    if (this.status !== 'draft') {
      throw new Error('Order has already been placed')
    }
    this.status = 'placed'
  }

  cancel () {
    if (this.status === 'cancelled') {
      throw new Error('Order is already cancelled')
    }
    if (this.status === 'shipped') {
      throw new Error('Cannot cancel a shipped order')
    }
    this.status = 'cancelled'
  }

  get total () {
    return this.lines.reduce(
      (sum, line) => sum.add(line.subtotal),
      Money.zero()
    )
  }
}

module.exports = Order
```

**Key Points:**
- Business rules (cannot modify non-draft, cannot place empty order) live in the entity, not in routes or services.
- The entity is a plain JavaScript class with no framework dependencies.
- `total` is a computed property — derived from the aggregate's internal state.

---

#### Value Object

Value objects are immutable and compared by value, not identity:

```js
// contexts/ordering/domain/Money.js
'use strict'

class Money {
  constructor (amount, currency = 'USD') {
    if (typeof amount !== 'number' || amount < 0) {
      throw new Error('Amount must be a non-negative number')
    }
    this.amount = Math.round(amount * 100) / 100  // two decimal places
    this.currency = currency
    Object.freeze(this)
  }

  add (other) {
    if (other.currency !== this.currency) {
      throw new Error(`Currency mismatch: ${this.currency} vs ${other.currency}`)
    }
    return new Money(this.amount + other.amount, this.currency)
  }

  multiply (factor) {
    return new Money(this.amount * factor, this.currency)
  }

  equals (other) {
    return this.amount === other.amount && this.currency === other.currency
  }

  toString () {
    return `${this.currency} ${this.amount.toFixed(2)}`
  }

  static zero (currency = 'USD') {
    return new Money(0, currency)
  }
}

module.exports = Money
```

---

#### Repository Interface

In DDD, the domain layer defines the repository contract. The infrastructure layer implements it. This keeps the domain independent of any specific database:

```js
// contexts/ordering/domain/OrderRepository.js
'use strict'

/**
 * Abstract repository interface for Order aggregates.
 * Implementations must fulfill this contract.
 */
class OrderRepository {
  async findById (id) {
    throw new Error('Not implemented')
  }

  async findByCustomerId (customerId) {
    throw new Error('Not implemented')
  }

  async save (order) {
    throw new Error('Not implemented')
  }

  async delete (id) {
    throw new Error('Not implemented')
  }
}

module.exports = OrderRepository
```

> [Inference] JavaScript does not enforce interface contracts at the language level. This abstract class pattern communicates intent and causes runtime errors if methods are not overridden, but does not provide compile-time safety. TypeScript interfaces or abstract classes with type checking offer stronger guarantees.

---

### Infrastructure Layer

The infrastructure layer contains the concrete repository implementation:

```js
// contexts/ordering/infrastructure/PgOrderRepository.js
'use strict'

const OrderRepository = require('../domain/OrderRepository')
const Order = require('../domain/Order')
const Money = require('../domain/Money')

class PgOrderRepository extends OrderRepository {
  constructor (db) {
    super()
    this.db = db
  }

  async findById (id) {
    const { rows } = await this.db.query(
      `SELECT o.*, json_agg(ol.*) AS lines
       FROM orders o
       LEFT JOIN order_lines ol ON ol.order_id = o.id
       WHERE o.id = $1
       GROUP BY o.id`,
      [id]
    )
    if (!rows[0]) return null
    return this._hydrate(rows[0])
  }

  async findByCustomerId (customerId) {
    const { rows } = await this.db.query(
      `SELECT o.*, json_agg(ol.*) AS lines
       FROM orders o
       LEFT JOIN order_lines ol ON ol.order_id = o.id
       WHERE o.customer_id = $1
       GROUP BY o.id
       ORDER BY o.created_at DESC`,
      [customerId]
    )
    return rows.map(this._hydrate)
  }

  async save (order) {
    const client = await this.db.connect()
    try {
      await client.query('BEGIN')

      await client.query(
        `INSERT INTO orders (id, customer_id, status, created_at)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (id) DO UPDATE
         SET status = EXCLUDED.status`,
        [order.id, order.customerId, order.status, order.createdAt]
      )

      await client.query('DELETE FROM order_lines WHERE order_id = $1', [order.id])

      for (const line of order.lines) {
        await client.query(
          `INSERT INTO order_lines (order_id, product_id, quantity, unit_price, currency)
           VALUES ($1, $2, $3, $4, $5)`,
          [order.id, line.productId, line.quantity, line.unitPrice.amount, line.unitPrice.currency]
        )
      }

      await client.query('COMMIT')
    } catch (err) {
      await client.query('ROLLBACK')
      throw err
    } finally {
      client.release()
    }
  }

  _hydrate (row) {
    return new Order({
      id: row.id,
      customerId: row.customer_id,
      status: row.status,
      createdAt: row.created_at,
      lines: (row.lines || []).filter(Boolean).map(line => ({
        productId: line.product_id,
        quantity: line.quantity,
        unitPrice: new Money(line.unit_price, line.currency)
      }))
    })
  }
}

module.exports = PgOrderRepository
```

---

### Application Layer

Application services orchestrate use cases. They coordinate domain objects, repositories, and infrastructure without containing business rules themselves:

```js
// contexts/ordering/application/OrderService.js
'use strict'

class OrderService {
  constructor ({ orderRepository, eventBus }) {
    this.orderRepository = orderRepository
    this.eventBus = eventBus
  }

  async createOrder ({ customerId }) {
    const Order = require('../domain/Order')
    const order = new Order({ customerId })
    await this.orderRepository.save(order)
    return order
  }

  async addLineToOrder ({ orderId, productId, quantity, unitPrice }) {
    const Money = require('../domain/Money')
    const order = await this.orderRepository.findById(orderId)
    if (!order) throw Object.assign(new Error('Order not found'), { statusCode: 404 })

    order.addLine({
      productId,
      quantity,
      unitPrice: new Money(unitPrice.amount, unitPrice.currency)
    })

    await this.orderRepository.save(order)
    return order
  }

  async placeOrder ({ orderId }) {
    const order = await this.orderRepository.findById(orderId)
    if (!order) throw Object.assign(new Error('Order not found'), { statusCode: 404 })

    order.place()  // domain rule enforced here — throws if invalid

    await this.orderRepository.save(order)

    await this.eventBus.publish('order.placed', {
      orderId: order.id,
      customerId: order.customerId,
      total: order.total
    })

    return order
  }

  async cancelOrder ({ orderId }) {
    const order = await this.orderRepository.findById(orderId)
    if (!order) throw Object.assign(new Error('Order not found'), { statusCode: 404 })

    order.cancel()  // domain rule enforced — throws if already shipped

    await this.orderRepository.save(order)
    return order
  }

  async getOrder ({ orderId }) {
    const order = await this.orderRepository.findById(orderId)
    if (!order) throw Object.assign(new Error('Order not found'), { statusCode: 404 })
    return order
  }
}

module.exports = OrderService
```

**Key Points:**
- Application services receive dependencies through their constructor — no direct Fastify access.
- Business rules (`order.place()`, `order.cancel()`) are delegated to the domain entity.
- The application service handles the use case flow: fetch → mutate → persist → publish.
- Attaching `statusCode` to errors allows Fastify's error handler to map domain errors to HTTP status codes.

---

### Presentation Layer (Fastify Routes)

Routes are thin. They translate HTTP into application service calls and serialize the result:

```js
// contexts/ordering/presentation/routes.js
'use strict'

const { createOrderSchema, placeOrderSchema, addLineSchema, getOrderSchema } = require('./schemas')

async function orderRoutes (fastify, opts) {
  const { orderService } = fastify

  fastify.post('/', { schema: createOrderSchema }, async (req, reply) => {
    const order = await orderService.createOrder({
      customerId: req.user.id
    })
    return reply.code(201).send(order)
  })

  fastify.get('/:id', { schema: getOrderSchema }, async (req, reply) => {
    return orderService.getOrder({ orderId: req.params.id })
  })

  fastify.post('/:id/lines', { schema: addLineSchema }, async (req, reply) => {
    const order = await orderService.addLineToOrder({
      orderId: req.params.id,
      ...req.body
    })
    return reply.code(201).send(order)
  })

  fastify.post('/:id/place', { schema: placeOrderSchema }, async (req, reply) => {
    const order = await orderService.placeOrder({ orderId: req.params.id })
    return order
  })

  fastify.post('/:id/cancel', async (req, reply) => {
    const order = await orderService.cancelOrder({ orderId: req.params.id })
    return order
  })
}

module.exports = orderRoutes
```

---

### Context Entry Plugin

The bounded context entry plugin wires infrastructure to the domain and makes the application service available as a Fastify decorator:

```js
// contexts/ordering/index.js
'use strict'

const PgOrderRepository = require('./infrastructure/PgOrderRepository')
const OrderService = require('./application/OrderService')
const routes = require('./presentation/routes')

async function orderingContext (fastify, opts) {
  // Wire infrastructure to domain
  const orderRepository = new PgOrderRepository(fastify.db)

  // Compose application service
  const orderService = new OrderService({
    orderRepository,
    eventBus: fastify.eventBus   // global plugin decorator
  })

  // Decorate within this context's scope
  fastify.decorate('orderService', orderService)

  // Register routes
  fastify.register(routes)
}

module.exports = orderingContext
```

Because `orderingContext` is not wrapped with `fp`, the `orderService` decorator is scoped to this context only — other contexts cannot access it directly.

---

### Root Application Composition

```js
// app.js
'use strict'

const fp = require('fastify-plugin')

module.exports = fp(async function app (fastify, opts) {
  // Global infrastructure
  await fastify.register(require('./plugins/00-env'))
  await fastify.register(require('./plugins/01-db'))
  await fastify.register(require('./plugins/02-auth'))
  await fastify.register(require('./plugins/03-event-bus'))

  // Bounded contexts, each under its own prefix
  fastify.register(require('./contexts/identity'),  { prefix: '/identity' })
  fastify.register(require('./contexts/ordering'),  { prefix: '/orders' })
  fastify.register(require('./contexts/inventory'), { prefix: '/inventory' })
})
```

---

### Domain Events

Domain events communicate that something meaningful happened in the domain. They decouple bounded contexts:

```js
// plugins/03-event-bus.js
'use strict'

const fp = require('fastify-plugin')
const { EventEmitter } = require('node:events')

module.exports = fp(async function eventBusPlugin (fastify) {
  const bus = new EventEmitter()

  fastify.decorate('eventBus', {
    publish (event, payload) {
      fastify.log.info({ event, payload }, 'Domain event published')
      bus.emit(event, payload)
    },
    subscribe (event, handler) {
      bus.on(event, handler)
    }
  })
}, { name: 'event-bus' })
```

The ordering context publishes; the inventory context subscribes:

```js
// contexts/inventory/index.js
async function inventoryContext (fastify, opts) {
  const inventoryService = new InventoryService(...)

  // React to domain events from ordering context
  fastify.eventBus.subscribe('order.placed', async ({ orderId, customerId }) => {
    await inventoryService.reserveItemsForOrder(orderId)
  })

  fastify.register(require('./presentation/routes'))
}

module.exports = inventoryContext
```

> [Inference] Using Node.js `EventEmitter` as an in-process event bus is appropriate for single-instance applications. For distributed systems or multi-instance deployments, an external message broker (Redis Streams, RabbitMQ, Kafka) would be necessary. Behavior of in-process events under high concurrency should be evaluated per use case.

---

### Error Mapping: Domain to HTTP

Domain errors carry business meaning but not HTTP semantics. A custom error handler translates them:

```js
// plugins/04-error-handler.js
'use strict'

const fp = require('fastify-plugin')

module.exports = fp(async function errorHandlerPlugin (fastify) {
  fastify.setErrorHandler(async (error, req, reply) => {
    const statusCode = error.statusCode ?? 500

    if (statusCode >= 500) {
      fastify.log.error({ err: error }, 'Unhandled error')
    } else {
      fastify.log.warn({ err: error }, 'Client error')
    }

    return reply.code(statusCode).send({
      error: error.message,
      statusCode
    })
  })
})
```

Domain errors are thrown with `statusCode` attached:

```js
// In domain or application layer
const err = new Error('Cannot place an empty order')
err.statusCode = 422
throw err
```

---

### Testing in a DDD Structure

#### Unit Testing Domain Logic

No Fastify, no database — pure unit tests:

```js
// test/contexts/ordering/domain/Order.test.js
const { test } = require('node:test')
const Order = require('../../../../src/contexts/ordering/domain/Order')
const Money = require('../../../../src/contexts/ordering/domain/Money')

test('Order: cannot add line to non-draft order', (t) => {
  const order = new Order({ customerId: 'user-1', status: 'placed' })
  t.assert.throws(
    () => order.addLine({ productId: 'p1', quantity: 1, unitPrice: new Money(10) }),
    /Cannot modify a non-draft order/
  )
})

test('Order: total sums all line subtotals', (t) => {
  const order = new Order({ customerId: 'user-1' })
  order.addLine({ productId: 'p1', quantity: 2, unitPrice: new Money(15) })
  order.addLine({ productId: 'p2', quantity: 1, unitPrice: new Money(10) })
  t.assert.equal(order.total.amount, 40)
})
```

#### Unit Testing Application Service

```js
// test/contexts/ordering/application/OrderService.test.js
const { test } = require('node:test')
const OrderService = require('../../../../src/contexts/ordering/application/OrderService')

test('placeOrder: throws if order not found', async (t) => {
  const service = new OrderService({
    orderRepository: { findById: async () => null, save: async () => {} },
    eventBus: { publish: async () => {} }
  })

  await t.assert.rejects(
    () => service.placeOrder({ orderId: 'nonexistent' }),
    /Order not found/
  )
})
```

#### Integration Testing via Fastify Injection

```js
// test/contexts/ordering/presentation/routes.test.js
const { test } = require('node:test')
const { build } = require('../../../helper')

test('POST /orders creates a new order', async (t) => {
  const app = await build(t)
  const res = await app.inject({
    method: 'POST',
    url: '/orders',
    headers: { authorization: 'Bearer test-token' }
  })
  t.assert.equal(res.statusCode, 201)
  t.assert.ok(JSON.parse(res.payload).id)
})
```

---

### DDD in Fastify — Practical Boundaries

Not every application warrants full DDD. The approach adds structural overhead that pays off under specific conditions:

| Condition | DDD Appropriate? |
|---|---|
| Complex business rules that change frequently | Yes |
| Multiple bounded contexts with independent lifecycles | Yes |
| Large teams where domain ownership matters | Yes |
| Simple CRUD with little business logic | No — over-engineering |
| Rapid prototype or MVP | No — premature structure |
| Single developer, small scope | No — flat structure is simpler |

> [Inference] The value of DDD is proportional to the complexity of the business rules being modeled. Applying full DDD to a simple REST API adds structural cost without corresponding benefit.

---

**Related Topics:**
- Fastify encapsulation and bounded context isolation
- Repository pattern with `pg`, `knex`, or an ORM
- Domain event patterns and in-process vs. external event buses
- Error handling strategies: domain errors to HTTP responses
- TypeScript interfaces for repository contracts and entity typing
- Feature flags and conditional context registration
- CQRS (Command Query Responsibility Segregation) with Fastify
- Testing strategies: unit, integration, and end-to-end in layered architectures
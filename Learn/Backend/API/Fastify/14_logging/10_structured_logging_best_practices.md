## Structured Logging Best Practices

Structured logging means emitting log records as machine-parseable data — typically JSON — rather than free-form strings. Fastify's built-in Pino logger produces JSON by default, making it a strong foundation. The practices below focus on how to use that foundation consistently and effectively.

---

### Why Structure Matters

Free-form log strings require regex or manual parsing to extract meaning. Structured logs allow log aggregation platforms (Loki, Elasticsearch, Datadog, etc.) to index, filter, and alert on specific fields without parsing.

**Example — unstructured vs structured**

```js
// Unstructured — harder to query
fastify.log.info(`User 42 purchased item 99 for $19.99`)

// Structured — fields are queryable
fastify.log.info({ userId: 42, itemId: 99, amount: 19.99 }, 'Purchase completed')
```

In Pino, the first argument to a log method can be an object of additional fields. Those fields are merged into the top-level JSON record alongside `level`, `time`, `msg`, and other default fields.

---

### Pino Log Method Signature

Understanding the correct call signature avoids accidentally losing structured data.

```js
// Correct — object first, message string second
fastify.log.info({ key: 'value' }, 'Human-readable message')

// Also valid — message only
fastify.log.info('Simple message')

// Incorrect — object as second argument is ignored by Pino
fastify.log.info('message', { key: 'value' }) // fields are NOT logged
```

**Key Points**
- Always pass the data object as the **first** argument
- The message string is the **second** argument
- Reversing this order silently drops your structured fields — Pino does not throw an error

---

### Use Consistent Field Names

Inconsistent field naming across log lines makes querying unreliable.

```js
// Inconsistent — same concept, different names
fastify.log.info({ user_id: 42 }, 'Login')
fastify.log.info({ userId: 42 }, 'Logout')
fastify.log.info({ uid: 42 }, 'Password changed')

// Consistent — one canonical name throughout
fastify.log.info({ userId: 42 }, 'Login')
fastify.log.info({ userId: 42 }, 'Logout')
fastify.log.info({ userId: 42 }, 'Password changed')
```

**Key Points**
- Define a field naming convention (e.g., camelCase) and apply it across the entire codebase
- Consider documenting a log schema or field dictionary for your team
- [Inference] Inconsistent field names are one of the most common causes of failed log queries in production — though actual impact depends on your query tooling and team practices

---

### Add Context with Child Loggers

Pino's `child()` method creates a new logger instance that inherits all fields from the parent and permanently attaches additional fields to every record it emits.

```js
fastify.get('/orders/:orderId', async (request, reply) => {
  const log = request.log.child({ orderId: request.params.orderId, userId: request.user.id })

  log.info('Fetching order')
  // { "orderId": "123", "userId": 42, "msg": "Fetching order", ... }

  const order = await getOrder(request.params.orderId)
  log.info({ itemCount: order.items.length }, 'Order fetched')
  // { "orderId": "123", "userId": 42, "itemCount": 5, "msg": "Order fetched", ... }
})
```

**Key Points**
- `request.log` is already a child logger with `reqId` attached by Fastify
- Further child loggers layer additional context without repeating fields on every call
- Child loggers are cheap to create — Pino shares the parent's stream

---

### Attach Request Context Automatically

Fastify automatically attaches a `reqId` to `request.log`. Always prefer `request.log` over `fastify.log` inside route handlers and hooks, so every log line is traceable to a specific request.

```js
fastify.addHook('onRequest', async (request, reply) => {
  request.log.info({ method: request.method, url: request.url }, 'Incoming request')
})

fastify.get('/users/:id', async (request, reply) => {
  request.log.info({ userId: request.params.id }, 'Handling user lookup')
})
```

Using `fastify.log` inside a request handler produces a log line with no `reqId`, making it impossible to correlate with a specific request in a high-concurrency environment.

---

### Avoid Logging Sensitive Data

Structured logs are easy to search, which also means sensitive values are easy to expose. Never log:

- Passwords or secrets
- Full credit card numbers or PAN data
- Authentication tokens or session IDs in plain form
- Personally identifiable information (PII) unless explicitly required and authorized

Pino provides a `redact` option to automatically remove or mask fields by path.

```js
const fastify = require('fastify')({
  logger: {
    redact: {
      paths: ['req.headers.authorization', 'req.body.password', 'req.body.cardNumber'],
      censor: '[REDACTED]'
    }
  }
})
```

**Key Points**
- `paths` uses a dot-notation or bracket-notation path syntax
- Wildcards are supported: `'req.headers["*"]'` redacts all headers
- Redaction happens before serialization — the sensitive value never reaches the transport
- [Inference] Redaction covers fields you explicitly list; fields you forget to list are not redacted — there is no automatic PII detection

---

### Use Appropriate Log Levels

Pino (and Fastify by extension) supports these levels in ascending severity:

| Level | Value | Intended Use |
|---|---|---|
| `trace` | 10 | Very fine-grained, high-frequency diagnostics |
| `debug` | 20 | Development diagnostics, internal state |
| `info` | 30 | Normal operational events |
| `warn` | 40 | Unexpected but recoverable situations |
| `error` | 50 | Errors that affect a single operation |
| `fatal` | 60 | Errors that require process termination |

```js
fastify.log.debug({ query: sql }, 'Executing query')
fastify.log.info({ userId }, 'User authenticated')
fastify.log.warn({ retries }, 'Upstream slow, retrying')
fastify.log.error({ err }, 'Payment failed')
fastify.log.fatal({ err }, 'Database connection lost, shutting down')
```

**Key Points**
- Set `level: 'info'` in production; `level: 'debug'` in development
- Do not use `info` for every event — reserve it for genuinely meaningful operational milestones
- `trace` produces very high log volume; enable it only for targeted diagnostics

---

### Log Errors Correctly

Pino has built-in support for serializing `Error` objects when passed under the `err` key (by convention, matching Pino's default error serializer).

```js
try {
  await riskyOperation()
} catch (err) {
  request.log.error({ err }, 'Operation failed')
}
```

This produces a structured record with `err.message`, `err.stack`, and `err.type` as separate fields rather than a stringified blob.

**Key Points**
- Always use the key `err` (not `error`) unless you have reconfigured Pino's serializers — the default serializer is keyed to `err`
- Never log `err.message` as the `msg` string alone — you lose the stack trace
- Do not pass the error object as the first argument without a key: `fastify.log.error(err)` serializes it differently and may not use the error serializer depending on the Pino version

---

### Keep Messages Static, Data Dynamic

Log messages should be stable strings that can be searched and aggregated. Variable data belongs in fields, not in the message string.

```js
// Avoid — message changes with every user; cannot aggregate
fastify.log.info(`User ${userId} logged in from ${ip}`)

// Prefer — message is stable; data is queryable
fastify.log.info({ userId, ip }, 'User logged in')
```

Static messages allow log platforms to group and count events by message. Dynamic messages fragment those groups.

---

### Include Correlation IDs for Distributed Systems

In microservice architectures, a single user action may span multiple services. A correlation ID (also called a trace ID) passed through request headers allows log lines from different services to be linked.

```js
fastify.addHook('onRequest', async (request, reply) => {
  const correlationId = request.headers['x-correlation-id'] || generateId()
  request.correlationId = correlationId
  request.log = request.log.child({ correlationId })
  reply.header('x-correlation-id', correlationId)
})
```

Every subsequent `request.log` call in that request's lifecycle automatically includes `correlationId`.

**Key Points**
- Propagate the same ID to any downstream HTTP calls your service makes
- This pattern complements but does not replace OpenTelemetry trace propagation — [Inference] for full distributed tracing, a dedicated tracing solution provides more capability than log correlation alone
- Behavior depends on your log aggregation platform supporting cross-service field queries

---

### Avoid Excessive Logging

High log volume has real costs: storage, ingestion fees, and increased noise when investigating incidents.

**Practices to reduce unnecessary volume**
- Do not log every iteration of a tight loop
- Avoid logging at `info` inside frequently called middleware unless conditionally gated
- Use sampling for high-frequency events where appropriate

```js
// Example — log only a fraction of health check requests
fastify.get('/health', async (request, reply) => {
  if (Math.random() < 0.01) {
    request.log.info('Health check sampled')
  }
  return { status: 'ok' }
})
```

[Inference] The appropriate sampling rate depends on your traffic volume and monitoring requirements — there is no universal value.

---

### Serialize Objects Deliberately

Avoid passing large or deeply nested objects directly into log records. They inflate log size, may expose unintended fields, and can trigger slow serialization.

```js
// Avoid — logs entire user object including sensitive fields
fastify.log.info({ user }, 'User loaded')

// Prefer — log only what is necessary
fastify.log.info({ userId: user.id, role: user.role }, 'User loaded')
```

For complex objects that appear frequently in logs, define a custom Pino serializer.

```js
const fastify = require('fastify')({
  logger: {
    serializers: {
      user (user) {
        return { id: user.id, role: user.role }
      }
    }
  }
})
```

---

### Custom Serializers for req and res

Fastify pre-configures Pino serializers for `req` and `res`. You can override them to control exactly which request and response fields appear in logs.

```js
const fastify = require('fastify')({
  logger: {
    serializers: {
      req (request) {
        return {
          method: request.method,
          url: request.url,
          userAgent: request.headers['user-agent']
        }
      },
      res (reply) {
        return {
          statusCode: reply.statusCode
        }
      }
    }
  }
})
```

**Key Points**
- The `req` serializer receives the raw Node.js `IncomingMessage`, not the Fastify request object
- Keeping serializers lean reduces per-request log size

---

### Do Not Use String Concatenation or Template Literals for Log Data

```js
// Avoid
fastify.log.info('Processing request for user ' + userId + ' on route ' + route)

// Prefer
fastify.log.info({ userId, route }, 'Processing request')
```

String concatenation:
- Produces unstable, non-queryable messages
- Incurs string allocation cost even when the log level is disabled
- Loses the ability to index individual values

Pino's level checks are very fast, but string interpolation happens before the level check.

---

### Check Log Level Before Expensive Operations

If building a log argument requires non-trivial computation, guard it with a level check.

```js
if (fastify.log.isLevelEnabled('debug')) {
  const diagnostics = computeExpensiveDiagnostics()
  fastify.log.debug({ diagnostics }, 'Diagnostic snapshot')
}
```

**Key Points**
- `isLevelEnabled(level)` returns a boolean
- This pattern avoids the computation entirely when the level is disabled
- [Inference] For simple object literals, the overhead is typically negligible; guarding is most valuable when the argument construction itself is costly

---

### Summary of Key Practices

| Practice | Reason |
|---|---|
| Object first, message second | Prevents silent field loss |
| Consistent field names | Enables reliable querying |
| Use `request.log` in handlers | Preserves `reqId` correlation |
| Redact sensitive fields | Prevents data exposure |
| Static messages, dynamic fields | Enables log aggregation |
| Use `err` key for errors | Activates Pino's error serializer |
| Avoid large object serialization | Reduces size and exposure risk |
| Guard expensive log arguments | Avoids unnecessary computation |

---

**Conclusion**

Structured logging's value is only realized when records are consistently shaped, fields are named predictably, sensitive data is excluded, and log levels are used with discipline. Fastify's Pino integration provides the right primitives — child loggers, redaction, serializers, and level checks — to implement these practices without significant overhead. The patterns here apply at the application level; [Inference] actual query performance and alerting effectiveness depend on the log platform and indexing configuration used in your environment.
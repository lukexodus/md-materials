## Fastify — `fastify.decorateReply`

### Overview

`fastify.decorateReply` is the official API for adding custom properties or methods to the `Reply` object in Fastify. It mirrors `decorateRequest` in design and intent, but targets `reply.*` instead. It is used to attach shared utilities, state, or helper methods that route handlers and hooks can access through the reply object.

---

### Why Use `decorateReply` Instead of Direct Assignment

The same V8 hidden class reasoning that applies to `decorateRequest` applies here. Fastify manages the shape of its `Reply` object internally. Declaring properties upfront via `decorateReply` allows the JavaScript engine to maintain a consistent object shape across all replies.

> **Disclaimer:** V8 optimization behavior is an [Inference] based on how JavaScript engines handle object shapes. Actual performance impact may vary depending on runtime version, load patterns, and usage.

---

### Syntax

js

```
fastify.decorateReply(name, defaultValue)
fastify.decorateReply(name, defaultValue, dependencies)
```

| Parameter | Type | Description |
| --- | --- | --- |
| `name` | `string` | The property name to add to `Reply` |
| `defaultValue` | `any` | The initial value for each reply instance |
| `dependencies` | `string[]` | Optional. Other decorators this one depends on |

---

### Basic Usage

js

```
import Fastify from 'fastify'

const fastify = Fastify()

fastify.decorateReply('requestStartTime', null)

fastify.addHook('onRequest', async (request, reply) => {
  reply.requestStartTime = Date.now()
})

fastify.get('/ping', async (request, reply) => {
  const elapsed = Date.now() - reply.requestStartTime
  return { elapsed }
})

await fastify.listen({ port: 3000 })
```

**Output** (GET `/ping`):

json

```
{
  "elapsed": 2
}
```

**Key Points:**

- `decorateReply('requestStartTime', null)` registers the property with a `null` default
- The `onRequest` hook assigns the value at the start of each request lifecycle
- The handler reads it from `reply.requestStartTime`

---

### Default Value Behavior

The same rules that govern `decorateRequest` apply here.

#### Scalar defaults (safe)

js

```
fastify.decorateReply('sent', false)
fastify.decorateReply('statusLabel', '')
fastify.decorateReply('attemptCount', 0)
```

Scalars are safe as default values because they are not shared references.

#### Reference type defaults (requires caution)

js

```
// ⚠️ Problematic — object is shared across all replies
fastify.decorateReply('meta', { cached: false })
```

Fastify emits a **warning** when a reference type is used as `defaultValue`, for the same reason as with `decorateRequest`: the object reference is shared, not copied, across reply instances.

**Correct approach:**

js

```
fastify.decorateReply('meta', null)

fastify.addHook('onRequest', async (request, reply) => {
  reply.meta = { cached: false }
})
```

> **Disclaimer:** Cross-reply state leakage via shared references is based on Fastify's documented behavior. Actual consequences may vary by usage pattern and Fastify version.

---

### Attaching Helper Methods

A common and practical use of `decorateReply` is attaching response helper methods — functions that standardize how responses are structured and sent.

js

```
fastify.decorateReply('sendSuccess', null)
fastify.decorateReply('sendError', null)

fastify.addHook('onRequest', async (request, reply) => {
  reply.sendSuccess = (data) => reply.code(200).send({ ok: true, data })
  reply.sendError = (message, code = 400) =>
    reply.code(code).send({ ok: false, error: message })
})

fastify.get('/user/:id', async (request, reply) => {
  const id = Number(request.params.id)

  if (isNaN(id)) {
    return reply.sendError('Invalid user ID')
  }

  return reply.sendSuccess({ id, name: 'Ada' })
})
```

**Output** (GET `/user/abc`):

json

```
{
  "ok": false,
  "error": "Invalid user ID"
}
```

**Output** (GET `/user/1`):

json

```
{
  "ok": true,
  "data": { "id": 1, "name": "Ada" }
}
```

**Key Points:**

- Helper methods are assigned in a hook so they have access to the per-request `reply` instance
- This centralizes response formatting logic and keeps handlers clean
- [Inference] This pattern is particularly useful in APIs with consistent response envelope structures. Behavior depends on implementation.

---

### Using with Plugins and Encapsulation

Like `decorateRequest`, `decorateReply` follows Fastify's encapsulation model. Decorators registered at root level are available everywhere; those registered inside a plugin are scoped to that plugin and its children.

js

```
// root-level — available in all routes
fastify.decorateReply('requestId', null)

fastify.register(async function (instance) {
  // plugin-scoped — only available within this plugin
  instance.decorateReply('traceId', null)

  instance.get('/trace', async (request, reply) => {
    reply.traceId = 'abc-123'
    return { traceId: reply.traceId }
  })
})

fastify.get('/outside', async (request, reply) => {
  // reply.traceId is undefined here
  return { requestId: reply.requestId }
})
```

---

### Dependency Declaration

When one reply decorator depends on another being present, declare the dependency explicitly.

js

```
fastify.decorateReply('requestStartTime', null)

fastify.decorateReply('elapsedMs', null, ['requestStartTime'])
// Fastify ensures 'requestStartTime' is registered before 'elapsedMs'
```

If a declared dependency is not registered, Fastify throws an error at startup — not at request time.

---

### TypeScript Support

Augment the `FastifyReply` interface to get type-safe access to custom reply decorators.

ts

```
import Fastify, { FastifyReply } from 'fastify'

declare module 'fastify' {
  interface FastifyReply {
    sendSuccess: (data: unknown) => void
    sendError: (message: string, code?: number) => void
    requestStartTime: number | null
  }
}

const fastify = Fastify()

fastify.decorateReply('requestStartTime', null)
fastify.decorateReply('sendSuccess', null)
fastify.decorateReply('sendError', null)

fastify.addHook('onRequest', async (request, reply: FastifyReply) => {
  reply.requestStartTime = Date.now()
  reply.sendSuccess = (data) => reply.code(200).send({ ok: true, data })
  reply.sendError = (message, code = 400) =>
    reply.code(code).send({ ok: false, error: message })
})
```

**Key Points:**

- Augment `FastifyReply` (not `FastifyRequest`) for reply decorator types
- Method signatures in the interface should match what is assigned in hooks
- Without augmentation, TypeScript will report errors on `reply.*` custom properties

---

### Comparing `decorateReply` and `decorateRequest`

| Aspect | `decorateRequest` | `decorateReply` |
| --- | --- | --- |
| Target object | `request.*` | `reply.*` |
| Typical use | Auth state, parsed input, user context | Response helpers, timing, trace headers |
| Default value rules | Same | Same |
| Encapsulation | Plugin-scoped | Plugin-scoped |
| TypeScript augmentation | `FastifyRequest` | `FastifyReply` |
| Lifecycle assignment | `onRequest`, `preHandler` | `onRequest`, `onSend` |

---

### Common Mistakes

| Mistake | Problem | Fix |
| --- | --- | --- |
| Passing object/array as `defaultValue` | Shared reference across replies | Use `null`; assign in a hook |
| Defining inside a route handler | Too late in lifecycle | Register during setup phase |
| Calling `reply.send()` inside a helper without returning | May cause double-send issues | Return the result of `reply.send()` or use carefully |
| Missing TypeScript augmentation | Type errors on `reply.*` | Augment `FastifyReply` interface |

---

### Lifecycle Position

```
Server Setup          Per-Request Lifecycle
──────────────────    ──────────────────────────────────────────────────
decorateReply     →   onRequest → preHandler → handler → onSend → onResponse
(registers shape)     (assign value)           (use value)
```

`decorateReply` registers the property shape once at setup. Per-request values are assigned in hooks early in the lifecycle and consumed in handlers or later hooks.

---

### Summary

| Feature | Detail |
| --- | --- |
| Purpose | Add properties/methods to `Reply` safely |
| Default scalar values | Safe — not shared across replies |
| Default reference values | Unsafe — use `null` + hook assignment |
| Scope | Follows Fastify's plugin encapsulation |
| TypeScript | Requires `FastifyReply` interface augmentation |
| Dependencies | Declared via third argument `string[]` |
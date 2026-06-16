## Fastify — `fastify.decorateRequest`

### Overview

`fastify.decorateRequest` is the official API for adding custom properties or methods to the `Request` object in Fastify. It allows plugins, hooks, and route handlers to access shared functionality or state through `request.*` without mutating the prototype directly in an uncontrolled way.

---

### Why Use `decorateRequest` Instead of Direct Assignment

Fastify manages its `Request` object internally. Directly assigning properties to `request` inside a handler (e.g., `request.myProp = value`) works at runtime but bypasses Fastify's initialization system and can cause performance degradation in V8 due to hidden class (shape) changes on objects.

`decorateRequest` declares the property upfront, so V8 can optimize the object shape consistently across all requests.

> **Disclaimer:** V8 optimization behavior is an [Inference] based on how JavaScript engines handle object shapes. Actual performance impact may vary depending on runtime version, load patterns, and usage.

---

### Syntax

js

```
fastify.decorateRequest(name, defaultValue)
fastify.decorateRequest(name, defaultValue, dependencies)
```

| Parameter | Type | Description |
| --- | --- | --- |
| `name` | `string` | The property name to add to `Request` |
| `defaultValue` | `any` | The initial value for each request instance |
| `dependencies` | `string[]` | Optional. Other decorators this one depends on |

---

### Basic Usage

js

```
import Fastify from 'fastify'

const fastify = Fastify()

fastify.decorateRequest('user', null)

fastify.addHook('preHandler', async (request, reply) => {
  request.user = { id: 42, name: 'Ada' }
})

fastify.get('/profile', async (request, reply) => {
  return { user: request.user }
})

await fastify.listen({ port: 3000 })
```

**Output** (GET `/profile`):

json

```
{
  "user": { "id": 42, "name": "Ada" }
}
```

**Key Points:**

- `decorateRequest('user', null)` registers the property with a `null` default
- The hook populates it per-request before the handler runs
- The handler reads it safely via `request.user`

---

### Default Value Behavior

The `defaultValue` is used to initialize the property for every incoming request. Fastify handles this per-request, not as a shared reference — **with an important caveat for reference types**.

#### Scalar defaults (safe)

js

```
fastify.decorateRequest('requestId', '')
fastify.decorateRequest('retryCount', 0)
fastify.decorateRequest('isAuthenticated', false)
```

Scalars (`string`, `number`, `boolean`, `null`) are safe as default values because they are copied by value.

#### Reference type defaults (requires caution)

js

```
// ⚠️ Problematic — object is shared across requests
fastify.decorateRequest('meta', { role: 'guest' })
```

Fastify will emit a **warning** when a reference type (object or array) is passed as `defaultValue`. This is because the same object reference would be shared across all requests, leading to cross-request state leakage.

**Correct approach — use `null` and assign per request:**

js

```
fastify.decorateRequest('meta', null)

fastify.addHook('onRequest', async (request) => {
  request.meta = { role: 'guest' }
})
```

> **Disclaimer:** Behavior of shared references across requests is based on Fastify's documented warnings. Actual consequences may vary by usage pattern.

---

### Using with Plugins and Encapsulation

`decorateRequest` respects Fastify's encapsulation model. A decorator registered inside a plugin is available only within that plugin's scope and its children — unless registered at the root level.

js

```
// root-level — available everywhere
fastify.decorateRequest('user', null)

fastify.register(async function (instance) {
  // plugin-level — only available in this scope
  instance.decorateRequest('tenantId', null)

  instance.get('/tenant', async (request) => {
    return { tenantId: request.tenantId }
  })
})

fastify.get('/outside', async (request) => {
  // request.tenantId is undefined here — out of scope
  return { user: request.user }
})
```

**Key Points:**

- Root-level decorators are available in all routes
- Plugin-scoped decorators are not accessible outside their scope
- Attempting to access an out-of-scope decorator returns `undefined` at runtime — Fastify does not throw by default in this case [Inference — behavior may vary by version]

---

### Dependency Declaration

When one decorator depends on another, declare it explicitly using the third argument. This allows Fastify to enforce initialization order.

js

```
fastify.decorateRequest('user', null)

fastify.decorateRequest('isAdmin', null, ['user'])
// 'isAdmin' can safely assume 'user' exists when initialized
```

If a listed dependency is not registered, Fastify throws an error during startup.

---

### Using `decorateRequest` for Methods

You can attach functions to the request object as well.

js

```
fastify.decorateRequest('logContext', null)

fastify.addHook('onRequest', async (request) => {
  request.logContext = () => ({
    id: request.id,
    method: request.method,
    url: request.url,
  })
})

fastify.get('/debug', async (request) => {
  return request.logContext()
})
```

**Output** (GET `/debug`):

json

```
{
  "id": "req-1",
  "method": "GET",
  "url": "/debug"
}
```

> [Inference] Attaching functions via `decorateRequest` with a `null` default and assigning them in a hook is the recommended pattern when the function needs per-request context. Behavior may vary by Fastify version.

---

### TypeScript Support

In TypeScript, you must augment the `FastifyRequest` interface to get type-safe access to custom decorators.

ts

```
import Fastify, { FastifyRequest } from 'fastify'

declare module 'fastify' {
  interface FastifyRequest {
    user: { id: number; name: string } | null
  }
}

const fastify = Fastify()

fastify.decorateRequest('user', null)

fastify.addHook('preHandler', async (request: FastifyRequest) => {
  request.user = { id: 1, name: 'Ada' }
})

fastify.get('/me', async (request) => {
  return request.user
})
```

**Key Points:**

- Module augmentation on `FastifyRequest` is required for TypeScript recognition
- Without augmentation, accessing `request.user` causes a TypeScript error
- The declared type should match what is actually assigned at runtime

---

### Common Mistakes

| Mistake | Problem | Fix |
| --- | --- | --- |
| Passing an object/array as `defaultValue` | Shared reference across requests | Use `null`; assign in a hook |
| Assigning without registering first | V8 hidden class change; Fastify warning | Always call `decorateRequest` before use |
| Registering inside a route handler | Too late in lifecycle | Register at plugin or root setup time |
| Forgetting TypeScript augmentation | Type errors on `request.*` | Augment `FastifyRequest` interface |

---

### Lifecycle Position

`decorateRequest` is called during **server setup**, before any request arrives. The actual per-request value is typically set inside a **hook** (commonly `onRequest` or `preHandler`), then consumed in the **route handler**.

```
Server Setup         Per-Request Lifecycle
─────────────────    ─────────────────────────────────────────────
decorateRequest  →   onRequest → preHandler → handler → onSend
(registers shape)    (assign value)           (read value)
```

---

### Summary

| Feature                  | Detail                                           |
| ------------------------ | ------------------------------------------------ |
| Purpose                  | Add properties/methods to `Request` safely       |
| Default scalar values    | Safe — copied per request                        |
| Default reference values | Unsafe — use `null` + hook assignment            |
| Scope                    | Follows Fastify's plugin encapsulation           |
| TypeScript               | Requires `FastifyRequest` interface augmentation |
| Dependencies             | Declared via third argument `string[]`           |
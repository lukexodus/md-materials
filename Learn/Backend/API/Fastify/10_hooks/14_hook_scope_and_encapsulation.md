## Fastify Hooks — Scope and Encapsulation

### Overview

Fastify's plugin system is built on encapsulation — each plugin operates within its own isolated scope unless explicitly configured otherwise. Hooks follow the same encapsulation rules. Understanding how hook scope interacts with plugin boundaries is essential for building predictable, well-structured Fastify applications.

---

### The Encapsulation Model

Fastify uses a tree-based architecture where the root instance is the trunk and each registered plugin is a child node. A child inherits from its parent but cannot affect its siblings or ancestors.

This means:
- A hook registered on the **root** instance applies to **all routes** in the application
- A hook registered inside a **scoped plugin** applies only to routes within that plugin and its descendants
- A hook registered in one scoped plugin does **not** affect sibling plugins

The diagram below illustrates this:

<svg viewBox="0 0 720 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Root -->
  <rect x="270" y="20" width="180" height="44" rx="8" fill="#4f46e5" opacity="0.15" stroke="#4f46e5" stroke-width="1.5"/>
  <text x="360" y="38" text-anchor="middle" fill="#4f46e5" font-weight="bold" font-size="13">Root Instance</text>
  <text x="360" y="55" text-anchor="middle" fill="#4f46e5" font-size="11">onRequest hook (root)</text>

  <!-- Lines root to children -->
  <line x1="360" y1="64" x2="160" y2="130" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="5,3"/>
  <line x1="360" y1="64" x2="360" y2="130" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="5,3"/>
  <line x1="360" y1="64" x2="560" y2="130" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="5,3"/>

  <!-- Plugin A -->
  <rect x="60" y="130" width="200" height="54" rx="8" fill="#0891b2" opacity="0.12" stroke="#0891b2" stroke-width="1.5"/>
  <text x="160" y="150" text-anchor="middle" fill="#0891b2" font-weight="bold">Plugin A (scoped)</text>
  <text x="160" y="168" text-anchor="middle" fill="#0891b2" font-size="11">preHandler hook (A only)</text>

  <!-- Plugin B (fp) -->
  <rect x="270" y="130" width="180" height="54" rx="8" fill="#059669" opacity="0.12" stroke="#059669" stroke-width="1.5"/>
  <text x="360" y="150" text-anchor="middle" fill="#059669" font-weight="bold">Plugin B (fp)</text>
  <text x="360" y="168" text-anchor="middle" fill="#059669" font-size="11">onSend hook (global)</text>

  <!-- Plugin C -->
  <rect x="460" y="130" width="200" height="54" rx="8" fill="#0891b2" opacity="0.12" stroke="#0891b2" stroke-width="1.5"/>
  <text x="560" y="150" text-anchor="middle" fill="#0891b2" font-weight="bold">Plugin C (scoped)</text>
  <text x="560" y="168" text-anchor="middle" fill="#0891b2" font-size="11">preHandler hook (C only)</text>

  <!-- Lines A to children -->
  <line x1="160" y1="184" x2="100" y2="260" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="5,3"/>
  <line x1="160" y1="184" x2="220" y2="260" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="5,3"/>

  <!-- Route A1 -->
  <rect x="40" y="260" width="120" height="36" rx="6" fill="#e2e8f0" stroke="#94a3b8" stroke-width="1"/>
  <text x="100" y="283" text-anchor="middle" fill="#334155" font-size="12">GET /a/one</text>

  <!-- Route A2 -->
  <rect x="170" y="260" width="120" height="36" rx="6" fill="#e2e8f0" stroke="#94a3b8" stroke-width="1"/>
  <text x="230" y="283" text-anchor="middle" fill="#334155" font-size="12">GET /a/two</text>

  <!-- Line C to child -->
  <line x1="560" y1="184" x2="560" y2="260" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="5,3"/>

  <!-- Route C1 -->
  <rect x="500" y="260" width="120" height="36" rx="6" fill="#e2e8f0" stroke="#94a3b8" stroke-width="1"/>
  <text x="560" y="283" text-anchor="middle" fill="#334155" font-size="12">GET /c/one</text>

  <!-- Legend -->
  <rect x="40" y="340" width="640" height="62" rx="6" fill="#f8fafc" stroke="#e2e8f0" stroke-width="1"/>
  <rect x="56" y="356" width="12" height="12" fill="#4f46e5" opacity="0.5" rx="2"/>
  <text x="74" y="367" fill="#334155" font-size="11">Root hook → applies to ALL routes</text>
  <rect x="56" y="376" width="12" height="12" fill="#059669" opacity="0.5" rx="2"/>
  <text x="74" y="387" fill="#334155" font-size="11">fp plugin hook → promoted to root scope → applies to ALL routes</text>
  <rect x="320" y="356" width="12" height="12" fill="#0891b2" opacity="0.5" rx="2"/>
  <text x="338" y="367" fill="#334155" font-size="11">Scoped plugin hook → applies ONLY within that plugin's routes</text>
</svg>

---

### Root-Level Hooks

A hook registered directly on the root `fastify` instance applies globally — every route in the application will pass through it, regardless of which plugin registered that route.

```js
const fastify = Fastify({ logger: true });

fastify.addHook('onRequest', async (request, reply) => {
  request.log.info('Global onRequest fired for: %s', request.url);
});

fastify.get('/root-route', async () => ({ from: 'root' }));

fastify.register(async function pluginA(instance) {
  instance.get('/plugin-a', async () => ({ from: 'pluginA' }));
});
```

**Both** `GET /root-route` and `GET /plugin-a` will trigger the root-level `onRequest` hook.

---

### Scoped Plugin Hooks

A hook registered inside a plugin that does **not** use `fastify-plugin` is scoped to that plugin. It does not affect the root instance or sibling plugins.

```js
fastify.register(async function pluginA(instance) {
  instance.addHook('preHandler', async (request, reply) => {
    request.log.info('Plugin A preHandler');
  });

  instance.get('/a', async () => ({ from: 'a' }));
});

fastify.register(async function pluginB(instance) {
  // Plugin A's preHandler does NOT fire here
  instance.get('/b', async () => ({ from: 'b' }));
});

fastify.get('/root', async () => ({ from: 'root' }));
```

**Hook coverage:**

| Route | Root hooks | Plugin A `preHandler` | Plugin B hooks |
|---|---|---|---|
| `GET /root` | ✅ | ❌ | ❌ |
| `GET /a` | ✅ | ✅ | ❌ |
| `GET /b` | ✅ | ❌ | ❌ |

---

### Breaking Encapsulation with fastify-plugin

Wrapping a plugin with `fastify-plugin` (`fp`) causes Fastify to skip creating a new child scope. Decorators, hooks, and other registrations made inside the plugin are promoted to the **parent scope** — effectively making them global when applied at the root level.

```js
import fp from 'fastify-plugin';

async function authPlugin(instance, options) {
  instance.addHook('onRequest', async (request, reply) => {
    if (!request.headers.authorization) {
      reply.code(401).send({ error: 'Unauthorized' });
    }
  });
}

fastify.register(fp(authPlugin));

fastify.get('/protected', async () => ({ secret: true }));
fastify.get('/also-protected', async () => ({ secret: true }));
```

Because `fp` breaks encapsulation, the `onRequest` hook applies to all routes — including those registered after the plugin.

> **Disclaimer:** The order in which plugins are registered relative to route definitions matters. A hook promoted via `fp` still only applies to routes registered after the hook is in place during the initialization phase. [Inference]

---

### Hook Inheritance — Child Scopes

Child plugins inherit hooks from their parent scope. A hook registered at the root is visible to all descendants. A hook registered in a parent plugin is visible to that plugin's child plugins.

```js
fastify.addHook('onRequest', async (request) => {
  request.log.info('Root onRequest');
});

fastify.register(async function parent(parentInstance) {
  parentInstance.addHook('preHandler', async (request) => {
    request.log.info('Parent preHandler');
  });

  // Child inherits both root onRequest AND parent preHandler
  parentInstance.register(async function child(childInstance) {
    childInstance.get('/child-route', async () => ({ level: 'child' }));
  });
});
```

For `GET /child-route`, both hooks fire:
1. Root `onRequest`
2. Parent `preHandler`

---

### Hook Isolation — Siblings Cannot Share

Hooks registered in one scoped plugin are invisible to its siblings. There is no lateral inheritance.

```js
fastify.register(async function pluginA(instance) {
  instance.addHook('onSend', async (request, reply, payload) => {
    request.log.info('Plugin A onSend');
    return payload;
  });
  instance.get('/a', async () => ({ from: 'a' }));
});

fastify.register(async function pluginB(instance) {
  // Plugin A's onSend hook does NOT fire for routes in Plugin B
  instance.get('/b', async () => ({ from: 'b' }));
});
```

---

### Practical Patterns

#### Pattern 1 — Global Authentication via fp

Apply authentication broadly using `fp` to promote the hook to root scope:

```js
import fp from 'fastify-plugin';

async function authPlugin(instance) {
  instance.addHook('onRequest', async (request, reply) => {
    await verifyToken(request, reply);
  });
}

fastify.register(fp(authPlugin));
```

#### Pattern 2 — Scoped Logging for an API Namespace

Apply detailed logging only within a specific route group:

```js
fastify.register(async function apiV1(instance) {
  instance.addHook('onResponse', async (request, reply) => {
    instance.log.info({
      method: request.method,
      url: request.url,
      statusCode: reply.statusCode,
      responseTime: reply.getResponseTime()
    }, 'v1 response');
  });

  instance.get('/users', async () => getUsers());
  instance.get('/posts', async () => getPosts());
}, { prefix: '/v1' });
```

#### Pattern 3 — Layered Hooks Across Nested Plugins

```js
fastify.addHook('onRequest', async (req) => {
  req.log.info('Layer 1: root');
});

fastify.register(async function layer2(instance) {
  instance.addHook('onRequest', async (req) => {
    req.log.info('Layer 2: plugin');
  });

  instance.register(async function layer3(inner) {
    inner.addHook('onRequest', async (req) => {
      req.log.info('Layer 3: nested plugin');
    });

    inner.get('/deep', async () => ({ depth: 3 }));
  });
});
```

For `GET /deep`, all three `onRequest` hooks fire in order:
1. `Layer 1: root`
2. `Layer 2: plugin`
3. `Layer 3: nested plugin`

---

### Scope Rules Summary

| Scenario | Hook applies to |
|---|---|
| Registered on root instance | All routes in the application |
| Registered inside a scoped plugin | Only routes within that plugin and its descendants |
| Registered inside an `fp`-wrapped plugin at root | All routes (promoted to root scope) |
| Registered in Plugin A | Does not apply to Plugin B (siblings are isolated) |
| Registered in a parent plugin | Inherited by child plugins within that parent |

---

### Common Pitfalls

**Pitfall 1 — Expecting a scoped hook to be global:**
Forgetting to use `fp` when a hook is intended for the entire application results in it silently applying only to a subset of routes.

**Pitfall 2 — Hook order with fp and route registration:**
If routes are registered before the `fp` plugin is processed, those routes may not be covered by the promoted hook. [Inference: registration order determines hook coverage during the initialization phase.]

**Pitfall 3 — Over-globalizing with fp:**
Using `fp` indiscriminately can make hooks harder to reason about. Prefer scoped hooks for cross-cutting concerns that only apply to a specific API surface.

**Pitfall 4 — Assuming sibling visibility:**
Hook registrations in one plugin do not bleed into sibling plugins. If shared behavior is needed across siblings, register it on their common parent or use `fp`.

---

**Conclusion:**
Hook scope in Fastify is a direct extension of its encapsulation model. Root hooks are global; scoped hooks are local; `fastify-plugin` promotes local registrations to the parent scope. Child plugins inherit from parents but siblings remain isolated. Mastering these rules allows precise, intentional placement of cross-cutting concerns — authentication, logging, metrics, and request enrichment — exactly where they are needed and nowhere else.
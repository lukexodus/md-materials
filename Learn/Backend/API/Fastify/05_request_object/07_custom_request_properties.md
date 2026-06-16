### Fastify Request Object — Custom Request Properties

#### Overview

Fastify provides mechanisms to attach custom properties to the request object, enabling handlers, hooks, and plugins to share data within the lifecycle of a single request. This is essential for patterns such as attaching authenticated user data, parsed context, feature flags, or any derived state that multiple parts of the request pipeline need to access.

---

#### Approach 1: Direct Assignment in Hooks or Handlers

The simplest approach is to assign properties directly onto the `request` object inside a hook or handler. Because each request object is a fresh instance, properties assigned this way are scoped to that request's lifetime.

js

```
fastify.addHook('preHandler', async (request, reply) => {
  request.user = { id: 42, role: 'admin' };
});

fastify.get('/profile', async (request, reply) => {
  return { user: request.user };
});
```

**Key Points:**

- This works at runtime but bypasses TypeScript type safety without additional declarations.
- Properties assigned in earlier lifecycle hooks are available in later hooks and the final handler.
- There is no built-in validation or schema enforcement on custom properties added this way.

---

#### Approach 2: `decorateRequest`

The idiomatic and recommended Fastify approach is `fastify.decorateRequest()`. This registers a named property on the request prototype, making it available on every request object served by that Fastify instance or plugin scope.

##### Syntax

js

```
fastify.decorateRequest(name, defaultValue);
```

- `name` — the property name to attach
- `defaultValue` — the initial value for each request; must be a primitive (`null`, `''`, `0`, `false`) when the intent is per-request mutation

js

```
fastify.decorateRequest('user', null);

fastify.addHook('preHandler', async (request, reply) => {
  request.user = { id: 42, role: 'admin' };
});

fastify.get('/me', async (request) => {
  return request.user;
});
```

**Output:**

json

```
{ "id": 42, "role": "admin" }
```

---

#### Why `decorateRequest` Over Direct Assignment

Fastify internally uses a shared prototype chain for request objects as a performance optimization. Assigning a property directly without declaring it via `decorateRequest` causes a hidden class deoptimization in V8, which can degrade runtime performance under load. [Inference: this is the stated rationale in Fastify's documentation; actual performance impact depends on runtime environment and workload.]

**Key Points:**

- `decorateRequest` pre-declares the property on the prototype, preserving V8 hidden class stability.
- Direct assignment without decoration still works but is not idiomatic and may have performance implications. [Inference]
- Fastify will emit a warning in development mode if a property is set on the request object without prior decoration.

---

#### Default Value Rules

The `defaultValue` passed to `decorateRequest` has strict constraints:

| Default Value Type | Behavior |
| --- | --- |
| Primitive (`null`, `0`, `''`, `false`) | Safe — each request gets the primitive independently |
| Object or Array | **Shared by reference** across all requests — mutations affect every request |

**Example of the reference trap (incorrect):**

js

```
// DANGEROUS — all requests share the same array object
fastify.decorateRequest('tags', []);
```

**Correct approach — use null and assign per-request:**

js

```
fastify.decorateRequest('tags', null);

fastify.addHook('onRequest', async (request) => {
  request.tags = [];
});
```

**Key Points:**

- Fastify will log a warning if a non-primitive default is passed to `decorateRequest`. Behavior may vary by version.
- Always initialize object/array values inside a hook, not as a `decorateRequest` default.

---

#### Approach 3: Using a Getter via `decorateRequest`

`decorateRequest` also accepts a descriptor object with a `getter` function, enabling computed or lazily evaluated properties.

js

```
fastify.decorateRequest('isAdmin', {
  getter() {
    return this.user?.role === 'admin';
  }
});
```

- `this` inside the getter refers to the request instance.
- The getter is evaluated each time the property is accessed.
- No setter is defined by default, so assignment will silently fail in non-strict mode or throw in strict mode.

**Example:**

js

```
fastify.decorateRequest('user', null);

fastify.decorateRequest('isAdmin', {
  getter() {
    return this.user?.role === 'admin';
  }
});

fastify.addHook('preHandler', async (request) => {
  request.user = { id: 1, role: 'admin' };
});

fastify.get('/check', async (request) => {
  return { isAdmin: request.isAdmin };
});
```

**Output:**

json

```
{ "isAdmin": true }
```

---

#### Scoping with Plugins

Decorations registered inside an `fastify.register()` block are scoped to that plugin and its children. They are not visible in sibling or parent scopes.

js

```
fastify.register(async function (instance) {
  instance.decorateRequest('tenantId', null);

  instance.addHook('onRequest', async (request) => {
    request.tenantId = 'tenant_abc';
  });

  instance.get('/tenant', async (request) => {
    return { tenantId: request.tenantId };
  });
});

// request.tenantId is NOT available here — outside the plugin scope
fastify.get('/outside', async (request) => {
  return { tenantId: request.tenantId }; // undefined
});
```

**Key Points:**

- Plugin-scoped decorations follow Fastify's encapsulation model.
- Use `fastify-plugin` (`fp`) to break encapsulation and share decorations across sibling scopes when needed.

---

#### TypeScript: Augmenting the Request Type

When using TypeScript, custom properties require type augmentation to avoid `any` or type errors.

ts

```
declare module 'fastify' {
  interface FastifyRequest {
    user: { id: number; role: string } | null;
    isAdmin: boolean;
  }
}
```

This augmentation should be placed in a `.d.ts` file or at the top of the relevant module. It extends Fastify's own `FastifyRequest` interface so TypeScript recognizes the added properties throughout the codebase.

**Key Points:**

- Module augmentation does not enforce runtime behavior — it is a compile-time declaration only.
- The declared type and the actual runtime value can diverge if hooks do not run as expected. [Inference]

---

#### Lifecycle Placement — When to Set Custom Properties

onRequestpreParsingpreValidationpreHandlerHandleronSend

**Key Points:**

- Properties needed before the body is parsed (e.g., auth tokens from headers) should be set in `onRequest` or `preParsing`.
- Properties derived from the parsed and validated body should be set in `preHandler`.
- The handler itself can also set properties, though they are only useful if passed to `onSend` hooks or serialization logic.

---

#### Summary

| Method | Idiomatic | Scoped | Type-safe (TS) | Per-request isolation |
| --- | --- | --- | --- | --- |
| Direct assignment | No | Per-request | No | Yes |
| `decorateRequest` (primitive default) | Yes | Plugin scope | With augmentation | Yes |
| `decorateRequest` (object default) | No — avoid | Plugin scope | With augmentation | No — shared ref |
| `decorateRequest` (getter) | Yes | Plugin scope | With augmentation | Computed |

---
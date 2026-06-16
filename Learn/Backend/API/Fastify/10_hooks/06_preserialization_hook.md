## preSerialization Hook

The `preSerialization` hook fires after route handler execution and before the response payload is serialized. It provides an opportunity to inspect or transform the payload object while it is still in its native form—before any JSON serialization schema is applied.

---

### Position in the Request Lifecycle

`preSerialization` occupies a specific slot in Fastify's hook execution order. Understanding where it sits relative to adjacent hooks clarifies what it can and cannot do.

```
onRequest → preParsing → preValidation → preHandler → handler → preSerialization → onSend → onResponse
```

By the time `preSerialization` runs:

- The route handler has already returned a payload
- The payload has **not yet** been passed through the serialization schema
- The response has **not yet** been written to the socket

`onSend` runs immediately after, receiving the already-serialized payload as a string or buffer.

---

### Hook Signature

```js
fastify.addHook('preSerialization', async (request, reply, payload) => {
  return payload
})
```

The hook receives three arguments:

| Argument  | Type                        | Description                                       |
|-----------|-----------------------------|---------------------------------------------------|
| `request` | `FastifyRequest`            | The incoming request object                       |
| `reply`   | `FastifyReply`              | The reply object, including headers and status    |
| `payload` | `object \| string \| Buffer \| null` | The value returned by the route handler  |

The hook **must return a value**. The returned value replaces the payload for subsequent processing. If you return `undefined` [Inference: based on Fastify's hook contract behavior], the payload may be treated as `undefined` downstream—always return an explicit value.

> Behavior of returning `undefined` is not guaranteed to be consistent across Fastify versions. Always return a defined payload.

---

### Registering the Hook

#### Globally (all routes)

```js
import Fastify from 'fastify'

const fastify = Fastify()

fastify.addHook('preSerialization', async (request, reply, payload) => {
  fastify.log.debug({ payload }, 'preSerialization hook fired')
  return payload
})
```

#### Scoped to a plugin or prefix

```js
fastify.register(async function (instance) {
  instance.addHook('preSerialization', async (request, reply, payload) => {
    return { wrapped: true, data: payload }
  })

  instance.get('/data', async () => {
    return { value: 42 }
  })
})
```

Routes outside the plugin scope are not affected by this hook registration.

#### Per-route (inline)

```js
fastify.get('/item', {
  preSerialization: [
    async (request, reply, payload) => {
      return { ...payload, _source: 'item-route' }
    }
  ],
  handler: async (request, reply) => {
    return { id: 1, name: 'Widget' }
  }
})
```

Per-route hooks run **after** any enclosing scope hooks of the same type. [Inference: consistent with Fastify's documented hook composition model]

---

### Callback-style (non-async)

If you are not using async/await, use the `done` callback pattern:

```js
fastify.addHook('preSerialization', (request, reply, payload, done) => {
  const modified = { ...payload, hookApplied: true }
  done(null, modified)
})
```

Pass the modified payload as the second argument to `done`. Pass an `Error` as the first argument to abort with an error response.

---

### When preSerialization Is Skipped

The hook does **not** fire in the following situations:

- The payload is a `string`, `Buffer`, `stream`, or `null` — Fastify bypasses serialization (and therefore `preSerialization`) for these types
- The reply has already been sent manually via `reply.raw`
- An error occurred prior to the handler — the error serialization path is separate

**Key Points:**
- `preSerialization` is only invoked when the payload is an object that will go through schema-based serialization
- If your handler returns a plain string, this hook will not run

---

### Common Use Cases

#### Wrapping the response envelope

A common pattern in APIs is to wrap all responses in a standard envelope structure:

```js
fastify.addHook('preSerialization', async (request, reply, payload) => {
  return {
    success: true,
    data: payload,
    timestamp: new Date().toISOString()
  }
})
```

**Example** — Handler returns:

```json
{ "id": 7, "name": "Alice" }
```

**Output** — After hook:

```json
{
  "success": true,
  "data": { "id": 7, "name": "Alice" },
  "timestamp": "2025-11-04T08:00:00.000Z"
}
```

> If a serialization schema is defined on the route, it will be applied to the **hook's return value**, not the original handler output. Adjust your schema to match the wrapped structure, or the output may be stripped of unexpected fields.

---

#### Injecting metadata

```js
fastify.addHook('preSerialization', async (request, reply, payload) => {
  if (typeof payload === 'object' && payload !== null) {
    return {
      ...payload,
      _requestId: request.id,
      _version: '1.0'
    }
  }
  return payload
})
```

---

#### Conditional transformation based on route or content type

```js
fastify.addHook('preSerialization', async (request, reply, payload) => {
  const isAdminRoute = request.routerPath?.startsWith('/admin')
  if (isAdminRoute) {
    return { ...payload, _debug: { headers: request.headers } }
  }
  return payload
})
```

> `request.routerPath` availability and exact naming may vary by Fastify version. Verify against your installed version's API reference.

---

#### Removing sensitive fields before serialization

```js
fastify.addHook('preSerialization', async (request, reply, payload) => {
  if (payload && typeof payload === 'object') {
    const { password, secret, ...safe } = payload
    return safe
  }
  return payload
})
```

**Key Points:**
- This approach is applied globally and affects all object payloads
- A schema with `additionalProperties: false` achieves similar field-stripping but only after serialization; `preSerialization` allows logic-driven removal before that step

---

### Interaction with Serialization Schemas

Fastify applies its serialization schema **after** `preSerialization` completes. This has a direct consequence: if you modify the shape of the payload in `preSerialization`, the serialization schema must reflect that new shape.

```js
fastify.get('/user', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          success: { type: 'boolean' },
          data: {
            type: 'object',
            properties: {
              id: { type: 'integer' },
              name: { type: 'string' }
            }
          }
        }
      }
    }
  },
  preSerialization: [
    async (request, reply, payload) => {
      return { success: true, data: payload }
    }
  ],
  handler: async () => ({ id: 1, name: 'Alice' })
})
```

If the schema does not account for the wrapper, fields added in `preSerialization` may be silently dropped by the serializer. [Inference: consistent with how `fast-json-stringify` handles unknown properties when `additionalProperties` is not set to `true`]

> Schema behavior depends on the serializer in use. Results are not guaranteed to be identical across all serializer configurations.

---

### Error Handling Within the Hook

Throwing or passing an error inside `preSerialization` aborts serialization and triggers Fastify's error handling pipeline:

```js
fastify.addHook('preSerialization', async (request, reply, payload) => {
  if (!payload || Object.keys(payload).length === 0) {
    throw new Error('Empty payload is not allowed at serialization stage')
  }
  return payload
})
```

With the callback form:

```js
fastify.addHook('preSerialization', (request, reply, payload, done) => {
  if (!payload) {
    return done(new Error('Payload missing'))
  }
  done(null, payload)
})
```

Fastify will invoke its error serializer and send an appropriate error response. The `onError` hook will fire if registered.

---

### preSerialization vs onSend

These two hooks are frequently compared. The distinction is the form of the payload each receives.

| Aspect               | `preSerialization`              | `onSend`                            |
|----------------------|---------------------------------|-------------------------------------|
| Payload form         | Native object (pre-serialized)  | String or Buffer (post-serialized)  |
| Fires for strings?   | No                              | Yes                                 |
| Fires for Buffers?   | No                              | Yes                                 |
| Fires for streams?   | No                              | Yes                                 |
| Schema applied after?| Yes                             | No (already applied)                |
| Typical use          | Shape/transform the data model  | Modify raw output bytes or string   |

**Key Points:**
- Use `preSerialization` when you need to work with the structured data object
- Use `onSend` when you need to work with the final serialized output

---

### Multiple preSerialization Hooks

Multiple hooks of this type can be registered and will execute in registration order. Each hook receives the payload returned by the previous hook.

```js
fastify.addHook('preSerialization', async (request, reply, payload) => {
  return { ...payload, step: 'first' }
})

fastify.addHook('preSerialization', async (request, reply, payload) => {
  return { ...payload, step: 'second' }
})
```

**Output** — the second hook overwrites `step` from the first:

```json
{ "step": "second" }
```

Each hook in the chain must return the payload explicitly. A missing return value in one hook breaks the chain for subsequent hooks. [Inference: based on standard Fastify hook chaining behavior; verify with your version]

---

### Interaction with Reply.send() Called Early

If `reply.send()` is called explicitly inside the route handler with a string or buffer, `preSerialization` will not fire, because Fastify treats that as a bypassed serialization path.

```js
fastify.get('/raw', async (request, reply) => {
  reply.send('plain text response') // preSerialization does NOT fire
})
```

To intercept that output, use `onSend` instead.

---

**Conclusion:**
The `preSerialization` hook provides structured, pre-schema access to the response payload while it is still in its object form. It is the appropriate interception point for envelope wrapping, metadata injection, field sanitization, and conditional payload transformation. Because it runs before the serialization schema is applied, any structural changes made here must be aligned with the route's response schema to avoid unintended field omission. For post-serialization concerns, `onSend` is the correct hook to use.
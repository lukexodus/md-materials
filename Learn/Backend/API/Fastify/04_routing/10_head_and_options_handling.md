### HEAD and OPTIONS Handling in Fastify

Fastify provides built-in behavior for the HTTP `HEAD` and `OPTIONS` methods, with some automatic handling that reduces boilerplate while still allowing explicit control when needed.

---

#### HEAD Requests

The `HEAD` method is identical to `GET` in terms of the request URI and headers — but the server must not return a body in the response. It is commonly used by clients to check resource existence, content type, or content length without downloading the full payload.

##### Automatic HEAD from GET

Fastify automatically creates a `HEAD` route for every `GET` route you define. When a `HEAD` request is received for a route that only has a `GET` handler, Fastify runs the `GET` handler internally but strips the response body before sending.

js

```
fastify.get('/article/:id', async (request, reply) => {
  return { id: request.params.id, title: 'Hello Fastify' }
})
```

With this route registered, a `HEAD /article/42` request is automatically handled — the response headers (including `Content-Type` and `Content-Length`) are sent, but no body is included.

> [Inference] The `Content-Length` header reflects the serialized body length, even though the body itself is omitted. Actual header values depend on your serializer and reply configuration. Behavior may vary.

##### Explicit HEAD Route

You can define a `HEAD` route explicitly if you need custom logic — for example, returning different headers than the `GET` route would produce.

js

```
fastify.head('/article/:id', async (request, reply) => {
  reply
    .header('Content-Type', 'application/json')
    .header('X-Custom-Header', 'value')
    .send()
})
```

When an explicit `HEAD` route is registered, Fastify uses it instead of falling back to the `GET` handler.

**Key Points:**

- Automatic `HEAD` handling is enabled by default
- The body is suppressed automatically — you do not need to call `.send('')` or manage this manually
- Explicit `HEAD` routes take precedence over the automatic behavior
- Behavior of header values derived from body serialization may vary depending on plugins and lifecycle hooks

---

#### OPTIONS Requests

The `OPTIONS` method is used by clients — most commonly browsers performing CORS preflight checks — to query which HTTP methods and headers a resource supports.

##### Default Behavior

Unlike `HEAD`, Fastify does **not** automatically handle `OPTIONS` requests unless you explicitly register the route or use a CORS plugin. Without a handler, an `OPTIONS` request to an unregistered path returns a `404`.

##### Explicit OPTIONS Route

js

```
fastify.options('/article/:id', async (request, reply) => {
  reply
    .header('Allow', 'GET, HEAD, POST, OPTIONS')
    .header('Access-Control-Allow-Origin', '*')
    .header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
    .header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
    .code(204)
    .send()
})
```

This pattern is typical for manually handling CORS preflight responses.

##### Using `@fastify/cors` for OPTIONS

For most production use cases, manually writing `OPTIONS` handlers is unnecessary. The `@fastify/cors` plugin handles preflight requests automatically.

js

```
import Fastify from 'fastify'
import cors from '@fastify/cors'

const fastify = Fastify()

await fastify.register(cors, {
  origin: 'https://example.com',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
})
```

> [Inference] When `@fastify/cors` is registered, it intercepts `OPTIONS` preflight requests and responds with the appropriate headers based on your configuration. You typically do not need to register individual `OPTIONS` routes. Behavior depends on plugin version and configuration — verify against the plugin's documentation.

---

#### Route Options: `exposeHeadRoute`

Fastify exposes a per-route option to control whether the automatic `HEAD` route is generated.

js

```
fastify.get('/private', {
  exposeHeadRoute: false,
  handler: async (request, reply) => {
    return { secret: true }
  }
})
```

Setting `exposeHeadRoute: false` disables the automatic `HEAD` route for that specific `GET` handler.

You can also set a global default via the Fastify server options:

js

```
const fastify = Fastify({
  exposeHeadRoutes: false // disables auto-HEAD for all GET routes
})
```

**Key Points:**

- The global option is `exposeHeadRoutes` (plural)
- The per-route option is `exposeHeadRoute` (singular)
- Mixing global and per-route settings is supported; per-route takes precedence

---

#### Behavior Summary

| Method | Auto-handled? | Body stripped? | Typical Use |
| --- | --- | --- | --- |
| `HEAD` | Yes (from `GET`) | Yes | Resource metadata checks |
| `OPTIONS` | No | N/A | CORS preflight, capability discovery |

---

#### Common Pitfalls

**1. Expecting automatic OPTIONS handling**
Fastify does not generate `OPTIONS` routes automatically. Without `@fastify/cors` or an explicit handler, preflight requests will receive a `404`.

**2. Registering HEAD before GET**
If you register an explicit `HEAD` route for a path before registering the `GET` route, Fastify treats them as independent routes. The automatic `HEAD`-from-`GET` behavior only applies when no explicit `HEAD` route exists.

**3. Hooks running on auto-HEAD**
[Inference] Lifecycle hooks (e.g., `onRequest`, `preHandler`) registered on a `GET` route are expected to also run when Fastify handles an automatic `HEAD` request via that route. However, behavior may vary depending on hook scope and plugin interaction — test explicitly if hooks are critical to your `HEAD` response.

---

#### Related Topics

- CORS and preflight handling (`@fastify/cors`)
- Lifecycle hooks and their interaction with method handling
- Route-level options and server-level defaults
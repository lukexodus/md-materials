## Performance Benchmarks and Internals

### Why Fastify Is Fast

Fastify is designed from the ground up with performance as a primary goal. Several architectural decisions contribute to its throughput advantage over many other Node.js frameworks.

### The Role of `find-my-way`

Fastify uses [`find-my-way`](https://github.com/delvedor/find-my-way) as its router — a radix tree (compressed trie) based HTTP router.

**Key Points:**
- Routes are stored as a compressed tree, not a flat array of regex patterns
- Route lookup time scales with URL depth, not the number of registered routes
- Parametric and wildcard routes are resolved without regex at the matching layer [Inference: based on documented design; actual runtime behavior may vary]

```
/users
  /users/:id
    /users/:id/posts
```

Rather than scanning each route sequentially, `find-my-way` traverses the tree based on URL segments, making lookups significantly faster when many routes are registered.

### Schema-Based Serialization with `fast-json-stringify`

One of the most impactful optimizations in Fastify is its use of [`fast-json-stringify`](https://github.com/fastify/fast-json-stringify) for response serialization.

Standard `JSON.stringify()` is a general-purpose function — it inspects each value at runtime to determine how to serialize it. `fast-json-stringify` takes a JSON Schema and generates a dedicated serialization function ahead of time.

**Example:**

```js
const schema = {
  type: 'object',
  properties: {
    id: { type: 'integer' },
    name: { type: 'string' }
  }
}
```

From this schema, a specialized function is compiled that skips type inference during serialization. This can produce measurable throughput gains for response-heavy routes. [Inference: gains depend on payload size, shape, and runtime conditions; behavior is not guaranteed to improve in all scenarios]

### Request Validation with Ajv

Fastify uses [Ajv](https://ajv.js.org/) (Another JSON Validator) to validate incoming request data — body, querystring, params, and headers — against a JSON Schema.

**Key Points:**
- Ajv compiles schemas into validation functions at route registration time, not per-request
- This means validation cost is paid once at startup, not on every incoming request
- Invalid requests are rejected early in the lifecycle, before handler execution

```js
fastify.post('/user', {
  schema: {
    body: {
      type: 'object',
      required: ['name'],
      properties: {
        name: { type: 'string' },
        age:  { type: 'integer' }
      }
    }
  }
}, async (request, reply) => {
  return { received: request.body }
})
```

If `name` is missing or the types do not match, Ajv rejects the request before your handler runs.

### Request and Reply Encapsulation

Rather than mutating a shared global object, Fastify creates lightweight `Request` and `Reply` wrapper objects per incoming connection. These wrap Node's native `http.IncomingMessage` and `http.ServerResponse`.

**Key Points:**
- Wrappers are minimal by design — only what is needed is added
- Avoids prototype pollution risks from shared mutable state [Inference]
- V8 can optimize monomorphic objects more effectively than objects with varying shapes [Inference: based on general V8 optimization principles; not Fastify-specific documentation]

### The Hook and Lifecycle Pipeline

Fastify's request lifecycle is a structured pipeline of hooks. Understanding this pipeline is important for understanding where time is spent per request.

```
Incoming Request
      │
      ▼
 onRequest hooks
      │
      ▼
 Parsing (body)
      │
      ▼
 preParsing hooks
      │
      ▼
 preValidation hooks
      │
      ▼
 Validation (Ajv)
      │
      ▼
 preHandler hooks
      │
      ▼
 Handler
      │
      ▼
 preSerialization hooks
      │
      ▼
 Serialization (fast-json-stringify)
      │
      ▼
 onSend hooks
      │
      ▼
 Response sent
      │
      ▼
 onResponse hooks
```

Each hook stage is optional. If no hooks are registered at a stage, that stage adds negligible overhead. [Inference: based on Fastify's documented design intent; actual overhead depends on runtime conditions]

### Benchmarks: What the Numbers Show

Fastify publishes benchmark comparisons on its official repository against frameworks including Express, Hapi, Koa, and Restify.

**Key Points:**
- Benchmarks are typically run using tools such as [`autocannon`](https://github.com/mcollina/autocannon) or `wrk`
- Fastify consistently shows higher requests-per-second in these controlled tests compared to Express in the same benchmark suite
- These are synthetic benchmarks — real-world performance depends heavily on database I/O, middleware chain length, payload complexity, and infrastructure

> **Important disclaimer:** Benchmark results are environment-sensitive. Numbers published by framework maintainers reflect controlled conditions and may not reflect your production scenario. Always benchmark your own application under realistic load.

**Example benchmark invocation using autocannon:**

```bash
npx autocannon -c 100 -d 10 http://localhost:3000/
```

- `-c 100` — 100 concurrent connections
- `-d 10` — run for 10 seconds

**Example output:**
```
┌─────────┬──────┬──────┬───────┬──────┬─────────┬─────────┬──────────┐
│ Stat    │ 2.5% │ 50%  │ 97.5% │ 99%  │ Avg     │ Stdev   │ Max      │
├─────────┼──────┼──────┼───────┼──────┼─────────┼─────────┼──────────┤
│ Latency │ 0 ms │ 1 ms │ 3 ms  │ 4 ms │ 0.98 ms │ 0.87 ms │ 23.45 ms │
└─────────┴──────┴──────┴───────┴──────┴─────────┴─────────┴──────────┘
Req/Sec: 54,200 (example figure — actual results vary)
```

[Unverified: the above output is illustrative only and does not represent a verified benchmark run]

### V8 and Node.js Internals That Fastify Leverages

Fastify's design aligns with patterns that V8 (the JavaScript engine in Node.js) handles efficiently:

| Pattern | Relevance |
|---|---|
| Monomorphic objects | Request/Reply objects have consistent shapes per route |
| Pre-compiled functions | Ajv and fast-json-stringify compile at startup |
| Minimal allocations per request | Reduces garbage collector pressure |
| Avoiding `try/catch` in hot paths | Allows V8 to optimize those functions more aggressively |

[Inference: each of the above is based on documented V8 optimization behavior and Fastify's stated design goals; actual JIT behavior is not guaranteed and varies by Node.js version and workload]

### Pino: Logging Without Blocking

Fastify ships with [Pino](https://github.com/pinojs/pino) as its default logger — a logger designed explicitly for low-overhead structured logging.

**Key Points:**
- Pino serializes logs asynchronously where possible, reducing impact on the request/response cycle
- Log output is newline-delimited JSON (NDJSON), processed by separate transport processes rather than inline
- Using `logger: true` in Fastify's options activates Pino with sensible defaults

```js
const fastify = require('fastify')({ logger: true })
```

Compared to synchronous loggers that write inline to stdout on every request, Pino's design is intended to reduce logging overhead. [Inference: actual overhead reduction depends on transport configuration and system I/O]

### Summary of Internal Components

| Component | Library | Purpose |
|---|---|---|
| Router | `find-my-way` | Radix-tree HTTP routing |
| Serialization | `fast-json-stringify` | Schema-compiled JSON output |
| Validation | `ajv` | Schema-compiled input validation |
| Logging | `pino` | Low-overhead structured logging |
| HTTP layer | Node.js `http` / `http2` | Native transport |

### Practical Takeaways

- Define response schemas for all routes — this activates `fast-json-stringify` and produces the most direct throughput benefit
- Define request schemas for validation — Ajv compiles once at startup rather than validating dynamically per request
- Keep hooks lean — every hook adds to the per-request pipeline cost
- Use Pino's transport mode in production to offload log serialization to a separate process
- Profile your own application before drawing conclusions from published benchmarks
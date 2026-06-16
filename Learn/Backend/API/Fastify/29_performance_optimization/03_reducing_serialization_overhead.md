## Reducing Serialization Overhead

Serialization — converting in-memory objects to JSON bytes for the HTTP response — is one of the most frequently executed operations in a Fastify application. Even modest inefficiencies compound at scale. Fastify provides several mechanisms to reduce this overhead, and understanding them allows targeted optimization without sacrificing correctness.

---

### Where Serialization Overhead Originates

Before optimizing, it helps to identify where cost accumulates:

- **Type inspection** — generic `JSON.stringify` must determine the type of every value at runtime
- **Property enumeration** — iterating `Object.keys()` or equivalent on every object in the graph
- **Unnecessary fields** — serializing properties the client never uses
- **Deep object graphs** — nested structures multiply the above costs
- **String concatenation and Buffer allocation** — assembling the final byte payload

Fastify addresses the first two through schema-driven code generation. The remaining three require application-level decisions.

---

### Response Schemas Are the Primary Lever

The single most impactful action is providing a `response` schema for every route. Without one, Fastify falls back to `JSON.stringify`. With one, `fast-json-stringify` generates a dedicated serialization function during startup.

```ts
// No schema — JSON.stringify path, no field filtering
fastify.get('/users/:id', {
  handler: async (request) => db.users.findById(request.params.id),
});

// With schema — compiled serializer, only declared fields emitted
fastify.get('/users/:id', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          name: { type: 'string' },
          email: { type: 'string' },
        },
        required: ['id', 'name', 'email'],
      },
    },
  },
  handler: async (request) => db.users.findById(request.params.id),
});
```

The compiled serializer for the second route does not inspect `Object.keys`, does not branch on types, and does not emit any field absent from the schema — including internal fields, ORM metadata, or sensitive properties the database row may carry.

---

### Declaring required Accurately

`fast-json-stringify` uses the `required` array to determine whether to emit a property unconditionally or guard it with a presence check.

```ts
// Without required — generates a conditional per property
{
  type: 'object',
  properties: {
    id: { type: 'string' },
    name: { type: 'string' },
  },
}
// Compiled roughly as:
// if (obj.id !== undefined) json += '"id":' + serialize(obj.id)
// if (obj.name !== undefined) json += ',"name":' + serialize(obj.name)

// With required — unconditional access, no branch
{
  type: 'object',
  properties: {
    id: { type: 'string' },
    name: { type: 'string' },
  },
  required: ['id', 'name'],
}
// Compiled roughly as:
// json += '"id":' + obj.id
// json += ',"name":' + obj.name
```

**Key Points:**
- Marking properties `required` removes conditional branches from the compiled serializer
- Every optional property adds a branch — for objects with many optional fields, the overhead accumulates [Inference: actual branch cost depends on V8's branch prediction and JIT behavior; measurable at high throughput, less relevant at low request rates]
- Do not mark a property `required` if it may genuinely be absent — the compiled function will emit `undefined` or corrupt output [Unverified: exact behavior when a required field is missing depends on `fast-json-stringify` version; behavior is not guaranteed to be safe]

---

### Avoiding additionalProperties in Response Schemas

`additionalProperties: false` in a response schema instructs `fast-json-stringify` to validate that no extra fields are present. This adds overhead because it requires enumerating object keys at runtime — the opposite of what schema compilation is designed to avoid.

```ts
// Adds runtime key enumeration — avoid in response schemas
{
  type: 'object',
  properties: { id: { type: 'string' } },
  additionalProperties: false,
}

// Omitting additionalProperties is sufficient for response schemas
// fast-json-stringify already ignores undeclared fields
{
  type: 'object',
  properties: { id: { type: 'string' } },
}
```

**Key Points:**
- `additionalProperties: false` is useful in **request** validation schemas (via Ajv) to reject unexpected input
- In **response** schemas, it is redundant and adds cost — `fast-json-stringify` does not emit undeclared fields regardless
- The distinction matters: request schemas go through Ajv; response schemas go through `fast-json-stringify`

---

### Flattening Nested Objects

Each nested object in a response schema adds a level of serialization function invocation. Where the structure permits, flattening reduces nesting depth and the associated call overhead.

```ts
// Nested — each level requires a separate serializer invocation
{
  type: 'object',
  properties: {
    user: {
      type: 'object',
      properties: {
        address: {
          type: 'object',
          properties: {
            city: { type: 'string' },
            country: { type: 'string' },
          },
        },
      },
    },
  },
}

// Flattened — single-level serializer for the same data
{
  type: 'object',
  properties: {
    userId: { type: 'string' },
    city: { type: 'string' },
    country: { type: 'string' },
  },
}
```

Flattening is not always appropriate — it changes the API contract. It is most applicable to internal service endpoints, analytics responses, or cases where nesting was introduced for organizational reasons rather than client necessity.

---

### Schema Reuse with $ref to Avoid Redundant Compilation

When the same shape appears in multiple routes, define it once with `addSchema` and reference it. This compiles the shape once and reuses the result.

```ts
fastify.addSchema({
  $id: 'Address',
  type: 'object',
  properties: {
    street: { type: 'string' },
    city: { type: 'string' },
    country: { type: 'string' },
  },
  required: ['city', 'country'],
});

fastify.addSchema({
  $id: 'UserProfile',
  type: 'object',
  properties: {
    id: { type: 'string' },
    name: { type: 'string' },
    address: { $ref: 'Address#' },
  },
  required: ['id', 'name'],
});

// Both routes reuse compiled Address serializer
fastify.get('/users/:id', {
  schema: { response: { 200: { $ref: 'UserProfile#' } } },
  handler: getUserHandler,
});

fastify.get('/me', {
  schema: { response: { 200: { $ref: 'UserProfile#' } } },
  handler: getMeHandler,
});
```

---

### Precise Type Declarations

`fast-json-stringify` generates different code paths for different declared types. Declaring types accurately enables tighter code generation.

```ts
// Loose — type array allows multiple paths
{ type: ['string', 'null'] }

// Precise with nullable — cleaner branch
{ type: 'string', nullable: true }

// Integer vs number — integer serialization omits decimal handling
{ type: 'integer' }   // emits Math.trunc or direct coercion
{ type: 'number' }    // must handle float formatting
```

For numeric fields that are always whole numbers, declaring `integer` rather than `number` allows the serializer to skip floating-point formatting. [Inference: actual code generation difference depends on `fast-json-stringify` version; verify against installed version]

---

### Avoiding preSerialization for Transformation

The `preSerialization` hook runs before the compiled serializer and receives the raw payload. Using it to reshape data adds an extra function call and potentially an object allocation before the optimized path runs.

```ts
// Adds overhead — creates new object before serializer runs
fastify.addHook('preSerialization', async (request, reply, payload) => {
  return { ...payload, _metadata: { version: '1' } };
});

// Better — include metadata in the schema and return it from the handler
fastify.get('/data', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          data: { type: 'object', ... },
          _metadata: {
            type: 'object',
            properties: { version: { type: 'string' } },
          },
        },
      },
    },
  },
  handler: async () => ({
    data: await fetchData(),
    _metadata: { version: '1' },
  }),
});
```

`preSerialization` is appropriate for cross-cutting concerns that cannot be embedded in individual handlers (envelope wrapping at the framework level, for example). Use it deliberately rather than as a convenience.

---

### Serialization Pipeline Overhead Diagram

<svg viewBox="0 0 680 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#64748b"/>
    </marker>
  </defs>

  <!-- Handler -->
  <rect x="240" y="20" width="180" height="50" rx="7" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="330" y="42" text-anchor="middle" fill="#38bdf8" font-weight="bold">Route Handler</text>
  <text x="330" y="59" text-anchor="middle" fill="#94a3b8">returns payload object</text>

  <line x1="330" y1="70" x2="330" y2="110" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>

  <!-- preSerialization -->
  <rect x="200" y="110" width="260" height="50" rx="7" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
  <text x="330" y="132" text-anchor="middle" fill="#fbbf24" font-weight="bold">preSerialization hook</text>
  <text x="330" y="149" text-anchor="middle" fill="#94a3b8">optional — avoid if possible</text>

  <line x1="330" y1="160" x2="330" y2="200" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>

  <!-- Branch -->
  <line x1="330" y1="200" x2="160" y2="240" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <line x1="330" y1="200" x2="490" y2="240" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <text x="330" y="218" text-anchor="middle" fill="#64748b" font-size="11">schema present?</text>

  <!-- Yes path -->
  <rect x="60" y="240" width="200" height="60" rx="7" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="160" y="263" text-anchor="middle" fill="#4ade80" font-weight="bold">fast-json-stringify</text>
  <text x="160" y="280" text-anchor="middle" fill="#94a3b8">compiled fn, no inspection</text>
  <text x="60" y="230" text-anchor="start" fill="#4ade80" font-size="11">YES</text>

  <!-- No path -->
  <rect x="400" y="240" width="200" height="60" rx="7" fill="#1e293b" stroke="#f87171" stroke-width="1.5"/>
  <text x="500" y="263" text-anchor="middle" fill="#f87171" font-weight="bold">JSON.stringify</text>
  <text x="500" y="280" text-anchor="middle" fill="#94a3b8">runtime inspection</text>
  <text x="400" y="230" text-anchor="start" fill="#f87171" font-size="11">NO</text>

  <!-- Converge -->
  <line x1="160" y1="300" x2="160" y2="340" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <line x1="500" y1="300" x2="500" y2="340" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <line x1="160" y1="340" x2="490" y2="340" stroke="#64748b" stroke-width="1"/>

  <!-- onSend -->
  <rect x="220" y="340" width="220" height="50" rx="7" fill="#1e293b" stroke="#f472b6" stroke-width="1.5"/>
  <text x="330" y="362" text-anchor="middle" fill="#f472b6" font-weight="bold">onSend hook</text>
  <text x="330" y="379" text-anchor="middle" fill="#94a3b8">serialized string/buffer</text>
</svg>

---

### Returning Strings and Buffers Directly

When the response is already serialized — from a cache, a file read, or a pre-built payload — returning a `string` or `Buffer` bypasses serialization entirely.

```ts
fastify.get('/static-data', async (request, reply) => {
  reply.header('Content-Type', 'application/json');
  return '{"status":"ok","version":"1.0"}'; // no serialization step
});
```

```ts
// Cached serialized response
const cachedPayload = JSON.stringify(expensiveComputation());

fastify.get('/report', async (request, reply) => {
  reply.header('Content-Type', 'application/json');
  return cachedPayload; // string returned directly, no re-serialization
});
```

**Key Points:**
- When a `string` is returned and `Content-Type` is `application/json`, Fastify skips serialization and sends the string as-is
- This is the fastest possible path — the serialization pipeline is not invoked at all
- The application is responsible for correctness of the pre-serialized string [Inference: no schema validation or field filtering is applied to pre-serialized strings]

---

### Streaming Large Responses

For large payloads, building the entire JSON string in memory before sending increases peak memory usage and time-to-first-byte. Streaming serializes and flushes incrementally.

```ts
import { Readable } from 'node:stream';

fastify.get('/export', async (request, reply) => {
  const cursor = db.orders.findAllCursor(); // database cursor, not full result set

  const stream = new Readable({
    objectMode: false,
    async read() {
      const row = await cursor.next();
      if (row === null) {
        this.push(null); // end of stream
      } else {
        this.push(JSON.stringify(row) + '\n'); // newline-delimited JSON
      }
    },
  });

  reply.header('Content-Type', 'application/x-ndjson');
  return reply.send(stream);
});
```

**Key Points:**
- Streaming is appropriate for export endpoints, paginated data dumps, and server-sent events
- Fastify pipes the stream to the response socket directly — no full-payload buffer is built [Inference: behavior depends on Node.js stream backpressure handling; verify under load]
- The compiled serializer is not applied to streamed responses — serialization is the application's responsibility per chunk

---

### Disabling Serialization for Specific Routes

Routes that return pre-validated, pre-serialized data can skip schema-based serialization entirely using a custom serializer.

```ts
fastify.get('/passthrough', {
  serializerCompiler: () => (data) => data, // identity — return as-is
  handler: async () => {
    return alreadySerializedString;
  },
});
```

A per-route `serializerCompiler` overrides the instance-level compiler for that route only.

---

### Content-Type Negotiation Overhead

Fastify's default reply serializer checks `Content-Type` to decide how to handle the payload. Setting the content type explicitly avoids this check.

```ts
fastify.get('/data', async (request, reply) => {
  reply.type('application/json'); // skip content-type detection
  return payload;
});
```

For JSON-only APIs, setting `Content-Type` globally via an `onSend` hook or a reply decorator removes per-route boilerplate while keeping the optimization.

---

### Benchmarking Serialization Impact

When profiling, isolate serialization cost from handler cost using a minimal handler:

```ts
const fixture = { id: '1', name: 'Alice', email: 'alice@example.com' };

// Baseline: no schema
fastify.get('/bench/no-schema', async () => fixture);

// Optimized: with schema
fastify.get('/bench/with-schema', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          name: { type: 'string' },
          email: { type: 'string' },
        },
        required: ['id', 'name', 'email'],
      },
    },
  },
  handler: async () => fixture,
});
```

Run with `autocannon`:

```bash
npx autocannon -c 100 -d 10 http://localhost:3000/bench/no-schema
npx autocannon -c 100 -d 10 http://localhost:3000/bench/with-schema
```

The difference in requests/second isolates the serialization path cost for that payload shape. [Unverified: results are environment-dependent; treat as directional, not absolute]

---

### Summary of Techniques

| Technique | Mechanism | Best applied when |
|---|---|---|
| Add response schema | Enables compiled serializer | Always — no exceptions |
| Mark fields `required` | Removes conditionals from compiled fn | Fields are structurally guaranteed |
| Omit `additionalProperties` in response | Avoids key enumeration | All response schemas |
| Use `integer` not `number` | Tighter numeric serialization | Whole-number fields |
| Return pre-serialized string | Bypasses serialization entirely | Cacheable or static responses |
| Stream large payloads | Avoids full-buffer allocation | Exports, large data sets |
| Avoid `preSerialization` transforms | Removes hook overhead | Most routes |
| Set `Content-Type` explicitly | Skips type detection | JSON-only endpoints |
| Reuse schemas via `$ref` | Compiles shared shapes once | Repeated structures across routes |

---

**Related Topics:**
- `fast-json-stringify` large array mechanisms (`'json-stringify'` vs `'default'`)
- Response caching strategies with `@fastify/caching` and ETags
- Compression middleware (`@fastify/compress`) and its interaction with serialization
- Profiling serialization cost with Node.js `--prof` and `0x`
- Protobuf and MessagePack as alternatives to JSON for internal services
- Streaming JSON with `@fastify/reply-from` for proxy responses
- Schema-driven API documentation with `@fastify/swagger` and serialization schema reuse
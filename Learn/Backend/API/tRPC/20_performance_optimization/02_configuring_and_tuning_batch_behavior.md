## Configuring and Tuning Batch Behavior

Enabling `httpBatchLink` is the starting point, not the end. Production applications often need to tune how batching collects requests, splits oversized batches, routes certain procedures outside the batch, and interacts with caching and streaming infrastructure.

---

### What Is Configurable

tRPC exposes batch behavior at three levels:

| Level | What Changes |
| --- | --- |
| Client link configuration | Batch window, URL length limits, headers |
| Per-call context | Opt individual calls out of batching |
| Server adapter configuration | Enable or disable batching server-side |

---

### `httpBatchLink` Configuration Options

```ts
import { httpBatchLink } from '@trpc/client';

httpBatchLink({
  url: '/api/trpc',

  // Maximum URL length before the batch is split into multiple requests
  maxURLLength: 2048,

  // Static or dynamic headers applied to every batched request
  headers: () => ({
    Authorization: `Bearer ${getToken()}`,
  }),

  // Transformer applied to serialized data (must match server transformer)
  transformer: superjson,
})
```

**Key Points**

- `maxURLLength` is the primary tool for controlling batch splitting. When the assembled URL for a batch exceeds this value, the client splits the batch into two or more smaller requests automatically.
- `headers` accepts a function so that token values are read at request time, not at client construction time. This matters for tokens that rotate or expire.
- `transformer` must be identical on client and server. A mismatch produces silent serialization errors. [Inference: behavior on transformer mismatch varies; it may manifest as parse errors or corrupted data rather than an explicit error. Verify consistency carefully.]

---

### Choosing a `maxURLLength` Value

URL length limits are imposed at multiple points in the request path:

generates URLforwardsforwardsparsesClientProxyLoadBalancerServerHandler

Each layer may impose its own limit:

| Component | Typical Default Limit |
| --- | --- |
| Chrome / Firefox | ~2MB (effectively unlimited) |
| nginx | 4096 bytes (`large_client_header_buffers`) |
| AWS ALB | 8192 bytes |
| Cloudflare | 16KB |
| Next.js dev server | No explicit limit documented |
| Node.js `http` module | ~80KB |

[Unverified: the values above are approximate and subject to change. Verify the actual limits imposed by your specific infrastructure configuration before relying on them.]

**Practical guidance:**

- If your stack includes nginx with default config, `maxURLLength: 2048` is a conservative safe value.
- If you control the full stack and have confirmed higher limits, `maxURLLength: 8192` allows larger batches before splitting.
- Setting `maxURLLength` too low causes unnecessary batch splitting and negates the latency benefit of batching.
- Setting it too high risks 414 errors from intermediaries.

---

### Controlling the Batch Collection Window

[Inference: `httpBatchLink` collects calls within the same synchronous execution frame — effectively, calls queued before the JavaScript event loop yields. There is no explicit `batchWindow` timer option in the standard tRPC client at the time of writing. This behavior is a consequence of how microtask scheduling works, not a configurable parameter.]

To influence which calls batch together, control when they are initiated:

**Calls that batch together:**

```ts
// Both queries are initiated in the same render cycle — they batch
const profileQuery = trpc.user.getProfile.useQuery({ id });
const settingsQuery = trpc.user.getSettings.useQuery();
```

**Calls that do not batch together:**

```ts
// Second call depends on first result — sequential, cannot batch
const profile = await trpc.user.getProfile.query({ id });
const settings = await trpc.user.getSettings.query(); // separate request
```

---

### `splitLink` — Routing Calls Outside the Batch

`splitLink` evaluates a condition per operation and routes it to one of two links. This is the primary mechanism for opting individual calls out of batching.

```ts
import { createTRPCProxyClient, httpBatchLink, httpLink, splitLink } from '@trpc/client';
import type { AppRouter } from '../server/router';

export const trpc = createTRPCProxyClient<AppRouter>({
  links: [
    splitLink({
      condition: (op) => {
        // Route to httpLink (no batching) when skipBatch is set
        return op.context.skipBatch === true;
      },
      true: httpLink({ url: '/api/trpc' }),
      false: httpBatchLink({ url: '/api/trpc', maxURLLength: 2048 }),
    }),
  ],
});
```

**Calling with `skipBatch`:**

```ts
const result = await trpc.notifications.poll.query(undefined, {
  context: { skipBatch: true },
});
```

**Alternative condition — route by operation type:**

```ts
splitLink({
  condition: (op) => op.type === 'subscription',
  true: wsLink({ client: wsClient }),
  false: httpBatchLink({ url: '/api/trpc' }),
})
```

**Alternative condition — route by procedure path:**

```ts
splitLink({
  condition: (op) => op.path.startsWith('admin.'),
  true: httpLink({
    url: '/api/trpc',
    headers: () => ({ 'X-Admin-Token': getAdminToken() }),
  }),
  false: httpBatchLink({ url: '/api/trpc' }),
})
```

---

### Chaining Multiple `splitLink`s

Complex routing needs — for example, subscriptions over WebSocket, admin procedures over a dedicated endpoint, and everything else batched — can be composed by nesting `splitLink`.

```ts
import { createWSClient, wsLink } from '@trpc/client';

const wsClient = createWSClient({ url: 'wss://api.example.com/trpc' });

const links = [
  splitLink({
    condition: (op) => op.type === 'subscription',
    true: wsLink({ client: wsClient }),
    false: splitLink({
      condition: (op) => op.context.skipBatch === true,
      true: httpLink({ url: '/api/trpc' }),
      false: httpBatchLink({ url: '/api/trpc', maxURLLength: 2048 }),
    }),
  }),
];
```

---

### Link Chain Diagram

yesnoyesnoOperationsubscription?wsLinkskipBatch?httpLinkhttpBatchLink

---

### Disabling Batching Server-Side

If the server receives a batched request but batching is disabled, it returns an error. Disable server-side batching when:

- You want to enforce that clients never batch (e.g., for per-procedure HTTP caching)
- Your infrastructure cannot handle long batched URLs

**Next.js adapter:**

```ts
// pages/api/trpc/[trpc].ts
export default nextApiHandler({
  router: appRouter,
  createContext,
  batching: { enabled: false },
});
```

**Standalone adapter:**

```ts
createHTTPServer({
  router: appRouter,
  createContext,
  batching: { enabled: false },
});
```

[Inference: not all tRPC adapters expose a `batching` configuration option at the same path. Verify the option name and shape against your specific adapter's type definitions.]

---

### `httpBatchStreamLink` Configuration

`httpBatchStreamLink` shares most options with `httpBatchLink` but streams each procedure result back as it completes rather than waiting for all procedures to finish.

```ts
import { httpBatchStreamLink } from '@trpc/client';

httpBatchStreamLink({
  url: '/api/trpc',
  maxURLLength: 2048,
  headers: () => ({ Authorization: `Bearer ${getToken()}` }),
})
```

**When to prefer `httpBatchStreamLink`:**

- Some procedures in a typical batch are fast and some are slow
- You want fast procedures to render immediately without waiting for slower ones
- Your server and all infrastructure between client and server support chunked transfer encoding

**When to avoid it:**

- Your CDN or proxy buffers responses before forwarding (negates streaming benefit)
- Your server runtime does not support streaming (e.g., some serverless environments)
- You need response-level HTTP caching, which streaming responses may interfere with

[Speculation: serverless environments such as Vercel Edge Functions and AWS Lambda@Edge have varying levels of streaming support depending on the runtime version and configuration. Verify streaming compatibility with your specific deployment target before adopting `httpBatchStreamLink`.]

---

### Tuning for Specific Scenarios

#### High-latency networks (mobile, satellite)

Batching provides the most benefit here. Maximize batch collection by ensuring all queries for a view are initiated in the same render cycle. Avoid `await` chains that fragment calls.

```ts
// Prefer: both calls batch
const [profile, settings] = await Promise.all([
  trpc.user.getProfile.query({ id }),
  trpc.user.getSettings.query(),
]);

// Avoid: sequential, cannot batch
const profile = await trpc.user.getProfile.query({ id });
const settings = await trpc.user.getSettings.query();
```

#### CDN-cached public data

Batching combines multiple procedures into a single URL. This URL is specific to the exact combination of procedures and inputs, making CDN cache hits unlikely across different users or pages. For publicly cacheable procedures, consider using `httpLink` (or a `splitLink` condition) so each procedure gets its own cacheable URL.

```ts
splitLink({
  condition: (op) => op.context.cacheable === true,
  true: httpLink({ url: '/api/trpc' }),   // CDN-cacheable individual URLs
  false: httpBatchLink({ url: '/api/trpc' }),
})
```

#### Mixed fast and slow procedures

If a batch regularly contains one slow procedure that delays all results, consider `httpBatchStreamLink` to allow fast results to arrive without waiting, or use `splitLink` to route the slow procedure through a separate link.

#### Authenticated vs. public endpoints

Different endpoints may require different headers or base URLs. Use `splitLink` to route them independently:

```ts
splitLink({
  condition: (op) => op.context.public === true,
  true: httpBatchLink({ url: 'https://public.api.example.com/trpc' }),
  false: httpBatchLink({
    url: 'https://private.api.example.com/trpc',
    headers: () => ({ Authorization: `Bearer ${getToken()}` }),
  }),
})
```

---

### Adding Headers Dynamically

The `headers` option accepts an async function, allowing token retrieval or cookie access at request time:

```ts
httpBatchLink({
  url: '/api/trpc',
  headers: async () => {
    const token = await refreshTokenIfExpired();
    return {
      Authorization: `Bearer ${token}`,
      'X-Request-ID': crypto.randomUUID(),
    };
  },
})
```

[Inference: the `headers` function is called once per batched HTTP request, not once per procedure within the batch. All procedures in a batch share the same headers. If different procedures require different auth tokens, they should be routed to different links via `splitLink`.]

---

### Observing Batch Splitting

When `maxURLLength` causes a batch to split, the resulting behavior is transparent to callers but visible in the network tab. Two (or more) requests appear, each containing a subset of the original procedures:

```
GET /api/trpc/user.getProfile,user.getSettings?batch=1&input={"0":...,"1":...}
GET /api/trpc/posts.getRecent,posts.getTrending?batch=1&input={"0":...,"1":...}
```

Both requests are sent in parallel. Each caller still receives its result independently. The split is invisible at the application layer.

---

### Batch Behavior Reference

| Scenario | Recommended Configuration |
| --- | --- |
| Default multi-query pages | `httpBatchLink` with `maxURLLength: 2048` |
| Mixed fast/slow procedures | `httpBatchStreamLink` |
| Publicly cacheable procedures | `splitLink` → `httpLink` for cacheable paths |
| Subscriptions | `splitLink` → `wsLink` for subscriptions |
| Long-polling procedures | `splitLink` → `httpLink` with `skipBatch` context |
| Admin-only endpoints | `splitLink` by path prefix → separate `httpLink` |
| Strict per-procedure caching | Disable batching; use `httpLink` only |

---

### Common Pitfalls

**Setting `maxURLLength` without verifying infrastructure limits** — A value safe for your Node.js server may be rejected by an nginx proxy in front of it. Audit every layer in the request path.

**Expecting different `headers` per procedure in a batch** — All procedures in a batch share the same request headers. Procedures requiring distinct credentials must be routed to separate links.

**Using `httpBatchStreamLink` without confirming streaming support** — A proxy that buffers the full response before forwarding silently negates all streaming benefit while adding complexity.

**Assuming `splitLink` conditions are typed** — The `op.context` field on an operation is typed as `Record<string, unknown>` by default. Access custom context fields with care; TypeScript may not catch typos in the key name. [Inference: some versions of tRPC allow augmenting the operation context type. Verify whether your version supports this before relying on it.]

**Routing mutations through `httpLink` when POST body size is the concern** — `maxURLLength` only applies to GET requests. POST mutations encode input in the request body, not the URL. URL length limits do not apply to mutation batches.

---

### Summary

Tuning batch behavior in tRPC involves selecting the right link (`httpBatchLink` vs. `httpBatchStreamLink` vs. `httpLink`), setting an appropriate `maxURLLength` based on verified infrastructure limits, and using `splitLink` to route procedures with special requirements — subscriptions, long-polling, public caching, per-procedure auth — outside the default batch. Headers are shared across all procedures in a batch, making `splitLink` necessary when different procedures require different credentials. The goal is a link configuration that minimizes round trips for the common case while giving escape hatches for the exceptions.
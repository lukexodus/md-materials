## Request Batching Explained

Request batching is a performance optimization where multiple tRPC procedure calls made in close temporal proximity are combined into a single HTTP request. The server processes all procedures in the batch and returns all results in a single response.

---

### The Problem Batching Solves

Without batching, a page that needs data from three procedures on initial load sends three separate HTTP requests:

```
GET /api/trpc/user.getProfile
GET /api/trpc/user.getSettings
GET /api/trpc/posts.getRecent
```

Each request incurs independent TCP connection overhead, HTTP header overhead, and round-trip latency. On a slow connection or high-latency network, these costs compound.

With batching, the same three calls collapse into one:

```
GET /api/trpc/user.getProfile,user.getSettings,posts.getRecent?batch=1&input=...
```

One TCP handshake, one round trip, one response.

---

### How Batching Works in tRPC

tRPC's batching mechanism operates on the client side. When batching is enabled, the client collects procedure calls that are initiated within the same JavaScript microtask or tick — specifically, within the same synchronous execution frame — and combines them into a single HTTP request before dispatching.

[Inference: the exact timing window for batch collection depends on the link implementation. Calls that are initiated in separate event loop ticks may not be batched together. Verify behavior against the `@trpc/client` version in use.]

The batched request encodes multiple procedure names in the URL path, separated by commas, and encodes their inputs as a JSON object keyed by index.

---

### Enabling Batching on the Client

Batching is controlled by the `httpBatchLink` (or `httpBatchStreamLink`) on the tRPC client. It is not enabled by default with `httpLink`.

```ts
// src/utils/trpc.ts
import { createTRPCProxyClient, httpBatchLink } from '@trpc/client';
import type { AppRouter } from '../server/router';

export const trpc = createTRPCProxyClient<AppRouter>({
  links: [
    httpBatchLink({
      url: '/api/trpc',
    }),
  ],
});
```

For React with `@tanstack/react-query`:

```ts
import { httpBatchLink } from '@trpc/client';
import { createTRPCReact } from '@trpc/react-query';
import type { AppRouter } from '../server/router';

export const trpc = createTRPCReact<AppRouter>();

export const trpcClient = trpc.createClient({
  links: [
    httpBatchLink({
      url: '/api/trpc',
    }),
  ],
});
```

---

### What a Batched Request Looks Like

Given three simultaneous queries — `user.getProfile`, `user.getSettings`, `posts.getRecent` — the client sends:

```
GET /api/trpc/user.getProfile,user.getSettings,posts.getRecent
  ?batch=1
  &input={"0":{"id":"u1"},"1":{},"2":{"limit":10}}
```

**Key Points**

- The URL path contains procedure names joined by commas.
- `batch=1` signals to the server that this is a batched request.
- `input` is a JSON object where each key is the zero-based index of the corresponding procedure.
- The server processes all procedures and returns an array of results, one per procedure, in the same index order.

---

### What a Batched Response Looks Like

The server returns a JSON array:

```json
[
  { "result": { "data": { "id": "u1", "name": "Ada" } } },
  { "result": { "data": { "theme": "dark", "language": "en" } } },
  { "result": { "data": [{ "id": "p1", "title": "First Post" }] } }
]
```

Each element corresponds to the procedure at the same index in the request. If one procedure errors, its element contains an `error` key instead of `result`:

```json
[
  { "result": { "data": { "id": "u1", "name": "Ada" } } },
  { "error": { "message": "Not found", "code": -32004, "data": { "code": "NOT_FOUND", "httpStatus": 404 } } },
  { "result": { "data": [] } }
]
```

[Inference: the exact error envelope shape depends on tRPC version and any custom error formatters. Verify against your configuration.]

---

### Request and Response Flow

tRPC ServerhttpBatchLinkuseQuery: getPostsuseQuery: getSettingsuseQuery: getProfiletRPC ServerhttpBatchLinkuseQuery: getPostsuseQuery: getSettingsuseQuery: getProfileCollects calls in same tickgetProfile({ id: "u1" })getSettings()getPosts({ limit: 10 })GET /api/trpc/getProfile,getSettings,getPosts?batch=1&input=...[result0, result1, result2]result0result1result2

---

### Server-Side Batching Support

The tRPC server adapter handles batched requests automatically when `allowBatching` is not explicitly disabled. No additional server configuration is required in most setups.

For the Next.js adapter:

```ts
// pages/api/trpc/[trpc].ts
import { nextApiHandler } from '@trpc/server/adapters/next';
import { appRouter } from '../../../server/router';

export default nextApiHandler({
  router: appRouter,
  createContext,
  // batching is enabled by default
});
```

To explicitly disable batching on the server:

```ts
export default nextApiHandler({
  router: appRouter,
  createContext,
  batching: { enabled: false },
});
```

If the client sends a batched request to a server with batching disabled, the server returns an error response. [Inference: the exact error code and message in this case may vary by adapter. Verify against your adapter version.]

---

### Configuring Batch Size Limits

`httpBatchLink` accepts a `maxURLLength` option. When the combined URL of a batch would exceed this length, the client automatically splits the batch into multiple requests.

```ts
httpBatchLink({
  url: '/api/trpc',
  maxURLLength: 2048,
})
```

**Key Points**

- URL length limits vary by server and proxy configuration. Common limits are 2048–8192 characters, though this is not standardized.
- When a batch is split, the split happens transparently — callers receive their results as if a single batch had been sent.
- [Inference: the `maxURLLength` option may not be present in all versions of `@trpc/client`. Verify availability against your installed version.]

---

### `httpBatchStreamLink` — Streaming Batch Responses

tRPC also provides `httpBatchStreamLink`, which streams each procedure result back to the client as it becomes available, rather than waiting for all procedures to complete before sending the response.

```ts
import { httpBatchStreamLink } from '@trpc/client';

export const trpc = createTRPCProxyClient<AppRouter>({
  links: [
    httpBatchStreamLink({
      url: '/api/trpc',
    }),
  ],
});
```

**Comparison:**

|  | `httpBatchLink` | `httpBatchStreamLink` |
| --- | --- | --- |
| Response timing | Waits for all procedures | Streams each result as ready |
| Slow procedure impact | Blocks all results | Only blocks its own result |
| Transport | Standard HTTP | HTTP with streaming (chunked transfer) |
| Browser support | Universal | Requires streaming-capable environment |
| Server support | Standard | Requires streaming-capable adapter |

[Inference: `httpBatchStreamLink` availability and behavior depend on tRPC version and server environment. Not all deployment targets support chunked transfer encoding or streaming responses. Verify compatibility before adopting.]

---

### When Batching Helps and When It Does Not

**Batching helps when:**

- Multiple queries are initiated simultaneously on page load
- A parent component and several child components each trigger their own queries at mount time
- Round-trip latency is a significant cost (e.g., mobile networks, geographically distant servers)

**Batching does not help when:**

- Procedures are initiated sequentially (second call depends on first result)
- Only one procedure is called at a time
- The server is colocated with the client (negligible latency)
- Procedures have very different execution times — the slowest procedure delays the entire batch response when using `httpBatchLink`

---

### Disabling Batching Per-Request

Some calls should not be batched — for example, a long-polling query or a procedure with special caching requirements. tRPC allows opting out per call.

```ts
// With @trpc/react-query
const { data } = trpc.notifications.poll.useQuery(undefined, {
  trpc: { abortOnUnmount: true },
  // To skip batching for this specific call, use a separate client
  // configured with httpLink instead of httpBatchLink
});
```

A cleaner pattern is to configure a split link that routes certain procedures through a non-batching link:

```ts
import { createTRPCProxyClient, httpLink, httpBatchLink, splitLink } from '@trpc/client';

export const trpc = createTRPCProxyClient<AppRouter>({
  links: [
    splitLink({
      condition: (op) => op.context.skipBatch === true,
      true: httpLink({ url: '/api/trpc' }),
      false: httpBatchLink({ url: '/api/trpc' }),
    }),
  ],
});
```

Then per call:

```ts
const result = await trpc.notifications.poll.query(undefined, {
  context: { skipBatch: true },
});
```

[Inference: `splitLink` usage and the `context` field on per-call options may vary by tRPC version. Verify the API against your installed version.]

---

### Batching and Mutations

Mutations can also be batched with `httpBatchLink`. However, batching mutations carries additional considerations:

- Batched mutations are sent as a single POST request. If the request fails at the network level, all mutations in the batch are lost.
- Individual mutation errors are still scoped per procedure — one mutation failing does not fail others in the same batch.
- [Inference: whether batching mutations is appropriate depends on whether the mutations are independent. Mutations with dependencies between them should not be batched, as execution order within a batch is not guaranteed to be sequential from the application's perspective.]

---

### Batching and Caching

HTTP caching applies differently to batched and non-batched requests:

- Non-batched GET queries can be cached by CDNs, proxies, and the browser cache based on the URL.
- Batched GET queries produce URLs that contain multiple procedure names and all inputs, making them less likely to be cache-hit across different call combinations.
- If CDN or edge caching of individual tRPC queries is important, batching may work against that goal.

[Speculation: some teams disable batching at the edge and rely on per-procedure caching for high-traffic public APIs, while keeping batching enabled for authenticated, user-specific data. This is not a universal recommendation.]

---

### Observing Batching in the Browser

To confirm batching is working, open the browser DevTools Network tab and filter by `trpc`. On a page load that triggers multiple queries simultaneously, you should see a single request with a comma-separated path rather than multiple individual requests.

```
Request URL: /api/trpc/user.getProfile,user.getSettings,posts.getRecent?batch=1&input=...
```

If you see separate requests per procedure, verify that:

- `httpBatchLink` is configured (not `httpLink`)
- The calls are initiated in the same render cycle
- `batching` is not disabled on the server

---

### Common Pitfalls

**Expecting sequential calls to batch** — Calls that await one another cannot batch because the second call is not initiated until the first resolves. Only concurrent calls batch.

**Forgetting `batch=1` in route matchers** — If you use `page.route()` in Playwright or similar interceptors, batched request URLs include `batch=1` and comma-separated procedure names. Patterns like `**/api/trpc/greet**` may not match `**/api/trpc/greet,getUser**`.

**Long batches exceeding URL limits** — A batch with many procedures or large inputs may produce a URL that exceeds server or proxy limits, resulting in a 414 error. Configure `maxURLLength` appropriately.

**Assuming all procedures in a batch succeed or fail together** — They do not. Each procedure result is independent. Handle errors per procedure.

**Using batching with streaming-incompatible infrastructure** — `httpBatchStreamLink` requires that the entire request pipeline (server, proxy, CDN, client) supports streaming responses. Verifying this before adoption avoids subtle failures.

---

### Summary

Request batching in tRPC collapses multiple concurrent procedure calls into a single HTTP request, reducing round-trip overhead and connection cost. It is enabled client-side via `httpBatchLink` or `httpBatchStreamLink` and requires no meaningful server configuration in most setups. Batching is most beneficial for parallel queries on page load and least beneficial for sequential calls, long-running procedures, or scenarios where per-procedure HTTP caching is important. Understanding what batching does — and does not — cover allows deliberate decisions about when to enable, configure, or bypass it.
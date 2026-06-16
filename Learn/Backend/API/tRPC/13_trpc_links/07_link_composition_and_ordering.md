### tRPC Links — Link composition and ordering

#### What is Link Composition?

In tRPC, **links** are middleware-like units that process requests and responses as they travel between the client and server. Link composition is the practice of combining multiple links into an ordered chain, where each link can inspect, modify, or short-circuit the flow before passing control to the next.

The `links` array passed to `createTRPCClient` (or the React Query integration) defines this chain explicitly.

**Key Points**

- Links are executed in array order for outgoing requests (left to right / top to bottom)
- Responses travel back in reverse order through the same links
- Each link receives an `op` (operation) object and a `next` function
- A link must either call `next(op)` to continue the chain or return an observable directly to terminate it

---

#### The `links` Array

```ts
import { createTRPCClient, httpBatchLink, loggerLink } from '@trpc/client';
import type { AppRouter } from '../server/router';

const client = createTRPCClient<AppRouter>({
  links: [
    loggerLink(),
    httpBatchLink({
      url: 'http://localhost:3000/api/trpc',
    }),
  ],
});
```

The array is the composition. Order matters — links are not automatically reordered by tRPC.

---

#### Request and Response Flow

The chain is bidirectional. A request passes through each link in forward order; the response (or error) unwinds back through them in reverse.

<svg viewBox="0 0 680 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
<!-- Background -->
<rect width="680" height="260" fill="#0f1117" rx="12"/>
<!-- Title -->

<text x="340" y="30" text-anchor="middle" fill="`#94a3b8`" font-size="12">Request / Response flow through link chain</text>

<!-- CLIENT box -->
<rect x="20" y="55" width="80" height="40" rx="6" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="60" y="80" text-anchor="middle" fill="#e2e8f0" font-size="12">Client</text>
<!-- Link 1 box -->
<rect x="150" y="55" width="110" height="40" rx="6" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
<text x="205" y="74" text-anchor="middle" fill="#93c5fd" font-size="11">loggerLink</text>
<text x="205" y="88" text-anchor="middle" fill="#64748b" font-size="10">[0]</text>
<!-- Link 2 box -->
<rect x="310" y="55" width="120" height="40" rx="6" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
<text x="370" y="74" text-anchor="middle" fill="#93c5fd" font-size="11">authLink</text>
<text x="370" y="88" text-anchor="middle" fill="#64748b" font-size="10">[1]</text>
<!-- Link 3 box (terminating) -->
<rect x="480" y="55" width="130" height="40" rx="6" fill="#1a3a2a" stroke="#22c55e" stroke-width="1.5"/>
<text x="545" y="74" text-anchor="middle" fill="#86efac" font-size="11">httpBatchLink</text>
<text x="545" y="88" text-anchor="middle" fill="#64748b" font-size="10">[2] terminating</text>
<!-- Forward arrows (request) -->
<defs>
<marker id="arr-fwd" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#3b82f6"/>
</marker>
<marker id="arr-rev" markerWidth="8" markerHeight="8" refX="2" refY="3" orient="auto">
<path d="M8,0 L8,6 L0,3 z" fill="#f59e0b"/>
</marker>
</defs>
<!-- Req: client -> link1 -->
<line x1="102" y1="68" x2="148" y2="68" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#arr-fwd)"/>
<!-- Req: link1 -> link2 -->
<line x1="262" y1="68" x2="308" y2="68" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#arr-fwd)"/>
<!-- Req: link2 -> link3 -->
<line x1="432" y1="68" x2="478" y2="68" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#arr-fwd)"/>
<!-- Response arrows (reverse) -->
<!-- Res: link3 -> link2 -->
<line x1="478" y1="82" x2="432" y2="82" stroke="#f59e0b" stroke-width="1.5" marker-end="url(#arr-rev)"/>
<!-- Res: link2 -> link1 -->
<line x1="308" y1="82" x2="262" y2="82" stroke="#f59e0b" stroke-width="1.5" marker-end="url(#arr-rev)"/>
<!-- Res: link1 -> client -->
<line x1="148" y1="82" x2="102" y2="82" stroke="#f59e0b" stroke-width="1.5" marker-end="url(#arr-rev)"/>
<!-- Legend -->
<line x1="40" y1="155" x2="90" y2="155" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#arr-fwd)"/>
<text x="100" y="159" fill="#93c5fd" font-size="11">Request (forward)</text>
<line x1="40" y1="178" x2="90" y2="178" stroke="#f59e0b" stroke-width="1.5" marker-end="url(#arr-rev)"/>
<text x="100" y="182" fill="#fcd34d" font-size="11">Response (reverse)</text>
<!-- Notes -->

<text x="340" y="220" text-anchor="middle" fill="`#475569`" font-size="11">Each link calls next(op) to pass the request forward.</text>
<text x="340" y="238" text-anchor="middle" fill="`#475569`" font-size="11">The terminating link returns an observable — it does not call next.</text>
</svg>

---

#### Terminating vs. Non-Terminating Links

This distinction is critical to correct composition.

**Terminating link**

- Returns an observable directly without calling `next`
- Must be the **last** link in the array
- Built-in examples: `httpBatchLink`, `httpLink`, `wsLink`

**Non-terminating link**

- Calls `next(op)` to pass the operation down the chain
- Can inspect or modify the `op` before calling `next`
- Can also tap into the returned observable to inspect the response
- Built-in examples: `loggerLink`, custom middleware links

Placing a terminating link before the end of the array means subsequent links will never receive operations. tRPC does not enforce array length or position at the type level — this is a runtime behavioral concern. [Inference: the chain simply stops at the terminating link; no error is thrown for unreachable links, though behavior may vary across versions.]

---

#### Ordering Rules and Conventions

The order of links has direct, observable consequences.

##### Rule 1 — Terminating link last

```ts
// Correct
links: [loggerLink(), authLink(), httpBatchLink({ url })]

// Incorrect — httpBatchLink before authLink means authLink never runs on requests
links: [loggerLink(), httpBatchLink({ url }), authLink()]
```

##### Rule 2 — Logging near the front

`loggerLink` placed first captures the full round-trip: it sees the outgoing request and the final response after all other links have processed it on the way back.

```ts
links: [
  loggerLink(),        // sees everything
  authLink(),
  retryLink(),
  httpBatchLink({ url }),
]
```

Placing `loggerLink` last (just before the terminating link) means it only sees the request at that stage — it will not observe modifications made by earlier links on the response path.

##### Rule 3 — Auth before the network

Token injection or header attachment must happen before the request reaches the transport link.

```ts
links: [
  loggerLink(),
  authLink(),          // injects Authorization header
  httpBatchLink({ url }),  // sends with the header present
]
```

##### Rule 4 — Retry links wrap the transport

A retry link must be positioned so that it can re-invoke the chain segment that includes the transport. Placing it after the transport has no effect.

```ts
links: [
  loggerLink(),
  retryLink({ retry: (op, error) => error.data?.code !== 'UNAUTHORIZED' }),
  httpBatchLink({ url }),
]
```

---

#### Splitting by Operation Type

`splitLink` (available via `@trpc/client`) allows conditional routing — different sub-chains for different operations. This is the standard pattern for mixing HTTP and WebSocket transports.

```ts
import { createTRPCClient, httpBatchLink, splitLink, wsLink, createWSClient } from '@trpc/client';

const wsClient = createWSClient({ url: 'ws://localhost:3000/api/trpc' });

const client = createTRPCClient<AppRouter>({
  links: [
    loggerLink(),
    splitLink({
      condition: (op) => op.type === 'subscription',
      true: wsLink({ client: wsClient }),
      false: httpBatchLink({ url: 'http://localhost:3000/api/trpc' }),
    }),
  ],
});
```

**Key Points**

- `splitLink` is itself a terminating link — it delegates to one of two sub-chains based on the condition
- Both `true` and `false` branches must be terminating links (or end in one)
- `loggerLink` placed before `splitLink` observes all operations regardless of which branch they take

---

#### Custom Link and Composition Example

A custom non-terminating link follows a consistent shape:

```ts
import { TRPCLink } from '@trpc/client';
import { observable } from '@trpc/server/observable';
import type { AppRouter } from '../server/router';

const customHeaderLink: TRPCLink<AppRouter> = () => {
  return ({ next, op }) => {
    // Modify the operation context before forwarding
    const modifiedOp = {
      ...op,
      context: {
        ...op.context,
        headers: {
          ...(op.context.headers as Record<string, string>),
          'x-request-id': crypto.randomUUID(),
        },
      },
    };

    return observable((observer) => {
      const subscription = next(modifiedOp).subscribe({
        next: (result) => observer.next(result),
        error: (err) => observer.error(err),
        complete: () => observer.complete(),
      });

      return () => subscription.unsubscribe();
    });
  };
};
```

Composed with other links:

```ts
const client = createTRPCClient<AppRouter>({
  links: [
    loggerLink(),
    customHeaderLink,   // adds x-request-id to every request
    httpBatchLink({ url: 'http://localhost:3000/api/trpc' }),
  ],
});
```

**Output** (what the server receives, [Inference])

Each request will carry an `x-request-id` header generated on the client side. Actual header propagation depends on server and proxy configuration — behavior is not guaranteed across all deployment environments.

---

#### Composition Checklist

| Position | Requirement |
| --- | --- |
| Last in array | Must be a terminating link |
| Auth / header injection | Must precede the transport link |
| Logger | Typically first for broadest visibility |
| Retry | Must precede the transport link |
| `splitLink` | Acts as terminating; branches must also terminate |
| Custom links | Must return an observable and handle unsubscribe |

---

#### Common Mistakes

**Terminating link in the middle**

```ts
// loggerLink after httpBatchLink never sees requests
links: [httpBatchLink({ url }), loggerLink()]
```

**Forgetting to unsubscribe in custom links**

Not returning a cleanup function from the observable can cause subscription leaks. [Inference: behavior depends on how the tRPC client manages observable lifecycles internally; verify against the version in use.]

**Mutating `op` directly instead of spreading**

```ts
// Avoid
op.context.headers['x-id'] = '123';

// Prefer
const modifiedOp = { ...op, context: { ...op.context, headers: { ... } } };
```

Direct mutation may affect other links sharing the same object reference. [Inference: immutability is a defensive convention here, not a guarantee enforced by tRPC's type system.]

---

**Next Steps**

- `loggerLink` — built-in logging link in depth
- `splitLink` — conditional routing patterns
- `httpBatchLink` — batching behavior and configuration
- Writing and testing custom links
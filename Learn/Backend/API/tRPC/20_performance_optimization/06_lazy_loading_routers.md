## Lazy Loading Routers

### What Is Lazy Loading in tRPC?

In tRPC, **lazy loading routers** refers to deferring the initialization or import of sub-routers until they are actually needed, rather than loading all routers eagerly at application startup. This is a performance optimization aimed at reducing initial startup time and memory footprint, particularly in large applications with many procedures.

**Key Points:**

- Routers are typically composed at startup; lazy loading defers that work.
- Most relevant in serverless environments, large monorepos, or apps with many domain routers.
- tRPC does not have a built-in `lazyRouter()` API as of v11. [Unverified: whether this changes in future versions — behavior may vary across releases.]

---

### Why It Matters

In a standard tRPC setup, all routers are imported and merged at module load time:

```ts
// Eager loading — all modules imported immediately
import { userRouter } from './routers/user';
import { postRouter } from './routers/post';
import { analyticsRouter } from './routers/analytics';

export const appRouter = router({
  user: userRouter,
  post: postRouter,
  analytics: analyticsRouter,
});
```

Every import triggers module evaluation. In large applications, this can mean:

- Slow cold starts (especially in AWS Lambda, Vercel Functions, etc.)
- Loading code paths that may never be reached in a given invocation
- Higher memory usage at startup

---

### Lazy Loading via Dynamic Imports

Since tRPC routers are plain JavaScript objects, you can apply standard dynamic import patterns. The key insight is that a tRPC procedure handler is just a function — you can delay the import of heavy dependencies inside that function.

#### Pattern 1: Lazy dependency inside a procedure

```ts
export const reportRouter = router({
  generate: publicProcedure
    .input(z.object({ type: z.string() }))
    .mutation(async ({ input }) => {
      // Heavy library only loaded when this procedure is called
      const { generatePDF } = await import('../lib/pdf-generator');
      return generatePDF(input.type);
    }),
});
```

[Inference] This reduces startup cost if `pdf-generator` is large and infrequently used. Actual performance gain depends on runtime module caching behavior, which varies by environment.

---

#### Pattern 2: Lazy sub-router initialization

Because tRPC merges routers at definition time, true lazy router merging requires restructuring how the router is exposed. One approach is to defer router construction behind a factory function:

```ts
// routers/analytics.ts
let _analyticsRouter: ReturnType<typeof buildAnalyticsRouter> | null = null;

function buildAnalyticsRouter() {
  // Expensive imports or setup happen here
  const { heavyUtil } = require('../lib/heavy-util');

  return router({
    report: publicProcedure.query(() => heavyUtil.run()),
  });
}

export function getAnalyticsRouter() {
  if (!_analyticsRouter) {
    _analyticsRouter = buildAnalyticsRouter();
  }
  return _analyticsRouter;
}
```

**Note:** This does not defer the router from being merged into `appRouter` at startup unless you also restructure the root router. It only defers internal setup within the module. Behavior may vary depending on bundler and runtime.

---

#### Pattern 3: Route-level dynamic dispatch (advanced)

For true per-request lazy loading, some teams proxy procedure dispatch manually. This is outside standard tRPC API usage and is [Speculation] based on general Node.js patterns:

```ts
// This is a non-standard pattern — verify against your tRPC version
export const appRouter = router({
  analytics: publicProcedure.query(async (opts) => {
    const { analyticsRouter } = await import('./routers/analytics');
    // Cannot call a router as a procedure — this pattern has limitations
    // [Unverified] — consult tRPC docs for your version before using
  }),
});
```

> ⚠️ This pattern is illustrative only. tRPC does not natively support routing to a lazily-loaded sub-router mid-dispatch. Do not use in production without verifying against your specific version.

---

### Lazy Loading in Serverless Contexts

Serverless functions benefit most from lazy loading. The general strategy is to keep the top-level module lean and defer any heavy work into procedure handlers.

```
Cold Start Timeline (Eager):
│
├─ Import userRouter       ← runs immediately
├─ Import postRouter       ← runs immediately
├─ Import analyticsRouter  ← runs immediately (even if unused)
├─ Merge into appRouter
└─ Handle request

Cold Start Timeline (Lazy dependencies):
│
├─ Import lightweight router shells
├─ Merge into appRouter
└─ Handle request
    └─ Dynamic import of heavy dep ← only when needed
```

[Inference] This can reduce cold start latency in environments that bill per invocation. Actual impact depends on module size, bundler behavior, and runtime caching. Not guaranteed.

---

### Interaction with Bundlers

Bundlers like esbuild, Webpack, and Rollup handle dynamic imports differently:

| Bundler | Dynamic `import()` behavior |
| --- | --- |
| esbuild | Code-splits by default; dynamic imports become separate chunks |
| Webpack | Supports code splitting with `import()` out of the box |
| Rollup | Supports code splitting; manual chunks configurable |
| tsup | Wraps esbuild; inherits its behavior |

[Inference] If your bundler inlines all modules into a single bundle regardless of dynamic imports, lazy loading at the module level will have no effect on bundle size or load time. Verify your bundler's output.

---

### When to Apply This Pattern

| Scenario | Lazy loading recommended? |
| --- | --- |
| Large monolith with many routers | Yes — defer unused domain routers |
| Serverless / edge functions | Yes — minimize cold start |
| Small app with few routers | No — overhead not justified |
| Procedures with heavy one-off deps | Yes — import inside handler |
| Frequently called hot paths | No — dynamic import overhead per call [Inference] |

---

### Caveats and Limitations

- **No native tRPC API for lazy routers.** All patterns described here use general JavaScript/Node.js techniques applied to tRPC structures. [Unverified: whether tRPC plans to add first-class support.]
- **Module caching mitigates repeat cost.** After the first dynamic import, Node.js caches the module. [Inference] Subsequent calls to the same lazy import are likely fast, but this is runtime-dependent.
- **Type inference is unaffected.** TypeScript resolves types statically at compile time. Lazy imports at runtime do not affect tRPC's end-to-end type safety.
- **Testing complexity increases.** Lazy imports may require additional mocking setup in test environments.

---

**Conclusion:**
Lazy loading in tRPC is achieved through standard JavaScript dynamic import patterns applied to procedure handlers and module initialization, rather than a dedicated tRPC API. The primary use case is reducing cold start time in serverless environments or deferring heavy dependencies that are rarely invoked. Apply selectively — not all routers benefit, and incorrect application can introduce unnecessary complexity without measurable gain.

**Next Steps:**

- Profile your cold start times before and after to confirm actual improvement
- Review your bundler's code-splitting output to verify dynamic imports are being split
- Consider combining lazy loading with request batching for further serverless optimization
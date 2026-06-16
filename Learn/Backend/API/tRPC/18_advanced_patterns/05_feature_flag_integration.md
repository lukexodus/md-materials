## Feature Flag Integration

---

### Overview

Feature flags (also called feature toggles) allow functionality to be enabled or disabled at runtime without deploying new code. In tRPC, feature flags intersect with routing at several layers: they can gate entire procedures, modify procedure behavior, control which fields are returned, or determine whether a router subtree is exposed at all.

tRPC has no native feature flag support. Integration is implemented through context, middleware, and resolver logic — the same building blocks used for authorization and multi-tenancy.

---

### Flag Evaluation Models

Feature flags vary in how they are evaluated. Understanding the model matters because it determines where flag evaluation belongs in the tRPC request lifecycle.

| Model | Description | Evaluation point |
| --- | --- | --- |
| Static / build-time | Flag values are environment variables baked in at deploy time | Module load |
| Remote / runtime | Flags are fetched from an external service (LaunchDarkly, Unleash, Flagsmith) | Context creation or middleware |
| User-targeted | Flag varies per user, based on ID, cohort, or percentage rollout | Middleware or resolver |
| Tenant-targeted | Flag varies per tenant or organization | Middleware or resolver |

---

### Providing Flags Through Context

For flags that vary per request — user-targeted, tenant-targeted, or remotely fetched — context creation is the correct evaluation point. Evaluating once per request and storing results in context avoids redundant SDK calls across multiple procedures in a batch.

```ts
// server/context.ts
import { inferAsyncReturnType } from '@trpc/server';
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';
import { flagsmith } from './lib/flagsmith'; // example SDK
import { getSession } from './auth';
import { db } from './db';

export async function createContext({ req }: CreateNextContextOptions) {
  const session = await getSession(req);

  // Evaluate all flags once per request
  const flags = session?.user
    ? await flagsmith.getIdentityFlags(session.user.id)
    : await flagsmith.getEnvironmentFlags();

  return {
    session,
    db,
    flags, // available to all middleware and resolvers
  };
}

export type Context = inferAsyncReturnType<typeof createContext>;
```

**Key Points:**

- Centralizing flag evaluation in context means flag values are consistent across all procedures in a single request — a procedure cannot see a different flag state than another procedure in the same batch
- If the flag SDK call fails, context creation fails, which means the entire request fails. Consider wrapping in a try/catch and falling back to safe defaults [Inference: appropriate fallback behavior depends on your flag provider's reliability guarantees]

```ts
// Defensive flag resolution with fallback
const flags = await (async () => {
  try {
    return session?.user
      ? await flagsmith.getIdentityFlags(session.user.id)
      : await flagsmith.getEnvironmentFlags();
  } catch {
    return defaultFlags; // pre-defined safe defaults
  }
})();
```

---

### Static Flags from Environment Variables

For flags that are stable per deployment — gradual rollouts managed at deploy time, not per user — environment variables are sufficient and introduce no per-request overhead.

```ts
// server/flags.ts
export const staticFlags = {
  enableBetaApi: process.env.ENABLE_BETA_API === 'true',
  enableNewBillingFlow: process.env.ENABLE_NEW_BILLING === 'true',
  enableAiFeatures: process.env.ENABLE_AI_FEATURES === 'true',
} as const;

export type StaticFlags = typeof staticFlags;
```

These can be merged into context:

```ts
import { staticFlags } from './flags';

export async function createContext({ req }: CreateNextContextOptions) {
  return {
    session: await getSession(req),
    db,
    flags: staticFlags,
  };
}
```

**Key Points:**

- Static flags are evaluated at module load time — changing them requires a restart or redeploy
- They are appropriate for infrastructure-level feature gates, not user-level rollouts

---

### Feature Flag Middleware

For procedures that should be entirely blocked when a flag is disabled, a middleware guard is cleaner than an in-resolver check.

```ts
// server/middleware/requireFlag.ts
import { middleware } from '../trpc';
import { TRPCError } from '@trpc/server';

export function requireFlag(flagName: keyof Context['flags']) {
  return middleware(({ ctx, next }) => {
    const flag = ctx.flags[flagName];
    const enabled = typeof flag === 'boolean' ? flag : flag?.enabled ?? false;

    if (!enabled) {
      throw new TRPCError({
        code: 'NOT_FOUND', // deliberately vague — does not reveal feature existence
        message: 'Procedure not found.',
      });
    }

    return next({ ctx });
  });
}
```

**Usage:**

```ts
// server/trpc.ts
import { requireFlag } from './middleware/requireFlag';

export const betaProcedure = protectedProcedure.use(requireFlag('enableBetaApi'));
export const aiProcedure = protectedProcedure.use(requireFlag('enableAiFeatures'));
```

```ts
// server/routers/ai.ts
export const aiRouter = router({
  summarize: aiProcedure
    .input(z.object({ text: z.string() }))
    .mutation(({ input }) => summarizeText(input.text)),

  classify: aiProcedure
    .input(z.object({ text: z.string() }))
    .mutation(({ input }) => classifyText(input.text)),
});
```

**Key Points:**

- Using `NOT_FOUND` rather than `FORBIDDEN` avoids revealing that a feature exists but is disabled — appropriate when the feature's existence should not be disclosed to non-participants [Inference: the appropriate error code depends on your product's disclosure policy]
- The middleware approach enforces the flag at the procedure boundary, before any resolver logic executes
- Procedures using `betaProcedure` or `aiProcedure` inherit the flag check automatically — no per-procedure repetition

---

### In-Resolver Flag Checks

When a flag affects only part of a procedure's behavior — a different code path, an additional field in the response, or a modified algorithm — the check belongs inside the resolver rather than in middleware.

```ts
export const postRouter = router({
  get: protectedProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ input, ctx }) => {
      const post = await ctx.db.post.findUnique({ where: { id: input.id } });

      if (!post) {
        throw new TRPCError({ code: 'NOT_FOUND' });
      }

      // Conditionally include AI-generated summary
      const summary = ctx.flags.enableAiFeatures
        ? await generateSummary(post.body)
        : null;

      return {
        ...post,
        summary,
      };
    }),
});
```

**Key Points:**

- In-resolver checks are appropriate when the procedure itself is always valid — only some of its behavior is gated
- The response shape changes based on the flag; the client should handle nullable fields accordingly
- [Inference: if the client relies on TypeScript inference from tRPC, the return type will reflect the conditional — `summary: string | null` — regardless of flag state]

---

### Output Schema Variation with Flags

When a flag controls whether a field is present at all in the response, the output schema should reflect this:

```ts
const PostBaseSchema = z.object({
  id: z.string(),
  title: z.string(),
  body: z.string(),
});

const PostWithAiSchema = PostBaseSchema.extend({
  summary: z.string(),
});

export const postRouter = router({
  get: protectedProcedure
    .input(z.object({ id: z.string() }))
    .output(
      z.discriminatedUnion('hasAi', [
        PostBaseSchema.extend({ hasAi: z.literal(false) }),
        PostWithAiSchema.extend({ hasAi: z.literal(true) }),
      ])
    )
    .query(async ({ input, ctx }) => {
      const post = await ctx.db.post.findUnique({ where: { id: input.id } });

      if (!post) throw new TRPCError({ code: 'NOT_FOUND' });

      if (ctx.flags.enableAiFeatures) {
        return { ...post, hasAi: true as const, summary: await generateSummary(post.body) };
      }

      return { ...post, hasAi: false as const };
    }),
});
```

**Key Points:**

- A discriminated union output schema forces the client to narrow the type before accessing flag-gated fields
- This is more type-safe than returning `summary: string | null` — the client cannot accidentally use `summary` without first checking `hasAi`
- The added schema complexity is a trade-off; simpler nullable fields are acceptable when strict client-side narrowing is not required [Inference]

---

### Conditional Router Exposure

For features where the entire router subtree should be hidden when a flag is off, conditional exposure at the router assembly level is an option:

```ts
// server/routers/index.ts
import { staticFlags } from '../flags';
import { betaRouter } from './beta';
import { aiRouter } from './ai';

export const appRouter = router({
  user: userRouter,
  post: postRouter,
  ...(staticFlags.enableBetaApi && { beta: betaRouter }),
  ...(staticFlags.enableAiFeatures && { ai: aiRouter }),
});
```

**Key Points:**

- When the flag is `false`, the router key is entirely absent from `appRouter` — the client type system will not include it, and calls to `trpc.ai.*` will fail at compile time as well as runtime
- This is a static flag pattern only — it is evaluated at module load time. User-targeted flags cannot be used here because the router shape must be fixed for the TypeScript compiler [Inference: attempting dynamic router shapes per request is architecturally incompatible with tRPC's type system]
- When the flag transitions from `false` to `true`, the server must restart for the router to include the new subtree

---

### Integrating a Remote Flag Provider

For production systems using a managed flag service, the integration point is context creation. Below is a generalized pattern compatible with providers such as LaunchDarkly, Unleash, Flagsmith, or GrowthBook.

```ts
// server/lib/flags.ts
export interface FeatureFlags {
  enableBetaApi: boolean;
  enableAiFeatures: boolean;
  enableNewBillingFlow: boolean;
  maxUploadSizeMb: number;         // flags can carry non-boolean values
}

export const defaultFlags: FeatureFlags = {
  enableBetaApi: false,
  enableAiFeatures: false,
  enableNewBillingFlow: false,
  maxUploadSizeMb: 10,
};

export async function resolveFlags(
  userId?: string,
  tenantId?: string
): Promise<FeatureFlags> {
  // Replace with your provider's SDK call
  const raw = await flagProvider.evaluate({
    context: { userId, tenantId },
  });

  return {
    enableBetaApi: raw.getBoolean('enable-beta-api', false),
    enableAiFeatures: raw.getBoolean('enable-ai-features', false),
    enableNewBillingFlow: raw.getBoolean('enable-new-billing-flow', false),
    maxUploadSizeMb: raw.getNumber('max-upload-size-mb', 10),
  };
}
```

```ts
// server/context.ts
import { resolveFlags, defaultFlags } from './lib/flags';

export async function createContext({ req }: CreateNextContextOptions) {
  const session = await getSession(req);

  const flags = await resolveFlags(
    session?.user?.id,
    session?.user?.tenantId
  ).catch(() => defaultFlags); // fallback on provider failure

  return { session, db, flags };
}
```

---

### Visualizing Flag Evaluation Flow

YesNoYesNoYesNoYesNoIncoming RequestcreateContextresolveFlags - userId +tenantIdProvider available?Evaluated flagsdefaultFlags fallbackctx.flagsProcedure usesrequireFlag?Flag enabled?NOT_FOUNDResolver executesIn-resolver flag check?Conditional behaviorStandard behaviorResponse

---

### Exposing Flag State to the Client

In some architectures, the client needs to know which flags are active — to conditionally render UI, hide navigation items, or adjust behavior. A dedicated procedure can expose this safely.

```ts
export const flagsRouter = router({
  getClientFlags: protectedProcedure
    .query(({ ctx }) => {
      // Expose only flags relevant to the client
      // Do not expose internal infrastructure flags
      return {
        enableBetaApi: ctx.flags.enableBetaApi,
        enableAiFeatures: ctx.flags.enableAiFeatures,
      };
    }),
});
```

**Key Points:**

- Only expose flags the client legitimately needs — exposing all flags may reveal unreleased features or internal configuration
- The client should treat these flags as hints for UI rendering, not as security gates. Authorization enforcement remains server-side [Inference: client-side flag checks are trivially bypassable; never use them as the sole access control]
- Fetching flags via a tRPC query means the client benefits from the same caching and invalidation mechanisms as any other query

---

### Common Pitfalls

**Pitfall 1 — Relying on client-side flags for access control:**
If a feature is disabled by a flag, that enforcement must exist on the server. A client that skips the UI for a disabled feature can still call the tRPC procedure directly. Server-side middleware or resolver checks are mandatory.

**Pitfall 2 — Inconsistent flag state across a request:**
Evaluating flags inside individual resolvers rather than in context can produce inconsistent results within a single request — particularly with remote providers where evaluation is non-deterministic or involves caching windows. Context-level evaluation enforces consistency.

**Pitfall 3 — Missing fallback on provider failure:**
Remote flag providers can be unavailable. Without a fallback to safe defaults, a provider outage causes your entire tRPC API to fail at context creation. Always wrap remote evaluations in a try/catch with a conservative default.

**Pitfall 4 — Stale flags in long-lived processes:**
Serverless environments re-evaluate context per request, so flags stay current. Long-lived server processes (e.g., a persistent Node.js server) may cache a flag provider SDK's internal state. Verify your SDK's polling or streaming behavior to understand how quickly flag changes propagate. [Inference: behavior is SDK and provider specific]

---

**Conclusion**

Feature flag integration in tRPC is most cleanly expressed through three layers: resolution in context (once per request, consistent across all procedures), enforcement in middleware (blocking access to gated procedures), and conditional logic in resolvers (for partial behavioral variation). Static flags suit deploy-time gates and can conditionally exclude entire router subtrees from the type system. Remote flags suit user- or tenant-targeted rollouts and belong in context creation with a safe fallback. Client-side flag exposure through a dedicated query is appropriate for UI rendering hints, but server-side enforcement remains mandatory regardless.
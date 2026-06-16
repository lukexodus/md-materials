## Per-Resource Authorization Checks in tRPC

Per-resource authorization checks extend beyond simple role gating — they determine whether a requesting user has rights over a *specific piece of data*, not just a category of action. A user may be allowed to "edit posts" in general but not allowed to edit *this particular post* if they don't own it.

---

### Why Per-Resource Checks Are Necessary

Route-level middleware can confirm identity and broad permissions, but it cannot know which specific resource is being requested until the procedure runs. Per-resource checks happen *inside* the procedure, after the resource has been fetched, comparing the resource's ownership or access metadata against the authenticated user.

**Key Points:**

- Middleware handles *who you are* and *what you're generally allowed to do*
- Per-resource checks handle *whether you may act on this specific thing*
- Skipping this layer is a common cause of Insecure Direct Object Reference (IDOR) vulnerabilities

---

### The Basic Pattern

The fundamental structure is: fetch → check → act.

```ts
// server/routers/post.ts
import { protectedProcedure, router } from '../trpc';
import { z } from 'zod';
import { TRPCError } from '@trpc/server';

export const postRouter = router({
  update: protectedProcedure
    .input(z.object({
      postId: z.string(),
      content: z.string(),
    }))
    .mutation(async ({ ctx, input }) => {
      const post = await ctx.db.post.findUnique({
        where: { id: input.postId },
      });

      if (!post) {
        throw new TRPCError({ code: 'NOT_FOUND' });
      }

      // Per-resource authorization check
      if (post.authorId !== ctx.user.id) {
        throw new TRPCError({ code: 'FORBIDDEN' });
      }

      return ctx.db.post.update({
        where: { id: input.postId },
        data: { content: input.content },
      });
    }),
});
```

**Key Points:**

- Always fetch the resource before checking ownership — you cannot authorize against data you don't have
- Throw `NOT_FOUND` before `FORBIDDEN` when the resource doesn't exist, to avoid leaking existence information to unauthorized callers [Inference: this is a common security convention, but the right choice depends on your threat model]
- The check compares a resource field (`authorId`) to a context value (`ctx.user.id`)

---

### Extracting a Reusable Authorization Helper

When multiple procedures need ownership checks on the same resource type, inline checks create duplication. Extract them into typed helper functions.

```ts
// server/lib/authz.ts
import { TRPCError } from '@trpc/server';

type AuthorizedUser = { id: string; role: string };

export function assertPostOwner(
  post: { authorId: string },
  user: AuthorizedUser
) {
  if (post.authorId !== user.id) {
    throw new TRPCError({ code: 'FORBIDDEN' });
  }
}

export function assertCommentOwner(
  comment: { userId: string },
  user: AuthorizedUser
) {
  if (comment.userId !== user.id) {
    throw new TRPCError({ code: 'FORBIDDEN' });
  }
}
```

```ts
// Usage in procedure
import { assertPostOwner } from '../lib/authz';

update: protectedProcedure
  .input(z.object({ postId: z.string(), content: z.string() }))
  .mutation(async ({ ctx, input }) => {
    const post = await ctx.db.post.findUnique({
      where: { id: input.postId },
    });

    if (!post) throw new TRPCError({ code: 'NOT_FOUND' });

    assertPostOwner(post, ctx.user);

    return ctx.db.post.update({
      where: { id: input.postId },
      data: { content: input.content },
    });
  }),
```

---

### Role-Augmented Per-Resource Checks

Admins or moderators often need to bypass ownership constraints. Combine role checks with ownership checks in the same helper.

```ts
// server/lib/authz.ts
export function assertPostAccess(
  post: { authorId: string },
  user: { id: string; role: string }
) {
  const isOwner = post.authorId === user.id;
  const isAdmin = user.role === 'admin';

  if (!isOwner && !isAdmin) {
    throw new TRPCError({ code: 'FORBIDDEN' });
  }
}
```

```ts
// Procedure remains clean
assertPostAccess(post, ctx.user);
```

**Key Points:**

- The logic for "who can act" lives in one place, not scattered across procedures
- Adding new roles (e.g., `moderator`) requires changing only the helper

---

### Authorization via Membership or Relationship

Not all access models are owner-based. Some resources are shared among groups — for example, a workspace, team, or project. Here the check queries a *membership table* rather than a single owner field.

```ts
deleteProject: protectedProcedure
  .input(z.object({ projectId: z.string() }))
  .mutation(async ({ ctx, input }) => {
    const membership = await ctx.db.projectMember.findFirst({
      where: {
        projectId: input.projectId,
        userId: ctx.user.id,
        role: { in: ['owner', 'admin'] },
      },
    });

    if (!membership) {
      throw new TRPCError({ code: 'FORBIDDEN' });
    }

    return ctx.db.project.delete({
      where: { id: input.projectId },
    });
  }),
```

**Key Points:**

- This pattern delegates authorization logic to the database query
- The trade-off is an extra query per request; this may be mitigated by caching membership data in context [Inference]

---

### Preloading Authorization Data into Context

If many procedures check membership or roles against the same resource type, issuing repeated queries is expensive. One approach is to preload a lightweight authorization object into the context at request time.

```ts
// server/context.ts
export async function createContext({ req }: CreateNextContextOptions) {
  const user = await getUserFromRequest(req);

  // Preload team memberships if user is authenticated
  const memberships = user
    ? await db.teamMember.findMany({
        where: { userId: user.id },
        select: { teamId: true, role: true },
      })
    : [];

  return { user, memberships, db };
}
```

```ts
// In procedure — no extra DB query needed
getTeamData: protectedProcedure
  .input(z.object({ teamId: z.string() }))
  .query(async ({ ctx, input }) => {
    const membership = ctx.memberships.find(
      (m) => m.teamId === input.teamId
    );

    if (!membership) {
      throw new TRPCError({ code: 'FORBIDDEN' });
    }

    return ctx.db.team.findUnique({ where: { id: input.teamId } });
  }),
```

**Key Points:**

- This trades startup cost (one broader query at context creation) for per-procedure savings
- Only appropriate when the preloaded set is small and bounded [Inference]
- For users with large numbers of team memberships, preloading the full set may not scale [Inference]

---

### Using a Middleware for Shared Resource Authorization

When a single resource type is accessed across many procedures, a reusable middleware that fetches and attaches the resource to context can centralize both fetching and authorization.

```ts
// server/middleware/withPost.ts
import { middleware, protectedProcedure } from '../trpc';
import { TRPCError } from '@trpc/server';
import { z } from 'zod';

const withPost = middleware(async ({ ctx, next, rawInput }) => {
  const parsed = z.object({ postId: z.string() }).safeParse(rawInput);

  if (!parsed.success) {
    throw new TRPCError({ code: 'BAD_REQUEST' });
  }

  const post = await ctx.db.post.findUnique({
    where: { id: parsed.data.postId },
  });

  if (!post) throw new TRPCError({ code: 'NOT_FOUND' });

  if (post.authorId !== ctx.user.id) {
    throw new TRPCError({ code: 'FORBIDDEN' });
  }

  return next({ ctx: { ...ctx, post } });
});

export const postOwnerProcedure = protectedProcedure.use(withPost);
```

```ts
// Usage — post is already fetched and authorized in ctx
update: postOwnerProcedure
  .input(z.object({ postId: z.string(), content: z.string() }))
  .mutation(async ({ ctx, input }) => {
    // ctx.post is guaranteed to exist and belong to ctx.user
    // (behavior depends on middleware executing correctly — not an absolute guarantee)
    return ctx.db.post.update({
      where: { id: ctx.post.id },
      data: { content: input.content },
    });
  }),
```

**Key Points:**

- `postOwnerProcedure` encodes the full fetch-and-authorize flow as a reusable base
- Procedures built on it can skip redundant checks
- Parsing `rawInput` inside middleware carries a caveat: if input validation hasn't run yet, the shape is untyped — use `safeParse` defensively

---

### Authorization Flow Diagram

<svg viewBox="0 0 680 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
<!-- Background -->
<rect width="680" height="420" fill="#0f1117" rx="12"/>
<!-- Title -->

<text x="340" y="36" text-anchor="middle" fill="`#e2e8f0`" font-size="15" font-weight="bold">Per-Resource Authorization Flow</text>

<!-- Step boxes -->
<!-- 1: Request -->
<rect x="270" y="60" width="140" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="340" y="87" text-anchor="middle" fill="#94a3b8">Incoming Request</text>
<!-- Arrow down -->
<line x1="340" y1="104" x2="340" y2="128" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- 2: Auth Middleware -->
<rect x="255" y="128" width="170" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="340" y="155" text-anchor="middle" fill="#94a3b8">Auth Middleware</text>
<!-- Arrow: pass / fail -->
<!-- Pass arrow down -->
<line x1="340" y1="172" x2="340" y2="196" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- Fail arrow right -->
<line x1="425" y1="150" x2="530" y2="150" stroke="#ef4444" stroke-width="1.5" marker-end="url(#arrerr)"/>
<text x="472" y="144" text-anchor="middle" fill="#ef4444" font-size="11">UNAUTHORIZED</text>
<!-- 3: Fetch Resource -->
<rect x="255" y="196" width="170" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="340" y="223" text-anchor="middle" fill="#94a3b8">Fetch Resource</text>
<!-- Not Found arrow right -->
<line x1="425" y1="218" x2="530" y2="218" stroke="#f59e0b" stroke-width="1.5" marker-end="url(#arrwarn)"/>
<text x="472" y="212" text-anchor="middle" fill="#f59e0b" font-size="11">NOT_FOUND</text>
<!-- Arrow down -->
<line x1="340" y1="240" x2="340" y2="264" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- 4: Per-resource check -->
<rect x="235" y="264" width="210" height="44" rx="8" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
<text x="340" y="291" text-anchor="middle" fill="#93c5fd">Per-Resource Auth Check</text>
<!-- Forbidden arrow right -->
<line x1="445" y1="286" x2="530" y2="286" stroke="#ef4444" stroke-width="1.5" marker-end="url(#arrerr)"/>
<text x="487" y="280" text-anchor="middle" fill="#ef4444" font-size="11">FORBIDDEN</text>
<!-- Arrow down -->
<line x1="340" y1="308" x2="340" y2="332" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- 5: Execute Mutation / Query -->
<rect x="240" y="332" width="200" height="44" rx="8" fill="#14532d" stroke="#22c55e" stroke-width="1.5"/>
<text x="340" y="359" text-anchor="middle" fill="#86efac">Execute Procedure</text>
<!-- Arrow down -->
<line x1="340" y1="376" x2="340" y2="400" stroke="#22c55e" stroke-width="1.5" marker-end="url(#arrgreen)"/>
<text x="340" y="414" text-anchor="middle" fill="#86efac" font-size="12">Response</text>
<!-- Error box -->
<rect x="530" y="126" width="120" height="196" rx="8" fill="#1a0a0a" stroke="#7f1d1d" stroke-width="1.2"/>
<text x="590" y="198" text-anchor="middle" fill="#fca5a5" font-size="12">Error</text>
<text x="590" y="216" text-anchor="middle" fill="#fca5a5" font-size="12">Responses</text>
<!-- Labels on left -->

<text x="228" y="155" text-anchor="end" fill="`#64748b`" font-size="11">identity</text>
<text x="228" y="223" text-anchor="end" fill="`#64748b`" font-size="11">existence</text>
<text x="228" y="291" text-anchor="end" fill="`#64748b`" font-size="11">ownership</text>

<!-- Arrowhead markers -->
<defs>
<marker id="arr" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#475569"/>
</marker>
<marker id="arrerr" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#ef4444"/>
</marker>
<marker id="arrwarn" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#f59e0b"/>
</marker>
<marker id="arrgreen" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#22c55e"/>
</marker>
</defs>
</svg>

---

### Error Response Conventions

| Situation | Recommended Code | Notes |
| --- | --- | --- |
| User not authenticated | `UNAUTHORIZED` | Handled by auth middleware |
| Resource does not exist | `NOT_FOUND` | Return before ownership check |
| Resource exists, user lacks access | `FORBIDDEN` | After ownership check fails |
| Input missing or malformed | `BAD_REQUEST` | Before any DB interaction |

**Key Points:**

- Returning `NOT_FOUND` for non-existent resources (even when the user would be unauthorized) is a common convention to avoid confirming that a resource exists
- The right choice between `NOT_FOUND` and `FORBIDDEN` for inaccessible-but-existing resources depends on your application's security requirements [Inference]

---

### Common Mistakes

**Checking authorization before fetching:**

```ts
// ❌ Cannot check ownership without the resource
if (input.postId !== ctx.user.id) { ... } // This makes no sense
```

**Trusting client-supplied ownership data:**

```ts
// ❌ Never trust the client to tell you who owns the resource
.input(z.object({ postId: z.string(), authorId: z.string() }))
.mutation(async ({ ctx, input }) => {
  if (input.authorId !== ctx.user.id) { ... } // authorId is attacker-controlled
})
```

**Correct approach:**

```ts
// ✅ Fetch authorId from the database, not from client input
const post = await ctx.db.post.findUnique({ where: { id: input.postId } });
if (post.authorId !== ctx.user.id) { ... }
```

---

**Next Steps:** Field-level authorization — restricting which fields are returned or mutated based on the caller's role or relationship to the resource.
## Migrating from GraphQL to tRPC

Migrating from GraphQL to tRPC is conceptually closer than migrating from REST — both are typed, schema-driven RPC systems with client-server co-generation. The key difference is that GraphQL's type system lives in SDL (Schema Definition Language) and is language-agnostic, while tRPC's type system lives entirely in TypeScript. The migration replaces the SDL layer with Zod schemas and TypeScript types, and replaces resolvers with procedures.

---

### Conceptual Mapping: GraphQL to tRPC

Before touching code, understanding the direct conceptual equivalents reduces the cognitive overhead of the migration.

| GraphQL concept | tRPC equivalent |
|---|---|
| Schema SDL (`type`, `input`) | Zod schemas + TypeScript types |
| `Query` type field | `query` procedure |
| `Mutation` type field | `mutation` procedure |
| `Subscription` type field | `subscription` procedure (via WebSocket) |
| Resolver function | Procedure handler |
| `context` (per-request) | tRPC `context` |
| Middleware / plugins (Apollo) | tRPC `middleware` |
| `DataLoader` | `DataLoader` (unchanged — library-level) |
| `__typename` / fragments | TypeScript union types / discriminated unions |
| Nested resolvers | Nested routers |
| `@deprecated` directive | No direct equivalent — TypeScript `@deprecated` JSDoc |
| `@auth` directive | `protectedProcedure` middleware |
| `GraphQLError` | `TRPCError` |
| `useQuery` (urql / Apollo) | `trpc.procedure.useQuery` |
| `useMutation` | `trpc.procedure.useMutation` |
| `useSubscription` | `trpc.procedure.useSubscription` |
| Fragment colocation | No direct equivalent — TypeScript types serve this role |

**Key Points:**
- GraphQL's flexible field selection (clients request only what they need) has no direct tRPC equivalent — tRPC procedures return a fixed shape [Inference — this is the most significant architectural difference]
- GraphQL SDL serves as a language-agnostic contract visible to non-TypeScript consumers; tRPC's contract is TypeScript-only — factor this into the migration decision if non-TypeScript clients exist

---

### What tRPC Does Not Replicate

Some GraphQL capabilities do not have tRPC equivalents. These should be evaluated before committing to the migration.

**Selective field fetching:** GraphQL clients request only the fields they need. tRPC procedures return fixed shapes. If many clients request different subsets of a large object, tRPC may over-fetch at the database layer [Inference — impact depends on query complexity and dataset size].

**Graph traversal / nested resolvers:** GraphQL can resolve deeply nested relationships lazily, with each resolver layer potentially hitting a different data source. tRPC procedures are flat — complex graph traversal must be handled explicitly in the procedure body.

**Introspection for non-TypeScript clients:** GraphQL introspection allows any client in any language to discover the schema at runtime. tRPC provides no introspection endpoint — non-TypeScript clients require an OpenAPI layer (see `trpc-openapi`) or manual documentation.

**Federation:** Apollo Federation and similar tools compose schemas across microservices. tRPC has no native federation equivalent — multi-service composition requires manual router merging or a gateway layer [Inference].

**Key Points:**
- If the GraphQL schema's primary value is field-level selection granularity or cross-service federation, tRPC may not be the right migration target
- If the GraphQL schema's primary value is type safety and structured RPC over a TypeScript stack, tRPC is a strong replacement

---

### Phase 1: Install and Mount tRPC Without Removing GraphQL

The GraphQL server remains fully operational. tRPC is mounted at a new path alongside it.

**Example — Apollo Server + Express before migration:**

```ts
import express from "express";
import { ApolloServer } from "@apollo/server";
import { expressMiddleware } from "@apollo/server/express4";
import { schema } from "./graphql/schema";
import { createGraphQLContext } from "./graphql/context";

const app = express();
const apollo = new ApolloServer({ schema });
await apollo.start();

app.use(express.json());
app.use("/graphql", expressMiddleware(apollo, { context: createGraphQLContext }));

app.listen(4000);
```

**Example — after Phase 1 (tRPC added alongside GraphQL):**

```ts
import express from "express";
import { ApolloServer } from "@apollo/server";
import { expressMiddleware } from "@apollo/server/express4";
import { createExpressMiddleware } from "@trpc/server/adapters/express";
import { schema } from "./graphql/schema";
import { createGraphQLContext } from "./graphql/context";
import { appRouter } from "./trpc/routers/_app";
import { createContext } from "./trpc/context";

const app = express();
const apollo = new ApolloServer({ schema });
await apollo.start();

app.use(express.json());

// GraphQL — unchanged
app.use("/graphql", expressMiddleware(apollo, { context: createGraphQLContext }));

// tRPC — new path, no conflict
app.use("/trpc", createExpressMiddleware({ router: appRouter, createContext }));

app.listen(4000);
```

---

### Phase 2: Translate the GraphQL Schema to Zod + TypeScript

Each GraphQL type becomes a Zod schema. Input types become Zod input schemas. Output types become Zod output schemas or plain TypeScript types.

**Example — GraphQL SDL:**

```graphql
type User {
  id: ID!
  name: String!
  email: String!
  role: UserRole!
  createdAt: String!
  profile: UserProfile
}

type UserProfile {
  bio: String
  avatarUrl: String
}

enum UserRole {
  ADMIN
  USER
  GUEST
}

input CreateUserInput {
  name: String!
  email: String!
  role: UserRole
}

input UpdateUserInput {
  name: String
  email: String
}
```

**Example — equivalent Zod schemas (`src/trpc/schemas/user.ts`):**

```ts
import { z } from "zod";

export const UserRoleSchema = z.enum(["ADMIN", "USER", "GUEST"]);

export const UserProfileSchema = z.object({
  bio: z.string().nullable(),
  avatarUrl: z.string().url().nullable(),
});

export const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
  role: UserRoleSchema,
  createdAt: z.string().datetime(),
  profile: UserProfileSchema.nullable(),
});

export const CreateUserInputSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  role: UserRoleSchema.optional().default("USER"),
});

export const UpdateUserInputSchema = z.object({
  name: z.string().min(1).optional(),
  email: z.string().email().optional(),
});

// TypeScript types inferred from schemas
export type User = z.infer<typeof UserSchema>;
export type CreateUserInput = z.infer<typeof CreateUserInputSchema>;
export type UpdateUserInput = z.infer<typeof UpdateUserInputSchema>;
```

**Key Points:**
- GraphQL `!` (non-null) maps to a required Zod field (no `.nullable()`, no `.optional()`)
- GraphQL nullable fields (`String` without `!`) map to `.nullable()` in Zod
- GraphQL `ID` type maps to `z.string()` — IDs are strings in the transport layer regardless of database type
- GraphQL `enum` maps to `z.enum([...])` with string literal values
- GraphQL `union` types map to `z.discriminatedUnion()` or `z.union()` — discriminated unions are preferred for performance [Inference]

---

### Phase 3: Translate Resolvers to Procedures

Each GraphQL query and mutation resolver becomes a tRPC procedure. The resolver's data fetching logic moves into the procedure handler.

**Example — GraphQL resolvers:**

```ts
// graphql/resolvers/user.ts
export const userResolvers = {
  Query: {
    user: async (_parent, { id }, ctx) => {
      const user = await ctx.db.user.findUnique({ where: { id } });
      if (!user) throw new GraphQLError("User not found", {
        extensions: { code: "NOT_FOUND" },
      });
      return user;
    },

    users: async (_parent, { limit, offset }, ctx) => {
      return ctx.db.user.findMany({
        take: limit ?? 20,
        skip: offset ?? 0,
        orderBy: { createdAt: "desc" },
      });
    },
  },

  Mutation: {
    createUser: async (_parent, { input }, ctx) => {
      if (!ctx.user) throw new GraphQLError("Unauthorized", {
        extensions: { code: "UNAUTHORIZED" },
      });
      return ctx.db.user.create({ data: input });
    },

    updateUser: async (_parent, { id, input }, ctx) => {
      if (!ctx.user) throw new GraphQLError("Unauthorized", {
        extensions: { code: "UNAUTHORIZED" },
      });
      return ctx.db.user.update({ where: { id }, data: input });
    },

    deleteUser: async (_parent, { id }, ctx) => {
      if (!ctx.user) throw new GraphQLError("Unauthorized", {
        extensions: { code: "UNAUTHORIZED" },
      });
      await ctx.db.user.delete({ where: { id } });
      return true;
    },
  },
};
```

**Example — equivalent tRPC procedures (`src/trpc/routers/user.ts`):**

```ts
import { z } from "zod";
import { TRPCError } from "@trpc/server";
import { router, publicProcedure, protectedProcedure } from "../trpc";
import {
  UserSchema,
  CreateUserInputSchema,
  UpdateUserInputSchema,
} from "../schemas/user";

export const userRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .output(UserSchema)
    .query(async ({ input, ctx }) => {
      const user = await ctx.db.user.findUnique({ where: { id: input.id } });

      if (!user) {
        throw new TRPCError({ code: "NOT_FOUND", message: "User not found" });
      }

      return user;
    }),

  list: publicProcedure
    .input(z.object({
      limit: z.number().int().min(1).max(100).default(20),
      offset: z.number().int().min(0).default(0),
    }))
    .output(z.array(UserSchema))
    .query(async ({ input, ctx }) => {
      return ctx.db.user.findMany({
        take: input.limit,
        skip: input.offset,
        orderBy: { createdAt: "desc" },
      });
    }),

  create: protectedProcedure
    .input(CreateUserInputSchema)
    .output(UserSchema)
    .mutation(async ({ input, ctx }) => {
      return ctx.db.user.create({ data: input });
    }),

  update: protectedProcedure
    .input(z.object({
      id: z.string(),
      data: UpdateUserInputSchema,
    }))
    .output(UserSchema)
    .mutation(async ({ input, ctx }) => {
      return ctx.db.user.update({
        where: { id: input.id },
        data: input.data,
      });
    }),

  delete: protectedProcedure
    .input(z.object({ id: z.string() }))
    .output(z.boolean())
    .mutation(async ({ input, ctx }) => {
      await ctx.db.user.delete({ where: { id: input.id } });
      return true;
    }),
});
```

**Key Points:**
- `_parent` (the resolver parent object) has no equivalent in tRPC — nested object resolution is handled explicitly in the procedure body
- `GraphQLError` with extension codes maps directly to `TRPCError` with corresponding `code` values
- Auth guards that were scattered across resolvers are consolidated into `protectedProcedure` middleware — one definition applies to all protected procedures

---

### Phase 4: Translating Nested Resolvers

GraphQL nested resolvers resolve fields on a type lazily. tRPC has no equivalent — nested data must be fetched eagerly in the procedure body or via separate procedures called by the client.

**Example — GraphQL nested resolver:**

```graphql
type Post {
  id: ID!
  title: String!
  author: User!       # resolved lazily
  comments: [Comment!]!  # resolved lazily
}
```

```ts
// Resolvers
const postResolvers = {
  Post: {
    author: (parent, _args, ctx) =>
      ctx.db.user.findUnique({ where: { id: parent.authorId } }),

    comments: (parent, _args, ctx) =>
      ctx.db.comment.findMany({ where: { postId: parent.id } }),
  },
};
```

**tRPC equivalents — two strategies:**

#### Strategy A: Eager Fetch (Single Procedure)

```ts
export const postRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ input, ctx }) => {
      // Fetch everything in one query
      return ctx.db.post.findUnique({
        where: { id: input.id },
        include: { author: true, comments: true },
      });
    }),
});
```

#### Strategy B: Separate Procedures (Client Composes)

```ts
export const postRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(({ input, ctx }) =>
      ctx.db.post.findUnique({ where: { id: input.id } })
    ),

  getAuthor: publicProcedure
    .input(z.object({ postId: z.string() }))
    .query(async ({ input, ctx }) => {
      const post = await ctx.db.post.findUnique({ where: { id: input.postId } });
      return ctx.db.user.findUnique({ where: { id: post!.authorId } });
    }),

  getComments: publicProcedure
    .input(z.object({ postId: z.string() }))
    .query(({ input, ctx }) =>
      ctx.db.comment.findMany({ where: { postId: input.postId } })
    ),
});
```

**Key Points:**
- Strategy A (eager fetch) is simpler and fits most use cases — it eliminates the N+1 problem that DataLoader was solving in GraphQL [Inference]
- Strategy B (separate procedures) mirrors GraphQL's lazy resolution model and suits cases where not all clients need all nested data
- tRPC's request batching means multiple procedure calls from one client render in a single HTTP request — Strategy B's multiple calls are batched automatically [Inference]

---

### Phase 5: Migrating DataLoader

GraphQL uses DataLoader to batch and cache per-request data fetches, addressing the N+1 problem in nested resolvers. In tRPC, N+1 typically does not arise because eager fetching with `include` is the norm — but DataLoader remains useful for shared lookups across procedures in a single request.

**Example — DataLoader in GraphQL context:**

```ts
// graphql/context.ts
import DataLoader from "dataloader";

export function createGraphQLContext() {
  return {
    db,
    loaders: {
      user: new DataLoader(async (ids: readonly string[]) => {
        const users = await db.user.findMany({
          where: { id: { in: [...ids] } },
        });
        return ids.map(id => users.find(u => u.id === id) ?? null);
      }),
    },
  };
}
```

**Example — DataLoader in tRPC context:**

```ts
// trpc/context.ts
import DataLoader from "dataloader";
import { db } from "../db";

export async function createContext() {
  return {
    db,
    loaders: {
      user: new DataLoader(async (ids: readonly string[]) => {
        const users = await db.user.findMany({
          where: { id: { in: [...ids] } },
        });
        return ids.map(id => users.find(u => u.id === id) ?? null);
      }),
    },
  };
}
```

**Key Points:**
- DataLoader is context-level, not procedure-level — it is instantiated fresh per request in both GraphQL and tRPC, which is the correct pattern [Inference]
- The DataLoader library itself is framework-agnostic — the migration of DataLoader usage is a transplant, not a rewrite
- If eager fetching with Prisma `include` replaces nested resolvers during migration, DataLoader may become unnecessary [Inference — depends on data access patterns]

---

### Phase 6: Migrating GraphQL Subscriptions

GraphQL subscriptions typically use WebSocket transports (subscriptions-transport-ws, graphql-ws). tRPC subscriptions use its own WebSocket adapter.

**Example — GraphQL subscription:**

```graphql
type Subscription {
  messageAdded(channelId: ID!): Message!
}
```

```ts
// GraphQL subscription resolver
const subscriptionResolvers = {
  Subscription: {
    messageAdded: {
      subscribe: (_parent, { channelId }, ctx) =>
        ctx.pubsub.asyncIterableIterator(`MESSAGE_ADDED:${channelId}`),
    },
  },
};
```

**Example — equivalent tRPC subscription:**

```ts
import { observable } from "@trpc/server/observable";
import EventEmitter from "events";

const ee = new EventEmitter();

export const messageRouter = router({
  onMessageAdded: publicProcedure
    .input(z.object({ channelId: z.string() }))
    .subscription(({ input }) => {
      return observable<Message>(({ next }) => {
        const handler = (message: Message) => {
          if (message.channelId === input.channelId) {
            next(message);
          }
        };

        ee.on("messageAdded", handler);
        return () => ee.off("messageAdded", handler);
      });
    }),
});

// Emit from mutation
export const sendMessage = protectedProcedure
  .input(z.object({ channelId: z.string(), content: z.string() }))
  .mutation(async ({ input, ctx }) => {
    const message = await ctx.db.message.create({ data: input });
    ee.emit("messageAdded", message);
    return message;
  });
```

**Key Points:**
- tRPC subscriptions require the WebSocket adapter (`@trpc/server/adapters/ws`) — the HTTP adapter does not support subscriptions
- `EventEmitter` replaces PubSub libraries for in-process scenarios — for multi-instance deployments, a Redis-backed PubSub remains necessary [Inference]
- The tRPC client subscription API (`trpc.message.onMessageAdded.useSubscription`) differs from Apollo's `useSubscription` hook — client migration is required alongside server migration

---

### Phase 7: Migrating Apollo Client to tRPC Client

Apollo Client and urql manage caching, subscriptions, and state. The tRPC + React Query stack replaces this.

**Example — Apollo Client query (before):**

```tsx
import { useQuery, gql } from "@apollo/client";

const GET_USER = gql`
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
      email
    }
  }
`;

function UserProfile({ id }: { id: string }) {
  const { data, loading, error } = useQuery(GET_USER, { variables: { id } });

  if (loading) return <Spinner />;
  if (error) return <Error message={error.message} />;

  return <div>{data.user.name}</div>;
}
```

**Example — tRPC + React Query equivalent (after):**

```tsx
import { trpc } from "../utils/trpc";

function UserProfile({ id }: { id: string }) {
  const { data, isLoading, error } = trpc.user.getById.useQuery({ id });

  if (isLoading) return <Spinner />;
  if (error) return <Error message={error.message} />;

  return <div>{data.name}</div>;
}
```

**Example — Apollo mutation (before):**

```tsx
const CREATE_USER = gql`
  mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) { id name email }
  }
`;

const [createUser, { loading }] = useMutation(CREATE_USER, {
  onCompleted: () => refetch(),
});

createUser({ variables: { input: { name, email } } });
```

**Example — tRPC mutation (after):**

```tsx
const utils = trpc.useUtils();

const createUser = trpc.user.create.useMutation({
  onSuccess: () => utils.user.list.invalidate(),
});

createUser.mutate({ name, email });
```

**Key Points:**
- Apollo's normalized cache (entity-level cache keyed by `__typename` + `id`) has no direct equivalent in React Query — React Query uses query-key-based invalidation, which is less granular but simpler [Inference]
- `utils.user.list.invalidate()` replaces Apollo's `refetchQueries` and cache eviction — it re-fetches the query rather than patching the cache
- Fragment colocation (co-locating data requirements with components) is a GraphQL pattern with no tRPC equivalent — data shape is defined at the procedure level, not the component level
- Apollo Client's `InMemoryCache` optimistic updates translate to React Query's `onMutate` + `cancelQueries` + `setQueryData` pattern

---

### Migrating Apollo Client Optimistic Updates

**Example — Apollo optimistic update (before):**

```ts
createUser({
  variables: { input: { name, email } },
  optimisticResponse: {
    createUser: { __typename: "User", id: "temp-id", name, email },
  },
  update(cache, { data }) {
    cache.modify({
      fields: {
        users(existing = []) {
          return [...existing, data.createUser];
        },
      },
    });
  },
});
```

**Example — tRPC + React Query optimistic update (after):**

```ts
const utils = trpc.useUtils();

const createUser = trpc.user.create.useMutation({
  onMutate: async (newUser) => {
    await utils.user.list.cancel();
    const previous = utils.user.list.getData();

    utils.user.list.setData(undefined, (old) => [
      ...(old ?? []),
      { id: "temp-id", ...newUser },
    ]);

    return { previous };
  },
  onError: (_err, _newUser, context) => {
    utils.user.list.setData(undefined, context?.previous);
  },
  onSettled: () => {
    utils.user.list.invalidate();
  },
});
```

---

### Migration Progress Tracking

<svg viewBox="0 0 700 380" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="12">
  <rect width="700" height="380" fill="#0f1117" rx="12"/>
  <text x="350" y="28" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">GraphQL → tRPC Migration Checklist per Domain</text>

  <!-- Header row -->
  <rect x="30" y="45" width="640" height="28" rx="4" fill="#1e293b" stroke="#334155" stroke-width="1"/>
  <text x="50"  y="63" fill="#64748b" font-size="11" font-weight="bold">Domain</text>
  <text x="210" y="63" fill="#64748b" font-size="11" font-weight="bold">GraphQL artifact</text>
  <text x="390" y="63" fill="#64748b" font-size="11" font-weight="bold">tRPC equivalent</text>
  <text x="580" y="63" fill="#64748b" font-size="11" font-weight="bold">Client change?</text>

  <!-- Rows -->
  <rect x="30" y="73" width="640" height="26" rx="0" fill="#0f1117"/>
  <text x="50"  y="90" fill="#94a3b8" font-size="11">Types</text>
  <text x="210" y="90" fill="#64748b" font-size="11">SDL type / input</text>
  <text x="390" y="90" fill="#4ade80" font-size="11">Zod schema</text>
  <text x="580" y="90" fill="#f87171" font-size="11">Yes — import Zod type</text>

  <rect x="30" y="99" width="640" height="26" rx="0" fill="#1e293b" fill-opacity="0.3"/>
  <text x="50"  y="116" fill="#94a3b8" font-size="11">Query</text>
  <text x="210" y="116" fill="#64748b" font-size="11">Query resolver</text>
  <text x="390" y="116" fill="#4ade80" font-size="11">query procedure</text>
  <text x="580" y="116" fill="#f87171" font-size="11">Yes — useQuery hook</text>

  <rect x="30" y="125" width="640" height="26" rx="0" fill="#0f1117"/>
  <text x="50"  y="142" fill="#94a3b8" font-size="11">Mutation</text>
  <text x="210" y="142" fill="#64748b" font-size="11">Mutation resolver</text>
  <text x="390" y="142" fill="#4ade80" font-size="11">mutation procedure</text>
  <text x="580" y="142" fill="#f87171" font-size="11">Yes — useMutation hook</text>

  <rect x="30" y="151" width="640" height="26" rx="0" fill="#1e293b" fill-opacity="0.3"/>
  <text x="50"  y="168" fill="#94a3b8" font-size="11">Subscription</text>
  <text x="210" y="168" fill="#64748b" font-size="11">Subscription resolver</text>
  <text x="390" y="168" fill="#4ade80" font-size="11">subscription procedure</text>
  <text x="580" y="168" fill="#f87171" font-size="11">Yes — useSubscription</text>

  <rect x="30" y="177" width="640" height="26" rx="0" fill="#0f1117"/>
  <text x="50"  y="194" fill="#94a3b8" font-size="11">Auth</text>
  <text x="210" y="194" fill="#64748b" font-size="11">Directive / plugin</text>
  <text x="390" y="194" fill="#4ade80" font-size="11">protectedProcedure</text>
  <text x="580" y="194" fill="#fcd34d" font-size="11">No — transparent</text>

  <rect x="30" y="203" width="640" height="26" rx="0" fill="#1e293b" fill-opacity="0.3"/>
  <text x="50"  y="220" fill="#94a3b8" font-size="11">Context</text>
  <text x="210" y="220" fill="#64748b" font-size="11">context() function</text>
  <text x="390" y="220" fill="#4ade80" font-size="11">createContext()</text>
  <text x="580" y="220" fill="#fcd34d" font-size="11">No — server only</text>

  <rect x="30" y="229" width="640" height="26" rx="0" fill="#0f1117"/>
  <text x="50"  y="246" fill="#94a3b8" font-size="11">DataLoader</text>
  <text x="210" y="246" fill="#64748b" font-size="11">DataLoader in context</text>
  <text x="390" y="246" fill="#4ade80" font-size="11">DataLoader in context</text>
  <text x="580" y="246" fill="#fcd34d" font-size="11">No — server only</text>

  <rect x="30" y="255" width="640" height="26" rx="0" fill="#1e293b" fill-opacity="0.3"/>
  <text x="50"  y="272" fill="#94a3b8" font-size="11">Caching</text>
  <text x="210" y="272" fill="#64748b" font-size="11">Apollo InMemoryCache</text>
  <text x="390" y="272" fill="#4ade80" font-size="11">React Query cache</text>
  <text x="580" y="272" fill="#f87171" font-size="11">Yes — invalidation model</text>

  <rect x="30" y="281" width="640" height="26" rx="0" fill="#0f1117"/>
  <text x="50"  y="298" fill="#94a3b8" font-size="11">Error handling</text>
  <text x="210" y="298" fill="#64748b" font-size="11">GraphQLError</text>
  <text x="390" y="298" fill="#4ade80" font-size="11">TRPCError</text>
  <text x="580" y="298" fill="#fcd34d" font-size="11">No — transparent</text>

  <rect x="30" y="307" width="640" height="26" rx="0" fill="#1e293b" fill-opacity="0.3"/>
  <text x="50"  y="324" fill="#94a3b8" font-size="11">Nested resolvers</text>
  <text x="210" y="324" fill="#64748b" font-size="11">Type-level resolver</text>
  <text x="390" y="324" fill="#fcd34d" font-size="11">Eager include or separate proc</text>
  <text x="580" y="324" fill="#f87171" font-size="11">Possibly — depends</text>

  <rect x="30" y="333" width="640" height="26" rx="0" fill="#0f1117"/>
  <text x="50"  y="350" fill="#94a3b8" font-size="11">Fragments</text>
  <text x="210" y="350" fill="#64748b" font-size="11">Fragment + spread</text>
  <text x="390" y="350" fill="#fcd34d" font-size="11">TypeScript type reuse</text>
  <text x="580" y="350" fill="#f87171" font-size="11">Yes — remove fragments</text>
</svg>

---

### Handling the Overlap Period

During migration, some operations use GraphQL, others use tRPC. Both clients must be initialized and coexist in the frontend.

**Example — coexisting Apollo Client and tRPC client:**

```ts
// src/lib/apollo.ts — unchanged
import { ApolloClient, InMemoryCache } from "@apollo/client";
export const apolloClient = new ApolloClient({
  uri: "/graphql",
  cache: new InMemoryCache(),
});

// src/lib/trpc.ts — new
import { createTRPCReact } from "@trpc/react-query";
import type { AppRouter } from "../../server/trpc/routers/_app";
export const trpc = createTRPCReact<AppRouter>();
```

**Example — providers wrapping both:**

```tsx
// src/app/providers.tsx
import { ApolloProvider } from "@apollo/client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { httpBatchLink } from "@trpc/client";
import { apolloClient } from "../lib/apollo";
import { trpc } from "../lib/trpc";

const queryClient = new QueryClient();
const trpcClient = trpc.createClient({
  links: [httpBatchLink({ url: "/trpc" })],
});

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <ApolloProvider client={apolloClient}>
      <trpc.Provider client={trpcClient} queryClient={queryClient}>
        <QueryClientProvider client={queryClient}>
          {children}
        </QueryClientProvider>
      </trpc.Provider>
    </ApolloProvider>
  );
}
```

**Key Points:**
- Both providers can coexist indefinitely — there is no conflict at the React tree level [Inference]
- Bundle size increases during the overlap period as both Apollo Client and tRPC client are included — this is a temporary cost of incremental migration [Inference]
- Once all queries are migrated, `ApolloProvider` and `apollo-client` are removed entirely

---

### When to Keep GraphQL

Not all GraphQL APIs are good tRPC migration candidates. Retain GraphQL when:

- Non-TypeScript clients are primary consumers and require introspection or SDL-based codegen
- Selective field fetching is a hard requirement and over-fetching is a performance concern
- Apollo Federation is used to compose schemas across multiple independent services
- The team includes frontend engineers who are not TypeScript-first and benefit from GraphQL's language-agnostic tooling

**Key Points:**
- tRPC and GraphQL can coexist permanently — a partial migration that keeps some domains on GraphQL and others on tRPC is a valid architecture [Inference]
- The migration decision should be made per-domain, not as a binary all-or-nothing choice

---

**Conclusion:**
Migrating from GraphQL to tRPC is a structured translation: SDL types become Zod schemas, resolvers become procedures, GraphQL context becomes tRPC context, and Apollo Client becomes the tRPC React Query client. The migration is safe to perform incrementally — GraphQL and tRPC coexist on the same server and in the same React tree throughout the overlap period. The most significant architectural difference is the loss of selective field fetching and lazy nested resolution, which must be addressed through eager database fetching or separate procedures. DataLoader and PubSub patterns transplant without fundamental change. Subscriptions, optimistic updates, and the client-side caching model require deliberate adaptation rather than direct translation. Behavioral parity between GraphQL and tRPC versions of each operation should be validated before migrating client call sites.
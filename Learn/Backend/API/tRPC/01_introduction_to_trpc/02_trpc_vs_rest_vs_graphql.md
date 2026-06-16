## tRPC vs REST vs GraphQL

### What This Comparison Covers

tRPC, REST, and GraphQL are three distinct approaches to building APIs between a client and a server. Each makes different trade-offs around type safety, flexibility, tooling, and developer experience. This section compares them across dimensions relevant to a TypeScript full-stack developer.

---

### The Core Problem All Three Solve

When a frontend needs data from a backend, something must define:

- **What data can be requested**
- **How the request is structured**
- **What the response looks like**

REST, GraphQL, and tRPC are three different answers to that contract problem.

---

### REST

REST (Representational State Transfer) is an architectural style, not a protocol. It uses HTTP methods and URLs to represent resources and actions.

**How it works:**

- Resources are identified by URLs: `/users`, `/posts/42`
- HTTP verbs express intent: `GET`, `POST`, `PUT`, `DELETE`
- Responses are typically JSON, with no enforced schema by default

**Example**

```
GET /users/1
→ { "id": 1, "name": "Alice", "email": "alice@example.com" }
```

**Strengths:**

- Universally understood and widely supported
- No special client library required — any HTTP client works
- Caching is natural via HTTP semantics
- Language-agnostic

**Weaknesses:**

- No built-in type safety across the client-server boundary
- Over-fetching: the endpoint returns all fields even if only one is needed
- Under-fetching: related data may require multiple round trips
- Types must be manually maintained or generated from tools like OpenAPI — drift between spec and implementation is common [Inference: based on how REST schemas are typically maintained without strict enforcement]

---

### GraphQL

GraphQL is a query language and runtime for APIs, developed by Meta. The client specifies exactly what data it needs in a typed schema.

**How it works:**

- A single endpoint (usually `/graphql`) handles all requests
- The client sends a query describing the shape of the response
- The server resolves only what was requested

**Example**

```graphql
query {
  user(id: 1) {
    name
    email
  }
}
```

```json
{ "data": { "user": { "name": "Alice", "email": "alice@example.com" } } }
```

**Strengths:**

- Eliminates over-fetching and under-fetching
- Schema is the single source of truth — it is introspectable
- Tooling ecosystem is mature (Apollo, urql, codegen)
- Works across languages and platforms

**Weaknesses:**

- Significant setup overhead: schema definition, resolvers, codegen pipelines
- Type safety on the client requires a separate code generation step (e.g., GraphQL Code Generator)
- Caching is more complex than REST — HTTP caching does not apply the same way
- Overkill for applications without a public API or multiple consumers [Inference]
- Runtime errors can still occur if codegen is out of sync with the actual schema

---

### tRPC

tRPC takes a different approach: instead of defining an API schema separately, it infers the API contract directly from TypeScript function signatures. There is no schema language, no code generation, and no runtime contract — the TypeScript compiler is the contract.

**How it works:**

- Procedures (queries and mutations) are defined on the server as TypeScript functions
- The client calls those procedures as if they were local async functions
- TypeScript's type inference propagates input and output types from server to client automatically

**Example**

```ts
// Server
const appRouter = router({
  getUser: publicProcedure
    .input(z.object({ id: z.number() }))
    .query(({ input }) => {
      return { name: "Alice", email: "alice@example.com" };
    }),
});

// Client
const user = await trpc.getUser.query({ id: 1 });
// `user` is typed as { name: string; email: string } automatically
```

**Strengths:**

- End-to-end type safety with zero codegen
- Instant feedback in the editor — type errors appear before runtime
- Dramatically reduces boilerplate compared to REST + OpenAPI or GraphQL + codegen
- Input validation and type inference work together (commonly used with Zod)

**Weaknesses:**

- Requires TypeScript on both client and server — not suitable for cross-language APIs
- Not designed for public APIs consumed by third parties
- The client must import the router type from the server, creating a monorepo dependency or a shared type package requirement
- Less mature ecosystem compared to REST or GraphQL

---

### Side-by-Side Comparison

| Dimension | REST | GraphQL | tRPC |
|---|---|---|---|
| Type safety | Manual / codegen | Codegen required | Automatic via TypeScript |
| Schema definition | Implicit or OpenAPI | Explicit (SDL) | TypeScript types |
| Code generation | Optional | Usually required | Not required |
| Over/under-fetching | Common | Solved | Solved (per-procedure) |
| Language support | Any | Any | TypeScript only |
| Public API suitability | Excellent | Good | Not suited |
| Setup complexity | Low | High | Low (in TS monorepos) |
| Caching | HTTP-native | Complex | Depends on adapter |
| Learning curve | Low | Medium–High | Low (for TS developers) |

---

### When to Use Each

**Use REST when:**
- The API must be consumed by clients in multiple languages
- You are building a public API
- Your team is not using TypeScript throughout

**Use GraphQL when:**
- You have multiple clients with different data needs (mobile, web, third-party)
- Over/under-fetching is a real problem at scale
- You need a strongly typed, introspectable public schema

**Use tRPC when:**
- Both client and server are TypeScript
- You are building a full-stack application in a monorepo (e.g., Next.js, T3 Stack)
- You want the fastest path to end-to-end type safety without a codegen step
- The API is internal — not intended for external consumers

---

### Where tRPC Fits in the Ecosystem

tRPC does not compete with REST or GraphQL in all contexts. It occupies a specific and narrow sweet spot: **TypeScript-only, internal, full-stack applications** where developer velocity and type safety are the primary concerns.

For teams already using Next.js or a similar full-stack TypeScript framework, tRPC removes an entire class of runtime bugs — mismatched request/response shapes — that would otherwise require discipline, documentation, or tooling to prevent.

> **Disclaimer:** Claims about type errors being caught at compile time assume correct TypeScript configuration and usage. Actual behavior depends on project setup, TypeScript strictness settings, and correct use of tRPC APIs. Behavior is not guaranteed across all configurations.

---

**Conclusion**

REST is the universal baseline. GraphQL solves data-fetching flexibility at scale. tRPC solves the type-safety problem for TypeScript full-stack teams with the least overhead. Understanding where each approach breaks down is what makes the choice meaningful — there is no universally correct answer.

**Next Steps**

The next topic covers setting up a tRPC project: installing dependencies, configuring the server, and connecting the client.
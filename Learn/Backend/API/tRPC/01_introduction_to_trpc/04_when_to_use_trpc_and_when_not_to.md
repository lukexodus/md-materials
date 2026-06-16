## When to Use tRPC — and When Not To

### Why This Decision Matters

Choosing tRPC is not just a technical decision — it shapes your project's architecture, team requirements, and long-term maintainability. tRPC's strengths are real, but they are conditional. Understanding the boundaries of those conditions is what makes the choice defensible.

---

### What tRPC Optimizes For

Before listing use cases, it helps to be explicit about what tRPC is designed to do:

- Infer API types from TypeScript — no schema language, no codegen
- Keep the client and server in the same type system
- Reduce the surface area for client-server contract bugs
- Minimize boilerplate in TypeScript-first full-stack applications

Every "use this" and "avoid this" recommendation below follows from these design goals.

---

### When tRPC Is a Strong Fit

#### TypeScript on Both Ends

tRPC's core mechanism — type inference from server router to client — only works when both the client and server are TypeScript. If either side is not TypeScript, the type propagation does not apply, and tRPC's primary advantage is lost.

**This includes:**
- Next.js full-stack applications
- Remix with a TypeScript backend
- Any Node.js backend paired with a TypeScript frontend

#### Monorepos and Shared Codebases

tRPC requires the client to import the router's type from the server. This is straightforward when both live in the same repository or a shared package.

```ts
// packages/server/src/router.ts
export type AppRouter = typeof appRouter;

// apps/web/src/trpc.ts
import type { AppRouter } from "@myapp/server";
```

In a monorepo setup (e.g., Turborepo, Nx), this is natural. The type import adds no runtime cost — it is erased at compile time.

#### Internal APIs

tRPC is designed for APIs consumed by a known, controlled client — typically your own frontend. There is no published schema, no versioning convention, and no introspection endpoint for third parties. This is intentional. For internal APIs, this is a simplification. For public APIs, it is a significant limitation.

#### Small-to-Medium Teams Moving Fast

tRPC removes the overhead of:
- Writing OpenAPI specs
- Running codegen pipelines
- Keeping documentation in sync with implementation

For teams where a single developer or a small group owns both the frontend and backend, this reduction in ceremony is meaningful. [Inference: productivity benefit is context-dependent and not universally guaranteed]

#### The T3 Stack and Similar Opinionated Stacks

tRPC is a first-class citizen in the T3 Stack (Next.js + tRPC + Prisma + Tailwind + NextAuth). If your team is adopting T3 or a similar opinionated full-stack setup, tRPC is already integrated and the setup cost is minimal.

---

### When tRPC Is a Poor Fit

#### Public or Third-Party APIs

If your API will be consumed by:
- External developers
- Mobile clients built in Swift or Kotlin
- Partners or integrations outside your codebase

…then tRPC is not appropriate. It produces no language-agnostic schema. External consumers cannot generate clients, cannot inspect the API contract, and cannot use it without TypeScript. REST with OpenAPI or GraphQL with a published schema are better choices here.

#### Multi-Language Backends or Clients

tRPC has no official support for non-TypeScript servers. A Python, Go, or Java backend cannot participate in tRPC's type inference. Similarly, a React Native client in a non-TypeScript project cannot use tRPC's typed client meaningfully.

> **Disclaimer:** Community adapters and unofficial implementations may exist for other languages, but their stability, completeness, and long-term support are [Unverified]. Core tRPC is TypeScript-first by design.

#### Teams Without TypeScript Discipline

tRPC's safety properties depend on TypeScript being used correctly across the codebase. If the project uses:
- `any` types liberally
- `// @ts-ignore` suppressions
- Loose TypeScript configuration (`strict: false`)

…then the type safety guarantees that motivate choosing tRPC are weakened. [Inference: the degree of degradation depends on specific usage patterns and is not uniformly predictable]

In these environments, tRPC may add structural complexity without delivering its primary benefit.

#### Large Distributed Teams With Separate Frontend and Backend Ownership

When the frontend and backend are owned by separate teams — possibly on different release cycles — a formal API contract becomes operationally important. REST with OpenAPI or GraphQL's schema SDL both support:
- Independent versioning
- Schema review processes
- Generated documentation
- Contract testing

tRPC does not have a built-in versioning or deprecation story. Procedure names change, input shapes change, and the only enforcement is TypeScript — which only helps when both sides compile together.

#### Microservices Communicating With Each Other

tRPC can technically be used for service-to-service communication, but it is not designed for it. In a microservices architecture, services are often written in different languages, deployed independently, and need stable, versioned contracts. REST or gRPC are more conventional and better-supported choices for this context. [Inference]

#### You Need HTTP-Level Caching or CDN Integration

REST maps naturally to HTTP caching semantics. GraphQL has workarounds (persisted queries, GET requests). tRPC queries can use GET requests, but its caching story is less mature and more dependent on the adapter and framework being used. If CDN-level or edge caching of API responses is a hard requirement, REST is the safer choice.

---

### Edge Cases and Nuanced Situations

#### Mixed API Surface

Some applications need both: an internal API for their own frontend, and a public API for third-party consumers. tRPC can handle the internal surface while a separate REST or GraphQL layer handles the public surface. This is a reasonable architecture, though it adds maintenance overhead. [Inference]

#### Mobile Clients in React Native With TypeScript

tRPC works with React Native if the client is TypeScript. The router type can be shared via a package. This is a legitimate use case, but introduces additional complexity around native build tooling and package resolution that is not present in a standard web setup. [Inference: specific behavior depends on project configuration]

#### Migrating an Existing REST API to tRPC

tRPC is not designed as a migration target for existing REST APIs. It does not wrap REST endpoints — it replaces the communication layer. Incremental adoption is possible by running tRPC alongside an existing REST API, but the two do not interoperate at the type level. [Inference]

---

### Decision Summary

```
Is TypeScript used on both client and server?
  └─ No  → Do not use tRPC.
  └─ Yes → Continue.

Is the API intended for external or third-party consumers?
  └─ Yes → Do not use tRPC. Use REST + OpenAPI or GraphQL.
  └─ No  → Continue.

Do frontend and backend share a codebase or monorepo?
  └─ No  → tRPC is possible but adds complexity. Evaluate carefully.
  └─ Yes → tRPC is a strong fit.

Do you need HTTP-level caching or a published schema?
  └─ Yes → Reconsider. REST or GraphQL may serve better.
  └─ No  → tRPC is likely appropriate.
```

---

### Comparison With Prior Section

The previous section compared tRPC to REST and GraphQL across technical dimensions. This section focuses on the **organizational and architectural** conditions that determine whether tRPC's technical advantages actually materialize in practice. A tool that fits the problem is more valuable than a technically superior tool that does not.

---

**Conclusion**

tRPC is a high-leverage choice in the right context: TypeScript throughout, internal API, shared codebase, small-to-medium team. Outside that context, its primary advantage — automatic type inference across the client-server boundary — either does not apply or is insufficient to justify the trade-offs. The decision should be made on fit, not on novelty or trend.

**Next Steps**

The next topic covers setting up a tRPC project from scratch: installing packages, initializing the router, and connecting the client.
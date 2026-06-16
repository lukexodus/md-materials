## tRPC vs Other Type-Safe API Solutions

### Overview

Type safety across the client-server boundary is a shared goal among several modern API solutions. tRPC achieves this differently from its peers — without a schema language, code generation step, or shared contract file. Understanding these differences helps in choosing the right tool for a given project.

---

### The Core Problem Each Tool Solves

All of the following tools attempt to answer the same question: _How do we make sure the client and server agree on data shapes and types?_

They differ in **where type safety comes from** and **what tradeoffs that introduces**.

---

### tRPC

tRPC derives type safety directly from TypeScript — specifically from the return types and input validators of server-side router procedures. No schema is written separately. No code is generated. The client infers types from the server's TypeScript definitions at compile time.

**Key Points**

- Requires a monorepo or shared codebase (client and server must share TypeScript types)
- No code generation step
- No schema language to learn
- Type inference happens through TypeScript's type system
- Runtime validation is handled by a separate library (commonly Zod)
- Transport is typically HTTP or WebSockets; the wire format is JSON by default

**When it fits well:** Full-stack TypeScript monorepos where client and server are developed together.

**When it does not fit:** Across language boundaries (e.g., a Python client consuming a Node.js tRPC server), or when a public API contract needs to be shared with external consumers.

---

### GraphQL (with Type Generation — e.g., GraphQL Code Generator, Pothos, TypeGraphQL)

GraphQL uses a schema definition language (SDL) as the source of truth. Type safety for TypeScript clients is achieved through code generation tools that read the SDL and emit TypeScript types.

**Key Points**

- Schema is language-agnostic; any client in any language can consume it
- Requires a build/generation step to produce TypeScript types
- Generated types can drift from actual resolvers if generation is skipped or outdated
- Flexible querying (clients request only the fields they need)
- Higher setup overhead; more moving parts
- Well-suited for public or multi-consumer APIs

**Comparison to tRPC**

|Dimension|tRPC|GraphQL + Codegen|
|---|---|---|
|Type source|TypeScript inference|SDL + code generation|
|Cross-language|No|Yes|
|Schema file|None|Required|
|Flexible queries|No (procedure-based)|Yes|
|Setup complexity|Low|Medium–High|
|Runtime type safety|Via Zod or similar|Resolver-level only|

---

### REST + OpenAPI (with Type Generation — e.g., openapi-typescript, Orval, zod-openapi)

OpenAPI defines an API contract in JSON or YAML. Tools like `openapi-typescript` generate TypeScript types from that contract. Some tools (e.g., Orval) also generate typed client functions.

**Key Points**

- OpenAPI is the dominant standard for documenting REST APIs
- Type safety is only as accurate as the OpenAPI spec — if the spec is wrong, the generated types are wrong
- Excellent for public APIs and cross-team or cross-language consumers
- Generation step is required; types can go stale
- Some tools (e.g., `zod-openapi`, `@anatine/zod-openapi`) attempt to derive the OpenAPI spec from Zod schemas, reducing drift

**Comparison to tRPC**

|Dimension|tRPC|REST + OpenAPI Codegen|
|---|---|---|
|Type source|TypeScript inference|OpenAPI spec + codegen|
|Cross-language|No|Yes|
|Spec file|None|Required|
|Type drift risk|Low (same codebase)|Present (spec can lag)|
|Public API support|Limited|Strong|
|Setup complexity|Low|Medium|

---

### Zodios

Zodios is a TypeScript library that lets you define an API contract using Zod schemas, then generates a fully typed client and server from that contract. It sits closer to tRPC in philosophy but retains a REST-style structure.

**Key Points**

- Contract is defined in TypeScript using Zod — no separate SDL or YAML
- Both client and server are generated from the same Zod contract
- REST-compatible (uses HTTP verbs and paths explicitly)
- Usable across separate repositories if the contract is published as a package
- More boilerplate than tRPC for internal use; more portable than tRPC for external use

**Comparison to tRPC**

|Dimension|tRPC|Zodios|
|---|---|---|
|Type source|TypeScript inference|Zod contract definitions|
|REST-style routing|No (procedures)|Yes|
|Separate repo support|Limited|Yes (via published contract)|
|Setup complexity|Low|Low–Medium|

---

### ts-rest

ts-rest defines a shared contract using TypeScript objects (with Zod for validation). Both client and server implement the contract. It is explicitly REST-compatible and works across separate repositories.

**Key Points**

- Contract is a plain TypeScript object shared between client and server
- REST-compatible; HTTP methods and paths are explicit
- Can work in a monorepo or across repos (contract published as a package)
- Slightly more verbose contract definition than tRPC procedures
- Does not require code generation

**Comparison to tRPC**

|Dimension|tRPC|ts-rest|
|---|---|---|
|Type source|TypeScript inference|Shared contract object|
|REST-compatible|No|Yes|
|Cross-repo support|Limited|Yes|
|Code generation|None|None|
|Setup complexity|Low|Low|

---

### gRPC (with grpc-tools or protoc-gen-ts)

gRPC uses Protocol Buffers (`.proto` files) as the schema language. TypeScript types are generated from `.proto` files using code generation tools.

**Key Points**

- Binary wire format (Protocol Buffers) — more efficient than JSON for high-throughput systems
- Strongly typed across many languages (Go, Java, Python, TypeScript, etc.)
- Requires `.proto` file authorship and a code generation step
- Best suited for internal microservices communication, especially in polyglot environments
- Significantly higher setup and operational overhead compared to tRPC
- Browser support requires a proxy layer (e.g., gRPC-Web, Connect)

**Comparison to tRPC**

|Dimension|tRPC|gRPC|
|---|---|---|
|Type source|TypeScript inference|`.proto` + codegen|
|Cross-language|No|Yes|
|Wire format|JSON|Binary (Protobuf)|
|Browser support|Native|Requires proxy|
|Setup complexity|Low|High|
|Performance ceiling|Moderate|High|

---

### Summary Comparison Table

|Solution|Type Source|Codegen Required|Cross-Language|REST-Compatible|Best Fit|
|---|---|---|---|---|---|
|tRPC|TS inference|No|No|No|Full-stack TS monorepos|
|GraphQL + Codegen|SDL|Yes|Yes|No|Multi-consumer, flexible queries|
|REST + OpenAPI|OpenAPI spec|Yes|Yes|Yes|Public APIs, cross-team|
|Zodios|Zod contract|No|Limited|Yes|TS REST APIs, some portability|
|ts-rest|TS contract object|No|Limited|Yes|TS REST with cross-repo support|
|gRPC|`.proto` files|Yes|Yes|No|High-perf microservices, polyglot|

---

### Choosing Between Them

There is no universally correct choice. The decision depends on the project's constraints:

- **Full-stack TypeScript, monorepo, internal API** → tRPC is [Inference] likely the lowest-friction option
- **Public API or external consumers** → REST + OpenAPI or GraphQL are better fits; tRPC's type sharing model does not extend cleanly beyond a shared codebase
- **Multiple languages involved** → GraphQL, gRPC, or OpenAPI are more appropriate; tRPC does not support cross-language type sharing
- **REST semantics required (caching, HTTP verbs)** → ts-rest or Zodios fit better; tRPC abstracts away HTTP methods by design
- **High-throughput internal services** → gRPC's binary format offers advantages tRPC does not

> [Inference] The above recommendations are based on documented design characteristics of each tool. Actual suitability depends on team familiarity, existing infrastructure, and project-specific requirements. Behavior and feature sets of these tools may change across versions.

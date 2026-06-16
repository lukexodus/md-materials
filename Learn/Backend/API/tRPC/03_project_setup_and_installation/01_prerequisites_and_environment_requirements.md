## Prerequisites and Environment Requirements

### Who This Is For

tRPC is a TypeScript-first library. Before working with it, you need a working foundation in TypeScript and Node.js. This section covers what you need installed, what you need to understand conceptually, and what assumptions tRPC makes about your environment.

---

### Required Knowledge

**TypeScript**

tRPC's core value proposition is type inference across a client-server boundary. If you are not comfortable with TypeScript, the framework's benefits are largely inaccessible, and its error messages will be difficult to interpret.

Specifically, you should be comfortable with:

- Generic types and type parameters (`<T>`)
- Type inference (`typeof`, `ReturnType<>`, `Parameters<>`)
- Union and intersection types
- Module imports and `import type`
- Interface vs. type alias distinctions

**Node.js and the JavaScript module system**

tRPC runs on Node.js on the server side. You should understand:

- CommonJS vs. ESM module formats and how your project is configured
- `async`/`await` and `Promise`-based code
- Basic HTTP concepts (request, response, headers, status codes)

**A working knowledge of React is assumed for most guides but is not required by tRPC itself.** tRPC is framework-agnostic on the server. The `@trpc/react-query` adapter is one integration option, not a requirement.

---

### Runtime Requirements

**Node.js**

tRPC requires Node.js. As of the tRPC v11 line, the minimum supported version is **Node.js 18**. [Unverified — confirm against the official tRPC changelog for your target version, as this may change across releases.]

Node.js 18 introduced the native `fetch` API, which tRPC's client relies on in certain configurations. If you are on an earlier Node.js version, you may need to polyfill `fetch`.

**Package manager**

Any of the following work:

- `npm`
- `yarn` (classic or berry)
- `pnpm` (commonly used in tRPC monorepo examples)
- `bun` [Inference] — Bun has broad Node.js compatibility but behavior in edge cases is not guaranteed to match Node.js exactly.

---

### Core Packages

tRPC is split across multiple packages. Which ones you install depends on your stack.

| Package | Purpose |
|---|---|
| `@trpc/server` | Router, procedure builders, adapter utilities |
| `@trpc/client` | Vanilla client for querying procedures |
| `@trpc/react-query` | React integration via TanStack Query |
| `@trpc/next` | Next.js-specific adapter |

You always need `@trpc/server` on the server. On the client, you need at minimum `@trpc/client`, plus any framework adapter you are using.

**Example — minimal installation**

```bash
npm install @trpc/server @trpc/client
```

**Example — with React and Next.js**

```bash
npm install @trpc/server @trpc/client @trpc/react-query @trpc/next @tanstack/react-query
```

**Key Point:** `@tanstack/react-query` is a peer dependency of `@trpc/react-query`. You must install it separately and ensure the version is compatible with the version of `@trpc/react-query` you are using.

---

### TypeScript Configuration

tRPC requires **strict mode** enabled in your `tsconfig.json`. Without it, many of the type inferences that tRPC depends on either behave incorrectly or fail silently.

**Minimum recommended `tsconfig.json` settings**

```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2020",
    "moduleResolution": "bundler",
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
```

`strict: true` enables a collection of checks including `strictNullChecks`, `strictFunctionTypes`, and `noImplicitAny`. All of these matter for correct tRPC type inference.

[Inference] Using tRPC without `strict: true` may appear to work in simple cases but is likely to produce incorrect or missing types on complex procedures. This is not guaranteed behavior — your mileage may vary.

**TypeScript version**

tRPC v11 requires TypeScript **4.7 or later**. TypeScript 5.x is recommended. [Unverified — verify against the specific tRPC version you are targeting.]

---

### Validator Library

tRPC does not ship its own validation logic. You need a compatible validator library for input validation. The most common choice is **Zod**.

```bash
npm install zod
```

Other supported options include:

- **Valibot** — smaller bundle size than Zod; compatible via `@valibot/to-json-schema` or direct tRPC adapter
- **Yup**
- **ArkType**
- **Superstruct**
- Custom validators that conform to tRPC's inference interface

[Inference] Zod is the most thoroughly documented and most commonly used option in tRPC's official docs and community examples. Other validators are supported but may have less community coverage for edge cases.

You can also define procedures without an input validator, in which case the input type is `unknown` and no runtime validation occurs.

---

### Server Framework

tRPC does not provide an HTTP server itself. It provides **adapters** that integrate with your existing server framework.

Supported server environments include:

| Environment | Adapter |
|---|---|
| Next.js (Pages Router) | `@trpc/next` |
| Next.js (App Router) | Fetch adapter (manual wiring) |
| Express | `@trpc/server/adapters/express` |
| Fastify | `@trpc/server/adapters/fastify` |
| Fetch API (edge runtimes) | `@trpc/server/adapters/fetch` |
| AWS Lambda | `@trpc/server/adapters/aws-lambda` |
| Standalone (Node HTTP) | `@trpc/server/adapters/standalone` |

You must have the corresponding server framework installed separately.

**Example — Express**

```bash
npm install express
npm install --save-dev @types/express
```

---

### Monorepo Considerations

tRPC is commonly used in a monorepo where the server and client are separate packages that share a common types package. This is not required, but it is a natural fit because the `AppRouter` type must be accessible on the client.

Common monorepo tools used with tRPC:

- **Turborepo**
- **Nx**
- **pnpm workspaces**

In a monorepo setup, you typically create a shared package (e.g., `packages/api`) that exports the `AppRouter` type, and both the server app and client app depend on it.

[Inference] In a non-monorepo setup (e.g., a single Next.js project), the `AppRouter` type is importable within the same project, so no special configuration is needed.

---

### Edge Runtime Considerations

tRPC supports edge runtimes (Vercel Edge, Cloudflare Workers) via the Fetch adapter. However, edge runtimes impose constraints:

- No access to Node.js-specific APIs (filesystem, `child_process`, etc.)
- Restricted or absent support for some npm packages that depend on Node.js internals
- Different `fetch` and `Request`/`Response` implementations than Node.js

[Inference] If your procedures or dependencies use Node.js-specific APIs, they will not work in an edge runtime without modification. This is a general edge runtime constraint, not specific to tRPC.

---

### Development Tooling

The following tools are commonly part of a tRPC development environment, though none are strictly required by tRPC itself:

| Tool | Purpose |
|---|---|
| `tsx` or `ts-node` | Run TypeScript files directly in Node.js |
| `tsc --watch` | Incremental type checking |
| Turborepo or similar | Monorepo task orchestration |
| ESLint + `typescript-eslint` | Lint TypeScript code |
| Prettier | Code formatting |

---

### Checklist Before Starting

- [ ] Node.js 18+ installed
- [ ] TypeScript 4.7+ installed (5.x recommended)
- [ ] `strict: true` in `tsconfig.json`
- [ ] `@trpc/server` installed
- [ ] `@trpc/client` installed (and framework adapter if applicable)
- [ ] A validator library installed (Zod recommended)
- [ ] A server framework or Next.js project configured
- [ ] `AppRouter` type accessible to the client (same project or shared package)
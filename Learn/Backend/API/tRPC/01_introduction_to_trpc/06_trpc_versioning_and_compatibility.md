## tRPC Versioning and Compatibility

### Why This Topic Matters

tRPC's type safety model creates a tighter coupling between packages than is typical in REST or GraphQL tooling. When versions are mismatched — even by a minor version in some cases — type inference can silently degrade or break entirely. Understanding tRPC's versioning model is not optional housekeeping; it directly affects the reliability of the guarantees tRPC is chosen for.

---

### Major Versions in the tRPC Ecosystem

As of the knowledge cutoff (August 2025), tRPC has gone through three significant major versions:

| Version | Status | Notes |
|---|---|---|
| v9 | Deprecated | Legacy API, no longer maintained |
| v10 | Stable, widely deployed | Major rewrite; introduced current `initTRPC` API |
| v11 | Current | Incremental improvements over v10; SSE support added |

> **Disclaimer:** Version status may have changed after August 2025. Verify current status at [trpc.io](https://trpc.io) or the [tRPC GitHub repository](https://github.com/trpc/trpc) before making version decisions.

---

### The v9 → v10 Breaking Change

The jump from v9 to v10 was a significant rewrite, not an incremental update. It is worth understanding because:

- Many tutorials and Stack Overflow answers still reference v9 patterns
- The two APIs are not compatible — v9 code does not run against a v10 server without migration
- The `initTRPC` builder pattern introduced in v10 is the foundation of all subsequent versions

**v9 pattern (legacy):**

```ts
import * as trpc from "@trpc/server";

const appRouter = trpc.router()
  .query("getUser", {
    input: z.object({ id: z.number() }),
    resolve({ input }) {
      return { name: "Alice" };
    },
  });
```

**v10+ pattern (current):**

```ts
import { initTRPC } from "@trpc/server";

const t = initTRPC.create();

const appRouter = t.router({
  getUser: t.procedure
    .input(z.object({ id: z.number() }))
    .query(({ input }) => {
      return { name: "Alice" };
    }),
});
```

**Key structural differences:**

- Procedure names moved from string keys in `.query("name", ...)` to object property keys
- `resolve()` replaced by `.query()` / `.mutation()` callbacks directly
- `initTRPC` replaced the global `trpc` import as the entry point
- Context and middleware wiring changed substantially

When reading third-party tRPC content, the presence of `.query("procedureName", ...)` with a string argument is a reliable indicator of v9 code. [Inference]

---

### The v10 → v11 Changes

v11 was designed to be largely compatible with v10 for most common use cases, but introduced new features that required some API surface changes.

**Notable additions in v11:**

- `httpSubscriptionLink` — Server-Sent Events support without a WebSocket server
- Improved Next.js App Router compatibility
- Refined `observable` and subscription APIs
- Changes to how some internal types are structured

**Potential compatibility impact:**

- Projects using subscriptions may need to update link configuration
- Some internal types that were previously accessible changed shape — code relying on internal tRPC types (not recommended practice) may break [Inference]
- The public procedure and router API remained largely stable between v10 and v11

> **Disclaimer:** The full scope of v10 → v11 breaking changes should be verified against the official [tRPC v11 migration guide](https://trpc.io/docs/migrate-from-v10-to-v11) before upgrading. Behavior may vary based on which features your project uses.

---

### Package Version Alignment

tRPC publishes multiple packages under the `@trpc/*` namespace. These packages are versioned together and must be kept on the same major and minor version.

**Packages that must align:**

- `@trpc/server`
- `@trpc/client`
- `@trpc/react-query`
- `@trpc/next`

**Example of a correctly aligned `package.json`:**

```json
{
  "dependencies": {
    "@trpc/server": "^11.0.0",
    "@trpc/client": "^11.0.0",
    "@trpc/react-query": "^11.0.0",
    "@trpc/next": "^11.0.0"
  }
}
```

**What happens with mismatched versions:**

Mismatching `@trpc/server` and `@trpc/client` across major versions can cause:

- TypeScript type errors that are difficult to diagnose
- Runtime failures where the client and server disagree on the wire format
- Silent loss of type inference — the client types fall back to `unknown` or `any` in some cases [Inference: specific failure mode depends on which versions are mixed]

> **Disclaimer:** Exact failure behavior from version mismatches is not fully predictable and depends on which packages are mismatched and by how much. Always align all `@trpc/*` packages to the same version.

---

### Peer Dependency Requirements

tRPC packages declare peer dependencies that constrain what versions of external libraries are compatible.

**`@trpc/react-query` peer dependencies (v11, approximate):**

| Peer dependency | Required version |
|---|---|
| `@tanstack/react-query` | v5.x |
| `react` | v18.x or later |

**`@trpc/server` peer dependencies:**

| Peer dependency | Required version |
|---|---|
| `typescript` | v5.x recommended; v4.7+ minimum [Unverified: exact minimum may vary by tRPC patch version] |
| `zod` | No direct peer dep — used optionally |

> **Disclaimer:** Peer dependency requirements change between tRPC releases. Always verify against the `package.json` of the specific version you are installing. The values above are [Inference] based on known v11 requirements and may not reflect current patch releases.

**TanStack Query version note:**

`@trpc/react-query` v11 requires TanStack Query v5. TanStack Query v5 introduced breaking changes from v4 — particularly around `useQuery` option names and the removal of `onSuccess` / `onError` callbacks. If your project uses TanStack Query v4, it cannot use `@trpc/react-query` v11 without upgrading TanStack Query as well.

---

### TypeScript Version Compatibility

tRPC relies heavily on TypeScript's type inference, including features introduced in TypeScript 4.1 (template literal types) and later. Using an older TypeScript version may cause:

- Failure to infer procedure input and output types correctly
- Type errors in tRPC's own internal types
- Degraded or missing autocomplete

**Recommended practice:** Use the latest stable TypeScript version when working with tRPC. Avoid pinning to very old TypeScript versions without first verifying compatibility. [Inference: specific minimum TypeScript version varies by tRPC version]

---

### Compatibility With Community Packages

Community packages that integrate with tRPC — such as `trpc-openapi` or `trpc-panel` — maintain their own compatibility matrices independently of the tRPC core team.

**Common issues:**

- A community package may support tRPC v10 but not yet v11
- A community package may lag behind tRPC releases by weeks or months after a major version
- Breaking changes in tRPC's internal types (which community packages sometimes depend on) can break community packages without a corresponding tRPC major version bump [Inference]

**Before adopting a community package:**

- Check its repository for explicit tRPC version support statements
- Review open issues for compatibility reports
- Check when it was last updated relative to the tRPC version you are targeting

---

### Monorepo Version Management

In a monorepo, tRPC packages must resolve to the same version across all workspaces. Package managers handle this differently:

**npm / yarn workspaces:**
Hoisting typically ensures a single version is installed, but conflicting version ranges across workspaces can result in duplicate installations. This can cause the type mismatch problems described above.

**pnpm:**
Uses stricter isolation by default. Explicit version alignment across workspace `package.json` files is more important. A shared `catalog` or root-level dependency pinning helps. [Inference: specific behavior depends on pnpm configuration]

**Recommended approach regardless of package manager:**

Define tRPC versions in a single place — either the root `package.json` or a shared constants file — and reference them consistently across workspaces. Avoid allowing workspaces to independently resolve `@trpc/*` to different versions.

---

### Checking Installed Versions

To verify which versions of tRPC packages are installed and detect duplicates:

```bash
# npm
npm list @trpc/server @trpc/client @trpc/react-query

# pnpm
pnpm list @trpc/server @trpc/client @trpc/react-query

# yarn
yarn list --pattern "@trpc/*"
```

If any of these shows more than one version for the same package, investigate the root cause before proceeding.

---

### Migration Strategy Between Major Versions

When upgrading tRPC across a major version boundary:

1. **Read the official migration guide first.** tRPC publishes guides for each major version transition. These are the authoritative source — not this document.
2. **Upgrade all `@trpc/*` packages simultaneously.** Do not upgrade server without upgrading client and vice versa.
3. **Upgrade peer dependencies at the same time.** For example, upgrading to `@trpc/react-query` v11 requires upgrading TanStack Query to v5.
4. **Run TypeScript compilation after upgrading.** Type errors after a version bump are often the first signal of a breaking change.
5. **Check community packages separately.** They may require their own updates or may not yet support the new version.

---

### Summary of Version Rules

| Rule | Reason |
|---|---|
| All `@trpc/*` packages must share the same version | Type inference depends on internal type contracts across packages |
| TypeScript should be kept current | tRPC uses advanced inference features unavailable in older TS versions |
| Peer dependencies must be satisfied | Mismatched peers can cause runtime and type failures |
| Community packages require independent verification | They are not versioned with tRPC core |
| Read migration guides before major upgrades | Breaking changes are documented there; this content may lag |

---

**Conclusion**

tRPC's tight coupling between packages is the price of its zero-codegen type safety model. That coupling makes version alignment non-negotiable. Mismatched versions do not always produce obvious errors — they can silently degrade type inference, which undermines the primary reason to use tRPC. Treat version management as a first-class concern, not an afterthought.

**Next Steps**

The next topic covers setting up a tRPC project from scratch: installing packages, initializing the server, and connecting the client.
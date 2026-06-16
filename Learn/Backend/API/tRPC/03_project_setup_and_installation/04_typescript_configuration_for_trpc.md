## TypeScript Configuration for tRPC

### Why Configuration Matters More Than Usual

tRPC's type safety is not a runtime feature — it is a compile-time feature built entirely on TypeScript's type inference engine. If your TypeScript configuration is loose, incomplete, or misaligned with tRPC's expectations, the result is not a runtime error you can catch and fix. The result is silently incorrect types: procedures that appear typed but are not, inputs that appear validated but accept anything, or client calls that appear safe but carry no guarantees.

Getting the TypeScript configuration right is a prerequisite, not a refinement.

---

### The Non-Negotiable: `strict` Mode

tRPC requires `strict: true` in your `tsconfig.json`. This is explicitly stated in tRPC's documentation and is not optional.

```json
{
  "compilerOptions": {
    "strict": true
  }
}
```

`strict: true` is a shorthand that enables the following individual flags simultaneously:

| Flag | What it enforces |
|---|---|
| `strictNullChecks` | `null` and `undefined` are not assignable to other types without explicit handling |
| `strictFunctionTypes` | Function parameters are checked contravariantly |
| `strictBindCallApply` | `bind`, `call`, and `apply` are type-checked correctly |
| `strictPropertyInitialization` | Class properties must be initialized in the constructor |
| `noImplicitAny` | Variables without a type annotation cannot silently become `any` |
| `noImplicitThis` | `this` inside functions must have an explicit type |
| `alwaysStrict` | Emits `"use strict"` and parses files in strict mode |

Of these, `strictNullChecks` and `noImplicitAny` are the most consequential for tRPC. Without `strictNullChecks`, optional fields in procedure outputs collapse in ways that make client-side types unreliable. Without `noImplicitAny`, inference gaps in procedure definitions silently widen to `any` rather than producing an error.

[Inference] Enabling `strict: true` on an existing codebase that was written without it typically surfaces a large number of pre-existing type errors. This is expected — those errors were already present; TypeScript was simply not reporting them. Address them before integrating tRPC, or the signal-to-noise ratio of type errors will be poor.

---

### Recommended `tsconfig.json`

The following is a solid baseline for a tRPC project. Explanations follow.

```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2020",
    "lib": ["ES2020"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "skipLibCheck": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "resolveJsonModule": true,
    "forceConsistentCasingInFileNames": true,
    "noUncheckedIndexedAccess": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

---

### Key Options Explained

**`target`**

Determines which JavaScript syntax TypeScript compiles down to. `ES2020` is a safe baseline for Node.js 18+. It supports `async`/`await`, optional chaining, nullish coalescing, and `BigInt` natively.

[Inference] If you are targeting an edge runtime or a browser build pipeline, your bundler may take over transpilation and this setting becomes less critical, but it should still reflect the lowest common denominator of your deployment environment.

**`module` and `moduleResolution`**

These two settings work together and must be compatible with each other and your toolchain.

| Scenario | `module` | `moduleResolution` |
|---|---|---|
| Next.js (App or Pages Router) | `ESNext` | `bundler` |
| Vite-based frontend | `ESNext` | `bundler` |
| Node.js with ESM | `NodeNext` | `NodeNext` |
| Node.js with CJS | `CommonJS` | `Node` |

`moduleResolution: "bundler"` is a TypeScript 5.0+ option that matches how bundlers like Vite and webpack resolve modules. It supports `exports` fields in `package.json` without requiring file extensions on imports. This is the correct setting for most modern tRPC setups using Next.js or Vite.

`moduleResolution: "NodeNext"` is stricter and requires explicit file extensions on relative imports (e.g., `./router.js` not `./router`). It is the correct setting if you are running TypeScript output directly in Node.js with `"type": "module"`.

[Inference] Mismatches between `module` and `moduleResolution` are a common source of confusing errors when setting up a tRPC monorepo. If TypeScript cannot resolve an import that clearly exists, the module resolution strategy is often the cause.

**`esModuleInterop`**

Allows `import x from 'module'` syntax for CommonJS modules that do not have a default export. Required for clean interop with many npm packages in the tRPC ecosystem.

**`skipLibCheck`**

Skips type checking of `.d.ts` files in `node_modules`. Without this, TypeScript may report errors from third-party type definitions that are outside your control.

**Key Point:** `skipLibCheck` does not skip type checking of your own code. It only skips checking type declaration files in dependencies. It is safe and widely recommended.

**`declaration` and `declarationMap`**

Generates `.d.ts` files and source maps for them. Required if your package is consumed by other packages in a monorepo or published to npm. For a standalone Next.js project, these can be omitted.

**`noUncheckedIndexedAccess`**

When enabled, accessing an array by index (e.g., `arr[0]`) returns `T | undefined` rather than `T`. This catches a class of runtime errors where an array is shorter than assumed.

[Inference] This flag is not enabled by `strict: true`. It is an additional strictness flag worth enabling in tRPC projects because procedure outputs often include arrays that are mapped or accessed by index on the client. Whether to enable it depends on your tolerance for the additional type narrowing it requires throughout the codebase.

---

### `paths` for Monorepos

In a monorepo, TypeScript needs to know how to resolve package names defined in your workspace. The `paths` compiler option maps package names to file locations.

```json
{
  "compilerOptions": {
    "strict": true,
    "moduleResolution": "bundler",
    "paths": {
      "@my-org/api": ["../../packages/api/src/root.ts"],
      "@my-org/api/*": ["../../packages/api/src/*"]
    }
  }
}
```

This allows the client app to write:

```ts
import type { AppRouter } from '@my-org/api';
```

And TypeScript resolves it directly to the source TypeScript file, bypassing the need for a compiled output during development.

**Key Point:** `paths` is a TypeScript-only mapping. It has no effect on how your bundler (Vite, webpack, Next.js) resolves modules at runtime. You must configure the bundler separately to match — for example, using Vite's `resolve.alias` or Next.js's `webpack` config.

[Inference] Keeping `paths` in `tsconfig.json` and bundler aliases in sync is a maintenance burden. Some monorepo setups avoid this by using `moduleResolution: "NodeNext"` with `package.json` `exports` fields, which both TypeScript and Node.js-compatible bundlers can follow without separate alias configuration.

---

### Project References in a Monorepo

TypeScript project references allow the compiler to understand the dependency graph between packages and type-check them incrementally.

**packages/api/tsconfig.json**

```json
{
  "compilerOptions": {
    "strict": true,
    "composite": true,
    "declaration": true,
    "declarationMap": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "moduleResolution": "bundler"
  },
  "include": ["src"]
}
```

`composite: true` is required for a package to be used as a project reference target. It enforces that `declaration: true` is set and that the package has an explicit `include` or `files` list.

**apps/web/tsconfig.json**

```json
{
  "compilerOptions": {
    "strict": true,
    "moduleResolution": "bundler"
  },
  "references": [
    { "path": "../../packages/api" }
  ],
  "include": ["src"]
}
```

With project references in place, running `tsc --build` from the root compiles packages in dependency order. Running `tsc --noEmit` in a package that references others will type-check across the boundary.

[Inference] Project references add setup complexity. For small monorepos, using `paths` and pointing directly at source TypeScript files is simpler and sufficient. Project references become more valuable when packages are large enough that incremental compilation speed matters.

---

### `tsconfig` Inheritance and the Base Config Pattern

In a monorepo, it is common to define a shared base `tsconfig` at the root and extend it in each package. This reduces duplication and ensures consistent settings.

**Root `tsconfig.base.json`**

```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2020",
    "lib": ["ES2020"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  }
}
```

**packages/api/tsconfig.json**

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src"]
}
```

**apps/web/tsconfig.json**

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "jsx": "react-jsx"
  },
  "references": [
    { "path": "../../packages/api" }
  ],
  "include": ["src"]
}
```

**Key Point:** Package-level `tsconfig.json` files extend the base but can override any option. Package-specific settings (`composite`, `jsx`, `outDir`) belong in the package config, not the base.

---

### Next.js-Specific Considerations

Next.js generates its own `tsconfig.json` when you run `create-next-app`. It includes sensible defaults but may need adjustment for tRPC.

Confirm the following in a Next.js project's `tsconfig.json`:

```json
{
  "compilerOptions": {
    "strict": true,
    "moduleResolution": "bundler",
    "plugins": [
      { "name": "next" }
    ]
  }
}
```

The `plugins: [{ "name": "next" }]` entry enables the Next.js TypeScript plugin, which provides additional diagnostics specific to the App Router (server components, client components, route handlers). This is separate from tRPC but relevant if you are using App Router.

[Inference] Next.js manages its own TypeScript compilation via SWC and does not use `tsc` directly in most cases. The `tsconfig.json` is used for editor tooling and type checking (`tsc --noEmit`), but not necessarily for the actual build. This means some `tsconfig` options (like `outDir`) have no effect in a Next.js project.

---

### Common Configuration Mistakes

**Using `"moduleResolution": "node"` with modern packages**

The legacy `"node"` resolution strategy does not support `exports` fields in `package.json`. Many modern packages, including some in the tRPC ecosystem, define their public API exclusively via `exports`. Using `"node"` resolution can cause TypeScript to fail to find types for these packages even though they are installed.

**Omitting `strict: true` and enabling individual flags**

Some developers enable `strictNullChecks` but not `noImplicitAny`, expecting this to be sufficient. tRPC's internal types assume the full `strict` set. Partial enablement can lead to inference gaps that are difficult to trace.

**Using `any` to silence tRPC type errors**

When a tRPC type error is unclear, the temptation is to cast to `any`. This breaks the type chain across the client-server boundary at the point of the cast. [Inference] Most tRPC type errors that seem to require `any` are instead symptoms of a configuration problem or a missing type annotation elsewhere in the procedure definition.

**Mismatched `target` and `lib`**

If `target` is `ES2020` but `lib` does not include `ES2020`, TypeScript will not recognize APIs introduced in ES2020 (such as `Promise.allSettled`). Keep `lib` consistent with or broader than `target`.

---

### Checklist

- [ ] `strict: true` is set — not partial flags
- [ ] `moduleResolution` is `"bundler"` or `"NodeNext"` — not `"node"`
- [ ] `module` is compatible with `moduleResolution`
- [ ] `skipLibCheck: true` is set to avoid noise from third-party types
- [ ] `paths` entries (if any) are mirrored in bundler alias configuration
- [ ] All packages in a monorepo extend a shared base `tsconfig`
- [ ] Packages intended as project references have `composite: true` and `declaration: true`
- [ ] No `any` casts are suppressing legitimate tRPC inference errors
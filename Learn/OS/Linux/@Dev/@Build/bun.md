# bun

---

## What It Is

**Bun** is a fast JavaScript runtime, package manager, bundler, and test runner — all in one tool. It is built on JavaScriptCore (Safari's JS engine) instead of V8, written in Zig, and designed as a drop-in replacement for Node.js in most cases.

Key goals: speed, Node.js compatibility, and reducing toolchain sprawl (no separate npm, webpack, jest needed).

---

## Installation

```bash
# macOS / Linux (official installer)
curl -fsSL https://bun.sh/install | bash

# macOS
brew install oven-sh/bun/bun

# npm (ironic but works)
npm install -g bun

# Upgrade
bun upgrade
```

Windows support exists but is newer and [Unverified] may have compatibility gaps compared to macOS/Linux.

---

## Runtime

Bun runs JavaScript and TypeScript directly — no transpilation step needed.

```bash
bun run script.ts          # run a TypeScript file
bun run script.js          # run a JS file
bun script.ts              # shorthand (no 'run' needed for files)
bun run start              # run 'start' script from package.json
bun run dev                # run 'dev' script from package.json
```

### Node.js Compatibility

Bun implements Node.js built-in modules (`fs`, `path`, `http`, `crypto`, etc.) and supports CommonJS and ESM. Most Node.js code runs without changes. [Inference] Compatibility is not total — edge cases exist, especially around native addons and less common Node APIs.

```bash
# Check compatibility status
https://bun.sh/docs/runtime/nodejs-apis
```

### Environment Variables

```bash
bun run --env-file=.env script.ts    # load specific env file
```

Bun automatically loads `.env`, `.env.local`, `.env.production`, etc. based on `NODE_ENV` — similar to how Next.js and Vite handle it.

### Watch Mode

```bash
bun --watch script.ts          # restart on file change
bun --hot script.ts            # hot reload (in-place, no restart)
```

`--hot` preserves module state across reloads where possible. `--watch` does a full restart.

---

## Package Manager

Bun's package manager is a drop-in replacement for npm, yarn, and pnpm.

### Install

```bash
bun install                    # install all dependencies
bun install --frozen-lockfile  # fail if bun.lockb would change (CI use)
bun install --production       # skip devDependencies
bun i                          # shorthand
```

### Add / Remove

```bash
bun add express                # add dependency
bun add -d typescript          # add devDependency
bun add -o lodash              # add optional dependency
bun add express@4.18           # specific version
bun remove express             # remove package
bun rm express                 # shorthand
```

### Update

```bash
bun update                     # update all packages
bun update express             # update specific package
bun outdated                   # list outdated packages
```

### Global packages

```bash
bun add -g typescript          # install globally
bun remove -g typescript
bunx tsc --init                # run global package without installing
```

### Lockfile

Bun uses `bun.lockb` — a binary lockfile. It is faster to read/write than JSON lockfiles but not human-readable.

```bash
# To view it as text:
bun bun.lockb                  # prints as yarn.lock-style text
```

Commit `bun.lockb` to version control like any other lockfile.

### Workspaces

Bun supports npm-style workspaces defined in `package.json`:

```json
{
  "workspaces": ["packages/*", "apps/*"]
}
```

```bash
bun install                    # installs all workspace deps
bun add lodash --filter myapp  # add to specific workspace
```

---

## bunx (Package Runner)

Equivalent to `npx`:

```bash
bunx cowsay hello              # run without installing
bunx --bun tsc                 # force run with bun runtime (not node)
```

---

## Test Runner

Bun has a built-in Jest-compatible test runner.

```bash
bun test                       # run all tests
bun test file.test.ts          # run specific file
bun test --watch               # watch mode
bun test --coverage            # code coverage report
bun test --bail                # stop after first failure
bun test --timeout 5000        # per-test timeout in ms
bun test -t "pattern"          # run tests matching name pattern
```

### Test syntax (Jest-compatible)

```typescript
import { describe, it, expect, beforeEach, mock } from "bun:test";

describe("math", () => {
  it("adds numbers", () => {
    expect(1 + 1).toBe(2);
  });

  it("is async", async () => {
    const result = await Promise.resolve(42);
    expect(result).toBe(42);
  });
});
```

Supports: `expect`, `describe`, `it`/`test`, `beforeAll`, `afterAll`, `beforeEach`, `afterEach`, `mock`, `spyOn`, `jest.fn()` (aliased).

---

## Bundler

Bun has a built-in bundler for building browser or edge-targeted output.

```bash
bun build ./src/index.ts --outdir ./dist
bun build ./src/index.ts --outfile ./dist/bundle.js
```

### Flags

```bash
--target browser          # target: browser (default), bun, node
--format esm              # output format: esm, cjs, iife
--minify                  # enable all minification
--minify-syntax           # minify syntax only
--minify-whitespace       # minify whitespace only
--minify-identifiers      # shorten variable names
--sourcemap external      # generate sourcemap: none, inline, external
--splitting               # enable code splitting
--public-path /assets/    # prefix for asset URLs
--define FOO='"bar"'      # replace global identifiers
--loader .svg:text        # custom loader for file type
--external react          # mark as external (don't bundle)
--watch                   # rebuild on change
```

### Plugins (programmatic API)

```typescript
import { plugin } from "bun";

plugin({
  name: "my-plugin",
  setup(build) {
    build.onLoad({ filter: /\.txt$/ }, async (args) => {
      const text = await Bun.file(args.path).text();
      return { contents: `export default ${JSON.stringify(text)}`, loader: "js" };
    });
  },
});
```

---

## Bun APIs

Bun exposes its own fast native APIs under the `Bun` global.

### File I/O

```typescript
// Read
const file = Bun.file("data.txt");
const text = await file.text();
const json = await file.json();
const buffer = await file.arrayBuffer();

// Write
await Bun.write("output.txt", "hello world");
await Bun.write("data.json", JSON.stringify({ key: "val" }));
await Bun.write("copy.txt", Bun.file("original.txt"));
```

### HTTP Server

```typescript
Bun.serve({
  port: 3000,
  fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === "/") return new Response("Hello!");
    return new Response("Not found", { status: 404 });
  },
});
```

### Shell

```typescript
import { $ } from "bun";

const result = await $`ls -la`.text();
const files = await $`find . -name "*.ts"`.lines();

// Pipe
await $`cat package.json | jq .name`.text();

// Throw on non-zero exit
await $`exit 1`;  // throws ShellError
```

### Hashing & Crypto

```typescript
const hash = Bun.hash("hello");                        // fast non-crypto hash
const md5 = new Bun.CryptoHasher("md5").update("hello").digest("hex");
const sha256 = new Bun.CryptoHasher("sha256").update("hello").digest("hex");
```

### Password Hashing

```typescript
const hash = await Bun.password.hash("mypassword");    // bcrypt by default
const valid = await Bun.password.verify("mypassword", hash);
```

---

## TypeScript & JSX

Bun handles TypeScript and JSX natively with no config needed:

- `.ts`, `.tsx`, `.jsx` files just work
- No `ts-node`, `tsx`, or `babel` required
- `tsconfig.json` is respected for path aliases and compiler options

---

## Configuration (bunfig.toml)

Project-level config file:

```toml
[install]
# Default registry
registry = "https://registry.npmjs.org"

# Auto-install on bun run if node_modules missing
auto = "local"

[test]
timeout = 10000
coverage = false
coverageThreshold = 0.8

[run]
bun = true   # always use bun runtime for bun run scripts
```

---

## Tips & Gotchas

- **`bun.lockb` is binary** — not diffable in PRs without tooling; use `git diff` with the bun lockb text converter
- **Node.js native addons (`.node` files) have limited support** — [Unverified] not all native modules work
- **`--hot` vs `--watch`** — `--hot` is for servers that should stay up; `--watch` is for scripts that should restart cleanly
- **JavaScriptCore differences** — rare JS behavior differences from V8 are possible; most code is unaffected in practice [Inference]
- **Bun shell (`$`)** is cross-platform and does not use system shell — not all shell syntax works identically to bash
- **bun build is not a webpack replacement yet** — lacks some advanced features; for complex frontend builds, Vite/webpack may still be needed [Inference based on current feature set]
- **`bunx` defaults to bun runtime** — unlike npx which uses node; use `--bun` explicitly or it may use node for some packages

---

## Quick Reference

```
bun install                    Install dependencies
bun add <pkg>                  Add package
bun remove <pkg>               Remove package
bun run <script>               Run package.json script
bun <file.ts>                  Run file directly
bun --watch <file>             Watch + restart
bun --hot <file>               Hot reload
bun test                       Run tests
bun test --coverage            With coverage
bun build ./src --outdir dist  Bundle
bunx <pkg>                     Run without installing
bun upgrade                    Upgrade bun itself
```
# Comprehensive Guide to Bun

## What Is Bun?

Bun is a fast, all-in-one JavaScript runtime, bundler, transpiler, package manager, and test runner built from scratch using Zig and JavaScriptCore (the engine powering Safari). It is designed as a drop-in alternative to Node.js with a focus on performance, developer experience, and reduced tooling complexity.

Bun was created by Jarred Sumner and first released publicly in 2022. Version 1.0 was released in September 2023, marking it as production-ready.

Key design goals:

- **Speed** — start fast, run fast, install packages fast
- **Node.js compatibility** — run existing Node.js projects with little or no changes
- **All-in-one** — replace Node.js + npm/yarn/pnpm + esbuild/webpack + Jest with a single binary
- **Web-standard APIs** — implement browser APIs like `fetch`, `Request`, `Response`, `ReadableStream`, and `WebSocket` natively

---

## Installation

### macOS and Linux

```bash
curl -fsSL https://bun.sh/install | bash
```

Or via npm (for bootstrapping):

```bash
npm install -g bun
```

Or via Homebrew:

```bash
brew install oven-sh/bun/bun
```

### Windows

Windows support is available as of Bun 1.1 (April 2024), though some APIs may behave differently from Unix systems.

```powershell
powershell -c "irm bun.sh/install.ps1 | iex"
```

Or via Scoop:

```bash
scoop install bun
```

### Upgrading

```bash
bun upgrade
```

### Verifying Installation

```bash
bun --version
```

---

## The Bun Runtime

### Running JavaScript and TypeScript

Bun runs `.js`, `.ts`, `.jsx`, `.tsx`, `.mjs`, `.cjs` files natively — no separate compilation step needed for TypeScript.

```bash
bun run index.ts
bun run server.js
```

The shorthand `bun` also works when a file path is passed:

```bash
bun index.ts
```

### Node.js Compatibility

Bun implements the Node.js module system, including:

- CommonJS (`require`, `module.exports`)
- ESModules (`import`, `export`)
- Node core modules (`fs`, `path`, `http`, `crypto`, `os`, `events`, `stream`, etc.)
- `process`, `Buffer`, `__dirname`, `__filename`
- `node:` protocol imports (`import fs from "node:fs"`)

[Inference] Most Node.js projects will run under Bun with few or no changes, but compatibility is not universal. Some native Node addons (`.node` files built with `node-gyp`) may not work. Bun maintains a compatibility tracker at https://bun.sh/nodejs.

### Environment Variables

Bun automatically loads `.env`, `.env.local`, `.env.development`, and `.env.production` files without any additional library.

```typescript
console.log(process.env.MY_VAR);
```

You can also use Bun's built-in `Bun.env`:

```typescript
console.log(Bun.env.MY_VAR);
```

### TypeScript Support

TypeScript is a first-class citizen in Bun. No `ts-node`, `tsx`, or build step is required.

Bun uses its own fast transpiler (not the TypeScript compiler `tsc`) for execution. This means:

- Type errors are **not** caught at runtime by Bun
- `tsconfig.json` is respected for path aliases and module resolution
- For type checking, run `tsc --noEmit` separately

### JSX Support

Bun supports JSX and TSX out of the box. Configure JSX behavior in `tsconfig.json` or `jsconfig.json`:

```json
{
  "compilerOptions": {
    "jsx": "react-jsx",
    "jsxImportSource": "react"
  }
}
```

### Watch Mode

```bash
bun --watch index.ts
```

Bun restarts the process when files change. For a softer reload that preserves state where possible:

```bash
bun --hot index.ts
```

`--hot` reloads modules in place without restarting the process. [Inference] This behavior may not work predictably with all module patterns.

---

## Package Manager

Bun includes a built-in package manager that is compatible with the npm registry and `package.json`.

### Installing Dependencies

```bash
bun install
```

This reads `package.json` and installs to `node_modules`. On first install, a `bun.lockb` binary lockfile is created.

### Adding Packages

```bash
bun add express
bun add -d typescript          # dev dependency
bun add -g typescript          # global install
bun add react@18               # specific version
```

### Removing Packages

```bash
bun remove express
```

### Updating Packages

```bash
bun update
bun update express
```

### Running package.json Scripts

```bash
bun run dev
bun run build
bun run test
```

Common script names have shortcuts:

```bash
bun dev    # runs the "dev" script
bun test   # runs the built-in test runner (not the "test" script)
```

### The Lockfile (`bun.lockb`)

`bun.lockb` is a binary lockfile for reproducible installs. It is faster to read and write than `package-lock.json` or `yarn.lock`. Commit it to version control.

To view a human-readable version:

```bash
bun bun.lockb
# or
cat bun.lockb | bun bun.lockb
```

As of Bun 1.1.x, a text-based lockfile format (`bun.lock`) is also supported and can be enabled in `bunfig.toml`.

### Workspaces

Bun supports npm-style workspaces for monorepos:

```json
{
  "name": "my-monorepo",
  "workspaces": ["packages/*"]
}
```

```bash
bun install
```

All workspace packages are symlinked into `node_modules`.

### `bunfig.toml`

Bun's configuration file. Examples:

```toml
[install]
# Use a custom registry
registry = "https://registry.npmjs.org"

[install.scopes]
# Scoped registry
"@mycompany" = { registry = "https://registry.mycompany.com", token = "$NPM_TOKEN" }

[run]
shell = "bun"
```

---

## The Bundler

Bun includes a built-in bundler for creating browser-ready output.

### Basic Usage

```bash
bun build ./src/index.ts --outdir ./dist
```

### Common Options

| Option                 | Description                           |
| ---------------------- | ------------------------------------- |
| `--outdir`             | Output directory                      |
| `--outfile`            | Single output file                    |
| `--target`             | `browser` (default), `bun`, or `node` |
| `--format`             | `esm` (default), `cjs`, `iife`        |
| `--minify`             | Enable all minification               |
| `--minify-syntax`      | Minify syntax only                    |
| `--minify-whitespace`  | Minify whitespace only                |
| `--minify-identifiers` | Minify identifier names               |
| `--sourcemap`          | `none`, `inline`, `external`          |
| `--splitting`          | Enable code splitting                 |
| `--external`           | Mark a package as external            |
| `--loader`             | Override loader for a file extension  |

### Example

```bash
bun build ./src/index.tsx \
  --outdir ./dist \
  --target browser \
  --minify \
  --sourcemap=external
```

### Programmatic API

```typescript
const result = await Bun.build({
  entrypoints: ["./src/index.tsx"],
  outdir: "./dist",
  minify: true,
  splitting: true,
  target: "browser",
});

if (!result.success) {
  console.error(result.logs);
}
```

### Plugins

Bun's bundler supports plugins to transform content:

```typescript
import { plugin } from "bun";

plugin({
  name: "my-plugin",
  setup(build) {
    build.onLoad({ filter: /\.txt$/ }, async (args) => {
      const text = await Bun.file(args.path).text();
      return {
        contents: `export default ${JSON.stringify(text)}`,
        loader: "js",
      };
    });
  },
});
```

### CSS and Asset Handling

Bun's bundler handles CSS imports when targeting the browser. Static assets (images, fonts) can be referenced and will be copied or inlined depending on configuration.

---

## The Test Runner

Bun has a built-in test runner compatible with Jest's API.

### Running Tests

```bash
bun test
```

By default, Bun discovers files matching:

- `**/*.test.{js,ts,jsx,tsx}`
- `**/*.spec.{js,ts,jsx,tsx}`
- `**/test.{js,ts}`

Filter by name:

```bash
bun test --test-name-pattern "my test name"
```

Filter by file:

```bash
bun test src/utils.test.ts
```

### Writing Tests

```typescript
import { describe, it, expect, beforeEach, afterEach } from "bun:test";

describe("math utils", () => {
  it("adds numbers", () => {
    expect(1 + 1).toBe(2);
  });

  it("handles async", async () => {
    const result = await Promise.resolve(42);
    expect(result).toBe(42);
  });
});
```

### Matchers

Bun supports most Jest matchers:

```typescript
expect(value).toBe(x)
expect(value).toEqual(x)
expect(value).toStrictEqual(x)
expect(value).toBeTruthy()
expect(value).toBeFalsy()
expect(value).toBeNull()
expect(value).toBeUndefined()
expect(value).toBeDefined()
expect(value).toBeGreaterThan(n)
expect(value).toContain(item)
expect(value).toMatchObject(obj)
expect(value).toMatchSnapshot()
expect(fn).toThrow()
expect(fn).toThrow("message")
```

### Mocking

```typescript
import { mock, spyOn } from "bun:test";

const myFn = mock(() => "mocked");
myFn();
expect(myFn).toHaveBeenCalled();

// Spy on a method
const spy = spyOn(console, "log");
console.log("hello");
expect(spy).toHaveBeenCalledWith("hello");
spy.mockRestore();
```

### Lifecycle Hooks

```typescript
beforeAll(() => { /* runs once before all tests in this scope */ });
afterAll(() => { /* runs once after all tests in this scope */ });
beforeEach(() => { /* runs before each test */ });
afterEach(() => { /* runs after each test */ });
```

### Coverage

```bash
bun test --coverage
```

### Watch Mode for Tests

```bash
bun test --watch
```

### Snapshot Testing

```typescript
expect({ name: "Bun" }).toMatchSnapshot();
```

Snapshots are stored in `__snapshots__/` directories. Update with:

```bash
bun test --update-snapshots
```

---

## Bun APIs

Bun exposes its own native APIs under the `Bun` global namespace. These are faster than Node.js equivalents in many cases.

### File I/O

```typescript
// Read a file
const file = Bun.file("./data.json");
const text = await file.text();
const json = await file.json();
const buffer = await file.arrayBuffer();
const stream = file.stream();

// File metadata
console.log(file.size);      // bytes
console.log(file.type);      // MIME type
console.log(file.lastModified); // timestamp

// Write a file
await Bun.write("./output.txt", "Hello, world!");
await Bun.write("./output.json", JSON.stringify({ ok: true }));

// Copy a file
await Bun.write(Bun.file("./copy.txt"), Bun.file("./original.txt"));
```

### HTTP Server

```typescript
Bun.serve({
  port: 3000,
  fetch(req) {
    const url = new URL(req.url);

    if (url.pathname === "/") {
      return new Response("Hello from Bun!");
    }

    return new Response("Not Found", { status: 404 });
  },
});

console.log("Listening on http://localhost:3000");
```

With TLS:

```typescript
Bun.serve({
  port: 443,
  tls: {
    cert: Bun.file("./cert.pem"),
    key: Bun.file("./key.pem"),
  },
  fetch(req) {
    return new Response("Secure!");
  },
});
```

### WebSockets

```typescript
Bun.serve({
  port: 3000,
  fetch(req, server) {
    if (server.upgrade(req)) {
      return; // upgraded to WebSocket
    }
    return new Response("Expected WebSocket");
  },
  websocket: {
    open(ws) {
      console.log("Client connected");
    },
    message(ws, message) {
      ws.send(`Echo: ${message}`);
    },
    close(ws) {
      console.log("Client disconnected");
    },
  },
});
```

### `fetch`

Bun implements the browser-standard `fetch` API natively:

```typescript
const res = await fetch("https://api.example.com/data");
const json = await res.json();
```

Bun's `fetch` also supports Unix domain sockets and custom DNS settings.

### Subprocess

```typescript
// Simple run
const proc = Bun.spawn(["ls", "-la"]);
const output = await new Response(proc.stdout).text();

// With shell
const result = await Bun.$`ls -la`.text();
const files = await Bun.$`find . -name "*.ts"`.lines();
```

The `Bun.$` shell API (available from Bun 1.0.23+) provides a cross-platform shell interface similar to `zx`.

### Hashing

```typescript
const hash = Bun.hash("some string");       // fast non-cryptographic hash
const crc32 = Bun.CryptoHasher.hash("crc32", "data");
const sha256 = new Bun.CryptoHasher("sha256");
sha256.update("hello");
console.log(sha256.digest("hex"));
```

### Password Hashing

```typescript
const hash = await Bun.password.hash("my-password");
const valid = await Bun.password.verify("my-password", hash);
```

Supports `bcrypt` and `argon2` algorithms.

### `Bun.sleep`

```typescript
await Bun.sleep(1000); // sleep 1 second
```

### `Bun.peek`

Inspects a Promise's current value without awaiting:

```typescript
const p = Promise.resolve(42);
console.log(Bun.peek(p)); // 42 (if already resolved)
```

### SQLite

Bun includes a built-in SQLite driver:

```typescript
import { Database } from "bun:sqlite";

const db = new Database("mydb.sqlite");

db.run("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)");
db.run("INSERT INTO users (name) VALUES (?)", ["Alice"]);

const users = db.query("SELECT * FROM users").all();
console.log(users);

db.close();
```

Prepared statements are supported and strongly recommended for performance and safety.

### `bun:ffi` — Foreign Function Interface

Bun can call native C libraries directly:

```typescript
import { dlopen, FFIType, suffix } from "bun:ffi";

const { symbols } = dlopen(`libmath.${suffix}`, {
  sqrt: {
    args: [FFIType.double],
    returns: FFIType.double,
  },
});

console.log(symbols.sqrt(16)); // 4
```

### `bun:dns`

```typescript
import { lookup } from "bun:dns";

const result = await lookup("bun.sh");
console.log(result);
```

---

## HTTP with Bun

### Basic Server Patterns

```typescript
// JSON API
Bun.serve({
  port: 3000,
  async fetch(req) {
    const url = new URL(req.url);

    if (req.method === "POST" && url.pathname === "/echo") {
      const body = await req.json();
      return Response.json({ received: body });
    }

    return new Response("Not Found", { status: 404 });
  },
});
```

### Routing

Bun does not include a built-in router, but frameworks like Hono, Elysia, and Express (with compatibility) work well.

**Hono** (recommended lightweight option):

```typescript
import { Hono } from "hono";

const app = new Hono();

app.get("/", (c) => c.text("Hello!"));
app.get("/users/:id", (c) => c.json({ id: c.req.param("id") }));

export default app;
```

Run with:

```bash
bun run index.ts
```

**Elysia** (Bun-native framework):

```typescript
import { Elysia } from "elysia";

const app = new Elysia()
  .get("/", () => "Hello!")
  .post("/mirror", ({ body }) => body)
  .listen(3000);
```

### Serving Static Files

```typescript
Bun.serve({
  port: 3000,
  async fetch(req) {
    const url = new URL(req.url);
    const file = Bun.file(`./public${url.pathname}`);

    if (await file.exists()) {
      return new Response(file);
    }

    return new Response("Not Found", { status: 404 });
  },
});
```

---

## Working with TypeScript

### Configuration (`tsconfig.json`)

Bun respects these `tsconfig.json` fields:

- `compilerOptions.paths` — module path aliases
- `compilerOptions.baseUrl`
- `compilerOptions.jsx` / `jsxImportSource`
- `compilerOptions.target` (for syntax downleveling)

Bun does **not** use `tsc` to transpile. It strips types without checking them.

### Path Aliases

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@utils/*": ["src/utils/*"],
      "@components/*": ["src/components/*"]
    }
  }
}
```

```typescript
import { formatDate } from "@utils/date";
```

### Type Checking

```bash
bunx tsc --noEmit
```

Or add to `package.json`:

```json
{
  "scripts": {
    "typecheck": "tsc --noEmit"
  }
}
```

---

## Bun in Production

### Building for Production

```bash
bun build ./src/index.ts --outfile dist/app.js --target bun --minify
```

Running the compiled output:

```bash
bun dist/app.js
```

### Compiling to a Single Executable

Bun can compile your project into a standalone binary with no runtime dependency:

```bash
bun build ./index.ts --compile --outfile myapp
./myapp
```

The binary embeds Bun's JavaScript runtime and your code. Supported on macOS, Linux, and Windows.

Cross-compilation (building for a different target OS) is supported with `--target`:

```bash
bun build ./index.ts --compile --target bun-linux-x64 --outfile myapp-linux
```

### Docker

Official Bun Docker images:

```dockerfile
FROM oven/bun:1

WORKDIR /app
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile

COPY . .
EXPOSE 3000
CMD ["bun", "run", "start"]
```

Use `--frozen-lockfile` in CI/CD to detect lockfile drift.

### Environment Variable Safety

Bun reads `.env` files automatically. In production, set environment variables via the host environment rather than `.env` files.

---

## The `bunx` Command

`bunx` is Bun's equivalent of `npx`. It runs a package without permanently installing it:

```bash
bunx create-next-app my-app
bunx prettier --write .
bunx tsc --noEmit
```

Packages are cached locally after the first use.

---

## Macros

Bun Macros are functions that run at **bundle time**, not at runtime. They are marked with the `with { type: "macro" }` import attribute.

```typescript
import { getVersion } from "./version.ts" with { type: "macro" };

const version = getVersion(); // evaluated at bundle time
console.log(version);
```

```typescript
// version.ts
export function getVersion() {
  return "1.0.0";
}
```

Macros must be pure functions that return serializable values. They are useful for embedding build-time constants, file contents, or generated data.

---

## Module System

### ESM and CommonJS Interop

Bun handles both ESM and CommonJS in the same project:

```typescript
// ESM
import express from "express"; // works even though express is CJS

// CommonJS
const path = require("path");
```

Bun automatically determines the module format from file extension and `package.json` `"type"` field:

|Extension|Format|
|---|---|
|`.mjs`|ESM|
|`.cjs`|CommonJS|
|`.js`|Depends on `"type"` in `package.json`|
|`.ts` / `.tsx`|ESM (by default)|

### `import.meta`

```typescript
console.log(import.meta.url);    // file:///path/to/file.ts
console.log(import.meta.dir);    // /path/to
console.log(import.meta.file);   // file.ts
console.log(import.meta.path);   // /path/to/file.ts (Bun-specific)
console.log(import.meta.main);   // true if this is the entry file
```

### `require` in ESM

Bun allows `require()` inside ESM files as a convenience. This is non-standard but useful for compatibility.

---

## Debugging

### Using the Inspector

```bash
bun --inspect index.ts
```

Opens a WebSocket debug server. Connect via:

- Chrome DevTools: `chrome://inspect`
- VS Code: attach to the Bun debug port (default `6499`)

```bash
bun --inspect-brk index.ts  # break on first line
```

### VS Code Integration

Install the official **Bun for Visual Studio Code** extension from the VS Code Marketplace. It provides:

- Debugger integration
- Test runner UI
- IntelliSense improvements

---

## Performance Notes

Bun is generally faster than Node.js in:

- Cold start time (important for serverless / CLI tools)
- Package installation speed
- HTTP throughput in simple benchmarks
- File I/O using `Bun.file`

[Inference] Real-world performance depends heavily on workload, framework, and infrastructure. Benchmark your specific use case before drawing conclusions.

[Unverified] Third-party benchmark numbers change frequently as both Bun and Node.js release updates. Treat any specific figure as a snapshot, not a permanent fact.

---

## Compatibility Notes

|Feature|Status|
|---|---|
|Node.js core modules|Mostly supported|
|npm packages (pure JS)|Broadly supported|
|Native addons (`.node`)|Partial / limited|
|`node-gyp` packages|Often unsupported|
|Worker threads|Supported|
|`cluster` module|Supported|
|`vm` module|Partial|
|`child_process`|Supported|
|WASM|Supported|

Check https://bun.sh/nodejs for an up-to-date compatibility table.

---

## Common CLI Reference

```bash
# Runtime
bun index.ts
bun run index.ts
bun --watch index.ts
bun --hot index.ts

# Package management
bun install
bun add <package>
bun add -d <package>
bun remove <package>
bun update
bun link
bun unlink

# Scripts
bun run <script>
bun dev
bun start

# Testing
bun test
bun test --watch
bun test --coverage
bun test --bail          # stop after first failure

# Building
bun build ./src/index.ts --outdir ./dist
bun build ./index.ts --compile --outfile myapp

# Utilities
bun --version
bun upgrade
bunx <package>
bun repl                 # interactive REPL
bun pm ls                # list installed packages
bun pm cache rm          # clear cache
```

---

## Configuration Summary

|File|Purpose|
|---|---|
|`package.json`|Dependencies, scripts, workspace config|
|`bun.lockb`|Binary lockfile (commit to VCS)|
|`bunfig.toml`|Bun-specific config (registry, test settings, etc.)|
|`tsconfig.json`|TypeScript options, path aliases|
|`.env`|Environment variables (auto-loaded)|

---

## Ecosystem and Frameworks

Frameworks and libraries known to work well with Bun:

- **Hono** — lightweight web framework, Bun-native support
- **Elysia** — Bun-first framework with TypeScript-first design
- **Express** — works via Node.js compatibility layer
- **Fastify** — works with minor caveats
- **Next.js** — experimental Bun support (check official Next.js docs)
- **Prisma** — supported
- **Drizzle ORM** — supported, works well with `bun:sqlite`
- **tRPC** — supported
- **Zod** — supported

[Inference] Framework compatibility changes with releases. Verify current status in each project's documentation.

---

## Resources

- Official site: https://bun.sh
- Documentation: https://bun.sh/docs
- GitHub: https://github.com/oven-sh/bun
- Discord: https://bun.sh/discord
- Node.js compatibility tracker: https://bun.sh/nodejs

---

# Bun APIs

## Overview

Bun provides a set of **native runtime APIs** that replace or extend Node.js-style tooling. These APIs are designed to be fast, simple, and tightly integrated with the Bun runtime (not the browser).

---

## Core Bun APIs

### 1. `Bun.file()`

Represents a file without immediately reading it into memory.

```ts
const file = Bun.file("data.txt");

const text = await file.text();
const bytes = await file.bytes();
```

Use cases:

* Reading files lazily
* Streaming large files efficiently
* Avoiding unnecessary memory allocation

---

### 2. `Bun.write()`

Writes data to disk.

```ts
await Bun.write("out.txt", "hello world");
```

You can also write:

* Strings
* `Uint8Array`
* Streams
* `Response` objects

---

### 3. `Bun.spawn()`

Runs external processes.

```ts
const proc = Bun.spawn(["ls", "-la"]);

const output = await new Response(proc.stdout).text();
```

Features:

* Faster than Node’s `child_process`
* Direct stream access to `stdout` / `stderr`

---

### 4. `Bun.serve()`

Built-in high-performance HTTP server.

```ts
Bun.serve({
  port: 3000,
  fetch(req) {
    return new Response("Hello Bun");
  },
});
```

Key points:

* No external framework required
* Extremely low overhead
* Built-in Web API compatibility (`Request`, `Response`)

---

### 5. `Bun.sql`

Simple SQL client (experimental depending on version).

```ts
const db = new Bun.SQL("sqlite://my.db");

const result = await db.query("SELECT 1 + 1");
```

Use cases:

* SQLite access
* Lightweight database queries
* Embedded database workflows

---

### 6. `Bun.env`

Access environment variables.

```ts
const apiKey = Bun.env.API_KEY;
```

Similar to `process.env`, but more directly integrated.

---

### 7. `Bun.argv`

Command-line arguments.

```ts
console.log(Bun.argv);
```

Example:

```bash
bun run app.ts hello world
```

---

### 8. `Bun.password`

Utilities for hashing and verifying passwords.

```ts
const hash = await Bun.password.hash("secret");

const match = await Bun.password.verify("secret", hash);
```

---

### 9. `Bun.sleep()`

Async delay utility.

```ts
await Bun.sleep(1000);
```

---

### 10. `Bun.which()`

Find executable path.

```ts
const gitPath = Bun.which("git");
```

---

## Web-Standard APIs (also available in Bun)

Bun also implements modern web APIs:

* `fetch`
* `Request` / `Response`
* `WebSocket`
* `ReadableStream` / `WritableStream`
* `URL`, `URLSearchParams`
* `TextEncoder` / `TextDecoder`

---

## Mental Model

Think of Bun as:

> Node.js + modern Web APIs + built-in tooling (bundler, test runner, package manager)

Instead of installing libraries for everything, Bun exposes many of them directly via runtime APIs.


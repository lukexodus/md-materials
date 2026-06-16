## Nodemon and Hot-Reloading for Development

Fastify does not include a built-in development server or hot-reload mechanism. During development, external tools are used to watch for file changes and restart the process automatically. The most common tool in the Node.js ecosystem for this purpose is `nodemon`. Newer alternatives exist and are increasingly used alongside or instead of it.

---

### What Hot-Reloading Means in This Context

In Node.js development, "hot-reloading" commonly refers to process restart on file change rather than true in-process module replacement. Full in-process hot module replacement (HMR) as seen in frontend bundlers is not standard in Node.js server applications.

[Inference] Fastify's plugin encapsulation model and module caching make true HMR non-trivial to implement without additional tooling. Most Fastify development workflows use process restart rather than in-process reload.

---

### Nodemon Overview

`nodemon` is a CLI tool that wraps a Node.js process, watches specified files or directories, and restarts the process when changes are detected.

**Key Points**

- Watches for file changes using filesystem events
- Restarts the Node.js process on change
- Configurable via CLI flags or a config file (`nodemon.json` or `package.json`)
- Does not modify application code

---

### Installation

**As a development dependency** (recommended):

```bash
npm install --save-dev nodemon
```

**Or globally** (not recommended for team projects; creates environment inconsistency):

```bash
npm install -g nodemon
```

---

### Basic Usage

**Via `package.json` scripts**:

```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  }
}
```

**Run**:

```bash
npm run dev
```

**Key Points**

- `nodemon` restarts the entire Node.js process; Fastify graceful shutdown hooks are not invoked on SIGTERM by default in this context [Unverified — behavior depends on nodemon version and OS signal handling]
- The entry point passed to `nodemon` should be `server.js`, not `app.js`, so that `listen()` is called after restart

---

### Nodemon Configuration

Nodemon can be configured via a `nodemon.json` file at the project root or via a `nodemon` key in `package.json`.

**Example** — `nodemon.json`:

```json
{
  "watch": ["src", "plugins", "routes", "app.js", "server.js"],
  "ext": "js,json,mjs",
  "ignore": ["node_modules", "test", "*.test.js", "*.spec.js"],
  "exec": "node server.js",
  "delay": "500"
}
```

**Key Points**

- `watch` — directories and files to monitor; defaults to the current directory if omitted
- `ext` — comma-separated list of file extensions to watch
- `ignore` — paths excluded from watching; `node_modules` is ignored by default but explicit inclusion is safe
- `exec` — the command to run; useful when the startup command differs from a simple `node` call
- `delay` — milliseconds to wait after a change before restarting; helps with rapid successive saves

**Example** — inline in `package.json`:

```json
{
  "scripts": {
    "dev": "nodemon server.js"
  },
  "nodemon": {
    "watch": ["src"],
    "ext": "js,json",
    "ignore": ["test"]
  }
}
```

---

### Watching Additional File Types

By default, nodemon watches `.js`, `.mjs`, `.cjs`, `.json`, and `.node` files. For projects using TypeScript or other transpiled formats, the watched extensions must be updated.

**Example** — TypeScript project:

```json
{
  "watch": ["src"],
  "ext": "ts,json",
  "exec": "ts-node src/server.ts",
  "ignore": ["**/*.test.ts"]
}
```

---

### Using Nodemon with Environment Variables

Nodemon does not load `.env` files itself. If `dotenv` is not configured inside the application, environment variables must be provided via the shell or a tool like `dotenv-cli`.

**Option 1** — application loads dotenv internally (preferred):

```js
// server.js
require('dotenv').config()
const buildApp = require('./app')
// ...
```

**Option 2** — `dotenv-cli` in the script:

```bash
npm install --save-dev dotenv-cli
```

```json
{
  "scripts": {
    "dev": "dotenv -e .env nodemon server.js"
  }
}
```

---

### Nodemon with Fastify-CLI

`fastify-cli` includes its own watch mode, making nodemon redundant when using the CLI.

**Example**:

```bash
fastify dev app.js
```

Or in `package.json`:

```json
{
  "scripts": {
    "dev": "fastify dev app.js"
  }
}
```

**Key Points**

- `fastify dev` uses `chokidar` internally for file watching [Unverified — implementation detail subject to change across CLI versions]
- It respects the `fastify-cli` entry point conventions described in the directory structure topic
- Using both `nodemon` and `fastify dev` simultaneously is unnecessary and may cause conflicts

---

### Node.js Built-in Watch Mode

Since Node.js 18, a built-in `--watch` flag is available, eliminating the need for nodemon in some cases.

**Example**:

```bash
node --watch server.js
```

Or in `package.json`:

```json
{
  "scripts": {
    "dev": "node --watch server.js"
  }
}
```

**Key Points**

- Available in Node.js 18.11.0+ (stable watch) and Node.js 16.19.0+ (experimental)
- Watches files loaded via `require()` or `import`; does not watch arbitrary directories
- Has no external configuration file; behavior is controlled via CLI flags only
- `--watch-path` flag allows specifying additional paths to watch

**Example** — with additional watch paths:

```bash
node --watch --watch-path=./config server.js
```

[Inference] For simple projects, the built-in `--watch` flag may be sufficient. For projects requiring fine-grained ignore patterns or extension filtering, `nodemon` remains more configurable. Behavior of `--watch` may vary across Node.js minor versions.

---

### Comparison of Development Reload Tools

| Tool | Configuration | `.env` Support | TS Support | External Dep |
|---|---|---|---|---|
| `nodemon` | `nodemon.json` / `package.json` | Via app or `dotenv-cli` | Via `exec` override | Yes |
| `node --watch` | CLI flags only | Via app | No (native Node) | No |
| `fastify dev` | fastify-cli config | Via app | [Unverified] | Yes (fastify-cli) |
| `tsx --watch` | CLI flags | Via app | Yes (native) | Yes |

---

### Common Issues and Notes

**Port already in use after restart**

If Fastify does not close the server cleanly before nodemon restarts the process, the port may remain bound briefly. Adding a short `delay` in nodemon config can reduce this occurrence. [Inference — actual behavior depends on OS, Node.js version, and whether graceful shutdown is implemented]

**Module caching**

Node.js caches `require()` calls. On process restart via nodemon, the cache is cleared because it is a full process restart — not a module-level reload. This is distinct from HMR approaches.

**Watching `node_modules`**

Watching `node_modules` is unnecessary and causes significant performance degradation. Nodemon excludes it by default, but explicitly confirming this in config is good practice for large projects.

---

**Conclusion**

For most Fastify development workflows, `nodemon` remains the most configurable and widely supported option for file watching and process restart. For projects using `fastify-cli`, the built-in `fastify dev` command is the more integrated choice. Node.js 18+ projects with simple requirements may use the built-in `--watch` flag to avoid the additional dependency. [Inference] None of these tools provide true in-process hot module replacement; all rely on full process restart, which means Fastify re-initializes completely on each file change.
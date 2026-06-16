## Fastify CLI Commands Overview

`fastify-cli` is a command-line tool that bootstraps, runs, and manages Fastify applications. It provides a standard project structure, a development server with watch mode, and a plugin-based application loader that integrates with Fastify's encapsulation model.

Install it globally or as a project dependency:

```bash
npm install fastify-cli --save-dev
# or globally
npm install -g fastify-cli
```

When installed locally, commands are available via `npx fastify` or through npm scripts.

---

### Command Reference Overview

The CLI exposes the following primary commands:

| Command | Purpose |
|---|---|
| `fastify start` | Start a Fastify application |
| `fastify generate` | Scaffold a new project |
| `fastify generate-plugin` | Scaffold a new plugin |
| `fastify print-routes` | Print the route tree |
| `fastify print-plugins` | Print the plugin tree |

---

### `fastify start`

Loads and starts a Fastify application from an entry file. The entry file must export a valid Fastify plugin function (i.e., an `async function (fastify, opts)` or equivalent).

```bash
fastify start app.js
fastify start src/app.js --port 4000 --address 0.0.0.0
```

**Key flags:**

| Flag | Alias | Default | Description |
|---|---|---|---|
| `--port` | `-p` | `3000` | Port to listen on |
| `--address` | `-a` | `127.0.0.1` | Host address to bind |
| `--socket` | `-s` | — | Unix socket path (overrides port/address) |
| `--log-level` | `-l` | `info` | Pino log level (`trace`, `debug`, `info`, `warn`, `error`, `fatal`, `silent`) |
| `--pretty-logs` | `-P` | `false` | Enable Pino pretty printing (for development) |
| `--watch` | `-w` | `false` | Restart on file changes |
| `--watch-ignore` | — | — | Glob patterns to exclude from watch |
| `--watch-verbose` | — | `false` | Log files being watched |
| `--ignore-watch` | — | — | Alias for `--watch-ignore` on some versions [Unverified] |
| `--options` | `-o` | — | Pass Fastify options as a JSON string |
| `--prefix` | `-x` | — | Mount the application under a URL prefix |
| `--plugin-timeout` | — | `10000` | Max ms to wait for a plugin to load |
| `--body-limit` | — | — | Override default body size limit (bytes) |
| `--require` | `-r` | — | Require modules before loading the app |
| `--debug` | `-d` | — | Enable Node.js inspector |
| `--debug-port` | — | `9320` | Inspector port |
| `--config` | `-c` | — | Path to a config file |

**Example — development server with watch and pretty logs:**

```bash
fastify start app.js --watch --pretty-logs --log-level debug
```

**Example — production-style start with prefix:**

```bash
fastify start app.js --port 8080 --address 0.0.0.0 --prefix /api/v1
```

---

### Entry File Requirements for `fastify start`

The file passed to `fastify start` must export a plugin function. The CLI wraps it in a Fastify instance internally.

```js
// app.js
async function app (fastify, opts) {
  fastify.get('/health', async () => ({ status: 'ok' }))
}

module.exports = app
```

Optionally, export an `options` object to pass default Fastify options:

```js
module.exports = app
module.exports.options = {
  trustProxy: true,
  logger: true
}
```

> [Inference] The `options` export is merged with CLI-provided options; CLI flags may take precedence over exported options in some cases — verify precedence behavior for your version.

---

### `fastify generate`

Scaffolds a new Fastify project with an opinionated directory structure.

```bash
fastify generate my-app
cd my-app
npm install
```

**Generated structure:**

```
my-app/
├── app.js              # Root plugin / entry point
├── package.json
├── README.md
├── plugins/            # Shared plugins (registered first)
│   ├── sensible.js
│   └── support.js
├── routes/             # Auto-loaded route plugins
│   └── root.js
└── test/
    ├── helper.js
    └── routes/
        └── root.test.js
```

**Key Points:**
- Routes in `routes/` are auto-loaded using `@fastify/autoload`.
- Plugins in `plugins/` are loaded before routes, making them available application-wide.
- The structure enforces Fastify's encapsulation model by design.

**Options:**

| Flag | Description |
|---|---|
| `--lang` | Language: `js` (default) or `ts` for TypeScript |
| `--esm` | Scaffold using ES module syntax |
| `--standardx` | Use StandardX linting |
| `--integrations` | [Unverified] May vary by version |

**TypeScript scaffold:**

```bash
fastify generate my-app --lang=ts
```

This produces a TypeScript-ready project with `tsconfig.json`, `.ts` source files, and appropriate build scripts.

---

### `fastify generate-plugin`

Scaffolds a standalone Fastify plugin package — useful for creating reusable plugins intended for npm publication or monorepo sharing.

```bash
fastify generate-plugin my-plugin
cd my-plugin
npm install
```

**Generated structure:**

```
my-plugin/
├── index.js          # Plugin entry, exports fastify-plugin wrapped function
├── package.json
├── README.md
└── test/
    └── index.test.js
```

The generated `index.js` wraps the plugin with `fastify-plugin` by default, which breaks encapsulation so decorators and hooks are available to the parent scope — the standard pattern for shareable plugins.

---

### `fastify print-routes`

Prints the full route tree of the application to stdout, without starting the HTTP server. Useful for auditing registered routes during development or CI.

```bash
fastify print-routes app.js
```

**Example output:**

```
└── /
    ├── health (GET)
    ├── api/
    │   └── v1/
    │       ├── users (GET, POST)
    │       └── users/:id (GET, PUT, DELETE)
    └── docs (GET)
```

**Flags:**

| Flag | Description |
|---|---|
| `--short-source` | Truncate source file paths |
| `--pretty-print` | Human-readable tree format (default behavior) |

> **Note:** `print-routes` instantiates the Fastify app internally to collect routes, so plugins and autoload must resolve correctly for it to succeed.

---

### `fastify print-plugins`

Prints the plugin tree — showing how plugins are nested and in what order they are loaded.

```bash
fastify print-plugins app.js
```

**Example output:**

```
bound _after (fastify)
└── @fastify/autoload
    ├── plugins/sensible.js
    ├── plugins/support.js
    └── routes/
        └── root.js
```

This is useful for diagnosing plugin load order issues, encapsulation scope problems, or unexpected decoration availability.

---

### Using the CLI via npm Scripts

When `fastify-cli` is a local dependency, define scripts in `package.json`:

```json
{
  "scripts": {
    "start": "fastify start app.js",
    "dev": "fastify start app.js --watch --pretty-logs --log-level debug",
    "build": "tsc",
    "routes": "fastify print-routes app.js"
  }
}
```

Run with:

```bash
npm start
npm run dev
```

---

### Watch Mode Behavior

When `--watch` is active, `fastify-cli` monitors the project directory for file changes and restarts the server automatically.

**Key Points:**
- Watch mode uses `chokidar` internally [Inference — based on common CLI tooling patterns; verify in source].
- Node modules (`node_modules/`) are excluded from watching by default.
- Use `--watch-ignore` to exclude additional patterns:

```bash
fastify start app.js --watch --watch-ignore "*.test.js" --watch-ignore "coverage/**"
```

> [Inference] Watch mode is intended for development use; running it in production is not a supported or recommended pattern, and behavior under high file-change frequency is not guaranteed.

---

### Passing Options via `--options`

Fastify instance options can be passed as a JSON string:

```bash
fastify start app.js --options '{"trustProxy":true,"requestTimeout":5000}'
```

This is useful for passing options that do not have dedicated CLI flags.

---

### `--require` Flag

Preloads Node.js modules before the application loads. Common uses include registering TypeScript path aliases or loading environment variable files:

```bash
fastify start app.js --require dotenv/config --require tsconfig-paths/register
```

> [Inference] Module resolution follows standard Node.js `require` semantics; ES module compatibility depends on your Node.js version and project configuration.

---

### TypeScript Usage

When using TypeScript with `fastify-cli`, the entry point should be the compiled JS output. A typical workflow:

```json
{
  "scripts": {
    "build": "tsc",
    "start": "npm run build && fastify start dist/app.js",
    "dev": "tsc-watch --onSuccess \"fastify start dist/app.js --watch\""
  }
}
```

Alternatively, use `--require ts-node/register` for a no-build development setup:

```bash
fastify start src/app.ts --require ts-node/register
```

> [Inference] `ts-node` in this context bypasses compilation; production deployments should use compiled output. Behavior with ESM TypeScript may vary.

---

### Environment Variables

`fastify-cli` respects the following environment variables, which can supplement or override CLI flags:

| Variable | Equivalent flag |
|---|---|
| `FASTIFY_PORT` | `--port` |
| `FASTIFY_ADDRESS` | `--address` |
| `FASTIFY_SOCKET` | `--socket` |
| `FASTIFY_LOG_LEVEL` | `--log-level` |
| `FASTIFY_PRETTY_LOGS` | `--pretty-logs` |
| `FASTIFY_WATCH` | `--watch` |
| `FASTIFY_PREFIX` | `--prefix` |

> [Unverified] The exact set of supported environment variables may differ across `fastify-cli` versions. Verify against your installed version's documentation or `fastify start --help`.

---

**Related Topics:**
- `@fastify/autoload` — file-based plugin and route loading
- `fastify-plugin` (`fp`) — breaking encapsulation for shared plugins
- Fastify project structure conventions and best practices
- TypeScript integration with `fastify-cli` and `ts-node`
- Environment-based configuration patterns (`dotenv`, `@fastify/env`)
- CI/CD integration using `print-routes` for route auditing
- Fastify plugin timeout tuning and startup diagnostics
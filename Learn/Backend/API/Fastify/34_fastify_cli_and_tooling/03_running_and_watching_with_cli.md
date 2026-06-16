## Running and Watching with CLI

`fastify-cli` manages the full application lifecycle for development and production — loading the entry plugin, binding the server, and optionally restarting on file changes. Understanding the runtime behavior, flag interactions, and watch mode mechanics allows you to configure a reliable development workflow and avoid common startup pitfalls.

---

### How `fastify start` Loads an Application

When you run `fastify start app.js`, the CLI:

1. Requires (or imports) the entry file
2. Expects a default export that is a valid Fastify plugin function
3. Creates a Fastify instance internally
4. Registers the exported plugin onto that instance
5. Calls `fastify.listen()` with the resolved address and port

The entry file must export a plugin function — not a configured Fastify instance:

```js
// ✅ Correct — exports a plugin function
async function app (fastify, opts) {
  fastify.get('/health', async () => ({ ok: true }))
}
module.exports = app

// ❌ Incorrect — exports a configured instance
const fastify = require('fastify')()
fastify.get('/health', async () => ({ ok: true }))
module.exports = fastify
```

> [Inference] Exporting a configured instance rather than a plugin function may cause silent failures or errors at startup, as the CLI expects to control instance creation itself.

---

### Listening Options

#### Port and Address

```bash
fastify start app.js --port 4000 --address 0.0.0.0
```

- `--port` (`-p`): defaults to `3000`
- `--address` (`-a`): defaults to `127.0.0.1`

Binding to `0.0.0.0` makes the server reachable on all network interfaces — necessary in containerized environments.

#### Unix Socket

```bash
fastify start app.js --socket /tmp/fastify.sock
```

When `--socket` is provided, `--port` and `--address` are ignored. The server binds to the socket path instead. Useful for reverse proxy setups (e.g., Nginx communicating with Fastify over a Unix socket).

#### Backlog

[Unverified] Some versions of `fastify-cli` support a `--backlog` flag to control the TCP listen backlog queue length. Verify availability with `fastify start --help` for your installed version.

---

### Logging Options

#### Log Level

```bash
fastify start app.js --log-level debug
```

Valid levels (Pino): `trace`, `debug`, `info`, `warn`, `error`, `fatal`, `silent`.

- Default: `info`
- `silent` suppresses all log output

#### Pretty Logs

```bash
fastify start app.js --pretty-logs
```

Enables `pino-pretty` for human-readable, colorized output. Requires `pino-pretty` to be installed:

```bash
npm install --save-dev pino-pretty
```

> **Note:** Pretty logging carries formatting overhead. It is intended for development only. Structured JSON output (the default) is preferred for production log aggregation.

**Example pretty output:**

```
[12:34:56.789] INFO (12345): Server listening at http://127.0.0.1:3000
[12:34:57.001] INFO (12345): incoming request
    reqId: "req-1"
    req: { "method": "GET", "url": "/health" }
```

**Example JSON output (default):**

```json
{"level":30,"time":1718000000000,"pid":12345,"hostname":"host","msg":"Server listening at http://127.0.0.1:3000"}
```

---

### URL Prefix

```bash
fastify start app.js --prefix /api/v1
```

Mounts the entire application under the given prefix. All routes defined in the app are offset by this value:

```
GET /health   →   GET /api/v1/health
GET /users    →   GET /api/v1/users
```

This is equivalent to wrapping the plugin in a `fastify.register` with a `prefix` option. Useful when deploying behind a reverse proxy that strips or rewrites path prefixes.

---

### Plugin Timeout

```bash
fastify start app.js --plugin-timeout 15000
```

Sets the maximum time (in milliseconds) Fastify will wait for a plugin to finish loading before throwing a timeout error. The default is `10000` (10 seconds).

Increase this when plugins perform slow initialization (e.g., database connection pools with retry logic):

```
Error: Plugin did not start in time: 'my-db-plugin'. You may have forgotten to call 'done' or to resolve a Promise
```

> [Inference] If you encounter plugin timeouts in CI environments with limited resources, increasing this value is a reasonable first diagnostic step. The root cause is often a hung promise in plugin initialization.

---

### Requiring Modules Before Load

```bash
fastify start app.js --require dotenv/config
fastify start app.js --require dotenv/config --require tsconfig-paths/register
```

The `--require` (`-r`) flag preloads Node.js modules before the app loads. Multiple `--require` flags are supported and applied in order.

**Common uses:**

| Module | Purpose |
|---|---|
| `dotenv/config` | Load `.env` variables into `process.env` |
| `tsconfig-paths/register` | Resolve TypeScript path aliases at runtime |
| `ts-node/register` | Transpile TypeScript files on the fly |
| `@opentelemetry/auto-instrumentations-node` | Enable OTel auto-instrumentation |

---

### Passing Fastify Options

```bash
fastify start app.js --options '{"trustProxy":true,"connectionTimeout":5000}'
```

The `--options` (`-o`) flag passes a JSON string that is merged into the Fastify instance options. Use this for options that do not have dedicated CLI flags.

Alternatively, define defaults in the exported `options` object in your entry file:

```js
module.exports = app
module.exports.options = {
  trustProxy: true,
  connectionTimeout: 5000,
  bodyLimit: 1048576
}
```

> [Inference] CLI `--options` values and exported `options` may be merged rather than one fully overriding the other; the exact precedence behavior should be verified for your specific version.

---

### Environment Variables as Configuration

`fastify-cli` reads environment variables as an alternative to CLI flags:

| Environment Variable | Equivalent Flag | Default |
|---|---|---|
| `FASTIFY_PORT` | `--port` | `3000` |
| `FASTIFY_ADDRESS` | `--address` | `127.0.0.1` |
| `FASTIFY_SOCKET` | `--socket` | — |
| `FASTIFY_LOG_LEVEL` | `--log-level` | `info` |
| `FASTIFY_PRETTY_LOGS` | `--pretty-logs` | `false` |
| `FASTIFY_WATCH` | `--watch` | `false` |
| `FASTIFY_PREFIX` | `--prefix` | — |
| `FASTIFY_PLUGIN_TIMEOUT` | `--plugin-timeout` | `10000` |
| `FASTIFY_BODY_LIMIT` | `--body-limit` | — |

**Example `.env` file used with `--require dotenv/config`:**

```env
FASTIFY_PORT=4000
FASTIFY_ADDRESS=0.0.0.0
FASTIFY_LOG_LEVEL=debug
FASTIFY_PRETTY_LOGS=true
```

> [Unverified] The complete set of supported environment variables may vary by version. Verify with `fastify start --help` and your installed version's changelog.

---

### Watch Mode

Watch mode monitors the project for file changes and automatically restarts the server.

```bash
fastify start app.js --watch
# or shorthand
fastify start app.js -w
```

#### What Watch Mode Does

On detecting a file change:

1. The running Fastify server is closed gracefully
2. Node.js module cache is cleared for changed files
3. The application is re-required and restarted

> [Inference] Full module cache invalidation behavior depends on how `fastify-cli` implements watch restarts internally; in some configurations, only directly changed files may be re-evaluated. Test complex plugin dependency chains manually.

#### Watch Scope

By default, `fastify-cli` watches the current working directory recursively, excluding `node_modules`.

#### Ignoring Files and Directories

```bash
fastify start app.js --watch --watch-ignore "*.test.js"
fastify start app.js --watch --watch-ignore "coverage/**" --watch-ignore "*.log"
```

Multiple `--watch-ignore` patterns are supported. Patterns follow glob syntax.

#### Verbose Watch Output

```bash
fastify start app.js --watch --watch-verbose
```

Logs which files are being watched and which changes triggered a restart. Useful when diagnosing why changes are or are not causing restarts.

**Example output with `--watch-verbose`:**

```
Watching: /home/user/my-app
Watching: /home/user/my-app/app.js
Watching: /home/user/my-app/routes/root.js
...
[change] /home/user/my-app/routes/root.js — restarting
```

---

### Watch Mode with Pretty Logs (Development Workflow)

A complete development start command combining the most useful flags:

```bash
fastify start app.js \
  --watch \
  --pretty-logs \
  --log-level debug \
  --port 3000 \
  --watch-ignore "test/**" \
  --watch-ignore "*.md"
```

As an npm script:

```json
{
  "scripts": {
    "dev": "fastify start app.js -w -P -l debug"
  }
}
```

---

### Debugging

#### Enable Node.js Inspector

```bash
fastify start app.js --debug
```

Starts the server with the Node.js inspector active. Attach any inspector-compatible debugger (Chrome DevTools, VS Code, WebStorm).

#### Custom Debug Port

```bash
fastify start app.js --debug --debug-port 9229
```

Default debug port when `--debug` is used without `--debug-port` is `9320`.

#### Debugging with Watch Mode

```bash
fastify start app.js --watch --debug --debug-port 9229
```

> [Inference] Combining watch mode with the debugger may require re-attaching the debugger after each restart, as the inspector session is reset when the process restarts. Behavior varies by IDE and debugger implementation.

---

### Graceful Shutdown

`fastify-cli` registers signal handlers for `SIGINT` and `SIGTERM` that call `fastify.close()` before the process exits.

> [Inference] Custom cleanup logic should be registered with `fastify.addHook('onClose', ...)` inside the application plugin. This hook is invoked during `fastify.close()` and is the appropriate place for database disconnection, cache flushing, and similar teardown work.

```js
// app.js
async function app (fastify, opts) {
  fastify.addHook('onClose', async (instance) => {
    await instance.db.disconnect()
  })
}
module.exports = app
```

---

### Common Startup Errors and Diagnostics

| Error | Likely Cause |
|---|---|
| `Plugin did not start in time` | Plugin initialization hung — unresolved promise or missing `done()` call |
| `FST_ERR_PLUGIN_NOT_VALID` | Entry file does not export a valid plugin function |
| `EADDRINUSE` | Port already in use — another process is bound to the same port |
| `Cannot find module '...'` | Missing dependency or incorrect `--require` path |
| `EACCES` | Permission denied binding to a privileged port (< 1024) or socket path |

For plugin load issues, `fastify print-plugins app.js` can help identify where in the tree loading fails before attempting to start the server.

---

### Running in Production

In production, avoid watch mode, pretty logging, and debug flags. A minimal production start:

```bash
fastify start app.js \
  --port 8080 \
  --address 0.0.0.0 \
  --log-level warn
```

Or via environment variables in a container:

```dockerfile
ENV FASTIFY_PORT=8080
ENV FASTIFY_ADDRESS=0.0.0.0
ENV FASTIFY_LOG_LEVEL=warn
CMD ["fastify", "start", "app.js"]
```

> [Inference] For production deployments requiring zero-downtime restarts or cluster mode, a process manager such as PM2 or a container orchestrator (Kubernetes) is the recommended approach. `fastify-cli` itself does not provide clustering or worker management.

---

**Related Topics:**
- Fastify `onClose` hook and graceful shutdown patterns
- Pino logger configuration and log transport setup
- `@fastify/autoload` behavior during watch restarts
- Containerizing Fastify applications (Docker, environment variable configuration)
- PM2 cluster mode with Fastify
- Node.js inspector and VS Code debugger attachment
- `fastify print-routes` and `fastify print-plugins` for startup diagnostics
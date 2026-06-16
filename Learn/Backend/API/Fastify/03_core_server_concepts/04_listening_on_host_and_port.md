## Listening on Host and Port

### Overview

When Fastify binds to a host and port, it determines which network interfaces accept incoming connections. Choosing the correct host and port values is critical for local development, containerized deployments, and production environments. Behavior may vary depending on the OS, network configuration, and Node.js version.

---

### The `host` Option

The `host` value passed to `fastify.listen()` controls which network interface the server binds to.

| Host Value | Behavior |
|---|---|
| `'127.0.0.1'` | Localhost only — default; not reachable externally |
| `'0.0.0.0'` | All IPv4 interfaces — externally reachable |
| `'::'` | All IPv6 interfaces (may include IPv4 depending on OS) [Unverified — OS-dependent] |
| `'localhost'` | Resolves to loopback — exact behavior depends on OS DNS resolution |
| A specific IP | Binds only to that interface |

**Key Points:**
- Fastify's default host is `'127.0.0.1'` — this is intentionally conservative
- In Docker or Kubernetes, the server must bind to `'0.0.0.0'` to be reachable from outside the container
- Using `'localhost'` is subtly different from `'127.0.0.1'` — on some systems `localhost` resolves to `::1` (IPv6 loopback), which may produce unexpected behavior [Inference]
- Prefer explicit IP strings over `'localhost'` for predictability

---

### The `port` Option

| Port Value | Behavior |
|---|---|
| `0` | OS assigns a random available port |
| `1–1023` | Well-known ports — require elevated privileges on most Unix systems |
| `1024–49151` | Registered ports — typical application range |
| `49152–65535` | Dynamic/ephemeral ports |

**Key Points:**
- Port `0` is commonly used in testing to avoid hardcoded port conflicts
- Ports below `1024` typically require root or `CAP_NET_BIND_SERVICE` on Linux — attempting to bind without privileges throws `EACCES`
- The assigned port (especially when using `0`) can be retrieved after binding via `fastify.server.address().port`

---

### Basic Examples

**Localhost only (default behavior):**

```js
await fastify.listen({ port: 3000 })
// Equivalent to: { port: 3000, host: '127.0.0.1' }
```

**All IPv4 interfaces:**

```js
await fastify.listen({ port: 3000, host: '0.0.0.0' })
```

**Specific interface:**

```js
await fastify.listen({ port: 3000, host: '192.168.1.100' })
```

**Random port (useful for tests):**

```js
await fastify.listen({ port: 0 })
const { port } = fastify.server.address()
console.log(`Bound to port: ${port}`)
```

---

### Retrieving the Bound Address

After a successful `listen()` call, the actual address can be inspected:

```js
await fastify.listen({ port: 3000, host: '0.0.0.0' })

const address = fastify.server.address()
console.log(address)
// { address: '0.0.0.0', family: 'IPv4', port: 3000 }
```

Fastify also logs the listening address automatically when a logger is enabled:

```js
const fastify = require('fastify')({ logger: true })
await fastify.listen({ port: 3000, host: '0.0.0.0' })
```

**Output:**
```
{"level":30,"msg":"Server listening at http://0.0.0.0:3000"}
```

---

### IPv6 Binding

To bind to all IPv6 interfaces:

```js
await fastify.listen({ port: 3000, host: '::' })
```

**Key Points:**
- On Linux, binding to `::` with `IPV6_V6ONLY` disabled (the default on most systems) may also accept IPv4 connections [Unverified — OS and Node.js configuration dependent]
- On Windows, dual-stack behavior differs from Linux — verify binding behavior in your target environment [Inference]
- To bind exclusively to IPv6 loopback: use `'::1'`

---

### Binding to Multiple Addresses

Fastify does not natively support binding a single instance to multiple host/port combinations. [Inference — based on the single `listen()` call design]

Common workarounds include:

- Running multiple Fastify instances, each bound to a different address
- Using a reverse proxy (e.g., Nginx, HAProxy) in front of a single `0.0.0.0`-bound instance
- Using Node.js `cluster` or a process manager to manage multiple workers

---

### Environment-Driven Configuration

Hardcoding host and port values is discouraged in production. The standard pattern reads from environment variables:

```js
const host = process.env.HOST ?? '127.0.0.1'
const port = parseInt(process.env.PORT ?? '3000', 10)

await fastify.listen({ port, host })
```

**Key Points:**
- Always parse `PORT` as an integer — `process.env` values are strings, and passing a string to `port` may produce unexpected behavior depending on the Node.js version [Inference]
- Provide sensible defaults that are safe for local development (e.g., `127.0.0.1`) while allowing overrides in deployment environments

---

### The `listenTextResolver` Option

Fastify allows customizing the log message emitted when the server starts listening:

```js
await fastify.listen({
  port: 3000,
  host: '0.0.0.0',
  listenTextResolver: (address) => `Custom: server up at ${address}`
})
```

**Output:**
```
{"level":30,"msg":"Custom: server up at http://0.0.0.0:3000"}
```

**Key Points:**
- This is useful when the default log message does not fit your logging conventions
- The resolver receives the full bound address string as its argument

---

### Unix Socket Path (Alternative to Host/Port)

When the `path` option is provided, Fastify binds to a Unix domain socket instead of a TCP host/port:

```js
await fastify.listen({ path: '/tmp/fastify.sock' })
```

**Key Points:**
- `path` overrides `host` and `port` — they are ignored when `path` is set
- Unix sockets are only available on Unix-like systems
- Useful for inter-process communication or when a reverse proxy communicates with the app over a socket

---

### Host and Port Binding Across Environments

| Environment | Recommended Host | Notes |
|---|---|---|
| Local development | `'127.0.0.1'` | Safe default; not externally exposed |
| Docker container | `'0.0.0.0'` | Required for traffic to reach the container |
| Kubernetes pod | `'0.0.0.0'` | Service routing requires all-interface binding |
| Behind reverse proxy | `'127.0.0.1'` | Proxy handles external traffic; app binds locally |
| Testing | `'127.0.0.1'`, port `0` | Avoids conflicts; retrieve port dynamically |

---

### Binding Diagram

<svg viewBox="0 0 640 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="640" height="400" fill="#1e1e2e" rx="12"/>
  <text x="320" y="32" text-anchor="middle" fill="#cdd6f4" font-size="14" font-weight="bold">Host Binding — Network Interface Scope</text>

  <!-- Machine outline -->
  <rect x="60" y="55" width="520" height="310" rx="8" fill="#181825" stroke="#45475a" stroke-width="1.5" stroke-dasharray="6,3"/>
  <text x="320" y="76" text-anchor="middle" fill="#6c7086" font-size="11">Host Machine</text>

  <!-- 0.0.0.0 ring -->
  <ellipse cx="320" cy="210" rx="230" ry="130" fill="none" stroke="#a6e3a1" stroke-width="1.5" stroke-dasharray="5,3"/>
  <text x="320" y="92" text-anchor="middle" fill="#a6e3a1" font-size="11">0.0.0.0 — all interfaces</text>

  <!-- 127.0.0.1 ring -->
  <ellipse cx="320" cy="210" rx="120" ry="70" fill="none" stroke="#89b4fa" stroke-width="1.5" stroke-dasharray="5,3"/>
  <text x="320" y="152" text-anchor="middle" fill="#89b4fa" font-size="11">127.0.0.1 — loopback only</text>

  <!-- Center node -->
  <circle cx="320" cy="210" r="32" fill="#313244" stroke="#cba6f7" stroke-width="2"/>
  <text x="320" y="206" text-anchor="middle" fill="#cba6f7" font-size="11">Fastify</text>
  <text x="320" y="221" text-anchor="middle" fill="#cba6f7" font-size="10">:3000</text>

  <!-- External traffic arrow (0.0.0.0) -->
  <line x1="80" y1="210" x2="186" y2="210" stroke="#a6e3a1" stroke-width="1.5" marker-end="url(#arrG)"/>
  <text x="68" y="200" text-anchor="middle" fill="#a6e3a1" font-size="10">External</text>
  <text x="68" y="213" text-anchor="middle" fill="#a6e3a1" font-size="10">Traffic</text>

  <!-- Loopback arrow (127.0.0.1) -->
  <line x1="197" y1="195" x2="285" y2="195" stroke="#89b4fa" stroke-width="1.5" marker-end="url(#arrB)"/>
  <text x="240" y="185" text-anchor="middle" fill="#89b4fa" font-size="10">Loopback</text>

  <!-- Blocked external (127.0.0.1 only label) -->
  <line x1="80" y1="260" x2="155" y2="245" stroke="#f38ba8" stroke-width="1.5" stroke-dasharray="4,3"/>
  <text x="62" y="258" text-anchor="middle" fill="#f38ba8" font-size="10">Blocked</text>
  <text x="62" y="271" text-anchor="middle" fill="#f38ba8" font-size="10">(127 only)</text>

  <!-- Legend -->
  <rect x="420" y="300" width="12" height="12" fill="none" stroke="#a6e3a1" stroke-width="1.5"/>
  <text x="438" y="311" fill="#a6e3a1" font-size="11">0.0.0.0</text>
  <rect x="420" y="320" width="12" height="12" fill="none" stroke="#89b4fa" stroke-width="1.5"/>
  <text x="438" y="331" fill="#89b4fa" font-size="11">127.0.0.1</text>
  <line x1="420" y1="344" x2="432" y2="344" stroke="#f38ba8" stroke-width="1.5" stroke-dasharray="4,3"/>
  <text x="438" y="348" fill="#f38ba8" font-size="11">Blocked</text>

  <defs>
    <marker id="arrG" markerWidth="8" markerHeight="8" refX="4" refY="3" orient="auto">
      <path d="M0,0 L0,6 L7,3 z" fill="#a6e3a1"/>
    </marker>
    <marker id="arrB" markerWidth="8" markerHeight="8" refX="4" refY="3" orient="auto">
      <path d="M0,0 L0,6 L7,3 z" fill="#89b4fa"/>
    </marker>
  </defs>
</svg>

---

### Common Errors and Causes

| Error           | Cause                                           | Resolution                                                   |
| --------------- | ----------------------------------------------- | ------------------------------------------------------------ |
| `EADDRINUSE`    | Port already in use                             | Choose a different port or terminate the conflicting process |
| `EACCES`        | Port below 1024 without privileges              | Use a port ≥ 1024 or run with appropriate permissions        |
| `EADDRNOTAVAIL` | Specified host IP not available on this machine | Verify the IP is assigned to a local interface               |

---

**Conclusion:** The `host` and `port` options together determine the reachability and exposure of your Fastify server. Binding to `127.0.0.1` is the safe default for local development, while `0.0.0.0` is required for containerized or externally accessible deployments. Combining environment-driven configuration with explicit IP strings produces the most portable and predictable behavior across environments.
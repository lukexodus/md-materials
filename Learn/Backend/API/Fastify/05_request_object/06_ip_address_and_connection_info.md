### Fastify Request Object — IP Address and Connection Info

#### Overview

Fastify exposes connection-level metadata through the request object, allowing handlers to inspect the client's IP address, hostname, protocol, and related network information. These properties are derived from the underlying Node.js `http.IncomingMessage` object and, where configured, from proxy-forwarded headers.

---

#### `request.ip`

Returns the client's IP address as a string.

By default, Fastify reads the IP from the raw socket connection (`request.socket.remoteAddress`). If the server is behind a reverse proxy (e.g., Nginx, Cloudflare), the real client IP is typically forwarded via the `X-Forwarded-For` header instead.

To enable proxy-aware IP resolution, set `trustProxy` in the Fastify factory options:

js

```
const fastify = require('fastify')({ trustProxy: true });

fastify.get('/ip', async (request, reply) => {
  return { ip: request.ip };
});
```

**Key Points:**

- When `trustProxy` is `false` (the default), `request.ip` reflects the immediate socket peer address.
- When `trustProxy` is `true`, Fastify reads the leftmost address from `X-Forwarded-For`.
- `trustProxy` can also be set to a specific IP, CIDR, or array of trusted proxies for finer control. [Inference: this delegates to the `proxy-addr` package under the hood, though this is an implementation detail subject to change.]

**Example:**

js

```
const fastify = require('fastify')({ trustProxy: true });

fastify.get('/who', async (request) => {
  return { clientIP: request.ip };
});
```

**Output** (behind a proxy forwarding `X-Forwarded-For: 203.0.113.5`):

json

```
{ "clientIP": "203.0.113.5" }
```

---

#### `request.ips`

Returns an array of IP addresses parsed from the `X-Forwarded-For` header, ordered from the original client IP (leftmost) to the nearest proxy (rightmost).

Only available when `trustProxy` is enabled. Returns `undefined` otherwise.

js

```
fastify.get('/ips', async (request) => {
  return { ips: request.ips };
});
```

**Output** (for `X-Forwarded-For: 203.0.113.5, 10.0.0.1`):

json

```
{ "ips": ["203.0.113.5", "10.0.0.1"] }
```

**Key Points:**

- Useful for auditing the full proxy chain.
- The trustworthiness of entries beyond the first depends on whether each proxy is actually trusted.
- Do not treat all entries as verified client IPs — only the leftmost address before untrusted hops reflects the actual originating client. [Inference]

---

#### `request.hostname`

Returns the hostname from the incoming `Host` header (without port).

When `trustProxy` is enabled, Fastify will also check the `X-Forwarded-Host` header first.

js

```
fastify.get('/host', async (request) => {
  return { hostname: request.hostname };
});
```

**Output:**

json

```
{ "hostname": "example.com" }
```

**Key Points:**

- If the `Host` header is absent, the value may be an empty string or `undefined` depending on the Node.js version and client behavior.
- `X-Forwarded-Host` takes precedence over `Host` when `trustProxy` is active.

---

#### `request.protocol`

Returns either `'http'` or `'https'` depending on the connection type.

When `trustProxy` is enabled, Fastify checks the `X-Forwarded-Proto` header to determine the original protocol used by the client, which may differ from the protocol used between the proxy and the server.

js

```
fastify.get('/proto', async (request) => {
  return { protocol: request.protocol };
});
```

**Output** (client connected via HTTPS through a proxy doing HTTP internally):

json

```
{ "protocol": "https" }
```

---

#### `request.socket`

Provides direct access to the underlying `net.Socket` (or `tls.TLSSocket`) object from Node.js core. This gives low-level connection information independent of proxy headers.

js

```
fastify.get('/socket-info', async (request) => {
  const socket = request.socket;
  return {
    remoteAddress: socket.remoteAddress,
    remotePort:    socket.remotePort,
    localAddress:  socket.localAddress,
    localPort:     socket.localPort,
  };
});
```

**Key Points:**

- `socket.remoteAddress` is the actual TCP peer — the last-hop address, which is the proxy's IP if one is present.
- `socket.remotePort` is the ephemeral port of the peer.
- `socket.localAddress` and `socket.localPort` reflect the server-side binding.
- This does not change based on `trustProxy`; it always reflects the raw socket.

---

#### `trustProxy` Configuration — Summary

| Setting | Behavior |
| --- | --- |
| `false` (default) | Uses raw socket address; `request.ips` is `undefined` |
| `true` | Trusts all proxies; reads `X-Forwarded-*` headers |
| `'127.0.0.1'` | Trusts only the specified IP as a proxy |
| `['10.0.0.1', '10.0.0.2']` | Trusts only the listed IPs |
| CIDR string e.g. `'10.0.0.0/8'` | Trusts any IP in the subnet |

---

#### Security Considerations

**Key Points:**

- Never blindly trust `X-Forwarded-For` without configuring `trustProxy` to a specific set of known proxy IPs. Clients can spoof this header if the server accepts it unconditionally.
- Setting `trustProxy: true` in a deployment not behind a proxy exposes the server to IP spoofing via crafted headers. [Inference]
- Rate limiting, IP blocking, and audit logging based on `request.ip` are only reliable when `trustProxy` is configured correctly for the actual network topology.
- Behavior of IP resolution may vary depending on Fastify version and the underlying `proxy-addr` dependency. Always verify against the version in use.

---

#### Relationship Between Properties

NoYesYesNoYesNoIncoming RequesttrustProxy enabled?request.ip =socket.remoteAddressParse X-Forwarded-Forrequest.ip = leftmosttrusted IPrequest.ips = full arrayrequest.socket = rawNode.js sockettrustProxy enabled?request.protocol fromX-Forwarded-Protorequest.protocol from TLSdetectionrequest.hostname fromX-Forwarded-Hostrequest.hostname fromHost header

---
## HTTPS and HTTP/2 Setup

### Overview

Fastify supports HTTPS and HTTP/2 natively through Node.js's built-in `https`, `http2`, and `tls` modules. Both are configured at server creation time via options passed to the `fastify()` factory — not to `listen()`. Behavior may vary depending on Node.js version, TLS library version, and client capabilities.

---

### TLS Fundamentals Relevant to Fastify

Before configuring HTTPS or HTTP/2, the following TLS concepts are directly relevant:

| Concept | Description |
|---|---|
| `key` | Private key for the server certificate |
| `cert` | Public certificate (PEM format) |
| `ca` | Certificate Authority bundle (for mutual TLS) |
| `passphrase` | Passphrase for an encrypted private key |
| `requestCert` | If `true`, server requests a client certificate (mTLS) |
| `rejectUnauthorized` | If `true`, rejects clients with invalid certificates |

---

### Enabling HTTPS

Pass an `https` object to the Fastify factory containing TLS credentials. Fastify delegates this directly to Node.js's `https.createServer()`. [Inference — behavior is Node.js TLS behavior, not Fastify-specific]

**Example (reading from files):**

```js
const fs = require('fs')
const fastify = require('fastify')({
  https: {
    key: fs.readFileSync('./certs/server.key'),
    cert: fs.readFileSync('./certs/server.crt')
  }
})

fastify.get('/', async () => ({ secure: true }))

await fastify.listen({ port: 443, host: '0.0.0.0' })
```

**Key Points:**
- `fs.readFileSync` is acceptable at startup — this runs once before the event loop is busy
- The `https` option accepts any option that Node.js `tls.createServer()` accepts
- Self-signed certificates will cause browser warnings and client rejections unless the CA is trusted

---

### Generating Self-Signed Certificates for Development

For local development and testing, a self-signed certificate can be generated with OpenSSL:

```bash
openssl req -x509 -newkey rsa:4096 -keyout server.key \
  -out server.crt -days 365 -nodes \
  -subj "/CN=localhost"
```

Alternatively, the `@fastify/self-signed` or `selfsigned` npm packages can generate certificates programmatically:

```js
const selfsigned = require('selfsigned')
const attrs = [{ name: 'commonName', value: 'localhost' }]
const pems = selfsigned.generate(attrs, { days: 365 })

const fastify = require('fastify')({
  https: {
    key: pems.private,
    cert: pems.cert
  }
})
```

---

### Enabling HTTP/2

Set `http2: true` in the Fastify factory options. HTTP/2 can be used in two modes: **secure** (with TLS — the standard for browsers) and **insecure** (plaintext, also called h2c).

#### Secure HTTP/2 (h2 over TLS)

```js
const fs = require('fs')
const fastify = require('fastify')({
  http2: true,
  https: {
    key: fs.readFileSync('./certs/server.key'),
    cert: fs.readFileSync('./certs/server.crt'),
    allowHTTP1: true  // graceful fallback for HTTP/1.1 clients
  }
})

await fastify.listen({ port: 443, host: '0.0.0.0' })
```

**Key Points:**
- Browsers require TLS to use HTTP/2 — plaintext HTTP/2 is not supported by most browsers [Inference — per ALPN negotiation requirements]
- `allowHTTP1: true` enables compatibility with clients that do not support HTTP/2; they fall back to HTTP/1.1 on the same port
- The ALPN (Application-Layer Protocol Negotiation) extension handles protocol negotiation during the TLS handshake

#### Insecure HTTP/2 (h2c — cleartext)

```js
const fastify = require('fastify')({ http2: true })

await fastify.listen({ port: 3000 })
```

**Key Points:**
- h2c is useful for internal service-to-service communication where TLS termination is handled upstream (e.g., by a sidecar or load balancer)
- Browsers do not support h2c — this is only practical for non-browser clients [Inference]
- Some HTTP clients require explicit h2c upgrade negotiation; behavior varies by client

---

### HTTP/2 with `allowHTTP1`

The `allowHTTP1` flag is important for gradual migration and maximum compatibility:

```js
const fastify = require('fastify')({
  http2: true,
  https: {
    key: fs.readFileSync('./certs/server.key'),
    cert: fs.readFileSync('./certs/server.crt'),
    allowHTTP1: true
  }
})
```

| Client | Protocol Used |
|---|---|
| HTTP/2-capable (modern browser, curl/2) | HTTP/2 |
| HTTP/1.1-only client | HTTP/1.1 (fallback) |
| HTTP/1.1 client without `allowHTTP1` | Connection may be rejected [Inference] |

---

### Checking the Protocol in a Request

When `allowHTTP1: true` is set, you may want to inspect which protocol a given request used:

```js
fastify.get('/', async (request, reply) => {
  const proto = request.raw.httpVersion
  return { httpVersion: proto }
})
```

**Output (HTTP/2 client):**
```json
{ "httpVersion": "2.0" }
```

**Output (HTTP/1.1 client):**
```json
{ "httpVersion": "1.1" }
```

---

### Mutual TLS (mTLS)

Mutual TLS requires clients to present a certificate, which the server validates. This is common in service mesh and zero-trust architectures.

```js
const fastify = require('fastify')({
  https: {
    key: fs.readFileSync('./certs/server.key'),
    cert: fs.readFileSync('./certs/server.crt'),
    ca: fs.readFileSync('./certs/ca.crt'),
    requestCert: true,
    rejectUnauthorized: true
  }
})
```

**Key Points:**
- `requestCert: true` instructs the server to request a certificate from the client during the TLS handshake
- `rejectUnauthorized: true` rejects connections from clients that do not present a valid certificate signed by the specified CA
- Setting `rejectUnauthorized: false` allows the connection but the certificate is still accessible via `request.socket.getPeerCertificate()` for manual validation [Inference]

---

### Accessing the Client Certificate

When mTLS is configured, the peer certificate is accessible on the raw socket:

```js
fastify.get('/whoami', async (request, reply) => {
  const cert = request.socket.getPeerCertificate()
  if (!cert || !Object.keys(cert).length) {
    return reply.code(401).send({ error: 'No client certificate' })
  }
  return { subject: cert.subject }
})
```

---

### SNI — Server Name Indication

For servers hosting multiple domains on one IP, SNI allows different TLS certificates per hostname. This is configured via the `SNICallback` option passed through the `https` object:

```js
const fastify = require('fastify')({
  https: {
    SNICallback: (serverName, callback) => {
      const ctx = getCertContextForHost(serverName) // your lookup logic
      callback(null, ctx)
    }
  }
})
```

**Key Points:**
- `SNICallback` receives the hostname as presented by the client before certificate exchange
- The callback must provide a `tls.SecureContext` object (created via `tls.createSecureContext()`)
- This pattern is foundational for virtual hosting with TLS [Inference]

---

### Using `@fastify/secure-session` vs TLS

These are distinct concerns and are sometimes confused:

| Concern | Tool |
|---|---|
| Encrypting data in transit | TLS (`https` option) |
| Encrypting session cookies | `@fastify/secure-session` |
| Authenticating clients | mTLS (`requestCert`) |
| Authenticating users | `@fastify/jwt`, `@fastify/auth` |

---

### TLS Best Practices

**Key Points:**
- Disable SSLv2, SSLv3, TLSv1.0, and TLSv1.1 — use `minVersion: 'TLSv1.2'` or `'TLSv1.3'`
- Specify a strong cipher suite via the `ciphers` option when security requirements demand it
- Rotate certificates before expiry — expired certificates cause hard client failures
- In production, prefer certificates from a trusted CA (e.g., Let's Encrypt) over self-signed certificates
- Do not commit private keys to version control

**Example (enforcing minimum TLS version):**

```js
const fastify = require('fastify')({
  https: {
    key: fs.readFileSync('./certs/server.key'),
    cert: fs.readFileSync('./certs/server.crt'),
    minVersion: 'TLSv1.2'
  }
})
```

---

### HTTP/2 Push (Server Push)

HTTP/2 server push allows the server to proactively send resources to the client. In Fastify, this is accessible via the raw HTTP/2 stream:

```js
fastify.get('/', async (request, reply) => {
  const stream = reply.raw
  if (stream.pushAllowed) {
    stream.pushStream({ ':path': '/styles.css' }, (err, pushStream) => {
      if (!err) {
        pushStream.respond({ ':status': 200, 'content-type': 'text/css' })
        pushStream.end('body { margin: 0 }')
      }
    })
  }
  return reply.sendFile('index.html')
})
```

**Key Points:**
- `pushAllowed` checks whether the client supports and accepts server push
- Server push is largely deprecated in favor of HTTP `103 Early Hints` and `Link` preload headers in modern stacks [Unverified — verify against your target client ecosystem]
- Misusing server push can harm performance rather than improve it [Inference]

---

### Architecture Diagram

<svg viewBox="0 0 660 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="660" height="420" fill="#1e1e2e" rx="12"/>
  <text x="330" y="32" text-anchor="middle" fill="#cdd6f4" font-size="14" font-weight="bold">HTTPS / HTTP2 — Connection Modes</text>

  <!-- CLIENT -->
  <rect x="30" y="60" width="120" height="44" rx="6" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/>
  <text x="90" y="78" text-anchor="middle" fill="#89b4fa">Browser /</text>
  <text x="90" y="95" text-anchor="middle" fill="#89b4fa">HTTP/2 Client</text>

  <!-- HTTP1 CLIENT -->
  <rect x="30" y="200" width="120" height="44" rx="6" fill="#313244" stroke="#fab387" stroke-width="1.5"/>
  <text x="90" y="218" text-anchor="middle" fill="#fab387">HTTP/1.1</text>
  <text x="90" y="235" text-anchor="middle" fill="#fab387">Client</text>

  <!-- SERVICE CLIENT -->
  <rect x="30" y="320" width="120" height="44" rx="6" fill="#313244" stroke="#a6e3a1" stroke-width="1.5"/>
  <text x="90" y="338" text-anchor="middle" fill="#a6e3a1">Internal</text>
  <text x="90" y="355" text-anchor="middle" fill="#a6e3a1">Service (h2c)</text>

  <!-- TLS BOX -->
  <rect x="230" y="100" width="160" height="44" rx="6" fill="#313244" stroke="#cba6f7" stroke-width="1.5"/>
  <text x="310" y="118" text-anchor="middle" fill="#cba6f7">TLS Handshake</text>
  <text x="310" y="135" text-anchor="middle" fill="#cba6f7">ALPN Negotiation</text>

  <!-- allowHTTP1 BOX -->
  <rect x="230" y="210" width="160" height="44" rx="6" fill="#313244" stroke="#fab387" stroke-width="1.5"/>
  <text x="310" y="228" text-anchor="middle" fill="#fab387">TLS Handshake</text>
  <text x="310" y="245" text-anchor="middle" fill="#fab387">allowHTTP1 fallback</text>

  <!-- h2c BOX -->
  <rect x="230" y="320" width="160" height="44" rx="6" fill="#313244" stroke="#a6e3a1" stroke-width="1.5"/>
  <text x="310" y="338" text-anchor="middle" fill="#a6e3a1">Plaintext</text>
  <text x="310" y="355" text-anchor="middle" fill="#a6e3a1">HTTP/2 (h2c)</text>

  <!-- FASTIFY -->
  <rect x="480" y="180" width="130" height="120" rx="8" fill="#181825" stroke="#cdd6f4" stroke-width="2"/>
  <text x="545" y="230" text-anchor="middle" fill="#cdd6f4" font-size="13" font-weight="bold">Fastify</text>
  <text x="545" y="250" text-anchor="middle" fill="#6c7086" font-size="11">http2: true</text>
  <text x="545" y="266" text-anchor="middle" fill="#6c7086" font-size="11">https: {...}</text>
  <text x="545" y="282" text-anchor="middle" fill="#6c7086" font-size="11">allowHTTP1</text>

  <!-- Arrows: client to TLS -->
  <line x1="150" y1="82" x2="228" y2="118" stroke="#89b4fa" stroke-width="1.5" marker-end="url(#ab)"/>
  <text x="185" y="93" fill="#89b4fa" font-size="10">h2+TLS</text>

  <line x1="150" y1="222" x2="228" y2="230" stroke="#fab387" stroke-width="1.5" marker-end="url(#ao)"/>
  <text x="162" y="218" fill="#fab387" font-size="10">HTTP/1.1</text>

  <line x1="150" y1="340" x2="228" y2="340" stroke="#a6e3a1" stroke-width="1.5" marker-end="url(#ag)"/>
  <text x="162" y="334" fill="#a6e3a1" font-size="10">h2c</text>

  <!-- Arrows: boxes to Fastify -->
  <line x1="390" y1="122" x2="478" y2="215" stroke="#cba6f7" stroke-width="1.5" marker-end="url(#ap)"/>
  <line x1="390" y1="232" x2="478" y2="240" stroke="#fab387" stroke-width="1.5" marker-end="url(#ao)"/>
  <line x1="390" y1="340" x2="478" y2="270" stroke="#a6e3a1" stroke-width="1.5" marker-end="url(#ag)"/>

  <defs>
    <marker id="ab" markerWidth="8" markerHeight="8" refX="4" refY="3" orient="auto"><path d="M0,0 L0,6 L7,3 z" fill="#89b4fa"/></marker>
    <marker id="ao" markerWidth="8" markerHeight="8" refX="4" refY="3" orient="auto"><path d="M0,0 L0,6 L7,3 z" fill="#fab387"/></marker>
    <marker id="ag" markerWidth="8" markerHeight="8" refX="4" refY="3" orient="auto"><path d="M0,0 L0,6 L7,3 z" fill="#a6e3a1"/></marker>
    <marker id="ap" markerWidth="8" markerHeight="8" refX="4" refY="3" orient="auto"><path d="M0,0 L0,6 L7,3 z" fill="#cba6f7"/></marker>
  </defs>
</svg>

---

### Configuration Summary

| Goal | Factory Options |
|---|---|
| HTTPS only | `{ https: { key, cert } }` |
| HTTP/2 + TLS (browsers) | `{ http2: true, https: { key, cert, allowHTTP1: true } }` |
| HTTP/2 cleartext (h2c) | `{ http2: true }` |
| Mutual TLS | `{ https: { key, cert, ca, requestCert: true, rejectUnauthorized: true } }` |
| Enforce TLS version | `{ https: { key, cert, minVersion: 'TLSv1.2' } }` |
| SNI multi-domain | `{ https: { SNICallback: fn } }` |

---

**Conclusion:** HTTPS and HTTP/2 are configured at the Fastify factory level, not at `listen()`. HTTPS delegates directly to Node.js TLS, giving access to the full range of TLS options. HTTP/2 can be used securely with TLS (standard for browsers) or as h2c for internal service communication. Setting `allowHTTP1: true` provides safe fallback behavior during migration or for mixed client environments.
## TLS Configuration Hardening

TLS configuration in a Fastify deployment spans two distinct boundaries: the TLS termination point (which may be Fastify itself, a reverse proxy, or a cloud load balancer) and the TLS settings applied at that point. Hardening means reducing the negotiable surface — disabling weak protocol versions, restricting cipher suites, enforcing certificate validation, and configuring operational controls like HSTS and OCSP stapling. This document covers all of these across Fastify-native TLS and proxy-terminated TLS deployments.

---

### TLS Termination Architecture — Where TLS Lives

Before configuring TLS, the termination point must be established. Fastify supports three architectures:

**Architecture 1 — Fastify terminates TLS directly:**
```
Client ──[TLS]──► Fastify (Node.js tls.Server)
```
TLS configuration lives in Fastify's server options. Full control over cipher suites, protocol versions, and certificate handling.

**Architecture 2 — Reverse proxy terminates TLS, plain HTTP to Fastify:**
```
Client ──[TLS]──► nginx / Caddy / HAProxy ──[HTTP]──► Fastify
```
TLS configuration lives entirely in the proxy. Fastify sees plain HTTP. Fastify must trust the proxy for forwarded headers (`X-Forwarded-For`, `X-Forwarded-Proto`).

**Architecture 3 — Load balancer terminates TLS (cloud deployments):**
```
Client ──[TLS]──► AWS ALB / GCP LB / Cloudflare ──[HTTP or TLS]──► Fastify
```
TLS configuration is managed by the cloud provider. Fastify may receive plain HTTP or re-encrypted TLS from the load balancer.

**Key Points:**
- Architecture 1 gives the most control and is appropriate for internal services, microservice meshes, and deployments where a proxy layer is not present.
- Architecture 2 is the most common production pattern — nginx or Caddy handles TLS, Fastify focuses on application logic.
- In Architectures 2 and 3, hardening Fastify's TLS settings has no effect — the configuration must be applied to the proxy or load balancer.
- [Inference] Running Fastify behind a proxy without configuring `trustProxy` correctly causes IP-related features (rate limiting, logging, geolocation) to see the proxy's IP rather than the client's — not a TLS concern but a related configuration requirement.

---

### Fastify-Native TLS — Basic Setup

Fastify exposes Node.js's `tls.createServer` options directly via the `https` option:

```typescript
import Fastify from 'fastify'
import fs from 'fs'
import path from 'path'

const fastify = Fastify({
  https: {
    key:  fs.readFileSync(path.join(__dirname, '../certs/server.key')),
    cert: fs.readFileSync(path.join(__dirname, '../certs/server.crt')),
    ca:   fs.readFileSync(path.join(__dirname, '../certs/ca.crt')) // optional: for client cert verification
  },
  logger: true
})

await fastify.listen({ port: 443, host: '0.0.0.0' })
```

This uses Node.js defaults for protocol versions and cipher suites. The following sections harden those defaults.

---

### Protocol Version Restriction

TLS 1.0 and TLS 1.1 are deprecated and have known weaknesses (POODLE, BEAST). TLS 1.2 is the minimum acceptable version. TLS 1.3 is preferred where client compatibility permits.

```typescript
const fastify = Fastify({
  https: {
    key:  fs.readFileSync('./certs/server.key'),
    cert: fs.readFileSync('./certs/server.crt'),

    // Enforce TLS 1.2 minimum
    minVersion: 'TLSv1.2',

    // TLS 1.3 is the maximum Node.js supports — no explicit maxVersion needed
    // maxVersion: 'TLSv1.3' // optional, this is the Node.js default ceiling
  }
})
```

**Key Points:**
- `minVersion: 'TLSv1.2'` is the current industry minimum — PCI DSS 3.2.1 and NIST SP 800-52 Rev 2 both mandate TLS 1.2 or higher. [Unverified: current compliance standard version requirements — verify against the applicable standard version in your regulatory context.]
- `minVersion: 'TLSv1.3'` is more restrictive and may exclude older clients. [Inference] TLS 1.3 only is viable for internal services and APIs where client compatibility is controlled; it may be too restrictive for public-facing APIs serving heterogeneous clients.
- Node.js's TLS implementation uses OpenSSL — the actual protocol availability depends on the OpenSSL version bundled with the Node.js build. [Unverified: specific OpenSSL versions per Node.js release — verify in the Node.js release notes for the version in use.]

---

### Cipher Suite Restriction

Cipher suites govern the cryptographic algorithms used for key exchange, authentication, encryption, and integrity verification. Weak suites (export-grade, RC4, 3DES, NULL) must be explicitly excluded.

```typescript
const fastify = Fastify({
  https: {
    key:  fs.readFileSync('./certs/server.key'),
    cert: fs.readFileSync('./certs/server.crt'),
    minVersion: 'TLSv1.2',

    // Explicit cipher suite allowlist for TLS 1.2
    // TLS 1.3 cipher suites are not configurable via this option in Node.js —
    // they are always the TLS 1.3 default set
    ciphers: [
      // TLS 1.3 suites (included by default regardless — listed for documentation)
      'TLS_AES_256_GCM_SHA384',
      'TLS_CHACHA20_POLY1305_SHA256',
      'TLS_AES_128_GCM_SHA256',

      // TLS 1.2 — ECDHE with AES-GCM (forward secrecy, AEAD)
      'ECDHE-ECDSA-AES256-GCM-SHA384',
      'ECDHE-RSA-AES256-GCM-SHA384',
      'ECDHE-ECDSA-AES128-GCM-SHA256',
      'ECDHE-RSA-AES128-GCM-SHA256',
      'ECDHE-ECDSA-CHACHA20-POLY1305',
      'ECDHE-RSA-CHACHA20-POLY1305',

      // DHE with AES-GCM (forward secrecy, AEAD) — for RSA cert compatibility
      'DHE-RSA-AES256-GCM-SHA384',
      'DHE-RSA-AES128-GCM-SHA256'
    ].join(':'),

    // Prefer server cipher suite order over client's
    honorCipherOrder: true
  }
})
```

**Key Points:**
- All listed suites provide forward secrecy (ECDHE or DHE key exchange) — a compromised private key does not decrypt previously captured sessions.
- All listed suites use AEAD modes (GCM, CHACHA20-POLY1305) — they provide authenticated encryption, preventing padding oracle attacks.
- `honorCipherOrder: true` ensures the server's preferred (stronger) suites are selected, not the client's potentially weaker preference.
- TLS 1.3 cipher suites are fixed by the specification and cannot be restricted via Node.js's `ciphers` option — [Unverified: this behavior may vary by Node.js version; verify in the `tls` module documentation.]
- Excluding `CBC` suites eliminates LUCKY13 and BEAST attack vectors.
- [Inference] Overly restrictive cipher lists may cause handshake failures with legitimate older clients — test against the actual client population before deploying.

---

### HTTP/2 with TLS

Fastify supports HTTP/2, which requires TLS in browser contexts (h2 is TLS-only; h2c is cleartext but browsers do not support it):

```typescript
import Fastify from 'fastify'
import fs from 'fs'

const fastify = Fastify({
  http2: true,
  https: {
    allowHTTP1: true, // allow HTTP/1.1 fallback for clients that do not support HTTP/2
    key:  fs.readFileSync('./certs/server.key'),
    cert: fs.readFileSync('./certs/server.crt'),
    minVersion: 'TLSv1.2',
    ciphers: [
      'TLS_AES_256_GCM_SHA384',
      'TLS_CHACHA20_POLY1305_SHA256',
      'TLS_AES_128_GCM_SHA256',
      'ECDHE-ECDSA-AES256-GCM-SHA384',
      'ECDHE-RSA-AES256-GCM-SHA384',
      'ECDHE-ECDSA-CHACHA20-POLY1305',
      'ECDHE-RSA-CHACHA20-POLY1305'
    ].join(':'),
    honorCipherOrder: true
  }
})
```

**Key Points:**
- HTTP/2 uses ALPN (Application-Layer Protocol Negotiation) to negotiate the protocol during the TLS handshake — no additional configuration is needed; Node.js handles ALPN automatically when `http2: true` is set.
- `allowHTTP1: true` enables fallback for clients that do not support HTTP/2 — set to `false` for HTTP/2-only services.
- [Inference] HTTP/2 requires ALPN, which requires TLS — `http2: true` without `https` options results in h2c (cleartext), which browsers reject. Verify your deployment context before using h2c.

---

### Mutual TLS (mTLS) — Client Certificate Authentication

mTLS requires the client to present a certificate signed by a trusted CA. It is used for service-to-service authentication in internal APIs and zero-trust architectures.

```typescript
const fastify = Fastify({
  https: {
    key:                fs.readFileSync('./certs/server.key'),
    cert:               fs.readFileSync('./certs/server.crt'),
    ca:                 fs.readFileSync('./certs/client-ca.crt'), // CA that signs client certs
    requestCert:        true,  // request client certificate during handshake
    rejectUnauthorized: true,  // reject clients without a valid cert
    minVersion:         'TLSv1.2'
  }
})

// Access client certificate in route handlers
fastify.get('/internal/data', async (request, reply) => {
  const socket = request.raw.socket as import('tls').TLSSocket
  const cert = socket.getPeerCertificate()

  if (!cert || !Object.keys(cert).length) {
    return reply.status(401).send({ error: 'Client certificate required' })
  }

  // cert.subject.CN — common name from client certificate
  // cert.valid_to — expiry date
  // cert.fingerprint — certificate fingerprint

  request.log.info({ certCN: cert.subject?.CN }, 'Authenticated via mTLS')
  return { authenticated: true, identity: cert.subject?.CN }
})
```

**Key Points:**
- `requestCert: true` + `rejectUnauthorized: true` enforces mTLS — connections without a valid client cert are rejected at the TLS layer.
- `rejectUnauthorized: false` with `requestCert: true` allows connections without a cert but makes the cert available if provided — useful for optional client cert scenarios.
- [Inference] The `getPeerCertificate()` call returns an empty object `{}` when no certificate was presented — the guard `!Object.keys(cert).length` handles this case.
- mTLS terminates at the TLS layer — if TLS is terminated at a proxy, the proxy must forward client certificate information to Fastify via headers (e.g., `X-Client-Cert`). The proxy becomes the mTLS enforcement point.

---

### HSTS — HTTP Strict Transport Security

HSTS instructs browsers to always use HTTPS for the domain, even if the user types `http://`:

```typescript
import helmet from '@fastify/helmet'

await fastify.register(helmet, {
  hsts: {
    maxAge:            31536000, // 1 year in seconds — minimum for HSTS preload
    includeSubDomains: true,     // applies HSTS to all subdomains
    preload:           true      // signals intent to be included in browser preload lists
  }
})
```

**Resulting header:**
```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

**Key Points:**
- `maxAge: 31536000` (1 year) is the minimum required by the HSTS preload list at hstspreload.org. [Unverified: current minimum requirements — verify at hstspreload.org before submission.]
- `includeSubDomains` applies the policy to all subdomains — ensure all subdomains serve valid HTTPS before enabling this.
- `preload` is a declaration of intent — the domain must be separately submitted to the HSTS preload list. The header alone does not add it to the list.
- [Inference] Setting a long `maxAge` and then reverting to HTTP is operationally complex — browsers will refuse HTTP connections for the full `maxAge` duration. Start with a short `maxAge` during testing and increase once HTTPS is stable.
- HSTS only applies when delivered over HTTPS — a browser that has never visited the site via HTTPS has no HSTS policy cached. The first visit is not protected by HSTS; it is protected by a redirect from HTTP to HTTPS.

---

### Redirecting HTTP to HTTPS in Fastify

When Fastify terminates TLS directly and also listens on port 80:

```typescript
import Fastify from 'fastify'
import fs from 'fs'

// HTTP server — redirect only
const httpApp = Fastify({ logger: false })

httpApp.addHook('onRequest', async (request, reply) => {
  const host = request.hostname
  const url  = request.url
  return reply
    .status(301)
    .redirect(`https://${host}${url}`)
})

await httpApp.listen({ port: 80, host: '0.0.0.0' })

// HTTPS server — application
const httpsApp = Fastify({
  https: {
    key:        fs.readFileSync('./certs/server.key'),
    cert:       fs.readFileSync('./certs/server.crt'),
    minVersion: 'TLSv1.2'
  },
  logger: true
})

// Register routes on httpsApp
await httpsApp.listen({ port: 443, host: '0.0.0.0' })
```

**Key Points:**
- Use `301` (permanent redirect) rather than `302` (temporary) — browsers and search engines cache permanent redirects, reducing subsequent HTTP requests.
- [Inference] In most production deployments, the HTTP-to-HTTPS redirect is handled at the proxy or load balancer level — running two Fastify instances for this purpose is only appropriate when Fastify terminates TLS directly.

---

### `serverFactory` with External TLS Configuration

For advanced TLS control using `serverFactory`:

```typescript
import https from 'https'
import tls from 'tls'
import Fastify, { FastifyServerFactory } from 'fastify'
import fs from 'fs'

const serverFactory: FastifyServerFactory = (handler) => {
  return https.createServer(
    {
      key:  fs.readFileSync('./certs/server.key'),
      cert: fs.readFileSync('./certs/server.crt'),

      minVersion:       'TLSv1.2',
      honorCipherOrder: true,

      ciphers: [
        'TLS_AES_256_GCM_SHA384',
        'TLS_CHACHA20_POLY1305_SHA256',
        'TLS_AES_128_GCM_SHA256',
        'ECDHE-ECDSA-AES256-GCM-SHA384',
        'ECDHE-RSA-AES256-GCM-SHA384',
        'ECDHE-ECDSA-CHACHA20-POLY1305',
        'ECDHE-RSA-CHACHA20-POLY1305'
      ].join(':'),

      // Session resumption — reduces handshake overhead for returning clients
      sessionTimeout: 300, // seconds

      // ECDH curve selection — P-256 is widely supported and secure
      ecdhCurve: 'P-256:P-384'
    },
    handler
  )
}

const fastify = Fastify({ serverFactory, logger: true })
```

---

### Certificate Management

**Self-signed certificates (development only):**

```bash
# Generate self-signed cert for development
openssl req -x509 -newkey rsa:4096 -keyout server.key -out server.crt \
  -days 365 -nodes -subj '/CN=localhost'
```

**Let's Encrypt via ACME (production):**

```bash
# certbot — automatic cert issuance and renewal
certbot certonly --standalone -d example.com -d www.example.com

# Certs are placed at:
# /etc/letsencrypt/live/example.com/fullchain.pem
# /etc/letsencrypt/live/example.com/privkey.pem
```

```typescript
const fastify = Fastify({
  https: {
    cert: fs.readFileSync('/etc/letsencrypt/live/example.com/fullchain.pem'),
    key:  fs.readFileSync('/etc/letsencrypt/live/example.com/privkey.pem'),
    minVersion: 'TLSv1.2'
  }
})
```

**Certificate reload without restart:**

```typescript
// Watch for cert renewal and reload without dropping connections
import chokidar from 'chokidar'

let currentCreds = tls.createSecureContext({
  key:  fs.readFileSync('./certs/server.key'),
  cert: fs.readFileSync('./certs/server.crt')
})

chokidar.watch('./certs').on('change', () => {
  try {
    currentCreds = tls.createSecureContext({
      key:  fs.readFileSync('./certs/server.key'),
      cert: fs.readFileSync('./certs/server.crt')
    })
    fastify.log.info('TLS certificates reloaded')
  } catch (err) {
    fastify.log.error({ err }, 'Failed to reload TLS certificates')
  }
})

// SNICallback enables dynamic cert selection per hostname
const serverFactory: FastifyServerFactory = (handler) => {
  return https.createServer(
    {
      SNICallback: (servername, cb) => {
        cb(null, currentCreds) // return current credentials for all hostnames
      }
    },
    handler
  )
}
```

[Inference] The `SNICallback` approach for cert hot-reload is a valid pattern used in production — behavior depends on the Node.js version's TLS implementation. Test cert reload under load before relying on it in production.

---

### nginx TLS Hardening (Proxy Termination)

When nginx terminates TLS and proxies to Fastify, TLS hardening belongs in the nginx configuration:

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    ssl_certificate     /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    # Protocol restriction
    ssl_protocols TLSv1.2 TLSv1.3;

    # Cipher suite restriction — TLS 1.2 suites (TLS 1.3 suites are not configurable)
    ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers on;

    # DH parameters for DHE cipher suites
    ssl_dhparam /etc/nginx/dhparam.pem; # generated: openssl dhparam -out dhparam.pem 4096

    # OCSP stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/letsencrypt/live/example.com/chain.pem;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;

    # Session configuration
    ssl_session_cache   shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_session_tickets off; # disable session tickets — forward secrecy concern

    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

    location / {
        proxy_pass         http://127.0.0.1:3000;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name example.com;
    return 301 https://$host$request_uri;
}
```

**Key Points:**
- `ssl_session_tickets off` — session tickets are encrypted with a ticket key that must be rotated regularly for forward secrecy. Disabling them avoids the operational complexity of ticket key rotation; session cache provides resumption instead.
- `ssl_dhparam` with a 4096-bit DH parameter strengthens DHE cipher suites. Generate once: `openssl dhparam -out dhparam.pem 4096` (this takes several minutes).
- OCSP stapling reduces client latency by including the certificate revocation status in the TLS handshake — the server fetches and caches the OCSP response rather than the client having to query the CA.
- [Unverified] Specific nginx directive syntax and version compatibility — verify against the nginx version in deployment.

---

### Fastify `trustProxy` Configuration

When TLS is terminated upstream, Fastify must be configured to trust forwarded headers:

```typescript
const fastify = Fastify({
  logger: true,
  trustProxy: true // trust X-Forwarded-For, X-Forwarded-Proto from any proxy

  // More restrictive — trust only a specific proxy IP
  // trustProxy: '127.0.0.1'

  // Trust a CIDR range (e.g., internal network)
  // trustProxy: '10.0.0.0/8'
})

// After trustProxy is set:
fastify.get('/info', async (request) => ({
  ip:       request.ip,       // real client IP from X-Forwarded-For
  protocol: request.protocol  // 'https' from X-Forwarded-Proto
}))
```

**Key Points:**
- `trustProxy: true` is appropriate when Fastify is behind a controlled proxy — not when Fastify is directly internet-facing, as clients could spoof `X-Forwarded-For`.
- [Inference] Setting `trustProxy` to a specific IP or CIDR range is more secure than `true` — it restricts which upstream sources Fastify trusts for forwarded headers.
- `request.protocol` returning `'https'` when `X-Forwarded-Proto: https` is set by the proxy allows Fastify route handlers to enforce HTTPS at the application level even though Fastify itself receives plain HTTP.

---

### TLS Hardening Checklist

| Control | Fastify-native | nginx proxy |
|---|---|---|
| TLS 1.0 / 1.1 disabled | `minVersion: 'TLSv1.2'` | `ssl_protocols TLSv1.2 TLSv1.3` |
| Weak cipher suites disabled | `ciphers` allowlist | `ssl_ciphers` allowlist |
| Forward secrecy | ECDHE/DHE suites only | ECDHE/DHE suites only |
| Server cipher preference | `honorCipherOrder: true` | `ssl_prefer_server_ciphers on` |
| HSTS | `@fastify/helmet` hsts | `add_header Strict-Transport-Security` |
| HTTP → HTTPS redirect | Separate HTTP Fastify instance | `return 301 https://` |
| OCSP stapling | Not natively supported in Node.js | `ssl_stapling on` |
| Session tickets disabled | Via `serverFactory` options | `ssl_session_tickets off` |
| mTLS | `requestCert` + `rejectUnauthorized` | `ssl_verify_client on` |
| Certificate auto-renewal | External (certbot) | External (certbot) |
| `trustProxy` set | When behind proxy | N/A |

[Unverified] Node.js native OCSP stapling support — verify against current Node.js `tls` module documentation. If OCSP stapling is required, proxy-terminated TLS (nginx, Caddy) is the more reliable path.

---

### Testing TLS Configuration

```bash
# Test with openssl — inspect negotiated protocol and cipher
openssl s_client -connect example.com:443 -tls1_2
openssl s_client -connect example.com:443 -tls1_3

# Attempt a weak protocol — should fail with a hardened config
openssl s_client -connect example.com:443 -tls1_1

# testssl.sh — comprehensive TLS audit tool
docker run --rm drwetter/testssl.sh example.com

# sslyze — Python-based TLS scanner
pip install sslyze
python -m sslyze example.com:443

# Qualys SSL Labs — web-based grading (for public endpoints)
# https://www.ssllabs.com/ssltest/
```

**Key Points:**
- `testssl.sh` and `sslyze` run locally — appropriate for internal endpoints not accessible to SSL Labs.
- SSL Labs provides a letter grade (A+ through F) and detailed findings — useful for public-facing endpoints and compliance documentation.
- Test after every certificate renewal and configuration change.

---

**Related Topics:**
- `@fastify/helmet` — full security header configuration including CSP alongside HSTS
- HTTP/2 push and server push configuration in Fastify
- Certificate management with cert-manager in Kubernetes
- Caddy as a TLS-terminating reverse proxy — automatic HTTPS via ACME
- mTLS in service meshes — Istio and Linkerd sidecar-based mTLS
- OCSP stapling implementation options for Node.js
- Session ticket key rotation for forward secrecy maintenance
- `@fastify/rate-limit` — reducing TLS handshake abuse via connection rate limiting
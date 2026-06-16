## Content Security Policy in Fastify

Content Security Policy (CSP) is an HTTP response header that instructs browsers on which sources are permitted to load resources — scripts, styles, images, fonts, frames, and more. It is one of the most effective browser-enforced mitigations against Cross-Site Scripting (XSS) and data injection attacks. In Fastify, CSP is primarily managed through @fastify/helmet.

---

### What CSP Does

Without CSP, a browser will load and execute any resource referenced by a page, including injected malicious scripts. CSP narrows this by declaring an explicit allowlist of trusted origins and behaviors.

NoYesYesNoYesNoBrowser receivesresponseCSP header present?Load all resources freelyParse CSP directivesResource origin inallowlist?Load resourceBlock resourcereport-uri or report-toset?Send violation reportSilent block

---

### CSP Header Structure

A CSP header is a semicolon-separated list of directives. Each directive names a resource type followed by one or more source expressions.

```
Content-Security-Policy: default-src 'self'; script-src 'self' cdn.example.com; img-src *; report-uri /csp-report
```

**Anatomy of a directive:**

```
script-src  'self'  https://cdn.example.com  'nonce-abc123'
    │          │              │                     │
    │       keyword        origin               nonce value
    │
  resource type
```

---

### Enabling CSP via @fastify/helmet

@fastify/helmet enables CSP by default. The default policy is intentionally restrictive.

js

```js
import Fastify from 'fastify'
import helmet from '@fastify/helmet'

const fastify = Fastify()

await fastify.register(helmet)
// Content-Security-Policy header is now applied to all responses
```

To customize directives, pass a `contentSecurityPolicy` configuration object:

js

```js
await fastify.register(helmet, {
  contentSecurityPolicy: {
    useDefaults: true,    // Merge with helmet's safe defaults
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", 'cdn.example.com'],
      styleSrc: ["'self'", 'fonts.googleapis.com'],
      fontSrc: ["'self'", 'fonts.gstatic.com'],
      imgSrc: ["'self'", 'data:', 'img.example.com'],
      connectSrc: ["'self'", 'api.example.com'],
      objectSrc: ["'none'"],
      frameAncestors: ["'none'"],
      upgradeInsecureRequests: [],
    },
  },
})
```

**Key Points:**

- Directive names in helmet's config use **camelCase** (`scriptSrc`), which maps to the hyphenated header form (`script-src`).
- String values that require quotes in the actual header (like `'self'`, `'none'`, `'unsafe-inline'`) must include the single quotes inside the JavaScript string.
- `useDefaults: true` merges your directives with helmet's baseline — omitting a directive does not remove it from the header. Set `useDefaults: false` for full manual control.

---

### Directive Reference

#### Fetch Directives

These control where resources of each type may be loaded from.

| Directive | Controls |
| --- | --- |
| `default-src` | Fallback for all resource types not explicitly listed |
| `script-src` | JavaScript sources |
| `style-src` | CSS sources |
| `img-src` | Image sources |
| `font-src` | Web font sources |
| `connect-src` | XHR, fetch, WebSocket, EventSource destinations |
| `media-src` | `<audio>` and `<video>` sources |
| `object-src` | `<object>`, `<embed>`, `<applet>` sources |
| `frame-src` | Sources for `<iframe>` and `<frame>` |
| `worker-src` | Web Worker, SharedWorker, ServiceWorker scripts |
| `manifest-src` | Web app manifest files |
| `prefetch-src` | Prefetch and prerender requests [Inference: deprecated in some specs] |
| `child-src` | Fallback for `frame-src` and `worker-src` |

#### Document Directives

| Directive | Effect |
| --- | --- |
| `base-uri` | Restricts values in `<base href>` |
| `sandbox` | Applies sandbox restrictions as if in an `<iframe sandbox>` |

#### Navigation Directives

| Directive | Effect |
| --- | --- |
| `form-action` | Restricts where forms may submit |
| `frame-ancestors` | Controls which origins may embed this page (replaces `X-Frame-Options`) |
| `navigate-to` | Restricts where the page may navigate [Inference: limited browser support as of late 2024] |

#### Reporting Directives

| Directive | Effect |
| --- | --- |
| `report-uri` | URL to POST violation reports (deprecated but widely supported) |
| `report-to` | Endpoint group name for the Reporting API |

---

### Source Expressions

Source expressions define what is allowed within each directive.

| Expression | Meaning |
| --- | --- |
| `'self'` | Same origin (scheme + host + port) |
| `'none'` | Nothing allowed |
| `*` | Any origin (wildcard — use sparingly) |
| `https:` | Any HTTPS origin |
| `https://example.com` | Specific origin |
| `https://*.example.com` | Wildcard subdomain |
| `'unsafe-inline'` | Allows inline scripts/styles (weakens CSP significantly) |
| `'unsafe-eval'` | Allows `eval()` and similar (weakens CSP significantly) |
| `'nonce-<base64>'` | Allows specific inline element by nonce |
| `'sha256-<base64>'` | Allows inline element matching this hash |
| `'strict-dynamic'` | Trusts scripts loaded by a trusted (nonced) script |
| `'unsafe-hashes'` | Allows hashes on event handlers and `style` attributes |
| `'wasm-unsafe-eval'` | Allows WebAssembly compilation |

---

### Nonces

A nonce (number used once) is a cryptographically random value generated per response. It is included in the CSP header and as an attribute on trusted inline `<script>` or `<style>` tags. The browser only executes inline elements whose nonce matches the header.

This allows specific inline scripts without `'unsafe-inline'`.

#### Nonce Generation in Fastify

@fastify/helmet can generate nonces automatically:

js

```js
await fastify.register(helmet, {
  contentSecurityPolicy: {
    useDefaults: true,
    directives: {
      scriptSrc: [
        "'self'",
        // Function form: called per-request, receives (req, res)
        (req, res) => `'nonce-${res.locals?.nonce ?? ''}'`,
      ],
    },
  },
})
```

For reliable nonce access, generate and attach the nonce manually in a hook:

js

```js
import { randomBytes } from 'node:crypto'

fastify.addHook('onRequest', (request, reply, done) => {
  reply.locals = reply.locals ?? {}
  reply.locals.nonce = randomBytes(16).toString('base64')
  done()
})

await fastify.register(helmet, {
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: [
        "'self'",
        (req, res) => `'nonce-${res.locals.nonce}'`,
      ],
      styleSrc: [
        "'self'",
        (req, res) => `'nonce-${res.locals.nonce}'`,
      ],
    },
  },
})

fastify.get('/page', async (request, reply) => {
  const nonce = reply.locals.nonce
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style nonce="${nonce}">body { color: navy; }</style>
    </head>
    <body>
      <script nonce="${nonce}">console.log('Allowed by nonce')</script>
    </body>
    </html>
  `
  return reply.type('text/html').send(html)
})
```

**Key Points:**

- Nonces must be unique per response — reusing nonces degrades security.
- `randomBytes(16).toString('base64')` produces a suitably random 16-byte (128-bit) nonce.
- A nonce on a `<script>` tag without `nonce` in the CSP `script-src` has no effect — the header and the tag must both be present.
- [Inference: `reply.locals` is not a built-in Fastify property — it must be initialized manually or via a plugin. Confirm availability in your setup.]

---

### Hashes

A hash allows a specific inline script or style by its content fingerprint. Unlike nonces, hashes do not change per request — they are computed from the exact content of the inline element.

#### Computing a Hash

js

```js
import { createHash } from 'node:crypto'

const scriptContent = `console.log('hello')`
const hash = createHash('sha256')
  .update(scriptContent)
  .digest('base64')

console.log(`'sha256-${hash}'`)
// 'sha256-abc123...'
```

#### Using the Hash in CSP

js

```js
await fastify.register(helmet, {
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: [
        "'self'",
        "'sha256-abc123...=='",  // Exact base64 hash of the script content
      ],
    },
  },
})
```

html

```html
<!-- The content must match exactly — whitespace included -->
<script>console.log('hello')</script>
```

**Key Points:**

- The hash covers the exact byte content of the script, including whitespace and newlines. Any change invalidates it.
- Supported algorithms: `sha256`, `sha384`, `sha512`.
- Hashes work well for small, static inline scripts (e.g., analytics initialization snippets). For dynamic content, use nonces.

---

### `strict-dynamic`

`'strict-dynamic'` allows scripts loaded by a trusted (nonced or hashed) script to also execute, without needing to be listed in `script-src` explicitly. This simplifies CSP for applications that load scripts programmatically.

js

```js
scriptSrc: [
  "'strict-dynamic'",
  "'nonce-abc123'",
  // 'self' and origin allowlists are ignored when strict-dynamic is present
  // in browsers that support it — but listed for fallback
  "'self'",
  'https:',
]
```

**Key Points:**

- `'strict-dynamic'` only takes effect if a nonce or hash is also present in the directive.
- In browsers that support `'strict-dynamic'`, origin allowlists in `script-src` are ignored — the nonce/hash is the only gate.
- In older browsers that do not support it, the keyword is ignored and the origin allowlist applies as a fallback. [Inference: browser support is broad in modern environments but verify for your target audience.]

---

### Report-Only Mode

`Content-Security-Policy-Report-Only` sends the header without enforcing it. Violations are reported but not blocked. This is invaluable for auditing an existing application before enforcing CSP.

js

```js
await fastify.register(helmet, {
  contentSecurityPolicy: {
    useDefaults: true,
    directives: {
      defaultSrc: ["'self'"],
      reportUri: ['/csp-violations'],
    },
    reportOnly: true,   // Emit Report-Only header instead of enforcing
  },
})

// Collect violation reports
fastify.post('/csp-violations', {
  config: { rawBody: true },
  handler: async (request, reply) => {
    fastify.log.warn({ cspViolation: request.body }, 'CSP violation reported')
    return reply.status(204).send()
  },
})
```

**Key Points:**

- Report-Only and enforcing CSP can be sent simultaneously — use helmet for one and a manual hook for the other.
- Violation reports are JSON POST bodies sent by the browser to `report-uri`.
- The `report-uri` directive is deprecated in favor of `report-to` and the Reporting API, but `report-uri` retains the broadest browser support.

#### Sample Violation Report Body

json

```json
{
  "csp-report": {
    "document-uri": "https://example.com/page",
    "referrer": "",
    "violated-directive": "script-src",
    "effective-directive": "script-src",
    "original-policy": "default-src 'self'; script-src 'self'",
    "blocked-uri": "https://evil.example.com/malicious.js",
    "status-code": 200
  }
}
```

---

### The Reporting API (`report-to`)

The modern replacement for `report-uri` uses the `Reporting-Endpoints` header and `report-to` directive:

js

```js
fastify.addHook('onSend', (request, reply, payload, done) => {
  reply.header(
    'Reporting-Endpoints',
    'csp-endpoint="https://example.com/csp-report"'
  )
  done()
})

await fastify.register(helmet, {
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      reportTo: 'csp-endpoint',
    },
  },
})
```

[Inference: browser support for the Reporting API is still inconsistent as of mid-2025 — using both `report-uri` and `report-to` in the same policy provides broader coverage.]

---

### Per-Route CSP Overrides

Disable or modify CSP for specific routes using helmet's `global: false` pattern:

js

```js
await fastify.register(helmet, { global: false })

// Apply full default CSP
fastify.get('/secure', {
  config: { helmet: { contentSecurityPolicy: true } },
  handler: async () => ({ page: 'secure' }),
})

// Relaxed CSP for an embeddable widget page
fastify.get('/widget', {
  config: {
    helmet: {
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          frameAncestors: ['https://trusted-partner.com'],
        },
      },
    },
  },
  handler: async () => ({ page: 'widget' }),
})

// No CSP for an API endpoint
fastify.get('/api/data', {
  config: { helmet: { contentSecurityPolicy: false } },
  handler: async () => ({ data: [] }),
})
```

---

### CSP for Common Scenarios

#### API-Only Server (No HTML)

CSP is primarily a browser-enforced mechanism. For JSON APIs not consumed by browsers directly, CSP has limited relevance. A minimal policy or none at all is acceptable.

js

```js
await fastify.register(helmet, {
  contentSecurityPolicy: false,
})
```

#### Application Using a CDN for Assets

js

```js
directives: {
  defaultSrc: ["'self'"],
  scriptSrc: ["'self'", 'https://cdn.example.com'],
  styleSrc: ["'self'", 'https://cdn.example.com'],
  imgSrc: ["'self'", 'data:', 'https://cdn.example.com'],
  fontSrc: ["'self'", 'https://cdn.example.com'],
  connectSrc: ["'self'", 'https://api.example.com'],
  objectSrc: ["'none'"],
  frameAncestors: ["'none'"],
  upgradeInsecureRequests: [],
}
```

#### Application Using Google Fonts

js

```js
directives: {
  defaultSrc: ["'self'"],
  styleSrc: ["'self'", 'https://fonts.googleapis.com'],
  fontSrc: ["'self'", 'https://fonts.gstatic.com'],
}
```

#### Application with WebSockets

js

```js
directives: {
  defaultSrc: ["'self'"],
  connectSrc: ["'self'", 'wss://ws.example.com'],
}
```

Note: `connect-src` governs WebSocket connections. Use `wss://` (not `https://`) for WebSocket origins.

---

### Progressive CSP Adoption Strategy

Deploying CSP on an existing application with no prior policy often breaks things immediately. A phased approach reduces disruption.

```
Phase 1 — Audit
  Deploy Report-Only with a permissive policy
  Collect violations for 1–2 weeks
  Map all legitimate resource origins

Phase 2 — Tighten
  Build a policy from the violation data
  Test in staging with enforcement enabled
  Identify and fix 'unsafe-inline' usage

Phase 3 — Enforce
  Enable enforcement in production
  Keep report-uri active for ongoing monitoring
  Iterate on violations

Phase 4 — Harden
  Remove 'unsafe-inline' — replace with nonces or hashes
  Add 'strict-dynamic' for script loading chains
  Enable upgrade-insecure-requests
  Add frame-ancestors 'none' or specific origins
```

---

### Common Pitfalls

#### `'self'` Does Not Include Subdomains

`'self'` matches only the exact origin — scheme, host, and port. `https://app.example.com` does not match `https://api.example.com`. List subdomains explicitly or use `https://*.example.com`.

#### Whitespace in Inline Scripts Breaks Hashes

The hash is computed over the exact byte sequence. A trailing newline, leading space, or indentation change invalidates the hash. Use nonces for anything that may be reformatted.

#### `upgrade-insecure-requests` Rewrites All HTTP Requests

`upgrade-insecure-requests` instructs the browser to upgrade HTTP sub-resource requests to HTTPS. It does not redirect — it rewrites at the browser level. This can silently break resources served only over HTTP.

js

```js
// Only include in fully HTTPS environments
upgradeInsecureRequests: process.env.NODE_ENV === 'production' ? [] : null
```

#### `unsafe-inline` Negates Most XSS Protection

Allowing `'unsafe-inline'` in `script-src` allows any inline `<script>` tag to execute, which is precisely what XSS injects. If your codebase requires inline scripts, migrate to nonces as the safer alternative.

#### Helmet's Defaults May Break SPAs

Frameworks like React, Vue, and Angular often inject inline scripts or load scripts dynamically. Helmet's default CSP will block these without additional configuration. Use Report-Only mode first to identify what needs to be allowed.

---

### Verifying CSP Headers

bash

```bash
curl -I http://localhost:3000/ | grep -i content-security
```

Browser DevTools also display applied CSP and log violations in the Console panel.

---

**Related Topics:**

- Nonce-based CSP with server-side rendering — integrating nonces with template engines (Handlebars, EJS, Pug)
- Subresource Integrity (SRI) — complementing CSP with hash verification on external scripts
- `@fastify/helmet` — full header suite beyond CSP
- Trusted Types — a CSP-adjacent browser API for preventing DOM XSS
- CORS and CSP interaction — how `connect-src` and CORS headers relate
- Reporting API and violation aggregation — building a CSP violation dashboard
- CSP with WebSockets and Server-Sent Events — `connect-src` configuration details
- Migrating from `report-uri` to `report-to` — the Reporting API transition
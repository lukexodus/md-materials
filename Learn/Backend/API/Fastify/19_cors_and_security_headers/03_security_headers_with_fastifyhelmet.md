## Security Headers with @fastify/helmet

@fastify/helmet integrates the widely-used `helmet` middleware into Fastify, applying a collection of HTTP response headers that help mitigate common web vulnerabilities. These headers do not eliminate attacks but can meaningfully reduce attack surface when configured correctly.

---

### Why Security Headers Matter

Browsers expose a range of features and behaviors that can be exploited — clickjacking, MIME-type sniffing, cross-site scripting, and more. HTTP response headers instruct browsers on how to handle your content. Setting them deliberately is a low-effort, high-value defensive measure.

@fastify/helmet sets several of these headers automatically with sensible defaults.

---

### Installation

bash

```bash
npm install @fastify/helmet
```

---

### Basic Registration

js

```js
import Fastify from 'fastify'
import helmet from '@fastify/helmet'

const fastify = Fastify()

await fastify.register(helmet)

fastify.get('/', async () => {
  return { hello: 'world' }
})

await fastify.listen({ port: 3000 })
```

With no options, @fastify/helmet applies its default header set to every response.

---

### Headers Applied by Default

The following headers are enabled out of the box. Actual behavior may vary depending on the version of @fastify/helmet and the underlying `helmet` package.

#### Content-Security-Policy (CSP)

```
Content-Security-Policy: default-src 'self'; base-uri 'self'; ...
```

Restricts the sources from which the browser may load resources (scripts, styles, images, fonts, etc.). One of the most impactful headers for XSS mitigation.

#### X-Content-Type-Options

```
X-Content-Type-Options: nosniff
```

Prevents browsers from MIME-sniffing a response away from the declared `Content-Type`. Reduces the risk of drive-by downloads and content confusion attacks.

#### X-Frame-Options

```
X-Frame-Options: SAMEORIGIN
```

Controls whether the page can be embedded in an `<iframe>`. Helps mitigate clickjacking. Note: CSP's `frame-ancestors` directive is the modern replacement, but `X-Frame-Options` retains broad support.

#### Strict-Transport-Security (HSTS)

```
Strict-Transport-Security: max-age=15552000; includeSubDomains
```

Instructs browsers to only connect via HTTPS for the specified duration. [Important:] This header has real consequences — once a browser receives it, it will refuse HTTP connections for the site until the `max-age` expires. Do not apply this to non-HTTPS environments.

#### X-XSS-Protection

```
X-XSS-Protection: 0
```

Modern guidance recommends disabling the legacy XSS auditor (set to `0`) rather than enabling it, as it could introduce its own vulnerabilities in some browsers. helmet follows this recommendation.

#### Referrer-Policy

```
Referrer-Policy: no-referrer
```

Controls how much referrer information is included in requests. `no-referrer` sends no referrer header at all.

#### X-DNS-Prefetch-Control

```
X-DNS-Prefetch-Control: off
```

Disables browser DNS prefetching. Reduces unsolicited DNS lookups that could leak information about links on your page.

#### X-Download-Options

```
X-Download-Options: noopen
```

Prevents Internet Explorer from executing downloads in the context of your site. [Inference: largely historical relevance in modern deployments.]

#### X-Permitted-Cross-Domain-Policies

```
X-Permitted-Cross-Domain-Policies: none
```

Restricts Adobe Flash and PDF from loading cross-domain data.

#### Cross-Origin-Opener-Policy (COOP)

```
Cross-Origin-Opener-Policy: same-origin
```

Isolates your browsing context from cross-origin documents. Required for certain browser features like `SharedArrayBuffer`.

#### Cross-Origin-Resource-Policy (CORP)

```
Cross-Origin-Resource-Policy: same-origin
```

Prevents other origins from loading your resources.

#### Cross-Origin-Embedder-Policy (COEP)

```
Cross-Origin-Embedder-Policy: require-corp
```

Requires all sub-resources to opt in to being loaded cross-origin. Combined with COOP, enables cross-origin isolation.

---

### Configuring Individual Headers

Each header can be configured or disabled individually via the options object passed to `register`.

js

```js
await fastify.register(helmet, {
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", 'cdn.example.com'],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", 'data:', 'img.example.com'],
      connectSrc: ["'self'", 'api.example.com'],
      fontSrc: ["'self'", 'fonts.gstatic.com'],
      objectSrc: ["'none'"],
      upgradeInsecureRequests: [],
    },
  },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  },
})
```

**Key Points:**

- CSP directives are arrays of strings. Values that require quotes (like `'self'` or `'unsafe-inline'`) must include the single quotes inside the string.
- `upgradeInsecureRequests: []` emits the directive with no value, which is valid CSP syntax.

---

### Disabling a Header

Pass `false` for any header you want to omit entirely:

js

```js
await fastify.register(helmet, {
  contentSecurityPolicy: false,     // Disable CSP entirely
  crossOriginEmbedderPolicy: false, // Useful when embedding third-party iframes
})
```

**When you might disable headers:**

- `crossOriginEmbedderPolicy: false` — when your app embeds cross-origin iframes or loads resources that do not send the required CORP header.
- `contentSecurityPolicy: false` — temporarily during development, or when CSP is managed at the CDN/proxy layer.

---

### Per-Route Header Overrides

@fastify/helmet supports route-level overrides via `helmet` in the route options. This requires using the `enableCSPNonces` or route-level configuration depending on the version. A reliable approach is to disable global helmet and apply it selectively.

js

```js
await fastify.register(helmet, { global: false })

fastify.get('/public', {
  config: { helmet: { contentSecurityPolicy: false } },
  handler: async () => ({ page: 'public' }),
})

fastify.get('/secure', {
  config: { helmet: true }, // Apply all defaults
  handler: async () => ({ page: 'secure' }),
})
```

**Key Points:**

- Setting `global: false` means no routes receive helmet headers by default.
- Each route opts in via `config.helmet`.
- Behavior of per-route overrides may vary across versions — consult the changelog for the version in use. [Unverified: exact API shape for route-level config may differ in versions beyond 11.x.]

---

### CSP Nonces

For inline scripts and styles, CSP normally requires `'unsafe-inline'`, which weakens security. Nonces provide a safer alternative — a cryptographically random value generated per request and included in both the CSP header and the inline tag.

js

```js
await fastify.register(helmet, {
  contentSecurityPolicy: {
    useDefaults: true,
    directives: {
      scriptSrc: ["'self'", (req, res) => `'nonce-${res.locals.nonce}'`],
    },
  },
})
```

Fastify's integration generates the nonce automatically and exposes it via `reply.cspNonce` (actual property name may vary by version — check the plugin documentation).

js

```js
fastify.get('/page', async (request, reply) => {
  const nonce = reply.cspNonce?.script  // [Unverified: exact API]
  return reply.view('page.html', { nonce })
})
```

In your template:

html

```html
<script nonce="{{ nonce }}">
  console.log('This inline script is allowed by CSP nonce.')
</script>
```

---

### Helmet with CORS

When using both `@fastify/cors` and `@fastify/helmet`, registration order matters. Register helmet after CORS so that CORS headers are not overwritten.

js

```js
await fastify.register(cors, { origin: 'https://example.com' })
await fastify.register(helmet)
```

[Inference: In practice, both modify response headers independently, but plugin hook ordering in Fastify means later-registered plugins can overwrite earlier ones' headers in some scenarios.]

---

### Viewing Applied Headers

During development, inspect the response headers using curl:

bash

```bash
curl -I http://localhost:3000/
```

**Output:**

```
HTTP/1.1 200 OK
content-security-policy: default-src 'self';base-uri 'self';...
x-content-type-options: nosniff
x-frame-options: SAMEORIGIN
strict-transport-security: max-age=15552000; includeSubDomains
referrer-policy: no-referrer
x-xss-protection: 0
cross-origin-opener-policy: same-origin
cross-origin-resource-policy: same-origin
cross-origin-embedder-policy: require-corp
```

---

### Common Pitfalls

#### CSP Blocking Legitimate Resources

A strict default CSP may break frontend assets loaded from CDNs, Google Fonts, or analytics scripts. Start with a report-only mode to audit violations before enforcing.

js

```js
contentSecurityPolicy: {
  directives: {
    defaultSrc: ["'self'"],
    reportTo: 'csp-endpoint',
  },
  reportOnly: true,  // Headers sent as Content-Security-Policy-Report-Only
}
```

#### HSTS on Non-HTTPS Environments

Applying HSTS to a local development server or HTTP-only staging environment can cause browsers to refuse to connect. Conditionally apply:

js

```js
const isProd = process.env.NODE_ENV === 'production'

await fastify.register(helmet, {
  hsts: isProd ? { maxAge: 31536000, includeSubDomains: true } : false,
})
```

#### COEP Breaking Third-Party Embeds

`Cross-Origin-Embedder-Policy: require-corp` prevents loading sub-resources that do not opt in with a `Cross-Origin-Resource-Policy` header. Disable it if you embed YouTube, Google Maps, or similar third-party content.

js

```js
await fastify.register(helmet, {
  crossOriginEmbedderPolicy: false,
})
```

---

### Header Reference Summary

| Header | Default Value | Purpose |
| --- | --- | --- |
| Content-Security-Policy | Restrictive default | Resource load restrictions |
| X-Content-Type-Options | `nosniff` | Prevent MIME sniffing |
| X-Frame-Options | `SAMEORIGIN` | Clickjacking mitigation |
| Strict-Transport-Security | `max-age=15552000; includeSubDomains` | Force HTTPS |
| Referrer-Policy | `no-referrer` | Limit referrer leakage |
| X-XSS-Protection | `0` | Disable legacy XSS auditor |
| X-DNS-Prefetch-Control | `off` | Disable DNS prefetch |
| Cross-Origin-Opener-Policy | `same-origin` | Browsing context isolation |
| Cross-Origin-Resource-Policy | `same-origin` | Restrict cross-origin resource loads |
| Cross-Origin-Embedder-Policy | `require-corp` | Require CORP on sub-resources |

---

**Related Topics:**

- Content Security Policy deep dive — directives, nonces, hashes, and report-uri
- `@fastify/cors` — Cross-Origin Resource Sharing configuration
- Rate limiting with `@fastify/rate-limit` — complementary request-layer defense
- Fastify plugin hooks and registration order — how plugin order affects header application
- HTTPS and TLS termination in Fastify — pairing HSTS with a valid TLS setup
- Helmet in a reverse proxy setup — when headers are managed upstream (nginx, Caddy)
- Subresource Integrity (SRI) — complementing CSP with hash-based script verification
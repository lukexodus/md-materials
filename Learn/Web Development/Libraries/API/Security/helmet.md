# Helmet

Helmet is a Node.js middleware library for Express (and compatible frameworks) that sets HTTP response headers to improve application security. It does not block attacks directly but reduces attack surface by configuring headers that browsers use to enforce security policies.

---

## Installation

```bash
npm install helmet
```

Compatible with Node.js 14+ and Express 4+.

---

## Basic Usage

```js
const express = require('express');
const helmet = require('helmet');

const app = express();
app.use(helmet());
```

Calling `helmet()` with no arguments applies a default set of middleware with opinionated defaults. Each middleware can also be used individually.

---

## Default Middleware

When you call `helmet()`, the following middleware are enabled by default:

### Content-Security-Policy

Sets the `Content-Security-Policy` (CSP) header to restrict which resources the browser is permitted to load.

```js
app.use(
  helmet.contentSecurityPolicy({
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "cdn.example.com"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:"],
    },
  })
);
```

**Key directives:**

- `defaultSrc` — fallback for unspecified fetch directives
- `scriptSrc` — allowed script sources
- `styleSrc` — allowed stylesheet sources
- `imgSrc` — allowed image sources
- `connectSrc` — restricts URLs for fetch, XHR, WebSocket
- `fontSrc` — allowed font sources
- `frameSrc` — allowed frame sources
- `mediaSrc` — allowed audio/video sources
- `objectSrc` — allowed plugin sources (e.g., Flash); recommend `"'none'"`
- `upgradeInsecureRequests` — instructs browser to upgrade HTTP requests to HTTPS
- `reportUri` / `reportTo` — endpoint for violation reports

To disable the default CSP and write your own entirely:

```js
app.use(
  helmet({
    contentSecurityPolicy: false,
  })
);
```

---

### Cross-Origin-Embedder-Policy

Sets `Cross-Origin-Embedder-Policy: require-corp`. Required for enabling `SharedArrayBuffer` and certain browser features gated behind cross-origin isolation.

```js
helmet.crossOriginEmbedderPolicy({ policy: "require-corp" });
// or
helmet.crossOriginEmbedderPolicy({ policy: "unsafe-none" });
```

---

### Cross-Origin-Opener-Policy

Sets `Cross-Origin-Opener-Policy` to isolate the browsing context, protecting against cross-origin attacks like Spectre.

```js
helmet.crossOriginOpenerPolicy({ policy: "same-origin" });
// Options: "same-origin" | "same-origin-allow-popups" | "unsafe-none"
```

---

### Cross-Origin-Resource-Policy

Sets `Cross-Origin-Resource-Policy` to control which origins can read a resource in response to a request.

```js
helmet.crossOriginResourcePolicy({ policy: "same-origin" });
// Options: "same-site" | "same-origin" | "cross-origin"
```

---

### Origin-Agent-Cluster

Sets `Origin-Agent-Cluster: ?1`, hinting to browsers to isolate the origin in a separate agent cluster, limiting side-channel attacks.

```js
helmet.originAgentCluster();
```

No configurable options. Enabled by default.

---

### Referrer-Policy

Controls how much referrer information is sent with requests.

```js
helmet.referrerPolicy({ policy: "no-referrer" });
```

**Common policy values:**

|Value|Behavior|
|---|---|
|`no-referrer`|No referrer header sent|
|`no-referrer-when-downgrade`|Sent on same-security-level requests only|
|`origin`|Only the origin is sent|
|`origin-when-cross-origin`|Full URL same-origin; origin only cross-origin|
|`same-origin`|Only sent to same origin|
|`strict-origin`|Origin sent only on same-security-level|
|`strict-origin-when-cross-origin`|Default browser behavior|
|`unsafe-url`|Always sends full URL (not recommended)|

Multiple policies can be set as an array for broader browser support:

```js
helmet.referrerPolicy({ policy: ["no-referrer", "strict-origin-when-cross-origin"] });
```

---

### Strict-Transport-Security

Sets `Strict-Transport-Security` (HSTS), instructing browsers to only communicate with the server over HTTPS.

```js
helmet.strictTransportSecurity({
  maxAge: 31536000,         // 1 year in seconds
  includeSubDomains: true,
  preload: false,
});
```

- `maxAge` — duration in seconds the browser should enforce HTTPS
- `includeSubDomains` — applies policy to all subdomains
- `preload` — opt into HSTS preload list (requires submission to hstspreload.org; irreversible without time delay)

**Do not enable HSTS on non-HTTPS servers.** It will lock out HTTP clients.

---

### X-Content-Type-Options

Sets `X-Content-Type-Options: nosniff`, preventing browsers from MIME-sniffing a response away from the declared `Content-Type`.

```js
helmet.xContentTypeOptions();
```

No configurable options.

---

### X-DNS-Prefetch-Control

Controls browser DNS prefetching. Helmet disables it by default.

```js
helmet.xDnsPrefetchControl({ allow: false });
// Set allow: true to enable DNS prefetching
```

---

### X-Download-Options

Sets `X-Download-Options: noopen`, preventing IE from executing downloaded files in the site's context. Relevant primarily to legacy IE environments.

```js
helmet.xDownloadOptions();
```

No configurable options.

---

### X-Frame-Options

Sets `X-Frame-Options` to control whether the page can be embedded in `<frame>`, `<iframe>`, or `<object>` elements, mitigating clickjacking.

```js
helmet.xFrameOptions({ action: "sameorigin" });
// Options: "deny" | "sameorigin"
```

Note: CSP's `frame-ancestors` directive supersedes this header in modern browsers, but `X-Frame-Options` provides fallback coverage.

---

### X-Permitted-Cross-Domain-Policies

Sets `X-Permitted-Cross-Domain-Policies` to restrict Adobe Flash and PDF cross-domain data loading.

```js
helmet.xPermittedCrossDomainPolicies({ permittedPolicies: "none" });
// Options: "none" | "master-only" | "by-content-type" | "all"
```

---

### X-Powered-By

Removes the `X-Powered-By` header, which by default advertises the server technology (e.g., `Express`).

Helmet removes this header rather than setting it. Express also exposes `app.disable('x-powered-by')` as an alternative.

```js
helmet.xPoweredBy(); // removes the header
```

---

### X-XSS-Protection

Sets `X-XSS-Protection: 0`, explicitly disabling the browser's built-in XSS filter. This is counterintuitive but deliberate — the old XSS filter introduced its own vulnerabilities in some browsers and is no longer recommended. CSP is the correct replacement.

```js
helmet.xXssProtection();
```

No configurable options.

---

## Middleware Not Enabled by Default

### HTTP Public Key Pinning

Not included in Helmet. HPKP was deprecated due to the catastrophic misconfiguration risk (pinning wrong keys can lock users out permanently). No replacement is provided.

---

## Configuring helmet() Globally

All middleware can be configured or disabled when calling `helmet()` directly:

```js
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
      },
    },
    crossOriginEmbedderPolicy: false,
    referrerPolicy: { policy: "no-referrer" },
    strictTransportSecurity: {
      maxAge: 63072000,
      includeSubDomains: true,
    },
    xFrameOptions: { action: "deny" },
  })
);
```

Setting a middleware key to `false` disables it entirely. Setting it to an object passes options to that middleware.

---

## Using Middleware Individually

Each middleware is exported as a named function:

```js
const { contentSecurityPolicy, referrerPolicy } = require('helmet');

app.use(contentSecurityPolicy({ directives: { defaultSrc: ["'self'"] } }));
app.use(referrerPolicy({ policy: "same-origin" }));
```

This is useful when using Helmet outside of a standard Express setup or when applying middleware only to specific routes.

---

## Route-Level Application

Helmet middleware can be scoped to specific routes:

```js
app.get(
  '/api/sensitive',
  helmet.contentSecurityPolicy({ directives: { defaultSrc: ["'none'"] } }),
  (req, res) => {
    res.json({ data: 'protected' });
  }
);
```

---

## Use with Fastify

Helmet has a separate Fastify plugin: `@fastify/helmet`.

```bash
npm install @fastify/helmet
```

```js
const fastify = require('fastify')();
const helmet = require('@fastify/helmet');

fastify.register(helmet, { global: true });
```

The API mirrors the Express version. The `global` option applies the plugin to all routes.

---

## Use with Koa

Use `koa-helmet`, a thin wrapper around Helmet for Koa middleware signature compatibility.

```bash
npm install koa-helmet
```

```js
const Koa = require('koa');
const helmet = require('koa-helmet');

const app = new Koa();
app.use(helmet());
```

---

## Nonce Support for CSP

For inline scripts that cannot be removed, CSP nonces are the recommended mechanism over `'unsafe-inline'`.

```js
const crypto = require('crypto');

app.use((req, res, next) => {
  res.locals.cspNonce = crypto.randomBytes(16).toString('base64');
  next();
});

app.use((req, res, next) => {
  helmet.contentSecurityPolicy({
    directives: {
      scriptSrc: ["'self'", (req, res) => `'nonce-${res.locals.cspNonce}'`],
    },
  })(req, res, next);
});
```

The nonce must be embedded in your HTML:

```html
<script nonce="<%= cspNonce %>">
  // inline script
</script>
```

A new nonce must be generated per request. Reusing nonces defeats the purpose.

---

## Reporting CSP Violations

Use `reportUri` (CSP Level 2) or `reportTo` with the `Report-To` header (CSP Level 3) to collect violation data:

```js
helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    reportUri: '/csp-violation-report',
  },
});

app.post('/csp-violation-report', express.json({ type: 'application/csp-report' }), (req, res) => {
  console.log('CSP Violation:', req.body);
  res.status(204).end();
});
```

For CSP Level 3 `report-to`:

```js
helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    reportTo: "default",
  },
});

res.setHeader('Report-To', JSON.stringify({
  group: "default",
  max_age: 86400,
  endpoints: [{ url: "/csp-violation-report" }],
}));
```

---

## Testing Headers

After setup, verify headers with:

```bash
curl -I http://localhost:3000
```

Or use browser DevTools → Network → select any request → Response Headers.

Automated header auditing tools include [Security Headers](https://securityheaders.com/) and [Observatory by Mozilla](https://observatory.mozilla.org/).

---

## Common Mistakes

**Disabling CSP entirely in production.** CSP is the highest-impact header. Disabling it to avoid configuration work leaves XSS fully unmitigated.

**Using `'unsafe-inline'` or `'unsafe-eval'` in scriptSrc.** These negate most XSS protection CSP provides. Use nonces or hashes instead.

**Setting HSTS on an HTTP server.** Browsers will refuse to connect over HTTP for the duration of `maxAge`. Only set HSTS after confirming full HTTPS deployment.

**Setting `preload` without understanding the commitment.** HSTS preloading is difficult to reverse and requires the domain to remain HTTPS-only indefinitely.

**Forgetting to regenerate nonces per request.** A static nonce is equivalent to no nonce.

**Assuming Helmet replaces authentication or input validation.** Helmet sets headers. It does not sanitize input, manage sessions, or enforce authorization. It is one layer of a defense-in-depth strategy.

---

## Version Notes

Helmet v4 to v5 introduced breaking changes: middleware were restructured, `featurePolicy` was removed (replaced by Permissions-Policy), and defaults changed. Helmet v6+ continued refining defaults. Always consult the changelog when upgrading.

The `Permissions-Policy` header (formerly `Feature-Policy`) is not currently included in Helmet's default set as of recent versions. It can be set manually:

```js
app.use((req, res, next) => {
  res.setHeader('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
  next();
});
```

[Unverified — Helmet's exact version-to-version feature set changes; verify against the current release changelog at github.com/helmetjs/helmet.]

---

## Reference

- Repository: [github.com/helmetjs/helmet](https://github.com/helmetjs/helmet)
- MDN HTTP Headers: [developer.mozilla.org/en-US/docs/Web/HTTP/Headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers)
- CSP Reference: [content-security-policy.com](https://content-security-policy.com/)
- HSTS Preload: [hstspreload.org](https://hstspreload.org/)
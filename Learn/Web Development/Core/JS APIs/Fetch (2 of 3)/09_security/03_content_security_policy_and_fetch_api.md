## Content Security Policy and Fetch API


### CSP Directives Affecting Fetch

#### connect-src

The `connect-src` directive controls which URLs can be loaded using script interfaces including `fetch()`, `XMLHttpRequest`, `WebSocket`, `EventSource`, and `Navigator.sendBeacon()`.

```http
Content-Security-Policy: connect-src 'self' https://api.example.com
```

When a fetch request violates `connect-src`, the browser blocks the request and returns a network error. The Promise returned by `fetch()` rejects with a `TypeError`.

```javascript
// Allowed if connect-src includes https://api.example.com
fetch('https://api.example.com/data')
  .then(response => response.json())
  .catch(error => {
    // TypeError: Failed to fetch (CSP violation)
  });
```

#### default-src Fallback

If `connect-src` is not specified, the `default-src` directive serves as a fallback for all fetch directives.

```http
Content-Security-Policy: default-src 'self'
```

This policy restricts fetch requests to same-origin URLs only.

### CSP and CORS Interaction

CSP evaluation occurs before CORS checks. A request must satisfy CSP requirements before the browser even initiates the network request that would trigger CORS preflight.

```javascript
// CSP blocks this before CORS preflight is sent
fetch('https://blocked-by-csp.example.com/api', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' }
});
```

### Special Source Values

#### 'self'

Restricts connections to the same origin (same scheme, host, and port).

```http
Content-Security-Policy: connect-src 'self'
```

```javascript
// Allowed on https://example.com
fetch('/api/data');
fetch('https://example.com/api/data');

// Blocked
fetch('https://api.example.com/data'); // Different subdomain
fetch('http://example.com/data'); // Different scheme
```

#### 'none'

Blocks all fetch requests.

```http
Content-Security-Policy: connect-src 'none'
```

All `fetch()` calls will fail with a CSP violation.

#### Scheme Sources

Allow connections to any URL with specified schemes.

```http
Content-Security-Policy: connect-src https: wss:
```

```javascript
// Allowed - any HTTPS URL
fetch('https://any-domain.com/api');

// Blocked - HTTP not allowed
fetch('http://insecure.com/api');
```

#### Host Sources

Specify allowed hosts with optional wildcards.

```http
Content-Security-Policy: connect-src https://*.example.com https://api.partner.com
```

```javascript
// Allowed
fetch('https://api.example.com/data');
fetch('https://cdn.example.com/resource');
fetch('https://api.partner.com/endpoint');

// Blocked
fetch('https://example.com'); // Subdomain required by wildcard
fetch('https://malicious.com/api');
```

### Reporting CSP Violations

#### report-uri (Deprecated)

```http
Content-Security-Policy: connect-src 'self'; report-uri /csp-violation-report
```

#### report-to (Modern)

```http
Content-Security-Policy: connect-src 'self'; report-to csp-endpoint
Report-To: {"group":"csp-endpoint","max_age":10886400,"endpoints":[{"url":"/csp-report"}]}
```

Violation reports include:

- `blocked-uri`: The URI that was blocked
- `violated-directive`: The directive that was violated
- `effective-directive`: The specific directive that caused the block
- `original-policy`: The full CSP policy

```json
{
  "csp-report": {
    "document-uri": "https://example.com/page",
    "violated-directive": "connect-src",
    "effective-directive": "connect-src",
    "original-policy": "connect-src 'self'",
    "blocked-uri": "https://malicious.com/api",
    "status-code": 0
  }
}
```

### Report-Only Mode

CSP can be deployed in report-only mode using the `Content-Security-Policy-Report-Only` header. Violations are reported but not enforced.

```http
Content-Security-Policy-Report-Only: connect-src 'self'; report-uri /csp-violations
```

```javascript
// This fetch executes normally but violation is reported
fetch('https://external-api.com/data');
```

This mode is useful for testing CSP policies before enforcement.

### Nonce and Hash Sources

[Inference] While `'nonce-'` and `'sha256-'` sources are commonly used with `script-src` and `style-src` directives, they are not applicable to `connect-src` or fetch requests. These sources control inline script/style execution, not network requests.

### Multiple Policies

When multiple CSP headers or meta tags are present, all policies must be satisfied (intersection of allowed sources).

```http
Content-Security-Policy: connect-src https://api1.example.com
Content-Security-Policy: connect-src https://api2.example.com
```

Result: No fetch requests are allowed because no origin satisfies both policies simultaneously.

```javascript
// Both blocked - violate one of the two policies
fetch('https://api1.example.com/data');
fetch('https://api2.example.com/data');
```

### CSP in Meta Tags

CSP can be specified via HTML meta tags, but with limitations.

```html
<meta http-equiv="Content-Security-Policy" 
      content="connect-src 'self' https://api.example.com">
```

Limitations:

- `report-uri` and `report-to` directives are not supported in meta tags
- Meta tag CSP is parsed after the document starts loading
- HTTP header CSP is preferred for reliability

### Dynamic Import and Worker CSP

#### Worker Scripts

Workers inherit the CSP of the document that created them, but `connect-src` applies to fetch requests made within the worker.

```javascript
// In worker.js
fetch('https://api.example.com/data'); // Subject to CSP connect-src
```

#### Import Scripts in Workers

The `importScripts()` function in workers is controlled by `script-src` (or `script-src-elem`), not `connect-src`.

### Upgrade-Insecure-Requests

The `upgrade-insecure-requests` directive automatically upgrades HTTP URLs to HTTPS.

```http
Content-Security-Policy: upgrade-insecure-requests
```

```javascript
// Automatically upgraded to https://api.example.com/data
fetch('http://api.example.com/data');
```

[Inference] This upgrade happens before CSP evaluation, so `connect-src` policies evaluate against the upgraded URL.

### Block-All-Mixed-Content

[Unverified] The `block-all-mixed-content` directive was previously used to prevent mixed content (HTTPS page loading HTTP resources), but modern browsers block mixed content by default. This directive is now largely obsolete.

### CSP Level 3 Features

#### Embedded Enforcement

Parent documents can enforce CSP on embedded iframes using the `csp` attribute.

```html
<iframe src="https://embed.example.com" 
        csp="connect-src 'self'">
</iframe>
```

Fetch requests within the iframe must satisfy both the iframe's own CSP and the embedded enforcement policy.

#### Strict Dynamic

While `'strict-dynamic'` is primarily for script execution control, understanding its behavior is important when loading scripts that make fetch requests.

```http
Content-Security-Policy: script-src 'nonce-abc123' 'strict-dynamic'; connect-src 'self'
```

Scripts loaded with the correct nonce can execute, but their fetch requests still must satisfy `connect-src`.

### CSP Evaluation Flow for Fetch

1. Browser receives fetch request from JavaScript
2. Browser checks `connect-src` directive (or `default-src` fallback)
3. If policy allows the URL:
    - Browser initiates network request
    - CORS checks apply if cross-origin
    - Request proceeds normally
4. If policy blocks the URL:
    - Browser blocks request immediately
    - Network request never occurs
    - `fetch()` Promise rejects with `TypeError`
    - Violation reported if reporting configured

### Debugging CSP Violations

Browser DevTools provide CSP violation information:

**Console Messages:**

```
Refused to connect to 'https://blocked.example.com/api' 
because it violates the following Content Security Policy directive: 
"connect-src 'self' https://api.example.com"
```

**Network Tab:**

- Blocked requests appear with "blocked:csp" status
- No actual network traffic occurs

**Security Tab:**

- Shows active CSP policies
- Lists violated directives
- [Inference] Available in Chrome/Edge DevTools

### Best Practices

#### Start Restrictive

Begin with strict policies and relax as needed:

```http
Content-Security-Policy: default-src 'none'; connect-src 'self'
```

#### Use Report-Only for Testing

Deploy new policies in report-only mode first:

```http
Content-Security-Policy-Report-Only: connect-src 'self' https://new-api.example.com
```

Monitor violation reports before enforcing.

#### Avoid Wildcards

Specify exact hosts when possible:

```http
# Less secure
Content-Security-Policy: connect-src https://*

# More secure
Content-Security-Policy: connect-src 'self' https://api.example.com https://cdn.example.com
```

#### Separate API Domains

Host APIs on dedicated subdomains for granular control:

```http
Content-Security-Policy: connect-src 'self' https://api.example.com
```

#### Monitor Violations

Set up violation reporting and monitoring infrastructure:

```http
Content-Security-Policy: connect-src 'self'; report-to csp-endpoint
```

Analyze reports regularly to detect:

- Configuration errors
- Malicious injection attempts
- Required policy adjustments

### Common Pitfalls

#### Forgetting About Redirects

CSP checks apply to the final URL after redirects, but [Inference] browsers may also check intermediate redirect URLs.

```javascript
// Initial URL allowed, but redirect destination blocked
fetch('https://api.example.com/redirect'); // Redirects to https://blocked.com
```

#### WebSocket Connections

WebSocket connections are also controlled by `connect-src`:

```http
Content-Security-Policy: connect-src 'self' wss://ws.example.com
```

```javascript
// Blocked if wss://external.com not in connect-src
const ws = new WebSocket('wss://external.com/socket');
```

#### ServiceWorker Fetch Events

Fetch requests made in ServiceWorker `fetch` event handlers are subject to the page's CSP, not the ServiceWorker script's CSP.

```javascript
// In service-worker.js
self.addEventListener('fetch', event => {
  // This fetch subject to page CSP, not SW CSP
  event.respondWith(
    fetch('https://api.example.com/data')
  );
});
```

#### Data URLs

Data URLs in fetch are blocked by most CSP configurations:

```http
Content-Security-Policy: connect-src 'self'
```

```javascript
// Blocked - data: scheme not allowed
fetch('data:text/plain,Hello');
```

To allow data URLs explicitly:

```http
Content-Security-Policy: connect-src 'self' data:
```

#### Blob URLs

Blob URLs created with `URL.createObjectURL()` are considered same-origin for CSP purposes when `'self'` is allowed.

```javascript
const blob = new Blob(['{"key": "value"}'], { type: 'application/json' });
const blobUrl = URL.createObjectURL(blob);

// Allowed if connect-src includes 'self'
fetch(blobUrl);
```

### Framework-Specific Considerations

#### React/Vue/Angular SPAs

Single-page applications making frequent API calls need carefully configured CSP:

```http
Content-Security-Policy: 
  default-src 'self'; 
  connect-src 'self' https://api.example.com https://analytics.example.com;
  script-src 'self' 'unsafe-inline' 'unsafe-eval';
```

Note: `'unsafe-inline'` and `'unsafe-eval'` weaken CSP security and should be avoided when possible using nonces or hashes.

#### API Gateways

When using API gateways, allow the gateway domain:

```http
Content-Security-Policy: connect-src 'self' https://gateway.example.com
```

Backend service URLs behind the gateway don't need to be whitelisted.

### Performance Implications

CSP evaluation is performed synchronously before network requests. [Inference] The performance impact is negligible as it involves simple string matching against policy directives, occurring in microseconds.

### Browser Support

CSP Level 2 (`connect-src`) is supported by all modern browsers. Legacy browsers without CSP support ignore the header, providing no protection but not breaking functionality.

[Unverified] Specific CSP Level 3 features like embedded enforcement may have varying support across browsers. Check compatibility tables for cutting-edge features.

---


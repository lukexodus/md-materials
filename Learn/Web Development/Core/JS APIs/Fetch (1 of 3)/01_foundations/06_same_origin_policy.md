## Same-Origin Policy


### Core Mechanism

The same-origin policy restricts how documents or scripts loaded from one origin can interact with resources from another origin. Two URLs share the same origin when their protocol (scheme), host (domain), and port are identical.

**Origin comparison examples:**

- `https://example.com:443/page1` and `https://example.com:443/page2` → Same origin
- `https://example.com` and `http://example.com` → Different origins (protocol)
- `https://example.com` and `https://api.example.com` → Different origins (host)
- `https://example.com:443` and `https://example.com:8080` → Different origins (port)

### Scope of Restrictions

#### DOM Access

Scripts cannot access the DOM of documents from different origins. A page at `https://site-a.com` cannot read or manipulate the DOM of an iframe containing `https://site-b.com`.

**Exception:** If both documents set `document.domain` to the same value and share the same protocol and port, they can interact. This only works for subdomains of the same parent domain.

#### Cookie Access

JavaScript can only access cookies for its own origin. Cookies have their own scoping rules:

- `Domain` attribute allows sharing across subdomains
- `Path` attribute restricts cookie visibility within an origin
- `Secure` attribute limits cookies to HTTPS
- `SameSite` attribute controls cross-site cookie sending

#### Local Storage and Session Storage

`localStorage` and `sessionStorage` are strictly origin-scoped. No cross-origin access is possible.

#### IndexedDB

IndexedDB databases are origin-scoped with no cross-origin access mechanisms.

### Network Request Restrictions

#### XMLHttpRequest and Fetch API

By default, cross-origin requests are blocked unless the target server explicitly permits them via CORS headers. The browser performs:

**Simple requests:** Sent directly with an `Origin` header. Server responds with `Access-Control-Allow-Origin` to permit access.

**Preflight requests:** For non-simple requests (custom headers, methods like PUT/DELETE, certain content types), the browser sends an OPTIONS request first. The server must respond with appropriate CORS headers before the actual request proceeds.

#### Form Submissions

Forms can POST to any origin (this predates SOP). The submitting page cannot read the response without CORS headers, but the request executes.

#### Script Tags

Scripts loaded via `<script src="...">` execute in the context of the including page regardless of origin. This creates the foundation for JSONP and also represents a security consideration.

#### Image, CSS, and Media

These resources can be loaded cross-origin:

- `<img>`, `<video>`, `<audio>` tags
- CSS via `<link>` or `@import`
- Fonts via `@font-face`

However, accessing pixel data from cross-origin images (via canvas) or reading CSS rules is restricted without CORS.

### Window References

Scripts can obtain references to windows from different origins through:

- `window.open()`
- `<iframe>` elements
- `window.parent`, `window.top`
- Named window targets

Cross-origin window references permit only limited operations:

- Posting messages via `postMessage()`
- Navigating the window via `location` assignment (write-only)
- Closing windows opened by the script
- Accessing `window.closed`, `window.frames`, `window.length`

Reading properties like `location.href`, accessing the DOM, or calling most methods is blocked.

### Cross-Origin Communication Mechanisms

#### postMessage API

`window.postMessage()` enables controlled cross-origin communication. The sending window calls:

```javascript
targetWindow.postMessage(message, targetOrigin);
```

The receiving window listens:

```javascript
window.addEventListener('message', (event) => {
  // Verify event.origin
  // Process event.data
});
```

**Critical security requirement:** Always verify `event.origin` before processing messages.

#### CORS (Cross-Origin Resource Sharing)

Servers opt-in to cross-origin requests by sending headers:

**Basic CORS headers:**

- `Access-Control-Allow-Origin`: Specifies allowed origins (* or specific origin)
- `Access-Control-Allow-Methods`: Permitted HTTP methods
- `Access-Control-Allow-Headers`: Permitted custom headers
- `Access-Control-Allow-Credentials`: Whether cookies/auth can be included
- `Access-Control-Max-Age`: Preflight cache duration

**Credentialed requests:** When `credentials: 'include'` is used, `Access-Control-Allow-Origin` cannot be `*` and must specify the exact origin.

#### JSONP (Legacy)

JSONP circumvents SOP by using `<script>` tags. The server wraps JSON data in a callback function. This pattern has significant security implications and is largely obsolete due to CORS.

### Browser Storage and SOP

#### Cookies

Cookies don't strictly follow SOP. Their scoping uses:

- `Domain` attribute (can include subdomains)
- `Path` attribute
- `Secure` and `SameSite` attributes

A cookie set with `Domain=.example.com` is accessible to all subdomains.

#### Web Storage

`localStorage` and `sessionStorage` are strictly origin-based. Subdomains are treated as different origins.

#### Cache

HTTP cache is typically origin-scoped, though implementation details vary by browser. [Inference: Some cache poisoning attacks exploit ambiguities in cache scoping.]

### Special Cases and Nuances

#### Data URIs and Blob URLs

Documents loaded from `data:` URLs have unique, opaque origins that don't match any other origin. Blob URLs inherit the origin of the context that created them.

#### File Protocol

`file://` URLs typically have special handling. [Inference: Different browsers treat `file://` origins differently - some treat each file as a unique origin, others treat all local files as same origin.]

#### Extensions and Privileged Contexts

Browser extensions can request permission to bypass SOP for specific origins. These permissions must be explicitly declared in the extension manifest.

#### WebSockets

WebSocket connections use an origin-based security model but with different semantics. The server receives an `Origin` header and decides whether to accept the connection.

### Interaction with Other Security Policies

#### Content Security Policy (CSP)

CSP adds another layer on top of SOP. While SOP controls what can be accessed, CSP controls what can be loaded or executed. CSP can:

- Restrict script sources beyond SOP
- Block inline scripts
- Control form submission targets
- Restrict frame ancestors

#### CORP (Cross-Origin Resource Policy)

CORP headers (`Cross-Origin-Resource-Policy`) allow resources to declare they should only be loaded by same-origin or same-site contexts, protecting against Spectre-like attacks.

#### COEP (Cross-Origin Embedder Policy)

COEP (`Cross-Origin-Embedder-Policy: require-corp`) requires all embedded resources to explicitly opt-in via CORP or CORS.

#### COOP (Cross-Origin Opener Policy)

COOP (`Cross-Origin-Opener-Policy`) isolates browsing context groups, preventing cross-origin windows from accessing each other even through references.

### Common Attack Vectors Related to SOP

#### CSRF (Cross-Site Request Forgery)

SOP doesn't prevent request sending, only response reading. CSRF exploits this by causing authenticated users to send unwanted requests. Mitigations include:

- CSRF tokens
- `SameSite` cookie attribute
- Verifying `Origin`/`Referer` headers
- Custom headers requiring preflight

#### XSS (Cross-Site Scripting)

XSS bypasses SOP by injecting malicious scripts that execute within the victim origin, granting full access to that origin's data.

#### Clickjacking

Overlaying transparent iframes to trick users into clicking unintended targets. Mitigated by:

- `X-Frame-Options` header
- CSP `frame-ancestors` directive

#### CORS Misconfiguration

Common vulnerabilities:

- Reflecting `Origin` header without validation
- Using `Access-Control-Allow-Origin: *` with credentials
- Insufficient validation of allowed origins
- Overly permissive preflight responses

### Implementation Variations

Different browsers implement SOP with slight variations:

**Port handling:** Some older browsers didn't consider ports in origin comparison. Modern browsers consistently include ports.

**Document.domain quirk:** The `document.domain` setter is deprecated and being removed from browsers due to security concerns.

**localhost special cases:** [Inference: Browsers may treat localhost specially, though the exact behavior varies.]

### Performance Considerations

SOP enforcement adds overhead:

- Preflight requests add latency for complex CORS requests
- Cache segregation by origin increases memory usage
- Storage APIs maintain per-origin quotas

**Preflight caching:** The `Access-Control-Max-Age` header allows browsers to cache preflight results, reducing repeated OPTIONS requests.

### Modern Additions and Evolution

#### Fetch Metadata Request Headers

Modern browsers send request metadata headers:

- `Sec-Fetch-Site`: Indicates request's site relationship (same-origin, same-site, cross-site, none)
- `Sec-Fetch-Mode`: Request mode (cors, no-cors, navigate, etc.)
- `Sec-Fetch-Dest`: Request destination (document, script, image, etc.)

Servers can use these for defense-in-depth.

#### Storage Access API

Allows embedded cross-origin iframes to request access to their own first-party storage after user interaction, addressing legitimate third-party embedding scenarios while maintaining privacy.

#### Partitioned Storage

Browsers are moving toward partitioning storage by top-level site in addition to origin, preventing cross-site tracking through storage mechanisms.

---


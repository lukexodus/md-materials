# Understanding CORS (Cross-Origin Resource Sharing)

CORS is a security mechanism built into web browsers that controls how web pages from one origin can access resources from a different origin.

## What is an Origin?

An origin consists of three parts:
- **Protocol** (http vs https)
- **Domain** (example.com)
- **Port** (80, 443, 8080, etc.)

Two URLs have the same origin only if all three match. For example:
- `https://example.com` and `https://example.com/page` → Same origin
- `https://example.com` and `http://example.com` → Different origins (protocol differs)
- `https://example.com` and `https://api.example.com` → Different origins (subdomain differs)

## Why CORS Exists

Without CORS, any website could make requests to other domains using your browser's credentials (cookies, authentication tokens). This would allow malicious sites to:
- Access your banking information
- Read your private emails
- Make unauthorized actions on your behalf

The browser's Same-Origin Policy blocks these cross-origin requests by default. CORS provides a controlled way to relax this restriction when appropriate.

## How CORS Works

When your browser makes a cross-origin request, it includes an `Origin` header. The server responds with CORS headers that tell the browser whether to allow the request:

**Key response headers:**
- `Access-Control-Allow-Origin` — Specifies which origins can access the resource (e.g., `https://example.com` or `*` for any origin)
- `Access-Control-Allow-Methods` — Lists allowed HTTP methods (GET, POST, PUT, etc.)
- `Access-Control-Allow-Headers` — Lists allowed request headers
- `Access-Control-Allow-Credentials` — Whether cookies/auth can be included

## Simple vs Preflight Requests

**Simple requests** proceed directly if they meet certain criteria:
- Methods: GET, HEAD, or POST
- Only simple headers (Accept, Content-Type with specific values, etc.)
- Content-Type: application/x-www-form-urlencoded, multipart/form-data, or text/plain

**Preflight requests** happen when a request doesn't meet "simple" criteria. The browser first sends an OPTIONS request to check permissions before sending the actual request. This occurs with:
- Methods like PUT, DELETE, PATCH
- Custom headers
- Content-Type: application/json

## Common CORS Errors

You'll see CORS errors in the browser console when:
- The server doesn't send CORS headers
- The `Access-Control-Allow-Origin` doesn't match your origin
- Credentials are sent but `Access-Control-Allow-Credentials` is missing
- The preflight OPTIONS request fails

## Enabling CORS on a Server

The implementation varies by technology. Here's the general pattern:

**Permissive (development only):**
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type
```

**Restrictive (production):**
```
Access-Control-Allow-Origin: https://trusted-site.com
Access-Control-Allow-Methods: GET, POST
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Credentials: true
```

## Important Security Notes

- Using `Access-Control-Allow-Origin: *` with `Access-Control-Allow-Credentials: true` is not allowed by browsers for security reasons
- CORS is a browser security feature — it doesn't protect your API from non-browser clients (like curl or Postman)
- Server-side authentication and authorization are still necessary regardless of CORS settings

## Workarounds

If you can't modify the server's CORS policy:
- Use a **proxy server** that adds CORS headers
- Make requests from your **backend** instead of the browser
- Use **JSONP** for GET requests (older technique, limited use cases)
- Some browsers allow CORS to be disabled for local development (not recommended for regular browsing)

The key principle: CORS is controlled by the **server**, not the client. The browser enforces the server's CORS policy to protect users.

---

# JSONP (JSON with Padding)

JSONP is an older technique for making cross-origin requests that predates CORS. It exploits the fact that `<script>` tags are not subject to the Same-Origin Policy.

## How JSONP Works

Instead of using XMLHttpRequest or fetch (which are blocked by CORS), JSONP works by:

1. Creating a `<script>` tag dynamically
2. Setting its `src` to the API endpoint with a callback parameter
3. The server wraps the JSON response in a function call
4. When the script loads, it executes your callback function with the data

**Example request:**
```javascript
// Client defines a callback function
function handleData(data) {
  console.log(data);
}

// Create script tag pointing to API
const script = document.createElement('script');
script.src = 'https://api.example.com/data?callback=handleData';
document.body.appendChild(script);
```

**Server response:**
```javascript
handleData({"name": "John", "age": 30});
```

When the browser loads this script, it executes `handleData()` with your data.

## Limitations

**Only supports GET requests** — Since `<script>` tags only make GET requests, you cannot POST, PUT, DELETE, or send request bodies.

**Security risks:**
- You're executing arbitrary JavaScript from a third-party server
- The server could inject malicious code
- No way to set custom headers or handle errors properly
- Vulnerable to callback manipulation attacks

**No error handling** — If the request fails, there's no standard way to catch the error (unlike fetch's catch block).

**Global namespace pollution** — Callback functions typically need to be global, which can cause naming conflicts.

## Modern Usage

JSONP is largely obsolete today because:
- **CORS** provides a safer, more flexible solution
- All modern browsers support CORS
- JSONP's limitations (GET-only, security issues) make it impractical for most use cases

**[Inference]** You might still encounter JSONP in:
- Legacy systems built before CORS was widely supported
- Some older third-party APIs that haven't been updated
- Services that need to support very old browsers (Internet Explorer 9 and below)

## Should You Use JSONP?

**No, in almost all cases.** Use CORS instead. The only scenario where JSONP might be considered is if you need to support extremely old browsers and can absolutely trust the server providing the data.

If you control the server, implement proper CORS headers. If you don't control the server and it doesn't support CORS, use a backend proxy instead of JSONP for security reasons.

---

# JSONP Callback: Client vs Server

## Who Implements the Callback?

**The client implements the callback function.** This is JavaScript code that runs in the browser.

```javascript
// CLIENT SIDE - You write this
function handleData(data) {
  console.log('Received:', data.name);
  document.getElementById('result').textContent = data.name;
}
```

## Who Calls the Callback?

**The server calls the callback** by wrapping the data in a function call, but **the actual execution happens in the client's browser**.

Here's the flow:

### Step 1: Client Sets Up
```javascript
// CLIENT: Define callback function
function myCallback(data) {
  console.log('Got data:', data);
}

// CLIENT: Request data with callback name
const script = document.createElement('script');
script.src = 'https://api.example.com/users?callback=myCallback';
document.body.appendChild(script);
```

### Step 2: Server Responds
```javascript
// SERVER: Wraps JSON in the callback function name
// The server reads the "callback" query parameter and uses it
myCallback({"name": "Alice", "age": 25});
```

### Step 3: Browser Executes
When the browser receives this response, it treats it as JavaScript code and executes it, which calls your `myCallback` function with the data.

## Where Everything Lives

```
CLIENT (Browser)
├── Callback function definition ← You write this
└── Script tag creation ← You write this

SERVER
└── Wraps data in callback name ← Server reads your callback parameter

EXECUTION
└── Happens in the browser ← After server sends the wrapped response
```

## Complete Example

**Client side:**
```javascript
// 1. Define what to do with the data (CLIENT)
function processUserData(userData) {
  alert('User: ' + userData.name);
}

// 2. Request the data (CLIENT)
const script = document.createElement('script');
script.src = 'https://api.example.com/user/123?callback=processUserData';
document.body.appendChild(script);
```

**Server side (pseudo-code):**
```javascript
// 3. Server receives request and generates response
const callbackName = request.query.callback; // "processUserData"
const data = {name: "Bob", age: 30};
const response = callbackName + '(' + JSON.stringify(data) + ');';

// Server sends: processUserData({"name":"Bob","age":30});
```

**Result in browser:**
```javascript
// 4. Browser receives and executes (CLIENT)
processUserData({"name":"Bob","age":30}); // This runs your function
```

## Key Point

The callback function is **defined and executed on the client**, but the **server wraps the data** in a call to that function. The server doesn't execute the callback—it just generates JavaScript code that will call it when the browser runs that code.

Think of it like this: You tell the server "send me data wrapped in a call to my function `X`", and the server responds with `X(data)`, which your browser then executes.

---

# Content Security Policy (CSP)

Content Security Policy (CSP) is a security standard that helps protect websites from cross-site scripting (XSS), clickjacking, and other code injection attacks by controlling which resources the browser is allowed to load.

## How CSP Works

CSP operates through HTTP headers or meta tags that specify rules (called directives) about what content sources are considered safe. When a browser receives these directives, it enforces them by blocking resources that violate the policy.

**Example HTTP header:**
```
Content-Security-Policy: default-src 'self'; script-src 'self' https://trusted.cdn.com
```

This policy allows resources from the same origin by default, and scripts only from the same origin or a specific CDN.

## Common CSP Directives

- **default-src** - Fallback for other directives
- **script-src** - Controls JavaScript sources
- **style-src** - Controls stylesheet sources
- **img-src** - Controls image sources
- **connect-src** - Controls fetch, XMLHttpRequest, WebSocket connections
- **font-src** - Controls font sources
- **object-src** - Controls `<object>`, `<embed>`, `<applet>` elements
- **frame-src** - Controls frame sources
- **base-uri** - Restricts URLs in `<base>` element
- **form-action** - Restricts form submission targets

## Source Values

- **'none'** - Blocks all sources
- **'self'** - Allows same-origin resources
- **'unsafe-inline'** - Allows inline scripts/styles (reduces security)
- **'unsafe-eval'** - Allows eval() and similar functions (reduces security)
- **'nonce-[value]'** - Allows specific inline script/style with matching nonce
- **'sha256-[hash]'** - Allows content matching specific hash
- **https:** - Allows HTTPS sources
- **Specific domains** - e.g., https://example.com

## Implementation Methods

**Via HTTP header:**
```
Content-Security-Policy: directive source; directive source
```

**Via meta tag:**
```html
<meta http-equiv="Content-Security-Policy" content="directive source; directive source">
```

**[Inference]** HTTP headers are generally preferred as they're harder to manipulate and provide broader coverage.

## Report-Only Mode

CSP can be deployed in report-only mode for testing:
```
Content-Security-Policy-Report-Only: default-src 'self'; report-uri /csp-violation-report
```

This logs violations without blocking them, useful for identifying issues before enforcement.

## Common Use Cases

**Preventing XSS attacks:** By restricting script sources, CSP makes it significantly harder for attackers to inject malicious scripts.

**Blocking mixed content:** Enforcing HTTPS-only resources prevents insecure content on secure pages.

**Preventing clickjacking:** The `frame-ancestors` directive controls where a page can be embedded.

## Challenges and Limitations

- Inline scripts and styles require refactoring or nonces/hashes
- Third-party integrations may require careful policy configuration
- Browser compatibility varies (though modern browsers have good support)
- **[Inference]** Overly restrictive policies may break legitimate functionality
- **[Unverified]** Maintenance overhead increases with complex applications

## Best Practices

Start with a restrictive policy and gradually allow necessary sources rather than starting permissive. Use report-only mode before enforcement. Avoid 'unsafe-inline' and 'unsafe-eval' when possible. Use nonces or hashes for necessary inline content. Regularly review and update policies. Monitor violation reports to identify issues.

**Note:** CSP is a powerful security tool but doesn't replace other security measures. It works best as part of a comprehensive security strategy including input validation, output encoding, and other protective measures.

---


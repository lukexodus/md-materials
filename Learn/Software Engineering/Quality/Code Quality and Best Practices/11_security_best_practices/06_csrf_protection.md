## CSRF Protection


Cross-Site Request Forgery (CSRF) exploits the trust a web application places in a user's browser, forcing authenticated users to execute unwanted actions. Effective mitigation requires a layered defense strategy, primarily centered on synchronizer token patterns and SameSite cookie attributes, implemented within the application layer and enforced by the browser.

### Synchronizer Token Pattern (STP)

The industry-standard defense involves generating a cryptographically strong, random token associated with the user's session. This token acts as a challenge-response mechanism.

#### Implementation Architecture

1. **Token Generation:** Upon session creation, generate a high-entropy string (e.g., CSPRNG-derived 32-byte hex). Store this `csrf_token` in the server-side session storage. Do not rely on predictable values like session IDs or timestamps.
    
2. **Token Transmission (Server-to-Client):** Inject the token into the HTML DOM for state-changing forms.
    
    - **Hidden Fields:** `<input type="hidden" name="csrf_token" value="...">`
        
    - **Meta Tags (SPA/AJAX):** `<meta name="csrf-token" content="...">` for JavaScript frameworks to read and append to headers.
        
3. **Token Validation (Client-to-Server):**
    
    - For standard POST requests: The backend middleware intercepts the request, extracts the token from the payload, and compares it against the session-stored token using a constant-time comparison algorithm (to prevent timing attacks).
        
    - For AJAX/Fetch: The token is extracted from the `X-CSRF-Token` custom header.
        

**Anti-Pattern:** Storing the CSRF token solely in a cookie without a corresponding check in the request body/header renders the protection useless, as the browser automatically includes cookies in cross-origin requests.

### Double Submit Cookie Pattern

In stateless architectures (e.g., RESTful microservices) where server-side session storage is undesirable, the Double Submit Cookie pattern is utilized.

#### Mechanism

1. **Token Creation:** The server generates a random token and sets it as a cookie on the client.
    
2. **Request Construction:** Client-side JavaScript reads this cookie and includes its value in a custom request header or request body.
    
3. **Validation:** The server validates that the value in the cookie matches the value in the header/body.
    

#### Security Hardening

- **Cookie Attributes:** The cookie _must not_ be `HttpOnly` because the client script needs to read it. However, it must be `Secure`.
    
- **Encryption:** To prevent attackers from setting their own cookies (on subdomains), encrypt the token in the cookie with a server-side secret. The server decrypts the cookie value and compares it to the header value. This is known as the "Encrypted Token Pattern."
    

### SameSite Cookie Attribute

The `SameSite` attribute instructs the browser on whether to send cookies with cross-site requests, providing a robust defense at the protocol level.

- **`SameSite=Strict`:** Cookies are sent _only_ in a first-party context. They are blocked for all cross-site requests, including top-level navigations (e.g., following a link from an email). While secure, this negatively impacts UX.
    
- **`SameSite=Lax`:** Cookies are withheld on cross-site subrequests (images, frames) but sent on top-level navigations that use safe HTTP methods (GET). This is the modern default and recommended balance for most applications.
    
- **`SameSite=None`:** Cookies are sent in all contexts. Requires the `Secure` attribute. Use strictly for legitimate cross-site use cases (e.g., third-party widgets).
    

### Origin and Referer Validation

As a defense-in-depth measure, validate the `Origin` and `Referer` headers.

1. **Check Origin:** Ensure the `Origin` header matches the application's target origin. If the header is present but mismatches, reject the request.
    
2. **Fallback to Referer:** If `Origin` is null (can happen in certain redirects or privacy modes), check the `Referer`.
    
3. **Policy:** Requests with neither header should generally be rejected in high-security contexts, though this may impact legitimate users behind aggressive proxies.
    

### Specialized Considerations

#### GraphQL and JSON APIs

Standard CSRF attacks typically rely on `application/x-www-form-urlencoded`, `multipart/form-data`, or `text/plain`.

- **Content-Type Enforcement:** Enforcing `Content-Type: application/json` acts as a partial mitigation, as standard HTML forms cannot generate this header. However, this relies on CORS preflight configurations. If a CORS misconfiguration allows cross-origin `application/json` with custom headers, CSRF is possible. Always combine with token validation.
    

#### Login CSRF

Attackers may forge a login request to log a victim into the attacker's account, tracking their activity.

- **Mitigation:** Pre-sessions. Create a session and CSRF token _before_ authentication. Validate the token on the login endpoint. Upon successful authentication, rotate the session ID and generate a _new_ CSRF token to prevent session fixation and token leakage.
    

Related Topics: Cross-Origin Resource Sharing (CORS), Content Security Policy (CSP), Session Management Lifecycle, Secure Cookie Attributes.

---


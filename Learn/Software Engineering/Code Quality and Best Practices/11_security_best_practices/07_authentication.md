## Authentication


### Credential Storage and Cryptographic Handling

Storage of user secrets demands adherence to adaptive hashing algorithms resistant to GPU/ASIC acceleration and side-channel attacks.

- **Algorithm Selection:** Deprecate PBKDF2 and BCrypt in favor of **Argon2id**. Argon2id provides hybrid resistance against both trade-off attacks (Argon2i) and side-channel attacks (Argon2d).1
    
    - **Configuration:** Minimum recommended parameters include 1 pass (iteration), 64 MiB memory cost, and 1 thread (parallelism). Adjust `m_cost` and `t_cost` based on the server's available resources to ensure hashing takes approximately 500ms–1000ms.
        
- **Salting Strategy:** Generate a unique, cryptographically random salt (minimum 16 bytes) for every credential. Salts must be stored alongside the hash, not hardcoded.2
    
- **Peppering:** Implement a secret key (pepper) stored in a Hardware Security Module (HSM) or a secure vault (e.g., AWS KMS, HashiCorp Vault), separate from the database. This mitigates offline brute-force attacks if the database is compromised.
    
- **Timing Attack Mitigation:** Use constant-time comparison functions (e.g., `crypto.timingSafeEqual`) for all secret evaluations to prevent enumeration based on response latency.
    

### NIST 800-63B Alignment for Password Policies

Modern authentication standards prioritize entropy and usability over arbitrary complexity rules.3

- **Complexity Rules:** Remove requirements for special characters, uppercase/lowercase mixtures, and periodic rotation.4 These enforce predictable patterns (e.g., "Password1!").
    
- **Length Requirements:** Enforce a minimum length of 12 characters. Allow maximums up to 64+ characters to support passphrases.
    
- **Credential Screening:** Implement real-time checking against compromised credential databases (e.g., Have I Been Pwned, Pwned Passwords API) during registration and password changes. Reject passwords known to be breached.
    
- **Throttling:** Implement exponential backoff or CAPTCHA challenges after failed attempts rather than hard account lockouts, which facilitate Denial of Service (DoS) attacks against users.
    

### Session Management and Token Architecture

Secure state management requires rigorous control over token lifecycle and transport security.

#### JSON Web Tokens (JWT) vs. Opaque Tokens

- **Statelessness Risks:** Avoid using JWTs for long-lived sessions unless necessary for microservices inter-communication. JWTs cannot be easily revoked without implementing a blocklist, effectively reintroducing state.5
    
- **Opaque Tokens (Reference Tokens):** Prefer random string tokens stored in a high-performance store (Redis) for the frontend-to-backend context. This allows immediate revocation and centralized session control.
    

#### Cookie Security

- **Storage Location:** Never store sensitive tokens (Access/Refresh) in `localStorage` or `sessionStorage` due to XSS vulnerability.6 Store tokens in **HttpOnly** cookies.
    
- **Flags:**
    
    - `Secure`: Ensures transmission only over HTTPS.
        
    - `HttpOnly`: Prevents client-side scripts from accessing the token.7
        
    - `SameSite`: Set to `Strict` or `Lax` to mitigate Cross-Site Request Forgery (CSRF).8
        

#### Token Rotation and Refresh

- **Short-Lived Access Tokens:** Limit access token lifespan (e.g., 5–15 minutes).
    
- **Refresh Token Rotation:** Issue a new refresh token with every access token renewal request.9 Invalidate the old refresh token immediately.
    
- **Reuse Detection:** If an invalidated refresh token is presented, assume token theft and revoke the entire token family (all tokens associated with that user session).
    

### OAuth 2.0 and OpenID Connect (OIDC)

Implementation of federated identity must strictly follow current RFC best practices to avoid redirection and interception exploits.

- **Flow Selection:** Exclusively use the **Authorization Code Flow with Proof Key for Code Exchange (PKCE)**. Deprecate the Implicit Flow and Resource Owner Password Credentials Grant.
    
- **PKCE Implementation:**
    
    - Generate a `code_verifier` (high-entropy random string).10
        
    - Derive a `code_challenge` (SHA-256 hash of the verifier).11
        
    - Send the challenge in the authorization request and the verifier in the token request.
        
- **State Parameter:** Always include a cryptographically random `state` parameter to prevent CSRF on the callback endpoint.12
    
- **Open Redirect Protection:** Strictly validate the `redirect_uri` against a pre-registered allowlist using exact string matching (no regex or wildcards).13
    

### Multi-Factor Authentication (MFA)

- **FIDO2/WebAuthn:** Prioritize hardware-backed authentication (Passkeys, YubiKeys, TouchID/FaceID) as the primary MFA method due to phishing resistance.14
    
- **TOTP (Time-based One-Time Password):** Use as a fallback. Ensure the QR code generation URL is not logged and is generated over HTTPS.
    
- **SMS/Email MFA:** Deprecate as a primary factor due to SIM swapping and interception risks. If used, categorize as "Restricted" assurance level.
    
- **Recovery Codes:** Generate a set of one-time use recovery codes upon MFA setup.15 Hash these codes in the backend (similar to passwords) to prevent compromise if the database is leaked.
    

### Anti-Patterns and Common Vulnerabilities

- **Account Enumeration:** Ensure login and password recovery responses do not reveal whether an account exists.
    
    - _Bad:_ "User not found."
        
    - _Good:_ "If an account matches these credentials, a reset email has been sent."
        
- **Logging Secrets:** Configure logging frameworks to redact headers containing `Authorization`, `Cookie`, or specific JSON fields like `password` or `token`.16
    
- **Weak Randomness:** Utilize `CSPRNG` (Cryptographically Secure Pseudo-Random Number Generator) for all token, salt, and nonce generation. Never use standard `Math.random()`.
    
- **JWT Algorithm Confusion:** Explicitly verify the signature algorithm in the backend.17 Whitelist allowed algorithms (e.g., `RS256`, `EdDSA`) and reject `None` or `HS256` if using asymmetric keys (to prevent public key HMAC attacks).
    

**Related Topics:** Authorization (RBAC/ABAC), Cryptographic Key Management, Secure API Architecture, Input Validation/Sanitization.

---


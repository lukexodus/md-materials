## Security Code Review


Security code review is a specialized discipline distinct from general peer review. It focuses strictly on identifying security flaws, logic vulnerabilities, and implementation errors that could compromise the Confidentiality, Integrity, or Availability (CIA) of the system. It requires a mindset shift from "does this code work?" to "how can this code be abused?"

### Strategic Approach: Threat-Informed Reviews

Effective security reviews are not line-by-line reads of the entire codebase. They are targeted based on risk.

- **Attack Surface Analysis:** Identify all entry points (API endpoints, public methods, file parsers, socket listeners). These are the boundaries where trust levels change.
    
- **Threat Modeling Integration:** Use the application's Threat Model (e.g., STRIDE) to prioritize modules. If the threat model identifies "Privilege Escalation" as a high risk, the review must scrutinize the Authorization logic first.
    
- **Dependency Analysis:** Verify that third-party libraries are not just up-to-date (SCA) but are used securely. A secure library can be rendered insecure by improper configuration or misuse of its API.
    

### Taint Analysis Methodology

The core mechanic of a manual security review is **Taint Analysis**. This involves tracing data flow from entry to execution.

1. **Identify Sources:** Any external input (HTTP headers, query parameters, file uploads, database reads from untrusted tables, command-line arguments).
    
2. **Identify Sinks:** Functions that execute critical operations (SQL execution, OS command execution, HTML rendering, file system access).
    
3. **Trace the Path:** Follow the variable from Source to Sink.
    
    - **Verification:** Is the data validated (type/length/format checks)?
        
    - **Sanitization:** Is the data encoded or escaped explicitly before entering the Sink?
        
    - **Context:** Is the sanitization context-appropriate? (e.g., URL encoding is insufficient for HTML body contexts).
        

### Critical Inspection Zones

#### 1. Input Validation and Data Sanitization

- **Whitelist over Blacklist:** Verify that validation logic explicitly defines allowed patterns (e.g., Regex `^[a-zA-Z0-9]+$`) rather than attempting to filter out "bad" characters.
    
- **Canonicalization:** Ensure input is normalized (canonicalized) _before_ validation to prevent encoding bypasses (e.g., `..%2f` vs `../`).
    
- **Deserialization:** Scrutinize any use of native deserialization (e.g., Java `ObjectInputStream`, Python `pickle`). Look for type-checking barriers or gadget chain prevention.
    

#### 2. Authentication and Session Management

- **Hardcoded Credentials:** Scan for API keys, passwords, or cryptographic salts embedded in the source code.
    
- **Session Lifecycle:** Verify absolute timeouts, idle timeouts, and proper invalidation upon logout. Ensure session IDs are not exposed in URLs.
    
- **Password Storage:** Ensure passwords are hashed using slow algorithms (Argon2, bcrypt, PBKDF2) with per-user salts. Reject MD5 or SHA-family hashing without iteration.
    

#### 3. Cryptographic Implementation

- **Algorithm Selection:** Flag weak ciphers (DES, RC4) or modes (ECB). Ensure Authenticated Encryption (AES-GCM or ChaCha20-Poly1305) is used over simple confidentiality modes (AES-CBC without HMAC).
    
- **Randomness:** Verify that security-critical values (tokens, salts, keys) use a Cryptographically Secure Pseudo-Random Number Generator (CSPRNG) (e.g., `java.security.SecureRandom`, `/dev/urandom`) rather than statistical PRNGs (e.g., `Math.random()`).
    

#### 4. Error Handling and Logging

- **Information Leakage:** Review `catch` blocks to ensure stack traces, database schema details, or system paths are not returned to the client.
    
- **Log Injection:** Ensure user input written to logs is sanitized to prevent Log Forging attacks (inserting newlines to spoof log entries).
    
- **Sensitive Data in Logs:** Verify that PII, payment info, or auth tokens are redacted or masked before logging.
    

### Logic Flaws (Business Logic Vulnerabilities)

Automated tools (SAST) rarely catch these. They require human understanding of the domain.

- **Race Conditions:** Identify check-then-act sequences in multi-threaded or distributed environments.
    
    - _Example:_ Checking if a coupon is valid, then applying it in a separate transaction step, allowing parallel requests to use the same coupon multiple times.
        
- **Order of Operations:** Ensure that payment processing occurs _before_ order fulfillment and that authorization checks occur _before_ resource retrieval.
    
- **Rounding Errors:** In financial software, check for floating-point arithmetic errors that could be exploited for skimming.
    

### Automated vs. Manual Review

- **SAST (Static Application Security Testing):** Use tools (e.g., SonarQube, Checkmarx, Fortify) to catch syntactic patterns (SQL injection concatenation, unclosed resources).
    
    - _Limitation:_ High false-positive rate; cannot understand context or business rules.
        
- **Manual Review:** indispensable for architectural flaws, logic bugs, and access control complexity.
    

### Code Quality in Security

- **Complexity is the Enemy of Security:** High Cyclomatic Complexity increases the likelihood of hidden vulnerabilities. Complex conditional logic is harder to secure.
    
- **Dead Code:** Unreachable code should be removed. It increases the attack surface (e.g., an old, unpatched debug endpoint that was never removed).
    

Related Topics:

Threat Modeling (STRIDE/DREAD), Static Application Security Testing (SAST), Dynamic Application Security Testing (DAST), OWASP Top 10, OWASP ASVS (Application Security Verification Standard), Secure Software Development Life Cycle (SSDLC).

---



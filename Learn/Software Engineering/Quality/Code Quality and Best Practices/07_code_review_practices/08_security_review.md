## Security review


A security review is the systematic examination of an application's source code, architecture, and libraries to identify security flaws, logic vulnerabilities, and non-compliance with security policies. Unlike a standard code review which focuses on functionality and maintainability, a security review operates under the "adversarial mindset"—assessing not just how the application functions, but how it can be forced to malfunction or disclose protected data.

**Key Principles**

- **Shift Left:** Security reviews must occur early in the Software Development Life Cycle (SDLC). remediation costs increase exponentially as the project moves from design to development to production.
    
- **Defense in Depth:** The review must ensure that multiple layers of security controls exist. If one control fails (e.g., frontend validation), a secondary control (e.g., backend validation) must be in place to prevent exploitation.
    
- **Least Privilege:** Code should be reviewed to ensure it operates with the minimum permissions necessary. Database connections, file system access, and API tokens should be scoped strictly to the required task.
    
- **Secure Defaults:** The application should be secure by default. Optional features that increase the attack surface should require explicit activation.
    

**Methodologies**

1. Static Application Security Testing (SAST):
    
    White-box testing where tools analyze source code without execution. It is effective for finding buffer overflows, SQL injection patterns, and hardcoded secrets.
    
    - _Limitation:_ High false-positive rates; cannot detect runtime configuration issues.
        
2. Software Composition Analysis (SCA):
    
    Automated review of third-party open-source dependencies (libraries, frameworks). It maps the dependency tree against databases of known vulnerabilities (CVEs).
    
    - _Focus:_ "Do we use libraries with known exploits?" (e.g., Log4Shell).
        
3. Manual Auditing:
    
    Human review focused on business logic flaws that automated tools miss. This includes broken access controls, privilege escalation paths, and race conditions.
    
    - _Focus:_ "Can a user with 'Viewer' role call the 'Admin' delete API?"
        

**Common Review Targets**

- **Input Validation & Sanitization:**
    
    - **Verify:** All external inputs (URL parameters, headers, JSON bodies, file uploads) are treated as untrusted.
        
    - **Check:** Usage of strict allow-lists (whitelisting) over block-lists. Ensure output encoding is applied to prevent Cross-Site Scripting (XSS).
        
- **Authentication & Session Management:**
    
    - **Verify:** Passwords are hashed using slow, salted algorithms (Argon2, bcrypt, scrypt) rather than fast hashes (MD5, SHA-1).
        
    - **Check:** Session IDs are high-entropy, regenerated upon login, and flagged as `HttpOnly` and `Secure`.
        
- **Access Control (Authorization):**
    
    - **Verify:** Checks for "Insecure Direct Object References" (IDOR). If a user requests `/invoice/123`, the system must verify they own invoice 123.
        
    - **Check:** API endpoints enforce role checks on the server side, not just by hiding UI elements in the client.
        
- **Cryptography & Data Protection:**
    
    - **Verify:** Transit encryption (TLS 1.2+) is enforced. Data at rest is encrypted.
        
    - **Check:** Hardcoded secrets (API keys, passwords, private keys) are absent from the codebase. Secrets should be injected via environment variables or vaults.
        
- **Error Handling & Logging:**
    
    - **Verify:** Error messages shown to users are generic and do not leak stack traces or database schema details.
        
    - **Check:** Logs are sanitized to exclude PII (Personally Identifiable Information), auth tokens, or payment data.
        

**Example**

The following snippet illustrates a vulnerability commonly found during a security review and its remediation.

_Vulnerable Code (SQL Injection Risk):_

Python

```
# Vulnerability: Direct concatenation of user input into SQL query.
# An attacker can input "admin' --" to bypass password checks.
def login(username, password):
    query = "SELECT * FROM users WHERE user = '" + username + "' AND pass = '" + password + "'"
    db.execute(query)
```

_Remediated Code (Parameterized Query):_

Python

```
# Security Review Fix: Use parameterized queries/prepared statements.
# The database engine treats inputs as data, not executable code.
def login(username, password):
    query = "SELECT * FROM users WHERE user = %s AND pass = %s"
    db.execute(query, (username, password))
```

**Output**

The output of a security review is a **Threat Report** or **Vulnerability Assessment**. This document must classify findings by severity:

1. **Critical:** Immediate exploitation is possible; leads to system compromise or massive data breach (e.g., RCE, SQLi). Stops the release.
    
2. **High:** Difficult to exploit but high impact, or easy to exploit with moderate impact (e.g., Stored XSS).
    
3. **Medium:** Requires specific conditions or user interaction (e.g., CSRF without critical state change).
    
4. **Low/Info:** Best practice violations or hardening recommendations (e.g., missing security headers).
    

**Next Steps**

Upon completion of the review, findings are triaged. Critical and High vulnerabilities act as "release blockers." The process concludes with a verification re-test (regression test) to ensure fixes are effective and have not introduced new issues.

---


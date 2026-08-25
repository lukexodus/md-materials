## API Key Handling


### Security Architecture and Threat Model

API keys function primarily as **project identifiers** and **authorization tokens** for machine-to-machine communication, distinct from user authentication protocols like OAuth2 or OIDC. A compromised API key grants persistent access until revoked, making their handling a critical security vector.

The threat model focuses on three primary surfaces:

1. **Leakage in Transit:** Interception via Man-in-the-Middle (MitM) attacks.
    
2. **Leakage at Rest:** Exposure via source control, logs, or insecure storage.
    
3. **Leakage via Client:** Extraction from decompiled mobile binaries or browser inspection.
    

### Transmission Standards

Strict Header-Based Transmission

API keys must never be transmitted via URL Query Parameters (e.g., ?api_key=xyz).

- **Vulnerability:** URLs are frequently logged by proxies, web servers (access logs), and browser history. They are also visible in the `Referer` header sent to third-party sites.
    
- **Standard:** Use standard HTTP headers.
    
    - `Authorization: Bearer <key>` (Preferred for standardized parsing)
        
    - `X-API-Key: <key>` (Common custom header)
        

Transport Layer Security (TLS)

Transmission must occur exclusively over HTTPS (TLS 1.2+). The application should reject any non-SSL requests containing API keys with a 403 Forbidden or 426 Upgrade Required before attempting to validate the key, preventing accidental plaintext leakage.

### Storage and Persistence Strategy

Server-Side Storage (Provider)

Treat API keys with the same rigor as passwords.

- **Hashing:** Do not store API keys in plaintext in the database. Store a cryptographic hash (e.g., SHA-256 or Argon2).
    
- **Implication:** The key is displayed to the user _only once_ upon generation. If lost, it must be regenerated. This prevents an attacker with database read access from harvesting valid keys.
    
- **Encryption:** If the architecture requires displaying the key later (less secure), use high-entropy symmetric encryption (AES-256-GCM) with keys managed by a dedicated KMS (Key Management Service).
    

**Application-Side Storage (Consumer)**

- **Environment Variables:** Inject keys via environment variables at runtime.
    
- **Secret Managers:** In containerized environments (Kubernetes), mount keys as volumes via secrets management systems (HashiCorp Vault, AWS Secrets Manager) rather than baking them into Docker images.
    
- **Git Prevention:** Implement pre-commit hooks (e.g., `git-secrets`, `trufflehog`) to scan for high-entropy strings preventing accidental commits to version control.
    

### Client-Side Exposure and Proxying

Embedding API keys in Single Page Applications (SPAs) or Mobile Apps constitutes a critical vulnerability, as these environments are fundamentally public.

The Proxy Pattern (Backend for Frontend - BFF)

To protect keys that interact with third-party services (e.g., OpenAI, Stripe):

1. **Do not** call the third-party API directly from the client.
    
2. **Do** route the request to your own backend server.
    
3. **Attach** the API key within your secure backend environment.
    
4. **Forward** the request to the third-party service.
    

Exception Handling (Public Keys)

Some services (Google Maps, Firebase) require client-side keys. In these specific cases:

- **Referrer Restrictions:** Configure the provider to accept requests only from specific domains (HTTP `Referer`).
    
- **IP Allow-listing:** Restrict usage to specific server IP addresses (if applicable).
    
- **Service Scope:** Restrict the key's permissions to the bare minimum required services (e.g., Maps JavaScript API only).
    

### Key Lifecycle Management

Rotation and Expiry

Static keys are a security liability. Implement mechanisms for key rotation without downtime:

1. **Dual-Key State:** Support "Active" and "Decommissioning" states.
    
2. **Rollover:** Generate a new key and distribute it.
    
3. **Grace Period:** Allow the old key to function for a set window (e.g., 24 hours) to allow consumers to update configurations.
    

Revocation

Build immediate "kill switches" for keys. If a leak is detected, the system must be able to invalidate a specific key instantly without a deployment. This requires a caching strategy (e.g., Redis) that balances performance with the Time-to-Live (TTL) of the revocation check.

### Rate Limiting and Quotas

API keys serve as the primary identifier for resource governance.

- **Throttling:** Implement Token Bucket or Leaky Bucket algorithms keyed by the API key hash.
    
- **Quotas:** Enforce hard caps on usage (e.g., requests per month) to prevent billing anomalies or DoS attacks.
    
- **Anomaly Detection:** Monitor for usage spikes or geo-hopping (accessing from disparate locations simultaneously), which may indicate a compromised key.
    

### Implementation: Constant-Time Comparison

When validating API keys in backend logic, avoid standard string comparison operators (`==` or `.equals()`). These function with "fail-fast" logic, returning false at the first mismatched character. This behavior allows attackers to deduce the key character-by-character using timing attacks.

**Secure Implementation (Python Example):**

Python

```
import hmac

def validate_api_key(incoming_key, stored_key):
    # hmac.compare_digest implements constant-time comparison
    if not hmac.compare_digest(incoming_key, stored_key):
        raise AuthenticationError("Invalid API Key")
```

**Secure Implementation (Java Example):**

Java

```
import java.security.MessageDigest;

public boolean slowEquals(byte[] a, byte[] b) {
    int diff = a.length ^ b.length;
    for (int i = 0; i < a.length && i < b.length; i++)
        diff |= a[i] ^ b[i];
    return diff == 0;
}
```

---


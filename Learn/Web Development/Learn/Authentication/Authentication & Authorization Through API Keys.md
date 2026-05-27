# Authentication & Authorization Through API Keys

## What Are API Keys

An API key is a string token issued by a service that identifies and authenticates the caller of an API. It is passed with each request so the server can verify who is making the call before processing it.

API keys serve two distinct functions:

- **Authentication** — confirming the identity of the caller ("who are you?")
- **Authorization** — determining what the caller is allowed to do ("what can you do?")

These are separate concerns. A key can authenticate a caller while still being denied access to specific resources.

---

## How API Keys Work

At a high level, the flow is:

1. A client includes an API key in an outbound request.
2. The server extracts the key from the request.
3. The server looks up the key in its store (database, cache, secrets manager).
4. If the key is valid, the server identifies the associated account or service.
5. The server checks permissions tied to that key.
6. The request is allowed or rejected accordingly.

The key itself is typically a randomly generated, cryptographically secure string. It does not contain claims or identity information in plain text (unlike JWTs), so its meaning is opaque without the server-side lookup.

---

## Where API Keys Are Passed

### Authorization Header (Bearer Token)

The most widely used pattern:

```http
GET /api/resource HTTP/1.1
Authorization: Bearer sk-abc123xyz
```

### Custom Header

Some APIs define their own header name:

```http
X-API-Key: sk-abc123xyz
```

### Query Parameter

Convenient for testing but discouraged in production because keys appear in URLs, access logs, and browser history:

```
GET /api/resource?api_key=sk-abc123xyz
```

### Request Body

Occasionally used in POST requests, though this is non-standard and generally not recommended:

```json
{
  "api_key": "sk-abc123xyz",
  "data": {}
}
```

---

## Generating API Keys

### Properties of a Secure Key

- Generated using a cryptographically secure random number generator (CSPRNG)
- Sufficient entropy — typically 128 to 256 bits
- URL-safe characters (alphanumeric, hyphens, underscores)
- Prefixed for readability and tooling (e.g., `sk_live_`, `pk_test_`)

### Generation in Common Languages

**Python**

```python
import secrets
import string

def generate_api_key(prefix="sk", length=32):
    alphabet = string.ascii_letters + string.digits
    token = ''.join(secrets.choice(alphabet) for _ in range(length))
    return f"{prefix}_{token}"
```

**Node.js**

```javascript
const crypto = require('crypto');

function generateApiKey(prefix = 'sk') {
  const token = crypto.randomBytes(24).toString('base64url');
  return `${prefix}_${token}`;
}
```

**Go**

```go
import (
    "crypto/rand"
    "encoding/base64"
    "fmt"
)

func generateApiKey(prefix string) (string, error) {
    b := make([]byte, 24)
    if _, err := rand.Read(b); err != nil {
        return "", err
    }
    return fmt.Sprintf("%s_%s", prefix, base64.URLEncoding.EncodeToString(b)), nil
}
```

---

## Storing API Keys Securely

### Server-Side Storage

Never store API keys in plaintext. Treat them like passwords:

1. Generate the key and show it to the user **once**.
2. Hash the key using a secure algorithm (e.g., SHA-256 or bcrypt).
3. Store only the hash in the database.
4. On each request, hash the incoming key and compare it to the stored hash.

**Example — hashing with SHA-256 (Python):**

```python
import hashlib

def hash_api_key(raw_key: str) -> str:
    return hashlib.sha256(raw_key.encode()).hexdigest()
```

> **Note:** SHA-256 is fast, which is acceptable here because API keys are long and random (unlike passwords). Bcrypt is more appropriate when keys are short or user-chosen.

### Client-Side Storage

|Environment|Recommended Storage|
|---|---|
|Server / backend|Environment variables or secrets manager|
|CI/CD|Secrets vault (e.g., GitHub Actions secrets)|
|Mobile app|Keychain (iOS) / Keystore (Android)|
|Browser (frontend)|**Avoid storing API keys in browsers entirely**|

Never hardcode keys in source files or commit them to version control.

---

## Transmitting API Keys Safely

- Always use **HTTPS/TLS**. An API key sent over plaintext HTTP is trivially intercepted.
- Avoid keys in query parameters in production — prefer headers.
- Set `Referrer-Policy` and avoid logging headers that contain keys.
- Scrub keys from error messages, stack traces, and logs.

---

## Key Scoping and Permissions

A key should carry only the permissions it needs — the principle of least privilege.

### Scope Design Patterns

**Resource-based scopes**

```
read:users
write:users
delete:users
read:orders
```

**Action-based scopes**

```
read
write
admin
```

**Environment scopes**

```
live
test
sandbox
```

Keys can be assigned a combination of scopes at creation time. The server enforces these on every request.

### Implementation Sketch

```python
API_KEY_PERMISSIONS = {
    "sk_abc123": ["read:users", "read:orders"],
    "sk_def456": ["read:users", "write:users", "read:orders", "write:orders"],
}

def authorize(api_key: str, required_scope: str) -> bool:
    scopes = API_KEY_PERMISSIONS.get(api_key, [])
    return required_scope in scopes
```

In practice, this lookup hits a database or cache rather than an in-memory dict.

---

## Rate Limiting

Rate limiting ties to the API key so each caller has an independent quota.

### Common Algorithms

**Fixed Window** — Count requests in a time window (e.g., 1,000 requests per minute). Simple but susceptible to bursting at window boundaries.

**Sliding Window** — Track request timestamps; count only those within the last N seconds. More accurate, higher memory cost.

**Token Bucket** — Each key holds a bucket of tokens replenished at a fixed rate. A request consumes one token. Allows short bursts while enforcing average rate.

**Leaky Bucket** — Requests are queued and processed at a fixed rate. Smooths traffic but adds latency under load.

### Response Headers

Return rate limit state so clients can self-throttle:

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 847
X-RateLimit-Reset: 1716000000
Retry-After: 30
```

Return `429 Too Many Requests` when a key is over limit.

---

## Key Lifecycle Management

### Issuance

- Generate on user request via dashboard or API.
- Display the full key **once only** at creation.
- Store only the hash.
- Record metadata: created at, created by, label, expiry, scopes.

### Rotation

Key rotation replaces an existing key with a new one. Best practices:

- Support **overlap periods** — old and new keys both valid briefly to allow zero-downtime rotation.
- Notify the key owner before the old key expires.
- Automate rotation in secrets managers where possible (e.g., AWS Secrets Manager, HashiCorp Vault).

### Revocation

- Invalidate immediately on suspected compromise.
- Provide a revoke endpoint or dashboard action.
- Log the revocation event with timestamp and actor.
- On revocation, subsequent requests with that key return `401 Unauthorized`.

### Expiry

Keys can carry a hard expiry date. On expiry, the key is automatically invalid. Short-lived keys reduce exposure window if compromised.

---

## Detecting and Responding to Compromised Keys

### Detection Signals

- Unusual request volume or geographic origin
- Requests at atypical hours
- Accessing resources outside normal patterns
- Reports from secret scanning tools (e.g., GitHub secret scanning, truffleHog)

### Response Steps

1. Revoke the key immediately.
2. Issue a new key.
3. Audit logs for unauthorized actions taken with the compromised key.
4. Notify the key owner.
5. If sensitive data was accessed, follow your incident response and disclosure procedures.

---

## Logging and Auditing

Log key usage in a way that supports investigation without exposing secrets:

```json
{
  "timestamp": "2026-05-17T08:42:00Z",
  "key_id": "key_9f3a",
  "key_prefix": "sk_live_",
  "endpoint": "POST /api/orders",
  "ip": "203.0.113.45",
  "status": 200,
  "latency_ms": 43
}
```

- Log the **key ID or prefix**, never the full key.
- Retain logs long enough for forensic review.
- Alert on repeated `401` or `403` responses from a single key — may indicate probing or a misconfigured client.

---

## Common HTTP Status Codes for Auth Failures

|Code|Meaning|When to Use|
|---|---|---|
|`400 Bad Request`|Malformed request, missing key field|Key field absent or unparseable|
|`401 Unauthorized`|Key missing, invalid, or expired|Authentication failed|
|`403 Forbidden`|Key valid, but lacks permission|Authorization failed|
|`429 Too Many Requests`|Rate limit exceeded|Quota exhausted|

Use `401` vs `403` correctly — they communicate different failure modes to the caller.

---

## API Keys vs Other Auth Mechanisms

|Mechanism|Stateless|User Identity|Short-lived|Suitable for|
|---|---|---|---|---|
|API Key|No (server lookup)|No (service identity)|Optional|Service-to-service, M2M|
|JWT|Yes|Yes|Yes (by design)|User sessions, delegated auth|
|OAuth 2.0|Depends on token type|Yes|Yes|Third-party delegated access|
|mTLS|Yes|Via certificate|Via cert expiry|High-trust service mesh|

API keys are best suited for server-to-server communication and machine-to-machine (M2M) scenarios where a human user is not directly involved in each request.

---

## Security Checklist

- [ ] Keys generated with CSPRNG, minimum 128-bit entropy
- [ ] Keys hashed before storage, never stored in plaintext
- [ ] Full key shown to user only once at creation
- [ ] All traffic over HTTPS/TLS
- [ ] Keys never in query parameters in production
- [ ] Keys not logged or included in error responses
- [ ] Keys never committed to version control
- [ ] Scopes assigned following least privilege
- [ ] Rate limiting enforced per key
- [ ] Key expiry enforced
- [ ] Rotation procedure documented and tested
- [ ] Revocation available and immediate
- [ ] Audit logging in place (key ID only, not full key)
- [ ] Monitoring and alerting on anomalous usage
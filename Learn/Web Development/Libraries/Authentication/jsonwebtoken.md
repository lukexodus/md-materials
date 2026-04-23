# JSON Web Token (JWT) — Comprehensive Guide

## What is a JWT?

A JWT is a compact, URL-safe token format defined in [RFC 7519](https://datatools.ietf.org/html/rfc7519). It encodes a set of claims as a JSON object that can be cryptographically signed (and optionally encrypted).

---

## Structure

A JWT has three Base64URL-encoded parts separated by dots:

```
header.payload.signature
```

### 1. Header

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

### 2. Payload (Claims)

```json
{
  "sub": "1234567890",
  "name": "Jane Doe",
  "iat": 1516239022,
  "exp": 1516242622
}
```

**Registered claim names (from RFC 7519):**

|Claim|Meaning|
|---|---|
|`iss`|Issuer|
|`sub`|Subject|
|`aud`|Audience|
|`exp`|Expiration time (Unix timestamp)|
|`nbf`|Not before|
|`iat`|Issued at|
|`jti`|JWT ID (unique identifier)|

### 3. Signature

```
HMACSHA256(
  base64url(header) + "." + base64url(payload),
  secret
)
```

---

## `jsonwebtoken` npm Package

The most widely used Node.js library for working with JWTs.

### Installation

```bash
npm install jsonwebtoken
```

---

## Core API

### `jwt.sign(payload, secret, [options])`

Creates a signed token.

```js
const jwt = require('jsonwebtoken');

const token = jwt.sign(
  { userId: 42, role: 'admin' },
  'your-secret-key',
  { expiresIn: '1h' }
);
```

**Key options:**

|Option|Type|Description|
|---|---|---|
|`expiresIn`|string/number|e.g. `'2h'`, `'7d'`, `3600` (seconds)|
|`notBefore`|string/number|Token not valid before this time|
|`audience`|string/string[]|Sets `aud` claim|
|`issuer`|string|Sets `iss` claim|
|`subject`|string|Sets `sub` claim|
|`jwtid`|string|Sets `jti` claim|
|`algorithm`|string|Default: `'HS256'`|
|`noTimestamp`|boolean|Omit `iat` if `true`|

---

### `jwt.verify(token, secret, [options], [callback])`

Verifies and decodes a token. **Throws** if invalid.

```js
// Synchronous
try {
  const decoded = jwt.verify(token, 'your-secret-key');
  console.log(decoded); // { userId: 42, role: 'admin', iat: ..., exp: ... }
} catch (err) {
  // Handle error (see Error Types below)
}

// Asynchronous (callback)
jwt.verify(token, 'your-secret-key', (err, decoded) => {
  if (err) return res.status(401).json({ error: err.message });
  console.log(decoded);
});
```

**Key verify options:**

|Option|Description|
|---|---|
|`algorithms`|Whitelist allowed algorithms (recommended)|
|`audience`|Validate `aud` claim|
|`issuer`|Validate `iss` claim|
|`subject`|Validate `sub` claim|
|`clockTolerance`|Seconds of leeway for `exp`/`nbf`|
|`ignoreExpiration`|Skip expiry check (use carefully)|
|`complete`|Return `{ header, payload, signature }` instead of just payload|

---

### `jwt.decode(token, [options])`

Decodes **without verifying**. Never use for authentication.

```js
const decoded = jwt.decode(token);
const full = jwt.decode(token, { complete: true });
// full = { header: {...}, payload: {...}, signature: '...' }
```

> ⚠️ `decode()` does not check the signature. [Inference] An attacker could construct an arbitrary payload that `decode()` would accept — this is not a reliable security boundary. Behavior not guaranteed across all versions.

---

## Algorithms

### Symmetric (HMAC) — shared secret

```js
jwt.sign(payload, 'shared-secret', { algorithm: 'HS256' }); // also HS384, HS512
```

### Asymmetric (RSA / ECDSA) — public/private key pair

```js
const fs = require('fs');
const privateKey = fs.readFileSync('private.pem');
const publicKey  = fs.readFileSync('public.pem');

// Sign with private key
const token = jwt.sign(payload, privateKey, { algorithm: 'RS256' });

// Verify with public key
const decoded = jwt.verify(token, publicKey, { algorithms: ['RS256'] });
```

Supported asymmetric algorithms: `RS256`, `RS384`, `RS512`, `ES256`, `ES384`, `ES512`, `PS256`, `PS384`, `PS512`

---

## Error Types

All thrown by `jwt.verify()`:

|Error|Cause|
|---|---|
|`JsonWebTokenError`|Malformed token, invalid signature, wrong algorithm|
|`TokenExpiredError`|`exp` has passed — has `.expiredAt` property|
|`NotBeforeError`|Current time is before `nbf` — has `.date` property|

```js
const { JsonWebTokenError, TokenExpiredError, NotBeforeError } = require('jsonwebtoken');

try {
  jwt.verify(token, secret);
} catch (err) {
  if (err instanceof TokenExpiredError) {
    console.log('Expired at:', err.expiredAt);
  } else if (err instanceof JsonWebTokenError) {
    console.log('Invalid token:', err.message);
  }
}
```

---

## Common Patterns

### Express.js Auth Middleware

```js
function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing token' });
  }

  const token = authHeader.split(' ')[1];

  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET, {
      algorithms: ['HS256']  // always whitelist algorithms
    });
    next();
  } catch (err) {
    return res.status(401).json({ error: err.message });
  }
}
```

### Token Refresh Pattern

```js
// Issue short-lived access token + long-lived refresh token
const accessToken  = jwt.sign({ userId }, secret, { expiresIn: '15m' });
const refreshToken = jwt.sign({ userId }, refreshSecret, { expiresIn: '7d' });

// On expiry: verify refresh token, issue new access token
```

### JWKS / Dynamic Key Retrieval

```js
const jwksClient = require('jwks-rsa');

const client = jwksClient({ jwksUri: 'https://YOUR_DOMAIN/.well-known/jwks.json' });

function getKey(header, callback) {
  client.getSigningKey(header.kid, (err, key) => {
    callback(err, key?.getPublicKey());
  });
}

jwt.verify(token, getKey, { algorithms: ['RS256'] }, (err, decoded) => { ... });
```

---

## Security Checklist

|Practice|Why|
|---|---|
|Always specify `algorithms` in `verify()`|Prevents algorithm confusion attacks (e.g. `"alg": "none"`)|
|Use `RS256`/`ES256` for distributed systems|Private key signs, any service can verify with public key|
|Keep secrets out of source code|Use environment variables or a secrets manager|
|Set reasonable `expiresIn`|Limits the window of a stolen token|
|Validate `aud` and `iss` in `verify()`|Prevents token reuse across services|
|Never trust `decode()` for access control|Does not verify the signature|
|Store tokens appropriately client-side|`HttpOnly` cookies reduce XSS exposure vs. `localStorage` — [Inference] both have tradeoffs; neither approach is universally superior|
|Implement token revocation if needed|JWTs are stateless; a blocklist (Redis, DB) is a common approach|

---

## What JWTs Are Not

- **Not a session store** — the server holds no state by default
- **Not encrypted by default** — the payload is Base64-encoded, not secret. Anyone can read it. Use JWE (JSON Web Encryption) if confidentiality of claims is required.
- **Not revocable by default** — a valid token stays valid until expiry unless you implement a blocklist

---

## Quick Reference

```js
const jwt = require('jsonwebtoken');

// Sign
const token = jwt.sign({ id: 1 }, process.env.SECRET, { expiresIn: '1h' });

// Verify (sync)
const payload = jwt.verify(token, process.env.SECRET, { algorithms: ['HS256'] });

// Decode only (no verification)
const raw = jwt.decode(token, { complete: true });
```
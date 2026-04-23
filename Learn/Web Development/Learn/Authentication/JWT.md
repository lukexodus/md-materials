# JWT

**JWT (JSON Web Token)** is a compact, URL-safe way to represent **claims (information)** between two parties—commonly used for **authentication and authorization** in web apps and APIs.

---

## 🔐 What JWT is used for

* Logging users in (authentication)
* Keeping users “logged in” without storing sessions on the server
* Passing secure info between frontend and backend

---

## 🧱 JWT structure

A JWT has **3 parts**, separated by dots:

```
header.payload.signature
```

### 1. Header

Describes the token type and signing algorithm:

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

---

### 2. Payload (Claims)

The actual data (NOT encrypted, just encoded):

```json
{
  "userId": 123,
  "role": "admin",
  "exp": 1710000000
}
```

Common claims:

* `sub` → subject (user id)
* `exp` → expiration time
* `iat` → issued at

---

### 3. Signature

Ensures the token wasn’t tampered with:

```
HMACSHA256(
  base64Url(header) + "." + base64Url(payload),
  secret
)
```

---

## 🔄 How JWT works (simple flow)

1. User logs in with username/password
2. Server verifies credentials
3. Server creates a JWT and sends it back
4. Client stores it (usually localStorage or cookie)
5. Client sends JWT on every request:

   ```
   Authorization: Bearer <token>
   ```
6. Server verifies signature → allows or denies access

---

## ⚡ Why JWT is popular

* No need to store sessions on server (stateless)
* Works well for APIs and microservices
* Easy to scale

---

## ⚠️ Important security notes

* JWT is **not encrypted by default** (payload is readable)
* Always use HTTPS
* Keep tokens short-lived
* Store securely (HttpOnly cookies preferred over localStorage in many cases)

---

If you want, I can also explain:

* JWT vs Session authentication
* How refresh tokens work
* How to implement JWT in Node.js or Spring Boot

---

# HMAC-SHA256

**HMAC-SHA256** is a specific way to create a **secure message authentication code (MAC)** using:

* **HMAC** = *Hash-based Message Authentication Code*
* **SHA-256** = a cryptographic hash function from the SHA-2 family

---

## 🔑 What it does (in plain terms)

HMAC-SHA256 lets two parties who share a **secret key**:

* Verify **data integrity** (message wasn’t changed)
* Verify **authenticity** (came from someone who knows the key)

It does **NOT encrypt** the message — it just signs it.

---

## ⚙️ How it works (conceptually)

HMAC wraps a hash function (like SHA-256) with a secret key:

```
HMAC(key, message) = SHA256((key ⊕ opad) || SHA256((key ⊕ ipad) || message))
```

* `⊕` = XOR
* `||` = concatenation
* `ipad`, `opad` = fixed padding constants

👉 The double hashing prevents attacks that affect plain hashing (like length extension).

---

## 🧠 Why not just SHA-256 alone?

Using plain SHA-256:

```
hash = SHA256(message)
```

❌ Anyone can recompute it → no authentication

Using HMAC:

```
mac = HMAC(key, message)
```

✅ Only someone with the key can generate/verify it

---

## 🔐 Common use cases

### 1. API request signing

* AWS, Stripe, etc.
* Prevent tampering and replay attacks

### 2. JWT signatures

* In JSON Web Token using `HS256`
* Verifies token integrity

### 3. Webhooks

* GitHub/Stripe send HMAC signatures to verify origin

### 4. Secure cookies / CSRF tokens

* Ensure data wasn’t modified client-side

---

## 💻 Example

### Node.js

```js
const crypto = require('crypto');

const key = 'secret-key';
const message = 'hello world';

const hmac = crypto
  .createHmac('sha256', key)
  .update(message)
  .digest('hex');

console.log(hmac);
```

---

### Python

```python
import hmac
import hashlib

key = b'secret-key'
message = b'hello world'

hmac_result = hmac.new(key, message, hashlib.sha256).hexdigest()
print(hmac_result)
```

---

## ⚠️ Security notes

* Use a **strong random key** (not a password)
* Compare HMACs using **constant-time comparison** (to avoid timing attacks)
* Never reuse the same key across unrelated systems

---

## 🧩 Mental model

Think of HMAC-SHA256 as:

> **“A tamper-proof seal that only people with the secret key can create.”**

---

# Message Authentication Code (MAC)

## 🔐 Message Authentication Code (MAC)

A **Message Authentication Code (MAC)** is a short piece of data that proves:
1. ✅ The message **was not altered** (integrity)
2. ✅ The message came from someone who knows the **shared secret key** (authentication)

---

## 🧠 Core idea

> A MAC is like a **tamper-proof seal** created using a **secret key**.

* Sender computes MAC using **key + message**
* Receiver recomputes it with the same key
* If they match → message is trusted

---

## ⚙️ How it works

```text
MAC = MAC(key, message)
```

Send:

```text
(message, MAC)
```

Verify:

```text
MAC(key, message) == received MAC ?
```

If equal → ✔ valid
If not → ❌ tampered or fake

---

## 🔑 Important: shared secret

* Both sender and receiver must share the **same secret key**
* Unlike digital signatures, MACs are **symmetric**

---

## 🔒 Common types of MACs

### 1. HMAC (Hash-based MAC)

Uses a hash function like SHA-256

Example:

* HMAC-SHA256

👉 Most widely used in practice

---

### 2. CMAC (Cipher-based MAC)

Uses block ciphers like AES

* Based on encryption instead of hashing

---

### 3. GMAC

Used with AES-GCM (common in modern encryption like TLS)

---

## 📦 Where MACs are used

### 🌐 Secure protocols

* Transport Layer Security → ensures message integrity
* IPsec → authenticates packets

---

### 🔑 APIs & authentication

* Request signing (e.g., HMAC headers)

---

### 🪪 Tokens

* JSON Web Token (HS256)

---

### 💾 Data protection

* Secure cookies
* CSRF tokens

---

## ⚠️ MAC vs Hash vs Digital Signature

| Feature             | Hash (SHA-256) | MAC (HMAC)   | Digital Signature   |
| ------------------- | -------------- | ------------ | ------------------- |
| Key required        | ❌ No           | ✅ Yes        | ✅ Yes (private key) |
| Verifies integrity  | ✅ Yes          | ✅ Yes        | ✅ Yes               |
| Verifies sender     | ❌ No           | ✅ Shared key | ✅ Public/private    |
| Public verification | ❌ No           | ❌ No         | ✅ Yes               |

👉 Key difference:

* MAC = **shared secret**
* Signature = **public-key cryptography**

---

## 🚫 Common mistake

**Using plain hash instead of MAC:**

```text
hash = SHA256(message)
```

❌ Anyone can recompute → no authentication

---

## 🧩 Mental model

* Hash → “fingerprint of data”
* MAC → “fingerprint + secret stamp”
* Signature → “fingerprint + legally verifiable signature”

---

## 🔐 Why MACs are secure

A good MAC (like HMAC):

* Resists **forgery**
* Resists **preimage attacks**
* Protects against **tampering**

---

# Comprehensive Guide to the `bcrypt` Node.js Library

`bcrypt` is a Node.js library for hashing and verifying passwords using the bcrypt algorithm. It is a native addon, meaning it compiles C++ bindings during installation and runs hashing operations outside the main JavaScript thread.

---

## What bcrypt Does

bcrypt is a password hashing function designed by Niels Provos and David Mazières in 1999, based on the Blowfish cipher. It has three properties that make it suitable for password storage:

- **Salting** — a random salt is generated and embedded in the hash, so two identical passwords produce different hashes.
- **Cost factor** — the number of hashing rounds is configurable and exponential. Increasing the cost by 1 doubles the computation time.
- **One-way** — there is no way to reverse a bcrypt hash to recover the original password. Verification works by hashing the candidate password with the same salt and comparing results.

---

## `bcrypt` vs `bcryptjs`

Two packages implement the same algorithm:

||`bcrypt`|`bcryptjs`|
|---|---|---|
|Implementation|Native C++ addon|Pure JavaScript|
|Performance|Faster|Slower|
|Installation|Requires build tools|No native build required|
|Node compatibility|Tied to Node ABI version|Any environment|

Use `bcrypt` when performance matters and you can install build tools. Use `bcryptjs` when you cannot (some cloud environments, WebAssembly targets, or if you want to avoid native compilation issues). The API is identical between the two.

---

## Installation

```bash
npm install bcrypt
```

`bcrypt` requires Python and a C++ compiler during installation because it includes native bindings.

On Ubuntu/Debian:

```bash
sudo apt-get install build-essential
```

On macOS, Xcode Command Line Tools are sufficient:

```bash
xcode-select --install
```

On Windows, install the `windows-build-tools` package or Visual Studio Build Tools.

If installation fails due to build issues, `bcryptjs` is a drop-in replacement:

```bash
npm install bcryptjs
```

---

## Core Concepts

### Salt

A salt is a random string generated before hashing. It is prepended to the password before the hash function runs, and it is stored as part of the resulting hash string. Because each password gets a unique salt, two users with the same password will have different hashes.

You never need to store the salt separately. It is embedded in the hash output.

### Cost Factor (Salt Rounds)

The cost factor, also called salt rounds, controls how computationally expensive the hash is. The actual number of iterations is `2^rounds`. A value of `10` means `1024` iterations; `12` means `4096`.

Higher cost makes brute-force attacks slower. It also makes your server slower for each login. A common starting point is `10–12`. As hardware improves over time, increasing this value is advisable for new passwords.

### Hash Format

A bcrypt hash looks like this:

```
$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
```

Breaking it down:

- `$2b$` — algorithm version (`2b` is the current standard)
- `10` — cost factor
- `N9qo8uLOickgx2ZMRZoMye` — 22 characters of base64-encoded salt (128 bits)
- `IjZAgcfl7p92ldGxad68LJZdL17lhWy` — 31 characters of base64-encoded hash

The total output is always 60 characters.

---

## API

`bcrypt` provides both async (Promise-based and callback-based) and synchronous versions of each operation.

### Generating a Salt

```js
// Async (Promise)
const salt = await bcrypt.genSalt(rounds);

// Async (callback)
bcrypt.genSalt(rounds, (err, salt) => { });

// Sync
const salt = bcrypt.genSaltSync(rounds);
```

`rounds` defaults to `10` if omitted.

In most cases you do not need to call `genSalt` directly. The `hash` function accepts a rounds integer and generates the salt internally.

### Hashing a Password

```js
const bcrypt = require('bcrypt');

// With auto-generated salt (recommended)
const hash = await bcrypt.hash(plainPassword, saltRounds);

// With a pre-generated salt
const salt = await bcrypt.genSalt(12);
const hash = await bcrypt.hash(plainPassword, salt);

// Sync
const hash = bcrypt.hashSync(plainPassword, saltRounds);
```

Passing an integer as the second argument tells the library to generate a salt with that many rounds. Passing a string tells it to use that string as the salt directly.

### Verifying a Password

```js
const match = await bcrypt.compare(plainPassword, hash);
// match is true or false

// Sync
const match = bcrypt.compareSync(plainPassword, hash);
```

`compare` extracts the salt from the stored hash, re-hashes the candidate password with that salt, and compares the results. You never need to extract or manage the salt yourself.

---

## Usage Pattern: Registration and Login

### Registration

```js
const bcrypt = require('bcrypt');

const SALT_ROUNDS = 12;

async function registerUser(username, plainPassword) {
  const hash = await bcrypt.hash(plainPassword, SALT_ROUNDS);

  // Store username and hash in the database
  await db.users.create({ username, passwordHash: hash });
}
```

### Login

```js
async function loginUser(username, plainPassword) {
  const user = await db.users.findOne({ username });

  if (!user) {
    // Do not reveal whether the username exists
    return false;
  }

  const match = await bcrypt.compare(plainPassword, user.passwordHash);
  return match;
}
```

---

## Async vs Sync

The synchronous functions (`hashSync`, `compareSync`, `genSaltSync`) block the Node.js event loop for the duration of the hashing operation. Because bcrypt is intentionally slow, this can block request handling for tens to hundreds of milliseconds depending on your cost factor.

Use the async versions in any server context. The async functions run hashing in a thread pool managed by libuv, leaving the event loop free.

```js
// Avoid in servers
const hash = bcrypt.hashSync(password, 12);

// Prefer
const hash = await bcrypt.hash(password, 12);
```

The sync versions are appropriate in scripts, CLI tools, or one-off operations where blocking is acceptable.

---

## Choosing a Cost Factor

There is no universally correct value. The goal is to make each hash take long enough that large-scale brute force is impractical, without making your login endpoint unacceptably slow.

A rough benchmark on a mid-range server (results vary by hardware):

|Rounds|Approximate time per hash|
|---|---|
|10|~65 ms|
|12|~250 ms|
|14|~1 s|
|16|~4 s|

A common recommendation is to target 100–300 ms per hash on your production hardware and pick the highest rounds value that achieves this. You can measure it:

```js
const bcrypt = require('bcrypt');

async function benchmark(rounds) {
  const start = Date.now();
  await bcrypt.hash('test', rounds);
  console.log(`Rounds ${rounds}: ${Date.now() - start}ms`);
}

for (let r = 10; r <= 14; r++) {
  await benchmark(r);
}
```

[Inference] As hardware improves, the same rounds value becomes cheaper to brute-force. Increasing rounds over time for newly created passwords (while keeping older hashes valid) is a reasonable long-term strategy. This behavior is not automatic; you must implement it yourself.

---

## Re-hashing on Login

To upgrade hashes to a higher cost factor over time without requiring password resets, re-hash on successful login:

```js
const CURRENT_ROUNDS = 12;

async function loginUser(username, plainPassword) {
  const user = await db.users.findOne({ username });
  if (!user) return false;

  const match = await bcrypt.compare(plainPassword, user.passwordHash);
  if (!match) return false;

  // Check if the stored hash uses the current cost factor
  const rounds = bcrypt.getRounds(user.passwordHash);
  if (rounds < CURRENT_ROUNDS) {
    const newHash = await bcrypt.hash(plainPassword, CURRENT_ROUNDS);
    await db.users.update({ username }, { passwordHash: newHash });
  }

  return true;
}
```

### `bcrypt.getRounds(hash)`

Returns the cost factor embedded in an existing hash.

```js
const rounds = bcrypt.getRounds('$2b$10$...');
// returns 10
```

---

## Password Length Limit

bcrypt truncates input at 72 bytes. Passwords longer than 72 bytes are silently truncated before hashing. Two passwords that differ only in characters after position 72 will produce the same hash.

If your application accepts passwords longer than 72 bytes and you want to differentiate them, pre-hash with SHA-256 before passing to bcrypt:

```js
const crypto = require('crypto');
const bcrypt = require('bcrypt');

function preparePassword(plainPassword) {
  // SHA-256 output is 32 bytes, well within bcrypt's 72-byte limit
  return crypto
    .createHash('sha256')
    .update(plainPassword)
    .digest('base64');
}

const hash = await bcrypt.hash(preparePassword(plainPassword), 12);
const match = await bcrypt.compare(preparePassword(plainPassword), hash);
```

[Inference] This approach changes the input format of existing hashes if retrofitted. It is simpler to apply from the start than to migrate later. Behavior is not guaranteed to match any specific security framework's recommendation; consult a security professional for high-stakes applications.

---

## Null Bytes in Passwords

bcrypt processes input as a C string, which stops at the first null byte (`\0`). If a user submits a password containing a null byte, everything after it is ignored.

To avoid this, validate or sanitize input:

```js
function validatePassword(password) {
  if (typeof password !== 'string') throw new Error('Password must be a string');
  if (password.includes('\0')) throw new Error('Password contains invalid characters');
  if (password.length < 8) throw new Error('Password too short');
}
```

---

## Timing Safety

`bcrypt.compare` is timing-safe in the sense that it always runs the full hashing operation before comparing, rather than short-circuiting on the first mismatched byte. However, when the user is not found in the database at all, skipping the compare call introduces a timing difference that could reveal whether a username exists.

To avoid this, always run `compare` even when no user is found:

```js
const DUMMY_HASH = '$2b$12$invalidhashvaluethatisusedtopreventienuserenumerationXXX';

async function loginUser(username, plainPassword) {
  const user = await db.users.findOne({ username });

  const hashToCheck = user ? user.passwordHash : DUMMY_HASH;
  const match = await bcrypt.compare(plainPassword, hashToCheck);

  if (!user || !match) return false;
  return true;
}
```

The dummy hash ensures the time taken for a non-existent username is similar to the time for an existing one.

---

## Error Handling

```js
try {
  const hash = await bcrypt.hash(password, saltRounds);
} catch (err) {
  // err.message describes the problem
  console.error('Hashing failed:', err.message);
}
```

Common error conditions:

- Passing a non-string, non-Buffer value to `hash` or `compare`
- Passing an invalid hash string to `compare` or `getRounds`
- Passing a rounds value that is not a positive integer

---

## TypeScript Usage

```ts
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12;

async function hashPassword(plain: string): Promise<string> {
  return bcrypt.hash(plain, SALT_ROUNDS);
}

async function verifyPassword(plain: string, hash: string): Promise<boolean> {
  return bcrypt.compare(plain, hash);
}
```

Type definitions are bundled with the package as of recent versions. If they are not found, install them separately:

```bash
npm install --save-dev @types/bcrypt
```

---

## With Express and Mongoose: Full Example

```js
const express = require('express');
const bcrypt = require('bcrypt');
const mongoose = require('mongoose');

const SALT_ROUNDS = 12;

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true }
});

const User = mongoose.model('User', userSchema);

const app = express();
app.use(express.json());

app.post('/register', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' });
  }

  try {
    const existing = await User.findOne({ email });
    if (existing) return res.status(409).json({ error: 'Email already registered' });

    const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);
    await User.create({ email, passwordHash });

    res.status(201).json({ message: 'Registered' });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  const DUMMY_HASH = '$2b$12$invalidhashXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

  try {
    const user = await User.findOne({ email });
    const hash = user ? user.passwordHash : DUMMY_HASH;
    const match = await bcrypt.compare(password, hash);

    if (!user || !match) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    res.json({ message: 'Logged in' });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});
```

---

## What bcrypt Does Not Do

- It does not encrypt data. Encryption is reversible; bcrypt hashing is not.
- It is not suitable for general-purpose data integrity (use SHA-256/SHA-3 for that).
- It does not protect against weak passwords. Input validation and rate limiting are separate concerns.
- It does not prevent brute force at scale on its own. Rate limiting, account lockout, and multi-factor authentication are complementary measures.

---

## Further Reading

- npm package: `bcrypt` by Nick Campbell
- Repository: https://github.com/kelektiv/node.bcrypt.js
- Original bcrypt paper: https://www.usenix.org/legacy/events/usenix99/provos/provos.pdf
- OWASP Password Storage Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
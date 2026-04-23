# Passport.js — Comprehensive Guide

Passport is authentication middleware for Node.js. It's strategy-based: you plug in a "strategy" (Local, Google OAuth, JWT, etc.) and Passport handles the plumbing — serialization, session integration, and request population.

---

## Core Concepts

- **Strategy** — a module that defines _how_ to authenticate (username/password, OAuth, JWT, API key, etc.)
- **Serialize / Deserialize** — controls how user identity is stored in and retrieved from the session
- **`req.user`** — Passport populates this on every authenticated request after successful authentication
- **`req.isAuthenticated()`** — returns `true` if a user is currently authenticated
- **`req.login()`** / **`req.logout()`** — manually log a user in or out

---

## Installation

```bash
npm install passport

# Pick your strategy:
npm install passport-local          # username + password
npm install passport-jwt            # JWT bearer tokens
npm install passport-google-oauth20 # Google OAuth 2.0
npm install passport-github2        # GitHub OAuth
npm install passport-facebook       # Facebook OAuth
```

---

## Setup Order

```
1. Configure strategy  →  2. Serialize/Deserialize  →  3. Initialize middleware  →  4. Protect routes
```

---

## Strategy 1 — Local (Username + Password)

### Full Setup

```js
const passport       = require('passport');
const LocalStrategy  = require('passport-local').Strategy;
const session        = require('express-session');

// 1. Configure strategy
passport.use(new LocalStrategy(
  { usernameField: 'email' },          // default field is 'username'
  async (email, password, done) => {
    try {
      const user = await User.findOne({ email });
      if (!user)           return done(null, false, { message: 'No user found' });
      if (!user.validPassword(password)) return done(null, false, { message: 'Wrong password' });
      return done(null, user);
    } catch (err) {
      return done(err);
    }
  }
));

// 2. Serialize (what to store in session)
passport.serializeUser((user, done) => {
  done(null, user.id);
});

// 3. Deserialize (how to retrieve user from session on each request)
passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findById(id);
    done(null, user);
  } catch (err) {
    done(err);
  }
});

// 4. Wire up middleware (order matters)
app.use(session({ secret: process.env.SESSION_SECRET, resave: false, saveUninitialized: false }));
app.use(passport.initialize());
app.use(passport.session());   // only needed if using sessions
```

### Login Route

```js
app.post('/login',
  passport.authenticate('local', {
    successRedirect: '/dashboard',
    failureRedirect: '/login',
    failureFlash: true          // requires connect-flash
  })
);

// Or with a custom callback for more control:
app.post('/login', (req, res, next) => {
  passport.authenticate('local', (err, user, info) => {
    if (err)   return next(err);
    if (!user) return res.status(401).json({ message: info.message });

    req.login(user, (err) => {
      if (err) return next(err);
      return res.json({ message: 'Logged in', user });
    });
  })(req, res, next);
});
```

### Logout Route

```js
app.post('/logout', (req, res, next) => {
  req.logout((err) => {       // passport v0.6+ requires callback
    if (err) return next(err);
    res.redirect('/login');
  });
});
```

---

## Strategy 2 — JWT

Use this for stateless APIs. No sessions needed.

```js
const passport    = require('passport');
const JwtStrategy = require('passport-jwt').Strategy;
const ExtractJwt  = require('passport-jwt').ExtractJwt;

passport.use(new JwtStrategy(
  {
    jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
    secretOrKey: process.env.JWT_SECRET,
    algorithms: ['HS256']   // always whitelist algorithms
  },
  async (jwtPayload, done) => {
    try {
      const user = await User.findById(jwtPayload.sub);
      if (!user) return done(null, false);
      return done(null, user);
    } catch (err) {
      return done(err);
    }
  }
));

// No serialize/deserialize needed for JWT (stateless)
app.use(passport.initialize());  // no passport.session()
```

### Protecting a Route

```js
const authenticate = passport.authenticate('jwt', { session: false });

app.get('/api/profile', authenticate, (req, res) => {
  res.json(req.user);
});
```

---

## Strategy 3 — Google OAuth 2.0

```js
const GoogleStrategy = require('passport-google-oauth20').Strategy;

passport.use(new GoogleStrategy(
  {
    clientID:     process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL:  '/auth/google/callback'
  },
  async (accessToken, refreshToken, profile, done) => {
    try {
      let user = await User.findOne({ googleId: profile.id });
      if (!user) {
        user = await User.create({
          googleId:    profile.id,
          email:       profile.emails[0].value,
          displayName: profile.displayName
        });
      }
      return done(null, user);
    } catch (err) {
      return done(err);
    }
  }
));

// Routes
app.get('/auth/google',
  passport.authenticate('google', { scope: ['profile', 'email'] })
);

app.get('/auth/google/callback',
  passport.authenticate('google', {
    successRedirect: '/dashboard',
    failureRedirect: '/login'
  })
);
```

---

## The `done` Callback

The `done` function is used inside every strategy's verify callback. It follows a consistent signature:

|Call|Meaning|
|---|---|
|`done(err)`|An error occurred (e.g. DB failure) — triggers a 500|
|`done(null, false)`|Authentication failed — no user found or wrong credentials|
|`done(null, false, { message: '...' })`|Failed with a flash message|
|`done(null, user)`|Success — `user` is set on `req.user`|

---

## Route Protection Middleware

### Session-based

```js
function requireAuth(req, res, next) {
  if (req.isAuthenticated()) return next();
  res.redirect('/login');
}

app.get('/dashboard', requireAuth, (req, res) => {
  res.render('dashboard', { user: req.user });
});
```

### JWT-based (stateless)

```js
const requireAuth = passport.authenticate('jwt', { session: false });

app.get('/api/me', requireAuth, (req, res) => {
  res.json(req.user);
});
```

### Role-based authorization (after authentication)

```js
function requireRole(role) {
  return (req, res, next) => {
    if (req.isAuthenticated() && req.user.role === role) return next();
    res.status(403).json({ error: 'Forbidden' });
  };
}

app.delete('/admin/users/:id', requireAuth, requireRole('admin'), handler);
```

---

## Serialize / Deserialize — In Depth

Serialization only applies to session-based strategies (Local, OAuth). JWT is stateless and skips this entirely.

```js
// Called once on login — what to store in the session cookie
passport.serializeUser((user, done) => {
  done(null, user.id);   // store only the ID
});

// Called on every subsequent request — rebuild the user object
passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findById(id).select('-password');
    done(null, user);    // attached as req.user
  } catch (err) {
    done(err);
  }
});
```

> ⚠️ If `deserializeUser` returns `null` or `false`, Passport clears the session and `req.user` becomes `undefined`. This happens when a user is deleted mid-session. [Inference] You may want to handle this case explicitly in your middleware. Behavior is not guaranteed across all versions.

---

## Multiple Strategies

You can register and use multiple strategies simultaneously:

```js
passport.use('local',  new LocalStrategy(...));
passport.use('google', new GoogleStrategy(...));
passport.use('jwt',    new JwtStrategy(...));

// Reference by name string
passport.authenticate('local', options)
passport.authenticate('google', options)
passport.authenticate('jwt',    { session: false })
```

---

## `passport.authenticate()` Options

|Option|Type|Description|
|---|---|---|
|`session`|boolean|Default `true`. Set `false` for stateless strategies like JWT|
|`successRedirect`|string|Redirect on success|
|`failureRedirect`|string|Redirect on failure|
|`failureFlash`|boolean/string|Flash a failure message (requires `connect-flash`)|
|`successFlash`|boolean/string|Flash a success message|
|`failureMessage`|boolean/string|Append message to `req.session.messages`|
|`assignProperty`|string|Attach user to `req[property]` instead of `req.user`|
|`passReqToCallback`|boolean|Pass `req` as first arg to verify callback|

---

## Passing `req` to the Verify Callback

Useful when you need request context (e.g. multi-tenant apps):

```js
passport.use(new LocalStrategy(
  { passReqToCallback: true },
  async (req, email, password, done) => {
    const tenantId = req.headers['x-tenant-id'];
    const user = await User.findOne({ email, tenantId });
    // ...
  }
));
```

---

## Common Patterns

### Check auth without redirecting (API use)

```js
app.get('/api/status', (req, res) => {
  if (req.isAuthenticated()) {
    return res.json({ authenticated: true, user: req.user });
  }
  res.status(401).json({ authenticated: false });
});
```

### Combine session + JWT (hybrid app)

```js
function flexAuth(req, res, next) {
  if (req.headers.authorization) {
    return passport.authenticate('jwt', { session: false })(req, res, next);
  }
  if (req.isAuthenticated()) return next();
  res.status(401).json({ error: 'Unauthorized' });
}
```

### Linking OAuth accounts to an existing user

```js
passport.use(new GoogleStrategy(options, async (accessToken, refreshToken, profile, done) => {
  if (req.user) {
    // User already logged in — link Google account
    await User.findByIdAndUpdate(req.user.id, { googleId: profile.id });
    return done(null, req.user);
  }
  // Normal flow
  const user = await User.findOne({ googleId: profile.id });
  return done(null, user || await User.create({ googleId: profile.id, ... }));
}));
```

---

## Security Notes

| Practice                                          | Why                                                              |
| ------------------------------------------------- | ---------------------------------------------------------------- |
| Always hash passwords (e.g. `bcrypt`)             | Never store plaintext passwords                                  |
| Use `{ session: false }` for JWT strategies       | Avoids unnecessarily creating sessions                           |
| Set `saveUninitialized: false` on express-session | Avoids storing empty sessions                                    |
| Regenerate session ID after login                 | Prevents session fixation attacks — `req.session.regenerate(cb)` |
| Use HTTPS in production                           | Session cookies and tokens are intercepted over plain HTTP       |
| Scope OAuth requests minimally                    | Only request the permissions your app actually needs             |
| Validate `state` parameter in OAuth flows         | Mitigates CSRF on the OAuth callback                             |

---

## Passport vs. Alternatives — Quick Comparison

|                      | Passport          | Auth.js (NextAuth) | Lucia       | BetterAuth  |
| -------------------- | ----------------- | ------------------ | ----------- | ----------- |
| Runtime              | Node.js           | Node/Edge          | Node.js     | Node.js     |
| Framework            | Express-centric   | Next.js-centric    | Agnostic    | Agnostic    |
| Sessions             | Yes               | Yes                | Yes         | Yes         |
| JWT                  | Via strategy      | Built-in           | Built-in    | Built-in    |
| Strategies/Providers | 500+              | ~80                | Manual      | ~30         |
| TypeScript           | Limited           | First-class        | First-class | First-class |
| Maintenance          | Slow (as of 2024) | Active             | Active      | Active      |


> [Unverified] Maintenance activity and strategy counts are approximations based on information available through mid-2025 and may have changed. Verify current status on each project's GitHub.

---

## Quick Reference

```js
const passport = require('passport');

// Initialize (always)
app.use(passport.initialize());
app.use(passport.session());         // only for session strategies

// Authenticate a route
passport.authenticate('local', { successRedirect: '/', failureRedirect: '/login' })
passport.authenticate('jwt', { session: false })
passport.authenticate('google', { scope: ['profile', 'email'] })

// In routes
req.isAuthenticated()   // → boolean
req.user                // → deserialized user object
req.login(user, cb)     // manually establish session
req.logout(cb)          // destroy session (v0.6+ requires callback)
```

---

# Passport-Local: Comprehensive Guide

`passport-local` is a [Passport.js](http://www.passportjs.org/) strategy for authenticating with a username and password. Here's a thorough walkthrough.

---

## What It Is

**Passport.js** is authentication middleware for Node.js. **passport-local** is the strategy plugin that handles traditional username/password login — as opposed to OAuth, JWT, etc.

---

## Installation

```bash
npm install passport passport-local express-session
```

---

## Core Concepts

### 1. The Strategy

You define _how_ to verify a user by providing a **verify callback**:

```js
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;

passport.use(new LocalStrategy(
  async function verify(username, password, done) {
    try {
      const user = await db.findUserByUsername(username);

      if (!user) {
        return done(null, false, { message: 'Incorrect username.' });
      }

      const isMatch = await bcrypt.compare(password, user.passwordHash);
      if (!isMatch) {
        return done(null, false, { message: 'Incorrect password.' });
      }

      return done(null, user); // success
    } catch (err) {
      return done(err); // server error
    }
  }
));
```

### The `done` callback has three signatures:

|Call|Meaning|
|---|---|
|`done(err)`|Server/database error|
|`done(null, false, { message })`|Auth failed (bad credentials)|
|`done(null, user)`|Auth succeeded|

---

### 2. Custom Field Names

By default, passport-local reads `req.body.username` and `req.body.password`. You can override this:

```js
passport.use(new LocalStrategy(
  { usernameField: 'email', passwordField: 'pin' },
  async function verify(email, pin, done) {
    // ...
  }
));
```

---

### 3. Sessions: serializeUser / deserializeUser

For session-based auth, Passport needs to know how to store and retrieve the user from the session:

```js
// Store user ID in session
passport.serializeUser(function(user, done) {
  done(null, user.id);
});

// Retrieve full user from session on each request
passport.deserializeUser(async function(id, done) {
  try {
    const user = await db.findUserById(id);
    done(null, user);
  } catch (err) {
    done(err);
  }
});
```

> **Note:** `deserializeUser` runs on **every authenticated request**, so keep it fast.

---

## Full Express Setup

```js
const express = require('express');
const session = require('express-session');
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const bcrypt = require('bcrypt');

const app = express();

// --- Middleware ---
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production', // HTTPS only in prod
    maxAge: 1000 * 60 * 60 * 24 // 1 day
  }
}));

app.use(passport.initialize());
app.use(passport.session()); // must come after express-session

// --- Strategy ---
passport.use(new LocalStrategy(
  { usernameField: 'email' },
  async function verify(email, password, done) {
    const user = await db.findUserByEmail(email);
    if (!user) return done(null, false, { message: 'User not found.' });

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) return done(null, false, { message: 'Wrong password.' });

    return done(null, user);
  }
));

passport.serializeUser((user, done) => done(null, user.id));
passport.deserializeUser(async (id, done) => {
  try {
    const user = await db.findUserById(id);
    done(null, user);
  } catch (e) {
    done(e);
  }
});

// --- Routes ---

// Login
app.post('/login',
  passport.authenticate('local', {
    successRedirect: '/dashboard',
    failureRedirect: '/login',
    failureFlash: true // requires connect-flash
  })
);

// Logout
app.post('/logout', (req, res, next) => {
  req.logout(function(err) {
    if (err) return next(err);
    res.redirect('/login');
  });
});

// Protected route
function requireAuth(req, res, next) {
  if (req.isAuthenticated()) return next();
  res.redirect('/login');
}

app.get('/dashboard', requireAuth, (req, res) => {
  res.send(`Hello, ${req.user.email}`);
});
```

---

## Flash Messages (optional but common)

```bash
npm install connect-flash
```

```js
const flash = require('connect-flash');
app.use(flash());

// In your login GET route:
app.get('/login', (req, res) => {
  res.render('login', { error: req.flash('error') });
});
```

`failureFlash: true` in `passport.authenticate()` automatically stores the `message` from `done(null, false, { message })` into the flash.

---

## Password Hashing (mandatory best practice)

Never store plaintext passwords. Use `bcrypt`:

```js
// Registration
const hash = await bcrypt.hash(plaintextPassword, 12); // 12 salt rounds
await db.createUser({ email, passwordHash: hash });

// Verification (in strategy)
const isMatch = await bcrypt.compare(plaintextPassword, user.passwordHash);
```

---

## Common Patterns & Pitfalls

### `passport.session()` order matters

It **must** be placed after `express-session` middleware, and after `passport.initialize()`.

### `req.logout()` is now async (Passport ≥ 0.6)

Older tutorials show `req.logout()` without a callback — this changed in Passport 0.6. Always use the callback form shown above.

### `req.user` is only populated if `deserializeUser` succeeds

If your DB lookup fails silently, `req.user` will be `undefined` even with a valid session.

### `saveUninitialized: false`

Recommended to avoid creating empty sessions for unauthenticated visitors.

---

## Checking Authentication State

```js
req.isAuthenticated()   // true if logged in
req.isUnauthenticated() // true if not logged in
req.user                // the deserialized user object (or undefined)
```

---

## Summary Flow

```
POST /login
  └─ passport.authenticate('local')
       └─ LocalStrategy verify callback
            ├─ done(null, user)     → serializeUser → session saved → redirect success
            └─ done(null, false)    → flash message  → redirect failure

Subsequent requests
  └─ express-session restores session
       └─ passport.session() calls deserializeUser
            └─ populates req.user
```

---

## What passport-local Does NOT Handle

- Password reset flows
- Account lockout after failed attempts
- Rate limiting login attempts
- Two-factor authentication
- Token-based (JWT) auth — use `passport-jwt` for that

These require additional libraries or custom middleware.

---

# Passport-JWT: Comprehensive Guide

`passport-jwt` is a Passport.js strategy for authenticating using **JSON Web Tokens (JWT)** — stateless, token-based auth commonly used in APIs and SPAs.

---

## What It Is

Unlike `passport-local` (which uses sessions), JWT auth is **stateless**: the server issues a signed token, the client stores it, and sends it with every request. The server verifies the token's signature — no session or DB lookup required for auth itself.

---

## Installation

```bash
npm install passport passport-jwt jsonwebtoken
```

---

## Core Concepts

### Anatomy of a JWT

A JWT has three Base64URL-encoded parts separated by dots:

```
header.payload.signature
eyJhbGci...  .  eyJ1c2VyS...  .  SflKxwRJSMeK...
```

|Part|Contains|
|---|---|
|Header|Algorithm, token type|
|Payload|Claims: `sub`, `iat`, `exp`, custom fields|
|Signature|HMAC or RSA signature of header + payload|

> **Important:** The payload is **encoded, not encrypted**. Anyone can read it. Never put sensitive data (passwords, secrets) in the payload.

---

## The Two Main Pieces

### 1. Issuing a Token (login)

This is done with `jsonwebtoken`, not passport-jwt:

```js
const jwt = require('jsonwebtoken');

app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await db.findUserByEmail(email);

  if (!user) return res.status(401).json({ message: 'User not found.' });

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) return res.status(401).json({ message: 'Wrong password.' });

  const payload = {
    sub: user.id,        // subject — standard JWT claim
    email: user.email,
    role: user.role
  };

  const token = jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: '1h'      // token expires in 1 hour
  });

  res.json({ token });
});
```

### 2. Verifying a Token (passport-jwt)

```js
const passport = require('passport');
const { Strategy: JwtStrategy, ExtractJwt } = require('passport-jwt');

const options = {
  jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
  secretOrKey: process.env.JWT_SECRET
};

passport.use(new JwtStrategy(options, async function verify(payload, done) {
  try {
    const user = await db.findUserById(payload.sub);
    if (!user) return done(null, false);
    return done(null, user);
  } catch (err) {
    return done(err);
  }
}));
```

---

## Token Extraction Methods

`ExtractJwt` provides several built-in extractors:

```js
// From Authorization: Bearer <token>  (most common for APIs)
ExtractJwt.fromAuthHeaderAsBearerToken()

// From any header
ExtractJwt.fromHeader('x-access-token')

// From a query parameter: GET /route?token=...
ExtractJwt.fromUrlQueryParameter('token')

// From request body field
ExtractJwt.fromBodyField('token')

// Custom extractor function
ExtractJwt.fromExtractors([
  ExtractJwt.fromAuthHeaderAsBearerToken(),
  (req) => req?.cookies?.jwt ?? null  // fallback to cookie
])
```

---

## Full Express Setup

```js
const express = require('express');
const passport = require('passport');
const { Strategy: JwtStrategy, ExtractJwt } = require('passport-jwt');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const app = express();
app.use(express.json());
app.use(passport.initialize()); // No passport.session() needed for JWT

// --- Strategy ---
passport.use(new JwtStrategy(
  {
    jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
    secretOrKey: process.env.JWT_SECRET,
    // issuer: 'yourapp.com',   // optional: validate iss claim
    // audience: 'yourapp.com', // optional: validate aud claim
  },
  async function verify(payload, done) {
    try {
      const user = await db.findUserById(payload.sub);
      if (!user) return done(null, false);
      return done(null, user);
    } catch (err) {
      return done(err);
    }
  }
));

// --- Auth middleware ---
const requireAuth = passport.authenticate('jwt', { session: false });
//                                                  ^^^^^^^^^^^^^^^
//                         Always set session: false for JWT — no sessions involved

// --- Routes ---

// Login → issue token
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await db.findUserByEmail(email);
    if (!user) return res.status(401).json({ message: 'Invalid credentials.' });

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) return res.status(401).json({ message: 'Invalid credentials.' });

    const token = jwt.sign(
      { sub: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    res.json({ token });
  } catch (err) {
    res.status(500).json({ message: 'Server error.' });
  }
});

// Protected route
app.get('/profile', requireAuth, (req, res) => {
  // req.user is populated by the verify callback
  res.json({ user: req.user });
});

// Role-based access
function requireRole(role) {
  return (req, res, next) => {
    if (req.user?.role !== role) {
      return res.status(403).json({ message: 'Forbidden.' });
    }
    next();
  };
}

app.delete('/admin/user/:id',
  requireAuth,
  requireRole('admin'),
  async (req, res) => {
    // ...
  }
);
```

---

## JWT Options Reference

```js
// jwt.sign options
jwt.sign(payload, secret, {
  expiresIn: '1h',        // '15m', '7d', 3600 (seconds)
  notBefore: '10s',       // token not valid until 10s from now
  issuer: 'myapp.com',    // sets iss claim
  audience: 'myapp.com',  // sets aud claim
  algorithm: 'HS256'      // default; HS256, HS512, RS256, etc.
});

// jwt.verify options
jwt.verify(token, secret, {
  issuer: 'myapp.com',
  audience: 'myapp.com',
  algorithms: ['HS256']
});
```

---

## Refresh Token Pattern

Access tokens should be short-lived. Refresh tokens handle re-issuance without re-login:

```js
// On login, issue both:
const accessToken = jwt.sign(
  { sub: user.id },
  process.env.JWT_SECRET,
  { expiresIn: '15m' }
);

const refreshToken = jwt.sign(
  { sub: user.id },
  process.env.REFRESH_SECRET,
  { expiresIn: '7d' }
);

// Store refreshToken in DB (so it can be revoked)
await db.saveRefreshToken(user.id, refreshToken);

res.json({ accessToken, refreshToken });

// Refresh endpoint:
app.post('/refresh', async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return res.status(401).json({ message: 'No token.' });

  try {
    const payload = jwt.verify(refreshToken, process.env.REFRESH_SECRET);
    const stored = await db.findRefreshToken(refreshToken);
    if (!stored) return res.status(403).json({ message: 'Token revoked.' });

    const newAccessToken = jwt.sign(
      { sub: payload.sub },
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );

    res.json({ accessToken: newAccessToken });
  } catch (err) {
    res.status(403).json({ message: 'Invalid refresh token.' });
  }
});
```

---

## Token Storage: Where to Keep It Client-Side

|Location|XSS Risk|CSRF Risk|Notes|
|---|---|---|---|
|`localStorage`|High|None|Easy to implement; vulnerable to XSS|
|`sessionStorage`|High|None|Cleared on tab close; still XSS-vulnerable|
|`httpOnly` cookie|None|Present|Requires CSRF protection; preferred for web apps|
|Memory (JS variable)|Low|None|Lost on page refresh; best for SPAs with refresh token in httpOnly cookie|

---

## Revoking JWTs

JWTs are stateless by design — once issued, they are valid until expiry. To revoke them you need a workaround:

```js
// Option 1: Token blocklist (denylist)
// Store revoked JTI (JWT ID) claims in Redis/DB until their natural expiry

jwt.sign({ sub: user.id, jti: crypto.randomUUID() }, secret, { expiresIn: '1h' });

// In verify callback:
async function verify(payload, done) {
  const isRevoked = await redis.get(`blocklist:${payload.jti}`);
  if (isRevoked) return done(null, false);
  // ...
}

// On logout:
await redis.set(`blocklist:${jti}`, '1', 'EX', secondsUntilExpiry);

// Option 2: Short expiry + refresh tokens (most common)
// Option 3: Per-user secret version stored in DB (invalidates all tokens on change)
```

> **Note:** Any revocation mechanism reintroduces statefulness to some degree. This is an inherent trade-off of JWTs. [Inference]

---

## RS256 (Asymmetric Signing)

Useful when multiple services need to **verify** tokens but only one should **issue** them:

```js
const fs = require('fs');

// Auth server — signs with private key
const privateKey = fs.readFileSync('private.pem');
const token = jwt.sign({ sub: user.id }, privateKey, { algorithm: 'RS256' });

// API servers — verify with public key only
const publicKey = fs.readFileSync('public.pem');

passport.use(new JwtStrategy(
  {
    jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
    secretOrKey: publicKey,
    algorithms: ['RS256']
  },
  verify
));
```

---

## Common Pitfalls

### Always use `session: false`

```js
passport.authenticate('jwt', { session: false })
// Omitting this can cause unexpected behavior with session middleware
```

### Never trust the payload without verifying the signature

`passport-jwt` handles this for you — but if you ever call `jwt.decode()` instead of `jwt.verify()`, the signature is **not checked**.

```js
jwt.decode(token)  // ⚠️ No verification — never use for auth
jwt.verify(token, secret)  // ✓ Checks signature and expiry
```

### `exp` is in seconds, not milliseconds

```js
// Wrong
{ expiresIn: Date.now() + 3600000 }

// Correct
{ expiresIn: '1h' }
// or
{ expiresIn: 3600 } // seconds
```

### Weak or missing secret

Use a long, random, environment-variable secret — never a hardcoded string.

```bash
# Generate a strong secret
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

---

## Summary Flow

```
POST /login
  └─ Verify credentials
       └─ jwt.sign(payload, secret)
            └─ Return { token } to client

Client stores token, sends on every request:
  Authorization: Bearer <token>

Protected request
  └─ passport.authenticate('jwt', { session: false })
       └─ ExtractJwt pulls token from header
            └─ Verifies signature + expiry
                 └─ Calls verify(payload, done)
                      └─ done(null, user) → req.user populated → next()
                      └─ done(null, false) → 401 Unauthorized
```

---

## What passport-jwt Does NOT Handle

- Refresh token rotation logic
- Token storage on the client
- Multi-device logout
- OAuth / social login — use `passport-oauth2` for that
- Encrypted payloads (JWE) — `passport-jwt` uses signed JWS only

---

# `passport-google-oauth20`

## Overview

`passport-google-oauth20` is a [Passport.js](http://www.passportjs.org/) strategy that implements OAuth 2.0 authentication against Google's identity platform. It delegates credential management to Google and exchanges an authorization code for tokens that identify the authenticated user.

---

## 1. Prerequisites

- Node.js application with Express (or compatible framework)
- A Google Cloud project with OAuth 2.0 credentials
- Packages: `passport`, `passport-google-oauth20`, `express-session` (or equivalent session store)

---

## 2. Google Cloud Console Setup

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create or select a project
3. Navigate to **APIs & Services → Credentials**
4. Click **Create Credentials → OAuth client ID**
5. Set Application type to **Web application**
6. Add authorized redirect URIs — must exactly match the callback URL in your app (e.g., `http://localhost:3000/auth/google/callback`)
7. Copy the **Client ID** and **Client Secret**

---

## 3. Installation

```bash
npm install passport passport-google-oauth20 express express-session
```

---

## 4. Strategy Registration

```js
const passport = require('passport');
const { Strategy: GoogleStrategy } = require('passport-google-oauth20');

passport.use(new GoogleStrategy(
  {
    clientID:     process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL:  'http://localhost:3000/auth/google/callback',

    // Optional: pass req into verify callback
    passReqToCallback: false,
  },
  function verify(accessToken, refreshToken, profile, done) {
    // profile: normalized Google profile object
    // accessToken: short-lived bearer token
    // refreshToken: long-lived token (only present if access_type=offline was requested)

    // Typical pattern: find or create user in DB
    User.findOrCreate({ googleId: profile.id }, function(err, user) {
      return done(err, user);
    });
  }
));
```

**`verify` callback contract:**

| Argument | Description |
|---|---|
| `accessToken` | Google API access token |
| `refreshToken` | Refresh token; `undefined` unless `access_type=offline` |
| `profile` | Normalized profile (see §7) |
| `done(err, user, info)` | Call with `false` as user to deny, or a user object to authenticate |

---

## 5. Session Serialization

Passport requires `serializeUser` and `deserializeUser` when using sessions.

```js
passport.serializeUser(function(user, done) {
  // Store only the user ID in the session
  done(null, user.id);
});

passport.deserializeUser(function(id, done) {
  User.findById(id, function(err, user) {
    done(err, user);
  });
});
```

---

## 6. Express Wiring

```js
const express = require('express');
const session  = require('express-session');
const passport = require('passport');

const app = express();

app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
}));

app.use(passport.initialize());
app.use(passport.session()); // Requires express-session above

// Initiate OAuth flow
app.get('/auth/google',
  passport.authenticate('google', {
    scope: ['profile', 'email'],
  })
);

// Handle callback from Google
app.get('/auth/google/callback',
  passport.authenticate('google', {
    failureRedirect: '/login',
    successRedirect: '/dashboard',
  })
);

// Protected route example
app.get('/dashboard', ensureAuthenticated, (req, res) => {
  res.send(`Hello, ${req.user.displayName}`);
});

function ensureAuthenticated(req, res, next) {
  if (req.isAuthenticated()) return next();
  res.redirect('/login');
}

app.listen(3000);
```

---

## 7. The `profile` Object

Google returns a normalized Passport profile. Confirmed fields from the official spec:

```json
{
  "id": "1234567890",
  "displayName": "Jane Doe",
  "name": {
    "familyName": "Doe",
    "givenName": "Jane"
  },
  "emails": [
    { "value": "jane@example.com", "verified": true }
  ],
  "photos": [
    { "value": "https://lh3.googleusercontent.com/..." }
  ],
  "provider": "google",
  "_raw": "...",     // Raw JSON string from Google
  "_json": { ... }  // Parsed raw response
}
```

- `emails` and `photos` are arrays; index 0 is the primary.
- `_json` contains the full unprocessed Google payload — use it to access fields not normalized by Passport (e.g., `locale`, `hd` for hosted domain).

---

## 8. Scopes

Scopes are passed in the `authenticate()` call. Common values:

| Scope | What it grants |
|---|---|
| `profile` | Basic profile info: name, photo, ID |
| `email` | Email address |
| `openid` | Enables OpenID Connect ID token |
| `https://www.googleapis.com/auth/calendar` | Google Calendar |
| `https://www.googleapis.com/auth/gmail.readonly` | Gmail read-only |

Requesting sensitive scopes requires Google's OAuth verification process for apps serving external users.

---

## 9. Refresh Tokens

By default, Google only returns a refresh token on the **first** authorization. To reliably receive one:

```js
passport.authenticate('google', {
  scope: ['profile', 'email'],
  accessType: 'offline',   // Request refresh token
  prompt: 'consent',       // Force consent screen to re-issue refresh token
})
```

- `prompt: 'consent'` forces the consent screen every time, which causes a new refresh token to be issued. Without it, subsequent logins may return `refreshToken` as `undefined`.
- Store refresh tokens securely server-side; they are not rotated automatically.

---

## 10. `passReqToCallback`

When set to `true`, the verify callback receives `req` as the first argument:

```js
new GoogleStrategy(
  { ..., passReqToCallback: true },
  function(req, accessToken, refreshToken, profile, done) {
    // req is the Express request object
    // Useful for associating accounts with an already-logged-in user
  }
)
```

---

## 11. Error Handling

```js
app.get('/auth/google/callback',
  passport.authenticate('google', {
    failureRedirect: '/login',
    failureMessage: true,      // Stores error in session as req.session.messages
  })
);

// Or use a custom callback for full control:
app.get('/auth/google/callback', function(req, res, next) {
  passport.authenticate('google', function(err, user, info) {
    if (err)   return next(err);
    if (!user) return res.redirect('/login?error=' + encodeURIComponent(info));
    req.logIn(user, function(err) {
      if (err) return next(err);
      res.redirect('/dashboard');
    });
  })(req, res, next);
});
```

---

## 12. State Parameter (CSRF Protection)

Passport sets a `state` parameter by default in OAuth 2.0 flows to mitigate CSRF against the callback endpoint. This is handled automatically — the generated state is stored in the session and verified on callback.

To disable (not recommended):

```js
passport.authenticate('google', { state: false })
```

---

## 13. PKCE

As of `passport-google-oauth20` v2.x, PKCE is not natively supported by the strategy. [Unverified — behavior may vary by version; confirm against the package changelog.]

---

## 14. Environment Variables Pattern

```bash
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
SESSION_SECRET=a_long_random_string
```

Never hardcode credentials. Use `dotenv` in development:

```js
require('dotenv').config();
```

---

## 15. Common Failure Modes

| Symptom | Likely Cause |
|---|---|
| `redirect_uri_mismatch` | Callback URL in code doesn't exactly match GCP console entry |
| `refreshToken` is `undefined` | `access_type: 'offline'` not set, or user already consented without `prompt: 'consent'` |
| Session not persisting | `express-session` misconfigured, or `passport.session()` missing |
| `profile.emails` is empty | `email` scope not requested |
| Strategy not found | `passport.use()` not called before routes |

---

## 16. Minimal Working Example (consolidated)

```js
require('dotenv').config();
const express  = require('express');
const session  = require('express-session');
const passport = require('passport');
const { Strategy: GoogleStrategy } = require('passport-google-oauth20');

const users = new Map(); // In-memory store; replace with DB

passport.use(new GoogleStrategy({
  clientID:     process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  callbackURL:  'http://localhost:3000/auth/google/callback',
}, (accessToken, refreshToken, profile, done) => {
  let user = users.get(profile.id);
  if (!user) {
    user = { id: profile.id, name: profile.displayName, email: profile.emails[0].value };
    users.set(profile.id, user);
  }
  return done(null, user);
}));

passport.serializeUser((user, done) => done(null, user.id));
passport.deserializeUser((id, done) => done(null, users.get(id) ?? false));

const app = express();
app.use(session({ secret: process.env.SESSION_SECRET, resave: false, saveUninitialized: false }));
app.use(passport.initialize());
app.use(passport.session());

app.get('/auth/google',          passport.authenticate('google', { scope: ['profile', 'email'] }));
app.get('/auth/google/callback', passport.authenticate('google', { failureRedirect: '/login', successRedirect: '/' }));
app.get('/logout', (req, res) => { req.logout(() => res.redirect('/')); });
app.get('/', (req, res) => {
  res.send(req.isAuthenticated() ? `Hello ${req.user.name}` : '<a href="/auth/google">Login with Google</a>');
});

app.listen(3000);
```

---

**Key Points:** Always validate that the redirect URI registered in GCP matches exactly — including scheme, host, port, and path. Never store access tokens client-side. Use `_json` on the profile object when you need fields beyond what Passport normalizes.

# `passport-facebook`

## Overview

`passport-facebook` is a Passport.js strategy implementing OAuth 2.0 authentication against Facebook's Graph API. It redirects users to Facebook for authorization, then exchanges the resulting code for an access token and fetches a user profile.

---

## 1. Prerequisites

- Node.js + Express application
- A Facebook App with a valid App ID and App Secret
- Packages: `passport`, `passport-facebook`, `express-session`

---

## 2. Facebook App Setup

1. Go to [developers.facebook.com](https://developers.facebook.com/) and create an app
2. Choose app type — **Consumer** or **Business** depending on your use case
3. Add the **Facebook Login** product to the app
4. Under **Facebook Login → Settings**, add your OAuth redirect URI to **Valid OAuth Redirect URIs** (e.g., `http://localhost:3000/auth/facebook/callback`)
5. From **Settings → Basic**, copy your **App ID** and **App Secret**
6. For production, the app must go through App Review for any permissions beyond `public_profile`

---

## 3. Installation

```bash
npm install passport passport-facebook express express-session
```

---

## 4. Strategy Registration

```js
const passport = require('passport');
const { Strategy: FacebookStrategy } = require('passport-facebook');

passport.use(new FacebookStrategy(
  {
    clientID:     process.env.FACEBOOK_APP_ID,
    clientSecret: process.env.FACEBOOK_APP_SECRET,
    callbackURL:  'http://localhost:3000/auth/facebook/callback',

    // Fields to request from Graph API (see §7)
    profileFields: ['id', 'displayName', 'emails', 'photos'],

    // Optional: pass req into verify callback
    passReqToCallback: false,

    // Optional: API version (default varies by package version)
    graphAPIVersion: 'v19.0',
  },
  function verify(accessToken, refreshToken, profile, done) {
    User.findOrCreate({ facebookId: profile.id }, function(err, user) {
      return done(err, user);
    });
  }
));
```

**`verify` callback contract:**

|Argument|Description|
|---|---|
|`accessToken`|Short-lived user access token|
|`refreshToken`|Not issued by Facebook for standard OAuth flows; typically `undefined`|
|`profile`|Normalized profile object (see §7)|
|`done(err, user, info)`|Pass `false` as user to deny; pass user object to authenticate|

---

## 5. Session Serialization

```js
passport.serializeUser(function(user, done) {
  done(null, user.id);
});

passport.deserializeUser(function(id, done) {
  User.findById(id, function(err, user) {
    done(err, user);
  });
});
```

---

## 6. Express Wiring

```js
const express = require('express');
const session  = require('express-session');
const passport = require('passport');

const app = express();

app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
}));

app.use(passport.initialize());
app.use(passport.session());

// Initiate OAuth flow
app.get('/auth/facebook',
  passport.authenticate('facebook', {
    scope: ['email'],         // public_profile is included by default
  })
);

// Handle callback from Facebook
app.get('/auth/facebook/callback',
  passport.authenticate('facebook', {
    failureRedirect: '/login',
    successRedirect: '/dashboard',
  })
);

app.get('/dashboard', ensureAuthenticated, (req, res) => {
  res.send(`Hello, ${req.user.displayName}`);
});

function ensureAuthenticated(req, res, next) {
  if (req.isAuthenticated()) return next();
  res.redirect('/login');
}

app.listen(3000);
```

---

## 7. The `profile` Object

Passport normalizes the Graph API response. Confirmed fields:

```json
{
  "id": "123456789",
  "displayName": "Jane Doe",
  "name": {
    "familyName": "Doe",
    "givenName": "Jane",
    "middleName": ""
  },
  "emails": [
    { "value": "jane@example.com" }
  ],
  "photos": [
    { "value": "https://graph.facebook.com/123456789/picture?type=large" }
  ],
  "provider": "facebook",
  "_raw": "...",
  "_json": { ... }
}
```

**Critical:** Fields beyond `id` and `name` are only present if:

- They were listed in `profileFields` in the strategy config
- The corresponding permission was granted by the user
- The app has passed Facebook's App Review for that permission

`emails` is frequently absent or empty in practice — Facebook does not expose email if the user registered with a phone number or if the `email` permission was not granted.

---

## 8. Permissions (Scopes)

Facebook uses the term **permissions** rather than scopes, though they are passed via the `scope` option.

|Permission|What it grants|Review required?|
|---|---|---|
|`public_profile`|id, name, profile picture|No (default)|
|`email`|Email address|No|
|`user_friends`|Friends who also use your app|Yes|
|`user_birthday`|Birthday|Yes|
|`user_location`|Location|Yes|
|`pages_manage_posts`|Post as a Page|Yes|

Permissions beyond `public_profile` and `email` require App Review for apps in Live mode. In Development mode, only app admins/testers can authorize them.

---

## 9. App Modes

Facebook enforces a distinction between app modes:

|Mode|Who can log in|Permissions available|
|---|---|---|
|Development|App admins, developers, testers only|All (for testing)|
|Live|Any Facebook user|Only approved permissions|

Switch to Live mode under **App Settings → Basic → App Status**. The app must have a valid privacy policy URL and complete domain verification before switching.

---

## 10. Token Behavior

Unlike Google, Facebook does **not** issue refresh tokens in the standard OAuth flow. Instead:

- The access token has a short TTL (~1–2 hours)
- You can exchange it for a **long-lived token** (~60 days) via the Graph API server-side:

```js
// Exchange short-lived for long-lived token
const url = `https://graph.facebook.com/oauth/access_token`
  + `?grant_type=fb_exchange_token`
  + `&client_id=${APP_ID}`
  + `&client_secret=${APP_SECRET}`
  + `&fb_exchange_token=${shortLivedToken}`;

const response = await fetch(url);
const { access_token, expires_in } = await response.json();
```

This exchange must happen server-side. The long-lived token can then be stored and used for offline Graph API calls.

---

## 11. `profileFields`

The `profileFields` option maps to Graph API fields. You must explicitly list every field you want:

```js
profileFields: ['id', 'displayName', 'name', 'emails', 'photos', 'birthday', 'gender']
```

Internally, `passport-facebook` translates Passport field names to Graph API field names. Some fields use Graph API names directly (e.g., `'birthday'`, `'gender'`). When in doubt, use `_json` on the profile to inspect the raw response.

---

## 12. `passReqToCallback`

```js
new FacebookStrategy(
  { ..., passReqToCallback: true },
  function(req, accessToken, refreshToken, profile, done) {
    // req available here
    // Useful for account linking when user is already logged in
  }
)
```

---

## 13. Error Handling

```js
// Custom callback for full control
app.get('/auth/facebook/callback', function(req, res, next) {
  passport.authenticate('facebook', function(err, user, info) {
    if (err)   return next(err);
    if (!user) return res.redirect('/login?error=' + encodeURIComponent(info));
    req.logIn(user, function(err) {
      if (err) return next(err);
      res.redirect('/dashboard');
    });
  })(req, res, next);
});
```

Facebook-specific error cases:

|Scenario|Behavior|
|---|---|
|User denies permission|Callback receives `error=access_denied` query param; `user` is `false`|
|Permission not granted|`profile` field absent; app must handle gracefully|
|App not in Live mode|Non-test users get an error screen from Facebook|

---

## 14. Graph API Version

Facebook deprecates old API versions on a rolling basis. Specify the version explicitly:

```js
new FacebookStrategy({
  ...
  graphAPIVersion: 'v19.0',
})
```

Check the [Graph API changelog](https://developers.facebook.com/docs/graph-api/changelog) for the current stable version. Unspecified versions may default to an older one depending on the package release.

---

## 15. Common Failure Modes

|Symptom|Likely Cause|
|---|---|
|`Invalid redirect_uri`|Callback URL not listed in Valid OAuth Redirect URIs|
|`profile.emails` empty|`email` permission not granted, or user has no email on account|
|Can't log in as external user|App still in Development mode|
|`Error validating access token`|Token expired; no automatic refresh mechanism|
|Missing profile fields|`profileFields` not set, or permission not approved|
|`graphAPIVersion` errors|Deprecated API version; update to current|

---

## 16. Minimal Working Example

```js
require('dotenv').config();
const express  = require('express');
const session  = require('express-session');
const passport = require('passport');
const { Strategy: FacebookStrategy } = require('passport-facebook');

const users = new Map();

passport.use(new FacebookStrategy({
  clientID:      process.env.FACEBOOK_APP_ID,
  clientSecret:  process.env.FACEBOOK_APP_SECRET,
  callbackURL:   'http://localhost:3000/auth/facebook/callback',
  profileFields: ['id', 'displayName', 'emails'],
  graphAPIVersion: 'v19.0',
}, (accessToken, refreshToken, profile, done) => {
  let user = users.get(profile.id);
  if (!user) {
    user = {
      id:    profile.id,
      name:  profile.displayName,
      email: profile.emails?.[0]?.value ?? null, // May be absent
    };
    users.set(profile.id, user);
  }
  return done(null, user);
}));

passport.serializeUser((user, done) => done(null, user.id));
passport.deserializeUser((id, done) => done(null, users.get(id) ?? false));

const app = express();
app.use(session({ secret: process.env.SESSION_SECRET, resave: false, saveUninitialized: false }));
app.use(passport.initialize());
app.use(passport.session());

app.get('/auth/facebook',          passport.authenticate('facebook', { scope: ['email'] }));
app.get('/auth/facebook/callback', passport.authenticate('facebook', { failureRedirect: '/login', successRedirect: '/' }));
app.get('/logout', (req, res) => { req.logout(() => res.redirect('/')); });
app.get('/', (req, res) => {
  res.send(req.isAuthenticated()
    ? `Hello ${req.user.name}`
    : '<a href="/auth/facebook">Login with Facebook</a>'
  );
});

app.listen(3000);
```

---

**Key Points:** Always use optional chaining on `profile.emails?.[0]?.value` — its absence is normal and must be handled. Keep the app in Development mode during testing and switch to Live only after App Review. Specify `graphAPIVersion` explicitly to avoid behavior changes from Facebook deprecations.

---

# `passport-github` / `passport-github2`

---

## Overview

Both `passport-github` and `passport-github2` implement OAuth 2.0 authentication against GitHub. `passport-github2` is the maintained fork — `passport-github` is effectively abandoned. For any new project, use `passport-github2`. The API surface is nearly identical; differences are noted where they exist.

---

## 1. Prerequisites

- Node.js + Express application
- A GitHub OAuth App (or GitHub App with user authorization)
- Packages: `passport`, `passport-github2`, `express-session`

---

## 2. GitHub OAuth App Setup

1. Go to **GitHub → Settings → Developer settings → OAuth Apps → New OAuth App**
2. Fill in:
    - **Application name** — display name shown on the authorization screen
    - **Homepage URL** — your app's root URL
    - **Authorization callback URL** — must exactly match the `callbackURL` in your strategy config (e.g., `http://localhost:3000/auth/github/callback`)
3. Click **Register application**
4. Copy the **Client ID**
5. Click **Generate a new client secret** and copy it immediately — it is not shown again

---

## 3. Installation

```bash
# Use passport-github2 for all new projects
npm install passport passport-github2 express express-session
```

```bash
# Legacy only — not recommended
npm install passport passport-github express express-session
```

---

## 4. Strategy Registration

```js
const passport = require('passport');
const { Strategy: GitHubStrategy } = require('passport-github2');

passport.use(new GitHubStrategy(
  {
    clientID:     process.env.GITHUB_CLIENT_ID,
    clientSecret: process.env.GITHUB_CLIENT_SECRET,
    callbackURL:  'http://localhost:3000/auth/github/callback',

    // Optional: request specific fields via GitHub API scope
    scope: ['user:email'],

    // Optional: pass req into verify callback
    passReqToCallback: false,
  },
  function verify(accessToken, refreshToken, profile, done) {
    User.findOrCreate({ githubId: profile.id }, function(err, user) {
      return done(err, user);
    });
  }
));
```

**`verify` callback contract:**

|Argument|Description|
|---|---|
|`accessToken`|GitHub user access token; no expiry by default|
|`refreshToken`|Not issued by GitHub for OAuth Apps; `undefined`|
|`profile`|Normalized profile object (see §7)|
|`done(err, user, info)`|Pass `false` as user to deny; pass user object to authenticate|

---

## 5. Session Serialization

```js
passport.serializeUser(function(user, done) {
  done(null, user.id);
});

passport.deserializeUser(function(id, done) {
  User.findById(id, function(err, user) {
    done(err, user);
  });
});
```

---

## 6. Express Wiring

```js
const express = require('express');
const session  = require('express-session');
const passport = require('passport');

const app = express();

app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
}));

app.use(passport.initialize());
app.use(passport.session());

// Initiate OAuth flow
app.get('/auth/github',
  passport.authenticate('github', {
    scope: ['user:email'],
  })
);

// Handle callback from GitHub
app.get('/auth/github/callback',
  passport.authenticate('github', {
    failureRedirect: '/login',
    successRedirect: '/dashboard',
  })
);

app.get('/dashboard', ensureAuthenticated, (req, res) => {
  res.send(`Hello, ${req.user.username}`);
});

function ensureAuthenticated(req, res, next) {
  if (req.isAuthenticated()) return next();
  res.redirect('/login');
}

app.listen(3000);
```

---

## 7. The `profile` Object

GitHub returns a profile normalized by Passport. Confirmed fields:

```json
{
  "id": "12345678",
  "nodeId": "MDQ6VXNlcjEyMzQ1Njc4",
  "displayName": "Jane Doe",
  "username": "janedoe",
  "profileUrl": "https://github.com/janedoe",
  "emails": [
    { "value": "jane@example.com", "primary": true, "verified": true }
  ],
  "photos": [
    { "value": "https://avatars.githubusercontent.com/u/12345678?v=4" }
  ],
  "provider": "github",
  "_raw": "...",
  "_json": { ... }
}
```

**Field availability notes:**

- `emails` is only populated if the `user:email` scope was requested. Even then, if the user has set their email to private on GitHub, the public email field is `null` — the `user:email` scope is required to retrieve it via the `/user/emails` API endpoint.
- `displayName` maps to the user's profile name, not their login handle. It may be `null` if the user has not set one.
- `username` maps to the GitHub login handle — the most reliable identifier alongside `id`.
- Use `profile.id` (not `profile.username`) as the stable foreign key in your database; usernames can be changed.

---

## 8. Scopes

GitHub OAuth scopes control what the access token can do beyond basic authentication.

|Scope|What it grants|
|---|---|
|_(none)_|Read-only public profile data; no email|
|`user:email`|Read user email addresses (including private)|
|`read:user`|Read all user profile data|
|`user`|Read/write user profile data|
|`repo`|Full access to public and private repositories|
|`public_repo`|Access to public repositories only|
|`gist`|Create gists|
|`read:org`|Read organization membership|
|`admin:org`|Full organization management|
|`workflow`|Update GitHub Actions workflows|

Request only what your application needs. GitHub displays the requested scopes on the authorization screen; broad scopes reduce user trust.

---

## 9. Token Behavior

GitHub OAuth App tokens have no expiration by default — they remain valid until:

- The user revokes authorization via GitHub Settings
- The OAuth App is deleted
- The token is explicitly revoked via the API

There is no refresh token mechanism for OAuth Apps. If you need expiring tokens, use **GitHub Apps** with user-to-server tokens, which do expire and support refresh.

**Storing tokens:** If your app needs to make GitHub API calls on behalf of the user after authentication, store the `accessToken` from the verify callback securely server-side.

---

## 10. `passport-github` vs `passport-github2` Differences

|Aspect|`passport-github`|`passport-github2`|
|---|---|---|
|Maintenance status|Abandoned|Actively maintained|
|Default OAuth endpoint|`github.com/login/oauth`|Same|
|`scope` in strategy options|Supported|Supported|
|`profile.emails` population|Inconsistent across versions|Consistently populated when `user:email` granted|
|Node.js compatibility|May lack support for newer versions|Maintained for current Node.js|
|npm registry|`passport-github`|`passport-github2`|

The strategy name registered with Passport is `'github'` in both packages — they are drop-in replacements for routing purposes.

---

## 11. `passReqToCallback`

```js
new GitHubStrategy(
  { ..., passReqToCallback: true },
  function(req, accessToken, refreshToken, profile, done) {
    // req is the Express request object
    // Useful for account linking when user is already logged in
    if (req.user) {
      // Link GitHub account to existing session user
    }
  }
)
```

---

## 12. Error Handling

```js
// Custom callback for full control
app.get('/auth/github/callback', function(req, res, next) {
  passport.authenticate('github', function(err, user, info) {
    if (err)   return next(err);
    if (!user) return res.redirect('/login?error=' + encodeURIComponent(info));
    req.logIn(user, function(err) {
      if (err) return next(err);
      res.redirect('/dashboard');
    });
  })(req, res, next);
});
```

GitHub-specific error cases:

|Scenario|Behavior|
|---|---|
|User denies authorization|Callback receives `error=access_denied`; `user` is `false`|
|Invalid client secret|GitHub returns an error at token exchange|
|Callback URL mismatch|GitHub rejects the authorization request outright|
|Scope not granted|Token is issued but API calls for that scope fail with 403|

---

## 13. GitHub Apps vs OAuth Apps

`passport-github2` works with OAuth Apps. GitHub Apps are a separate concept:

||OAuth App|GitHub App|
|---|---|---|
|Token type|User access token|User-to-server token|
|Token expiry|No expiry|Expires; supports refresh|
|Granular permissions|No (scope-based only)|Yes (fine-grained)|
|Installation context|Per-user|Per-organization or per-repo|
|Passport strategy support|`passport-github2`|Requires custom strategy or `passport-github-app`|

For most authentication-only use cases, OAuth Apps with `passport-github2` are sufficient.

---

## 14. Common Failure Modes

|Symptom|Likely Cause|
|---|---|
|`redirect_uri_mismatch`|Callback URL in code doesn't exactly match the registered one|
|`profile.emails` empty|`user:email` scope not requested, or email set to private without the scope|
|`displayName` is `null`|User has not set a display name on their GitHub profile|
|Token works but API calls fail|Requested scope insufficient for the API endpoint being called|
|Strategy not found at runtime|Still importing `passport-github` after installing `passport-github2`|

---

## 15. Minimal Working Example

```js
require('dotenv').config();
const express  = require('express');
const session  = require('express-session');
const passport = require('passport');
const { Strategy: GitHubStrategy } = require('passport-github2');

const users = new Map();

passport.use(new GitHubStrategy({
  clientID:     process.env.GITHUB_CLIENT_ID,
  clientSecret: process.env.GITHUB_CLIENT_SECRET,
  callbackURL:  'http://localhost:3000/auth/github/callback',
}, (accessToken, refreshToken, profile, done) => {
  let user = users.get(profile.id);
  if (!user) {
    user = {
      id:       profile.id,
      username: profile.username,
      name:     profile.displayName ?? profile.username,
      email:    profile.emails?.[0]?.value ?? null,
    };
    users.set(profile.id, user);
  }
  return done(null, user);
}));

passport.serializeUser((user, done) => done(null, user.id));
passport.deserializeUser((id, done) => done(null, users.get(id) ?? false));

const app = express();
app.use(session({ secret: process.env.SESSION_SECRET, resave: false, saveUninitialized: false }));
app.use(passport.initialize());
app.use(passport.session());

app.get('/auth/github',          passport.authenticate('github', { scope: ['user:email'] }));
app.get('/auth/github/callback', passport.authenticate('github', { failureRedirect: '/login', successRedirect: '/' }));
app.get('/logout', (req, res) => { req.logout(() => res.redirect('/')); });
app.get('/', (req, res) => {
  res.send(req.isAuthenticated()
    ? `Hello ${req.user.username}`
    : '<a href="/auth/github">Login with GitHub</a>'
  );
});

app.listen(3000);
```

---

**Key Points:** Always key your database records on `profile.id`, not `profile.username` — GitHub allows username changes. Use `passport-github2` exclusively for new work. Request `user:email` if you need the email address, and handle `null` email gracefully since private email configurations will omit it even with the scope granted.

---

# passport-twitter

> **Status note:** `passport-twitter` (the OAuth 1.0a strategy) is deprecated and no longer maintained by its original author. The actively maintained successor is `passport-twitter-oauth2`, which uses OAuth 2.0. This guide covers both, with clear labels distinguishing them. All behavior claims about middleware, session handling, and token storage are marked `[Inference]` unless confirmed by official documentation. LLM behavior predictions carry a disclaimer that outcomes are not guaranteed.

---

## Table of Contents

1. [Overview](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#overview)
2. [Package Comparison: OAuth 1.0a vs OAuth 2.0](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#package-comparison)
3. [Prerequisites](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#prerequisites)
4. [Installation](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#installation)
5. [Twitter Developer Portal Setup](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#twitter-developer-portal-setup)
6. [Basic Configuration](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#basic-configuration)
7. [Strategy Options Reference](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#strategy-options-reference)
8. [Routes and Middleware](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#routes-and-middleware)
9. [Session Serialization and Deserialization](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#session-serialization-and-deserialization)
10. [Accessing the Twitter Profile Object](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#accessing-the-twitter-profile-object)
11. [Storing Tokens](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#storing-tokens)
12. [Error Handling](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#error-handling)
13. [Using with Express](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#using-with-express)
14. [Using with NestJS](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#using-with-nestjs)
15. [Environment Variables and Security](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#environment-variables-and-security)
16. [Common Pitfalls](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#common-pitfalls)
17. [Testing](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#testing)
18. [Upgrading to OAuth 2.0](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#upgrading-to-oauth-20)
19. [Known Limitations](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#known-limitations)
20. [Resources](https://claude.ai/chat/eeb16502-539a-4e48-9e4b-73bb668d6521#resources)

---

## Overview

`passport-twitter` is a [Passport.js](http://www.passportjs.org/) authentication strategy that allows users to sign in to your application using their Twitter (now X) account. The original package uses **OAuth 1.0a**, which is the protocol Twitter used for most of its history. As of early 2023, Twitter began restricting OAuth 1.0a access on its free tier, and the ecosystem shifted toward `passport-twitter-oauth2`, which implements **OAuth 2.0 with PKCE**.

Passport.js itself is a middleware framework for Node.js that delegates authentication to pluggable "strategies." The strategies handle the protocol specifics; Passport handles the plumbing (attaching the user to `req.user`, managing sessions, redirects).

---

## Package Comparison

|Feature|`passport-twitter`|`passport-twitter-oauth2`|
|---|---|---|
|Protocol|OAuth 1.0a|OAuth 2.0 + PKCE|
|Maintenance status|Deprecated|Actively maintained (as of 2024)|
|Twitter free tier|Restricted / broken|Supported|
|Requires app secret|Yes (Consumer Secret)|Yes (Client Secret)|
|Token type|Access token + secret|Bearer token / refresh token|
|npm package|`passport-twitter`|`passport-twitter-oauth2`|

Unless you have a specific reason to use OAuth 1.0a (e.g., legacy system, Elevated Access tier), prefer `passport-twitter-oauth2`.

---

## Prerequisites

Before writing any code, you need:

- Node.js 14 or later (16+ recommended)
- A Twitter Developer account with a project and app created at [developer.twitter.com](https://developer.twitter.com/)
- A callback URL whitelisted in your Twitter app settings
- `express`, `passport`, `express-session` (or a compatible session store) installed

---

## Installation

### OAuth 1.0a (legacy)

```bash
npm install passport passport-twitter express-session
```

### OAuth 2.0 (recommended)

```bash
npm install passport passport-twitter-oauth2 express-session
```

---

## Twitter Developer Portal Setup

1. Go to [developer.twitter.com/en/portal/dashboard](https://developer.twitter.com/en/portal/dashboard).
2. Create a **Project** and an **App** inside it.
3. Under **App settings > Authentication settings**, enable **OAuth 1.0a** or **OAuth 2.0** depending on your chosen package.
4. Set the **Callback URL** to match your application (e.g., `http://localhost:3000/auth/twitter/callback` for local development).
5. Set the **Website URL** (required by Twitter).
6. Copy your **API Key** (Consumer Key), **API Secret** (Consumer Secret), and — for OAuth 2.0 — your **Client ID** and **Client Secret**.

> **Important:** Twitter requires the callback URL to match **exactly**, including trailing slashes and protocol (`http` vs `https`). Mismatches are a common source of `401 Unauthorized` errors.

---

## Basic Configuration

### OAuth 1.0a (`passport-twitter`)

```js
const passport = require('passport');
const TwitterStrategy = require('passport-twitter').Strategy;

passport.use(
  new TwitterStrategy(
    {
      consumerKey: process.env.TWITTER_CONSUMER_KEY,
      consumerSecret: process.env.TWITTER_CONSUMER_SECRET,
      callbackURL: 'http://localhost:3000/auth/twitter/callback',
    },
    function verify(token, tokenSecret, profile, done) {
      // token       — OAuth 1.0a access token
      // tokenSecret — OAuth 1.0a access token secret
      // profile     — normalized Passport profile object
      // done        — callback: done(err, user)

      // Find or create the user in your database here.
      User.findOrCreate({ twitterId: profile.id }, function (err, user) {
        return done(err, user);
      });
    }
  )
);
```

### OAuth 2.0 (`passport-twitter-oauth2`)

```js
const passport = require('passport');
const { Strategy: TwitterStrategy } = require('passport-twitter-oauth2');

passport.use(
  new TwitterStrategy(
    {
      clientID: process.env.TWITTER_CLIENT_ID,
      clientSecret: process.env.TWITTER_CLIENT_SECRET,
      callbackURL: 'http://localhost:3000/auth/twitter/callback',
      scope: ['tweet.read', 'users.read', 'offline.access'],
    },
    function verify(accessToken, refreshToken, profile, done) {
      User.findOrCreate({ twitterId: profile.id }, function (err, user) {
        return done(err, user);
      });
    }
  )
);
```

---

## Strategy Options Reference

### OAuth 1.0a Options

|Option|Type|Required|Description|
|---|---|---|---|
|`consumerKey`|string|Yes|Twitter API Key (Consumer Key)|
|`consumerSecret`|string|Yes|Twitter API Secret (Consumer Secret)|
|`callbackURL`|string|Yes|Full URL Twitter redirects to after auth|
|`userAuthorizationURL`|string|No|Override for the authorization endpoint|
|`requestTokenURL`|string|No|Override for request token endpoint|
|`accessTokenURL`|string|No|Override for access token endpoint|
|`userProfileURL`|string|No|Twitter API endpoint for fetching the user profile|
|`includeEmail`|boolean|No|Request the user's email (requires Elevated Access)|
|`includeStatus`|boolean|No|Include the user's last tweet in profile data|
|`includeEntities`|boolean|No|Include Twitter entities in the profile|
|`skipExtendedUserProfile`|boolean|No|Skip the secondary API call for extended profile data|
|`proxy`|boolean/string|No|Whether to trust the `X-Forwarded-Proto` header|
|`passReqToCallback`|boolean|No|If `true`, passes `req` as the first argument to the verify callback|

### OAuth 2.0 Options (`passport-twitter-oauth2`)

|Option|Type|Required|Description|
|---|---|---|---|
|`clientID`|string|Yes|OAuth 2.0 Client ID|
|`clientSecret`|string|Yes|OAuth 2.0 Client Secret|
|`callbackURL`|string|Yes|Redirect URI registered in Twitter Developer Portal|
|`scope`|string[]|Yes|Array of OAuth 2.0 scopes|
|`state`|boolean|No|Enable CSRF state parameter (recommended: `true`)|
|`pkce`|boolean|No|Enable PKCE (recommended: `true`)|
|`passReqToCallback`|boolean|No|Pass `req` as first arg to verify callback|

---

## Routes and Middleware

### Express Routes — OAuth 1.0a

```js
const express = require('express');
const passport = require('passport');
const app = express();

// Initiates the OAuth 1.0a flow — redirects user to twitter.com
app.get('/auth/twitter', passport.authenticate('twitter'));

// Twitter redirects here after user approves/denies
app.get(
  '/auth/twitter/callback',
  passport.authenticate('twitter', {
    successRedirect: '/dashboard',
    failureRedirect: '/login',
    failureMessage: true, // stores failure message in session
  })
);

// Protected route example
app.get('/dashboard', ensureAuthenticated, (req, res) => {
  res.send(`Hello, ${req.user.username}`);
});

function ensureAuthenticated(req, res, next) {
  if (req.isAuthenticated()) return next();
  res.redirect('/login');
}
```

### Express Routes — OAuth 2.0

```js
// Initiates the OAuth 2.0 flow with PKCE
app.get('/auth/twitter', passport.authenticate('twitter', {
  scope: ['tweet.read', 'users.read'],
}));

app.get(
  '/auth/twitter/callback',
  passport.authenticate('twitter', {
    successRedirect: '/dashboard',
    failureRedirect: '/login',
  })
);
```

---

## Session Serialization and Deserialization

Passport relies on your session store to persist the authenticated user between requests. You must implement `serializeUser` and `deserializeUser`.

```js
// Called once after successful login — stores user identifier in the session
passport.serializeUser(function (user, done) {
  done(null, user.id); // store only the user's DB id
});

// Called on every subsequent request — retrieves the full user from the session id
passport.deserializeUser(function (id, done) {
  User.findById(id, function (err, user) {
    done(err, user);
  });
});
```

**What to serialize:** Store only a stable, compact identifier (e.g., database primary key). Do not serialize the entire profile or token into the session cookie unless you have a specific reason and understand the size implications.

---

## Accessing the Twitter Profile Object

The `profile` object passed to your verify callback is a Passport-normalized object. Its structure follows the [Portable Contacts schema](http://portablecontacts.net/) convention used by Passport.

### Common Fields

```js
profile.id           // Twitter user ID (string)
profile.username     // Twitter handle (without @)
profile.displayName  // Name as shown on Twitter
profile.photos       // Array of photo objects: [{ value: 'https://...' }]
profile.emails       // Array of email objects (only if email scope granted)
profile._json        // Raw JSON response from the Twitter API
profile._raw         // Raw string response from the Twitter API
```

### Accessing the Profile Image

```js
const avatarUrl = profile.photos && profile.photos[0]
  ? profile.photos[0].value
  : null;
```

> **Note:** Twitter profile image URLs may use `_normal` sizing (48×48 px). To get a larger version, replace `_normal` with `_400x400` or remove the suffix entirely — but verify this against Twitter's current API documentation, as URL conventions may change.

### Accessing the Raw Profile

```js
const twitterData = profile._json;
// twitterData.description — bio text
// twitterData.followers_count — follower count (OAuth 1.0a; field names differ in v2)
// twitterData.verified — legacy verified badge (deprecated in Twitter API v2)
```

> **Warning:** Fields in `_json` differ significantly between Twitter API v1.1 (used by OAuth 1.0a) and Twitter API v2 (used by OAuth 2.0). Do not assume field names are consistent across both.

---

## Storing Tokens

### OAuth 1.0a

Store the `token` and `tokenSecret` together. Both are required to make authenticated API calls on behalf of the user. They do not expire on their own, but can be revoked by the user or by Twitter.

```js
function verify(token, tokenSecret, profile, done) {
  User.findOrCreate(
    { twitterId: profile.id },
    {
      username: profile.username,
      displayName: profile.displayName,
      twitterToken: token,
      twitterTokenSecret: tokenSecret,
    },
    function (err, user) {
      return done(err, user);
    }
  );
}
```

### OAuth 2.0

Store the `accessToken` and `refreshToken`. Access tokens expire (duration depends on scope and Twitter's policies). Use the refresh token to obtain a new access token.

```js
function verify(accessToken, refreshToken, profile, done) {
  User.findOrCreate(
    { twitterId: profile.id },
    {
      twitterAccessToken: accessToken,
      twitterRefreshToken: refreshToken,
    },
    function (err, user) {
      return done(err, user);
    }
  );
}
```

> **Security:** Treat tokens as secrets. Do not log them, do not return them to the client, and store them encrypted at rest when possible.

---

## Error Handling

### Common Errors

|Error|Likely Cause|
|---|---|
|`401 Unauthorized` on callback|Callback URL mismatch; invalid consumer key/secret|
|`403 Forbidden`|App does not have permission for the requested scope|
|`Failed to obtain request token`|Consumer key/secret wrong or Twitter API down|
|`InternalOAuthError`|Generic OAuth layer error — check credentials and callback URL|
|Session errors on callback|`express-session` not configured before `passport.initialize()`|
|`oauth_callback_confirmed` is false|Twitter rejected the callback URL registration|

### Custom Failure Handling

Instead of `failureRedirect`, you can intercept authentication failures manually:

```js
app.get(
  '/auth/twitter/callback',
  function (req, res, next) {
    passport.authenticate('twitter', function (err, user, info) {
      if (err) return next(err);
      if (!user) {
        // info.message may contain the reason for failure
        return res.redirect('/login?error=' + encodeURIComponent(info?.message || 'auth_failed'));
      }
      req.logIn(user, function (loginErr) {
        if (loginErr) return next(loginErr);
        return res.redirect('/dashboard');
      });
    })(req, res, next);
  }
);
```

---

## Using with Express

### Full Example (OAuth 2.0)

```js
require('dotenv').config();
const express = require('express');
const session = require('express-session');
const passport = require('passport');
const { Strategy: TwitterStrategy } = require('passport-twitter-oauth2');

const app = express();

// Session middleware must be configured before Passport
app.use(
  session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: { secure: process.env.NODE_ENV === 'production' },
  })
);

app.use(passport.initialize());
app.use(passport.session());

passport.use(
  new TwitterStrategy(
    {
      clientID: process.env.TWITTER_CLIENT_ID,
      clientSecret: process.env.TWITTER_CLIENT_SECRET,
      callbackURL: process.env.TWITTER_CALLBACK_URL,
      scope: ['tweet.read', 'users.read', 'offline.access'],
      pkce: true,
      state: true,
    },
    function (accessToken, refreshToken, profile, done) {
      // Replace with your actual DB logic
      const user = {
        id: profile.id,
        username: profile.username,
        displayName: profile.displayName,
        accessToken,
        refreshToken,
      };
      return done(null, user);
    }
  )
);

passport.serializeUser((user, done) => done(null, user.id));
passport.deserializeUser((id, done) => {
  // Replace with DB lookup
  done(null, { id });
});

app.get('/auth/twitter', passport.authenticate('twitter'));

app.get(
  '/auth/twitter/callback',
  passport.authenticate('twitter', {
    successRedirect: '/profile',
    failureRedirect: '/?error=auth_failed',
  })
);

app.get('/profile', (req, res) => {
  if (!req.isAuthenticated()) return res.redirect('/');
  res.json(req.user);
});

app.get('/logout', (req, res, next) => {
  req.logout(function (err) {
    if (err) return next(err);
    res.redirect('/');
  });
});

app.listen(3000, () => console.log('Server running on port 3000'));
```

---

## Using with NestJS

NestJS wraps Passport strategies in **Guards**. The typical pattern uses `@nestjs/passport`.

### Install

```bash
npm install @nestjs/passport passport passport-twitter-oauth2
npm install --save-dev @types/passport-twitter
```

### Strategy

```ts
// twitter.strategy.ts
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-twitter-oauth2';

@Injectable()
export class TwitterStrategy extends PassportStrategy(Strategy, 'twitter') {
  constructor() {
    super({
      clientID: process.env.TWITTER_CLIENT_ID,
      clientSecret: process.env.TWITTER_CLIENT_SECRET,
      callbackURL: process.env.TWITTER_CALLBACK_URL,
      scope: ['tweet.read', 'users.read'],
    });
  }

  async validate(
    accessToken: string,
    refreshToken: string,
    profile: any,
  ): Promise<any> {
    // Return the user object to attach to req.user
    return { twitterId: profile.id, username: profile.username, accessToken };
  }
}
```

### Guard

```ts
// twitter-auth.guard.ts
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class TwitterAuthGuard extends AuthGuard('twitter') {}
```

### Controller

```ts
// auth.controller.ts
import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { TwitterAuthGuard } from './twitter-auth.guard';

@Controller('auth')
export class AuthController {
  @Get('twitter')
  @UseGuards(TwitterAuthGuard)
  twitterLogin() {
    // Passport handles the redirect
  }

  @Get('twitter/callback')
  @UseGuards(TwitterAuthGuard)
  twitterCallback(@Req() req) {
    return req.user;
  }
}
```

---

## Environment Variables and Security

### Recommended `.env` Structure

```dotenv
TWITTER_CONSUMER_KEY=your_api_key
TWITTER_CONSUMER_SECRET=your_api_secret
TWITTER_CLIENT_ID=your_oauth2_client_id
TWITTER_CLIENT_SECRET=your_oauth2_client_secret
TWITTER_CALLBACK_URL=http://localhost:3000/auth/twitter/callback
SESSION_SECRET=a_long_random_string_at_least_32_chars
NODE_ENV=development
```

### Security Checklist

- Never commit `.env` to version control. Add it to `.gitignore`.
- Use a strong, randomly generated `SESSION_SECRET` (at least 32 characters).
- Set `cookie.secure: true` in production (requires HTTPS).
- Set `cookie.httpOnly: true` (default in `express-session`) to reduce XSS exposure.
- Use `cookie.sameSite: 'lax'` or `'strict'` to reduce CSRF surface.
- Enable `state: true` and `pkce: true` in OAuth 2.0 to reduce CSRF and code interception risk.
- Rotate tokens if you suspect compromise. Twitter allows token revocation from the Developer Portal.

---

## Common Pitfalls

### 1. Session middleware order

`express-session` must be registered before `passport.initialize()` and `passport.session()`. Reversing this order causes session data to be unavailable to Passport.

### 2. Callback URL not whitelisted

The callback URL in your code must exactly match the one registered in the Twitter Developer Portal. Even a missing trailing slash causes a mismatch.

### 3. Not handling the callback route

If you define the `/auth/twitter` route but forget the `/auth/twitter/callback` route, users will see a 404 after Twitter redirects them back.

### 4. `req.logout()` is now async

Since `passport@0.6.0`, `req.logout()` requires a callback:

```js
// Correct (passport >= 0.6.0)
req.logout(function (err) {
  if (err) return next(err);
  res.redirect('/');
});
```

### 5. Profile email is not always available

Even with email scope requested, Twitter does not always return an email address. Code defensively:

```js
const email = profile.emails && profile.emails[0] ? profile.emails[0].value : null;
```

### 6. `includeEmail` requires Elevated Access (OAuth 1.0a)

Requesting a user's email via the OAuth 1.0a strategy requires Twitter's **Elevated Access** tier, which must be applied for separately. Free-tier apps do not have this permission.

### 7. Using a proxy or load balancer

If your app sits behind a reverse proxy (nginx, Heroku, etc.), set `proxy: true` in the strategy options and trust the proxy in Express:

```js
app.set('trust proxy', 1);
// and in strategy options:
// proxy: true
```

Without this, the callback URL may be constructed with `http://` when Twitter is expecting `https://`, causing a mismatch.

---

## Testing

### Unit Testing the Verify Callback

Extract the verify function and test it independently from Passport:

```js
// verify.js
async function verifyTwitterUser(token, tokenSecret, profile, done) {
  try {
    const user = await User.findOrCreate({ twitterId: profile.id });
    return done(null, user);
  } catch (err) {
    return done(err);
  }
}
module.exports = verifyTwitterUser;
```

```js
// verify.test.js
const verifyTwitterUser = require('./verify');

test('calls done with user on success', async () => {
  const mockProfile = { id: '12345', username: 'testuser' };
  const done = jest.fn();
  await verifyTwitterUser('token', 'secret', mockProfile, done);
  expect(done).toHaveBeenCalledWith(null, expect.objectContaining({ twitterId: '12345' }));
});
```

### Integration Testing

Use a tool like [supertest](https://github.com/ladjs/supertest) combined with session mocking to test protected routes without hitting Twitter's servers. Stub `passport.authenticate` in tests to bypass the OAuth flow.

For end-to-end testing that exercises the actual OAuth redirect, tools like [Playwright](https://playwright.dev/) can automate the browser-level login flow using test Twitter accounts.

---

## Upgrading to OAuth 2.0

If you are migrating from `passport-twitter` (OAuth 1.0a) to `passport-twitter-oauth2`, the main changes are:

1. **Replace the package:** Uninstall `passport-twitter`, install `passport-twitter-oauth2`.
2. **Update credentials:** Replace `consumerKey`/`consumerSecret` with `clientID`/`clientSecret` in your config and environment variables.
3. **Update the verify callback signature:** OAuth 2.0 passes `(accessToken, refreshToken, profile, done)` instead of `(token, tokenSecret, profile, done)`.
4. **Add scopes:** OAuth 2.0 requires explicit scopes. At minimum: `['tweet.read', 'users.read']`.
5. **Enable PKCE and state:** Set `pkce: true` and `state: true` in strategy options.
6. **Update token storage:** If you were storing `twitterToken` and `twitterTokenSecret`, update your schema to store `accessToken` and `refreshToken`.
7. **Re-register your app in the Developer Portal:** Enable OAuth 2.0 in your app settings and update the callback URL if needed.
8. **Handle refresh tokens:** OAuth 2.0 access tokens expire. Implement token refresh logic if you need to make API calls outside of the login flow.

---

## Known Limitations

- `passport-twitter` (OAuth 1.0a) is deprecated and no longer receives updates. Bugs are unlikely to be fixed upstream.
- Twitter's free tier restrictions may block OAuth 1.0a token generation for new apps. Check the current [Twitter API tier documentation](https://developer.twitter.com/en/products/twitter-api) for the latest access levels.
- Email address retrieval via OAuth 1.0a requires Elevated Access, which Twitter grants manually and is not guaranteed.
- `profile._json` field names differ between Twitter API v1.1 (OAuth 1.0a) and v2 (OAuth 2.0). Code that reads from `_json` is not portable between the two.
- Passport.js does not handle token refresh automatically. If you need to make Twitter API calls after the session is established, you are responsible for refreshing the access token.

---

## Resources

- [passport-twitter on npm](https://www.npmjs.com/package/passport-twitter)
- [passport-twitter-oauth2 on npm](https://www.npmjs.com/package/passport-twitter-oauth2)
- [Passport.js official documentation](http://www.passportjs.org/docs/)
- [Twitter Developer Portal](https://developer.twitter.com/en/portal/dashboard)
- [Twitter API v2 documentation](https://developer.twitter.com/en/docs/twitter-api)
- [Twitter OAuth 2.0 documentation](https://developer.twitter.com/en/docs/authentication/oauth-2-0)
- [express-session documentation](https://github.com/expressjs/session)
- [@nestjs/passport documentation](https://docs.nestjs.com/security/authentication)

---

This is a documentation writing task — no skill needed. Let me write the guide directly.

---

# `passport-linkedin`

## Overview

`passport-linkedin` is a [Passport.js](http://www.passportjs.org/) authentication strategy for LinkedIn using OAuth. It allows Node.js applications to authenticate users via their LinkedIn accounts. There are two distinct packages in active use:

- **`passport-linkedin`** — the original OAuth 1.0a strategy (now largely deprecated; LinkedIn shut down OAuth 1.0a support)
- **`passport-linkedin-oauth2`** — the current OAuth 2.0 strategy, which is what virtually all active implementations use

This guide covers the OAuth 2.0 variant (`passport-linkedin-oauth2`) as the canonical implementation, with notes on the legacy package where relevant.

---

## Prerequisites

Before configuring the strategy, the following are required:

- Node.js (v14+ recommended)
- A LinkedIn Developer application registered at [https://www.linkedin.com/developers/](https://www.linkedin.com/developers/)
- The Client ID and Client Secret from that application
- A registered OAuth 2.0 redirect URL matching what you will configure in your app

---

## Installation

```bash
npm install passport passport-linkedin-oauth2
```

For session support (typical in web apps):

```bash
npm install express-session
```

---

## LinkedIn Developer App Setup

### Creating the App

1. Go to [https://www.linkedin.com/developers/apps/new](https://www.linkedin.com/developers/apps/new)
2. Fill in the app name, associated LinkedIn Page, and app logo
3. After creation, navigate to the **Auth** tab

### Configuring OAuth 2.0 Settings

Under the **Auth** tab:

- Copy your **Client ID** and **Client Secret** — these go into your environment variables
- Under **Authorized redirect URLs for your app**, add your callback URL (e.g., `http://localhost:3000/auth/linkedin/callback`)

### Selecting Products / Permissions

LinkedIn's API access is gated by **Products**, not just scopes. You must request and be approved for a product to use its associated scopes.

|Product|Key Scopes Unlocked|
|---|---|
|Sign In with LinkedIn using OpenID Connect|`openid`, `profile`, `email`|
|Share on LinkedIn|`w_member_social`|
|Marketing Developer Platform|Various ad/analytics scopes|

> **Note:** As of 2023–2024, LinkedIn deprecated the legacy `r_liteprofile` and `r_emailaddress` scopes in favor of OpenID Connect scopes (`openid`, `profile`, `email`). If you are working from older tutorials, their scope configuration will be incorrect for new apps.

---

## Basic Configuration

### Strategy Setup

```javascript
const passport = require('passport');
const LinkedInStrategy = require('passport-linkedin-oauth2').Strategy;

passport.use(new LinkedInStrategy({
  clientID: process.env.LINKEDIN_CLIENT_ID,
  clientSecret: process.env.LINKEDIN_CLIENT_SECRET,
  callbackURL: 'http://localhost:3000/auth/linkedin/callback',
  scope: ['openid', 'profile', 'email'],
}, function(accessToken, refreshToken, profile, done) {
  // Called after successful authentication
  // `profile` contains the normalized user profile
  User.findOrCreate({ linkedinId: profile.id }, function(err, user) {
    return done(err, user);
  });
}));
```

### Session Serialization

Required when using `express-session`:

```javascript
passport.serializeUser(function(user, done) {
  done(null, user.id);
});

passport.deserializeUser(function(id, done) {
  User.findById(id, function(err, user) {
    done(err, user);
  });
});
```

### Express App Setup

```javascript
const express = require('express');
const session = require('express-session');

const app = express();

app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
}));

app.use(passport.initialize());
app.use(passport.session());
```

---

## Routes

### Auth Initiation Route

```javascript
app.get('/auth/linkedin',
  passport.authenticate('linkedin')
);
```

You can pass a `state` parameter to protect against CSRF:

```javascript
app.get('/auth/linkedin',
  passport.authenticate('linkedin', { state: 'SOME_RANDOM_STRING' })
);
```

### Callback Route

```javascript
app.get('/auth/linkedin/callback',
  passport.authenticate('linkedin', {
    successRedirect: '/dashboard',
    failureRedirect: '/login',
  })
);
```

Or with a custom callback for finer control:

```javascript
app.get('/auth/linkedin/callback',
  passport.authenticate('linkedin', { failureRedirect: '/login' }),
  function(req, res) {
    // Authentication succeeded
    res.redirect('/dashboard');
  }
);
```

---

## The Profile Object

After authentication, `passport-linkedin-oauth2` provides a normalized `profile` object. Its shape depends on which scopes were granted.

### Typical Profile Structure

```json
{
  "id": "xxxxxx",
  "displayName": "Jane Doe",
  "name": {
    "familyName": "Doe",
    "givenName": "Jane"
  },
  "emails": [
    { "value": "jane@example.com" }
  ],
  "photos": [
    { "value": "https://..." }
  ],
  "_raw": "...",
  "_json": { ... }
}
```

- `_raw` — the raw JSON string from LinkedIn's API
- `_json` — the parsed object from LinkedIn's API, useful for accessing fields not mapped by the strategy

### Accessing Email

```javascript
const email = profile.emails && profile.emails[0] && profile.emails[0].value;
```

Email is only present if `email` scope was granted and the user's LinkedIn account has a verified email.

---

## Scope Reference

### Current OpenID Connect Scopes (Recommended)

|Scope|Description|
|---|---|
|`openid`|Required for OpenID Connect flow; returns `sub` claim|
|`profile`|Name, photo, profile URL|
|`email`|Primary email address|

### Legacy Scopes (Deprecated)

|Scope|Status|
|---|---|
|`r_liteprofile`|Deprecated — do not use for new apps|
|`r_emailaddress`|Deprecated — do not use for new apps|
|`r_fullprofile`|No longer available to new apps|
|`w_member_social`|Still available via Share on LinkedIn product|

---

## State Parameter and CSRF Protection

LinkedIn's OAuth 2.0 implementation supports the `state` parameter. You should generate a random value, store it in the session, and verify it in the callback.

`passport-linkedin-oauth2` accepts a `state` option in `passport.authenticate()`:

```javascript
app.get('/auth/linkedin', function(req, res, next) {
  const state = crypto.randomBytes(16).toString('hex');
  req.session.oauthState = state;
  passport.authenticate('linkedin', { state })(req, res, next);
});

app.get('/auth/linkedin/callback', function(req, res, next) {
  if (req.query.state !== req.session.oauthState) {
    return res.status(403).send('State mismatch');
  }
  passport.authenticate('linkedin', {
    successRedirect: '/dashboard',
    failureRedirect: '/login',
  })(req, res, next);
});
```

---

## Environment Variables

Never hardcode credentials. Use environment variables:

```
LINKEDIN_CLIENT_ID=your_client_id
LINKEDIN_CLIENT_SECRET=your_client_secret
SESSION_SECRET=your_session_secret
```

Load them with `dotenv`:

```bash
npm install dotenv
```

```javascript
require('dotenv').config();
```

---

## Token Handling

### Access Token

The `accessToken` passed to the verify callback is a short-lived Bearer token. LinkedIn's access tokens typically expire in 60 days for standard OAuth 2.0 flows, but this varies by product and is not under your direct control.

[Inference] You would need to store the access token if your application makes subsequent API calls to LinkedIn on behalf of the user after authentication. No guarantee is made here about LinkedIn's token TTL policies, which can change.

### Refresh Token

`passport-linkedin-oauth2` receives a `refreshToken` parameter in the verify callback. LinkedIn does issue refresh tokens for some flows, but the availability depends on the product and app type.

[Unverified] Refresh token behavior varies by LinkedIn app configuration and product approval status. Verify the current behavior in [LinkedIn's OAuth 2.0 documentation](https://learn.microsoft.com/en-us/linkedin/shared/authentication/authorization-code-flow).

---

## Common Errors and Fixes

### `invalid_redirect_uri`

The callback URL in your code does not match what is registered in the LinkedIn Developer portal. They must be identical including protocol and trailing slashes.

### `unauthorized_scope_error`

You are requesting a scope not enabled for your app. Either add the corresponding LinkedIn Product to your app or remove the scope.

### `badsessionid` / session not persisting

Ensure `express-session` is initialized before `passport.initialize()` and `passport.session()`, and that `saveUninitialized` is not interfering with session writes.

### Profile is empty or missing fields

The user may have denied certain permissions, or the fields require scopes you did not request. Always code defensively when accessing `profile.emails` and `profile.photos`.

### `Could not find property 'id' in profile`

[Inference] This typically occurs when the LinkedIn API response shape has changed and the strategy's internal parser fails. Check whether `profile._json` contains the data, and consider upgrading the package or patching the profile parser.

---

## Security Considerations

- Store `clientSecret` only in server-side environment variables — never expose it to the client
- Use HTTPS for all redirect URLs in production
- Validate the `state` parameter on every callback to protect against CSRF
- Do not log or persist `accessToken` unless required, and treat it as sensitive
- Use `express-session` with a strong, random `secret` and consider a persistent session store (e.g., `connect-redis`, `connect-mongo`) for production

---

## Full Minimal Working Example

```javascript
require('dotenv').config();
const express = require('express');
const session = require('express-session');
const passport = require('passport');
const LinkedInStrategy = require('passport-linkedin-oauth2').Strategy;

const app = express();

app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
}));

app.use(passport.initialize());
app.use(passport.session());

passport.use(new LinkedInStrategy({
  clientID: process.env.LINKEDIN_CLIENT_ID,
  clientSecret: process.env.LINKEDIN_CLIENT_SECRET,
  callbackURL: 'http://localhost:3000/auth/linkedin/callback',
  scope: ['openid', 'profile', 'email'],
}, function(accessToken, refreshToken, profile, done) {
  return done(null, profile);
}));

passport.serializeUser((user, done) => done(null, user));
passport.deserializeUser((user, done) => done(null, user));

app.get('/auth/linkedin', passport.authenticate('linkedin'));

app.get('/auth/linkedin/callback',
  passport.authenticate('linkedin', {
    successRedirect: '/profile',
    failureRedirect: '/',
  })
);

app.get('/profile', (req, res) => {
  if (!req.isAuthenticated()) return res.redirect('/');
  res.json(req.user);
});

app.get('/', (req, res) => res.send('<a href="/auth/linkedin">Login with LinkedIn</a>'));

app.listen(3000, () => console.log('Running on http://localhost:3000'));
```

---

## Package Maintenance Notes

As of the knowledge cutoff (August 2025):

- `passport-linkedin` (OAuth 1.0a) is effectively dead; LinkedIn shut down OAuth 1.0a support years ago
- `passport-linkedin-oauth2` is the maintained package, though community-maintained and not officially backed by LinkedIn
- LinkedIn's API surface changes frequently; always cross-reference the [LinkedIn Developer documentation](https://learn.microsoft.com/en-us/linkedin/shared/authentication/) for current scope and product availability

[Unverified] Package maintenance status and LinkedIn API compatibility should be verified at time of use, as the npm ecosystem and LinkedIn's platform policies are subject to change without notice.

---

# passport-apple: Comprehensive Guide

> **Disclaimer:** This guide is based on the official `passport-apple` GitHub repository (ananay/passport-apple), its README, and the associated `apple-auth` SETUP.md. Where behavior is inferred or not explicitly documented, it is labelled accordingly. Apple's Sign in with Apple API behavior is subject to change without notice.

---

## Table of Contents

1. [What is passport-apple?](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#1-what-is-passport-apple)
2. [How It Fits Into the Ecosystem](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#2-how-it-fits-into-the-ecosystem)
3. [Prerequisites](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#3-prerequisites)
4. [Apple Developer Account Setup](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#4-apple-developer-account-setup)
5. [Installation](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#5-installation)
6. [Strategy Configuration](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#6-strategy-configuration)
7. [Route Setup](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#7-route-setup)
8. [Handling the idToken and User Profile](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#8-handling-the-idtoken-and-user-profile)
9. [The One-Time Name Problem](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#9-the-one-time-name-problem)
10. [Local Development and HTTPS](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#10-local-development-and-https)
11. [Error Handling](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#11-error-handling)
12. [Session Management](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#12-session-management)
13. [Nonce Support](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#13-nonce-support)
14. [Related Packages and Forks](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#14-related-packages-and-forks)
15. [Common Pitfalls](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#15-common-pitfalls)
16. [Security Considerations](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#16-security-considerations)
17. [Legal Disclaimer](https://claude.ai/chat/2fc03b3f-698d-4d4e-825f-9ee265989722#17-legal-disclaimer)

---

## 1. What is passport-apple?

`passport-apple` is a Passport.js strategy for the Sign in with Apple feature, allowing Node.js applications to authenticate users via Apple ID using Apple's OAuth 2.0-based flow. The package is published on npm as `passport-apple` and maintained by Ananay Arora.

Key facts sourced from the repository:

- It uses `passport-oauth2` and replaces its client secret methods to support Apple's JWT-based client secret approach.
- It handles the POST-to-callback flow that Apple uses, which differs from most OAuth providers that use GET.
- It is not developed, endorsed by Apple Inc., or related to Apple Inc. in any way.

---

## 2. How It Fits Into the Ecosystem

Passport is authentication middleware for Node.js. Extremely flexible and modular, it can be unobtrusively dropped into any Express-based web application. `passport-apple` is a strategy plugin that handles the Sign in with Apple flow specifically.

The overall flow:

1. User clicks "Sign in with Apple" in your app.
2. Your server redirects to Apple's authorization server.
3. Apple authenticates the user and POSTs back to your callback URL with an authorization code and (on first login only) user profile data.
4. `passport-apple` exchanges the authorization code for tokens, provides the `idToken` JWT, and calls your verify callback with the result.
5. Your verify callback identifies or creates the user in your database and calls `cb(null, user)`.

---

## 3. Prerequisites

Before installing the package, you need:

- A paid **Apple Developer Program** membership.
- A Node.js application using **Express** (or a Connect-compatible framework).
- **Passport.js** installed (`npm install passport`).
- **HTTPS** on your production callback URL. Apple does not accept plain HTTP in production.
- A **body-parser** or equivalent middleware to parse URL-encoded POST bodies.

---

## 4. Apple Developer Account Setup

This section is sourced from the official `apple-auth` SETUP.md referenced by the passport-apple README.

### 4.1 Create an App ID

Go to [developer.apple.com](https://developer.apple.com/) → Certificates, Identifiers & Profiles → Identifiers → App IDs. Create a new App ID.

Scroll down to "Capabilities", find "Sign in with Apple", and check it. Hit Continue and then Register.

> You need to create an App ID even if you are building a web-only application with no iOS or macOS app.

### 4.2 Create a Services ID

Register a new Services ID, e.g. `com.example.account`. This is the `clientID` for the module configuration. Configure "Sign in with Apple" for this service and set the Return URLs. You might need to verify ownership of the domain by following the instructions.

### 4.3 Create a Key

Register a new Key, enable "Sign in with Apple" for this key and download it. Its ID is the `keyID`.

> **Critical:** Make sure you keep the file safe and secure. You cannot re-download it once you have already downloaded it.

### 4.4 Gather Your Credentials

After completing the above steps, you will have:

|Value|Where to find it|
|---|---|
|`clientID`|The Services ID identifier (e.g. `com.example.account`)|
|`teamID`|The 10-character code on the top left of the developer page next to your name|
|`keyID`|The key identifier shown in the Keys section|
|Private key|The downloaded `.p8` file|
|`callbackURL`|The return URL you configured in the Services ID|

---

## 5. Installation

Install the package via npm or yarn: `npm install --save passport-apple`. You will also need to install and configure body-parser if using Express: `npm install --save body-parser`.

```js
const bodyParser = require("body-parser");
app.use(bodyParser.urlencoded({ extended: true }));
```

---

## 6. Strategy Configuration

### 6.1 Basic Configuration

The strategy is initialized as follows:

```js
import AppleStrategy from 'passport-apple';
import jsonwebtoken from 'jsonwebtoken';
import assert from 'node:assert';
import fs from 'fs';
import path from 'path';

passport.use(new AppleStrategy({
  clientID: 'com.example.account',
  teamID: '1234567890',
  callbackURL: 'https://example.com/auth/apple/callback',
  keyID: 'ABCDEFGHIJ',
  privateKeyString: fs.readFileSync(
    path.join(__dirname, 'AuthKey_ABCDEFGHIJ.p8'),
    'utf-8'
  ),
  passReqToCallback: true,
}, async (req, accessToken, refreshToken, idToken, profile, cb) => {
  try {
    const decodedToken = jsonwebtoken.decode(idToken, { json: true });
    assert(decodedToken != null);

    const { sub, email, email_verified } = decodedToken;
    const user = await findOrCreateUser({ sub, email, email_verified });

    return cb(null, user);
  } catch (err) {
    return cb(err);
  }
}));
```

### 6.2 Configuration Options

|Option|Type|Description|
|---|---|---|
|`clientID`|string|Your Apple Services ID|
|`teamID`|string|Your 10-character Apple Team ID|
|`callbackURL`|string|The HTTPS URL Apple posts to after authentication|
|`keyID`|string|The identifier of your Sign in with Apple key|
|`privateKeyString`|string|The contents of your `.p8` file as a string|
|`privateKeyLocation`|string|Path to your `.p8` file (alternative to `privateKeyString`)|
|`passReqToCallback`|boolean|If `true`, `req` is passed as the first argument to the verify callback|
|`scope`|array|Fields to request: `['name', 'email']`|

### 6.3 Scope

```js
scope: ['name', 'email']
```

Requesting `name` and `email` prompts Apple to ask the user for consent. However, Apple only sends the name and email on the **first** authentication. See section 9 for details.

---

## 7. Route Setup

Apple's OAuth flow differs from most providers: **Apple POSTs to the callback URL** rather than using a GET redirect. This creates complications with cookie-based sessions because browsers block cookies in cross-site POST requests due to SameSite policy.

### 7.1 Initial Authorization Route

```js
app.get('/auth/apple', passport.authenticate('apple'));
```

### 7.2 Callback Routes — POST → GET Redirect Pattern

Apple is different in that they POST back to the callback. Because of SameSite policies in browsers, cookies cannot be included in external POST requests — so session authentication breaks. The solution is to redirect the POST request to GET with query parameters.

```js
// Apple POSTs here
app.post('/auth/apple/callback', express.urlencoded({ extended: true }), (req, res) => {
  const { body } = req;
  const sp = new URLSearchParams();
  Object.entries(body).forEach(([key, value]) => sp.set(key, String(value)));
  res.redirect(`/auth/apple/callback?${sp.toString()}`);
});

// Handle the GET after redirect
app.get('/auth/apple/callback',
  passport.authenticate('apple', {
    successReturnToOrRedirect: '/',
    failureRedirect: '/login',
  }),
  (err, req, res, next) => {
    if (err instanceof Error && (err.name === 'AuthorizationError' || err.name === 'TokenError')) {
      const sp = new URLSearchParams({ error: err.name });
      if ('code' in err && typeof err.code === 'string') sp.set('code', err.code);
      res.redirect(`/login?${sp.toString()}`);
      return;
    }
    res.redirect('/login');
  }
);
```

---

## 8. Handling the idToken and User Profile

The `idToken` returned is encoded. You can use the `jsonwebtoken` library via `jwt.decode(idToken)` to access the properties of the decoded idToken, which contains the user's identity information.

### 8.1 Decoding the idToken

```js
import jsonwebtoken from 'jsonwebtoken';

const decodedToken = jsonwebtoken.decode(idToken, { json: true });
```

The decoded token contains:

|Claim|Description|
|---|---|
|`sub`|Stable user identifier, scoped to your Team ID|
|`email`|User's email (if authorized); may be a private relay address|
|`email_verified`|Whether Apple has verified the email|
|`iss`|Issuer (`https://appleid.apple.com`)|
|`aud`|Your `clientID`|
|`exp`|Token expiry timestamp|

> **Important:** `jsonwebtoken.decode()` does **not** verify the token signature. [Unverified] Whether skipping signature verification is acceptable for your threat model is your decision. For production hardening, verify the signature against Apple's public keys at `https://appleid.apple.com/auth/keys`.

### 8.2 The `sub` Claim as Primary Key

Apple currently returns a User ID that is tied to your Team ID. The same Apple ID results in the same User ID for all authentication requests done with your Team ID. Other teams get a different ID for the same user.

Use `sub` as the primary key to look up or create users in your database.

### 8.3 Private Email Relay

When a user hides their email, Apple provides a private relay address (e.g. `abc123@privaterelay.appleid.com`). [Inference] To send email to private relay addresses, you must register your outbound email domains with Apple — consult Apple's official documentation for that process.

---

## 9. The One-Time Name Problem

This is one of the most critical behavioral characteristics of Sign in with Apple.

Apple will only provide you with the name ONCE — when the user first signs in. For every login after that, Apple will only provide a unique ID and the email. You must store the name in your database at this time.

### 9.1 Accessing the Name on First Login

```js
async (req, accessToken, refreshToken, idToken, profile, cb) => {
  // req.query['user'] because of the POST→GET redirect pattern
  // In a direct POST handler, use req.body.user instead
  const firstTimeUser = typeof req.query['user'] === 'string'
    ? JSON.parse(req.query['user'])
    : undefined;

  if (firstTimeUser) {
    const firstName = firstTimeUser.name?.firstName;
    const lastName  = firstTimeUser.name?.lastName;
    // Store now — this will not be sent again
  }
}
```

### 9.2 What You Must Do

Store the user's name immediately during first login. If you need to test first-auth again, you can remove the app from "Sign in with Apple" at appleid.apple.com/account/manage.

---

## 10. Local Development and HTTPS

Apple requires HTTPS for production callback URLs. For local development, you can work around this by using a service like redirectmeto.com. For example, if your local dev server is running on port 8080, add this redirect URL in your Apple developer console: `https://redirectmeto.com/http://localhost:8080/auth/apple/callback`.

> **Security warning:** Remember to remove it again after you're done testing, as it could be a security issue if running with it in production.

---

## 11. Error Handling

The strategy surfaces two primary error types:

### 11.1 AuthorizationError

|Code|Meaning|
|---|---|
|`user_cancelled_authorize`|The user declined to authorize the app|

### 11.2 TokenError

|Code|Meaning|
|---|---|
|`invalid_grant`|The authorization code has already been used or has expired|

### 11.3 Handling in Routes

For some reason, `failureRedirect` doesn't receive certain errors, so an error handler is needed alongside `passport.authenticate`.

```js
(err, req, res, next) => {
  if (err instanceof Error) {
    if (err.name === 'AuthorizationError') {
      return res.redirect('/login?error=cancelled');
    }
    if (err.name === 'TokenError') {
      return res.redirect('/login?error=token');
    }
  }
  next(err);
}
```

---

## 12. Session Management

Like all Passport.js strategies, `passport-apple` relies on your application's session middleware. You must implement `serializeUser` and `deserializeUser`, and configure session middleware before Passport:

```js
const session = require('express-session');

app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
}));

app.use(passport.initialize());
app.use(passport.session());

passport.serializeUser((user, done) => {
  done(null, user.id);
});

passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findById(id);
    done(null, user);
  } catch (err) {
    done(err);
  }
});
```

---

## 13. Nonce Support

To supply and verify a nonce to prevent a login session from being replayed, use the `verifyNonce` option when creating the strategy. This is documented in the `@nicokaiser/passport-apple` fork. [Unverified] Whether the main `passport-apple` package exposes an identical API is not confirmed in its README — check the current source code or open an issue to verify.

```js
// Example from @nicokaiser/passport-apple
// [Unverified] for the main passport-apple package
const generatedNonces = new NodeCache();

passport.use(new AppleStrategy({
  // ...other options
  verifyNonce: async (nonce) => {
    const stored = generatedNonces.get(nonce);
    if (!stored) throw new Error('Invalid nonce');
    generatedNonces.del(nonce);
  }
}, verifyCallback));
```

---

## 14. Related Packages and Forks

### 14.1 `@nicokaiser/passport-apple`

This was a fork of `passport-apple` created when `passport-apple` couldn't support fetching profile information. `passport-apple` now supports fetching profile information as well by using a simpler workaround instead of rewriting all of `passport-oauth2`.

Use `@nicokaiser/passport-apple` if you need nonce verification or prefer its more complete rewrite of the OAuth2 flow.

### 14.2 `apple-auth`

`apple-auth` is a standalone library for Sign in with Apple. It does not require Passport.js, whereas `passport-apple` is used with Passport.js.

### 14.3 `passport-appleid`

A separate npm package with a slightly different API and configuration structure. [Unverified] Its maintenance status and feature parity with `passport-apple` are not confirmed. Review its repository before choosing it.

### 14.4 NestJS Integration

For NestJS applications, `@arendajaelu/nestjs-passport-apple` integrates Apple login by leveraging Passport and its authentication framework, providing a typed `Profile` interface.

---

## 15. Common Pitfalls

**Not storing the user's name on first login.** Apple sends it exactly once. Miss it and you cannot retrieve it without the user revoking access.

**Using HTTP for callback URLs in production.** Apple rejects non-HTTPS return URLs.

**Treating `profile` as populated.** The `profile` parameter is required for the sake of Passport's implementation, but Apple hasn't implemented passing data in the access token yet — user data must be read from the decoded `idToken`.

**Not using the POST → GET redirect pattern.** Handling the callback as a raw POST loses the session cookie, breaking authentication.

**Reusing authorization codes.** Apple's codes are single-use. A second exchange attempt produces a `TokenError` with `invalid_grant`.

**Losing the `.p8` private key.** It cannot be re-downloaded. Losing it means revoking and regenerating the key, which breaks existing integrations until you redeploy with the new key.

---

## 16. Security Considerations

[Inference] These practices are not exhaustively specified in the `passport-apple` documentation but follow from general JWT and OAuth2 security guidance.

**Verify the idToken signature.** `jsonwebtoken.decode()` does not verify the signature. Verify it against Apple's public keys at `https://appleid.apple.com/auth/keys` using a JWK-capable library.

**Protect your `.p8` private key.** Never commit it to source control. Use environment variables or a secrets manager.

**Validate `aud`.** After decoding, confirm `aud` matches your `clientID`.

**Validate `iss`.** Confirm `iss` is `https://appleid.apple.com`.

**Validate `exp`.** Confirm the token has not expired before trusting it.

**Use HTTPS everywhere.** Apple requires it for callbacks; it also protects tokens and codes in transit.

---

## 17. Legal Disclaimer

This repository is NOT developed, endorsed by Apple Inc., or related to Apple Inc. in any way. This library was implemented solely by the community's hard work, based on information that is public on Apple Developer's website. The library merely acts as a helper tool for anyone trying to implement Apple's Sign in with Apple.

Apple's Sign in with Apple requirements, APIs, and token formats may change at any time. Always refer to [Apple's official documentation](https://developer.apple.com/documentation/sign_in_with_apple) alongside this guide.

---

_Guide compiled from: [github.com/ananay/passport-apple](https://github.com/ananay/passport-apple), [apple-auth SETUP.md](https://github.com/ananay/apple-auth/blob/master/SETUP.md), [npmjs.com/package/passport-apple](https://www.npmjs.com/package/passport-apple), and [@nicokaiser/passport-apple](https://www.npmjs.com/package/@nicokaiser/passport-apple)._
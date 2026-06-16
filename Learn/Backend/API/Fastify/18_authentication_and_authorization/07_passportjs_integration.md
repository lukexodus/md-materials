## Passport.js Integration

### Overview

`@fastify/passport` is the official Fastify adapter for [Passport.js](https://www.passportjs.org/), the widely-used Node.js authentication middleware. It ports Passport's strategy ecosystem — over 500 strategies covering local credentials, OAuth2 providers, SAML, LDAP, and more — into Fastify's hook and decorator system. It requires `@fastify/session` or `@fastify/secure-session` for session-based flows, and `@fastify/flash` for flash messages.

---

### Installation

bash

```bash
npm install @fastify/passport @fastify/session @fastify/cookie passport-local
```

Install additional strategy packages as needed:

bash

```bash
npm install passport-google-oauth20
npm install passport-github2
npm install passport-jwt
```

---

### Core Concepts

NoYesNoYesIncoming RequestSession DeserializationRoute hasauthenticate hook?Handler runs directlyPassport Strategy runsCredentialsvalid?401 / failureRedirectserializeUserSession updatedsuccessRedirect / next

**Key Points:**

- `serializeUser` — called after successful authentication to determine what to store in the session (typically a user ID).
- `deserializeUser` — called on every subsequent request to reconstruct the full user object from the session value.
- Each strategy encapsulates its own credential extraction and validation logic.
- `@fastify/passport` wraps Passport internals to be compatible with Fastify's `request`/`reply` rather than Express's `req`/`res`.

---

### Registration

js

```js
import Fastify from 'fastify'
import fastifyCookie from '@fastify/cookie'
import fastifySession from '@fastify/session'
import fastifyPassport from '@fastify/passport'
import { Strategy as LocalStrategy } from 'passport-local'

const fastify = Fastify({ logger: true })

// 1. Cookie support (required by session)
await fastify.register(fastifyCookie)

// 2. Session support (required by passport)
await fastify.register(fastifySession, {
  secret: process.env.SESSION_SECRET,
  cookie: { secure: process.env.NODE_ENV === 'production' }
})

// 3. Passport initialization — order matters
await fastify.register(fastifyPassport.initialize())
await fastify.register(fastifyPassport.secureSession())
```

**Key Points:**

- Registration order is strict: `cookie` → `session` → `passport.initialize()` → `passport.secureSession()`.
- `secureSession()` is the `@fastify/passport` equivalent of Express's `passport.session()` — it integrates with `@fastify/session` specifically.
- If using `@fastify/secure-session` instead of `@fastify/session`, use `passport.secureSession()` with the secure session plugin registered in its place.

---

### `serializeUser` and `deserializeUser`

js

```js
// What to store in the session
fastifyPassport.registerUserSerializer(async (user, request) => {
  return user.id  // only store the ID
})

// How to reconstruct the user from the session value
fastifyPassport.registerUserDeserializer(async (id, request) => {
  return await db.users.findById(id)  // fetch full user object
})
```

**Key Points:**

- `registerUserSerializer` and `registerUserDeserializer` replace Passport's `passport.serializeUser()` / `passport.deserializeUser()`.
- Deserializer runs on every authenticated request — keep it fast. Consider caching if DB load is a concern. [Inference]
- If `deserializeUser` returns `null` or `false`, the session is considered invalid and the user is treated as unauthenticated.

---

### Local Strategy — Username and Password

#### Strategy Definition

js

```js
fastifyPassport.use('local', new LocalStrategy(
  {
    usernameField: 'username',  // default
    passwordField: 'password'   // default
  },
  async function verify (username, password, done) {
    try {
      const user = await db.users.findOne({ username })
      if (!user) {
        return done(null, false, { message: 'Unknown user' })
      }

      const match = await bcrypt.compare(password, user.passwordHash)
      if (!match) {
        return done(null, false, { message: 'Incorrect password' })
      }

      return done(null, user)
    } catch (err) {
      return done(err)
    }
  }
))
```

**Key Points:**

- `done(null, user)` — success, proceeds to `serializeUser`.
- `done(null, false, { message })` — authentication failure, no error (wrong credentials).
- `done(err)` — unexpected error, triggers a 500.
- `usernameField` and `passwordField` can be customized to match your request body shape.

#### Login Route

js

```js
fastify.post(
  '/login',
  { preValidation: fastifyPassport.authenticate('local', { session: true }) },
  async (request, reply) => {
    // If we reach here, authentication succeeded
    return { user: request.user }
  }
)
```

#### Logout Route

js

```js
fastify.post('/logout', async (request, reply) => {
  await request.logout()
  return reply.redirect('/login')
})
```

**Key Points:**

- `request.logout()` is added by `@fastify/passport` — it clears the user from the session.
- `request.user` is populated on all authenticated requests via `deserializeUser`.
- `request.isAuthenticated()` and `request.isUnauthenticated()` are available for guard checks.

---

### Protecting Routes

#### Inline Guard

js

```js
fastify.get(
  '/dashboard',
  { preValidation: fastifyPassport.authenticate('local', { session: true }) },
  async (request, reply) => {
    return { welcome: request.user.username }
  }
)
```

#### Hook-Based Guard (Route Group)

js

```js
fastify.register(async function protectedScope (instance) {
  instance.addHook('preValidation', async (request, reply) => {
    if (!request.isAuthenticated()) {
      return reply.status(401).send({ error: 'Login required' })
    }
  })

  instance.get('/profile', async (request, reply) => {
    return request.user
  })

  instance.get('/settings', async (request, reply) => {
    return { settings: request.user.settings }
  })
})
```

---

### Google OAuth2 Strategy

bash

```bash
npm install passport-google-oauth20
```

js

```js
import { Strategy as GoogleStrategy } from 'passport-google-oauth20'

fastifyPassport.use('google', new GoogleStrategy(
  {
    clientID: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL: 'http://localhost:3000/auth/google/callback',
    scope: ['profile', 'email']
  },
  async function verify (accessToken, refreshToken, profile, done) {
    try {
      let user = await db.users.findOne({ googleId: profile.id })

      if (!user) {
        user = await db.users.create({
          googleId: profile.id,
          email: profile.emails[0].value,
          name: profile.displayName
        })
      }

      return done(null, user)
    } catch (err) {
      return done(err)
    }
  }
))

// Redirect to Google
fastify.get(
  '/auth/google',
  { preValidation: fastifyPassport.authenticate('google') },
  async () => {}
)

// Handle callback
fastify.get(
  '/auth/google/callback',
  {
    preValidation: fastifyPassport.authenticate('google', {
      failureRedirect: '/login',
      successRedirect: '/dashboard'
    })
  },
  async () => {}
)
```

---

### JWT Strategy — Stateless Auth

bash

```bash
npm install passport-jwt
```

js

```js
import { Strategy as JwtStrategy, ExtractJwt } from 'passport-jwt'

fastifyPassport.use('jwt', new JwtStrategy(
  {
    jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
    secretOrKey: process.env.JWT_SECRET
  },
  async function verify (jwtPayload, done) {
    try {
      const user = await db.users.findById(jwtPayload.sub)
      if (!user) return done(null, false)
      return done(null, user)
    } catch (err) {
      return done(err)
    }
  }
))

fastify.get(
  '/api/profile',
  { preValidation: fastifyPassport.authenticate('jwt', { session: false }) },
  async (request, reply) => {
    return request.user
  }
)
```

**Key Points:**

- `session: false` disables session serialization/deserialization — each request is validated independently via the token.
- `ExtractJwt` provides helpers: `fromAuthHeaderAsBearerToken()`, `fromBodyField('token')`, `fromUrlQueryParameter('token')`, and others.
- JWT strategy does not require `@fastify/session` when `session: false` is set.

---

### Composing Multiple Strategies

`@fastify/passport` can authenticate against multiple strategies in sequence using `@fastify/auth`:

bash

```bash
npm install @fastify/auth
```

js

```js
import fastifyAuth from '@fastify/auth'

await fastify.register(fastifyAuth)

fastify.get(
  '/api/data',
  {
    preValidation: fastify.auth([
      fastifyPassport.authenticate('jwt', { session: false }),
      fastifyPassport.authenticate('local', { session: true })
    ])
  },
  async (request, reply) => {
    return { user: request.user }
  }
)
```

**Key Points:**

- `@fastify/auth` tries each function in order and proceeds if any succeeds (OR logic by default).
- AND logic (all must pass) is also supported via options.
- This pattern supports hybrid APIs that accept both session cookies and Bearer tokens.

---

### Flash Messages

Flash messages pass one-time status messages across redirects (e.g., "Invalid password"). Requires `@fastify/flash`:

bash

```bash
npm install @fastify/flash
```

js

```js
import fastifyFlash from '@fastify/flash'

await fastify.register(fastifyFlash)

fastify.post(
  '/login',
  {
    preValidation: fastifyPassport.authenticate('local', {
      failureRedirect: '/login',
      failureFlash: true,       // stores strategy message in flash
      successRedirect: '/dashboard'
    })
  },
  async () => {}
)

fastify.get('/login', async (request, reply) => {
  const messages = request.flash('error')
  return reply.view('login.html', { error: messages[0] })
})
```

---

### Custom Callback — Full Control over Auth Response

Instead of using `successRedirect` / `failureRedirect`, handle the result manually:

js

```js
fastify.post('/login', async (request, reply) => {
  const user = await new Promise((resolve, reject) => {
    fastifyPassport.authenticate(
      'local',
      { session: false },
      async (request, reply, err, user, info) => {
        if (err) return reject(err)
        resolve(user || null)
      }
    )(request, reply)
  })

  if (!user) {
    return reply.status(401).send({ error: 'Invalid credentials' })
  }

  const token = fastify.jwt.sign({ sub: user.id })
  return { token }
})
```

**Key Points:**

- The custom callback form provides access to `info` (strategy-supplied message) and `err` separately.
- Useful when the authentication response must be JSON (API) rather than a redirect (web form).
- [Inference] Mixing redirect-based and callback-based patterns in the same app is common for apps serving both browser and API clients.

---

### Plugin Options Reference

| Option | Type | Description |
| --- | --- | --- |
| `session` | boolean | Enable/disable session persistence per authenticate call |
| `successRedirect` | string | Redirect URL on success |
| `failureRedirect` | string | Redirect URL on failure |
| `failureFlash` | boolean | string | Store failure message in flash |
| `successFlash` | boolean | string | Store success message in flash |
| `assignProperty` | string | Attach user to `request[property]` instead of `request.user` |
| `authInfo` | boolean | Pass `info` object to success handler (default: `true`) |

---

### Security Considerations

- Always use HTTPS — session cookies and Bearer tokens are credential-equivalent.
- Set `cookie.secure: true` on the session cookie in production.
- Use `httpOnly: true` on session cookies to reduce XSS exposure.
- The `deserializeUser` function runs on every request — validate that the returned user is still active (not deleted or suspended). [Inference]
- For JWT strategies, validate `exp`, `iss`, and `aud` claims — `passport-jwt` checks expiry by default but audience and issuer validation requires explicit configuration.
- Avoid storing sensitive data in the session beyond the minimum needed for deserialization (typically just a user ID).
- Rate-limit login routes to reduce brute-force risk.
- Invalidate sessions on password change or account compromise.

---

### Minimal Working Example — Local Strategy End to End

js

```js
import Fastify from 'fastify'
import fastifyCookie from '@fastify/cookie'
import fastifySession from '@fastify/session'
import fastifyPassport from '@fastify/passport'
import { Strategy as LocalStrategy } from 'passport-local'
import bcrypt from 'bcrypt'

const fastify = Fastify({ logger: true })

const users = [
  { id: 1, username: 'arya', passwordHash: await bcrypt.hash('direwolf', 10) }
]

await fastify.register(fastifyCookie)
await fastify.register(fastifySession, {
  secret: process.env.SESSION_SECRET ?? 'a-very-long-secret-at-least-32-chars',
  cookie: { secure: false }
})
await fastify.register(fastifyPassport.initialize())
await fastify.register(fastifyPassport.secureSession())

fastifyPassport.registerUserSerializer(async (user) => user.id)
fastifyPassport.registerUserDeserializer(async (id) => users.find(u => u.id === id) ?? false)

fastifyPassport.use('local', new LocalStrategy(async (username, password, done) => {
  const user = users.find(u => u.username === username)
  if (!user) return done(null, false)
  const match = await bcrypt.compare(password, user.passwordHash)
  return match ? done(null, user) : done(null, false)
}))

fastify.post(
  '/login',
  { preValidation: fastifyPassport.authenticate('local', { session: true }) },
  async (request) => ({ user: request.user.username })
)

fastify.get('/me', async (request, reply) => {
  if (!request.isAuthenticated()) return reply.status(401).send({ error: 'Not logged in' })
  return { user: request.user.username }
})

fastify.post('/logout', async (request, reply) => {
  await request.logout()
  return { status: 'logged out' }
})

await fastify.listen({ port: 3000 })
```

---

**Related Topics:**

- Composing auth strategies with `@fastify/auth`
- Session storage backends for `@fastify/session` (Redis, PostgreSQL)
- Replacing sessions with stateless JWT using `@fastify/jwt`
- SAML 2.0 authentication with `passport-saml`
- LDAP / Active Directory auth with `passport-ldapauth`
- Role-based access control (RBAC) after authentication
- `@fastify/secure-session` as a cookie-encrypted alternative to server-side sessions
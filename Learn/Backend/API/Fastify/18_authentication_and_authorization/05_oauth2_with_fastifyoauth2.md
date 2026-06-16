## OAuth2 with @fastify/oauth2

### Overview

`@fastify/oauth2` is the official Fastify plugin for integrating OAuth2 authorization flows. It wraps the `simple-oauth2` library and adds Fastify-native route generation, token management helpers, and a lifecycle hook system. It supports the **Authorization Code** flow (the most common for web apps), and can be adapted for other grant types. Popular providers — Google, GitHub, Facebook, Spotify, and others — have built-in presets.

---

### Installation

bash

```bash
npm install @fastify/oauth2
```

---

### How OAuth2 Authorization Code Flow Works

OAuth2 ProviderFastify AppUserOAuth2 ProviderFastify AppUserGET /auth/googleRedirect to Provider (with client_id, scope, state)Logs in and grants permissionGET /auth/google/callback?code=AUTH_CODE&state=STATEPOST /token (exchange code for tokens){ access_token, refresh_token, expires_in }Session/cookie set, redirect to app

**Key Points:**

- The `state` parameter is a CSRF token generated per request — `@fastify/oauth2` handles this automatically.
- The authorization code is short-lived and single-use.
- Access tokens expire; refresh tokens (when issued) allow obtaining new access tokens without re-prompting the user.

---

### Basic Registration — Google Example

js

```js
import Fastify from 'fastify'
import oauthPlugin from '@fastify/oauth2'

const fastify = Fastify({ logger: true })

await fastify.register(oauthPlugin, {
  name: 'googleOAuth2',
  scope: ['profile', 'email'],
  credentials: {
    client: {
      id: process.env.GOOGLE_CLIENT_ID,
      secret: process.env.GOOGLE_CLIENT_SECRET
    },
    auth: oauthPlugin.GOOGLE_CONFIGURATION
  },
  startRedirectPath: '/auth/google',
  callbackUri: 'http://localhost:3000/auth/google/callback'
})
```

**Key Points:**

- `name` — the key under which the OAuth2 client is decorated onto the `fastify` instance (e.g., `fastify.googleOAuth2`).
- `startRedirectPath` — `@fastify/oauth2` automatically registers a GET route at this path that redirects the user to the provider.
- `callbackUri` — must exactly match the redirect URI registered in your OAuth2 provider's developer console.
- `credentials.auth` — can use a built-in preset (see below) or a fully custom configuration object.

---

### Built-in Provider Presets

`@fastify/oauth2` ships with preset `auth` configurations for common providers:

| Preset Constant | Provider |
| --- | --- |
| `oauthPlugin.GOOGLE_CONFIGURATION` | Google |
| `oauthPlugin.GITHUB_CONFIGURATION` | GitHub |
| `oauthPlugin.FACEBOOK_CONFIGURATION` | Facebook |
| `oauthPlugin.SPOTIFY_CONFIGURATION` | Spotify |
| `oauthPlugin.APPLE_CONFIGURATION` | Apple |
| `oauthPlugin.TWITTER_CONFIGURATION` | Twitter/X |
| `oauthPlugin.LINKEDIN_CONFIGURATION` | LinkedIn |
| `oauthPlugin.MICROSOFT_CONFIGURATION` | Microsoft |
| `oauthPlugin.VKONTAKTE_CONFIGURATION` | VKontakte |
| `oauthPlugin.DISCORD_CONFIGURATION` | Discord |

For providers not listed, supply a custom `auth` object:

js

```js
auth: {
  authorizeHost: 'https://provider.example.com',
  authorizePath: '/oauth/authorize',
  tokenHost: 'https://provider.example.com',
  tokenPath: '/oauth/token'
}
```

---

### Handling the Callback

After the provider redirects back, exchange the authorization code for tokens in a route you define manually:

js

```js
fastify.get('/auth/google/callback', async (request, reply) => {
  const token = await fastify.googleOAuth2.getAccessTokenFromAuthorizationCodeFlow(request)

  // token.token contains: access_token, token_type, expires_in, refresh_token (if issued)
  const accessToken = token.token.access_token

  // Fetch user info from provider
  const userInfo = await fetch('https://www.googleapis.com/oauth2/v2/userinfo', {
    headers: { Authorization: `Bearer ${accessToken}` }
  }).then(r => r.json())

  // Store session, set cookie, etc.
  reply.setCookie('session', JSON.stringify(userInfo), {
    httpOnly: true,
    path: '/'
  })

  return reply.redirect('/')
})
```

**Key Points:**

- `getAccessTokenFromAuthorizationCodeFlow(request)` validates the `state` parameter automatically, defending against CSRF.
- The returned `token` object is a `simple-oauth2` `AccessToken` instance with helper methods.
- Behavior of `refresh_token` issuance varies by provider and scope — not all providers return one by default. [Inference]

---

### Token Object Structure

js

```js
{
  token: {
    access_token: 'ACCESS_TOKEN_STRING',
    token_type: 'Bearer',
    expires_in: 3599,
    refresh_token: 'REFRESH_TOKEN_STRING', // if issued
    scope: 'profile email',
    expiry_date: '2026-06-08T...'
  }
}
```

The `AccessToken` instance also exposes:

js

```js
token.expired()          // boolean — true if access token is expired
token.refresh()          // requests a new access token using the refresh token
token.revoke('access')   // revokes the access token
token.revoke('refresh')  // revokes the refresh token
```

---

### Refreshing Access Tokens

js

```js
fastify.get('/refresh', async (request, reply) => {
  // Retrieve the stored token object (e.g., from session or DB)
  const existingToken = fastify.googleOAuth2.createToken(storedTokenObject)

  if (existingToken.expired()) {
    try {
      const refreshed = await existingToken.refresh()
      // Persist refreshed.token to your session/DB
      return { access_token: refreshed.token.access_token }
    } catch (err) {
      return reply.status(401).send({ error: 'Could not refresh token' })
    }
  }

  return { access_token: existingToken.token.access_token }
})
```

**Key Points:**

- `fastify.googleOAuth2.createToken(raw)` reconstructs a `simple-oauth2` `AccessToken` instance from a plain stored object.
- Token refresh only works if a `refresh_token` was issued and has not been revoked.
- Refresh tokens may themselves expire depending on the provider. [Inference]

---

### Revoking Tokens

js

```js
fastify.post('/logout', async (request, reply) => {
  const storedToken = fastify.googleOAuth2.createToken(retrieveTokenFromSession(request))

  try {
    await storedToken.revoke('access_token')
    await storedToken.revoke('refresh_token')
  } catch (err) {
    fastify.log.warn('Token revocation failed', err)
    // Not all providers support revocation — proceed with local logout regardless
  }

  reply.clearCookie('session', { path: '/' })
  return reply.redirect('/login')
})
```

[Inference] Not all OAuth2 providers expose a revocation endpoint. In those cases, `revoke()` may throw — local session invalidation should proceed regardless.

---

### Registering Multiple Providers

Each provider registration must use a distinct `name` and distinct routes:

js

```js
await fastify.register(oauthPlugin, {
  name: 'googleOAuth2',
  credentials: {
    client: { id: process.env.GOOGLE_CLIENT_ID, secret: process.env.GOOGLE_CLIENT_SECRET },
    auth: oauthPlugin.GOOGLE_CONFIGURATION
  },
  scope: ['profile', 'email'],
  startRedirectPath: '/auth/google',
  callbackUri: 'http://localhost:3000/auth/google/callback'
})

await fastify.register(oauthPlugin, {
  name: 'githubOAuth2',
  credentials: {
    client: { id: process.env.GITHUB_CLIENT_ID, secret: process.env.GITHUB_CLIENT_SECRET },
    auth: oauthPlugin.GITHUB_CONFIGURATION
  },
  scope: ['user:email'],
  startRedirectPath: '/auth/github',
  callbackUri: 'http://localhost:3000/auth/github/callback'
})
```

Each registration decorates `fastify` with its own named client: `fastify.googleOAuth2`, `fastify.githubOAuth2`.

---

### State and CSRF Protection

`@fastify/oauth2` generates and validates a `state` parameter automatically. By default, state is stored in a cookie. You can customize this behavior:

js

```js
await fastify.register(oauthPlugin, {
  // ...
  generateStateFunction: (request) => {
    // Return a custom state string
    return crypto.randomUUID()
  },
  checkStateFunction: (request, callback) => {
    // Validate the returned state against what was stored
    if (request.query.state === request.cookies.oauth_state) {
      callback()
    } else {
      callback(new Error('Invalid state'))
    }
  }
})
```

**Key Points:**

- The default state mechanism uses a signed cookie, which requires `@fastify/cookie` to be registered first.
- Custom `generateStateFunction` / `checkStateFunction` pairs are useful when storing state server-side (e.g., in a session store or Redis).

---

### `callbackUriParams` — Requesting Offline Access

Some providers require additional parameters on the authorization redirect to issue a refresh token:

js

```js
await fastify.register(oauthPlugin, {
  name: 'googleOAuth2',
  credentials: {
    client: { id: process.env.GOOGLE_CLIENT_ID, secret: process.env.GOOGLE_CLIENT_SECRET },
    auth: oauthPlugin.GOOGLE_CONFIGURATION
  },
  scope: ['profile', 'email'],
  startRedirectPath: '/auth/google',
  callbackUri: 'http://localhost:3000/auth/google/callback',
  callbackUriParams: {
    access_type: 'offline',   // Google-specific: requests refresh token
    prompt: 'consent'         // Forces consent screen — required for refresh token re-issuance
  }
})
```

[Inference] `prompt: 'consent'` is typically needed on Google when a user has already authorized the app and you need a fresh refresh token — behavior may vary across accounts and prior authorization state.

---

### pkce Support

`@fastify/oauth2` supports **PKCE** (Proof Key for Code Exchange), which is recommended for public clients and adds a code challenge to the authorization request:

js

```js
await fastify.register(oauthPlugin, {
  name: 'githubOAuth2',
  credentials: {
    client: { id: process.env.GITHUB_CLIENT_ID, secret: process.env.GITHUB_CLIENT_SECRET },
    auth: oauthPlugin.GITHUB_CONFIGURATION
  },
  scope: ['user:email'],
  startRedirectPath: '/auth/github',
  callbackUri: 'http://localhost:3000/auth/github/callback',
  pkce: 'S256'  // SHA-256 code challenge method
})
```

**Key Points:**

- PKCE prevents authorization code interception attacks.
- `'S256'` (SHA-256) is the recommended method; `'plain'` is available but discouraged.
- Not all providers support PKCE — check your provider's documentation. [Unverified for all providers]

---

### Token Storage Strategies

`@fastify/oauth2` does not manage token persistence — that responsibility belongs to the application. Common patterns:

#### Encrypted Cookie (stateless)

js

```js
// Use @fastify/secure-session or encrypt manually
reply.setCookie('oauth_token', encrypt(token.token), {
  httpOnly: true,
  secure: true,
  sameSite: 'Lax',
  path: '/'
})
```

#### Server-Side Session

js

```js
// With @fastify/session
request.session.set('oauth_token', token.token)
```

#### Database

js

```js
await db.upsert('user_tokens', {
  userId: userInfo.id,
  accessToken: token.token.access_token,
  refreshToken: token.token.refresh_token,
  expiresAt: token.token.expiry_date
})
```

**Key Points:**

- Storing access tokens in plain cookies exposes them to theft if HTTPS is not enforced.
- Refresh tokens are long-lived and high-value — prefer server-side storage for them.
- Database storage enables token revocation tracking and multi-device session management.

---

### Full Working Example — GitHub OAuth2

js

```js
import Fastify from 'fastify'
import cookie from '@fastify/cookie'
import oauthPlugin from '@fastify/oauth2'

const fastify = Fastify({ logger: true })

await fastify.register(cookie, {
  secret: process.env.COOKIE_SECRET
})

await fastify.register(oauthPlugin, {
  name: 'githubOAuth2',
  credentials: {
    client: {
      id: process.env.GITHUB_CLIENT_ID,
      secret: process.env.GITHUB_CLIENT_SECRET
    },
    auth: oauthPlugin.GITHUB_CONFIGURATION
  },
  scope: ['user:email'],
  startRedirectPath: '/auth/github',
  callbackUri: 'http://localhost:3000/auth/github/callback'
})

fastify.get('/auth/github/callback', async (request, reply) => {
  const token = await fastify.githubOAuth2.getAccessTokenFromAuthorizationCodeFlow(request)

  const userInfo = await fetch('https://api.github.com/user', {
    headers: {
      Authorization: `Bearer ${token.token.access_token}`,
      Accept: 'application/vnd.github+json'
    }
  }).then(r => r.json())

  reply.setCookie('user', JSON.stringify({ login: userInfo.login, id: userInfo.id }), {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'Lax',
    path: '/',
    maxAge: 86400
  })

  return reply.redirect('/profile')
})

fastify.get('/profile', async (request, reply) => {
  const raw = request.cookies.user
  if (!raw) return reply.status(401).send({ error: 'Not authenticated' })
  return JSON.parse(raw)
})

await fastify.listen({ port: 3000 })
```

---

### Security Considerations

- Always use `state` validation — do not disable the built-in CSRF check. Custom `checkStateFunction` implementations must be equally rigorous.
- Use PKCE when the provider supports it, especially in environments where the authorization code could be intercepted.
- Never log access or refresh tokens — treat them as credentials.
- Set `secure: true` on any cookie carrying token data in production.
- Refresh tokens should be stored server-side when possible; avoid exposing them to the browser.
- Validate tokens from providers before trusting the user identity they represent — token introspection or userinfo endpoint verification adds a layer of assurance.
- Rotate `COOKIE_SECRET` and client secrets periodically. [Inference] Secret leaks via environment variable exposure are a common production incident vector.

---

**Related Topics:**

- Combining OAuth2 with `@fastify/jwt` for stateless session management
- OAuth2 + `@fastify/session` for server-side session storage
- OpenID Connect (OIDC) on top of OAuth2 — `id_token` validation
- Role mapping from provider claims (Google groups, GitHub orgs)
- OAuth2 token introspection endpoints
- Implementing OAuth2 as a **server** (authorization server) with Fastify
- `@fastify/passport` for strategy-based multi-provider auth
# Comprehensive Guide to the `cors` 

The `cors` package is a Node.js middleware that adds Cross-Origin Resource Sharing headers to HTTP responses. It is compatible with Express, Connect, and any framework that follows the Connect middleware signature.

---

## What Is CORS

CORS (Cross-Origin Resource Sharing) is a browser security mechanism. When a web page at one origin (scheme + host + port) makes a request to a different origin, the browser enforces rules about whether that request is allowed. The server communicates its policy by including specific HTTP headers in its responses. Without those headers, the browser blocks the response from being read by the requesting script.

The `cors` library handles the work of generating those headers so you do not have to set them manually on every response.

---

## Installation

```bash
npm install cors
```

For TypeScript projects, type definitions are available separately:

```bash
npm install --save-dev @types/cors
```

---

## Basic Usage

### With Express

```js
const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());

app.get('/data', (req, res) => {
  res.json({ message: 'This response has CORS headers.' });
});

app.listen(3000);
```

Calling `cors()` with no arguments applies a permissive default configuration. See the Configuration section for what that means exactly.

### With Plain Node.js `http`

```js
const http = require('http');
const cors = require('cors');

const corsMiddleware = cors();

const server = http.createServer((req, res) => {
  corsMiddleware(req, res, () => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ message: 'OK' }));
  });
});

server.listen(3000);
```

---

## Default Behavior

When called with no options, `cors()` produces the following headers:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET,HEAD,PUT,PATCH,POST,DELETE
```

No `Access-Control-Allow-Credentials` header is set by default. No `Access-Control-Allow-Headers` is set by default on simple requests; on preflight requests, the library reflects whatever the client sends in `Access-Control-Request-Headers`.

---

## Configuration

`cors()` accepts an options object or a function. All fields are optional.

### `origin`

Controls the `Access-Control-Allow-Origin` header.

|Value type|Behavior|
|---|---|
|`"*"` (default)|Allows any origin|
|`"https://example.com"`|Allows only that exact origin|
|`/\.example\.com$/`|Allows any origin matching the regex|
|`["https://a.com", "https://b.com"]`|Allows any origin in the array|
|`false`|Disables CORS entirely (no header set)|
|`function`|Called per-request; see Dynamic Origin below|

```js
app.use(cors({
  origin: 'https://myapp.com'
}));
```

### `methods`

Controls the `Access-Control-Allow-Methods` header. Accepts a string or array.

```js
app.use(cors({
  methods: ['GET', 'POST']
}));
```

### `allowedHeaders`

Controls `Access-Control-Allow-Headers`. If omitted, the library reflects the client's `Access-Control-Request-Headers` value on preflight requests.

```js
app.use(cors({
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

### `exposedHeaders`

Controls `Access-Control-Expose-Headers`. Lists headers the browser is allowed to read from the response beyond the default safe headers.

```js
app.use(cors({
  exposedHeaders: ['X-Custom-Header', 'X-Request-Id']
}));
```

### `credentials`

Sets `Access-Control-Allow-Credentials: true`. Required if the client sends cookies or HTTP authentication with cross-origin requests. **Cannot be combined with `origin: "*"`**; a specific origin must be set.

```js
app.use(cors({
  origin: 'https://myapp.com',
  credentials: true
}));
```

### `maxAge`

Sets `Access-Control-Max-Age`, which tells the browser how many seconds it may cache the preflight response.

```js
app.use(cors({
  maxAge: 600  // 10 minutes
}));
```

### `preflightContinue`

When `true`, the library passes preflight `OPTIONS` requests down to the next middleware instead of responding to them itself. Defaults to `false`.

### `optionsSuccessStatus`

The HTTP status code sent for successful OPTIONS preflight responses. Defaults to `204`. Some browsers (notably older Internet Explorer versions) handle `204` poorly; `200` is an alternative.

```js
app.use(cors({
  optionsSuccessStatus: 200
}));
```

---

## Dynamic Origin

When the allowed origin depends on the request (for example, reading a list of allowed origins from a database), pass a function to `origin`.

```js
const allowedOrigins = ['https://app1.com', 'https://app2.com'];

app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (e.g., curl, server-to-server)
    if (!origin) return callback(null, true);

    if (allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Origin not allowed by CORS policy'));
    }
  }
}));
```

The callback signature is `callback(error, allow)`. Pass `null` as the first argument on success, and an `Error` instance to reject.

---

## Route-Level CORS

Apply CORS to specific routes rather than globally.

```js
const cors = require('cors');

// Only this route is cross-origin accessible
app.get('/public', cors(), (req, res) => {
  res.json({ public: true });
});

// This route is not
app.get('/private', (req, res) => {
  res.json({ private: true });
});
```

You can also pass different option objects to different routes:

```js
const publicCors = cors({ origin: '*' });
const restrictedCors = cors({ origin: 'https://dashboard.example.com', credentials: true });

app.get('/feed', publicCors, feedHandler);
app.get('/account', restrictedCors, accountHandler);
```

---

## Handling Preflight Requests

Browsers send an `OPTIONS` preflight request before certain cross-origin requests (those using non-simple methods or custom headers). The `cors` middleware responds to these automatically when `preflightContinue` is `false` (the default).

If you are applying CORS at the route level rather than globally, you need to also handle `OPTIONS` on the same path:

```js
app.options('/api/data', cors(options));  // preflight
app.post('/api/data', cors(options), handler);  // actual request
```

To handle all preflight requests globally with one statement:

```js
app.options('*', cors(options));
```

---

## Using an Async Origin Function

The origin function supports asynchronous operations via the callback.

```js
const { getAllowedOrigins } = require('./db');

app.use(cors({
  origin: async function (origin, callback) {
    try {
      const origins = await getAllowedOrigins();
      if (!origin || origins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed'));
      }
    } catch (err) {
      callback(err);
    }
  }
}));
```

---

## Configuration with a Function (Per-Request Options)

Instead of a static options object, you can pass a function that receives the request and a callback. This lets you vary any option, not just `origin`.

```js
app.use(cors(function (req, callback) {
  const options = {
    origin: req.headers['x-requested-with'] === 'XMLHttpRequest'
      ? false
      : 'https://trusted.com',
    methods: ['GET', 'POST'],
    credentials: true
  };
  callback(null, options);
}));
```

---

## TypeScript Usage

```ts
import express from 'express';
import cors, { CorsOptions } from 'cors';

const app = express();

const corsOptions: CorsOptions = {
  origin: ['https://app.example.com'],
  methods: ['GET', 'POST', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 300
};

app.use(cors(corsOptions));
```

---

## Common Mistakes and How to Avoid Them

### Combining `credentials: true` with `origin: "*"`

This combination is invalid per the CORS specification and browsers will reject it. Always specify an explicit origin when credentials are enabled.

```js
// Incorrect
cors({ credentials: true, origin: '*' });

// Correct
cors({ credentials: true, origin: 'https://yourapp.com' });
```

### Not Handling Preflight on Route-Level Middleware

If you apply `cors()` only to `app.post(...)` but not to `app.options(...)`, preflight requests for that route will not receive CORS headers and browsers will block the subsequent POST.

### Forgetting That `origin: false` Disables CORS Entirely

Setting `origin: false` removes the `Access-Control-Allow-Origin` header entirely. It does not set it to `false` as a string.

### Expecting CORS to Block Server-Side Requests

CORS headers are enforced by browsers, not servers. Non-browser clients (curl, Postman, server-to-server HTTP) ignore CORS headers. CORS is not a server access control mechanism.

---

## Headers Reference

|Header|Direction|Set by option|
|---|---|---|
|`Access-Control-Allow-Origin`|Response|`origin`|
|`Access-Control-Allow-Methods`|Response (preflight)|`methods`|
|`Access-Control-Allow-Headers`|Response (preflight)|`allowedHeaders`|
|`Access-Control-Expose-Headers`|Response|`exposedHeaders`|
|`Access-Control-Allow-Credentials`|Response|`credentials`|
|`Access-Control-Max-Age`|Response (preflight)|`maxAge`|
|`Vary`|Response|Set automatically when origin is not `*`|

The `Vary: Origin` header is set automatically when the origin option is not the static string `"*"`. This is important for correct caching behavior when different responses are served to different origins.

---

## Debugging

If CORS headers are not appearing as expected:

1. Check whether the middleware is registered before your route handlers. Middleware order matters in Express.
2. Confirm the `OPTIONS` method is handled if you are using route-level CORS.
3. Inspect the raw response headers with `curl -I -X OPTIONS http://localhost:3000/route -H "Origin: https://yourapp.com"`.
4. Verify that the `origin` option matches exactly what the browser sends. The `Origin` header includes the scheme and port; `https://example.com` and `http://example.com` are different origins.

---

## Source and Further Reading

- npm package: `cors` by Troy Goode and contributors
- Repository: https://github.com/expressjs/cors
- MDN CORS documentation: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
- Fetch specification (defines CORS behavior): https://fetch.spec.whatwg.org
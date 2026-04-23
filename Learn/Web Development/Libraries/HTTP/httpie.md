# Comprehensive Guide to HTTPie for Node.js (`httpie`)

`httpie` is a lightweight, zero-dependency HTTP client for Node.js. It wraps the built-in `http` and `https` modules with a minimal Promise-based API. It is not the Python CLI tool of the same name; this is a separate package published to npm.

---

## What It Is and What It Is Not

`httpie` occupies a specific niche: it is smaller and simpler than `axios` or `got`, has no dependencies, and is oriented toward server-side Node.js code where bundle size does not matter but simplicity does. It does not run in browsers. It does not support request cancellation, interceptors, retry logic, or streaming out of the box. If you need those features, a more fully-featured client is likely a better fit.

---

## Installation

```bash
npm install httpie
```

No transitive dependencies are installed.

---

## Basic Usage

All methods return a Promise that resolves with a response object or rejects with an error object that includes the response details.

```js
const { get, post, put, patch, del, send } = require('httpie');
```

Or with ES modules:

```js
import { get, post, put, patch, del, send } from 'httpie';
```

---

## Methods

`httpie` exports one function per HTTP method, plus a generic `send`.

### `get(url, options?)`

```js
const { statusCode, data, headers } = await get('https://api.example.com/users');
console.log(data); // parsed JSON if Content-Type is application/json
```

### `post(url, options?)`

```js
const { statusCode, data } = await post('https://api.example.com/users', {
  body: { name: 'Alice', role: 'admin' }
});
```

### `put(url, options?)`

```js
await put('https://api.example.com/users/1', {
  body: { name: 'Alice Updated' }
});
```

### `patch(url, options?)`

```js
await patch('https://api.example.com/users/1', {
  body: { role: 'editor' }
});
```

### `del(url, options?)`

Named `del` rather than `delete` because `delete` is a reserved word in JavaScript.

```js
await del('https://api.example.com/users/1');
```

### `send(method, url, options?)`

The underlying function all named methods call. Use it for HTTP methods not covered by the named exports (such as `HEAD`, `OPTIONS`, or custom methods).

```js
const { statusCode, headers } = await send('HEAD', 'https://api.example.com/users');
```

---

## Response Object

Every resolved Promise returns an object with these fields:

`statusCode` — the HTTP status code as a number.

`headers` — an object of response headers, lowercased.

`data` — the response body. If the response `Content-Type` is `application/json`, `httpie` parses it automatically and `data` is a JavaScript object. Otherwise `data` is a string.

```js
const res = await get('https://api.example.com/users/1');

console.log(res.statusCode); // 200
console.log(res.headers['content-type']); // 'application/json; charset=utf-8'
console.log(res.data); // { id: 1, name: 'Alice' }
```

---

## Options

All named methods and `send` accept an optional options object as the last argument.

### `body`

The request body. Accepts an object, string, or Buffer.

When `body` is a plain object, `httpie` serializes it to JSON and sets `Content-Type: application/json` automatically.

When `body` is a string, it is sent as-is. Set `Content-Type` manually via `headers` if needed.

```js
// Object body — auto-serialized to JSON
await post('https://api.example.com/items', {
  body: { title: 'Hello', done: false }
});

// String body
await post('https://api.example.com/raw', {
  body: 'plain text content',
  headers: { 'Content-Type': 'text/plain' }
});
```

### `headers`

An object of request headers. Keys and values are strings.

```js
await get('https://api.example.com/protected', {
  headers: {
    'Authorization': 'Bearer eyJhbGc...',
    'Accept': 'application/json'
  }
});
```

### `timeout`

Request timeout in milliseconds. If the request does not complete within this time, the Promise rejects.

```js
await get('https://api.example.com/slow', {
  timeout: 5000
});
```

### `reviver`

A JSON reviver function, passed directly to `JSON.parse` when the response body is parsed.

```js
await get('https://api.example.com/data', {
  reviver: (key, value) => {
    if (key === 'createdAt') return new Date(value);
    return value;
  }
});
```

### Full Options Example

```js
const { statusCode, data } = await post('https://api.example.com/orders', {
  body: { product: 'widget', quantity: 3 },
  headers: {
    'Authorization': 'Bearer token123',
    'X-Request-Id': 'abc-456'
  },
  timeout: 10000
});
```

---

## Error Handling

When the server returns a non-2xx status code, `httpie` rejects the Promise. The rejection value is an `Error` object with additional properties attached.

```js
try {
  await get('https://api.example.com/missing');
} catch (err) {
  console.log(err.statusCode); // e.g. 404
  console.log(err.headers);   // response headers
  console.log(err.data);      // parsed response body, if any
  console.log(err.message);   // e.g. 'Not Found'
}
```

This means you must use `try/catch` (or `.catch()`) for both network failures and HTTP error responses — both surface as rejected Promises.

### Distinguishing Network Errors from HTTP Errors

```js
try {
  await get('https://api.example.com/data');
} catch (err) {
  if (err.statusCode) {
    // HTTP error — server responded with non-2xx
    console.error(`HTTP ${err.statusCode}:`, err.data);
  } else {
    // Network error — no response received
    console.error('Network failure:', err.message);
  }
}
```

---

## HTTPS

`httpie` uses the built-in `https` module for URLs starting with `https://`. No additional configuration is needed for standard TLS connections.

For self-signed certificates in development environments, you can pass Node.js `https` module options via the options object. [Unverified] — the library passes unrecognized options to the underlying Node.js request options object, so fields like `rejectUnauthorized` may work, but this is not documented as a supported feature and behavior is not guaranteed.

A safer approach for development is to set the environment variable:

```bash
NODE_TLS_REJECT_UNAUTHORIZED=0 node server.js
```

Do not do this in production.

---

## URL Handling

Pass URLs as strings. `httpie` accepts both `http://` and `https://` schemes. Query parameters are not handled by the library; append them to the URL string directly.

```js
const userId = 42;
const status = 'active';

const { data } = await get(`https://api.example.com/users/${userId}?status=${status}`);
```

For URL construction with proper encoding, use the built-in `URL` class:

```js
const url = new URL('https://api.example.com/users');
url.searchParams.set('status', 'active');
url.searchParams.set('page', '2');

const { data } = await get(url.toString());
```

---

## Common Patterns

### Authenticated Requests with a Shared Header

```js
const { get, post } = require('httpie');

const BASE_URL = 'https://api.example.com';
const AUTH_HEADER = { Authorization: `Bearer ${process.env.API_TOKEN}` };

async function apiGet(path) {
  return get(`${BASE_URL}${path}`, { headers: AUTH_HEADER });
}

async function apiPost(path, body) {
  return post(`${BASE_URL}${path}`, { body, headers: AUTH_HEADER });
}
```

### Wrapping with Retry Logic

`httpie` has no built-in retry. Implement it manually:

```js
async function getWithRetry(url, options = {}, retries = 3) {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      return await get(url, options);
    } catch (err) {
      const isLast = attempt === retries;
      const isRetryable = !err.statusCode || err.statusCode >= 500;

      if (isLast || !isRetryable) throw err;

      const delay = attempt * 500;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

### Sending Form-Encoded Data

`httpie` does not handle `application/x-www-form-urlencoded` automatically. Serialize manually:

```js
const body = new URLSearchParams({ username: 'alice', password: 'secret' }).toString();

await post('https://example.com/login', {
  body,
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
});
```

### Parallel Requests

```js
const [users, products] = await Promise.all([
  get('https://api.example.com/users'),
  get('https://api.example.com/products')
]);

console.log(users.data, products.data);
```

---

## TypeScript Usage

`httpie` does not bundle its own type definitions. Install community types if available, or write a local declaration:

```ts
// httpie.d.ts (minimal local declaration if @types/httpie is unavailable)
declare module 'httpie' {
  interface Options {
    body?: object | string | Buffer;
    headers?: Record<string, string>;
    timeout?: number;
    reviver?: (key: string, value: unknown) => unknown;
  }

  interface Response<T = unknown> {
    statusCode: number;
    headers: Record<string, string>;
    data: T;
  }

  function get<T = unknown>(url: string, options?: Options): Promise<Response<T>>;
  function post<T = unknown>(url: string, options?: Options): Promise<Response<T>>;
  function put<T = unknown>(url: string, options?: Options): Promise<Response<T>>;
  function patch<T = unknown>(url: string, options?: Options): Promise<Response<T>>;
  function del<T = unknown>(url: string, options?: Options): Promise<Response<T>>;
  function send<T = unknown>(method: string, url: string, options?: Options): Promise<Response<T>>;
}
```

[Unverified] — community type definitions may exist under `@types/httpie`. Verify on npmjs.com before writing your own.

---

## Comparison with Alternatives

|Feature|`httpie`|`axios`|`got`|`node-fetch`|
|---|---|---|---|---|
|Dependencies|0|Several|Several|0 (v3+)|
|Bundle size|Tiny|Medium|Medium|Small|
|Browser support|No|Yes|No|Yes|
|Interceptors|No|Yes|Yes (hooks)|No|
|Retry built-in|No|No|Yes|No|
|Streaming|No|Yes|Yes|Yes|
|Auto JSON parse|Yes|Yes|Yes|Manual|
|Request cancellation|No|Yes|Yes|Yes|
|TypeScript bundled|No|Yes|Yes|Yes|

`httpie` is well-suited for simple server-to-server HTTP calls where you want no dependencies and do not need advanced features.

---

## Limitations

- No streaming support. The entire response body is buffered before the Promise resolves.
- No request cancellation via `AbortController` or similar.
- No built-in retry, timeout backoff, or circuit breaking.
- No cookie jar or automatic redirect handling beyond what Node.js does natively.
- No multipart/form-data support. Use a dedicated library for file uploads.
- No proxy support documented in the official API.
- Does not run in browsers.

---

## Further Reading

- npm package: `httpie` by Luke Edwards
- Repository: https://github.com/lukeed/httpie
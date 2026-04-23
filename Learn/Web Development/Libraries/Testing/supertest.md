# Supertest: Comprehensive Guide

Supertest is a Node.js library for testing HTTP servers. It builds on top of [superagent](https://github.com/visionmedia/superagent) and provides a high-level API for making HTTP assertions against a Node.js HTTP server — without needing a running server bound to a port.

---

## Installation

```bash
npm install --save-dev supertest
```

If you are using TypeScript, also install the types:

```bash
npm install --save-dev @types/supertest
```

Supertest requires Node.js and an HTTP server — typically created with `http.createServer()`, Express, Koa, Fastify, or similar frameworks.

---

## Core Concept

Supertest wraps a Node.js HTTP server (or an app that exposes a `listen`-compatible interface) and lets you fire HTTP requests against it programmatically. It handles starting and closing the server internally, so you do not need to manually call `server.listen()` in most cases.

```
supertest(app)
  .get('/path')
  .expect(200)
  .then(response => { ... })
```

Supertest returns a **thenable** object — it is compatible with both callbacks and promises.

---

## Basic Setup

### CommonJS

```js
const request = require('supertest');
const app = require('./app'); // your Express/Koa/http app
```

### ES Modules

```js
import request from 'supertest';
import app from './app.js';
```

### TypeScript

```ts
import request from 'supertest';
import app from './app';
```

---

## Making Requests

Supertest supports all standard HTTP methods.

### GET

```js
const response = await request(app).get('/users');
```

### POST

```js
const response = await request(app)
  .post('/users')
  .send({ name: 'Alice', email: 'alice@example.com' });
```

### PUT

```js
const response = await request(app)
  .put('/users/1')
  .send({ name: 'Alice Updated' });
```

### PATCH

```js
const response = await request(app)
  .patch('/users/1')
  .send({ name: 'Patched Name' });
```

### DELETE

```js
const response = await request(app).delete('/users/1');
```

### HEAD

```js
const response = await request(app).head('/users');
```

### OPTIONS

```js
const response = await request(app).options('/users');
```

---

## Assertions

Assertions are chained using `.expect()`. Multiple `.expect()` calls can be chained on a single request.

### Status Code

```js
await request(app)
  .get('/users')
  .expect(200);
```

### Response Header

```js
await request(app)
  .get('/users')
  .expect('Content-Type', /json/);
```

The second argument can be an exact string or a regular expression.

### Response Body (exact match)

```js
await request(app)
  .get('/users/1')
  .expect({ id: 1, name: 'Alice' });
```

### Response Body (custom function)

```js
await request(app)
  .get('/users')
  .expect((res) => {
    if (!Array.isArray(res.body)) {
      throw new Error('Expected an array');
    }
    if (res.body.length === 0) {
      throw new Error('Expected at least one user');
    }
  });
```

The function receives the `res` object. Throwing inside it causes the assertion to fail.

### Chaining Multiple Assertions

```js
await request(app)
  .get('/users/1')
  .expect(200)
  .expect('Content-Type', /json/)
  .expect((res) => {
    if (res.body.id !== 1) throw new Error('Wrong user');
  });
```

---

## Working with Express

Express apps are the most common use case. Pass the Express `app` directly — do not call `app.listen()` first.

```js
// app.js
const express = require('express');
const app = express();
app.use(express.json());

app.get('/ping', (req, res) => {
  res.json({ message: 'pong' });
});

module.exports = app;
```

```js
// app.test.js
const request = require('supertest');
const app = require('./app');

describe('GET /ping', () => {
  it('responds with pong', async () => {
    const res = await request(app)
      .get('/ping')
      .expect(200)
      .expect('Content-Type', /json/);

    expect(res.body.message).toBe('pong');
  });
});
```

---

## Working with Other Frameworks

### Raw `http` Module

```js
const http = require('http');
const request = require('supertest');

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello');
});

it('returns Hello', async () => {
  await request(server).get('/').expect(200).expect('Hello');
});
```

### Koa

```js
const Koa = require('koa');
const request = require('supertest');

const app = new Koa();
app.use(async (ctx) => {
  ctx.body = { status: 'ok' };
});

it('returns ok', async () => {
  await request(app.callback())
    .get('/')
    .expect(200);
});
```

Note: Koa requires `.callback()` to produce a compatible request handler.

### Fastify

```js
const fastify = require('fastify')();

fastify.get('/ping', async () => ({ message: 'pong' }));

it('returns pong', async () => {
  await fastify.ready();
  const res = await request(fastify.server)
    .get('/ping')
    .expect(200);
});
```

Note: Fastify requires `await fastify.ready()` before passing `fastify.server`.

---

## Authentication and Headers

### Setting Request Headers

```js
await request(app)
  .get('/protected')
  .set('Authorization', 'Bearer my-token')
  .expect(200);
```

### Multiple Headers

```js
await request(app)
  .post('/api/data')
  .set('Authorization', 'Bearer my-token')
  .set('X-Custom-Header', 'value')
  .send({ key: 'value' })
  .expect(201);
```

### Basic Auth

```js
await request(app)
  .get('/admin')
  .auth('username', 'password')
  .expect(200);
```

### Bearer Token (shorthand)

```js
await request(app)
  .get('/me')
  .auth('my-token', { type: 'bearer' })
  .expect(200);
```

---

## Sending Request Bodies

### JSON (default for objects)

```js
await request(app)
  .post('/users')
  .send({ name: 'Alice' })
  .expect(201);
```

Supertest sets `Content-Type: application/json` automatically when `.send()` receives a plain object.

### URL-encoded Form Data

```js
await request(app)
  .post('/login')
  .type('form')
  .send({ username: 'alice', password: 'secret' })
  .expect(302);
```

### Plain String

```js
await request(app)
  .post('/raw')
  .set('Content-Type', 'text/plain')
  .send('raw body text')
  .expect(200);
```

### Setting Content-Type Explicitly

```js
await request(app)
  .post('/data')
  .type('application/json')
  .send(JSON.stringify({ key: 'value' }))
  .expect(200);
```

---

## File Uploads

Use `.attach()` for multipart file uploads.

```js
await request(app)
  .post('/upload')
  .attach('file', '/path/to/local/file.pdf')
  .expect(200);
```

### With Additional Form Fields

```js
await request(app)
  .post('/upload')
  .field('title', 'My Document')
  .field('category', 'reports')
  .attach('file', '/path/to/file.pdf')
  .expect(200);
```

### Buffer as File

```js
const buffer = Buffer.from('file content here');

await request(app)
  .post('/upload')
  .attach('file', buffer, 'filename.txt')
  .expect(200);
```

---

## Cookies and Sessions

### Reading Response Cookies

```js
const res = await request(app)
  .post('/login')
  .send({ username: 'alice', password: 'secret' });

const cookie = res.headers['set-cookie'];
```

### Sending Cookies on Subsequent Requests

```js
await request(app)
  .get('/dashboard')
  .set('Cookie', cookie)
  .expect(200);
```

---

## Persistent Agents

A **persistent agent** maintains cookies and state across multiple requests within a test. This is useful for login/session flows.

```js
const agent = request.agent(app);

// Login — agent stores the session cookie
await agent
  .post('/login')
  .send({ username: 'alice', password: 'secret' })
  .expect(200);

// Subsequent requests reuse the session
await agent
  .get('/dashboard')
  .expect(200);

await agent
  .get('/profile')
  .expect(200);
```

### Closing an Agent

If your app binds to a port (e.g., `server.listen()`), you may need to close the agent's underlying server to avoid open handles:

```js
afterAll((done) => {
  agent.app.close(done); // if applicable
});
```

---

## Async/Await and Promises

### Async/Await (recommended)

```js
it('returns users', async () => {
  const res = await request(app).get('/users').expect(200);
  expect(res.body).toHaveLength(3);
});
```

### Promise `.then()`

```js
it('returns users', () => {
  return request(app)
    .get('/users')
    .expect(200)
    .then((res) => {
      expect(res.body).toHaveLength(3);
    });
});
```

### Callback style (older pattern)

```js
it('returns users', (done) => {
  request(app)
    .get('/users')
    .expect(200)
    .end((err, res) => {
      if (err) return done(err);
      expect(res.body).toHaveLength(3);
      done();
    });
});
```

Async/await is the clearest and most maintainable style for modern Node.js projects.

---

## Integration with Test Runners

### Jest

```js
// jest.config.js
module.exports = {
  testEnvironment: 'node',
};
```

```js
const request = require('supertest');
const app = require('./app');

describe('User API', () => {
  describe('GET /users', () => {
    it('returns 200 with array', async () => {
      const res = await request(app).get('/users').expect(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe('POST /users', () => {
    it('creates a user', async () => {
      const res = await request(app)
        .post('/users')
        .send({ name: 'Bob' })
        .expect(201);
      expect(res.body.name).toBe('Bob');
    });
  });
});
```

### Mocha

```js
const { expect } = require('chai');
const request = require('supertest');
const app = require('./app');

describe('GET /users', () => {
  it('returns 200', async () => {
    const res = await request(app).get('/users').expect(200);
    expect(res.body).to.be.an('array');
  });
});
```

### Vitest

```js
import { describe, it, expect } from 'vitest';
import request from 'supertest';
import app from './app';

describe('GET /users', () => {
  it('returns 200', async () => {
    const res = await request(app).get('/users').expect(200);
    expect(res.body).toBeInstanceOf(Array);
  });
});
```

---

## Custom Assertions

You can extend `.expect()` with a function for complex validation logic.

```js
await request(app)
  .get('/users')
  .expect(200)
  .expect((res) => {
    const users = res.body;

    if (!users.every((u) => typeof u.id === 'number')) {
      throw new Error('All users must have a numeric id');
    }

    if (!users.every((u) => typeof u.name === 'string')) {
      throw new Error('All users must have a string name');
    }
  });
```

You can also extract this into a reusable helper:

```js
function assertUsersShape(res) {
  if (!Array.isArray(res.body)) throw new Error('Expected array');
  for (const u of res.body) {
    if (typeof u.id !== 'number') throw new Error('id must be number');
    if (typeof u.name !== 'string') throw new Error('name must be string');
  }
}

await request(app).get('/users').expect(200).expect(assertUsersShape);
```

---

## Timeout Configuration

Supertest inherits timeout settings from superagent.

```js
await request(app)
  .get('/slow-endpoint')
  .timeout(5000) // milliseconds
  .expect(200);
```

You can also set separate response and deadline timeouts:

```js
await request(app)
  .get('/slow-endpoint')
  .timeout({ response: 3000, deadline: 10000 })
  .expect(200);
```

- `response`: time to wait for the first byte of the response
- `deadline`: total time for the request to complete

---

## HTTPS

Supertest supports HTTPS servers. Pass your HTTPS server to `request()` as you would with HTTP.

```js
const https = require('https');
const fs = require('fs');
const request = require('supertest');

const server = https.createServer(
  {
    key: fs.readFileSync('server.key'),
    cert: fs.readFileSync('server.cert'),
  },
  app
);

await request(server).get('/secure').expect(200);
```

For self-signed certificates in test environments, you may need to disable TLS verification in your test process:

```js
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
```

This should only ever be done in test environments.

---

## Common Patterns

### Setup and Teardown with a Persistent Server

When testing against a started server (e.g., one bound to a port), close it after tests to avoid open handles.

```js
let server;

beforeAll((done) => {
  server = app.listen(done);
});

afterAll((done) => {
  server.close(done);
});

it('returns 200', async () => {
  await request(server).get('/ping').expect(200);
});
```

### Database Seeding Pattern

```js
beforeEach(async () => {
  await db.seed(); // seed test data
});

afterEach(async () => {
  await db.clear(); // clean up after each test
});
```

### Token-Based Auth Helper

```js
async function getAuthToken(app, credentials) {
  const res = await request(app)
    .post('/auth/login')
    .send(credentials)
    .expect(200);
  return res.body.token;
}

it('accesses protected route', async () => {
  const token = await getAuthToken(app, { username: 'alice', password: 'secret' });

  await request(app)
    .get('/protected')
    .set('Authorization', `Bearer ${token}`)
    .expect(200);
});
```

### Testing Error Responses

```js
it('returns 404 for unknown user', async () => {
  const res = await request(app)
    .get('/users/9999')
    .expect(404);

  expect(res.body.error).toBe('User not found');
});

it('returns 400 for invalid input', async () => {
  const res = await request(app)
    .post('/users')
    .send({ name: '' })
    .expect(400);

  expect(res.body.errors).toBeDefined();
});
```

### Testing Redirects

```js
it('redirects to login when unauthenticated', async () => {
  await request(app)
    .get('/dashboard')
    .expect(302)
    .expect('Location', '/login');
});
```

---

## Troubleshooting

### Open Handles Warning (Jest)

Jest may warn about open handles if the HTTP server is not closed after tests. Solutions:

1. Use `--forceExit` flag (not recommended for production test suites).
2. Explicitly close the server in `afterAll`.
3. Do not call `app.listen()` in your app module — let supertest manage the lifecycle.

### `EADDRINUSE` Errors

This typically happens when you call `app.listen()` in the app module, and your test suite imports it multiple times. Avoid calling `listen` in your app file; call it in a separate entry point (e.g., `server.js`).

```
// app.js — do NOT call app.listen() here
module.exports = app;

// server.js — entry point only
const app = require('./app');
app.listen(3000);
```

### `Cannot read properties of undefined` on `res.body`

This often means the server returned an empty or non-JSON body when JSON was expected. Check:

- That `Content-Type: application/json` is set on the response.
- That `express.json()` or equivalent middleware is in use.
- That the route actually returns a body.

### Response Body is an Empty Object `{}`

This can happen if the server sends a non-JSON content type but supertest still tries to parse it. Check the `res.text` property for the raw response instead.

```js
const res = await request(app).get('/text-endpoint').expect(200);
console.log(res.text); // raw string body
console.log(res.body); // parsed JSON, if applicable
```

---

## API Reference Summary

### `request(app)`

Creates a new supertest instance wrapping the provided app or server.

### HTTP Method Shortcuts

|Method|Usage|
|---|---|
|`.get(url)`|HTTP GET|
|`.post(url)`|HTTP POST|
|`.put(url)`|HTTP PUT|
|`.patch(url)`|HTTP PATCH|
|`.delete(url)`|HTTP DELETE|
|`.head(url)`|HTTP HEAD|
|`.options(url)`|HTTP OPTIONS|

### Request Modifiers

|Method|Description|
|---|---|
|`.set(field, value)`|Set a request header|
|`.send(data)`|Set the request body|
|`.type(contentType)`|Set Content-Type shorthand|
|`.auth(user, pass)`|HTTP Basic Auth|
|`.auth(token, {type: 'bearer'})`|Bearer token|
|`.attach(field, file)`|Attach a file (multipart)|
|`.field(name, value)`|Set a multipart form field|
|`.query(params)`|Set query string parameters|
|`.timeout(ms)`|Set request timeout|
|`.redirects(n)`|Follow up to n redirects|

### Assertions

|Method|Description|
|---|---|
|`.expect(statusCode)`|Assert HTTP status|
|`.expect(field, value)`|Assert response header|
|`.expect(body)`|Assert response body (deep equal)|
|`.expect(fn)`|Custom assertion function|

### Response Object Properties

|Property|Description|
|---|---|
|`res.status`|HTTP status code|
|`res.body`|Parsed JSON body (if applicable)|
|`res.text`|Raw response body as string|
|`res.headers`|Response headers object|
|`res.type`|Content-Type without parameters|

### `request.agent(app)`

Creates a persistent agent that retains cookies across requests.

---

_Source: [supertest on GitHub](https://github.com/ladjs/supertest) and [superagent documentation](https://github.com/visionmedia/superagent). Verify against the latest library version for any changes._
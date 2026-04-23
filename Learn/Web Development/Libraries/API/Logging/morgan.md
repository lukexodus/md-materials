# morgan

## Overview

`morgan` is an HTTP request logger middleware for Node.js and Express. It intercepts incoming requests and writes log entries to a stream — by default, `process.stdout`. It is named after Dexter Morgan.

**Source of truth:** [github.com/expressjs/morgan](https://github.com/expressjs/morgan)

---

## Installation

```bash
npm install morgan
```

---

## Basic Usage

```js
const express = require('express');
const morgan = require('morgan');

const app = express();
app.use(morgan('dev'));
```

`morgan(format, options)` returns an Express/Connect middleware function. It must be registered before route handlers to log all requests.

---

## Predefined Formats

### `combined`

Apache Combined Log Format. Standard for production logs.

```
::1 - - [20/Apr/2026 12:00:00 +0800] "GET /api/users HTTP/1.1" 200 1234 "-" "Mozilla/5.0"
```

Fields: remote-addr, ident, user, date, method, url, http-version, status, res[content-length], referrer, user-agent

### `common`

Apache Common Log Format. Like `combined` minus referrer and user-agent.

```
::1 - - [20/Apr/2026 12:00:00 +0800] "GET /api/users HTTP/1.1" 200 1234
```

### `dev`

Concise colored output keyed by response status. Intended for development.

```
GET /api/users 200 4.321 ms - 1234
```

Color: green (2xx), cyan (3xx), yellow (4xx), red (5xx).

### `short`

Shorter than `common`, includes response time.

```
::1 - GET /api/users HTTP/1.1 200 1234 - 4.321 ms
```

### `tiny`

Minimal output.

```
GET /api/users 200 1234 - 4.321 ms
```

---

## Custom Format String

Pass a string with `:token` placeholders:

```js
app.use(morgan(':method :url :status :res[content-length] - :response-time ms'));
```

---

## Tokens

### Built-in Tokens

|Token|Description|
|---|---|
|`:date[format]`|UTC date. Formats: `clf`, `iso`, `web`. Default: `web`|
|`:http-version`|HTTP version|
|`:method`|Request method|
|`:referrer`|`Referer` header (accepts misspelling too)|
|`:remote-addr`|Remote IP address|
|`:remote-user`|Basic auth user from URL|
|`:req[header]`|Arbitrary request header|
|`:res[header]`|Arbitrary response header|
|`:response-time[digits]`|Time in ms between request and response write. Default precision: 3 digits|
|`:status`|HTTP response status code|
|`:total-time[digits]`|Time in ms between request and response finish (including flushing)|
|`:url`|Request URL including query string|
|`:user-agent`|`User-Agent` header|

Examples:

```js
':req[x-forwarded-for]'   // specific request header
':res[content-type]'      // specific response header
':date[iso]'              // ISO 8601 date
':response-time[0]'       // response time, 0 decimal digits
```

### Custom Tokens

```js
morgan.token('id', (req) => req.id);

morgan.token('user', (req) => {
  return req.user ? req.user.username : 'anonymous';
});

app.use(morgan(':method :url :status - :user'));
```

`morgan.token(name, fn)` registers a token globally. The function receives `(req, res)` and must return a string (or `undefined`/`'-'` for absent values).

---

## Options

```js
morgan(format, {
  immediate: false,
  skip: fn,
  stream: writableStream
})
```

### `immediate`

Type: `boolean`. Default: `false`.

When `true`, writes the log on request receipt instead of on response finish. The log will not include status code, response time, or response headers.

```js
morgan('combined', { immediate: true });
```

### `skip`

Type: `function(req, res) => boolean`. Default: `undefined`.

When the function returns `true`, the log entry is skipped.

```js
// skip successful requests
morgan('combined', {
  skip: (req, res) => res.statusCode < 400
});

// skip health check endpoint
morgan('dev', {
  skip: (req) => req.url === '/health'
});
```

### `stream`

Type: writable stream. Default: `process.stdout`.

```js
const fs = require('fs');
const path = require('path');

const accessLog = fs.createWriteStream(
  path.join(__dirname, 'access.log'),
  { flags: 'a' }
);

app.use(morgan('combined', { stream: accessLog }));
```

---

## Log Rotation

morgan has no built-in rotation. Use `rotating-file-stream` for size- or time-based rotation:

```bash
npm install rotating-file-stream
```

```js
const rfs = require('rotating-file-stream');
const path = require('path');

const stream = rfs.createStream('access.log', {
  interval: '1d',        // rotate daily
  size: '10M',           // rotate if file exceeds 10 MB
  path: path.join(__dirname, 'logs'),
  compress: 'gzip'
});

app.use(morgan('combined', { stream }));
```

---

## Dual Logging

Log all requests to a file and errors-only to stdout:

```js
const fs = require('fs');

const allLog = fs.createWriteStream('./logs/access.log', { flags: 'a' });

// all requests to file
app.use(morgan('combined', { stream: allLog }));

// errors only to stdout
app.use(morgan('dev', {
  skip: (req, res) => res.statusCode < 400
}));
```

---

## Integrating with a Logger (e.g., Winston, Pino)

Pass a stream-compatible object. Most loggers expose a writable stream or can be wrapped:

### Winston

```js
const winston = require('winston');

const logger = winston.createLogger({
  transports: [new winston.transports.Console()]
});

app.use(morgan('combined', {
  stream: {
    write: (message) => logger.http(message.trim())
  }
}));
```

### Pino

```js
const pino = require('pino');
const logger = pino();

app.use(morgan('combined', {
  stream: {
    write: (message) => logger.info(message.trim())
  }
}));
```

`.trim()` removes the trailing newline morgan appends to each log entry.

---

## Format Function

Instead of a string, pass a function as the format:

```js
app.use(morgan((tokens, req, res) => {
  return [
    tokens.method(req, res),
    tokens.url(req, res),
    tokens.status(req, res),
    tokens['response-time'](req, res), 'ms',
    '-',
    tokens.res(req, res, 'content-length')
  ].join(' ');
}));
```

Returning `null` or `undefined` from the format function skips the log entry, equivalent to `skip`.

---

## Behavior Notes

morgan logs after the response is finished by default (`immediate: false`). This means `:status`, `:response-time`, and response headers are always available in the log unless `immediate` is set.

morgan does not modify `req` or `res`. It attaches no properties to the request object.

morgan does not buffer log entries. Each request produces one write to the stream.

If the stream write throws, the error is emitted on the stream, not propagated to Express's error handler.

---

## TypeScript

```bash
npm install --save-dev @types/morgan
```

```ts
import morgan, { StreamOptions } from 'morgan';
import { Request, Response } from 'express';

const stream: StreamOptions = {
  write: (message: string) => console.log(message.trim())
};

app.use(morgan('dev', { stream }));

morgan.token<Request, Response>('user', (req) => req.user?.id ?? 'anon');
```
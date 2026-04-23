# Node.js `compression` Library — Comprehensive Guide

## What Is `compression`?

`compression` is a Node.js middleware package that applies HTTP response compression using the `zlib` module built into Node.js. It is commonly used with Express and Connect-style frameworks to reduce the size of HTTP responses before sending them to clients.

- **npm package:** `compression`
- **Underlying engine:** Node.js native `zlib` (no native binaries required)
- **Supported algorithms:** Gzip and Deflate (chosen via content negotiation with the client's `Accept-Encoding` header)
- **License:** MIT

> **Note:** The `compression` package is a community-maintained middleware. Its behavior and API are based on its published documentation and source code. Claims about runtime behavior are labeled [Inference] where they cannot be independently confirmed from a static source.

---

## Installation

```bash
npm install compression
```

For TypeScript projects, type definitions are available separately:

```bash
npm install --save-dev @types/compression
```

---

## Basic Usage

### With Express

```js
const express = require('express');
const compression = require('compression');

const app = express();

// Mount compression middleware before route handlers
app.use(compression());

app.get('/', (req, res) => {
  res.send('This response will be compressed if the client supports it.');
});

app.listen(3000);
```

### With `http.createServer` (no framework)

```js
const http = require('http');
const compression = require('compression');
const connect = require('connect');

const app = connect();
app.use(compression());

http.createServer(app).listen(3000);
```

[Inference] The middleware intercepts the response stream and wraps it with a zlib transform stream before flushing to the socket. This is not guaranteed behavior and may vary with Node.js version.

---

## How It Works

When a request arrives:

1. The middleware reads the client's `Accept-Encoding` request header.
2. If `gzip` is listed, the response is compressed with Gzip.
3. If only `deflate` is listed (and `gzip` is not), Deflate is used.
4. If neither is listed, or the response does not meet the threshold, the response is passed through uncompressed.
5. The `Content-Encoding` response header is set to reflect the algorithm used.
6. The `Content-Length` header is removed (because the compressed length is not known in advance for streams), and `Transfer-Encoding: chunked` is used instead.

---

## Configuration Options

All options are passed as an object to `compression(options)`.

### `threshold`

The minimum response body size (in bytes) required before compression is applied. Responses smaller than this value are sent uncompressed.

- **Type:** `number | string`
- **Default:** `1024` (1 KB)
- Strings are parsed by the `bytes` package (e.g., `'1kb'`, `'500b'`).

```js
app.use(compression({ threshold: 0 }));      // compress everything
app.use(compression({ threshold: '2kb' }));  // only compress if > 2 KB
```

### `level`

The zlib compression level. Higher values produce smaller output but use more CPU.

- **Type:** `number`
- **Range:** `-1` to `9`
- **Default:** `zlib.Z_DEFAULT_COMPRESSION` (which is `-1`, mapped internally by zlib to level `6`)
- `0` = no compression (store only); `1` = fastest; `9` = best compression

```js
app.use(compression({ level: 6 }));
```

### `memLevel`

Controls how much memory zlib uses for internal compression state.

- **Type:** `number`
- **Range:** `1` to `9`
- **Default:** `zlib.Z_DEFAULT_MEMLEVEL` (`8`)
- Higher values use more memory and [Inference] may improve compression speed.

```js
app.use(compression({ memLevel: 8 }));
```

### `strategy`

The zlib compression strategy. Controls how the algorithm approaches the input data.

- **Type:** `number`
- **Default:** `zlib.Z_DEFAULT_STRATEGY`
- Common values:
    - `zlib.Z_DEFAULT_STRATEGY` — general-purpose
    - `zlib.Z_HUFFMAN_ONLY` — Huffman coding only, no string matching
    - `zlib.Z_FILTERED` — for data produced by a filter
    - `zlib.Z_RLE` — run-length encoding
    - `zlib.Z_FIXED` — prevents dynamic Huffman codes

```js
const zlib = require('zlib');
app.use(compression({ strategy: zlib.Z_DEFAULT_STRATEGY }));
```

### `filter`

A function that determines whether a given response should be compressed. Called with `(req, res)`. If it returns `true`, compression proceeds; if `false`, it is skipped.

- **Type:** `function(req, res): boolean`
- **Default:** `compression.filter` (the built-in filter, see below)

```js
app.use(compression({
  filter: (req, res) => {
    // Do not compress responses with this header
    if (req.headers['x-no-compression']) {
      return false;
    }
    // Fall back to the default filter
    return compression.filter(req, res);
  }
}));
```

### `windowBits`

The base-two logarithm of the window size used by zlib. Affects compression ratio and memory usage.

- **Type:** `number`
- **Range:** `8` to `15`
- **Default:** `zlib.Z_DEFAULT_WINDOWBITS` (`15`)

Typically left at the default unless you have a specific tuning requirement.

### `chunkSize`

The size of internal zlib output chunks.

- **Type:** `number`
- **Default:** `zlib.Z_DEFAULT_CHUNK` (`16384`, i.e., 16 KB)

---

## The Default Filter (`compression.filter`)

The built-in filter function checks the `Content-Type` response header. [Inference] It compresses responses whose content type matches patterns that indicate text-based or compressible content — for example, `text/*`, `application/json`, `application/javascript`, `application/xml`, and `image/svg+xml`. Binary formats such as `image/jpeg` or `image/png` are not compressed by default, because they are already compressed formats and further compression offers minimal benefit at a CPU cost.

You can inspect the source to confirm exact behavior: [https://github.com/expressjs/compression](https://github.com/expressjs/compression)

---

## Conditional Compression

### Skip compression for specific routes

```js
app.use(compression());

// This specific route disables compression by setting a header before
// the response is sent — the filter function checks req headers
app.get('/no-compress', (req, res) => {
  res.set('Cache-Control', 'no-transform');
  res.send('Not compressed.');
});
```

### Using a custom filter per request

```js
app.use(compression({
  filter: (req, res) => {
    if (req.path.startsWith('/static/images')) {
      return false; // skip for image routes
    }
    return compression.filter(req, res);
  }
}));
```

---

## Flushing Compressed Data (Server-Sent Events / Streaming)

By default, zlib buffers data for efficiency. For streaming use cases (e.g., Server-Sent Events, chunked streaming responses), you can call `res.flush()` to force the currently buffered compressed data to be sent immediately.

The `compression` middleware augments `res` with a `flush()` method for this purpose.

```js
app.get('/events', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');

  let count = 0;
  const interval = setInterval(() => {
    res.write(`data: ${JSON.stringify({ count: count++ })}\n\n`);
    res.flush(); // push compressed bytes immediately
  }, 1000);

  req.on('close', () => clearInterval(interval));
});
```

> Without `res.flush()`, the zlib stream may buffer data and the client may not receive events in real time. [Inference]

---

## Using with HTTPS

The `compression` middleware operates at the application layer and is unaware of whether the transport is HTTP or HTTPS. It can be used identically with both.

> **Security note:** There is a known class of attacks (BREACH, CRIME) that exploit HTTP compression combined with TLS to extract secrets from compressed, encrypted responses — particularly when attacker-controlled input is reflected alongside secrets in the same response. This is a broader TLS/HTTP design concern, not specific to this library. If your application compresses responses containing sensitive tokens or secrets alongside reflected user input, consult relevant security guidance.

---

## Integration with Reverse Proxies

If your Node.js application runs behind a reverse proxy (Nginx, Caddy, AWS ALB, etc.) that handles compression, you should typically disable compression in `compression` to avoid double-compression:

```js
// If Nginx is handling gzip, disable this middleware
// app.use(compression()); // commented out
```

Double-compression produces valid output but wastes CPU on both sides and can result in larger-than-necessary payloads. [Inference]

---

## TypeScript Usage

```ts
import express, { Request, Response } from 'express';
import compression from 'compression';

const app = express();

app.use(compression({
  level: 6,
  threshold: 1024,
}));

app.get('/', (req: Request, res: Response) => {
  res.json({ message: 'Compressed response' });
});

app.listen(3000);
```

---

## Performance Considerations

These are [Inference] based on how zlib compression generally works. They are not guaranteed outcomes and will vary by workload:

- **CPU cost:** Compression is CPU-bound. High-throughput APIs may see CPU pressure under load at `level 9`. Level `6` is a common middle ground.
- **Latency for small responses:** Compressing responses below ~1 KB [Inference] may increase latency rather than reduce it, because the overhead of compression exceeds the savings. The default `threshold` of `1024` bytes addresses this.
- **Already-compressed content:** Sending pre-compressed assets (gzip files) via `res.sendFile` bypasses middleware compression. Attempting to re-compress JPEG/PNG/WebP via a custom filter that returns `true` for those types [Inference] produces minimal benefit and wastes CPU.
- **Memory:** Each concurrent connection under compression holds a zlib stream in memory. The `memLevel` option controls the per-stream memory allocation.

---

## Alternatives and When to Prefer Them

|Option|Notes|
|---|---|
|`compression` npm package|Good for simple Express/Connect apps; uses Node.js `zlib`|
|Nginx / Caddy gzip|[Inference] Generally more performant for high-traffic scenarios; offloads CPU from the Node.js process|
|`@fastify/compress`|Purpose-built for Fastify; supports Brotli in addition to gzip/deflate|
|`shrink-ray-current`|Fork with Brotli support for Express|
|Node.js 21+ native `CompressionStream`|Web Streams API; not a drop-in middleware replacement|

> The `compression` package does not natively support Brotli (`br`) encoding. If Brotli support is needed with Express, consider `shrink-ray-current` or handle it manually with `zlib.createBrotliCompress()`.

---

## Debugging and Verification

To confirm compression is active, inspect the response headers:

```bash
curl -I -H "Accept-Encoding: gzip" http://localhost:3000/
```

Look for:

```
Content-Encoding: gzip
Transfer-Encoding: chunked
```

Or in a browser, open DevTools → Network → select a request → check the Response Headers tab for `Content-Encoding`.

---

## Common Mistakes

**Mounting after route handlers.** Middleware order matters in Express. If `compression()` is added after routes, it will not compress those responses.

```js
// Wrong
app.get('/data', handler);
app.use(compression()); // too late

// Correct
app.use(compression());
app.get('/data', handler);
```

**Setting `Content-Length` manually after compression.** The compressed body has a different length than the original. Setting `Content-Length` explicitly to the uncompressed size will cause clients to misread the response. Let the middleware manage this header.

**Assuming all responses are compressed.** The filter, threshold, and client `Accept-Encoding` header all gate compression. Not every response will be compressed. [Inference]

**Double-compressing.** If your reverse proxy also compresses, disable one layer.

---

## Full Example: Express App with Tuned Options

```js
const express = require('express');
const compression = require('compression');
const zlib = require('zlib');

const app = express();

app.use(compression({
  level: 6,
  threshold: 1024,
  memLevel: 8,
  strategy: zlib.Z_DEFAULT_STRATEGY,
  filter: (req, res) => {
    // Skip compression for event streams (handled per-route with res.flush)
    if (res.getHeader('Content-Type') === 'text/event-stream') {
      return false;
    }
    return compression.filter(req, res);
  }
}));

app.get('/api/data', (req, res) => {
  res.json({ items: Array.from({ length: 1000 }, (_, i) => ({ id: i, name: `Item ${i}` })) });
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

---

## Resources

- npm page: [https://www.npmjs.com/package/compression](https://www.npmjs.com/package/compression)
- GitHub source: [https://github.com/expressjs/compression](https://github.com/expressjs/compression)
- Node.js `zlib` docs: [https://nodejs.org/api/zlib.html](https://nodejs.org/api/zlib.html)
- BREACH attack reference: [https://breachattack.com](https://breachattack.com/)
### Reply Object — Streaming Responses

Streaming allows a server to send response data incrementally rather than waiting for an entire payload to be assembled before transmission. Fastify supports Node.js streams natively through the `reply.send()` method.

---

#### Why Stream Responses

- Reduces time-to-first-byte for large payloads
- Avoids buffering the entire response in memory
- Suitable for file downloads, real-time data, and large dataset exports

> [Inference] These are generally accepted benefits of streaming in Node.js HTTP servers. Actual performance characteristics depend on the specific workload, infrastructure, and client behavior.

---

#### Sending a Readable Stream

Pass any Node.js `Readable` stream directly to `reply.send()`. Fastify pipes the stream to the response socket.

js

```
import fs from 'fs';

fastify.get('/file', async (request, reply) => {
  const stream = fs.createReadStream('./large-file.csv');
  return reply.send(stream);
});
```

Fastify automatically sets `Content-Type` to `application/octet-stream` if no `Content-Type` header has been set manually.

---

#### Setting Headers for Streamed Responses

Since the `Content-Length` is often unknown ahead of time for streams, it is typically omitted. Set relevant headers before calling `reply.send()`.

js

```
fastify.get('/download', async (request, reply) => {
  const stream = fs.createReadStream('./report.pdf');

  reply.header('Content-Type', 'application/pdf');
  reply.header('Content-Disposition', 'attachment; filename="report.pdf"');

  return reply.send(stream);
});
```

> [Inference] Omitting `Content-Length` causes the response to use chunked transfer encoding in HTTP/1.1. Behavior may vary across HTTP versions and client implementations.

---

#### Streaming with `pump` / Pipeline

Directly piping streams without error handling can leave sockets open on stream errors. Use Node.js `stream.pipeline` to handle errors cleanly.

js

```
import { pipeline } from 'stream';
import { promisify } from 'util';
import fs from 'fs';

const pipelineAsync = promisify(pipeline);

fastify.get('/safe-stream', async (request, reply) => {
  const source = fs.createReadStream('./data.json');

  reply.header('Content-Type', 'application/json');

  await pipelineAsync(source, reply.raw);
});
```

> [Inference] Using `reply.raw` gives access to the underlying `http.ServerResponse` object. Writing directly to `reply.raw` bypasses some of Fastify's reply lifecycle. This pattern is appropriate when manual pipeline control is needed, but use with care.

---

#### Using `reply.raw` for Low-Level Streaming

`reply.raw` is the raw Node.js `ServerResponse`. It can be written to directly when Fastify's abstraction layer is not needed.

js

```
fastify.get('/raw-stream', (request, reply) => {
  reply.raw.writeHead(200, { 'Content-Type': 'text/plain' });
  reply.raw.write('chunk one\n');
  reply.raw.write('chunk two\n');
  reply.raw.end();
});
```

> [Inference] Writing to `reply.raw` directly bypasses Fastify hooks such as `onSend` and `preSerialization`. Behavior of lifecycle hooks when mixing `reply.raw` and Fastify reply methods is not guaranteed.

---

#### Server-Sent Events (SSE)

SSE is a technique for pushing a continuous stream of text events from server to client over a single HTTP connection. It uses `text/event-stream` as the content type.

js

```
fastify.get('/events', (request, reply) => {
  reply.raw.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
  });

  let count = 0;
  const interval = setInterval(() => {
    reply.raw.write(`data: tick ${count++}\n\n`);

    if (count >= 5) {
      clearInterval(interval);
      reply.raw.end();
    }
  }, 1000);

  request.raw.on('close', () => {
    clearInterval(interval);
  });
});
```

**Key points:**

- Each SSE message is separated by a double newline (`\n\n`)
- The `data:` prefix is part of the SSE protocol
- Listening to `request.raw.on('close')` cleans up resources when the client disconnects

> [Inference] SSE is suitable for unidirectional, server-to-client push. For bidirectional communication, WebSockets are the more appropriate choice.

---

#### Streaming JSON (Newline-Delimited JSON)

Newline-delimited JSON (NDJSON) is a format where each line is a valid JSON object. It is commonly used for streaming structured data.

js

```
import { Readable } from 'stream';

fastify.get('/ndjson', async (request, reply) => {
  const records = [{ id: 1 }, { id: 2 }, { id: 3 }];

  const readable = Readable.from(
    (async function* () {
      for (const record of records) {
        yield JSON.stringify(record) + '\n';
      }
    })()
  );

  reply.header('Content-Type', 'application/x-ndjson');
  return reply.send(readable);
});
```

---

#### Async Generators as Streams

Node.js `Readable.from()` accepts async generators, making it straightforward to produce stream data from asynchronous sources.

js

```
import { Readable } from 'stream';

async function* fetchRows() {
  const rows = await db.query('SELECT * FROM logs'); // [Inference] — placeholder
  for (const row of rows) {
    yield JSON.stringify(row) + '\n';
  }
}

fastify.get('/logs', async (request, reply) => {
  reply.header('Content-Type', 'application/x-ndjson');
  return reply.send(Readable.from(fetchRows()));
});
```

> [Inference] This pattern avoids loading the full result set into memory before responding. Actual memory behavior depends on the database driver and how it returns results (buffered vs. cursor-based).

---

#### Error Handling During Streaming

Once streaming has begun, Fastify cannot send an HTTP error response because the status code and headers have already been flushed. Stream errors after that point cannot be surfaced as standard JSON error responses.

js

```
fastify.get('/risky-stream', async (request, reply) => {
  const stream = fs.createReadStream('./maybe-missing.txt');

  stream.on('error', (err) => {
    // Headers may already be sent — cannot reply with a 500 here
    fastify.log.error(err);
    reply.raw.destroy(err);
  });

  return reply.send(stream);
});
```

> [Inference] This is a fundamental limitation of HTTP streaming: once the response body has begun transmitting, the status line and headers are immutable. Error handling strategy should be designed around this constraint.

---

#### Backpressure

Node.js streams handle backpressure automatically when using `pipe()` or `pipeline()`. When writing to `reply.raw` manually, backpressure must be managed explicitly by checking the return value of `write()`.

js

```
fastify.get('/backpressure', (request, reply) => {
  reply.raw.writeHead(200, { 'Content-Type': 'text/plain' });

  const source = fs.createReadStream('./large.txt');

  source.on('data', (chunk) => {
    const ok = reply.raw.write(chunk);
    if (!ok) {
      source.pause();
      reply.raw.once('drain', () => source.resume());
    }
  });

  source.on('end', () => reply.raw.end());
});
```

> [Inference] Ignoring backpressure when writing large streams manually can lead to excessive memory usage. Using `pipeline()` is generally preferable as it handles this automatically.

---

#### Comparison of Streaming Approaches

| Approach | Use Case | Handles Backpressure | Fastify Hooks Apply |
| --- | --- | --- | --- |
| `reply.send(stream)` | General file / data streaming | Yes (via pipe) | Yes |
| `stream.pipeline(src, reply.raw)` | Controlled pipeline with error handling | Yes | Partially |
| `reply.raw.write()` / `reply.raw.end()` | Low-level / SSE / fine-grained control | Manual | No |
| `Readable.from(asyncGen)` | Async generator sources | Yes (via pipe) | Yes |

---

#### Summary

- Pass a `Readable` stream to `reply.send()` for the simplest streaming setup
- Set `Content-Type` explicitly; `Content-Length` is typically omitted for streams
- Use `stream.pipeline()` for error-safe piping
- Use `reply.raw` for low-level control such as SSE, but be aware that Fastify lifecycle hooks may not apply
- Handle stream errors before headers are flushed; errors after transmission begins cannot be sent as HTTP error responses
- Prefer `pipeline()` or `reply.send(stream)` over manual `write()` calls to avoid backpressure issues
## SSE Plugin Patterns

### Why Use a Plugin for SSE

Manually wiring `reply.raw` in every SSE route duplicates header-setting logic, cleanup boilerplate, and event formatting. Encapsulating this into a Fastify plugin produces a consistent, reusable interface across routes and enforces correct behavior (headers, cleanup, keepalive) as a single maintained unit.

This topic covers both using an existing community plugin and building a custom SSE plugin from scratch using Fastify's plugin system.

---

### The `fastify-sse-v2` Community Plugin

`fastify-sse-v2` is the most actively referenced community plugin for SSE in Fastify. [Unverified — verify current maintenance status and compatibility with your Fastify version before adopting.]

#### Installation

bash

```bash
npm install fastify-sse-v2
```

#### Registration

javascript

```javascript
import Fastify from 'fastify';
import FastifySSEPlugin from 'fastify-sse-v2';

const fastify = Fastify();
fastify.register(FastifySSEPlugin);
```

#### Basic Usage

After registration, `reply.sse()` becomes available on every reply object:

javascript

```javascript
fastify.get('/events', (request, reply) => {
  reply.sse({ data: 'connected' });

  let id = 0;
  const interval = setInterval(() => {
    reply.sse({
      id: String(id++),
      event: 'update',
      data: JSON.stringify({ time: Date.now() }),
    });
  }, 1000);

  request.raw.on('close', () => clearInterval(interval));
});
```

**Key Points:**

- `reply.sse()` handles header setting and event formatting internally
- The plugin accepts an object with optional `id`, `event`, `data`, and `retry` fields — [Unverified] confirm accepted field shape against the installed version's README
- The connection remains open; cleanup via `request.raw.on('close')` is still the application's responsibility
- [Inference] Because `reply.sse()` wraps `reply.raw`, the same constraints around `reply.send()`, schema validation, and compression apply as with manual `reply.raw` usage

#### Async Iterator Support

`fastify-sse-v2` supports async iterables as the event source, which integrates cleanly with generators:

javascript

```javascript
import { EventIterator } from 'event-iterator'; // or any async iterable source

fastify.get('/stream', async (request, reply) => {
  async function* eventSource() {
    let id = 0;
    while (true) {
      yield {
        id: String(id++),
        event: 'tick',
        data: JSON.stringify({ count: id }),
      };
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }

  reply.sse(eventSource());
});
```

**Key Points:**

- When passed an async iterable, the plugin iterates it and sends each yielded value as an SSE event
- The plugin [Inference] handles cleanup when the iterable is exhausted or the client disconnects — verify this behavior against the installed version, as cleanup semantics may differ
- Infinite generators must have an external termination mechanism or rely on client disconnect to stop iteration

---

### Building a Custom SSE Plugin

When `fastify-sse-v2` does not fit your requirements (custom keepalive logic, specific header policies, proprietary event schemas), building a plugin gives full control.

#### Plugin Structure

javascript

```javascript
// plugins/sse.js
import fp from 'fastify-plugin';

function ssePlugin(fastify, options, done) {
  const {
    keepaliveInterval = 15000,
    retryMs = null,
  } = options;

  fastify.decorateReply('sse', null);

  fastify.addHook('onRequest', (request, reply, next) => {
    // Attach the sse sender to each reply instance
    reply.sse = function sseReply(event) {
      // Write SSE headers if not already sent
      if (!this.raw.headersSent) {
        this.raw.writeHead(200, {
          'Content-Type': 'text/event-stream',
          'Cache-Control': 'no-cache',
          'Connection': 'keep-alive',
          'X-Accel-Buffering': 'no',
        });
      }

      this.raw.write(formatEvent(event));
    };

    next();
  });

  function formatEvent({ id, event, data, retry } = {}) {
    let out = '';
    if (id !== undefined)    out += `id: ${id}\n`;
    if (event !== undefined) out += `event: ${event}\n`;
    if (retry !== undefined) out += `retry: ${retry}\n`;

    const lines = String(data ?? '').split('\n');
    for (const line of lines) {
      out += `data: ${line}\n`;
    }
    out += '\n';
    return out;
  }

  done();
}

export default fp(ssePlugin, {
  name: 'sse',
  fastify: '4.x || 5.x',
});
```

**Key Points:**

- `fp` (from `fastify-plugin`) unwraps the plugin's encapsulation scope, making `reply.sse` available across the entire Fastify instance
- `decorateReply` must be called with the initial value `null` before assigning in a hook — Fastify enforces decoration before use
- `onRequest` is used here to attach the method per-request — [Inference] `decorateReply` with a function value would also work, but method access to `this` (the reply instance) requires care depending on how the decorator is structured

#### Registering and Using the Custom Plugin

javascript

```javascript
import Fastify from 'fastify';
import ssePlugin from './plugins/sse.js';

const fastify = Fastify();
await fastify.register(ssePlugin, { keepaliveInterval: 20000 });

fastify.get('/events', (request, reply) => {
  reply.sse({ event: 'connected', data: 'ok' });

  let id = 0;
  const interval = setInterval(() => {
    reply.sse({
      id: id++,
      event: 'update',
      data: JSON.stringify({ ts: Date.now() }),
    });
  }, 2000);

  request.raw.on('close', () => clearInterval(interval));
});
```

---

### Adding Keepalive to the Custom Plugin

Keepalive should be managed per-connection, not globally. Attach it inside the route or in an `onRequest` hook scoped to SSE routes:

javascript

```javascript
fastify.get('/events', (request, reply) => {
  reply.sse({ event: 'connected', data: '' });

  const keepalive = setInterval(() => {
    if (!reply.raw.destroyed) {
      reply.raw.write(': keepalive\n\n');
    }
  }, 15000);

  let id = 0;
  const interval = setInterval(() => {
    reply.sse({ id: id++, event: 'tick', data: String(Date.now()) });
  }, 3000);

  request.raw.on('close', () => {
    clearInterval(keepalive);
    clearInterval(interval);
  });
});
```

---

### Scoping SSE Plugin to Specific Routes

Using Fastify's encapsulation, you can register the SSE plugin only within a specific context rather than globally:

javascript

```javascript
fastify.register(async function sseContext(instance) {
  await instance.register(ssePlugin);

  instance.get('/live', (request, reply) => {
    reply.sse({ event: 'ready', data: 'stream started' });
    // ...
  });
});

// Routes outside this context do not have reply.sse
fastify.get('/health', (request, reply) => {
  reply.send({ status: 'ok' });
});
```

**Key Points:**

- Without `fp()`, plugins are scoped to the enclosing `register` context
- With `fp()`, decorators propagate upward and are available globally
- Choosing between scoped and global registration is an architectural decision — [Inference] scoped is preferable if SSE is only used in a subset of routes, to avoid polluting all reply instances with SSE methods

---

### Plugin Architecture Patterns

#### Pattern 1 — Thin Decorator (reply.sse sends one event)

The plugin only adds a formatting and writing helper. Connection management remains in the route.

```
Route handler
  ├── reply.sse(event)     ← plugin responsibility
  ├── setInterval(...)     ← route responsibility
  └── request.raw.on('close', cleanup)   ← route responsibility
```

**Suitable for:** Simple use cases, full control per route.

#### Pattern 2 — Stream Manager (plugin manages the stream lifecycle)

The plugin exposes a stream object that encapsulates the connection, keepalive, and cleanup:

javascript

```javascript
// plugins/sse-stream.js
import fp from 'fastify-plugin';

function sseStreamPlugin(fastify, options, done) {
  fastify.decorateReply('sseStream', null);

  fastify.addHook('onRequest', (request, reply, next) => {
    reply.sseStream = function createStream() {
      if (!this.raw.headersSent) {
        this.raw.writeHead(200, {
          'Content-Type': 'text/event-stream',
          'Cache-Control': 'no-cache',
          'Connection': 'keep-alive',
          'X-Accel-Buffering': 'no',
        });
      }

      const raw = this.raw;
      const cleanups = new Set();

      const keepalive = setInterval(() => {
        if (!raw.destroyed) raw.write(': keepalive\n\n');
      }, options.keepaliveInterval ?? 15000);

      cleanups.add(() => clearInterval(keepalive));

      request.raw.on('close', () => {
        for (const fn of cleanups) fn();
        cleanups.clear();
      });

      return {
        send({ id, event, data } = {}) {
          if (raw.destroyed) return;
          let out = '';
          if (id !== undefined)    out += `id: ${id}\n`;
          if (event !== undefined) out += `event: ${event}\n`;
          const lines = String(data ?? '').split('\n');
          for (const line of lines) out += `data: ${line}\n`;
          out += '\n';
          raw.write(out);
        },
        onClose(fn) {
          cleanups.add(fn);
        },
        get destroyed() {
          return raw.destroyed;
        },
      };
    };
    next();
  });

  done();
}

export default fp(sseStreamPlugin, { name: 'sse-stream' });
```

**Usage:**

javascript

```javascript
fastify.get('/events', (request, reply) => {
  const stream = reply.sseStream();

  let id = 0;
  const interval = setInterval(() => {
    stream.send({
      id: id++,
      event: 'update',
      data: JSON.stringify({ ts: Date.now() }),
    });
  }, 1000);

  stream.onClose(() => clearInterval(interval));
});
```

**Key Points:**

- The stream object centralizes cleanup registration via `onClose`
- Keepalive is automatic and does not require per-route wiring
- `stream.destroyed` provides a safe guard before writes
- [Inference] This pattern scales better across many SSE routes as it enforces consistent behavior — but adds indirection that may complicate debugging

---

### Plugin Lifecycle Diagram

<svg viewBox="0 0 720 460" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="720" height="460" fill="#0f1117" rx="12"/>
<text x="360" y="28" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">SSE Plugin Patterns — Responsibility Layering</text>
<!-- Pattern 1 -->
<rect x="30" y="50" width="300" height="370" rx="8" fill="#0f172a" stroke="#334155" stroke-width="1"/>
<text x="180" y="75" text-anchor="middle" fill="#7dd3fc" font-size="12" font-weight="bold">Pattern 1 — Thin Decorator</text>
<rect x="55" y="90" width="250" height="40" rx="5" fill="#1e293b" stroke="#7dd3fc" stroke-width="1"/>
<text x="180" y="106" text-anchor="middle" fill="#7dd3fc" font-size="11">fastify-plugin</text>
<text x="180" y="121" text-anchor="middle" fill="#94a3b8" font-size="10">decorateReply('sse') + formatEvent()</text>
<line x1="180" y1="130" x2="180" y2="155" stroke="#475569" stroke-width="1" marker-end="url(#arr)"/>
<rect x="55" y="155" width="250" height="40" rx="5" fill="#1e293b" stroke="#86efac" stroke-width="1"/>
<text x="180" y="171" text-anchor="middle" fill="#86efac" font-size="11">Route Handler</text>
<text x="180" y="186" text-anchor="middle" fill="#94a3b8" font-size="10">calls reply.sse(event)</text>
<line x1="180" y1="195" x2="180" y2="220" stroke="#475569" stroke-width="1" marker-end="url(#arr)"/>
<rect x="55" y="220" width="250" height="40" rx="5" fill="#1e293b" stroke="#fbbf24" stroke-width="1"/>
<text x="180" y="236" text-anchor="middle" fill="#fbbf24" font-size="11">Route: Interval / Timer</text>
<text x="180" y="251" text-anchor="middle" fill="#94a3b8" font-size="10">setInterval managed in route</text>
<line x1="180" y1="260" x2="180" y2="285" stroke="#475569" stroke-width="1" marker-end="url(#arr)"/>
<rect x="55" y="285" width="250" height="40" rx="5" fill="#1e293b" stroke="#f87171" stroke-width="1"/>
<text x="180" y="301" text-anchor="middle" fill="#f87171" font-size="11">Route: Cleanup</text>
<text x="180" y="316" text-anchor="middle" fill="#94a3b8" font-size="10">request.raw.on('close', ...)</text>
<line x1="180" y1="325" x2="180" y2="350" stroke="#475569" stroke-width="1" marker-end="url(#arr)"/>
<rect x="55" y="350" width="250" height="40" rx="5" fill="#1e293b" stroke="#f9a8d4" stroke-width="1"/>
<text x="180" y="366" text-anchor="middle" fill="#f9a8d4" font-size="11">reply.raw</text>
<text x="180" y="381" text-anchor="middle" fill="#94a3b8" font-size="10">Node.js ServerResponse</text>
<!-- Pattern 2 -->
<rect x="390" y="50" width="300" height="370" rx="8" fill="#0f172a" stroke="#334155" stroke-width="1"/>
<text x="540" y="75" text-anchor="middle" fill="#7dd3fc" font-size="12" font-weight="bold">Pattern 2 — Stream Manager</text>
<rect x="415" y="90" width="250" height="40" rx="5" fill="#1e293b" stroke="#7dd3fc" stroke-width="1"/>
<text x="540" y="106" text-anchor="middle" fill="#7dd3fc" font-size="11">fastify-plugin</text>
<text x="540" y="121" text-anchor="middle" fill="#94a3b8" font-size="10">decorateReply('sseStream')</text>
<line x1="540" y1="130" x2="540" y2="155" stroke="#475569" stroke-width="1" marker-end="url(#arr)"/>
<rect x="415" y="155" width="250" height="55" rx="5" fill="#1e293b" stroke="#a78bfa" stroke-width="1"/>
<text x="540" y="173" text-anchor="middle" fill="#a78bfa" font-size="11">Stream Object (plugin-managed)</text>
<text x="540" y="188" text-anchor="middle" fill="#94a3b8" font-size="10">send() · onClose() · destroyed</text>
<text x="540" y="202" text-anchor="middle" fill="#94a3b8" font-size="10">keepalive · cleanup registry</text>
<line x1="540" y1="210" x2="540" y2="235" stroke="#475569" stroke-width="1" marker-end="url(#arr)"/>
<rect x="415" y="235" width="250" height="40" rx="5" fill="#1e293b" stroke="#86efac" stroke-width="1"/>
<text x="540" y="251" text-anchor="middle" fill="#86efac" font-size="11">Route Handler</text>
<text x="540" y="266" text-anchor="middle" fill="#94a3b8" font-size="10">stream.send() · stream.onClose()</text>
<line x1="540" y1="275" x2="540" y2="300" stroke="#475569" stroke-width="1" marker-end="url(#arr)"/>
<rect x="415" y="300" width="250" height="40" rx="5" fill="#1e293b" stroke="#fbbf24" stroke-width="1"/>
<text x="540" y="316" text-anchor="middle" fill="#fbbf24" font-size="11">Route: Interval / Timer</text>
<text x="540" y="331" text-anchor="middle" fill="#94a3b8" font-size="10">registered via stream.onClose()</text>
<line x1="540" y1="340" x2="540" y2="365" stroke="#475569" stroke-width="1" marker-end="url(#arr)"/>
<rect x="415" y="365" width="250" height="40" rx="5" fill="#1e293b" stroke="#f9a8d4" stroke-width="1"/>
<text x="540" y="381" text-anchor="middle" fill="#f9a8d4" font-size="11">reply.raw</text>
<text x="540" y="396" text-anchor="middle" fill="#94a3b8" font-size="10">Node.js ServerResponse</text>
<defs>
<marker id="arr" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#475569"/>
</marker>
</defs>
</svg>

---

### Choosing Between Community Plugin and Custom Plugin

| Consideration | `fastify-sse-v2` | Custom Plugin |
| --- | --- | --- |
| Setup time | Minimal | Moderate |
| Maintenance burden | External dependency | Internal ownership |
| Async iterable support | Built-in | Must implement |
| Keepalive control | [Unverified] check docs | Full control |
| Custom header logic | Limited | Full control |
| Audit surface | Third-party code | Your code |
| Compatibility guarantees | [Unverified] check repo | Tied to your Fastify version |

**Key Points:**

- [Inference] For rapid prototyping or small projects, `fastify-sse-v2` reduces boilerplate significantly
- [Inference] For production systems with specific security, observability, or scaling requirements, a custom plugin avoids opaque third-party behavior
- Always verify that any community plugin is compatible with your exact Fastify major version before adopting it

---

**Related Topics:**

- Broadcasting SSE to multiple clients (client registry pattern)
- Redis pub/sub integration for SSE fan-out across Fastify instances
- SSE authentication patterns (JWT, cookies, per-route guards)
- Testing SSE routes in Fastify (`fastify.inject` limitations, integration tests)
- Async generators as SSE event sources
- Backpressure and flow control with Node.js Writable streams
- HTTP/2 multiplexing and SSE in Fastify
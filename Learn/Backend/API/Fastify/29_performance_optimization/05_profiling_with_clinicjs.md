## Profiling with Clinic.js

Clinic.js is a suite of Node.js performance profiling tools developed by NearForm. It diagnoses performance problems that are difficult to identify from metrics alone — event loop delays, CPU hotspots, I/O bottlenecks, and memory pressure. Fastify's tight integration with Node.js internals makes it an appropriate target for Clinic.js analysis.

---

### What Clinic.js Is

Clinic.js is not a single tool — it is a collection of specialized diagnostic tools, each targeting a different class of performance problem:

| Tool | Diagnoses | Mechanism |
|---|---|---|
| `clinic doctor` | General health: event loop lag, CPU, memory, I/O imbalance | Sampling + heuristics |
| `clinic flame` | CPU hotspots and call stack bottlenecks | V8 sampling profiler + flame graph |
| `clinic bubbles` | Async operation patterns and I/O bottlenecks | Async hooks instrumentation |
| `clinic heapprofiler` | Memory allocation hotspots | V8 heap sampling profiler |

Each tool wraps a Node.js process, instruments it during a load test, and produces an interactive HTML report.

---

### Installing Clinic.js

```bash
npm install -g clinic
npm install -g autocannon  # load generator used alongside Clinic.js
```

Verify installation:

```bash
clinic --version
autocannon --version
```

---

### Basic Workflow

The general pattern for all Clinic.js tools is:

1. Start the Fastify application under the Clinic.js wrapper
2. Apply load using `autocannon` or another load generator while the process runs
3. Stop the process — Clinic.js processes collected data and generates a report

```bash
# Terminal 1: start app under clinic doctor
clinic doctor -- node server.js

# Terminal 2: apply load
autocannon -c 100 -d 30 http://localhost:3000/api/users

# Terminal 1: press Ctrl+C to stop — report generates automatically
```

The report opens in the default browser as a self-contained HTML file saved to `.clinic/`.

---

### clinic doctor

`clinic doctor` is the recommended starting point. It collects a broad set of metrics simultaneously and applies heuristics to identify which category of problem is most likely present.

```bash
clinic doctor -- node server.js
```

#### What It Measures

- **Event loop delay** — how long the event loop is delayed beyond its expected tick interval
- **CPU usage** — percentage of time spent executing JavaScript
- **Memory usage** — heap used, heap total, external, RSS over time
- **Active handles and requests** — open sockets, timers, and pending async operations

#### Reading the Doctor Report

The report presents four timeline panels. Clinic.js overlays a diagnosis panel with recommended next steps.

```
┌─────────────────────────────────────────────────────┐
│  Event Loop Delay  ████████████░░░░░░░░░░░░░░░░░░░  │  ← spike = blocking work
│  CPU               ████░░░████░░░████░░░████░░░░░░  │  ← consistent = normal
│  Memory            ████████████████████████████████  │  ← linear growth = leak
│  Handles           ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  ← high = connection leak
└─────────────────────────────────────────────────────┘
```

**Key Points:**
- A sustained spike in event loop delay with moderate CPU suggests synchronous blocking
- CPU near 100% with low event loop delay suggests compute-bound work — use `clinic flame`
- Monotonically growing memory with flat CPU suggests a memory leak — use `clinic heapprofiler`
- High handle count that does not decrease suggests connection or timer leaks

---

### clinic flame

`clinic flame` produces a flame graph from V8's CPU sampling profiler. It shows which functions are consuming the most CPU time and how they are called.

```bash
clinic flame -- node server.js
```

Apply load as before, then stop the process.

#### Reading a Flame Graph

```
Wide bar at bottom  = hot function consuming significant CPU
Tall stacks         = deep call chains
Flat top stacks     = leaf functions where CPU time is actually spent
```

Each bar represents a function. Width represents the proportion of CPU samples taken while that function was on the call stack. Color indicates whether the frame is Node.js core (grey), V8 internals (dark), or application code (colored).

**Common patterns in Fastify applications:**

```
Wide bar: JSON.stringify
→ Response schema is missing on a high-traffic route

Wide bar: ajv/compile or ajv/validate
→ Schema being compiled inside a handler instead of at startup

Wide bar: bcrypt or crypto operation
→ Synchronous cryptography in a preHandler hook on every request

Wide bar: RegExp execution
→ Complex regex in route matching or request parsing
```

#### Filtering Flame Graphs

Clinic.js flame graphs support text search and filtering. To isolate application code:
- Filter by filename (exclude `node_modules` to focus on application frames)
- Use the merge toggle to collapse recursive calls
- Click a frame to zoom into that subtree

---

### clinic bubbles

`clinic bubbles` instruments Node.js async hooks to visualize async operation patterns. It is particularly useful for identifying I/O bottlenecks and unexpected async operation behavior.

```bash
clinic bubbles -- node server.js
```

#### What Bubbles Shows

Each circle (bubble) represents an async operation type. Size indicates how many async operations of that type existed during the profile. Color and position indicate timing patterns.

**Patterns to look for:**

- Large `TCPWRAP` bubble — many open TCP connections (possible connection leak or pool exhaustion)
- Large `Timeout` bubble — many pending timers (possible runaway `setTimeout` usage)
- Large `PROMISE` bubble — many unresolved promises (possible async chain bottleneck)
- Isolated `DNSCACHELOOKUP` bubble — DNS resolution on every outbound request (missing DNS caching)

**Key Points:**
- Bubbles is most useful after Doctor identifies an I/O imbalance
- It does not show CPU time — combine with flame for CPU + async analysis
- Async hook instrumentation adds overhead; bubbles results reflect behavior under instrumentation, not bare performance [Inference: overhead magnitude depends on async operation volume; high async-hook density may distort timing measurements]

---

### clinic heapprofiler

`clinic heapprofiler` uses V8's heap sampling profiler to identify which code paths are allocating the most memory. It is the right tool when Doctor shows monotonically growing heap usage.

```bash
clinic heapprofiler -- node server.js
```

#### Reading the Heap Profile

The output is a flame graph ordered by allocation size rather than CPU time. Wide bars represent allocation hotspots.

**Common allocation hotspots in Fastify applications:**

```
Wide bar: Object spread ({ ...obj })
→ Per-request object spreading in handlers or hooks

Wide bar: Array.prototype.map / filter
→ Creating new arrays on every request from large datasets

Wide bar: JSON.parse
→ Parsing large bodies or cached JSON strings on every request

Wide bar: String concatenation
→ Building response strings manually instead of using compiled serializer
```

---

### Setting Up a Fastify App for Profiling

To get accurate profiles, the application must be run in a realistic configuration. A minimal profiling entry point:

```ts
// server.js — profiling entry point
import Fastify from 'fastify';
import appPlugin from './src/app.js';

const fastify = Fastify({
  logger: false, // disable logging during profiling to isolate app cost
});

await fastify.register(appPlugin);

await fastify.listen({ port: 3000, host: '0.0.0.0' });
```

**Key Points:**
- Disable logging during profiling runs to avoid measuring log I/O instead of application logic [Inference: logging should be re-enabled for production; disabling is for profiling isolation only]
- Use `host: '0.0.0.0'` to accept connections from the load generator if running on a separate machine or in Docker
- Run `NODE_ENV=production` to match production behavior (some libraries behave differently in development mode)

---

### Running a Full Doctor Diagnosis

```bash
# Start under clinic doctor
NODE_ENV=production clinic doctor -- node server.js

# In a separate terminal, warm up then apply sustained load
autocannon -c 50 -d 5 http://localhost:3000/api/users   # warm-up
autocannon -c 100 -d 30 http://localhost:3000/api/users  # profiling load

# Stop the server (Ctrl+C)
# Report opens at .clinic/<pid>.clinic-doctor/
```

Autocannon options:
- `-c` — number of concurrent connections
- `-d` — duration in seconds
- `-p` — pipelining factor (requests per connection without waiting)
- `--latency` — report latency percentiles

---

### Running a Flame Graph Analysis

```bash
clinic flame -- node server.js
```

```bash
autocannon -c 100 -d 20 http://localhost:3000/api/orders
```

Stop the server. The flame graph renders in the browser. To find Fastify-specific hotspots:

1. Search for `serialize` — identifies serialization time
2. Search for `validate` — identifies validation time
3. Search for handler function names — identifies application logic cost
4. Search for `JSON` — identifies JSON.parse or JSON.stringify usage

---

### Profiling Workflow Diagram

<svg viewBox="0 0 700 380" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#64748b"/>
    </marker>
  </defs>

  <!-- Start -->
  <rect x="270" y="20" width="160" height="44" rx="7" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="350" y="42" text-anchor="middle" fill="#38bdf8" font-weight="bold">clinic doctor</text>
  <text x="350" y="57" text-anchor="middle" fill="#94a3b8">broad diagnosis</text>
  <line x1="350" y1="64" x2="350" y2="100" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>

  <!-- Decision -->
  <polygon points="350,100 470,145 350,190 230,145" fill="#1e293b" stroke="#f472b6" stroke-width="1.5"/>
  <text x="350" y="140" text-anchor="middle" fill="#f472b6" font-size="11" font-weight="bold">Primary</text>
  <text x="350" y="156" text-anchor="middle" fill="#f472b6" font-size="11" font-weight="bold">symptom?</text>

  <!-- CPU branch -->
  <line x1="470" y1="145" x2="590" y2="145" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <text x="530" y="138" text-anchor="middle" fill="#94a3b8" font-size="11">High CPU</text>
  <rect x="590" y="118" width="90" height="54" rx="7" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="635" y="140" text-anchor="middle" fill="#4ade80" font-weight="bold">flame</text>
  <text x="635" y="158" text-anchor="middle" fill="#94a3b8" font-size="11">CPU hotspots</text>

  <!-- Memory branch -->
  <line x1="230" y1="145" x2="110" y2="145" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <text x="170" y="138" text-anchor="middle" fill="#94a3b8" font-size="11">Memory</text>
  <rect x="20" y="118" width="90" height="54" rx="7" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
  <text x="65" y="140" text-anchor="middle" fill="#fbbf24" font-weight="bold">heapprofiler</text>
  <text x="65" y="158" text-anchor="middle" fill="#94a3b8" font-size="11">allocations</text>

  <!-- I/O branch -->
  <line x1="350" y1="190" x2="350" y2="240" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <text x="380" y="220" text-anchor="middle" fill="#94a3b8" font-size="11">I/O lag</text>
  <rect x="270" y="240" width="160" height="54" rx="7" fill="#1e293b" stroke="#c084fc" stroke-width="1.5"/>
  <text x="350" y="262" text-anchor="middle" fill="#c084fc" font-weight="bold">bubbles</text>
  <text x="350" y="280" text-anchor="middle" fill="#94a3b8" font-size="11">async patterns</text>

  <!-- Report -->
  <line x1="635" y1="172" x2="635" y2="320" stroke="#64748b" stroke-width="1"/>
  <line x1="65" y1="172" x2="65" y2="320" stroke="#64748b" stroke-width="1"/>
  <line x1="350" y1="294" x2="350" y2="320" stroke="#64748b" stroke-width="1"/>
  <line x1="65" y1="320" x2="635" y2="320" stroke="#64748b" stroke-width="1"/>
  <line x1="350" y1="320" x2="350" y2="340" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>

  <rect x="220" y="340" width="260" height="30" rx="7" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="350" y="360" text-anchor="middle" fill="#38bdf8" font-weight="bold">HTML Report + Fix</text>
</svg>

---

### Interpreting Common Fastify-Specific Findings

#### Finding: Event Loop Delay Spikes Correlated With Request Peaks

**Likely cause:** Synchronous work in a handler or hook — body parsing of large payloads, synchronous crypto, regex on large strings, or synchronous file I/O.

**Diagnosis:** Run `clinic flame` and look for synchronous functions (no async frames above them) with wide bars.

**Fix:** Move CPU-bound work to worker threads; replace synchronous calls with async equivalents.

---

#### Finding: High CPU in JSON.stringify

**Likely cause:** One or more high-traffic routes are missing response schemas.

**Diagnosis:** In the flame graph, `JSON.stringify` appearing wide in the application subtree confirms the fallback path is being used.

**Fix:** Add `schema.response` to every high-traffic route.

---

#### Finding: Monotonically Growing Heap

**Likely cause:** Objects being retained — event listeners not removed, caches without eviction, closures holding references, or `Map`/`Set` growing without bounds.

**Diagnosis:** Run `clinic heapprofiler` and identify the allocation site. Cross-reference with `clinic doctor`'s handle count — rising handles alongside memory growth suggests a connection or listener leak.

**Fix:** Audit event listener registration (ensure `removeListener` is called), add LRU eviction to caches, check for closures in hooks capturing outer scope references.

---

#### Finding: Large TCPWRAP Bubble in Bubbles

**Likely cause:** HTTP connections to downstream services are not being reused (no keep-alive or connection pooling), or upstream clients are not closing connections.

**Fix:** Use a connection pool for outbound HTTP (`undici` with a `Pool` instance); ensure database clients reuse connections.

---

### Profiling in Docker

Clinic.js requires write access to the current directory to save `.clinic/` output. When profiling inside Docker:

```dockerfile
# Dockerfile.profile
FROM node:22-alpine
WORKDIR /app
COPY . .
RUN npm ci
# Ensure clinic output directory is writable
RUN mkdir -p .clinic && chmod 777 .clinic
CMD ["node", "--inspect", "server.js"]
```

```bash
docker run -p 3000:3000 -v $(pwd)/.clinic:/app/.clinic my-app-profile
```

The `.clinic/` directory is mounted as a volume so reports are accessible on the host after the container stops. [Inference: volume mount behavior depends on Docker version and platform; path syntax differs on Windows]

---

### Continuous Performance Regression Detection

Rather than profiling only when problems appear, integrate load testing into CI to catch regressions early.

```bash
# ci-perf.sh
#!/bin/bash
set -e

node server.js &
SERVER_PID=$!
sleep 2  # wait for server to start

# Run load test and capture results
autocannon -c 50 -d 10 --json http://localhost:3000/api/users > results.json

kill $SERVER_PID

# Check p99 latency threshold
P99=$(node -e "const r = require('./results.json'); console.log(r.latency.p99)")
THRESHOLD=100  # ms

if [ "$P99" -gt "$THRESHOLD" ]; then
  echo "FAIL: p99 latency ${P99}ms exceeds threshold ${THRESHOLD}ms"
  exit 1
fi

echo "PASS: p99 latency ${P99}ms"
```

[Inference: threshold values are application-specific; the 100ms example is illustrative only]

---

### Clinic.js Tool Selection Reference

| Symptom from Doctor | Tool to use next | What to look for |
|---|---|---|
| Event loop delay spikes | `clinic flame` | Synchronous functions with wide bars |
| CPU consistently near 100% | `clinic flame` | Hot application functions |
| Heap growing without plateau | `clinic heapprofiler` | Allocation sites in application code |
| High handle count | `clinic bubbles` | TCPWRAP, Timer, or FSReqCallback bubbles |
| Erratic async timing | `clinic bubbles` | Irregular async operation distribution |
| Slow cold start | `clinic flame` | Plugin registration or schema compilation cost |

---

**Related Topics:**
- Flame graph interpretation: identifying V8 JIT deoptimizations
- Node.js `--prof` and `node --prof-process` for low-overhead CPU profiling
- `perf_hooks` and `PerformanceObserver` for custom in-process metrics
- Heap snapshot analysis with Chrome DevTools
- Autocannon advanced usage: pipelines, custom headers, POST body load testing
- OpenTelemetry tracing in Fastify for distributed performance visibility
- `@clinic/doctor` programmatic API for automated performance gating
- Memory leak patterns specific to Fastify plugin closures
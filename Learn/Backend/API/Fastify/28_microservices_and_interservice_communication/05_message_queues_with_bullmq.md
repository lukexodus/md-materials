## Message Queues with BullMQ

BullMQ is a Node.js library for building job queues and message queues backed by Redis. It is commonly used with Fastify to offload background work, decouple services, and handle asynchronous processing reliably.

---

### What BullMQ Is

BullMQ is the modern successor to Bull, built with TypeScript-first design and a cleaner API. It uses Redis as its persistence and coordination layer, storing job data, state, and results in Redis data structures.

**Key Points:**
- Jobs are added to named queues and processed by workers
- Redis handles durability, ordering, and distributed coordination
- BullMQ separates producers (which enqueue jobs) and consumers (workers that process them)
- Supports delayed jobs, repeatable jobs, priorities, rate limiting, and job dependencies

---

### Installing BullMQ

```bash
npm install bullmq
```

Redis must be available. For local development, a Docker instance is typical:

```bash
docker run -d -p 6379:6379 redis:7
```

---

### Core Concepts

#### Queue

A `Queue` instance represents a named channel where jobs are submitted. Producers use this to enqueue work.

```ts
import { Queue } from 'bullmq';

const emailQueue = new Queue('email', {
  connection: { host: '127.0.0.1', port: 6379 },
});
```

#### Worker

A `Worker` instance listens to a named queue and processes jobs as they arrive.

```ts
import { Worker } from 'bullmq';

const worker = new Worker('email', async (job) => {
  console.log('Processing job:', job.name, job.data);
  // perform work here
}, {
  connection: { host: '127.0.0.1', port: 6379 },
});
```

#### Job

A job is a unit of work with a name, payload (`data`), and options. Each job has an auto-assigned ID and progresses through states: `waiting → active → completed | failed`.

---

### Integrating BullMQ into Fastify

The recommended pattern is to register queues as Fastify decorators or plugins, making them available across the application via `fastify.queues` or similar.

#### Queue Plugin

```ts
// plugins/queues.ts
import fp from 'fastify-plugin';
import { Queue } from 'bullmq';

const redisConnection = { host: '127.0.0.1', port: 6379 };

async function queuesPlugin(fastify) {
  const emailQueue = new Queue('email', { connection: redisConnection });
  const reportQueue = new Queue('report', { connection: redisConnection });

  fastify.decorate('queues', {
    email: emailQueue,
    report: reportQueue,
  });

  fastify.addHook('onClose', async () => {
    await emailQueue.close();
    await reportQueue.close();
  });
}

export default fp(queuesPlugin);
```

#### Enqueuing a Job from a Route

```ts
// routes/users.ts
export async function userRoutes(fastify) {
  fastify.post('/register', async (request, reply) => {
    const { email, name } = request.body;

    // synchronous work: save user to DB
    const user = await fastify.db.users.create({ email, name });

    // async work: send welcome email via queue
    await fastify.queues.email.add('welcome', { userId: user.id, email });

    return reply.code(201).send({ id: user.id });
  });
}
```

The route returns immediately. The email is processed independently.

---

### Worker Setup

Workers are typically started in a separate process or file. This separation prevents CPU-bound or slow jobs from blocking the Fastify event loop.

```ts
// workers/emailWorker.ts
import { Worker, QueueEvents } from 'bullmq';

const connection = { host: '127.0.0.1', port: 6379 };

const worker = new Worker('email', async (job) => {
  if (job.name === 'welcome') {
    const { email, userId } = job.data;
    await sendWelcomeEmail(email, userId); // your email-sending logic
  }
}, { connection });

worker.on('completed', (job) => {
  console.log(`Job ${job.id} completed`);
});

worker.on('failed', (job, err) => {
  console.error(`Job ${job?.id} failed:`, err.message);
});
```

**Key Points:**
- Workers run independently — they do not need Fastify to be running
- Multiple worker instances can process the same queue concurrently
- BullMQ handles locking to prevent duplicate processing [Inference: based on documented Redis-based locking; actual behavior depends on Redis availability and configuration]

---

### Job Options

Jobs support a range of options at enqueue time.

```ts
await fastify.queues.email.add('welcome', { email }, {
  delay: 5000,          // wait 5s before making job available
  attempts: 3,          // retry up to 3 times on failure
  backoff: {
    type: 'exponential',
    delay: 1000,        // initial backoff delay in ms
  },
  removeOnComplete: 100, // keep last 100 completed jobs
  removeOnFail: 200,
  priority: 1,          // lower number = higher priority
});
```

---

### Repeatable Jobs

BullMQ supports cron-style repeatable jobs, useful for scheduled tasks.

```ts
await fastify.queues.report.add(
  'daily-summary',
  { type: 'daily' },
  {
    repeat: {
      cron: '0 8 * * *', // every day at 08:00
    },
  }
);
```

**Key Points:**
- Repeatable jobs are deduplicated by BullMQ using the job name and cron pattern
- They persist across restarts because the schedule is stored in Redis

---

### Job Dependencies and Flows

BullMQ's `FlowProducer` allows defining parent/child job relationships. A parent job completes only after all its children succeed.

```ts
import { FlowProducer } from 'bullmq';

const flow = new FlowProducer({ connection });

await flow.add({
  name: 'generate-report',
  queueName: 'report',
  data: { reportId: 42 },
  children: [
    { name: 'fetch-data', queueName: 'data', data: { source: 'db' } },
    { name: 'fetch-metrics', queueName: 'metrics', data: { range: '7d' } },
  ],
});
```

The `generate-report` job will not be promoted to active state until both child jobs have completed. [Inference: based on BullMQ's documented flow semantics; behavior subject to Redis state and BullMQ version]

---

### Monitoring Job State

BullMQ provides methods to inspect queue state programmatically.

```ts
const waiting = await fastify.queues.email.getWaitingCount();
const active = await fastify.queues.email.getActiveCount();
const failed = await fastify.queues.email.getFailedCount();

console.log({ waiting, active, failed });
```

You can expose this via a Fastify route for internal health monitoring:

```ts
fastify.get('/admin/queues/status', async () => {
  return {
    email: {
      waiting: await fastify.queues.email.getWaitingCount(),
      active: await fastify.queues.email.getActiveCount(),
      failed: await fastify.queues.email.getFailedCount(),
    },
  };
});
```

---

### QueueEvents: Listening for Lifecycle Events

`QueueEvents` subscribes to Redis-based events for a queue without running a worker. Useful for logging, metrics, or notifications.

```ts
import { QueueEvents } from 'bullmq';

const emailEvents = new QueueEvents('email', { connection });

emailEvents.on('completed', ({ jobId }) => {
  console.log(`Email job ${jobId} completed`);
});

emailEvents.on('failed', ({ jobId, failedReason }) => {
  console.error(`Email job ${jobId} failed: ${failedReason}`);
});
```

---

### Error Handling and Retries

When a worker throws an error, BullMQ marks the job as failed. If `attempts` > 1, it will be retried according to the backoff strategy.

```ts
const worker = new Worker('email', async (job) => {
  if (!job.data.email) {
    throw new Error('Missing email address'); // will trigger retry/failure
  }
  await sendEmail(job.data.email);
}, { connection });
```

Jobs that exhaust all retry attempts land in the `failed` state and remain in Redis until manually removed or auto-pruned via `removeOnFail`.

---

### Architecture Diagram

<svg viewBox="0 0 740 300" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Fastify App -->
  <rect x="20" y="100" width="160" height="100" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="100" y="130" text-anchor="middle" fill="#38bdf8" font-size="12" font-weight="bold">Fastify App</text>
  <text x="100" y="150" text-anchor="middle" fill="#94a3b8" font-size="11">POST /register</text>
  <text x="100" y="168" text-anchor="middle" fill="#94a3b8" font-size="11">queue.add(job)</text>

  <!-- Arrow to Redis -->
  <line x1="180" y1="150" x2="270" y2="150" stroke="#38bdf8" stroke-width="1.5" marker-end="url(#arrow)"/>
  <text x="225" y="143" text-anchor="middle" fill="#94a3b8" font-size="11">enqueue</text>

  <!-- Redis -->
  <rect x="270" y="90" width="160" height="120" rx="8" fill="#1e293b" stroke="#f472b6" stroke-width="1.5"/>
  <text x="350" y="120" text-anchor="middle" fill="#f472b6" font-size="12" font-weight="bold">Redis</text>
  <text x="350" y="140" text-anchor="middle" fill="#94a3b8" font-size="11">Queue: email</text>
  <text x="350" y="158" text-anchor="middle" fill="#94a3b8" font-size="11">Jobs: waiting</text>
  <text x="350" y="176" text-anchor="middle" fill="#94a3b8" font-size="11">active / failed</text>

  <!-- Arrow to Worker -->
  <line x1="430" y1="150" x2="520" y2="150" stroke="#38bdf8" stroke-width="1.5" marker-end="url(#arrow)"/>
  <text x="475" y="143" text-anchor="middle" fill="#94a3b8" font-size="11">poll / dequeue</text>

  <!-- Worker -->
  <rect x="520" y="100" width="180" height="100" rx="8" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="610" y="130" text-anchor="middle" fill="#4ade80" font-size="12" font-weight="bold">Worker Process</text>
  <text x="610" y="150" text-anchor="middle" fill="#94a3b8" font-size="11">emailWorker.ts</text>
  <text x="610" y="168" text-anchor="middle" fill="#94a3b8" font-size="11">sendWelcomeEmail()</text>

  <!-- Arrow marker -->
  <defs>
    <marker id="arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#38bdf8"/>
    </marker>
  </defs>

  <!-- Labels -->
  <text x="370" y="260" text-anchor="middle" fill="#475569" font-size="11">Fastify enqueues → Redis persists → Worker processes independently</text>
</svg>

---

### Graceful Shutdown

Workers and queues must be closed cleanly to avoid orphaned jobs or open Redis connections.

```ts
// In your worker process
process.on('SIGTERM', async () => {
  await worker.close();
  process.exit(0);
});

// In Fastify (via onClose hook, as shown in the plugin above)
fastify.addHook('onClose', async () => {
  await emailQueue.close();
});
```

`worker.close()` waits for the currently active job to finish before shutting down. [Inference: based on BullMQ documentation behavior; actual drain behavior depends on whether `force` option is passed]

---

### Sandboxed Workers

For CPU-intensive jobs, BullMQ supports sandboxed processors — workers that run each job in a separate child process to isolate failures and avoid blocking.

```ts
import path from 'path';

const worker = new Worker('image-resize', path.resolve('./processors/imageResize.js'), {
  connection,
  useWorkerThreads: false, // uses child_process by default
});
```

The processor file must export a default async function:

```ts
// processors/imageResize.js
export default async function (job) {
  const { filePath } = job.data;
  await resizeImage(filePath);
}
```

---

### Common Patterns in Microservice Architectures

| Pattern | BullMQ Role |
|---|---|
| Fire-and-forget | Route enqueues job, returns immediately |
| Work offloading | Heavy tasks run in isolated worker processes |
| Scheduled tasks | Repeatable jobs replace cron daemons |
| Event fan-out | Multiple workers consume from different queues triggered by one producer |
| Rate-limited processing | Worker `limiter` option controls throughput |

---

**Related Topics:**
- BullMQ rate limiting and concurrency controls
- Bull Board or Arena for queue UI dashboards
- Using BullMQ with Fastify in a monorepo (shared queue definitions)
- Dead letter queues and failed job reprocessing strategies
- Redis Sentinel and Cluster support in BullMQ
- Job progress reporting with `job.updateProgress()`
- Combining BullMQ with Fastify event bus patterns
- BullMQ Flows for complex multi-step pipelines
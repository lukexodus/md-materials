## gRPC Integration

### What is gRPC

gRPC is a high-performance, contract-first remote procedure call framework developed by Google. It uses Protocol Buffers (protobuf) as its interface definition language (IDL) and wire format, and HTTP/2 as its transport. In a Fastify microservices architecture, gRPC is used for low-latency, high-throughput inter-service communication where HTTP/JSON overhead is a concern.

Fastify does not natively speak gRPC — it is an HTTP/1.1 and HTTP/2 server. gRPC integration is achieved by running a gRPC server alongside Fastify, or by using Fastify as an HTTP gateway that calls gRPC backends.

**Key Points**

- gRPC uses HTTP/2 exclusively — it cannot run over HTTP/1.1
- Protocol Buffers define the service contract: message types, field names, and RPC signatures are all declared in `.proto` files
- Code generation from `.proto` files produces typed client and server stubs
- Four communication patterns are supported: unary, server streaming, client streaming, and bidirectional streaming
- [Inference] gRPC is most beneficial when payload size, serialization speed, or strict schema contracts are primary concerns; for most internal services, HTTP/JSON is simpler and sufficient

---

### gRPC Communication Patterns

| Pattern | Client Sends | Server Sends | Use Case |
| --- | --- | --- | --- |
| **Unary** | One message | One message | Standard request/response |
| **Server streaming** | One message | Stream of messages | Live feeds, large result sets |
| **Client streaming** | Stream of messages | One message | Bulk upload, aggregation |
| **Bidirectional streaming** | Stream of messages | Stream of messages | Chat, real-time collaboration |

---

### Installing Dependencies

bash

```bash
# gRPC runtime and protobuf support
npm install @grpc/grpc-js @grpc/proto-loader

# Optional: code generation from .proto files
npm install --save-dev grpc-tools protoc-gen-ts
```

**Key Points**

- `@grpc/grpc-js` is the pure JavaScript gRPC implementation — it replaces the older `grpc` native addon
- `@grpc/proto-loader` loads `.proto` files at runtime without a code generation step — convenient for development
- Code generation (via `grpc-tools`) produces TypeScript or JavaScript stubs with full type information — preferred for production

---

### Defining the Proto Contract

protobuf

```protobuf
// proto/users.proto
syntax = "proto3";

package users;

service UserService {
  rpc GetUser (GetUserRequest) returns (User);
  rpc GetUsersByIds (GetUsersByIdsRequest) returns (GetUsersByIdsResponse);
  rpc WatchUser (GetUserRequest) returns (stream UserEvent);
  rpc CreateUsers (stream CreateUserRequest) returns (CreateUsersResponse);
}

message GetUserRequest {
  string id = 1;
}

message GetUsersByIdsRequest {
  repeated string ids = 1;
}

message GetUsersByIdsResponse {
  repeated User users = 1;
}

message User {
  string id = 1;
  string name = 2;
  string email = 3;
  string role = 4;
  int64 created_at = 5;
}

message UserEvent {
  string event_type = 1;
  User user = 2;
  int64 timestamp = 3;
}

message CreateUserRequest {
  string name = 1;
  string email = 2;
  string role = 3;
}

message CreateUsersResponse {
  int32 created_count = 1;
  repeated User users = 2;
}
```

**Key Points**

- Field numbers (`: 1`, `: 2`) are the wire identifiers — they must never change once a service is deployed; changing them breaks binary compatibility
- `repeated` is the protobuf equivalent of an array
- `stream` in the RPC signature indicates a streaming half of the call
- `int64` maps to JavaScript `string` or `BigInt` depending on proto-loader configuration — verify this for your version [Inference]

---

### Running a gRPC Server Alongside Fastify

The gRPC server is a separate process or a separate server instance within the same process. Fastify handles HTTP traffic; gRPC handles RPC traffic on a different port.

js

```js
// grpc/server.js
import grpc from '@grpc/grpc-js'
import protoLoader from '@grpc/proto-loader'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))

const PROTO_PATH = resolve(__dirname, '../proto/users.proto')

const packageDef = protoLoader.loadSync(PROTO_PATH, {
  keepCase: true,          // Preserve field names as-is (snake_case)
  longs: String,           // Represent int64 as string
  enums: String,           // Represent enums as string names
  defaults: true,          // Populate default values for missing fields
  oneofs: true
})

const proto = grpc.loadPackageDefinition(packageDef)
const { UserService } = proto.users

// Service implementation
const implementation = {
  async getUser(call, callback) {
    try {
      const user = await db.getUserById(call.request.id)
      if (!user) {
        return callback({
          code: grpc.status.NOT_FOUND,
          message: `User ${call.request.id} not found`
        })
      }
      callback(null, user)
    } catch (err) {
      callback({
        code: grpc.status.INTERNAL,
        message: 'Internal server error'
      })
    }
  },

  async getUsersByIds(call, callback) {
    try {
      const users = await db.getUsersByIds(call.request.ids)
      callback(null, { users })
    } catch (err) {
      callback({
        code: grpc.status.INTERNAL,
        message: 'Internal server error'
      })
    }
  }
}

export function startGrpcServer(port = 50051) {
  const server = new grpc.Server()
  server.addService(UserService.service, implementation)

  server.bindAsync(
    `0.0.0.0:${port}`,
    grpc.ServerCredentials.createInsecure(), // TLS covered separately below
    (err, boundPort) => {
      if (err) throw err
      console.log(`gRPC server listening on port ${boundPort}`)
      server.start()
    }
  )

  return server
}
```

js

```js
// app.js — start both Fastify and gRPC
import Fastify from 'fastify'
import { startGrpcServer } from './grpc/server.js'

const app = Fastify({ logger: true })

// Fastify HTTP routes
app.get('/health', async () => ({ status: 'ok' }))

// Start gRPC on a separate port
const grpcServer = startGrpcServer(50051)

// Graceful shutdown of both servers
app.addHook('onClose', async () => {
  await new Promise((resolve, reject) => {
    grpcServer.tryShutdown((err) => err ? reject(err) : resolve())
  })
})

await app.listen({ port: 3000 })
```

**Key Points**

- `grpc.ServerCredentials.createInsecure()` disables TLS — acceptable inside a private cluster network; never use on a public interface
- `tryShutdown` waits for in-flight RPCs to complete before stopping; `forceShutdown` aborts immediately
- The gRPC server and Fastify share the same Node.js event loop — a CPU-intensive RPC handler can affect Fastify response times [Inference]

---

### Unary RPC: Server Implementation Detail

js

```js
// Unary handler signature: (call, callback)
async function getUser(call, callback) {
  // call.request — the deserialized request message
  // call.metadata — gRPC metadata (analogous to HTTP headers)
  // callback(error, response) — send response or error

  const requestId = call.metadata.get('x-request-id')[0]

  const user = await db.getUserById(call.request.id)

  if (!user) {
    return callback({
      code: grpc.status.NOT_FOUND,
      details: `User ${call.request.id} not found`,
      metadata: new grpc.Metadata()
    })
  }

  callback(null, {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    created_at: String(user.created_at.getTime())
  })
}
```

**Key Points**

- `callback` follows Node.js error-first convention: `callback(null, result)` for success, `callback(error)` for failure
- gRPC status codes are distinct from HTTP status codes — `grpc.status.NOT_FOUND` (5) is not HTTP 404, though they represent the same semantic
- gRPC metadata is the equivalent of HTTP headers — attach via `call.metadata` on the server, `call.sendMetadata(meta)` for response metadata

---

### gRPC Status Codes Reference

| Code | Name | HTTP Equivalent | Meaning |
| --- | --- | --- | --- |
| 0 | OK | 200 | Success |
| 1 | CANCELLED | — | Client cancelled |
| 2 | UNKNOWN | 500 | Unknown error |
| 3 | INVALID_ARGUMENT | 400 | Bad request data |
| 4 | DEADLINE_EXCEEDED | 504 | Timeout |
| 5 | NOT_FOUND | 404 | Resource missing |
| 6 | ALREADY_EXISTS | 409 | Conflict |
| 7 | PERMISSION_DENIED | 403 | Forbidden |
| 8 | RESOURCE_EXHAUSTED | 429 | Rate limited |
| 12 | UNIMPLEMENTED | 501 | Method not implemented |
| 13 | INTERNAL | 500 | Internal error |
| 14 | UNAVAILABLE | 503 | Service unavailable |
| 16 | UNAUTHENTICATED | 401 | Missing or invalid credentials |

---

### Server Streaming RPC

js

```js
// proto: rpc WatchUser (GetUserRequest) returns (stream UserEvent)

function watchUser(call) {
  // call is a writable stream — no callback
  const userId = call.request.id

  // Send an initial snapshot
  call.write({
    event_type: 'SNAPSHOT',
    user: currentUserState(userId),
    timestamp: String(Date.now())
  })

  // Subscribe to change events
  const unsubscribe = userEvents.on(`user:${userId}`, (event) => {
    if (call.cancelled) {
      unsubscribe()
      return
    }
    call.write({
      event_type: event.type,
      user: event.user,
      timestamp: String(Date.now())
    })
  })

  // Client disconnects or deadline exceeded
  call.on('cancelled', () => {
    unsubscribe()
  })

  call.on('error', (err) => {
    unsubscribe()
    console.error('Stream error:', err)
  })
}
```

**Key Points**

- `call.write(message)` sends one message in the stream — can be called multiple times
- `call.end()` closes the server side of the stream — omitting it leaves the stream open indefinitely
- `call.cancelled` and the `cancelled` event signal client disconnection — always clean up subscriptions and resources
- Back-pressure: if the client cannot consume messages fast enough, `call.write()` may block [Inference — behavior depends on HTTP/2 flow control and grpc-js internals]

---

### Client Streaming RPC

js

```js
// proto: rpc CreateUsers (stream CreateUserRequest) returns (CreateUsersResponse)

function createUsers(call, callback) {
  const created = []

  call.on('data', async (createRequest) => {
    // Each message from the client stream
    const user = await db.createUser(createRequest)
    created.push(user)
  })

  call.on('end', () => {
    // Client has finished sending — send the single response
    callback(null, {
      created_count: created.length,
      users: created
    })
  })

  call.on('error', (err) => {
    callback({
      code: grpc.status.INTERNAL,
      message: err.message
    })
  })
}
```

**Key Points**

- `call` is a readable stream — listen to `data`, `end`, and `error` events
- `callback` is called exactly once — only after `end` is received from the client
- Async handlers in `data` events require careful ordering — `await` inside `data` does not pause the stream; use a queue or collect and process in `end` if ordering matters [Inference]

---

### Bidirectional Streaming RPC

js

```js
// proto: rpc Chat (stream ChatMessage) returns (stream ChatMessage)

function chat(call) {
  const sessionId = call.metadata.get('session-id')[0]

  call.on('data', (message) => {
    // Echo back with server timestamp
    call.write({
      sender: 'server',
      content: `Echo: ${message.content}`,
      timestamp: String(Date.now())
    })
  })

  call.on('end', () => {
    call.end()
  })

  call.on('error', (err) => {
    console.error(`Bidi stream error [${sessionId}]:`, err)
  })
}
```

---

### gRPC Client in Fastify

Fastify services call other gRPC services using generated client stubs:

js

```js
// plugins/grpcClients.js
import fp from 'fastify-plugin'
import grpc from '@grpc/grpc-js'
import protoLoader from '@grpc/proto-loader'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'
import { promisify } from 'util'

const __dirname = dirname(fileURLToPath(import.meta.url))
const PROTO_PATH = resolve(__dirname, '../proto/users.proto')

async function grpcClientsPlugin(app, opts) {
  const packageDef = protoLoader.loadSync(PROTO_PATH, {
    keepCase: true,
    longs: String,
    enums: String,
    defaults: true,
    oneofs: true
  })

  const proto = grpc.loadPackageDefinition(packageDef)
  const { UserService } = proto.users

  // Create client — one per target service
  const usersClient = new UserService(
    process.env.USERS_GRPC_ADDR ?? 'users-service:50051',
    grpc.credentials.createInsecure()
  )

  // Promisify unary methods for async/await usage
  const getUser = promisify(usersClient.getUser.bind(usersClient))
  const getUsersByIds = promisify(usersClient.getUsersByIds.bind(usersClient))

  app.decorate('grpc', {
    users: {
      getUser: async (id, metadata = new grpc.Metadata()) => {
        return getUser({ id }, metadata)
      },
      getUsersByIds: async (ids, metadata = new grpc.Metadata()) => {
        return getUsersByIds({ ids }, metadata)
      },
      // Streaming methods returned as-is — promisify does not apply
      watchUser: (id, metadata = new grpc.Metadata()) => {
        return usersClient.watchUser({ id }, metadata)
      }
    }
  })

  app.addHook('onClose', async () => {
    usersClient.close()
  })
}

export default fp(grpcClientsPlugin)
```

js

```js
// Using the gRPC client in a Fastify route
app.get('/orders/:id', async (request, reply) => {
  const order = await app.db.getOrder(request.params.id)

  const meta = new grpc.Metadata()
  meta.set('x-correlation-id', request.correlationId)

  const user = await app.grpc.users.getUser(order.userId, meta)

  return { order, user }
})
```

**Key Points**

- `promisify` works for unary methods only — streaming methods must use the event-based API
- The gRPC client maintains a connection pool internally — do not create a new client per request [Inference]
- `usersClient.close()` should be called on shutdown to drain in-flight calls and close connections
- gRPC metadata is the mechanism for forwarding correlation IDs, auth tokens, and other request-scoped data

---

### Forwarding Auth Tokens via Metadata

js

```js
// Attach JWT from Fastify request to outgoing gRPC metadata
app.get('/profile', async (request, reply) => {
  const meta = new grpc.Metadata()
  meta.set('authorization', request.headers.authorization ?? '')
  meta.set('x-correlation-id', request.correlationId)

  const user = await app.grpc.users.getUser(request.user.id, meta)
  return user
})
```

On the gRPC server, read and verify the token:

js

```js
async function getUser(call, callback) {
  const authHeader = call.metadata.get('authorization')[0] ?? ''

  if (!authHeader.startsWith('Bearer ')) {
    return callback({ code: grpc.status.UNAUTHENTICATED, message: 'Missing token' })
  }

  let claims
  try {
    claims = verifyJwt(authHeader.slice(7))
  } catch {
    return callback({ code: grpc.status.UNAUTHENTICATED, message: 'Invalid token' })
  }

  const user = await db.getUserById(call.request.id)
  callback(null, user)
}
```

---

### TLS for gRPC in Production

js

```js
import { readFileSync } from 'fs'

// Server: TLS credentials
const serverCredentials = grpc.ServerCredentials.createSsl(
  readFileSync('certs/ca.crt'),
  [{
    cert_chain: readFileSync('certs/server.crt'),
    private_key: readFileSync('certs/server.key')
  }],
  true  // checkClientCertificate — enables mTLS
)

server.bindAsync('0.0.0.0:50051', serverCredentials, (err, port) => {
  if (err) throw err
  server.start()
})

// Client: TLS credentials
const clientCredentials = grpc.credentials.createSsl(
  readFileSync('certs/ca.crt'),
  readFileSync('certs/client.key'),    // For mTLS
  readFileSync('certs/client.crt')     // For mTLS
)

const usersClient = new UserService(
  'users-service:50051',
  clientCredentials
)
```

**Key Points**

- `createInsecure()` must never be used on a public interface or for cross-datacenter traffic
- mTLS (mutual TLS) verifies both the server and client certificates — provides service-to-service authentication without application-level tokens [Inference]
- Certificate rotation requires client reconnection — [Inference] gRPC-js may not pick up rotated certificates without a client restart; verify with the installed version

---

### Deadline and Cancellation

gRPC deadlines propagate the remaining time budget across the call chain — if the overall budget is 500ms and 200ms has already elapsed, the downstream gRPC call gets a 300ms deadline:

js

```js
// Client: set a deadline
const deadlineMs = Date.now() + 5000  // 5 seconds from now

const user = await new Promise((resolve, reject) => {
  usersClient.getUser(
    { id: userId },
    meta,
    { deadline: deadlineMs },
    (err, response) => {
      if (err) return reject(err)
      resolve(response)
    }
  )
})
```

With promisified clients, pass options as the third argument:

js

```js
// promisify wraps (request, metadata, options, callback)
// — verify argument ordering with the grpc-js version in use [Unverified]
const getUser = promisify(usersClient.getUser.bind(usersClient))
const user = await getUser(
  { id: userId },
  meta,
  { deadline: Date.now() + 5000 }
)
```

**Key Points**

- If the deadline is exceeded, the call fails with `DEADLINE_EXCEEDED` on the client and the server receives a `cancelled` event
- Deadline propagation must be implemented manually in Node.js — extract the remaining deadline from incoming metadata and pass it to outgoing calls [Inference — automatic propagation as in some other languages is not built-in to grpc-js]

---

### Diagram: Fastify HTTP Gateway to gRPC Backend

DatabaseOrders gRPC:50052Users gRPC:50051Fastify Gateway:3000 HTTPHTTP ClientDatabaseOrders gRPC:50052Users gRPC:50051Fastify Gateway:3000 HTTPHTTP ClientGET /checkout/order-99Authorization: Bearer tokenVerify JWT, build MetadataGetOrder({ id: "order-99" }) [gRPC unary]SELECT \* FROM orders WHERE id=...order rowOrder messageGetUser({ id: order.userId }) [gRPC unary]SELECT \* FROM users WHERE id=...user rowUser message{ order, user } JSON

---

### Health Checking with gRPC Health Protocol

The gRPC health checking protocol is a standard convention for readiness probes:

bash

```bash
npm install grpc-health-check
```

js

```js
import { HealthImplementation } from 'grpc-health-check'
import { HealthCheckResponse } from 'grpc-health-check/health_pb.js'

const healthImpl = new HealthImplementation({
  '': HealthCheckResponse.ServingStatus.SERVING,
  'users.UserService': HealthCheckResponse.ServingStatus.SERVING
})

server.addService(healthImpl.service, healthImpl)

// Mark service as not serving during shutdown
app.addHook('onClose', async () => {
  healthImpl.setStatus(
    'users.UserService',
    HealthCheckResponse.ServingStatus.NOT_SERVING
  )
  // Allow load balancer to drain traffic before grpc shutdown
  await new Promise(resolve => setTimeout(resolve, 2000))
  await new Promise((resolve, reject) =>
    server.tryShutdown(err => err ? reject(err) : resolve())
  )
})
```

**Key Points**

- Kubernetes can probe gRPC health endpoints using `grpc` probe type (requires `grpc-health-probe` binary or native support in newer Kubernetes versions [Unverified — verify Kubernetes version support])
- Setting status to `NOT_SERVING` before shutting down allows load balancers to stop routing new calls before the server closes
- The empty string key `''` represents the overall server health; named keys represent individual services

---

### gRPC Reflection for Development

gRPC reflection allows tools like `grpcurl` and `Postman` to introspect the server's available services without the `.proto` file:

bash

```bash
npm install grpc-server-reflection
```

js

```js
import { addReflection } from 'grpc-server-reflection'

// Only enable in non-production environments
if (process.env.NODE_ENV !== 'production') {
  addReflection(server, resolve(__dirname, '../proto/descriptor.pb'))
}
```

Generate the descriptor file:

bash

```bash
protoc \
  --descriptor_set_out=proto/descriptor.pb \
  --include_imports \
  proto/users.proto
```

Test with `grpcurl`:

bash

```bash
# List services
grpcurl -plaintext localhost:50051 list

# Call a method
grpcurl -plaintext \
  -d '{"id": "1"}' \
  localhost:50051 \
  users.UserService/GetUser
```

---

### Testing gRPC Handlers

js

```js
import { test } from 'node:test'
import assert from 'node:assert'
import grpc from '@grpc/grpc-js'

// Test unary handler directly — no server needed
test('getUser returns user for valid id', async () => {
  const mockCall = {
    request: { id: '1' },
    metadata: new grpc.Metadata()
  }

  const result = await new Promise((resolve, reject) => {
    implementation.getUser(mockCall, (err, response) => {
      if (err) reject(err)
      else resolve(response)
    })
  })

  assert.strictEqual(result.id, '1')
  assert.strictEqual(result.name, 'Alice')
})

test('getUser returns NOT_FOUND for missing user', async () => {
  const mockCall = {
    request: { id: 'nonexistent' },
    metadata: new grpc.Metadata()
  }

  const err = await new Promise((resolve) => {
    implementation.getUser(mockCall, (err) => resolve(err))
  })

  assert.strictEqual(err.code, grpc.status.NOT_FOUND)
})
```

For integration tests, start a real gRPC server on a random port:

js

```js
test('end-to-end: client calls server', async (t) => {
  const server = new grpc.Server()
  server.addService(UserService.service, implementation)

  const port = await new Promise((resolve, reject) => {
    server.bindAsync(
      '127.0.0.1:0',   // Port 0 — OS assigns a free port
      grpc.ServerCredentials.createInsecure(),
      (err, port) => err ? reject(err) : resolve(port)
    )
  })

  server.start()
  t.after(() => new Promise(res => server.tryShutdown(res)))

  const client = new UserService(
    `127.0.0.1:${port}`,
    grpc.credentials.createInsecure()
  )
  const getUser = promisify(client.getUser.bind(client))
  t.after(() => client.close())

  const user = await getUser({ id: '1' })
  assert.strictEqual(user.name, 'Alice')
})
```

---

**Related Topics**

- Protocol Buffers: field types, `oneof`, `map`, reserved fields, and backwards compatibility
- Code generation with `protoc` and `ts-proto` for TypeScript stubs
- gRPC-Web: bridging browser clients to gRPC backends via Envoy or a Fastify proxy
- Connect protocol: gRPC-compatible HTTP/1.1 transport with `@connectrpc/connect`
- Load balancing gRPC connections: client-side vs. L7 proxy (Envoy, Nginx)
- gRPC interceptors for logging, metrics, and auth on both client and server
- OpenTelemetry instrumentation for gRPC calls in Fastify services
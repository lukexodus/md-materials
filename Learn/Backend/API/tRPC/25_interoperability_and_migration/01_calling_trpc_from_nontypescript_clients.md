## Calling tRPC from Non-TypeScript Clients

tRPC's primary value proposition is end-to-end type safety between a TypeScript server and a TypeScript client. When the client is not TypeScript — a mobile app, a Python service, a plain JavaScript frontend, or a third-party integration — the type system is absent, but the underlying HTTP transport remains fully accessible. Non-TypeScript clients call tRPC procedures as plain HTTP requests.

---

### What tRPC Procedures Look Like Over HTTP

tRPC does not use a custom binary protocol. Every procedure maps to an HTTP endpoint with a predictable structure. Understanding this structure is the foundation for calling tRPC from any client.

#### Query Procedures (GET)

```
GET /api/trpc/<procedurePath>?input=<url-encoded-json>
```

**Example:**

```
GET /api/trpc/user.getById?input=%7B%22id%22%3A%22123%22%7D
```

Decoded `input`:

```json
{ "id": "123" }
```

#### Mutation Procedures (POST)

```
POST /api/trpc/<procedurePath>
Content-Type: application/json

{ "json": <input-value> }
```

**Example:**

```
POST /api/trpc/user.create
Content-Type: application/json

{ "json": { "name": "Alice", "email": "alice@example.com" } }
```

**Key Points:**
- The `input` query parameter for GET requests must be JSON-serialized and URL-encoded
- The POST body wraps the input in a `{ "json": ... }` envelope — this is tRPC's SuperJSON transport format wrapper
- Nested procedure paths use dot notation: `user.getById`, `post.comment.create`
- Behavior may vary depending on the tRPC version and transformer configuration in use

---

### The SuperJSON Envelope

By default, tRPC wraps inputs and outputs in a SuperJSON-compatible envelope to support types that plain JSON cannot represent (Dates, Maps, Sets, undefined). The envelope shape is:

```json
{
  "json": <the actual value>,
  "meta": {
    "values": { "<path>": ["<type>"] }
  }
}
```

The `meta.values` field annotates paths where non-JSON types appear. For clients that only deal in plain JSON types (strings, numbers, booleans, objects, arrays), the `meta` field can be ignored on responses, and only `{ "json": ... }` needs to be sent in requests.

**Key Points:**
- If the tRPC server is configured with no transformer (`transformer: undefined` or omitted), the envelope is absent — inputs and outputs are raw JSON [Inference — depends on server configuration]
- If the server uses `superjson`, non-TypeScript clients must wrap inputs in `{ "json": <value> }` and unwrap `result.data.json` from responses
- Sending raw JSON without the envelope to a SuperJSON-configured server will likely cause a parsing error [Inference — behavior may vary by tRPC version]

---

### Response Envelope Shape

tRPC responses follow a consistent envelope regardless of procedure type:

**Success:**

```json
[
  {
    "result": {
      "data": {
        "json": <output-value>,
        "meta": { ... }
      }
    }
  }
]
```

**Error:**

```json
[
  {
    "error": {
      "json": {
        "message": "User not found",
        "code": -32004,
        "data": {
          "code": "NOT_FOUND",
          "httpStatus": 404,
          "path": "user.getById"
        }
      }
    }
  }
]
```

**Key Points:**
- The response is always an array — even for single procedure calls — because tRPC supports batching
- The actual data lives at `response[0].result.data.json` when using SuperJSON transformer
- Error codes follow JSON-RPC convention numerically but tRPC maps them to named codes (`NOT_FOUND`, `UNAUTHORIZED`, `BAD_REQUEST`, etc.) in `data.code`
- Response shape details may change across tRPC major versions — treat this as version-specific [Unverified — verify against your deployed tRPC version's source or changelog]

---

### Calling from Plain JavaScript (Browser or Node.js)

No tRPC client library needed — `fetch` suffices.

**Example — calling a query:**

```js
async function getUser(id) {
  const input = JSON.stringify({ id });
  const encoded = encodeURIComponent(input);

  const response = await fetch(`/api/trpc/user.getById?input=${encoded}`, {
    method: "GET",
    headers: { "Content-Type": "application/json" },
  });

  const body = await response.json();

  if (body[0].error) {
    throw new Error(body[0].error.json.message);
  }

  return body[0].result.data.json;
}
```

**Example — calling a mutation:**

```js
async function createUser(name, email) {
  const response = await fetch("/api/trpc/user.create", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ json: { name, email } }),
  });

  const body = await response.json();

  if (body[0].error) {
    throw new Error(body[0].error.json.message);
  }

  return body[0].result.data.json;
}
```

---

### Calling from Python

**Example — using `httpx`:**

```python
import httpx
import json
from urllib.parse import quote

BASE_URL = "http://localhost:3000/api/trpc"

def get_user(user_id: str) -> dict:
    input_json = json.dumps({"id": user_id})
    encoded = quote(input_json)

    response = httpx.get(
        f"{BASE_URL}/user.getById",
        params={"input": input_json},  # httpx handles encoding
        headers={"Content-Type": "application/json"},
    )
    response.raise_for_status()

    body = response.json()

    if "error" in body[0]:
        raise Exception(body[0]["error"]["json"]["message"])

    return body[0]["result"]["data"]["json"]


def create_user(name: str, email: str) -> dict:
    response = httpx.post(
        f"{BASE_URL}/user.create",
        json={"json": {"name": name, "email": email}},
    )
    response.raise_for_status()

    body = response.json()

    if "error" in body[0]:
        raise Exception(body[0]["error"]["json"]["message"])

    return body[0]["result"]["data"]["json"]


# Usage
user = get_user("123")
new_user = create_user("Alice", "alice@example.com")
```

**Key Points:**
- `httpx.get(..., params={"input": input_json})` lets httpx handle URL encoding — passing pre-encoded strings risks double-encoding [Inference]
- `response.raise_for_status()` catches HTTP-level errors (5xx); tRPC application errors arrive as `200 OK` with an `error` field in the body and must be checked separately

---

### Calling from Swift (iOS)

**Example — using `URLSession`:**

```swift
import Foundation

struct TRPCResponse<T: Decodable>: Decodable {
    struct Result: Decodable {
        struct Data: Decodable {
            let json: T
        }
        let data: Data
    }
    let result: Result?
}

func getUser(id: String) async throws -> User {
    var components = URLComponents(string: "http://localhost:3000/api/trpc/user.getById")!
    let inputJSON = try JSONSerialization.data(withJSONObject: ["id": id])
    let inputString = String(data: inputJSON, encoding: .utf8)!
    components.queryItems = [URLQueryItem(name: "input", value: inputString)]

    var request = URLRequest(url: components.url!)
    request.httpMethod = "GET"

    let (data, _) = try await URLSession.shared.data(for: request)
    let decoded = try JSONDecoder().decode([TRPCResponse<User>].self, from: data)

    guard let result = decoded.first?.result else {
        throw URLError(.badServerResponse)
    }

    return result.data.json
}
```

**Key Points:**
- `URLComponents` handles percent-encoding of the `input` query item automatically
- The response is decoded as an array (`[TRPCResponse<T>]`) matching tRPC's envelope structure
- Date decoding requires custom `JSONDecoder` strategy if the server uses SuperJSON Date serialization [Inference]

---

### Calling from Kotlin (Android)

**Example — using `ktor-client`:**

```kotlin
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.request.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.*

val client = HttpClient {
    install(ContentNegotiation) { json() }
}

val BASE = "http://10.0.2.2:3000/api/trpc"

suspend fun getUser(id: String): JsonObject {
    val input = Json.encodeToString(mapOf("id" to id))
    val response: JsonArray = client.get("$BASE/user.getById") {
        parameter("input", input)
    }.body()

    val first = response[0].jsonObject
    first["error"]?.let { throw Exception(it.jsonObject["json"]!!.jsonObject["message"]!!.jsonPrimitive.content) }

    return first["result"]!!.jsonObject["data"]!!.jsonObject["json"]!!.jsonObject
}

suspend fun createUser(name: String, email: String): JsonObject {
    val response: JsonArray = client.post("$BASE/user.create") {
        contentType(io.ktor.http.ContentType.Application.Json)
        setBody(buildJsonObject {
            put("json", buildJsonObject {
                put("name", name)
                put("email", email)
            })
        })
    }.body()

    val first = response[0].jsonObject
    first["error"]?.let { throw Exception(it.jsonObject["json"]!!.jsonObject["message"]!!.jsonPrimitive.content) }

    return first["result"]!!.jsonObject["data"]!!.jsonObject["json"]!!.jsonObject
}
```

**Key Points:**
- `10.0.2.2` is the Android emulator's alias for `localhost` on the host machine
- Ktor's `parameter()` builder handles URL encoding of the `input` value

---

### Batch Requests

tRPC supports batching multiple procedure calls into a single HTTP request. The batch format differs slightly from single calls.

**Example — batched GET:**

```
GET /api/trpc/user.getById,post.getAll?batch=1&input={"0":{"json":{"id":"123"}},"1":{"json":{}}}
```

**Example — batched POST:**

```json
POST /api/trpc/user.getById,post.getAll?batch=1
Content-Type: application/json

{
  "0": { "json": { "id": "123" } },
  "1": { "json": {} }
}
```

Response is an array with one entry per procedure, in index order:

```json
[
  { "result": { "data": { "json": { "id": "123", "name": "Alice" } } } },
  { "result": { "data": { "json": [ ... ] } } }
]
```

**Key Points:**
- Batching is optional for non-TypeScript clients — single calls are simpler and batching adds complexity with limited benefit unless latency is a concern
- The `batch=1` query parameter must be present for the server to interpret the request as a batch [Inference — verify against tRPC server adapter configuration]

---

### Authentication Headers

tRPC procedures that use `protectedProcedure` or session-based auth check headers or cookies in the context factory. Non-TypeScript clients pass these the same way as any HTTP client.

**Example — bearer token (JavaScript):**

```js
const response = await fetch("/api/trpc/user.getProfile", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": `Bearer ${accessToken}`,
  },
});
```

**Example — cookie-based session (Python):**

```python
# httpx maintains cookies across requests with a session client
with httpx.Client(base_url="http://localhost:3000") as session:
    session.post("/auth/login", json={"email": "...", "password": "..."})
    # Session cookie is stored and sent automatically on subsequent requests
    user = session.get("/api/trpc/user.getProfile", params={"input": "{}"})
```

---

### Eliminating the Envelope: Configuring No Transformer

If non-TypeScript clients are a primary use case, configuring tRPC without a transformer removes the SuperJSON envelope, making requests and responses plain JSON.

**Example — server without transformer:**

```ts
import { initTRPC } from "@trpc/server";

const t = initTRPC.context<Context>().create({
  // transformer omitted — plain JSON in, plain JSON out
});
```

**Request body (mutation, no transformer):**

```json
{ "name": "Alice", "email": "alice@example.com" }
```

**Response (no transformer):**

```json
[
  {
    "result": {
      "data": { "name": "Alice", "id": "123" }
    }
  }
]
```

**Key Points:**
- Without a transformer, `Date` objects are serialized as ISO strings and arrive as strings on the client — the TypeScript client would previously have deserialized them automatically
- Removing the transformer is a breaking change for existing TypeScript clients that relied on SuperJSON deserialization [Inference — assess impact before changing in production]
- A pragmatic middle ground is keeping SuperJSON on the TypeScript client path and exposing a separate REST or OpenAPI endpoint for non-TypeScript consumers (see below)

---

### Alternative: Exposing a REST Layer for Non-TypeScript Clients

Rather than working around the tRPC envelope, some teams expose a thin REST layer that calls tRPC procedures internally, presenting a clean JSON API to external consumers.

**Example — Express REST wrapper calling tRPC caller:**

```ts
import { createCallerFactory } from "@trpc/server";
import { appRouter } from "./router";
import { createContext } from "./context";

const createCaller = createCallerFactory(appRouter);

app.get("/rest/users/:id", async (req, res) => {
  const caller = createCaller(await createContext({ req, res }));

  try {
    const user = await caller.user.getById({ id: req.params.id });
    res.json(user);
  } catch (err: any) {
    res.status(err.data?.httpStatus ?? 500).json({ error: err.message });
  }
});
```

**Key Points:**
- `createCallerFactory` calls procedures server-side with no HTTP overhead — the REST endpoint is just a translation layer
- Context is created the same way as for tRPC HTTP calls, so authentication and middleware behavior is consistent
- This pattern also enables OpenAPI documentation generation for the REST surface [Inference]

---

### tRPC HTTP Compatibility Summary

<svg viewBox="0 0 700 340" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="12">
  <rect width="700" height="340" fill="#0f1117" rx="12"/>
  <text x="350" y="28" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">Non-TypeScript Client Call Anatomy</text>

  <!-- Query box -->
  <rect x="30" y="48" width="300" height="120" rx="8" fill="#1e293b" stroke="#2563eb" stroke-width="1.5"/>
  <text x="180" y="68" text-anchor="middle" fill="#93c5fd" font-size="12" font-weight="bold">Query (GET)</text>
  <text x="45" y="90"  fill="#94a3b8" font-size="11">GET /api/trpc/&lt;path&gt;</text>
  <text x="45" y="108" fill="#94a3b8" font-size="11">  ?input=&lt;url-encoded-json&gt;</text>
  <text x="45" y="126" fill="#64748b" font-size="11">  with SuperJSON:  {"json": value}</text>
  <text x="45" y="144" fill="#64748b" font-size="11">  without transformer: raw value</text>
  <text x="45" y="162" fill="#475569" font-size="11">  → response[0].result.data.json</text>

  <!-- Mutation box -->
  <rect x="370" y="48" width="300" height="120" rx="8" fill="#1e293b" stroke="#7c3aed" stroke-width="1.5"/>
  <text x="520" y="68" text-anchor="middle" fill="#c4b5fd" font-size="12" font-weight="bold">Mutation (POST)</text>
  <text x="385" y="90"  fill="#94a3b8" font-size="11">POST /api/trpc/&lt;path&gt;</text>
  <text x="385" y="108" fill="#94a3b8" font-size="11">  Content-Type: application/json</text>
  <text x="385" y="126" fill="#64748b" font-size="11">  body with SuperJSON: {"json": value}</text>
  <text x="385" y="144" fill="#64748b" font-size="11">  body no transformer: raw value</text>
  <text x="385" y="162" fill="#475569" font-size="11">  → response[0].result.data.json</text>

  <!-- Response box -->
  <rect x="30" y="188" width="300" height="120" rx="8" fill="#1a2e1a" stroke="#16a34a" stroke-width="1.5"/>
  <text x="180" y="208" text-anchor="middle" fill="#86efac" font-size="12" font-weight="bold">Success Response</text>
  <text x="45" y="228" fill="#94a3b8" font-size="11">[ {</text>
  <text x="45" y="246" fill="#94a3b8" font-size="11">    "result": {</text>
  <text x="45" y="264" fill="#94a3b8" font-size="11">      "data": { "json": &lt;value&gt; }</text>
  <text x="45" y="282" fill="#94a3b8" font-size="11">    }</text>
  <text x="45" y="300" fill="#94a3b8" font-size="11">} ]</text>

  <!-- Error box -->
  <rect x="370" y="188" width="300" height="120" rx="8" fill="#2a1a1a" stroke="#dc2626" stroke-width="1.5"/>
  <text x="520" y="208" text-anchor="middle" fill="#fca5a5" font-size="12" font-weight="bold">Error Response</text>
  <text x="385" y="228" fill="#94a3b8" font-size="11">[ {</text>
  <text x="385" y="246" fill="#94a3b8" font-size="11">    "error": { "json": {</text>
  <text x="385" y="264" fill="#94a3b8" font-size="11">      "message": "...",</text>
  <text x="385" y="282" fill="#94a3b8" font-size="11">      "data": { "code": "NOT_FOUND" }</text>
  <text x="385" y="300" fill="#94a3b8" font-size="11">    } }</text>
</svg>

---

**Conclusion:**
tRPC procedures are reachable from any HTTP client regardless of language. Queries map to GET requests with a URL-encoded `input` parameter; mutations map to POST requests with a JSON body. The SuperJSON envelope (`{ "json": value }`) wraps inputs and outputs when the server uses a transformer, and responses always arrive as arrays. Non-TypeScript clients can work directly with this HTTP interface, or the server can expose a REST translation layer via `createCallerFactory` for a cleaner integration surface. Exact envelope structure and error shape should be verified against the specific tRPC version deployed, as these details have shifted across major versions.
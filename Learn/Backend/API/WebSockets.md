# WebSockets: A Comprehensive Guide

## What Problem WebSockets Solve

Ordinary HTTP is fundamentally a request-response protocol: the client asks, the server answers, the exchange is done. There's no native way for a server to just send data to a client whenever it wants to, without the client having asked first. For a huge fraction of the web this is completely fine — but it breaks down for anything that needs the server to push data to the client in real time: a chat message arriving, a stock price ticking, a live multiplayer game state update, a collaborative document seeing another user's edit.

Before WebSockets existed, people worked around this with **long polling**: the client sends a request, the server deliberately holds it open without responding until it actually has something to say (or a timeout is reached), then responds, and the client immediately opens a new request to wait again. This works, but it's wasteful — every single message requires a full new HTTP request, with a new TCP handshake in the worst case, HTTP headers resent every time, and the round-trip latency of establishing that request before the server's answer can even be sent.

WebSockets solve this directly: they establish a single, long-lived, full-duplex connection between client and server, over which either side can send messages to the other at any time, with very low per-message overhead. "Full-duplex" here means the same thing it meant when I described HTTP/2 streams in the gRPC piece — both directions are open and independent at once — but WebSockets get there differently, and it's worth being precise about that difference rather than assuming it's the same mechanism.

## The Handshake: Upgrading from HTTP

This is the part that's easy to gloss over, so it's worth the same level of attention I gave the wire format in the protobuf piece and HTTP/2's role in the gRPC piece, because understanding it explains several downstream WebSocket behaviors that otherwise look arbitrary.

A WebSocket connection doesn't start life as a WebSocket connection. It starts as a completely ordinary HTTP request, which then asks to be **upgraded** to a WebSocket connection using HTTP's `Upgrade` header mechanism:

```
GET /chat HTTP/1.1
Host: example.com
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
Sec-WebSocket-Version: 13
```

If the server supports WebSockets on that endpoint and agrees to the upgrade, it responds:

```
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
```

The `101 Switching Protocols` status code is the key detail — it's a distinct, dedicated HTTP status code that exists specifically for this "we're about to stop speaking HTTP on this connection and start speaking something else" moment. Once the server sends this response, the underlying TCP connection is repurposed: no more HTTP requests will flow over it, and instead both sides start reading and writing WebSocket frames directly on the same socket.

The `Sec-WebSocket-Key` and `Sec-WebSocket-Accept` pair deserves a specific explanation, because it's not obviously self-explanatory the way HTTP methods or status codes are. The client generates a random base64-encoded key. The server takes that key, appends a fixed, spec-defined GUID string (`258EAFA5-E914-47DA-95CA-C5AB0DC85B11`), computes the SHA-1 hash of the result, base64-encodes that hash, and sends it back as `Sec-WebSocket-Accept`. This isn't a security or authentication mechanism in any meaningful cryptographic sense — the GUID is public and fixed by the spec, so anyone can compute the expected answer. Its actual purpose is to prevent a specific class of accidental-protocol-confusion bug: it proves the server actually understood it was being asked for a WebSocket upgrade (as opposed to, say, a plain HTTP server or a caching proxy blindly echoing back headers it didn't understand), and it prevents certain cross-protocol attacks where a non-WebSocket-aware server might be tricked into treating raw WebSocket frame bytes sent immediately as if they were HTTP.

One practical consequence worth being explicit about, connecting back to the gRPC-Web point I made in the previous piece: because this handshake starts as a normal HTTP request, WebSockets work over the same port (typically 80/443) as regular HTTP traffic, and can pass through most existing HTTP infrastructure (reverse proxies, load balancers) as long as that infrastructure knows to recognize and correctly forward the `Upgrade` header rather than treating it as a normal request — some older or misconfigured proxies don't, which is a genuinely common real-world source of "WebSockets work locally but not through our load balancer" bugs.

## The Frame Format

Once the connection is upgraded, all further communication happens as a sequence of WebSocket **frames** — this is the third distinct binary framing scheme across this three-part thread (protobuf's tag+varint wire format, gRPC's length-prefix-within-HTTP/2-streams framing, and now this), and the contrast is genuinely instructive rather than incidental, so it's worth laying out the structure explicitly:

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-------+-+-------------+-------------------------------+
|F|R|R|R| opcode|M| Payload len |    Extended payload length    |
|I|S|S|S|  (4)  |A|     (7)     |             (16/64)            |
|N|V|V|V|       |S|             |   (if payload len==126/127)    |
| |1|2|3|       |K|             |                                |
+-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
|     Extended payload length continued, if payload len == 127  |
+ - - - - - - - - - - - - - - - +-------------------------------+
|                     Masking-key (if MASK set to 1)             |
+-------------------------------+-------------------------------+
|                          Payload data                          |
+------------------------------------------------------------------+
```

Walking through the meaningful fields rather than every bit:

- **FIN bit** — indicates whether this is the final frame of a message. A single logical message can be split across multiple frames (this is called **fragmentation**), which is useful for sending a message before its full size is known (streaming a large payload as it's generated) or simply to avoid buffering an enormous message in memory before sending. The receiver reassembles fragments into one logical message before delivering it to the application layer — fragmentation is a wire-level detail, not something application code normally has to think about, on either side.
- **Opcode** — a 4-bit field indicating the frame type, covered in detail in the next section.
- **MASK bit and Masking-key** — covered in its own section right below, because it has a specific and important rationale that deserves more than a one-line mention.
- **Payload length** — encoded with a small variable-length scheme: a 7-bit field directly holds lengths up to 125, the special value 126 signals "read the next 16 bits as the real length," and 127 signals "read the next 64 bits as the real length." This is conceptually similar in spirit to protobuf's varint (small values are cheap, larger values cost more bytes) but a completely different concrete encoding — worth noting as a design-pattern parallel rather than assuming it's the same mechanism.

## Masking: Why It Exists

This is one of those WebSocket details that looks like arbitrary protocol trivia until you understand the actual attack it prevents, so it's worth explaining properly rather than just stating the rule.

**Every frame sent from client to server must be masked.** Frames sent from server to client must not be masked. Masking works by XOR-ing the payload bytes against a 4-byte masking key (randomly chosen per frame by the client, included in the frame itself so the server can reverse it), rather than sending the payload bytes as-is.

The reason this exists is specifically about the shared-port, upgraded-from-HTTP nature of WebSockets described above. Because a WebSocket connection typically shares infrastructure with regular HTTP traffic (proxies, caches, and other intermediaries that were designed to inspect and parse HTTP), there was a real concern that a malicious web page could use JavaScript to send carefully crafted WebSocket payload bytes that, if some misbehaving proxy in the path misinterpreted them as if they were plain bytes on the wire (rather than correctly recognizing them as an opaque WebSocket payload), could look like a completely different, attacker-chosen HTTP request smuggled through that proxy — a class of attack broadly called cache/proxy poisoning or request smuggling. Masking the payload with a key that's unpredictable per-frame ensures a browser-originated malicious page can't reliably control the exact bytes that hit the wire, which closes off that attack surface. This is specifically a client-to-server requirement because the threat model is about untrusted JavaScript running in a browser being able to choose payload bytes — a server is a trusted party in this model, so server-to-client frames don't need masking.

It's worth being clear that masking is **not encryption** and provides no confidentiality whatsoever — the masking key is sent right there in the frame, so anyone who can see the frame can trivially unmask it. If you need confidentiality, that's what running WebSockets over TLS (`wss://` instead of `ws://`, the WebSocket-over-TLS equivalent of `https://` vs `http://`) is for, entirely separately from masking.

## Frame Types (Opcodes)

The opcode field determines what kind of frame this is:

| Opcode | Type | Purpose |
|---|---|---|
| `0x0` | Continuation | A continuation of a fragmented message (see FIN bit above) |
| `0x1` | Text | A UTF-8 text message |
| `0x2` | Binary | An arbitrary binary message |
| `0x8` | Close | Initiates or acknowledges connection closure |
| `0x9` | Ping | A control frame asking the peer to respond |
| `0xA` | Pong | A response to a ping, or an unsolicited liveness signal |

Text and binary frames are what application code actually sends and receives as messages — most WebSocket libraries expose these as, respectively, a string and a byte array/buffer at the API level, and typically dispatch to different event handlers or callback signatures depending on which type arrived, so choosing the right one when sending matters for how the receiving code will handle it. If your application is sending protobuf-serialized messages over a WebSocket (a combination that does happen in practice, worth flagging as a direct callback to the first piece in this thread), those should go as binary frames, not text — protobuf's wire format is raw bytes, not valid UTF-8 in general, and sending it as a text frame would be a protocol violation.

Ping and pong are **control frames**, distinct from data frames, and exist specifically for connection liveness checking — covered in more depth in the heartbeat section below, since this is genuinely one of the most operationally important parts of running WebSockets correctly in production, similar in spirit to how deadlines were the operationally-critical section of the gRPC piece.

## Connection Lifecycle and Ready States

A WebSocket connection, once established, moves through a small set of states — most WebSocket client APIs (the browser's native `WebSocket` object being the most universally recognized example) expose this directly:

- **CONNECTING (0)** — the initial state, while the HTTP upgrade handshake described above is in flight.
- **OPEN (1)** — the handshake succeeded, and the connection is ready for sending and receiving frames.
- **CLOSING (2)** — a close handshake has begun (either side has sent a close frame) but hasn't finished.
- **CLOSED (3)** — the connection is fully closed, either cleanly or due to an error.

Closing a WebSocket connection, when done properly, is itself a small handshake, not just an abrupt disconnect — worth walking through since "clean vs unclean closure" is a genuinely meaningful distinction in how applications should react. One side sends a close frame (opcode `0x8`), optionally containing a numeric close code and an optional UTF-8 reason string in the payload. The other side, upon receiving a close frame, is expected to respond with its own close frame (if it hasn't already sent one) and then the underlying TCP connection is closed. This is called a **clean close**.

An **unclean closure** — the TCP connection simply drops (network failure, the process crashes, a proxy times out the connection) without this close-frame exchange happening — is a genuinely different situation from the application's point of view, and most WebSocket APIs surface this distinction (e.g., the browser API's `close` event includes a `wasClean` boolean specifically so application code can tell the difference and potentially react differently — a clean close might mean "the server intentionally ended this session," while an unclean one more likely means "something went wrong, consider reconnecting").

**Close codes** are a defined-by-spec numeric vocabulary for *why* a connection is closing, sent in the close frame's payload — some meaningful ones:

| Code | Meaning |
|---|---|
| 1000 | Normal closure — the purpose for which the connection was established has been fulfilled |
| 1001 | Going away — e.g., server shutting down, or a browser tab navigating away |
| 1002 | Protocol error |
| 1003 | Received a data type it cannot accept (e.g., a server that only handles text receiving a binary frame) |
| 1006 | Reserved — specifically means "the connection was closed abnormally, without a close frame," and cannot actually be sent on the wire; it's a value application code will see reported locally to represent exactly the unclean-closure case just described |
| 1008 | Policy violation — a generic code for "your message violated some policy," used when no more specific code fits |
| 1011 | Server encountered an unexpected condition, roughly analogous in spirit to gRPC's `INTERNAL` status code covered in the previous piece |

## Reconnection: A Genuinely Different Operational Shape from gRPC

This is worth calling out explicitly as a contrast, not just a list of behaviors, because it's a load-bearing difference from the previous piece in this thread. A gRPC channel, as covered previously, can be backed by multiple underlying HTTP/2 connections, can be load-balanced across multiple server addresses, and gRPC client libraries generally have built-in reconnection and retry behavior as a first-class, configurable feature. A raw WebSocket connection has none of that by default — it is a single connection to a single server, and if it drops, **the application is entirely responsible for detecting that and deciding whether and how to reconnect.** There's no automatic retry, no automatic failover to a different server, no automatic backoff — all of that is something you build on top, not something the protocol or typical client libraries give you for free the way gRPC's ecosystem more commonly does.

In practice, real WebSocket-based applications almost always implement:

- **Reconnection with backoff** — on an unexpected close, wait some amount of time before attempting to reconnect, and increase that wait time on repeated failures (exponential backoff, typically with some randomized jitter added) rather than hammering a struggling server with immediate reconnect attempts.
- **State resynchronization on reconnect** — because a dropped connection means any messages the server tried to send during the gap are simply lost (there's no built-in message queuing or replay), a well-designed application-level protocol on top of WebSockets often includes some way to catch up after reconnecting — e.g., the client sends "I last saw update #4521" and the server sends everything since, or the client just re-fetches full current state via a separate request rather than relying on the stream alone.

## Heartbeats: Ping/Pong in Practice

Also worth its own real explanation rather than a passing mention, because — similar to deadlines in the gRPC piece — this is one of the details that separates a WebSocket implementation that behaves well in production from one that silently misbehaves.

The problem heartbeats solve: TCP connections can go silently dead without either side immediately knowing. A client's laptop goes to sleep, a mobile client loses signal, a NAT/firewall in the middle silently drops an idle connection's mapping without telling either endpoint — in many of these cases, neither side gets an explicit "connection closed" signal; the connection is just dead, and the next attempt to write to it may not fail immediately.

Ping/pong control frames exist to detect this proactively rather than waiting to discover it the unpleasant way (e.g., a server holding a connection open and continuing to try to push data to a client that's actually long gone). The typical pattern: one side (usually the server, though either can) periodically sends a ping frame; the receiving side is expected to respond promptly with a pong frame carrying the same payload. If no pong arrives within some reasonable timeout, the sender treats the connection as dead and closes it (freeing up server-side resources tied to that connection) — and on the client side, this is exactly the kind of "connection appears dead" signal that should trigger the reconnection logic from the previous section.

Some higher-level protocols built on top of raw WebSockets implement their own application-level heartbeat instead of, or in addition to, the protocol-level ping/pong (a periodic small "I'm alive" text/JSON message sent as a normal data frame rather than a control frame) — this is sometimes done because not every environment or library exposes clean access to the control-frame-level ping/pong at the application layer, so an app-level heartbeat message is a portable workaround. Either approach is solving the same underlying problem.

## Subprotocols and Extensions

WebSockets have two distinct mechanisms for negotiating additional behavior beyond the base protocol, and they're worth distinguishing clearly since they solve different problems — this is a reasonable point of comparison back to how gRPC used metadata as a general side-channel, though the mechanism here is different in kind, not just in name.

**Subprotocols** let the client and server agree on what *application-level* message format/schema will be used over the connection — the base WebSocket protocol says nothing about what your text/binary frame payloads actually mean; subprotocols are how client and server can advertise and agree on that. Negotiated during the handshake via a `Sec-WebSocket-Protocol` header, where the client lists protocols it supports and the server picks one:

```
Sec-WebSocket-Protocol: graphql-ws, mqtt
```

Common real examples: `graphql-ws`/`graphql-transport-ws` (for running GraphQL subscriptions over a WebSocket), MQTT-over-WebSocket, and various chat or messaging protocols. This is roughly analogous to how a `.proto` file's `service` definition establishes an agreed-upon message schema for gRPC — the difference is that WebSocket subprotocol negotiation just picks a *name* during the handshake; it doesn't itself define or enforce the actual message schema the way protobuf's generated code does. Enforcing the schema is left entirely up to the application.

**Extensions**, by contrast, modify the *behavior of the WebSocket protocol itself* rather than the application-level payload meaning — the most common real-world example by far is `permessage-deflate`, which compresses frame payloads using the DEFLATE algorithm, negotiated similarly via a `Sec-WebSocket-Extensions` header. This is a transport-level optimization, transparent to application code, unlike subprotocols which are meaningful to and chosen by the application.

## Scaling Considerations

Worth its own section, again drawing a deliberate contrast with the gRPC piece's load-balancing discussion, because the operational shape here is genuinely different, not just a smaller version of the same problem.

A WebSocket connection is **stateful and long-lived**, and once established, it's pinned to whichever specific server process accepted it — unlike a stateless HTTP request that a load balancer can route independently on every single request, an open WebSocket connection can't simply be handed off to a different backend server mid-connection without the client and server actively cooperating to reconnect elsewhere. This has several real consequences for running WebSocket services at scale:

- **A load balancer only chooses the backend once**, at initial connection time — after that, all frames on that connection go to that same backend for the connection's entire lifetime. This means a naive round-robin load balancer can end up with an uneven distribution of *long-lived* connections across backends over time, even though it's technically balancing evenly on a per-new-connection basis, especially if some clients' connections happen to live much longer than others.
- **Each server process is holding open resources (memory, a file descriptor, potentially application state) for every connection it's serving**, for as long as that connection lives — this caps the practical number of concurrent connections a single server process can handle, and that ceiling is a real capacity-planning number in a way that stateless HTTP request handling generally isn't, since HTTP requests are typically handled and released quickly rather than held open.
- **Broadcasting a message to many connected clients requires some way of reaching all the relevant open connections**, which is straightforward if they're all on one server process but becomes a real distributed-systems problem once you have many server processes each holding a subset of connections — a message that needs to reach clients connected to *other* processes has to be routed there somehow. Common solutions include a shared pub/sub layer (Redis pub/sub, a message broker) that every server process subscribes to, so that "broadcast this message" becomes "publish to the shared channel, and whichever process holds the relevant client connection delivers it locally."
- **Deploying new server code becomes more delicate**, because restarting or redeploying a server process necessarily drops every connection it's currently holding — this is a much bigger disruption than a stateless HTTP server restart (which a load balancer can route around trivially, request by request), and often requires deliberate techniques like graceful draining (stop accepting new connections, wait for existing ones to naturally close or explicitly ask clients to reconnect elsewhere, then actually restart) to avoid a jarring mass-disconnect on every deploy.

This is worth contrasting directly with gRPC's model from the previous piece: a gRPC channel can transparently be backed by multiple connections and load-balanced at the RPC-call level (per the load-balancing section in that piece), because individual gRPC calls, even on a long-lived channel, are still discrete, self-contained operations that can reasonably be distributed across backends. A single WebSocket connection is a single, ongoing conversation — there's no equivalent unit of per-call granularity to redistribute mid-connection.

## WebSockets vs the Alternatives

Closing the loop, since this is the natural place to draw together WebSockets, Server-Sent Events, long polling, and gRPC's own streaming — all trying to solve some version of "the server needs to push data," but with different tradeoffs, worth laying out explicitly rather than leaving implicit.

**Long polling** — covered at the top as the pre-WebSocket workaround. Works over plain HTTP/1.1, so it has zero special infrastructure requirements, but carries meaningfully higher latency and overhead per message (a full HTTP request/response cycle, repeated headers, per the initial motivation section) compared to WebSockets' single persistent connection.

**Server-Sent Events (SSE)** — a simpler, standardized approach for the specific case where only the *server* needs to push to the client, and the client never needs to send anything back over the same channel (it would just make a normal separate HTTP request for that). SSE runs over a single, plain, long-lived HTTP response (using a specific `text/event-stream` content type and message format) — no special upgrade handshake, no separate binary framing scheme the way WebSockets have, and it gets automatic reconnection built into the browser's native `EventSource` API for free — a real practical advantage over raw WebSockets, which, as covered above, have no default reconnection behavior at all. The real limitation is that SSE is genuinely one-directional (server-to-client only) and, in its plain-text `text/event-stream` format, isn't naturally suited to binary payloads the way WebSocket binary frames are. If your use case is purely "server pushes updates, client never needs to talk back on this same channel" (a live news ticker, a stock price feed, live sports scores), SSE is frequently a simpler and more robust choice than reaching for a full WebSocket.

**gRPC server streaming** — covered in the previous piece; this is worth including in this comparison because it solves a similar-shaped problem (server pushing a sequence of results to a client) but is intended for internal service-to-service communication with a typed schema, not something a browser can consume directly without gRPC-Web's proxy translation layer, as already noted. If both ends are services you control and you already have a protobuf schema, gRPC's server streaming is often a better fit than building an ad hoc WebSocket protocol from scratch — you get the schema enforcement, deadlines, and status codes already covered, none of which raw WebSockets give you natively.

**WebSockets themselves** are the right choice specifically when you need genuine bidirectional, low-latency, frequent, browser-compatible communication — live chat, multiplayer games, collaborative editing, trading platforms — where SSE's one-directional limitation is a real blocker and long polling's overhead is a real cost, and where you're willing to take on the operational responsibilities covered above (manual reconnection logic, heartbeats, the stateful-scaling considerations) that come with them.

## Worked Example: Live Catalog Updates, Continuing the Library Scenario

Extending the same `CatalogService`/library scenario used in both previous pieces, here's a small but realistic example of a WebSocket-based live search — a client searching as the user types, receiving incremental results, with the reconnection and heartbeat patterns discussed above actually applied rather than just described abstractly:

```javascript
class CatalogSocket {
  constructor(url) {
    this.url = url;
    this.reconnectDelay = 1000; // start at 1s, doubles on repeated failure
    this.connect();
  }

  connect() {
    this.ws = new WebSocket(this.url);

    this.ws.onopen = () => {
      this.reconnectDelay = 1000; // reset backoff on successful connect
      console.log("Connected to catalog service");
    };

    this.ws.onmessage = (event) => {
      const update = JSON.parse(event.data);
      this.handleUpdate(update);
    };

    this.ws.onclose = (event) => {
      console.log(`Disconnected (clean: ${event.wasClean}, code: ${event.code})`);
      if (event.code !== 1000) { // not a normal, intentional closure
        this.scheduleReconnect();
      }
    };

    this.ws.onerror = (error) => {
      console.error("WebSocket error:", error);
    };
  }

  scheduleReconnect() {
    setTimeout(() => {
      this.reconnectDelay = Math.min(this.reconnectDelay * 2, 30000); // cap at 30s
      this.connect();
    }, this.reconnectDelay);
  }

  search(query) {
    if (this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify({ type: "search", query }));
    }
  }

  handleUpdate(update) {
    // application-specific handling of incoming search results
  }
}
```

Notice what this demonstrates in practice, tying back to the concepts above: `onclose` checks `wasClean`/the close code to decide *whether* reconnection is warranted at all (a normal code-1000 closure shouldn't trigger a reconnect loop — that's the connection ending as intended); reconnection uses exponential backoff with a cap, exactly as described in the reconnection section; and `readyState` is checked before sending, since attempting to send on a connection that isn't actually `OPEN` yet (or anymore) would fail. What this example deliberately doesn't show is server-side heartbeat handling or a shared-pub/sub broadcast layer — those live on the server side of this exchange and are more infrastructure-dependent than client code, per the scaling section above.

---

Same closing habit as the last two pieces — scope stated plainly. I focused on the base WebSocket protocol (RFC 6455) and the operational patterns that come up in real production use (reconnection, heartbeats, scaling), and gave the worked example in JavaScript specifically because the browser's native WebSocket API is the most universally recognized reference point, the way I used Python for gRPC's client-side illustrations. I didn't cover server-side framework-specific APIs (how a specific server library like `ws` in Node, Python's `websockets`, or Java's `javax.websocket` actually implement accepting connections and writing frames), and I didn't get into the newer WebTransport API, which is sometimes discussed as a potential eventual successor built on HTTP/3/QUIC. Both are reasonable next branches if you want to keep going in this direction.
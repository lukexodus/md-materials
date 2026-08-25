## Java Client

### Overview

The official Java client for Elasticsearch (`co.elastic.clients:elasticsearch-java`) is a strongly typed client built around Java's type system, offering compile-time safety for request and response structures rather than working primarily with loosely typed maps or raw JSON. This is a meaningfully different design philosophy from more dynamically typed clients like Python's, and reflects Java's own language conventions.

### Client Architecture

**Key Points**
- The client is layered on top of a low-level transport (`ElasticsearchTransport`), which handles the actual HTTP communication, and can be backed by different underlying HTTP libraries (historically the Java Low Level REST Client, though this has evolved across versions).
- API calls are exposed through typed request/response builder objects, using a fluent builder pattern rather than constructing raw JSON or generic maps for request bodies.
- The client uses Jackson (or a compatible JSON mapper) internally for serialization/deserialization between Java objects and the JSON wire format Elasticsearch expects.

### Basic Setup

```java
RestClient restClient = RestClient.builder(
    new HttpHost("localhost", 9200, "https")
).build();

ElasticsearchTransport transport = new RestClientTransport(
    restClient, new JacksonJsonpMapper()
);

ElasticsearchClient client = new ElasticsearchClient(transport);
```

**Key Points**
- `RestClient` is the low-level HTTP client handling connection details, host configuration, and TLS.
- `RestClientTransport` bridges the low-level REST client to the typed `ElasticsearchClient` API, using a `JsonpMapper` (commonly Jackson-backed) for serialization.
- `ElasticsearchClient` is the primary entry point applications interact with for typed API calls.

### Diagram: Java Client Layering

<svg width="100%" viewBox="0 0 680 300" role="img"><title>Java client layered architecture (svg_diagram)</title><desc>Application code calls the typed ElasticsearchClient, which delegates through a transport layer using a JSON mapper, down to the low-level RestClient that performs actual HTTP communication with the cluster.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="240" y="20" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="40" text-anchor="middle" dominant-baseline="central">Application code</text>
<text class="ts" x="340" y="60" text-anchor="middle" dominant-baseline="central">Typed builder calls</text>
</g>

<line x1="340" y1="76" x2="340" y2="110" class="arr" marker-end="url(#arrow)" />

<g class="node c-teal">
<rect x="220" y="110" width="240" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="128" text-anchor="middle" dominant-baseline="central">ElasticsearchClient</text>
<text class="ts" x="340" y="148" text-anchor="middle" dominant-baseline="central">Typed API surface</text>
</g>

<line x1="340" y1="166" x2="340" y2="200" class="arr" marker-end="url(#arrow)" />

<g class="node c-coral">
<rect x="200" y="200" width="280" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="218" text-anchor="middle" dominant-baseline="central">RestClientTransport</text>
<text class="ts" x="340" y="238" text-anchor="middle" dominant-baseline="central">JSON mapping via Jackson</text>
</g>

<line x1="340" y1="256" x2="340" y2="270" class="arr" marker-end="url(#arrow)" />
<text class="ts" x="340" y="290" text-anchor="middle">Low-level RestClient (HTTP)</text>
</svg>

### Executing a Typed Search

```java
SearchResponse<Product> response = client.search(s -> s
    .index("products")
    .query(q -> q
        .match(m -> m
            .field("name")
            .query("elasticsearch")
        )
    ),
    Product.class
);

for (Hit<Product> hit : response.hits().hits()) {
    Product p = hit.source();
}
```

**Key Points**
- The lambda-based builder syntax (`s -> s.index(...)`) is the client's idiomatic pattern for constructing nested request objects without deeply nested explicit builder chains.
- The target class (`Product.class` here) is passed so the client can deserialize each hit's `_source` directly into that application-defined type, rather than returning a generic map that must be manually mapped afterward.
- This typed deserialization is a core differentiator from more loosely typed clients — request construction and response parsing both benefit from compile-time checking against the application's own domain classes.

### Object Mapping

**Key Points**
- Application POJOs used as index/search targets are mapped to and from JSON using standard Jackson annotations (`@JsonProperty`, etc.) where field names need to differ from the Elasticsearch field names, similar to how Jackson is used in typical Java JSON-processing contexts outside of Elasticsearch entirely.
- Because the client is strongly typed end-to-end, changes to an application's domain model and a mismatch against the actual index mapping surface as compile-time or deserialization-time errors, rather than silent field-drop issues that a loosely typed client might not catch until data is inspected.

### Async Usage

**Key Points**
- An asynchronous variant, `ElasticsearchAsyncClient`, mirrors the synchronous client's API surface but returns `CompletableFuture`-wrapped results instead of blocking, fitting into reactive or non-blocking application architectures.
- The async and sync clients share the same underlying transport configuration, so switching between them for different parts of an application doesn't require separate connection setup.

```java
ElasticsearchAsyncClient asyncClient = new ElasticsearchAsyncClient(transport);

CompletableFuture<SearchResponse<Product>> future =
    asyncClient.search(s -> s.index("products"), Product.class);
```

### Bulk Operations

**Key Points**
- The Java client exposes a `BulkIngester` helper, analogous in purpose to other clients' bulk helpers (covered in the previous topic), which batches individual index/update/delete operations and automatically flushes them based on configurable size, count, or time thresholds.
- This avoids applications needing to manually track batch size and timing for efficient bulk indexing, particularly useful for high-throughput ingestion scenarios processing a continuous stream of documents.

```java
BulkIngester<Void> ingester = BulkIngester.of(b -> b
    .client(client)
    .maxOperations(1000)
    .flushInterval(5, TimeUnit.SECONDS)
);

ingester.add(op -> op.index(idx -> idx
    .index("products")
    .document(product)
));
```

### Migration from the Legacy High-Level REST Client

[Inference] The current typed `elasticsearch-java` client succeeded an older High Level REST Client (HLRC), and applications still running on the older client generally benefit from migrating to the current typed client for continued feature support and the type-safety advantages described above, though the specific migration path and how much rework is required depends on how deeply an existing codebase is coupled to the older client's API shapes.

### Related Topics

- **Official clients overview** (previous topic) for cross-language comparison of client design patterns
- **BulkIngester configuration options** in depth — flush thresholds, concurrent request limits, listener callbacks
- **Jackson JSON mapping customization** for complex domain object serialization needs
- **ElasticsearchAsyncClient** patterns for reactive application integration
- **API key and TLS configuration** specific to the Java client's `RestClient` builder
- **Legacy High Level REST Client (HLRC) migration guide** for applications still on the older client
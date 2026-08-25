## Official Clients Overview

### Overview

Elastic maintains official client libraries for interacting with Elasticsearch programmatically across a range of languages, providing idiomatic wrappers around the REST API rather than requiring applications to construct raw HTTP requests by hand. Using an official client is the standard approach for production application code, as distinct from the Dev Tools Console covered previously, which is an interactive UI tool.

### Supported Languages

**Key Points**
- Elastic publishes and maintains official clients for a range of languages, commonly including Java, Python (`elasticsearch-py`), Node.js/JavaScript (`@elastic/elasticsearch`), Go, .NET, PHP, Ruby, and Perl, among others.
- [Unverified] The exact list of officially supported languages, and each client's current feature parity with the REST API, changes over time as Elastic adds or deprecates clients, so current documentation should be checked when selecting a client for a new project.
- Community-maintained clients also exist for additional languages, distinct from Elastic's own officially maintained set, with varying levels of completeness and maintenance activity.

### Common Design Patterns Across Clients

**Key Points**
- Most official clients mirror the REST API's structure closely, exposing methods that map to the equivalent HTTP endpoint (e.g., a `search` method corresponds to `POST /_search`), which makes API documentation and client documentation cross-referenceable.
- Clients typically support both synchronous and asynchronous usage, though which mode is idiomatic default varies by language and its ecosystem conventions (e.g., Python's `elasticsearch-py` offers a separate async client module, while Node.js's client is Promise-based by default).
- Request and response bodies are generally represented as native language data structures (dicts in Python, objects in JavaScript, structs in Go) rather than requiring manual JSON string construction, though raw JSON/body access is typically still available for advanced or dynamic query construction.

### Basic Usage Example (Python)

```python
from elasticsearch import Elasticsearch

client = Elasticsearch(
    "https://es-node:9200",
    api_key="your-api-key"
)

response = client.search(
    index="my-index",
    query={"match": {"title": "elasticsearch"}}
)

for hit in response["hits"]["hits"]:
    print(hit["_source"])
```

### Diagram: Client Library Position in an Application

<svg width="100%" viewBox="0 0 680 260" role="img"><title>Position of an official client library within an application stack (svg_diagram)</title><desc>Application code calls idiomatic client library methods, which translate into REST API HTTP requests sent to the Elasticsearch cluster, with responses deserialized back into native data structures.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="40" y="90" width="160" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="120" y="110" text-anchor="middle" dominant-baseline="central">Application code</text>
<text class="ts" x="120" y="130" text-anchor="middle" dominant-baseline="central">client.search(...)</text>
</g>

<line x1="200" y1="118" x2="240" y2="118" class="arr" marker-end="url(#arrow)" />

<g class="node c-teal">
<rect x="240" y="90" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="330" y="110" text-anchor="middle" dominant-baseline="central">Official client library</text>
<text class="ts" x="330" y="130" text-anchor="middle" dominant-baseline="central">Builds HTTP request</text>
</g>

<line x1="420" y1="118" x2="460" y2="118" class="arr" marker-end="url(#arrow)" />

<g class="node c-coral">
<rect x="460" y="90" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="550" y="110" text-anchor="middle" dominant-baseline="central">Elasticsearch cluster</text>
<text class="ts" x="550" y="130" text-anchor="middle" dominant-baseline="central">REST API</text>
</g>

<line x1="550" y1="146" x2="330" y2="190" class="arr" marker-end="url(#arrow)" />
<text class="ts" x="440" y="175" text-anchor="middle">JSON response</text>
<line x1="330" y1="220" x2="150" y2="190" class="arr" marker-end="url(#arrow)" />
<text class="ts" x="240" y="215" text-anchor="middle">Native objects</text>
</svg>

### Connection Configuration

**Key Points**
- Clients typically accept one or more node URLs, and most support providing multiple hosts for the client's built-in connection pooling and round-robin/failover request distribution across nodes, though the exact behavior when multiple hosts are configured varies by client version.
- Authentication is commonly configured via API keys, basic auth (username/password), or a bearer token, with API keys generally being the recommended approach for application-to-cluster authentication in current guidance, since API keys can be scoped to specific privileges and revoked independently of a user account's credentials.
- TLS/certificate configuration (CA certificate path, or disabling certificate verification for development-only setups) is typically a required connection setting for clusters running with security enabled, which is the default for current Elasticsearch versions.

### Retry and Timeout Configuration

**Key Points**
- Clients generally expose configurable request timeout and retry-on-failure settings, letting an application tune how long to wait for a response and whether/how many times to automatically retry a failed request before raising an error to application code.
- [Inference] Retry behavior should generally be considered carefully for non-idempotent operations (like an index request without an explicit document ID, which could create a duplicate on retry after an ambiguous failure), since blind automatic retries are safer for read operations than for certain write operations, though the specific safe-retry semantics depend on the exact operation and client configuration.

### Bulk Helpers

**Key Points**
- Most official clients provide a bulk helper utility that simplifies constructing and sending `_bulk` API requests, handling the batching, retry-on-partial-failure, and response parsing that would otherwise need to be implemented manually against the raw bulk API.
- These helpers commonly accept a generator or iterable of documents/actions, streaming them into appropriately sized bulk requests rather than requiring the whole document set to be held in memory as one giant request.

```python
from elasticsearch.helpers import bulk

actions = [
    {"_index": "my-index", "_source": {"field": "value1"}},
    {"_index": "my-index", "_source": {"field": "value2"}},
]
bulk(client, actions)
```

### Version Compatibility

**Key Points**
- Client libraries are versioned to correspond with specific Elasticsearch server versions, and using a client version significantly mismatched from the server version can result in unsupported request/response formats or missing features.
- [Unverified] The specific compatibility policy (e.g., how many major versions of skew are supported between client and server) varies by client and has changed across Elastic's release history, so current documentation should be checked when planning an upgrade involving both client and server version changes.

### Related Topics

- **API key authentication** setup and privilege scoping in depth
- **The `_bulk` API** underlying mechanics that client bulk helpers wrap
- **Async client usage patterns** per language, for high-concurrency application scenarios
- **Elasticsearch security features** (TLS, role-based access control) and their client-side configuration requirements
- **Dev Tools Console** (previous topic) as the interactive complement to programmatic client usage during development
- **Connection pooling and node discovery/sniffing** behavior differences across client implementations
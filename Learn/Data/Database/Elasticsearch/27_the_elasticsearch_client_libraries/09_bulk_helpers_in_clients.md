## Bulk Helpers in Clients

### Overview

Bulk helpers are convenience utilities provided by official Elasticsearch client libraries that wrap the low-level `_bulk` API. Rather than requiring the developer to manually construct newline-delimited JSON (NDJSON) payloads, track buffer sizes, handle retries, and manage backpressure, the helper abstracts this into an iterator- or stream-based interface. The developer supplies a sequence of documents (and optionally actions), and the helper handles chunking, serialization, sending, and error surfacing.

**Key Points**

- Bulk helpers exist because the raw `_bulk` API is low-level: it expects a single request body made of alternating action/metadata lines and source lines, separated by newlines, with a trailing newline.
- Helpers are language-idiomatic wrappers — the Python client's `streaming_bulk`/`parallel_bulk`, the Node.js client's `client.helpers.bulk`, and the Java/`.NET` clients' equivalent bulk ingesters all solve the same problem differently, matching the concurrency and iterator conventions of their host language.
- They typically manage three concerns automatically: **chunking** (grouping documents into request-sized batches), **concurrency** (issuing multiple bulk requests in parallel), and **error handling** (retrying retryable failures like `429` responses).

### Why Not Call `_bulk` Directly

Manually building bulk requests is error-prone and repetitive:

- NDJSON formatting requires exact newline placement; a malformed body causes the entire request to fail parsing.
- Without chunking logic, a large document set either gets sent as one enormous request (risking `circuit_breaking_exception` or timeout) or requires hand-rolled batching code.
- The `_bulk` response is a flat array of per-item results; identifying which specific documents failed, and why, requires manual parsing of a `items` array where success/failure is nested per action type (`index`, `create`, `update`, `delete`).
- Retry logic for transient failures (queue capacity rejections, node overload) is easy to get wrong — retrying too aggressively worsens the very overload causing the failures.

Bulk helpers exist specifically to remove this repeated, easy-to-get-wrong boilerplate from application code.

### Common Helper Behavior Across Clients

While APIs differ, most official bulk helpers share this general shape:

1. **Input**: an iterable/generator of documents or actions, so the full dataset never needs to be loaded into memory at once.
2. **Chunking**: documents are grouped into batches based on a configurable item count and/or byte size threshold before each batch is sent as one `_bulk` call.
3. **Action inference**: many helpers default to `index` actions when given plain documents, but accept explicit action types (`index`, `create`, `update`, `delete`) via a reserved key or field convention (e.g., `_op_type` in the Python client).
4. **Retry**: retryable errors (typically `429 Too Many Requests` from queue saturation) are retried with backoff up to a configurable maximum; non-retryable errors (like a mapping conflict) are surfaced immediately.
5. **Result reporting**: helpers report success/failure counts and, in most cases, expose the individual failed items with their error details.

===MERMAID_DIAGRAM===

flowchart LR

A[Document iterator / generator] --> B[Bulk helper]

B --> C{Chunk by count / bytes}

C --> D[Serialize to NDJSON]

D --> E[POST _bulk]

E --> F{Response items}

F -->|success| G[Count success]

F -->|retryable error e.g. 429| H[Retry with backoff]

F -->|non-retryable error| I[Surface failure]

H --> E

### Python Client: `streaming_bulk` and `parallel_bulk`

The Python client (`elasticsearch-py`, via `elasticsearch.helpers`) offers several bulk utilities:

- **`bulk()`**: consumes an entire generator into memory, chunks it, and sends requests sequentially. Simplest to use, returns a `(success_count, errors)` tuple.
- **`streaming_bulk()`**: a generator-based version that yields `(ok, response)` per item as results come back, avoiding the need to hold all results in memory. Preferred for very large datasets.
- **`parallel_bulk()`**: like `streaming_bulk()` but issues chunks concurrently across a thread pool, trading memory/ordering guarantees for throughput.

**Example**

```python
from elasticsearch import Elasticsearch
from elasticsearch.helpers import streaming_bulk

es = Elasticsearch("https://localhost:9200")

def generate_docs():
    for i in range(10000):
        yield {
            "_index": "logs",
            "_id": i,
            "_source": {"message": f"log entry {i}", "level": "info"}
        }

success_count = 0
error_count = 0

for ok, result in streaming_bulk(es, generate_docs(), chunk_size=500, raise_on_error=False):
    if ok:
        success_count += 1
    else:
        error_count += 1
        print(f"Failed: {result}")

print(f"Indexed: {success_count}, Failed: {error_count}")
```

Each yielded document dict may include `_op_type` (default `"index"`) to control the action, along with `_index`, `_id`, and `_source`.

### Node.js Client: `client.helpers.bulk`

The Node.js client exposes a `helpers.bulk()` method that accepts a `datasource` (array, generator, async generator, or readable stream) and an `onDocument` callback that maps each source item to a bulk action.

**Example**

```javascript
const { Client } = require('@elastic/elasticsearch');
const client = new Client({ node: 'https://localhost:9200' });

async function* generateDocs() {
  for (let i = 0; i < 10000; i++) {
    yield { id: i, message: `log entry ${i}`, level: 'info' };
  }
}

const result = await client.helpers.bulk({
  datasource: generateDocs(),
  onDocument(doc) {
    return { index: { _index: 'logs', _id: doc.id.toString() } };
  },
  flushBytes: 5_000_000,
  concurrency: 4,
  retries: 3,
  onDrop(doc) {
    console.error('Dropped document:', doc);
  }
});

console.log(`Indexed: ${result.successful}, Failed: ${result.failed}`);
```

This helper manages internal concurrency (`concurrency` option controls parallel in-flight bulk requests) and byte-based flushing (`flushBytes`) alongside count-based flushing (`flushInterval` for time-based flush).

### Java Client: `BulkIngester`

The Java client provides `BulkIngester`, built on top of the low-level `BulkProcessor` concept from earlier client generations. It accepts documents added asynchronously and flushes based on configurable triggers.

**Example**

```java
BulkIngester<Void> ingester = BulkIngester.of(b -> b
    .client(esClient)
    .maxOperations(1000)
    .maxSize(5_000_000)
    .flushInterval(5, TimeUnit.SECONDS)
);

for (int i = 0; i < 10000; i++) {
    final int id = i;
    ingester.add(op -> op
        .index(idx -> idx
            .index("logs")
            .id(String.valueOf(id))
            .document(new LogEntry("log entry " + id, "info"))
        )
    );
}

ingester.close();
```

`BulkIngester` flushes when any configured threshold — operation count, byte size, or time interval — is reached, whichever comes first.

### Chunking Strategy: Count vs. Byte Size

Most helpers support two independent thresholds, and a flush is triggered when **either** is reached:

- **Item count** (e.g., 500–1,000 documents per chunk): straightforward, but a chunk of small documents behaves very differently from a chunk of large documents under the same count limit.
- **Byte size** (e.g., 5–15 MB per chunk): protects against oversized requests regardless of document count, which matters more for avoiding `circuit_breaking_exception` on the cluster side.

$$\text{chunk\_ready} = (\text{doc\_count} \geq N) \lor (\text{byte\_size} \geq S)$$

Where $N$ is the configured max operations and $S$ is the configured max byte size. Tuning both together, rather than relying on one, gives more predictable request sizes when document sizes vary widely within a dataset. [Inference] The specific optimal values for $N$ and $S$ are workload- and cluster-dependent and are not fixed by the client library itself.

### Error Handling and Retry Semantics

Bulk helpers generally classify per-item failures into two categories:

- **Retryable**: most commonly `429` (`es_rejected_execution_exception`) from thread pool queue saturation. Helpers retry these individual items (or the containing chunk, depending on client) with exponential backoff, up to a `max_retries` setting.
- **Non-retryable**: mapping errors, version conflicts (on `create` with a duplicate `_id`), or malformed documents. These are surfaced to the caller immediately without retry, since retrying them will not change the outcome.

[Inference] Some clients (e.g., the Node.js helper's `onDrop` callback) expose only permanently-failed items after retries are exhausted, while others (e.g., Python's `streaming_bulk`) surface every individual item result including transient ones as they resolve — the exact granularity of what's surfaced varies by client version and should be checked against the specific client's current documentation.

### Ordering Guarantees

- Sequential helpers (Python's `bulk()`, `streaming_bulk()`) preserve document ordering relative to input, since chunks are sent one at a time.
- Concurrent helpers (Python's `parallel_bulk()`, Node.js `concurrency > 1`, Java's `BulkIngester` with async flush) do **not** guarantee that chunks complete or land in input order, since multiple chunks are in flight simultaneously.
- [Unverified] Whether a specific application requires strict ordering (e.g., for event-sourcing style writes to the same document `_id`) determines whether concurrent bulk helpers are appropriate; this is workload-specific and cannot be generalized.

### Choosing Chunk Size and Concurrency

Practical tuning considerations:

- Smaller chunks reduce the blast radius of a single failed request but increase HTTP overhead per document.
- Larger chunks improve throughput per request but increase memory pressure and the risk of hitting `circuit_breaking_exception` on nodes with constrained heap.
- Increasing concurrency (parallel bulk requests) increases indexing throughput up to the point where it saturates the cluster's bulk thread pool queue, after which additional concurrency mainly produces more `429` rejections rather than more throughput.
- [Inference] A commonly cited starting point in community guidance is 5–15 MB per bulk request and low single-digit concurrency, then adjusting based on observed rejection rates and node resource utilization — but this is a heuristic starting point, not a guaranteed-correct configuration for any given cluster.

### Related Topics

- The low-level `_bulk` API request/response format and NDJSON structure
- Circuit breakers and `circuit_breaking_exception` causes
- Thread pool queue sizing and `es_rejected_execution_exception`
- Ingest pipelines combined with bulk indexing
- Index refresh interval tuning during bulk loads
- Reindexing large datasets with the `_reindex` API vs. client-side bulk helpers
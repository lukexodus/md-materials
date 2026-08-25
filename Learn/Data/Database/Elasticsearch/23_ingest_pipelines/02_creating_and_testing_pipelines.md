## Ingest Pipelines — Creating and Testing Pipelines

### Overview

An ingest pipeline is a named sequence of processors that transform documents before they are indexed into Elasticsearch. Each processor performs a specific transformation — renaming a field, parsing a date, extracting values with a regular expression, appending values to an array, and so on. Documents pass through the processors in the order they are defined, and the output of one processor becomes the input of the next.

Ingest pipelines run on ingest nodes (or nodes with the ingest role) as part of the indexing path, before the document is written to Lucene. This differs from Logstash-style transformation, which happens outside the cluster, and from runtime fields, which transform data at query time rather than at index time.

### Why Use an Ingest Pipeline

**Key Points**

- Centralizes transformation logic inside the cluster rather than in an external ETL layer
- Ensures every document written through the pipeline receives consistent processing
- Useful for enrichment (adding fields), normalization (renaming/reformatting), parsing (grok, dissect, CSV), and cleanup (removing sensitive fields) prior to indexing
- Reduces the need for client-side preprocessing logic that must be duplicated across every ingesting application

### Anatomy of a Pipeline

A pipeline definition consists of:

- `description` — a human-readable summary of the pipeline's purpose
- `processors` — an ordered array of processor objects, each with a type name as the key and its configuration as the value
- `on_failure` — an optional array of processors executed if any processor in the main list throws an exception

```json
PUT _ingest/pipeline/my-pipeline
{
  "description": "Parses log lines and adds metadata",
  "processors": [
    {
      "set": {
        "field": "ingested_at",
        "value": "{{{_ingest.timestamp}}}"
      }
    },
    {
      "grok": {
        "field": "message",
        "patterns": ["%{TIMESTAMP_ISO8601:log_timestamp} %{LOGLEVEL:log_level} %{GREEDYDATA:log_message}"]
      }
    },
    {
      "remove": {
        "field": "message"
      }
    }
  ],
  "on_failure": [
    {
      "set": {
        "field": "error.message",
        "value": "{{{_ingest.on_failure_message}}}"
      }
    }
  ]
}
```

### Common Processors

| Processor | Purpose |
| --- | --- |
| `set` | Sets a field to a static value or a Mustache template expression |
| `remove` | Removes one or more fields |
| `rename` | Renames a field |
| `convert` | Casts a field's value to a different type (integer, float, boolean, string, auto) |
| `grok` | Extracts structured fields from unstructured text using named patterns |
| `dissect` | Extracts fields using a lightweight delimiter-based syntax (faster than grok, less flexible) |
| `date` | Parses a string into a date field, normalizing to a consistent format |
| `json` | Parses a JSON-encoded string field into an object |
| `split` | Splits a string field into an array using a separator |
| `append` | Adds a value to an array field, creating the array if it does not exist |
| `foreach` | Runs a processor against each element of an array field |
| `pipeline` | Invokes another pipeline, enabling composition |
| `script` | Runs an inline Painless script for arbitrary transformation logic |

This list covers the processors most commonly used in day-to-day pipeline construction. Elasticsearch ships with a considerably larger built-in processor set (geoip, user_agent, enrich, csv, kv, and others) for more specialized use cases.

### Pipeline Execution Flow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 260">
<text x="450" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a1a">Ingest Pipeline Execution Flow (svg_diagram)</text>
<rect x="20" y="90" width="130" height="60" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
<text x="85" y="115" text-anchor="middle" font-size="12" fill="#1a1a1a">Index Request</text>
<text x="85" y="132" text-anchor="middle" font-size="11" fill="#555">?pipeline=my-pipeline</text>
<path d="M150 120 L200 120" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
<rect x="200" y="90" width="130" height="60" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
<text x="265" y="115" text-anchor="middle" font-size="12" fill="#1a1a1a">Processor 1</text>
<text x="265" y="132" text-anchor="middle" font-size="11" fill="#555">set</text>
<path d="M330 120 L380 120" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
<rect x="380" y="90" width="130" height="60" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
<text x="445" y="115" text-anchor="middle" font-size="12" fill="#1a1a1a">Processor 2</text>
<text x="445" y="132" text-anchor="middle" font-size="11" fill="#555">grok</text>
<path d="M510 120 L560 120" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
<rect x="560" y="90" width="130" height="60" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
<text x="625" y="115" text-anchor="middle" font-size="12" fill="#1a1a1a">Processor 3</text>
<text x="625" y="132" text-anchor="middle" font-size="11" fill="#555">remove</text>
<path d="M690 120 L740 120" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
<rect x="740" y="90" width="140" height="60" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
<text x="810" y="115" text-anchor="middle" font-size="12" fill="#1a1a1a">Lucene Index</text>
<text x="810" y="132" text-anchor="middle" font-size="11" fill="#555">document written</text>
<path d="M445 150 L445 190" stroke="#ea4335" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrowred)" />
<text x="445" y="205" text-anchor="middle" font-size="11" fill="#ea4335">on exception</text>
<rect x="360" y="210" width="170" height="45" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
<text x="445" y="237" text-anchor="middle" font-size="12" fill="#1a1a1a">on_failure processors</text>
</svg>

### Creating a Pipeline

Pipelines are created (or updated) via the `PUT _ingest/pipeline/<id>` API. The pipeline is stored in the cluster state, not tied to a specific index, and can be referenced by any index request.

```json
PUT _ingest/pipeline/user-agent-pipeline
{
  "description": "Parses user agent strings into structured fields",
  "processors": [
    {
      "user_agent": {
        "field": "agent_raw",
        "target_field": "user_agent"
      }
    },
    {
      "remove": {
        "field": "agent_raw",
        "ignore_missing": true
      }
    }
  ]
}
```

Retrieving a pipeline definition:

```json
GET _ingest/pipeline/user-agent-pipeline
```

Listing all pipelines (wildcard supported):

```json
GET _ingest/pipeline/*
```

Deleting a pipeline:

```json
DELETE _ingest/pipeline/user-agent-pipeline
```

### Testing a Pipeline with the Simulate API

Before applying a pipeline to real indexing traffic, the `_ingest/pipeline/_simulate` endpoint runs the pipeline against sample documents without persisting anything to an index. This is the primary tool for iterative pipeline development.

```json
POST _ingest/pipeline/_simulate
{
  "pipeline": {
    "processors": [
      {
        "grok": {
          "field": "message",
          "patterns": ["%{TIMESTAMP_ISO8601:log_timestamp} %{LOGLEVEL:log_level} %{GREEDYDATA:log_message}"]
        }
      }
    ]
  },
  "docs": [
    {
      "_source": {
        "message": "2026-08-24T10:15:00Z ERROR Connection refused"
      }
    }
  ]
}
```

An already-stored pipeline can also be simulated by ID instead of inlining the definition:

```json
POST _ingest/pipeline/my-pipeline/_simulate
{
  "docs": [
    { "_source": { "message": "2026-08-24T10:15:00Z ERROR Connection refused" } },
    { "_source": { "message": "2026-08-24T10:15:03Z INFO Health check OK" } }
  ]
}
```

**Output**

```json
{
  "docs": [
    {
      "doc": {
        "_index": "_index",
        "_id": "_id",
        "_source": {
          "message": "2026-08-24T10:15:00Z ERROR Connection refused",
          "log_timestamp": "2026-08-24T10:15:00Z",
          "log_level": "ERROR",
          "log_message": "Connection refused"
        },
        "_ingest": {
          "timestamp": "2026-08-24T10:15:00.512Z"
        }
      }
    }
  ]
}
```

### Verbose Simulation

Adding `?verbose` to the simulate request returns the intermediate document state after every processor, which is essential for diagnosing exactly which processor introduced an unexpected value or failed silently.

```json
POST _ingest/pipeline/_simulate?verbose
{
  "pipeline": {
    "processors": [
      { "set": { "field": "status", "value": "received" } },
      { "convert": { "field": "response_code", "type": "integer" } }
    ]
  },
  "docs": [
    { "_source": { "response_code": "200" } }
  ]
}
```

With `verbose`, the response includes a `processor_results` array, one entry per processor, each showing the document snapshot after that step ran. This lets a document's transformation be traced processor-by-processor rather than only inspecting the final state.

### Handling Failures During Simulation

If a processor throws (for example, `grok` failing to match, or `convert` receiving a non-numeric string), the simulate response reports the error inline for that specific document rather than failing the entire request, provided `ignore_failure` is not set to swallow it silently.

```json
{
  "docs": [
    {
      "doc": {
        "_source": { "response_code": "not-a-number" },
        "_index": "_index",
        "_id": "_id"
      },
      "error": {
        "type": "illegal_argument_exception",
        "reason": "unable to convert [not-a-number] to type [integer]"
      }
    }
  ]
}
```

**Key Points**

- Per-processor failure handling can be scoped with `ignore_failure: true` on an individual processor, which skips that processor's failure without triggering `on_failure`
- Pipeline-level `on_failure` catches any unhandled processor exception and can route the document into an error-tagging path instead of rejecting it outright
- Testing with representative malformed input during development surfaces these failure paths before production traffic does

### Applying a Pipeline at Index Time

A pipeline can be specified per request:

```json
PUT my-index/_doc/1?pipeline=my-pipeline
{
  "message": "2026-08-24T10:15:00Z ERROR Connection refused"
}
```

Or set as a default pipeline on the index itself, so every write to that index runs through it automatically without the caller specifying `?pipeline`:

```json
PUT my-index/_settings
{
  "index.default_pipeline": "my-pipeline"
}
```

A `final_pipeline` setting also exists, which runs after the default (or request-specified) pipeline unconditionally, commonly used to enforce a last-step guarantee such as always setting an `event.ingested` timestamp.

```json
PUT my-index/_settings
{
  "index.final_pipeline": "always-timestamp-pipeline"
}
```

### Pipeline Composition with the `pipeline` Processor

Complex ingestion logic is often split into smaller, single-purpose pipelines composed together with the `pipeline` processor, rather than written as one large monolithic pipeline. This improves reusability across indices with different but overlapping transformation needs.

```json
PUT _ingest/pipeline/combined-pipeline
{
  "processors": [
    { "pipeline": { "name": "user-agent-pipeline" } },
    { "pipeline": { "name": "geoip-pipeline" } }
  ]
}
```

```mermaid
flowchart LR
    A[Incoming Document] --> B[combined-pipeline]
    B --> C[user-agent-pipeline]
    C --> D[geoip-pipeline]
    D --> E[Indexed Document]
```

### Conditional Processor Execution

Any processor accepts an `if` field containing a Painless expression, allowing conditional logic without splitting into separate pipelines.

```json
{
  "set": {
    "if": "ctx.status_code != null && ctx.status_code >= 500",
    "field": "alert_level",
    "value": "critical"
  }
}
```

### Field Access and Templating

Processor configuration values support Mustache-style templating using `{{field}}` (HTML-escaped) or `{{{field}}}` (unescaped) to reference existing document fields dynamically.

```json
{
  "set": {
    "field": "summary",
    "value": "{{{log_level}}}: {{{log_message}}}"
  }
}
```

### Reroute Processor

The `reroute` processor changes the destination index of a document during ingestion, commonly used with data streams to route documents into a different backing stream based on field values (for example, splitting logs by `service.name` into per-service data streams).

```json
{
  "reroute": {
    "field": "service.name",
    "target": "logs-{{{service.name}}}-default"
  }
}
```

### Practical Example — End-to-End Development Cycle

**Example**

1. Draft the pipeline definition locally without storing it
2. Run it through `_simulate` with a small, representative set of sample documents covering both typical and edge-case input
3. Add `?verbose` when a processor's output does not match expectations
4. Iterate on processor configuration until simulation output is correct for all sample documents
5. `PUT` the finalized pipeline to store it
6. Reference it via `?pipeline=` on a small batch of real writes, or attach it as `index.default_pipeline` on a test index
7. Monitor `_nodes/stats/ingest` for per-pipeline processor timing and failure counts once live

```json
GET _nodes/stats/ingest?filter_path=nodes.*.ingest.pipelines
```

This returns per-pipeline counters — `count`, `time_in_millis`, `current`, and `failed` — useful for confirming that a newly deployed pipeline is being exercised as expected and is not silently erroring in production.

### Conclusion

Ingest pipelines provide a structured, cluster-native way to transform, enrich, and normalize documents before indexing, avoiding the need for a separate external processing layer for many common transformation tasks. The `_simulate` API is the central tool for pipeline development, since it allows processor logic to be validated — including failure paths — against representative documents before the pipeline is ever attached to live indexing traffic. Verbose simulation, per-processor `ignore_failure`, and pipeline-level `on_failure` together give fine-grained control over how malformed input is handled rather than allowing it to silently corrupt indexed data or reject writes outright.

### Next Steps

- Enrich processor and enrich policies for lookup-based field augmentation
- geoip and geoip database management (including offline database updates)
- Pipeline performance considerations and ingest node sizing
- Data streams and their interaction with default/final pipelines and the reroute processor
- Painless scripting fundamentals for the `script` processor
- Reindexing with pipelines applied (`_reindex` with a destination pipeline)
- Monitoring ingest node load via `_nodes/stats` and ingest pipeline circuit breakers
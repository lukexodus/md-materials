## Failure Handling in Pipelines

### Overview

Ingest pipelines process documents through a sequence of processors, and any processor can fail — a `grok` pattern that doesn't match, a `date` parse on a malformed timestamp, a `convert` on non-numeric text. Elasticsearch provides several mechanisms to control what happens when a processor fails: per-processor recovery, pipeline-level fallback, and bulk-request-level error visibility.

### Default Failure Behavior

**Key Points**
- By default, if a processor fails, the entire pipeline aborts for that document, and the document is rejected — it is not indexed.
- For a `_bulk` request, one document's pipeline failure does not stop other documents in the same bulk request from being processed; each document's outcome is independent and reported separately in the bulk response.
- Without any failure handling configured, a systematic upstream issue (e.g., a log format change breaking a `grok` pattern) causes affected documents to simply fail to index, which can go unnoticed unless bulk response errors are actively monitored.

### The `on_failure` Parameter (Per-Processor)

**Key Points**
- Any processor can define its own `on_failure` array of processors, which execute only if that specific processor fails, instead of aborting the pipeline.
- Within an `on_failure` block, special metadata fields become available: `_ingest.on_failure_message`, `_ingest.on_failure_processor_type`, `_ingest.on_failure_processor_tag`, and `_ingest.on_failure_pipeline`, letting the fallback logic record what went wrong.
- After the `on_failure` processors complete successfully, the pipeline continues to the next processor as normal — the failure is considered handled.

```json
{
  "processors": [
    {
      "grok": {
        "field": "message",
        "patterns": ["%{COMBINEDAPACHELOG}"],
        "on_failure": [
          {
            "set": {
              "field": "grok_failure",
              "value": "{{ _ingest.on_failure_message }}"
            }
          }
        ]
      }
    }
  ]
}
```

### Pipeline-Level `on_failure`

**Key Points**
- A pipeline can also define its own top-level `on_failure` array, which catches any processor failure not already handled by that processor's own `on_failure`.
- This acts as a catch-all fallback for the whole pipeline, useful for consistent error tagging without repeating the same `on_failure` block on every individual processor.

```json
{
  "processors": [
    { "grok": { "field": "message", "patterns": ["%{COMBINEDAPACHELOG}"] } },
    { "date": { "field": "timestamp", "formats": ["dd/MMM/yyyy:HH:mm:ss Z"] } }
  ],
  "on_failure": [
    {
      "set": {
        "field": "error.pipeline_failure",
        "value": "{{ _ingest.on_failure_message }}"
      }
    }
  ]
}
```

### Diagram: Failure Handling Flow

<svg width="100%" viewBox="0 0 680 380" role="img"><title>Pipeline failure handling flow through per-processor and pipeline-level fallback (svg_diagram)</title><desc>A processor failure first checks for a per-processor on_failure handler, then falls back to the pipeline-level on_failure handler, and only rejects the document if neither is defined.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="240" y="20" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="40" text-anchor="middle" dominant-baseline="central">Processor executes</text>
<text class="ts" x="340" y="60" text-anchor="middle" dominant-baseline="central">e.g. grok, date, convert</text>
</g>

<line x1="340" y1="76" x2="340" y2="110" class="arr" marker-end="url(#arrow)" />
<g class="c-gray">
<rect x="270" y="110" width="140" height="40" rx="8" stroke-width="0.5" />
<text class="ts" x="340" y="130" text-anchor="middle" dominant-baseline="central">Fails?</text>
</g>

<line x1="410" y1="130" x2="470" y2="130" class="arr" marker-end="url(#arrow)" />
<text class="ts" x="500" y="126" text-anchor="middle">yes</text>

<line x1="270" y1="130" x2="140" y2="290" class="arr" marker-end="url(#arrow)" />
<text class="ts" x="180" y="200" text-anchor="middle">no</text>

<g class="node c-coral">
<rect x="440" y="160" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="540" y="178" text-anchor="middle" dominant-baseline="central">Processor on_failure?</text>
<text class="ts" x="540" y="198" text-anchor="middle" dominant-baseline="central">Handle and continue</text>
</g>

<line x1="440" y1="200" x2="380" y2="240" class="arr" marker-end="url(#arrow)" />
<text class="ts" x="380" y="222" text-anchor="middle">no on_failure</text>

<g class="node c-amber">
<rect x="240" y="240" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="258" text-anchor="middle" dominant-baseline="central">Pipeline on_failure?</text>
<text class="ts" x="340" y="278" text-anchor="middle" dominant-baseline="central">Handle and finish</text>
</g>

<line x1="240" y1="270" x2="180" y2="310" class="arr" marker-end="url(#arrow)" />
<text class="ts" x="180" y="292" text-anchor="middle">no on_failure</text>

<g class="node c-red">
<rect x="40" y="310" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="140" y="328" text-anchor="middle" dominant-baseline="central">Document rejected</text>
<text class="ts" x="140" y="348" text-anchor="middle" dominant-baseline="central">Reported in bulk response</text>
</g>

<line x1="140" y1="150" x2="140" y2="290" class="arr" marker-end="url(#arrow)" />
<g class="node c-teal">
<rect x="40" y="240" width="200" height="0" opacity="0" />
</g>
</svg>

### Ignoring Failures Entirely with `ignore_failure`

**Key Points**
- Setting `ignore_failure: true` on a processor causes any failure from that specific processor to be silently ignored, and the pipeline continues to the next processor as if nothing happened.
- This differs from `on_failure` in that no fallback logic runs at all — the failure is simply discarded, with no record kept unless something else in the pipeline separately checks for the field the processor would have set.
- [Inference] `ignore_failure` is best reserved for genuinely optional enrichment steps where the absence of the enriched field is an acceptable and expected outcome, rather than for processors whose success is important to downstream logic, since silently discarded failures make certain classes of upstream problems (e.g. a persistently broken parse pattern) invisible without an explicit audit.

```json
{
  "geoip": {
    "field": "client_ip",
    "target_field": "geo",
    "ignore_failure": true
  }
}
```

### `ignore_missing` vs. `on_failure`/`ignore_failure`

**Key Points**
- Several processors additionally support `ignore_missing`, which is distinct from failure handling — it specifically controls whether the processor is silently skipped (not failed) when the field it operates on doesn't exist in the document at all.
- `ignore_missing` addresses "the field isn't there," while `on_failure`/`ignore_failure` address "the processor ran into an error while operating on the field" (e.g. wrong type, unparseable value) — the two are complementary, and both are commonly set together on the same processor for robustness.

```json
{
  "convert": {
    "field": "response_time",
    "type": "integer",
    "ignore_missing": true,
    "on_failure": [
      { "set": { "field": "conversion_error", "value": true } }
    ]
  }
}
```

### Redirecting Failed Documents with the `failure` Data Stream Pattern

**Key Points**
- A common production pattern uses `on_failure` combined with a `set` processor (to tag the document with error metadata) and a `reroute` processor (or a subsequent `pipeline` processor call), sending failed documents to a separate index or data stream dedicated to ingestion failures rather than either silently dropping them or losing them as bulk-response-only errors.
- This preserves the original document content alongside the failure reason, allowing later inspection and reprocessing once the root cause (e.g. a grok pattern needing an update) is fixed, rather than the data being permanently lost.

```json
{
  "on_failure": [
    { "set": { "field": "error.message", "value": "{{ _ingest.on_failure_message }}" } },
    { "reroute": { "dataset": "failed-ingest" } }
  ]
}
```

### Monitoring Pipeline Failures

Bulk API responses include an `errors: true` flag at the top level when any document in the request failed, along with a per-item `error` object describing the failure — applications performing bulk indexing should check this flag and the per-item errors rather than assuming a 200 HTTP status means every document succeeded, since a bulk request can return 200 overall while individual documents within it failed.

### Related Topics

- **The `reroute` processor** in depth for failure-driven and content-driven document redirection
- **Simulate pipeline API** (`_ingest/pipeline/_simulate`) for testing failure paths before production deployment
- **Bulk API response structure** and correctly parsing per-item success/failure status
- **Dead letter queue patterns** for Logstash as a comparison point to the pipeline-failure-redirect pattern in Elasticsearch ingest
- **`ignore_missing` support matrix** across different processor types
- **Conditional processors** (previous topic) as the mechanism often combined with failure handling to build robust multi-format pipelines
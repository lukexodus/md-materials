## Conditional Processors

### Overview

Conditional processors let ingest pipeline processors run only when a specified condition is met, rather than unconditionally on every document. This allows a single pipeline to branch its behavior based on document content — applying different parsing logic to different log formats, skipping expensive processors when they're not needed, or routing enrichment based on field values.

### The `if` Parameter

**Key Points**
- Every processor in an ingest pipeline supports an optional `if` parameter containing a Painless script expression.
- The processor only executes when the `if` condition evaluates to `true`; otherwise it is skipped entirely and the document passes through unchanged by that processor.
- The condition has access to the document being processed via the `ctx` variable, allowing checks against any field's current value at that point in the pipeline.

```json
{
  "set": {
    "if": "ctx.status_code != null && ctx.status_code >= 500",
    "field": "alert_level",
    "value": "critical"
  }
}
```

### Common Condition Patterns

**Key Points**
- Checking field existence before acting on it, to avoid null-pointer errors when a field may or may not be present: `ctx.user_agent != null`.
- Comparing a field's value against a threshold or specific value: `ctx.response_time > 1000`.
- Checking a field's type or matching against a set of allowed values: `['error', 'critical', 'fatal'].contains(ctx.log_level)`.
- Combining multiple conditions with Painless's standard boolean operators (`&&`, `||`, `!`).

```json
{
  "grok": {
    "if": "ctx.message != null && ctx.log_type == 'nginx'",
    "field": "message",
    "patterns": ["%{COMBINEDAPACHELOG}"]
  }
}
```

### Null Safety in Conditions

Because `ctx` fields may not exist on every document a pipeline processes (documents can have inconsistent schemas, especially from varied log sources), conditions should generally check for `null` before accessing nested fields or comparing values, since accessing a genuinely missing field or calling a method on `null` throws a script execution error that can fail the whole document rather than simply skip the processor.

```json
{
  "if": "ctx.containsKey('http') && ctx.http.containsKey('response') && ctx.http.response.status_code >= 400"
}
```

`containsKey` checks for a field's presence without throwing, which is safer than direct dot-notation access when the field's existence is genuinely uncertain at that point in the pipeline.

### Diagram: Conditional Branching Within a Pipeline

<svg width="100%" viewBox="0 0 680 320" role="img"><title>Conditional processor branching within a single ingest pipeline (svg_diagram)</title><desc>A document enters a pipeline and flows through processors in sequence, where each processor's if condition determines whether it executes on that particular document or is skipped.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-gray">
<rect x="270" y="20" width="140" height="44" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="42" text-anchor="middle" dominant-baseline="central">Document in</text>
</g>

<line x1="340" y1="64" x2="340" y2="100" class="arr" marker-end="url(#arrow)" />

<g class="node c-blue">
<rect x="240" y="100" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="118" text-anchor="middle" dominant-baseline="central">grok processor</text>
<text class="ts" x="340" y="138" text-anchor="middle" dominant-baseline="central">if log_type == nginx</text>
</g>

<line x1="340" y1="156" x2="340" y2="190" class="arr" marker-end="url(#arrow)" />

<g class="node c-teal">
<rect x="240" y="190" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="208" text-anchor="middle" dominant-baseline="central">set processor</text>
<text class="ts" x="340" y="228" text-anchor="middle" dominant-baseline="central">if status_code &gt;= 500</text>
</g>

<line x1="340" y1="246" x2="340" y2="280" class="arr" marker-end="url(#arrow)" />

<g class="node c-gray">
<rect x="270" y="280" width="140" height="40" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="300" text-anchor="middle" dominant-baseline="central">Document out</text>
</g>

<text class="ts" x="580" y="128" text-anchor="middle">Runs only for</text>
<text class="ts" x="580" y="144" text-anchor="middle">nginx documents</text>
<line class="leader" x1="440" y1="128" x2="540" y2="128" />

<text class="ts" x="580" y="218" text-anchor="middle">Runs only when</text>
<text class="ts" x="580" y="234" text-anchor="middle">status is 5xx</text>
<line class="leader" x1="440" y1="218" x2="540" y2="218" />
</svg>

### Skipping Expensive Processors

**Key Points**
- Some processors — `geoip`, `user_agent`, `enrich`, and scripted processors — carry meaningfully more CPU/lookup cost than simple field manipulation processors like `set` or `rename`.
- Gating an expensive processor with an `if` condition so it only runs on documents where its output is actually needed (e.g., only run `geoip` when an `ip_address` field is present and non-null) avoids unnecessary cost on documents where the processor's work would be wasted.

```json
{
  "geoip": {
    "if": "ctx.client_ip != null && ctx.client_ip != ''",
    "field": "client_ip",
    "target_field": "geo"
  }
}
```

### Conditional Routing to Different Pipelines

**Key Points**
- The `pipeline` processor, combined with an `if` condition, allows one pipeline to conditionally invoke a different sub-pipeline based on document content, effectively branching processing logic at a coarser granularity than individual processors.
- This pattern is common for multi-format log ingestion, where a single entry pipeline inspects a field (like a `log_type` or `service.name` tag) and dispatches to the appropriate format-specific pipeline.

```json
{
  "pipeline": {
    "if": "ctx.service?.name == 'nginx'",
    "name": "nginx-log-pipeline"
  }
}
```

### `?.` Safe Navigation Operator

Painless supports the `?.` safe navigation operator (as shown in the pipeline example above), which returns `null` instead of throwing when the object before it is `null`, allowing `ctx.service?.name` to safely evaluate to `null` rather than error when `ctx.service` itself doesn't exist — a more concise alternative to chained `containsKey` checks for deeply nested optional fields.

### Failure Handling Interaction

**Key Points**
- If a condition itself throws an error (for example, comparing against a field whose type doesn't support the comparison), the processor's failure handling (`on_failure`, or the pipeline's overall failure behavior) applies to that error just as it would to a processor's own execution failure.
- This means condition expressions should be written defensively, since a poorly written condition can cause the exact kind of document-processing failure the conditional was meant to help avoid.

### Related Topics

- **Painless scripting language** fundamentals — syntax, available context variables, restrictions in the ingest context
- **The `pipeline` processor and pipeline chaining** for multi-stage document processing
- **`on_failure` handling** at both the processor and pipeline level
- **Common processors in depth** (`grok`, `dissect`, `geoip`, `user_agent`, `enrich`) and their individual performance characteristics
- **Simulate pipeline API** (`_ingest/pipeline/_simulate`) for testing conditional logic before deploying a pipeline to production
- **Reroute processor** as an alternative mechanism for conditionally directing documents to different data streams
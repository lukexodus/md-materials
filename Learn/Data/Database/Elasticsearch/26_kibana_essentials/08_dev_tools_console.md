## Dev Tools Console

### Overview

The Dev Tools Console is Kibana's built-in interface for issuing Elasticsearch API requests directly, without needing curl, Postman, or a client library. It provides syntax highlighting, autocomplete, request history, and formatted responses, making it the standard tool for ad hoc querying, debugging, and learning the Elasticsearch REST API.

### Console Syntax

**Key Points**
- The Console uses a simplified shorthand syntax instead of full curl commands — a request is written as `METHOD /path` followed by an optional JSON body, omitting the host, port, and boilerplate curl flags entirely.
- Multiple requests can be stacked in the same editor pane, each executed independently by placing the cursor within it and running it (via the play button or a keyboard shortcut), rather than needing to clear the pane between requests.
- Comments are supported using `//` or `#`, useful for annotating a saved collection of example requests within the same pane.

```
GET my-index/_search
{
  "query": {
    "match": {
      "title": "elasticsearch"
    }
  }
}

// Check cluster health
GET _cluster/health
```

### Autocomplete

**Key Points**
- The Console provides context-aware autocomplete for endpoint paths, query DSL keywords, and — when connected to a live cluster — actual index names and field names from the cluster's mappings.
- Autocomplete for field names specifically requires the Console to have visibility into the target index's mapping, which it fetches from the connected cluster, so autocomplete for fields naturally improves once relevant indices exist.
- Triggering autocomplete manually (typically via a keyboard shortcut) inside a partially typed request is useful when the automatic suggestion doesn't appear or was dismissed.

### Diagram: Console Request Flow

<svg width="100%" viewBox="0 0 680 260" role="img"><title>Dev Tools Console request flow to Elasticsearch (svg_diagram)</title><desc>A shorthand request typed in the Console editor pane is translated into a full HTTP request and sent to the connected Elasticsearch cluster, with the JSON response rendered back in a formatted output pane.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="40" y="90" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="130" y="110" text-anchor="middle" dominant-baseline="central">Editor pane</text>
<text class="ts" x="130" y="130" text-anchor="middle" dominant-baseline="central">Shorthand request</text>
</g>

<line x1="220" y1="118" x2="260" y2="118" class="arr" marker-end="url(#arrow)" />

<g class="node c-teal">
<rect x="260" y="90" width="160" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="110" text-anchor="middle" dominant-baseline="central">Kibana server</text>
<text class="ts" x="340" y="130" text-anchor="middle" dominant-baseline="central">Proxies as HTTP</text>
</g>

<line x1="420" y1="118" x2="460" y2="118" class="arr" marker-end="url(#arrow)" />

<g class="node c-coral">
<rect x="460" y="90" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="550" y="110" text-anchor="middle" dominant-baseline="central">Elasticsearch cluster</text>
<text class="ts" x="550" y="130" text-anchor="middle" dominant-baseline="central">Processes request</text>
</g>

<line x1="550" y1="146" x2="550" y2="190" class="arr" marker-end="url(#arrow)" />
<line x1="460" y1="200" x2="220" y2="200" class="arr" marker-end="url(#arrow)" />

<g class="node c-purple">
<rect x="40" y="180" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="130" y="200" text-anchor="middle" dominant-baseline="central">Output pane</text>
<text class="ts" x="130" y="220" text-anchor="middle" dominant-baseline="central">Formatted JSON response</text>
</g>
</svg>

### Request History

**Key Points**
- The Console retains a history of previously executed requests, accessible via a history panel, letting a prior request be recalled and re-run or edited without retyping it.
- History is local to the browser/session rather than shared across users or persisted as a saved artifact, so it should not be relied upon as a durable record of past queries.

### Copy as cURL

The Console provides a "Copy as cURL" action on any request, converting the shorthand syntax into a complete, runnable curl command including host, authentication placeholder, and headers — useful for taking a request tested interactively in the Console and embedding it into a script, application code, or documentation.

### Settings and Customization

**Key Points**
- Console settings allow adjusting font size, enabling/disabling autocomplete for specific categories (fields, indices, templates), and toggling whether requests are automatically formatted (indented) on save.
- **Polling** for updated field/index mappings can be adjusted, controlling how frequently the Console refreshes its autocomplete data from the live cluster state.

### Common Uses

**Key Points**
- Ad hoc querying and debugging during development, testing query DSL changes interactively before embedding them in application code.
- Cluster administration tasks — checking `_cluster/health`, `_cat` APIs, managing index settings, mappings, and ILM policies — without needing a separate API client.
- Learning and experimentation, since the Console's autocomplete and immediate feedback loop make it a practical way to explore unfamiliar APIs directly against real cluster data.
- Reproducing and sharing a specific request for troubleshooting, since a Console snippet is easy to paste into a support ticket, chat message, or documentation alongside its response.

### Console vs. Client Libraries and curl

[Inference] The Console is generally best suited for interactive, exploratory, and debugging use, while official client libraries (in Python, Java, Node.js, etc.) or raw curl in scripts are generally better suited for production application code and automation, since the Console has no place in a deployed application's runtime request path — it is a Kibana UI feature, not an API endpoint applications call.

### Related Topics

- **`_cat` APIs** as a frequently used category of Console requests for quick cluster/index inspection
- **Query DSL** syntax and structure, most commonly practiced and tested via the Console
- **Kibana Dev Tools' other panels** (Search Profiler, Grok Debugger, Painless Lab) alongside the Console
- **Elasticsearch official client libraries** as the production-code equivalent of ad hoc Console requests
- **X-Opaque-Id and custom headers**, and how they can be added to Console requests for request tracing
- **Kibana role-based access control** governing who has Dev Tools access in a given deployment
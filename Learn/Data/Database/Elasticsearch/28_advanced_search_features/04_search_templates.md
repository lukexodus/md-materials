## Search Templates

### Overview

Search templates let a query be defined once as a reusable Mustache-based template with placeholder parameters, then executed repeatedly with different parameter values without the calling application needing to construct the full query DSL body on every request. This separates query logic (owned and version-controlled server-side) from the specific parameter values a client supplies at request time.

### Why Use Search Templates

**Key Points**
- Applications can send a small set of named parameters instead of a full query DSL body, reducing the amount of query-construction logic embedded in client-side application code.
- Query logic can be updated or tuned server-side (a new template version) without requiring every calling application to be redeployed with updated query-building code.
- Templates make it easier to enforce consistent query structure across multiple applications or teams querying the same index, rather than each team independently constructing potentially inconsistent query DSL.

### Defining and Using an Inline Search Template

```json
GET my-index/_search/template
{
  "source": {
    "query": {
      "match": {
        "{{field}}": "{{value}}"
      }
    }
  },
  "params": {
    "field": "title",
    "value": "elasticsearch"
  }
}
```

**Key Points**
- `source` contains the Mustache-templated query body, with `{{placeholder}}` syntax marking where parameter values are substituted.
- `params` supplies the actual values for each placeholder for this specific request.
- Inline templates (as shown here) are defined directly in the request itself, useful for prototyping, but don't provide the reuse/versioning benefits of a stored template.

### Stored Search Templates

**Key Points**
- A template can be stored server-side under a given ID via the `_scripts` (script/template storage) endpoint, then invoked by referencing that ID rather than resending the full template body on every request.
- This is the pattern that realizes the main benefits of search templates — a stored, named, centrally managed template that multiple applications can call by ID.

```json
PUT _scripts/product-search-template
{
  "script": {
    "lang": "mustache",
    "source": {
      "query": {
        "match": {
          "{{field}}": "{{value}}"
        }
      }
    }
  }
}
```

```json
GET my-index/_search/template
{
  "id": "product-search-template",
  "params": {
    "field": "title",
    "value": "elasticsearch"
  }
}
```

### Diagram: Search Template Request Flow

<svg width="100%" viewBox="0 0 680 260" role="img"><title>Stored search template request flow (svg_diagram)</title><desc>An application sends a template ID and parameters, Elasticsearch retrieves the stored Mustache template, renders it with the supplied parameters into a full query, and executes that query against the target index.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="40" y="30" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="130" y="50" text-anchor="middle" dominant-baseline="central">Application request</text>
<text class="ts" x="130" y="70" text-anchor="middle" dominant-baseline="central">id + params only</text>
</g>

<line x1="220" y1="58" x2="260" y2="58" class="arr" marker-end="url(#arrow)" />

<g class="node c-teal">
<rect x="260" y="30" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="350" y="50" text-anchor="middle" dominant-baseline="central">Stored template</text>
<text class="ts" x="350" y="70" text-anchor="middle" dominant-baseline="central">Retrieved by id</text>
</g>

<line x1="350" y1="86" x2="350" y2="120" class="arr" marker-end="url(#arrow)" />

<g class="node c-coral">
<rect x="230" y="120" width="240" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="350" y="140" text-anchor="middle" dominant-baseline="central">Mustache rendering</text>
<text class="ts" x="350" y="160" text-anchor="middle" dominant-baseline="central">Params substituted into query</text>
</g>

<line x1="350" y1="176" x2="350" y2="210" class="arr" marker-end="url(#arrow)" />

<g class="node c-purple">
<rect x="250" y="210" width="200" height="40" rx="8" stroke-width="0.5" />
<text class="ts" x="350" y="230" text-anchor="middle" dominant-baseline="central">Executed against index</text>
</g>
</svg>

### Mustache Templating Features

**Key Points**
- Beyond simple value substitution, Mustache supports conditional sections (`{{#field}}...{{/field}}`, rendering content only if the referenced parameter is present/truthy) and iteration over arrays (`{{#array}}...{{/array}}`), enabling a single template to adapt its structure based on which parameters were actually supplied.
- This conditional capability lets one template handle several related query shapes (e.g., optionally adding a filter clause only when a specific parameter is provided) rather than requiring a separate template per variation.

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "{{query_text}}" } }
      ],
      "filter": [
        {{#category}}
        { "term": { "category": "{{category}}" } }
        {{/category}}
      ]
    }
  }
}
```

### Rendering a Template Without Executing It

```
GET _render/template
{
  "id": "product-search-template",
  "params": {
    "field": "title",
    "value": "elasticsearch"
  }
}
```

**Key Points**
- The `_render/template` endpoint renders the final query DSL from a template and its parameters without actually executing a search, useful for debugging a template's output or verifying rendering logic before running it against real data.
- This separation between rendering and execution makes it straightforward to inspect exactly what query a given set of parameters would produce.

### Multi-Search Templates

The `_msearch/template` endpoint allows multiple templated searches to be submitted in a single request, following the same batching pattern as the standard `_msearch` API, useful when an application needs results from several related templated queries (e.g., the same template with different parameter sets) in one round trip rather than several sequential requests.

### Managing and Updating Stored Templates

**Key Points**
- Stored templates can be listed, retrieved, and deleted via the same `_scripts` endpoint used to create them (`GET _scripts/<id>`, `DELETE _scripts/<id>`).
- Updating a stored template in place (re-issuing the `PUT` with new content) changes the behavior of every application currently calling it by that ID, so changes to a shared, actively used template should be coordinated across all its consumers.
- [Inference] Because updating a stored template affects every caller immediately, a versioned naming convention for template IDs (e.g., `product-search-v2`) is a common practical pattern for introducing a breaking template change without disrupting applications still relying on the prior behavior, though Elasticsearch itself doesn't enforce or manage template versioning as a built-in feature.

### Related Topics

- **Mustache templating syntax** in depth beyond the conditional/iteration features shown here
- **Painless scripting** as a comparison point — search templates use Mustache specifically, distinct from Painless used elsewhere (scripted fields, ingest pipeline scripts)
- **`_msearch` API** general batching mechanics beyond the templated variant
- **Role-based access control for stored scripts/templates**, governing who can create or modify shared templates
- **Application-side query builder patterns** as the alternative to server-side templates for managing query construction
- **Search Applications feature**, a related higher-level abstraction some Elasticsearch versions offer for exposing templated search behavior as a dedicated API surface
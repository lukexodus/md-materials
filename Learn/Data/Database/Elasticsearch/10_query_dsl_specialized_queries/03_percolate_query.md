## Percolate Query

A percolate query is a reverse-search mechanism in Elasticsearch. In a standard query, you store documents and query them. In percolation, you store *queries* and match them against incoming documents. The percolate query asks: "Which of my stored queries match this document?"

This is useful for alert systems, content routing, notification engines, and classifier pipelines where the rules are dynamic and must be applied against new data as it arrives.

Here is the flow:

<svg width="100%" viewBox="0 0 680 420" role="img" style="" xmlns="http://www.w3.org/2000/svg">
  <title style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">Percolate query flow diagram</title>
  <desc style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">Shows the two-phase percolation pattern: stored queries indexed in percolator fields, then a document matched against them via the percolate query, returning matching query IDs.</desc>
  <defs>
    <marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  <mask id="imagine-text-gaps-u025y6" maskUnits="userSpaceOnUse"><rect x="0" y="0" width="680" height="420" fill="white"/><rect x="33.97916793823242" y="33.333335876464844" width="52.04166793823242" height="17.33333396911621" fill="black" rx="2"/><rect x="19.97395896911621" y="49.333335876464844" width="80.05208587646484" height="17.33333396911621" fill="black" rx="2"/><rect x="150.46875" y="48.333335876464844" width="99.0625" height="19.33333396911621" fill="black" rx="2"/><rect x="122.4375" y="79.33333587646484" width="155.125" height="17.33333396911621" fill="black" rx="2"/><rect x="318.65625" y="37.333335876464844" width="36.6875" height="17.33333396911621" fill="black" rx="2"/><rect x="419.41668701171875" y="48.333335876464844" width="109.49837493896484" height="19.33333396911621" fill="black" rx="2"/><rect x="415.96875" y="79.33333587646484" width="116.0625" height="17.33333396911621" fill="black" rx="2"/><rect x="33.97916793823242" y="135.33334350585938" width="52.04166793823242" height="17.33333396911621" fill="black" rx="2"/><rect x="28.317710876464844" y="151.33334350585938" width="63.364585876464844" height="17.33333396911621" fill="black" rx="2"/><rect x="149.3072967529297" y="150.33334350585938" width="101.4892578125" height="19.33333396911621" fill="black" rx="2"/><rect x="126.84896850585938" y="181.33334350585938" width="146.30209350585938" height="17.33333396911621" fill="black" rx="2"/><rect x="308.3125" y="139.33334350585938" width="57.375" height="17.33333396911621" fill="black" rx="2"/><rect x="420.96875" y="150.33334350585938" width="106.38802337646484" height="19.33333396911621" fill="black" rx="2"/><rect x="375.27606201171875" y="181.33334350585938" width="197.4479217529297" height="17.33333396911621" fill="black" rx="2"/><rect x="409.6927185058594" y="268.3333435058594" width="128.61458587646484" height="19.33333396911621" fill="black" rx="2"/><rect x="406.63543701171875" y="299.3333435058594" width="134.7291717529297" height="17.33333396911621" fill="black" rx="2"/><rect x="172.234375" y="353.3333435058594" width="329.53125" height="17.33333396911621" fill="black" rx="2"/><rect x="142.90625" y="371.3333435058594" width="388.1875" height="17.33333396911621" fill="black" rx="2"/></mask></defs>

  <!-- Phase label: Index queries -->
  <text x="60" y="46" text-anchor="middle" font-weight="500" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:500;text-anchor:middle;dominant-baseline:auto">Phase 1</text>
  <text x="60" y="62" text-anchor="middle" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:auto">Index queries</text>

  <!-- Stored queries -->
  <g style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">
    <rect x="100" y="36" width="200" height="44" rx="8" stroke-width="0.5" style="fill:rgb(8, 80, 65);stroke:rgb(93, 202, 165);color:rgb(255, 255, 255);stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
    <text x="200" y="58" text-anchor="middle" dominant-baseline="central" style="fill:rgb(159, 225, 203);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:14px;font-weight:500;text-anchor:middle;dominant-baseline:central">Stored queries</text>
  </g>
  <text x="200" y="92" text-anchor="middle" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:auto">{ "query": { "match": { ... } } }</text>

  <!-- Arrow right to Percolator index -->
  <line x1="302" y1="58" x2="372" y2="58" marker-end="url(#arrow)" style="fill:none;stroke:rgb(156, 154, 146);color:rgb(255, 255, 255);stroke-width:1.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
  <text x="337" y="50" text-anchor="middle" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:auto">index</text>

  <!-- Percolator index -->
  <g style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">
    <rect x="374" y="36" width="200" height="44" rx="8" stroke-width="0.5" style="fill:rgb(60, 52, 137);stroke:rgb(175, 169, 236);color:rgb(255, 255, 255);stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
    <text x="474" y="58" text-anchor="middle" dominant-baseline="central" style="fill:rgb(206, 203, 246);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:14px;font-weight:500;text-anchor:middle;dominant-baseline:central">Percolator index</text>
  </g>
  <text x="474" y="92" text-anchor="middle" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:auto">field type: percolator</text>

  <!-- Divider -->
  <line x1="40" y1="116" x2="640" y2="116" stroke="var(--color-border-tertiary)" stroke-width="0.5" stroke-dasharray="4 4" style="fill:rgb(0, 0, 0);stroke:rgba(222, 220, 209, 0.15);color:rgb(255, 255, 255);stroke-width:0.5px;stroke-dasharray:4px, 4px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>

  <!-- Phase label: Match document -->
  <text x="60" y="148" text-anchor="middle" font-weight="500" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:500;text-anchor:middle;dominant-baseline:auto">Phase 2</text>
  <text x="60" y="164" text-anchor="middle" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:auto">Match doc</text>

  <!-- New document -->
  <g style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">
    <rect x="100" y="138" width="200" height="44" rx="8" stroke-width="0.5" style="fill:rgb(99, 56, 6);stroke:rgb(239, 159, 39);color:rgb(255, 255, 255);stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
    <text x="200" y="160" text-anchor="middle" dominant-baseline="central" style="fill:rgb(250, 199, 117);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:14px;font-weight:500;text-anchor:middle;dominant-baseline:central">New document</text>
  </g>
  <text x="200" y="194" text-anchor="middle" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:auto">{ "price": 29, "tag": "sale" }</text>

  <!-- Arrow right to Percolate query -->
  <line x1="302" y1="160" x2="372" y2="160" marker-end="url(#arrow)" style="fill:none;stroke:rgb(156, 154, 146);color:rgb(255, 255, 255);stroke-width:1.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
  <text x="337" y="152" text-anchor="middle" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:auto">percolate</text>

  <!-- Percolate query box -->
  <g style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">
    <rect x="374" y="138" width="200" height="44" rx="8" stroke-width="0.5" style="fill:rgb(60, 52, 137);stroke:rgb(175, 169, 236);color:rgb(255, 255, 255);stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
    <text x="474" y="160" text-anchor="middle" dominant-baseline="central" style="fill:rgb(206, 203, 246);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:14px;font-weight:500;text-anchor:middle;dominant-baseline:central">Percolate query</text>
  </g>
  <text x="474" y="194" text-anchor="middle" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:auto">matches doc against stored queries</text>

  <!-- Arrow down to Results -->
  <line x1="474" y1="184" x2="474" y2="254" marker-end="url(#arrow)" mask="url(#imagine-text-gaps-u025y6)" style="fill:none;stroke:rgb(156, 154, 146);color:rgb(255, 255, 255);stroke-width:1.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>

  <!-- Results -->
  <g style="fill:rgb(0, 0, 0);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto">
    <rect x="374" y="256" width="200" height="44" rx="8" stroke-width="0.5" style="fill:rgb(8, 80, 65);stroke:rgb(93, 202, 165);color:rgb(255, 255, 255);stroke-width:0.5px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
    <text x="474" y="278" text-anchor="middle" dominant-baseline="central" style="fill:rgb(159, 225, 203);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:14px;font-weight:500;text-anchor:middle;dominant-baseline:central">Matching query IDs</text>
  </g>
  <text x="474" y="312" text-anchor="middle" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:auto">hits: [ query-1, query-3 ]</text>

  <!-- Legend / note -->
  <rect x="100" y="346" width="474" height="48" rx="8" fill="none" stroke="var(--color-border-tertiary)" stroke-width="0.5" stroke-dasharray="4 3" style="fill:none;stroke:rgba(222, 220, 209, 0.15);color:rgb(255, 255, 255);stroke-width:0.5px;stroke-dasharray:4px, 3px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:16px;font-weight:400;text-anchor:start;dominant-baseline:auto"/>
  <text x="337" y="366" text-anchor="middle" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:auto">The stored queries are the index; the document is the probe.</text>
  <text x="337" y="384" text-anchor="middle" style="fill:rgb(194, 192, 182);stroke:none;color:rgb(255, 255, 255);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;opacity:1;font-family:&quot;Anthropic Sans&quot;, -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, sans-serif;font-size:12px;font-weight:400;text-anchor:middle;dominant-baseline:auto">Normal search inverts this: documents are indexed, queries are probes.</text>
</svg>

### Percolator field type

Before issuing a percolate query, the index must have a field of type `percolator`. This field stores the query in its serialized form.

**Mapping example:**

```json
PUT /my-alerts
{
  "mappings": {
    "properties": {
      "query": {
        "type": "percolator"
      },
      "title": {
        "type": "text"
      }
    }
  }
}
```

**Key Points:**
- The `percolator` type accepts any standard Elasticsearch query DSL object.
- Any other fields in the mapping describe the *document* being percolated, not the stored query.
- The mapping must mirror the structure of documents you intend to percolate.

---

### Indexing stored queries

Each stored query is an ordinary document with a `percolator`-typed field holding the query JSON.

```json
PUT /my-alerts/_doc/1
{
  "query": {
    "bool": {
      "must": [
        { "match": { "category": "electronics" } },
        { "range": { "price": { "lte": 500 } } }
      ]
    }
  },
  "title": "Electronics under $500"
}

PUT /my-alerts/_doc/2
{
  "query": {
    "match": {
      "description": "wireless headphones"
    }
  },
  "title": "Wireless headphones alert"
}
```

---

### Issuing a percolate query

The percolate query is embedded inside a search request. You supply the document to test (either inline or by reference) and Elasticsearch evaluates every stored query against it.

**Syntax:**

```json
GET /my-alerts/_search
{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "category": "electronics",
        "price": 299,
        "description": "wireless headphones noise cancelling"
      }
    }
  }
}
```

**Key Points:**
- `field` — the percolator-typed field in the index.
- `document` — the document to match against stored queries. It is supplied inline as a JSON object.
- Each hit in the response corresponds to a stored query that matched the supplied document.

---

### Core parameters

#### `document`

Supplies the document to percolate inline.

```json
"percolate": {
  "field": "query",
  "document": {
    "price": 150,
    "tag": "sale"
  }
}
```

#### `documents`

Percolate multiple documents simultaneously. A stored query matches if it matches *any* of the supplied documents.

```json
"percolate": {
  "field": "query",
  "documents": [
    { "price": 150, "tag": "sale" },
    { "price": 800, "tag": "premium" }
  ]
}
```

#### `index`, `id`, `routing` — percolating an existing document

Instead of supplying the document inline, you can reference an existing document by its index and ID. Elasticsearch fetches it before matching.

```json
"percolate": {
  "field": "query",
  "index": "products",
  "id": "abc123"
}
```

**Key Points:**
- `routing` is optional; use it if the source document is stored with a custom routing value.
- `version` can also be supplied to target a specific document version.
- [Inference] Fetching by reference adds a network round-trip to retrieve the source document before percolation; this may increase latency compared to inline supply. Behavior may vary.

#### `name`

When multiple percolate queries appear in a single request (e.g., inside a `bool`), `name` distinguishes which percolate clause matched a given hit. The name appears in `_percolator_document_slot` metadata on each hit.

```json
"bool": {
  "should": [
    {
      "percolate": {
        "field": "query",
        "document": { "price": 50 },
        "name": "cheap-docs"
      }
    },
    {
      "percolate": {
        "field": "query",
        "document": { "price": 900 },
        "name": "expensive-docs"
      }
    }
  ]
}
```

---

### Response structure

```json
{
  "hits": {
    "hits": [
      {
        "_id": "1",
        "_score": 0.5753642,
        "_source": {
          "title": "Electronics under $500",
          "query": { ... }
        },
        "fields": {
          "_percolator_document_slot": [0]
        }
      }
    ]
  }
}
```

**Key Points:**
- Each hit is a *stored query* whose conditions were satisfied by the percolated document.
- `_percolator_document_slot` indicates which document (by index in `documents`) triggered the match when multiple documents are percolated.
- Standard relevance scoring applies; stored queries that match more of the document's content score higher.
- Highlighting, aggregations, and sorting work normally on the result set of matched stored queries.

---

### Highlighting percolated documents

Highlighting can be applied to show which parts of the percolated document triggered each stored query match.

```json
GET /my-alerts/_search
{
  "query": {
    "percolate": {
      "field": "query",
      "document": {
        "description": "wireless headphones with noise cancelling"
      }
    }
  },
  "highlight": {
    "fields": {
      "description": {}
    }
  }
}
```

The highlight result appears per hit and reflects the stored query's terms against the percolated document's content. [Inference] This is especially useful when debugging which part of the document activated a stored alert rule; behavior depends on query type and analyzer configuration.

---

### Multiple percolate queries in one request

Multiple `percolate` clauses can coexist in a `bool` query. Each can target a different document or field, and the `name` parameter tracks which clause fired.

```json
GET /my-alerts/_search
{
  "query": {
    "bool": {
      "should": [
        {
          "percolate": {
            "field": "query",
            "document": { "category": "books", "price": 12 },
            "name": "books"
          }
        },
        {
          "percolate": {
            "field": "query",
            "document": { "category": "electronics", "price": 999 },
            "name": "electronics"
          }
        }
      ]
    }
  }
}
```

---

### Combining percolate with other query clauses

A percolate query can be combined with standard query clauses inside a `bool` to filter which stored queries are considered before percolation runs. This is a critical performance technique.

```json
GET /my-alerts/_search
{
  "query": {
    "bool": {
      "must": {
        "percolate": {
          "field": "query",
          "document": { "price": 200, "category": "electronics" }
        }
      },
      "filter": {
        "term": { "active": true }
      }
    }
  }
}
```

**Key Points:**
- The `filter` reduces the candidate set of stored queries before percolation is applied. This can significantly reduce the number of queries evaluated. [Inference] The performance benefit scales with how effectively the pre-filter narrows the stored query set; actual gains depend on index size and filter selectivity. Behavior may vary.
- This pattern is especially relevant when stored queries are tagged with metadata (priority, owner, enabled flag).

---

### Percolate query and nested objects

If the mapping uses `nested` types, the percolated document must include nested objects in the expected structure, and stored queries must use `nested` query syntax to match them.

```json
PUT /alerts-nested
{
  "mappings": {
    "properties": {
      "query": { "type": "percolator" },
      "items": {
        "type": "nested",
        "properties": {
          "sku":   { "type": "keyword" },
          "qty":   { "type": "integer" }
        }
      }
    }
  }
}
```

Stored query referencing a nested path:

```json
{
  "query": {
    "nested": {
      "path": "items",
      "query": {
        "bool": {
          "must": [
            { "term":  { "items.sku": "ABC-001" } },
            { "range": { "items.qty": { "gte": 10 } } }
          ]
        }
      }
    }
  }
}
```

---

### Performance considerations

| Factor | Guidance |
|---|---|
| Candidate query volume | Pre-filter stored queries with `bool.filter` before percolation runs to reduce evaluated query count. |
| Index mapping alignment | The mapping used for percolation must match the document structure precisely; field type mismatches cause silent non-matches. |
| Inline vs. reference | Inline `document` avoids a secondary fetch. Use `index`/`id` only when the source document is large or already stored. |
| Scoring overhead | If ranking is not needed, use `filter` context for percolate to skip scoring. [Inference] This may reduce CPU usage; behavior may vary by Elasticsearch version and cluster load. |
| Shard count | Percolation runs per shard; a high shard count with many stored queries multiplies evaluation cost. |

---

### Common use cases

**Alert and notification systems** — store subscriber alert rules as queries. When new content is indexed, percolate it to find which subscribers to notify.

**Content tagging pipelines** — store classification rules. Percolate incoming documents to apply categories, labels, or routing decisions at ingest time.

**Search-as-subscription** — users save searches. When new items match a saved search, notify the user. Each saved search is a stored query.

**Compliance and policy enforcement** — store detection rules. Percolate incoming records to flag policy violations or regulatory triggers.

---

### Constraints and limitations

- The percolator field type stores the query as-is; if the stored query references fields not present in the mapping, matching behavior is undefined. [Unverified — behavior depends on Elasticsearch version and query type.]
- Queries that use `script` filters in stored queries may have security implications in multi-tenant environments. [Inference] Behavior depends on script security settings in the cluster configuration.
- Percolation is not a streaming operation; it runs at query time, not at index time, unless integrated into an ingest pipeline via a custom processor.
- The `percolate` query cannot itself be used as a stored query inside another percolator. [Inference based on documented query type constraints; verify against your Elasticsearch version.]

---

**Next Steps:** `rank_feature` query — used for boosting relevance scores using numeric feature fields, often in combination with retrieval pipelines.
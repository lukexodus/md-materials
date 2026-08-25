## Named Queries

### Overview

Named queries allow individual clauses within a compound query (typically inside a `bool` query) to be tagged with a `_name`. When a document matches, the response indicates which specific named clauses contributed to that match via a `matched_queries` field on each hit. This is primarily useful for understanding *why* a document matched when a query has many conditions.

### Basic Syntax

Any leaf query clause can carry a `_name` parameter.

```json
GET /products/_search
{
  "query": {
    "bool": {
      "should": [
        {
          "match": {
            "description": {
              "query": "wireless",
              "_name": "matched_wireless"
            }
          }
        },
        {
          "match": {
            "description": {
              "query": "bluetooth",
              "_name": "matched_bluetooth"
            }
          }
        },
        {
          "range": {
            "price": {
              "lte": 100,
              "_name": "under_100"
            }
          }
        }
      ]
    }
  }
}
```

### Reading the Response

Each hit includes a `matched_queries` array listing the `_name` values of every clause that matched that particular document.

```json
{
  "_id": "42",
  "_score": 2.4,
  "matched_queries": ["matched_wireless", "under_100"],
  "_source": { "description": "Wireless earbuds", "price": 79.99 }
}
```

If a hit's `description` also contained "bluetooth", `"matched_bluetooth"` would appear in the array as well. Clauses that did not match are simply absent from the array — there is no explicit "false" entry.

### Why Use Named Queries

- **Debugging complex `bool` queries** — with many `should`/`must`/`filter` clauses, it becomes difficult to infer from `_score` alone which conditions were actually satisfied
- **Faceted or rule-based UI feedback** — showing end users *why* a result was surfaced (e.g., "matched: brand, price range")
- **A/B testing and relevance tuning** — correlating which clauses fire most often across a query mix, to guide weighting or restructuring decisions
- **Business rule transparency** — in applications like eligibility or compliance search, showing which specific rule(s) a record satisfied

### Named Queries in `must` and `filter` Contexts

Naming is not limited to `should` clauses. It also works in `must` and `filter`, though since `must`/`filter` clauses are required for a document to match at all, every hit will show those names — the diagnostic value is highest in `should` and nested `bool` structures where matching is optional or conditional.

```json
GET /products/_search
{
  "query": {
    "bool": {
      "filter": [
        {
          "term": {
            "category": {
              "value": "electronics",
              "_name": "category_filter"
            }
          }
        }
      ],
      "should": [
        {
          "match": {
            "description": {
              "query": "wireless",
              "_name": "wireless_match"
            }
          }
        }
      ]
    }
  }
}
```

### Named Queries in Nested and Compound Structures

Names remain useful when clauses are nested inside sub-`bool` blocks — each named leaf clause still reports independently in `matched_queries`, regardless of nesting depth.

```json
GET /products/_search
{
  "query": {
    "bool": {
      "should": [
        {
          "bool": {
            "must": [
              { "match": { "brand": { "query": "acme", "_name": "brand_acme" } } },
              { "range": { "price": { "lte": 50, "_name": "price_under_50" } } }
            ]
          }
        },
        {
          "match": {
            "tags": {
              "query": "clearance",
              "_name": "clearance_tag"
            }
          }
        }
      ]
    }
  }
}
```

A document matching the nested `bool` would show both `"brand_acme"` and `"price_under_50"` in `matched_queries`, since both leaf clauses inside that nested block matched.

### Named Queries with Percolate

`matched_queries` is also commonly combined with the `percolate` query (see prior topic): when a submitted document matches multiple named sub-clauses within a single stored percolator query, `matched_queries` reveals exactly which internal conditions of that stored query fired — useful for explaining alert triggers in detail.

### Performance Considerations

Named queries add negligible overhead — the name itself does not change how the clause is evaluated or scored; it only causes Elasticsearch to track which clauses matched, for inclusion in the response metadata [Unverified — exact internal cost is implementation-dependent and may vary slightly by version, though it is generally considered lightweight].

### Limitations

- `_name` is only meaningful on leaf query clauses (`match`, `term`, `range`, etc.) and on `bool` sub-clauses; it does not apply to aggregations, which have their own independent naming via aggregation keys
- Names must be unique within a query for unambiguous interpretation — reusing the same `_name` across multiple clauses in the same query causes `matched_queries` to be unable to distinguish which specific clause matched
- `matched_queries` reflects clause-level matching, not scoring contribution — a matched clause with a `boost` of 0 still appears in `matched_queries` even though it contributed nothing to `_score`

### Example: Debugging a Broad `should` Query

```json
GET /jobs/_search
{
  "query": {
    "bool": {
      "should": [
        { "match": { "title": { "query": "engineer", "_name": "title_engineer" } } },
        { "match": { "skills": { "query": "elasticsearch", "_name": "skill_es" } } },
        { "match": { "skills": { "query": "python", "_name": "skill_python" } } },
        { "term": { "remote": { "value": true, "_name": "is_remote" } } }
      ],
      "minimum_should_match": 1
    }
  }
}
```

Given a hit with `matched_queries: ["skill_es", "is_remote"]`, it's immediately clear the document matched because it listed Elasticsearch as a skill and was remote — without title or Python matching — information that `_score` alone would not reveal.

### Diagram: Matched Queries Flow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 320">
\<style\>
.title { font: bold 14px sans-serif; fill: #1a1a1a; }
.label { font: 12px sans-serif; fill: #1a1a1a; }
.sub { font: 11px sans-serif; fill: #555; }
.box { fill: #eef3fb; stroke: #4a6fa5; stroke-width: 1.5; }
.boxY { fill: #eefbee; stroke: #4a9a5a; stroke-width: 1.5; }
.boxN { fill: #fbeeee; stroke: #a54a4a; stroke-width: 1.5; stroke-dasharray: 4,3; }
.arrow { stroke: #333; stroke-width: 1.5; marker-end: url(#arrow2); }
\</style\>
<text x="20" y="25" class="title">Named Query Clauses → matched_queries (svg_diagram)</text>

<rect x="30" y="55" width="180" height="40" rx="4" class="box" />
<text x="120" y="79" class="label" text-anchor="middle">bool.should[ ]</text>
<rect x="270" y="50" width="200" height="34" rx="4" class="boxY" />
<text x="370" y="72" class="label" text-anchor="middle">title_engineer ✓</text>
<rect x="270" y="95" width="200" height="34" rx="4" class="boxY" />
<text x="370" y="117" class="label" text-anchor="middle">skill_es ✓</text>
<rect x="270" y="140" width="200" height="34" rx="4" class="boxN" />
<text x="370" y="162" class="label" text-anchor="middle">skill_python ✗</text>
<rect x="270" y="185" width="200" height="34" rx="4" class="boxY" />
<text x="370" y="207" class="label" text-anchor="middle">is_remote ✓</text>
<line x1="210" y1="75" x2="270" y2="67" class="arrow" />
<line x1="210" y1="75" x2="270" y2="112" class="arrow" />
<line x1="210" y1="75" x2="270" y2="157" class="arrow" />
<line x1="210" y1="75" x2="270" y2="202" class="arrow" />
<rect x="540" y="90" width="160" height="90" rx="4" class="box" />
<text x="620" y="112" class="label" text-anchor="middle" font-weight="bold">matched_queries</text>
<text x="620" y="132" class="sub" text-anchor="middle">title_engineer</text>
<text x="620" y="148" class="sub" text-anchor="middle">skill_es</text>
<text x="620" y="164" class="sub" text-anchor="middle">is_remote</text>
<line x1="470" y1="67" x2="540" y2="110" class="arrow" />
<line x1="470" y1="112" x2="540" y2="125" class="arrow" />
<line x1="470" y1="202" x2="540" y2="150" class="arrow" />
</svg>

**Related Topics**

- `bool` query structure (`must`, `should`, `must_not`, `filter`)
- `minimum_should_match` behavior and its interaction with named clauses
- Explain API (`_explain`) for full scoring breakdowns beyond match/no-match
- Percolator and reverse search (prior topic) — combining `matched_queries` with `percolate`
- Function score query for weighting matched conditions
- Search relevance tuning workflows
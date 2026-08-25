## Rank Feature and Rank Features Field

### Overview

The `rank_feature` and `rank_features` field types store numeric signals intended purely to influence document ranking — not to be queried for exact matches or used in filters, aggregations, or sorting through ordinary means. They exist to feed the `rank_feature` query, a specialized query clause that boosts scoring based on these stored signal values using specific, efficient scoring functions.

### `rank_feature` vs. `rank_features`

**Key Points**
- `rank_feature` stores a single positive numeric value per document, representing one ranking signal (e.g., a popularity score, a PageRank-style authority score, a freshness score).
- `rank_features` stores a set of feature name/value pairs per document (structured similarly to a sparse vector), representing multiple named signals of varying applicability per document, useful when different documents have different relevant signal types rather than one universal numeric field.
- Both are declared as dedicated mapping types and are not intended for use in standard `term`, `range`, or `match` queries — they are consumed specifically through the `rank_feature` query.

```json
PUT products
{
  "mappings": {
    "properties": {
      "popularity": {
        "type": "rank_feature"
      },
      "topics": {
        "type": "rank_features"
      }
    }
  }
}
```

```json
PUT products/_doc/1
{
  "name": "Wireless headphones",
  "popularity": 42,
  "topics": {
    "electronics": 8,
    "audio": 12
  }
}
```

### Why a Dedicated Field Type

**Key Points**
- Storing a ranking signal in a standard `numeric` field and using it in a `function_score` query works, but `rank_feature` fields use an internal encoding and index structure specifically optimized for the scoring functions the `rank_feature` query applies, giving better query-time performance for this specific purpose.
- Because these fields are explicitly not intended for filtering, sorting, or exact-value queries, indexing them as `rank_feature`/`rank_features` rather than plain numerics also communicates intent clearly in the mapping — a `rank_feature` field signals "ranking signal only" to anyone reading the mapping later.

### The `rank_feature` Query

**Key Points**
- The `rank_feature` query is used within a `bool` query's `should` clause (or similar scoring-combination context) to add a score contribution derived from a `rank_feature`/`rank_features` field's value, on top of a primary text-relevance query.
- Three scoring functions are available: **saturation** (default — diminishing returns as the value increases, following a saturation curve), **log** (logarithmic growth), and **sigmoid** (an S-curve, configurable pivot and exponent), each suited to different desired relationships between raw signal value and score contribution.

```json
GET products/_search
{
  "query": {
    "bool": {
      "must": {
        "match": {
          "name": "headphones"
        }
      },
      "should": {
        "rank_feature": {
          "field": "popularity",
          "boost": 2.0
        }
      }
    }
  }
}
```

### Diagram: Scoring Function Shapes

<svg width="100%" viewBox="0 0 680 320" role="img"><title>Saturation, logarithmic, and sigmoid scoring function shapes (svg_diagram)</title><desc>Three curve shapes describe how a raw rank feature value translates into a score contribution: saturation flattens quickly, log grows slowly and steadily, and sigmoid follows an S-curve with a configurable pivot point.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<line x1="60" y1="280" x2="620" y2="280" stroke="var(--t)" stroke-width="0.5" />
<line x1="60" y1="280" x2="60" y2="40" stroke="var(--t)" stroke-width="0.5" />
<text class="ts" x="600" y="298" text-anchor="middle">raw value</text>
<text class="ts" x="30" y="50" text-anchor="middle">score</text>

<path d="M60 260 C 150 100, 300 80, 600 75" fill="none" stroke="#0F6E56" stroke-width="1.5" />
<text class="ts" x="560" y="65" fill="#0F6E56">saturation</text>

<path d="M60 275 C 200 220, 400 130, 600 100" fill="none" stroke="#185FA5" stroke-width="1.5" />
<text class="ts" x="500" y="130" fill="#185FA5">log</text>

<path d="M60 275 C 250 275, 300 90, 600 85" fill="none" stroke="#993C1D" stroke-width="1.5" />
<text class="ts" x="460" y="200" fill="#993C1D">sigmoid</text>
</svg>

### Sparse Feature Sets with `rank_features`

**Key Points**
- The `rank_features` field type is designed for the case where the set of applicable named features varies per document — for instance, a content-classification model tagging each document with a different subset of relevant topics and their confidence/relevance scores, rather than every document sharing the exact same fixed set of numeric fields.
- Querying a specific named feature within a `rank_features` field uses the same `rank_feature` query, specifying the full path (`topics.electronics`) as the field.

```json
GET products/_search
{
  "query": {
    "bool": {
      "must": { "match": { "name": "headphones" } },
      "should": {
        "rank_feature": {
          "field": "topics.electronics"
        }
      }
    }
  }
}
```

### Negative Score Contribution

By default, higher `rank_feature` values increase the score. Setting `positive_score_impact: false` on the field mapping inverts this relationship, useful for signals where a lower value should correspond to a higher score contribution — for example, a "distance to nearest store" or "price" type signal where smaller is generally more favorable.

```json
PUT products
{
  "mappings": {
    "properties": {
      "price_tier": {
        "type": "rank_feature",
        "positive_score_impact": false
      }
    }
  }
}
```

### Comparison to `function_score` Query

**Key Points**
- The `function_score` query is a more general-purpose mechanism for modifying document scores based on arbitrary functions (field value factors, decay functions, scripted scoring), and can achieve broadly similar outcomes to `rank_feature` for simple cases.
- [Inference] `rank_feature` fields and the `rank_feature` query trade some of `function_score`'s flexibility for better indexing/query performance on the specific, common pattern of "boost by a stored numeric signal using one of a few well-established curve shapes," making them the more appropriate choice when that specific pattern fits the use case, while `function_score` remains preferable for more bespoke or complex scoring logic that doesn't fit the `rank_feature` query's supported functions.

### Related Topics

- **`function_score` query** in depth as the more general-purpose scoring modification mechanism
- **Learning to Rank (LTR)**, a more advanced relevance-tuning approach that can incorporate multiple ranking signals including rank features
- **Dense and sparse vector fields**, distinct field types for embedding-based (rather than hand-engineered scalar signal) relevance approaches
- **Decay functions** (`gauss`, `exp`, `linear`) within `function_score` as an alternative approach to distance/freshness-based scoring
- **Query DSL `bool` query** structure and how `should` clauses combine with `must` for combined text-relevance-plus-signal scoring
- **Search relevance tuning workflows** more broadly, including the Rank Evaluation API for measuring relevance quality changes
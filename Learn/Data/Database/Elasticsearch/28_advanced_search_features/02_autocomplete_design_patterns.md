## Autocomplete Design Patterns

### Overview

Autocomplete (also called search-as-you-type or typeahead) suggests completions or relevant results as a user types, before they finish entering a full query. Elasticsearch offers several distinct implementation approaches, each with different trade-offs in latency, relevance behavior, fuzzy-matching support, and indexing complexity. Choosing the right pattern depends on whether the goal is pure prefix matching, fuzzy/typo-tolerant suggestions, or full search-quality relevance on partial input.

### The `completion` Suggester

**Key Points**
- The `completion` suggester uses a dedicated field type (`completion`) backed by an in-memory finite state transducer (FST) structure, purpose-built for extremely fast prefix-matching lookups.
- Because it's a specialized in-memory structure rather than a standard inverted index lookup, `completion` suggester queries are typically the fastest of the available approaches, but at the cost of more limited relevance/scoring flexibility compared to a full search query.
- The field is populated at index time with the specific input strings that should trigger a suggestion, which can differ from the document's other searchable fields — this separation allows deliberately curating what completes to what, rather than autocomplete being a byproduct of a general-purpose search field.

```json
PUT products
{
  "mappings": {
    "properties": {
      "suggest": {
        "type": "completion"
      }
    }
  }
}
```

```json
PUT products/_doc/1
{
  "suggest": {
    "input": ["Nike Air Max", "Air Max 90"]
  }
}
```

```json
GET products/_search
{
  "suggest": {
    "product-suggest": {
      "prefix": "Air",
      "completion": {
        "field": "suggest"
      }
    }
  }
}
```

### `search_as_you_type` Field Type

**Key Points**
- The `search_as_you_type` field type automatically indexes a field into several sub-fields at different n-gram/shingle granularities behind the scenes, enabling prefix-style matching through the standard `_search` endpoint (via `match_bool_prefix` query) rather than the separate suggester mechanism.
- Because it runs through the normal search/query path rather than a dedicated suggester structure, it can be combined with standard relevance scoring, filters, and other query clauses more naturally than the `completion` suggester.
- [Inference] This makes `search_as_you_type` generally preferable when the autocomplete results need to integrate with broader search relevance logic (boosting, filtering by other fields, standard scoring), while the `completion` suggester's raw speed generally makes it preferable for simple, low-latency prefix suggestion boxes disconnected from complex relevance requirements.

```json
PUT products
{
  "mappings": {
    "properties": {
      "product_name": {
        "type": "search_as_you_type"
      }
    }
  }
}
```

```json
GET products/_search
{
  "query": {
    "match_bool_prefix": {
      "product_name": "nike air"
    }
  }
}
```

### Diagram: Autocomplete Approach Selection

<svg width="100%" viewBox="0 0 680 320" role="img"><title>Choosing an autocomplete approach based on requirements (svg_diagram)</title><desc>A decision flow for selecting between the completion suggester, search_as_you_type, and edge n-gram approaches based on whether raw speed, integrated relevance scoring, or fuzzy typo tolerance is the priority.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-gray">
<rect x="240" y="20" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="40" text-anchor="middle" dominant-baseline="central">Autocomplete need</text>
<text class="ts" x="340" y="60" text-anchor="middle" dominant-baseline="central">What matters most?</text>
</g>

<line x1="280" y1="76" x2="120" y2="130" class="arr" marker-end="url(#arrow)" />
<line x1="340" y1="76" x2="340" y2="130" class="arr" marker-end="url(#arrow)" />
<line x1="400" y1="76" x2="560" y2="130" class="arr" marker-end="url(#arrow)" />

<g class="node c-blue">
<rect x="40" y="130" width="160" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="120" y="148" text-anchor="middle" dominant-baseline="central">Raw speed</text>
<text class="ts" x="120" y="168" text-anchor="middle" dominant-baseline="central">Simple prefix box</text>
</g>
<g class="node c-teal">
<rect x="260" y="130" width="160" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="148" text-anchor="middle" dominant-baseline="central">Integrated relevance</text>
<text class="ts" x="340" y="168" text-anchor="middle" dominant-baseline="central">Filters, scoring</text>
</g>
<g class="node c-coral">
<rect x="480" y="130" width="160" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="560" y="148" text-anchor="middle" dominant-baseline="central">Typo tolerance</text>
<text class="ts" x="560" y="168" text-anchor="middle" dominant-baseline="central">Fuzzy matching</text>
</g>

<line x1="120" y1="186" x2="120" y2="220" class="arr" marker-end="url(#arrow)" />
<line x1="340" y1="186" x2="340" y2="220" class="arr" marker-end="url(#arrow)" />
<line x1="560" y1="186" x2="560" y2="220" class="arr" marker-end="url(#arrow)" />

<g class="c-blue"><rect x="40" y="220" width="160" height="40" rx="8" stroke-width="0.5" /><text class="ts" x="120" y="240" text-anchor="middle" dominant-baseline="central">completion suggester</text></g>
<g class="c-teal"><rect x="260" y="220" width="160" height="40" rx="8" stroke-width="0.5" /><text class="ts" x="340" y="240" text-anchor="middle" dominant-baseline="central">search_as_you_type</text></g>
<g class="c-coral"><rect x="480" y="220" width="160" height="40" rx="8" stroke-width="0.5" /><text class="ts" x="560" y="240" text-anchor="middle" dominant-baseline="central">completion w/ fuzzy</text></g>
</svg>

### Fuzzy Matching with the `completion` Suggester

**Key Points**
- The `completion` suggester supports a `fuzzy` option, enabling typo-tolerant matching (based on edit distance) so a slightly misspelled prefix still returns relevant suggestions rather than nothing.
- Fuzzy matching adds computational cost relative to exact prefix matching, though the FST-backed structure still keeps it fast relative to fuzzy matching against a standard inverted index.

```json
GET products/_search
{
  "suggest": {
    "product-suggest": {
      "prefix": "Nkie",
      "completion": {
        "field": "suggest",
        "fuzzy": {
          "fuzziness": 1
        }
      }
    }
  }
}
```

### Edge N-gram Approach

**Key Points**
- An alternative, older pattern indexes a field using an `edge_ngram` tokenizer/filter at index time, generating tokens for every prefix length of each term (e.g., "elastic" generates "e", "el", "ela", "elas", etc.), then queries that field with a standard `match` query at search time.
- This approach works through the standard inverted index and query path (no specialized field type required), giving maximum flexibility to combine with any other query clause, but generally comes with a larger index size due to the multiplied token count per term, and less inherently optimized prefix-lookup performance than the purpose-built `completion` suggester.
- [Inference] The edge n-gram approach is generally considered a legacy pattern in favor of `search_as_you_type` for new implementations needing integrated relevance, since `search_as_you_type` was introduced specifically to provide similar flexibility with less manual mapping configuration, though edge n-gram remains a valid and sometimes still-used approach, particularly where fine control over exact n-gram sizing and token filtering is needed.

```json
PUT products
{
  "settings": {
    "analysis": {
      "filter": {
        "edge_ngram_filter": {
          "type": "edge_ngram",
          "min_gram": 1,
          "max_gram": 20
        }
      },
      "analyzer": {
        "autocomplete_analyzer": {
          "tokenizer": "standard",
          "filter": ["lowercase", "edge_ngram_filter"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "product_name": {
        "type": "text",
        "analyzer": "autocomplete_analyzer",
        "search_analyzer": "standard"
      }
    }
  }
}
```

- Using a different `search_analyzer` (standard, without the edge n-gram filter) than the index-time `analyzer` is essential here — applying edge n-gram expansion at search time as well would incorrectly generate prefix combinations of the user's already-partial query term.

### Category and Contextual Suggestions

**Key Points**
- The `completion` suggester supports **context suggesters** (`category` or `geo` context), allowing suggestions to be filtered or boosted based on additional context beyond the prefix text alone — for example, suggesting products only within a category the user is currently browsing.
- This lets a single suggestion index serve multiple contexts (different categories, different regions) without maintaining entirely separate suggestion indices per context.

### Performance Considerations

**Key Points**
- The `completion` suggester's FST structure lives in memory (loaded per segment), which contributes to a node's memory footprint proportional to the size and cardinality of the suggestion input data — very large suggestion vocabularies should be sized and monitored with this in mind.
- `search_as_you_type` and edge n-gram approaches both increase index size relative to a plain `text` field, due to the additional generated sub-fields or tokens, which is a storage/indexing-time cost trade-off against their query-time flexibility.

### Related Topics

- **Search-as-you-type field type** configuration options in depth, including the `max_shingle_size` parameter
- **Context suggesters** (category and geo) configuration and use cases in depth
- **N-gram and edge n-gram tokenizers** more broadly, beyond their autocomplete-specific application
- **Fuzzy query and fuzziness parameter** mechanics shared across suggester and standard fuzzy queries
- **Index size and memory monitoring** for suggestion-heavy indices with large vocabularies
- **Search relevance tuning** as it applies to blending autocomplete results with broader search ranking signals
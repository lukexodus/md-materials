## Normalizers

A normalizer is an analysis component applied to `keyword` fields rather than `text` fields. Like an analyzer, it can include character filters and token filters, but unlike an analyzer it does not include a tokenizer and its output must be a single token — the entire input string transformed, not split into multiple tokens. This allows `keyword` fields to receive light normalization (case-folding, accent-stripping) while preserving their exact-match, non-tokenized nature for filtering, sorting, and aggregations.

### Why Normalizers Exist Separately from Analyzers

`keyword` fields are designed for exact-value use cases — filtering, sorting, terms aggregations — where a field's value should be stored and matched as a single indivisible unit. A `keyword` field by default is analyzed by the `keyword` analyzer (a no-op), meaning `"USA"` and `"usa"` are treated as entirely distinct values. A normalizer allows limited transformation (e.g. lowercasing) to be applied at both index and search time, so that `"USA"` and `"usa"` can be treated as equivalent for exact-match purposes, without introducing tokenization.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 220">
  <text x="400" y="20" font-size="14" font-weight="bold" text-anchor="middle" fill="#333">Analyzer vs. Normalizer (svg_diagram)</text>

  <text x="200" y="50" font-size="13" font-weight="bold" text-anchor="middle" fill="#4285f4">Analyzer (text field)</text>
  <rect x="40" y="65" width="120" height="50" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
  <text x="100" y="94" font-size="11" text-anchor="middle" fill="#1a1a1a">char_filter</text>
  <line x1="160" y1="90" x2="185" y2="90" stroke="#666" stroke-width="1.5" marker-end="url(#arrow4)" />
  <rect x="185" y="65" width="120" height="50" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
  <text x="245" y="94" font-size="11" text-anchor="middle" fill="#1a1a1a">tokenizer</text>
  <line x1="305" y1="90" x2="330" y2="90" stroke="#666" stroke-width="1.5" marker-end="url(#arrow4)" />
  <rect x="330" y="65" width="120" height="50" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
  <text x="390" y="94" font-size="11" text-anchor="middle" fill="#1a1a1a">token filter</text>
  <text x="245" y="135" font-size="10" text-anchor="middle" fill="#777">output: multiple tokens</text>

  <text x="620" y="50" font-size="13" font-weight="bold" text-anchor="middle" fill="#4285f4">Normalizer (keyword field)</text>
  <rect x="500" y="65" width="120" height="50" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
  <text x="560" y="94" font-size="11" text-anchor="middle" fill="#1a1a1a">char_filter</text>
  <line x1="620" y1="90" x2="645" y2="90" stroke="#666" stroke-width="1.5" marker-end="url(#arrow4)" />
  <rect x="645" y="65" width="120" height="50" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
  <text x="705" y="94" font-size="11" text-anchor="middle" fill="#1a1a1a">token filter</text>
  <text x="705" y="135" font-size="10" text-anchor="middle" fill="#777">no tokenizer stage</text>
  <text x="705" y="150" font-size="10" text-anchor="middle" fill="#777">output: single token</text>

  <text x="400" y="195" font-size="11" text-anchor="middle" fill="#888">Both apply at index time and search time to keep matching consistent.</text>
</svg>

### Defining a Custom Normalizer

Unlike analyzers, there is no built-in named normalizer beyond the implicit default (no-op); any non-trivial normalizer must be explicitly defined in index settings and referenced from a `keyword` field's mapping via the `normalizer` parameter.

```json
PUT normalizer_example
{
  "settings": {
    "analysis": {
      "normalizer": {
        "lowercase_normalizer": {
          "type": "custom",
          "filter": ["lowercase", "asciifolding"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "country_code": {
        "type": "keyword",
        "normalizer": "lowercase_normalizer"
      }
    }
  }
}

POST normalizer_example/_analyze
{
  "normalizer": "lowercase_normalizer",
  "text": "USA"
}
```

This produces a single token: `usa`. Indexing a document with `"country_code": "USA"` and later filtering with `"country_code": "usa"` (or vice versa) matches, since both the stored value and the query value pass through the same normalizer.

### Permitted Components in a Normalizer

A normalizer's `filter` array may only reference token filters that operate on a single token without splitting or combining it into multiple tokens. Filters designed to produce multiple tokens from one input — such as `ngram`, `edge_ngram`, `word_delimiter`, `synonym`, or `shingle` — are not valid inside a normalizer, since the normalizer contract requires exactly one token in, one token out. `char_filter` entries are permitted since they operate on the string before any tokenization concept applies.

```json
PUT normalizer_char_filter_example
{
  "settings": {
    "analysis": {
      "char_filter": {
        "hyphen_to_underscore": {
          "type": "mapping",
          "mappings": ["- => _"]
        }
      },
      "normalizer": {
        "sku_normalizer": {
          "type": "custom",
          "char_filter": ["hyphen_to_underscore"],
          "filter": ["uppercase"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "sku": {
        "type": "keyword",
        "normalizer": "sku_normalizer"
      }
    }
  }
}

POST normalizer_char_filter_example/_analyze
{
  "normalizer": "sku_normalizer",
  "text": "abc-123-xyz"
}
```

This produces the single token `ABC_123_XYZ` — the character filter converts hyphens to underscores first, then `uppercase` normalizes case, with the entire input remaining one token throughout.

### Normalizers Apply at Both Index and Search Time

Because a normalizer transforms both the stored value and any query value used to match against it (via `term`, `terms`, or other exact-match queries), consistent matching is preserved automatically without requiring a separate `search_normalizer` concept — this differs from `text` fields, where `search_analyzer` can optionally diverge from the index-time `analyzer`.

```json
POST normalizer_example/_doc
{
  "country_code": "USA"
}

POST normalizer_example/_search
{
  "query": {
    "term": {
      "country_code": "usa"
    }
  }
}
```

This query matches the previously indexed document, since `"usa"` in the query is normalized identically to how `"USA"` was normalized at index time.

### Normalizers and Aggregations

Terms aggregations on a normalized `keyword` field return bucket keys in their normalized form, not the original input form, since the normalized value is what is actually stored in the field's doc values used for aggregation.

```json
POST normalizer_example/_search
{
  "size": 0,
  "aggs": {
    "by_country": {
      "terms": {
        "field": "country_code"
      }
    }
  }
}
```

If documents were indexed with `"USA"` and `"usa"` as raw input values, this aggregation returns a single bucket keyed `usa` (assuming `lowercase_normalizer` from the earlier example), with a combined document count — the original casing distinction is not recoverable from the aggregation unless the raw value is separately stored in another field.

### Common Use Cases

**Key Points**
- Case-insensitive exact matching on fields like country codes, status enums, tags, or SKUs, where full tokenization is undesired but strict case-sensitivity is also undesired.
- Accent-insensitive exact matching (via `asciifolding`) for `keyword` fields holding names or identifiers that may be entered with or without diacritics.
- Normalizing whitespace or punctuation variants (via `mapping` or `pattern_replace` character filters) so that superficially different but semantically identical values collapse to the same stored form.
- Normalizers should not be used as a substitute for `text` fields when actual full-text search (multi-word matching, relevance scoring, partial matching) is needed — a normalizer is strictly narrower in purpose than an analyzer's tokenization capability.

### Related Topics

- Keyword Field Type — mapping parameters and use cases
- Token Filters — which are normalizer-compatible (single-token-preserving) vs. not
- Character Filters — `mapping`, `html_strip`, `pattern_replace` in normalizer context
- Custom Analyzers — the `text` field equivalent of custom normalizers
- Terms Aggregations — how normalized values affect bucket keys
- `term` / `terms` Queries — exact-match query behavior against normalized fields
- Multi-fields — combining a normalized `keyword` sub-field with an analyzed `text` field
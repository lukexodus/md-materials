## Suggesters

### Overview

Suggesters are a family of Elasticsearch query mechanisms designed to power "did you mean," autocomplete, and typo-tolerant search features. Rather than returning matching documents, suggesters return candidate terms, phrases, or completions ranked by relevance to a user's partial or misspelled input. They are invoked through the `_search` API's `suggest` section, separate from the main `query` clause, and can be combined with a normal query in the same request.

**Key Points**

- Three primary suggester types exist: **term**, **phrase**, and **completion**, each solving a different UX problem.
- Suggesters operate on indexed terms (term, phrase) or a specialized in-memory structure (completion), not on live document scoring.
- They are commonly combined: completion suggesters for fast autocomplete-as-you-type, and term/phrase suggesters for post-search "did you mean" corrections.

### Term Suggester

The term suggester works on a per-term basis, suggesting corrections for each token in the input independently, based on edit distance against terms present in the index.

- It does not consider word order or context — each term is corrected in isolation.
- Candidate terms are drawn from the field's indexed terms, scored by string similarity (Levenshtein distance by default, configurable) and term frequency.
- Useful as a lower-level building block, but generally superseded by the phrase suggester for realistic "did you mean" use cases since it ignores context.

**Example**

```json
GET /articles/_search
{
  "suggest": {
    "text": "elasticsaerch aggregations",
    "my-term-suggestion": {
      "term": {
        "field": "content",
        "suggest_mode": "popular"
      }
    }
  }
}
```

**Output**

```json
{
  "suggest": {
    "my-term-suggestion": [
      {
        "text": "elasticsaerch",
        "offset": 0,
        "length": 13,
        "options": [
          { "text": "elasticsearch", "score": 0.85, "freq": 120 }
        ]
      },
      {
        "text": "aggregations",
        "offset": 14,
        "length": 13,
        "options": []
      }
    ]
  }
}
```

Each input token is evaluated independently; `aggregations` returns no suggestions because it already matches an indexed term.

`suggest_mode` controls which candidates are considered:

- `missing` (default): only suggest for terms not present in the index.
- `popular`: only suggest terms more frequent than the original.
- `always`: suggest for every term regardless of whether it exists in the index.

### Phrase Suggester

The phrase suggester extends the term suggester by scoring candidate corrections at the **phrase level** using n-gram language models, so it accounts for word co-occurrence rather than correcting each word in isolation.

- Requires a field indexed with shingles (word n-grams) for effective scoring — typically a dedicated sub-field using a `shingle` filter in its analyzer.
- Produces more contextually accurate corrections than the term suggester because it considers how likely word sequences are to co-occur, not just individual term similarity.
- Supports `collate`, which re-runs a specified query against each candidate correction and filters out corrections that would return zero results — preventing suggestions for phrases that don't actually exist as real content.

**Example**

```json
PUT /articles
{
  "settings": {
    "analysis": {
      "analyzer": {
        "trigram": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": ["lowercase", "shingle"]
        }
      },
      "filter": {
        "shingle": {
          "type": "shingle",
          "min_shingle_size": 2,
          "max_shingle_size": 3
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "content": {
        "type": "text",
        "fields": {
          "trigram": { "type": "text", "analyzer": "trigram" }
        }
      }
    }
  }
}
```

```json
GET /articles/_search
{
  "suggest": {
    "text": "elasticsaerch aggreagtions",
    "my-phrase-suggestion": {
      "phrase": {
        "field": "content.trigram",
        "size": 1,
        "gram_size": 3,
        "confidence": 0,
        "collate": {
          "query": {
            "source": {
              "match": { "content": "{{suggestion}}" }
            }
          }
        }
      }
    }
  }
}
```

**Output**

```json
{
  "suggest": {
    "my-phrase-suggestion": [
      {
        "text": "elasticsaerch aggreagtions",
        "offset": 0,
        "length": 27,
        "options": [
          { "text": "elasticsearch aggregations", "score": 0.72 }
        ]
      }
    ]
  }
}
```

### Completion Suggester

The completion suggester is built for low-latency, prefix-based autocomplete — the "type-ahead" behavior seen in search boxes. It is architecturally distinct from the term and phrase suggesters.

- Backed by a purpose-built, in-memory finite state transducer (FST) structure rather than the standard inverted index, which is what allows sub-millisecond response times even under high query volume.
- Requires a dedicated field of type `completion` in the mapping; plain `text` or `keyword` fields cannot be queried with a completion suggester.
- Matches only on **prefixes** of the input tokens, not arbitrary substrings or edit-distance corrections.
- Supports weighted suggestions (`weight` field) to bias ranking — e.g., boosting popular products or recently trending queries above alphabetically earlier matches.
- Supports contextual filtering via `contexts` (category or geo context), allowing suggestions to be scoped, for example, by product category or by proximity to a location.

**Example**

```json
PUT /products
{
  "mappings": {
    "properties": {
      "suggest": { "type": "completion" }
    }
  }
}
```

```json
POST /products/_doc
{
  "suggest": {
    "input": ["Nike Air Max", "Nike Air Force 1"],
    "weight": 10
  }
}
```

```json
GET /products/_search
{
  "suggest": {
    "product-suggest": {
      "prefix": "nike ai",
      "completion": {
        "field": "suggest",
        "size": 5,
        "fuzzy": {
          "fuzziness": 1
        }
      }
    }
  }
}
```

**Output**

```json
{
  "suggest": {
    "product-suggest": [
      {
        "text": "nike ai",
        "offset": 0,
        "length": 7,
        "options": [
          { "text": "Nike Air Max", "_score": 10 },
          { "text": "Nike Air Force 1", "_score": 10 }
        ]
      }
    ]
  }
}
```

The optional `fuzzy` parameter allows the completion suggester to tolerate minor typos in the prefix itself (edit-distance matching on the prefix), at some cost to latency compared to exact-prefix matching.

### Comparing the Three Suggesters

| Aspect | Term | Phrase | Completion |
| --- | --- | --- | --- |
| Scoring unit | Individual term | Full phrase (n-gram model) | Prefix match |
| Context-aware | No | Yes | No (prefix-only, optional context filters) |
| Data structure | Inverted index | Inverted index + shingles | FST (in-memory) |
| Typical use case | Building block | "Did you mean" | Autocomplete / type-ahead |
| Requires dedicated field type | No | No (but benefits from shingle sub-field) | Yes (`completion` type) |
| Latency profile | Standard query latency | Standard to higher (n-gram scoring) | Very low (optimized structure) |

===MERMAID_DIAGRAM===

flowchart TD

A[User input] --> B{Suggester type}

B -->|Per-term correction| C[Term Suggester]

B -->|Contextual phrase correction| D[Phrase Suggester]

B -->|Prefix-based type-ahead| E[Completion Suggester]

C --> F[Edit distance vs indexed terms]

D --> G[N-gram / shingle language model]

D --> H[Optional collate query filter]

E --> I[FST structure lookup]

E --> J[Optional fuzzy + context filtering]

### Performance Considerations

- The completion suggester's FST is held in memory per shard, which gives its speed advantage but also means it consumes heap proportional to the number of indexed suggestions — a factor to account for in cluster sizing when suggestion volume is large.
- The phrase suggester's reliance on shingle-indexed fields increases index size and indexing time compared to standard text fields, since n-gram fields store substantially more terms.
- [Inference] For very high query-per-second autocomplete use cases, the completion suggester is generally preferred over running phrase or term suggestions on every keystroke, since its FST lookup is designed specifically for that latency profile — but actual throughput depends on shard count, suggestion volume, and hardware, and should be validated with load testing rather than assumed.
- [Unverified] Behavior and available options for all three suggesters can differ across Elasticsearch versions; current field-level defaults and parameter names should be confirmed against the documentation for the specific version in use.

### Related Topics

- Search-as-you-type field type as an alternative to the completion suggester
- Shingle and n-gram tokenizers/filters in custom analyzers
- Context suggesters (category and geo context) in depth
- Edge n-gram approaches for autocomplete without a dedicated `completion` field
- Fuzzy query and fuzziness parameters across query types
- Analyzer design for multilingual autocomplete and suggestion use cases
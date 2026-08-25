## Elasticsearch match_phrase Query

The `match_phrase` query extends full-text search by requiring that search terms appear **in the exact order** and **in proximity** to one another. It is used when word sequence matters, not just word presence.

---

### How It Works

Like `match`, the `match_phrase` query analyzes the input string. However, instead of treating the resulting tokens independently, it requires:

1. All tokens must be present in the field
2. Tokens must appear in the same order as in the query
3. Tokens must be in the correct positional relationship to each other (by default, adjacent)

**Key Points:**
- Built on top of Lucene's phrase query mechanism
- Position information recorded at index time is used for matching
- Fields must store position data (enabled by default for `text` fields)
- Not suitable for `keyword` fields; use `term` for exact keyword matching

---

### Basic Syntax

```json
GET /index_name/_search
{
  "query": {
    "match_phrase": {
      "field_name": "exact phrase here"
    }
  }
}
```

Expanded form with parameters:

```json
GET /index_name/_search
{
  "query": {
    "match_phrase": {
      "field_name": {
        "query": "exact phrase here"
      }
    }
  }
}
```

---

### Practical Example

Assume an index called `articles` with a `content` field mapped as `text`.

```json
GET /articles/_search
{
  "query": {
    "match_phrase": {
      "content": "quick brown fox"
    }
  }
}
```

**What happens internally:**
1. The query string is analyzed → tokens: `quick`, `brown`, `fox`
2. Elasticsearch checks that all three tokens exist in the field
3. It also checks that their positions are consecutive: `quick` at position N, `brown` at N+1, `fox` at N+2
4. Only documents satisfying all three conditions are returned

**Output:**
Documents where `"quick brown fox"` appears as a contiguous phrase, ranked by `_score`.

---

### Comparison: match vs match_phrase

```json
// match — returns documents containing any of: "quick", "brown", "fox"
{
  "query": {
    "match": {
      "content": "quick brown fox"
    }
  }
}

// match_phrase — returns only documents where "quick brown fox" appears in sequence
{
  "query": {
    "match_phrase": {
      "content": "quick brown fox"
    }
  }
}
```

| Behavior | `match` | `match_phrase` |
|---|---|---|
| Analyzes query | Yes | Yes |
| All tokens required | No (default `or`) | Yes |
| Order enforced | No | Yes |
| Position-aware | No | Yes |

---

### The `slop` Parameter

By default, tokens must be strictly adjacent. The `slop` parameter allows a specified number of intervening or transposed words between tokens.

```json
GET /articles/_search
{
  "query": {
    "match_phrase": {
      "content": {
        "query": "quick fox",
        "slop": 1
      }
    }
  }
}
```

With `slop: 1`, the phrase `"quick brown fox"` would match because only one word (`brown`) separates `quick` and `fox`.

**Key Points:**
- `slop` represents the number of positional moves allowed to reconstruct the phrase
- A `slop` of `0` is the default — strict adjacency required
- Higher slop values increase recall but reduce precision
- [Inference] Very high slop values may behave similarly to a `match` query with `and` operator; behavior depends on the specific token positions in indexed documents

| Slop Value | Effect |
|---|---|
| `0` | Tokens must be strictly adjacent |
| `1` | One intervening word allowed |
| `2` | Two intervening words, or one transposition allowed |
| N | Up to N positional moves allowed |

---

### Slop and Word Transposition

`slop` also accounts for **transpositions** — words appearing in reverse order relative to the query.

**Example:**

Index contains: `"the fox quick jumped"`
Query: `"quick fox"` with `slop: 2`

[Inference] The transposition of `quick` and `fox` may be matched depending on the positional distance calculated; exact behavior depends on the Lucene phrase scoring implementation and is not guaranteed.

---

### The `analyzer` Parameter

As with `match`, you can override the query-time analyzer.

```json
GET /articles/_search
{
  "query": {
    "match_phrase": {
      "content": {
        "query": "Running Quickly",
        "analyzer": "english"
      }
    }
  }
}
```

**Key Points:**
- The `english` analyzer stems tokens: `"Running"` → `"run"`, `"Quickly"` → `"quick"`
- Phrase matching then operates on the stemmed tokens
- [Inference] A mismatch between index-time and query-time analyzers may cause unexpected misses or matches; behavior is not guaranteed to be consistent across configurations

---

### The `zero_terms_query` Parameter

Behaves identically to its counterpart in `match`. If analysis removes all tokens, this controls what is returned.

```json
GET /articles/_search
{
  "query": {
    "match_phrase": {
      "content": {
        "query": "to be",
        "zero_terms_query": "all"
      }
    }
  }
}
```

| Value | Behavior |
|---|---|
| `none` (default) | No documents returned when all tokens are removed |
| `all` | All documents returned when all tokens are removed |

---

### Position Increments and Stop Words

When an analyzer removes stop words, it preserves **position increments** — the gap left by the removed word counts toward token positions.

**Example:**

Field value: `"the quick brown fox"`
After analysis with stop word removal: tokens `quick`(pos 1), `brown`(pos 2), `fox`(pos 3)

Query: `"quick brown fox"` — matches because positions align.

Query: `"quick fox"` with `slop: 0` — does **not** match because `fox` is at position 3, not position 2.

Query: `"quick fox"` with `slop: 1` — matches because the position gap of 1 is within the allowed slop.

**Key Points:**
- Position gap behavior depends on the analyzer configuration and how it handles stop words
- [Inference] Unexpected phrase misses may be caused by position gaps introduced by stop word removal; behavior varies by analyzer

---

### Index Configuration Requirement

`match_phrase` depends on **term positions** being stored in the index. This is controlled by the `index_options` mapping parameter.

| `index_options` value | Stores Positions |
|---|---|
| `docs` | No |
| `freqs` | No |
| `positions` (default for `text`) | Yes |
| `offsets` | Yes |

**Key Points:**
- The default mapping for `text` fields stores positions, so `match_phrase` works out of the box
- If `index_options` is explicitly set to `docs` or `freqs`, `match_phrase` cannot function correctly on that field
- [Inference] Querying with `match_phrase` on a field without position data may return no results or behave unexpectedly; this is not guaranteed behavior

---

### Relevance Scoring

`match_phrase` scores documents using BM25 as a baseline, but phrase proximity also influences scoring.

**Key Points:**
- Documents where the phrase appears with fewer intervening words (lower effective slop used) typically score higher
- [Inference] When `slop` is greater than `0`, documents where the phrase is more tightly packed may receive higher scores; exact scoring behavior depends on Elasticsearch version and index configuration

---

### Common Use Cases

| Use Case | Example Query |
|---|---|
| Exact phrase search | `"machine learning"` in a research database |
| Name matching | `"John Smith"` in a contacts index |
| Code or error message search | `"null pointer exception"` in a logs index |
| Near-phrase search with slop | `"open source"` with slop to catch `"open and free source"` |

---

### Common Mistakes

**Expecting stop word phrases to match without slop:**

```json
{
  "query": {
    "match_phrase": {
      "content": "to be or not"
    }
  }
}
```

If the analyzer removes stop words (`to`, `be`, `or`, `not`), all tokens may be eliminated. Use `zero_terms_query: "all"` or choose an analyzer that retains these words.

---

**Using `match_phrase` on a `keyword` field:**

```json
{
  "query": {
    "match_phrase": {
      "status.keyword": "in progress"
    }
  }
}
```

[Inference] This may not behave as expected because `keyword` fields are not analyzed and do not store position data; use `term` for exact matching on `keyword` fields.

---

### Summary of Parameters

| Parameter | Type | Default | Purpose |
|---|---|---|---|
| `query` | string | *(required)* | The phrase to search for |
| `slop` | integer | `0` | Number of positional moves allowed between tokens |
| `analyzer` | string | Field default | Analyzer applied at query time |
| `zero_terms_query` | string | `none` | Behavior when all tokens removed by analyzer |

---

**Conclusion:**
`match_phrase` is the appropriate query when word order and proximity carry semantic meaning. The `slop` parameter provides flexibility without fully abandoning phrase structure. Understanding position data, stop word behavior, and analyzer alignment is essential for using it reliably.

**Next Steps:**
- `match_phrase_prefix` — phrase matching with wildcard behavior on the final term, commonly used for search-as-you-type
- `intervals` query — more expressive positional matching rules
- `span_near` query — low-level positional query for advanced proximity control
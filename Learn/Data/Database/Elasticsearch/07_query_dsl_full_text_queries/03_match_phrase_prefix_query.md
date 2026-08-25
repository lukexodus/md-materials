## Elasticsearch match_phrase_prefix Query

The `match_phrase_prefix` query combines phrase matching with prefix matching on the **last term** of the query string. It is primarily used to implement search-as-you-type functionality, where users are still typing and the final word may be incomplete.

---

### How It Works

`match_phrase_prefix` behaves like `match_phrase` with one key difference: the last token in the analyzed query string is treated as a **prefix** rather than a complete term.

**Key Points:**
- All tokens except the last must match exactly, in order, with position awareness
- The last token matches any indexed term that **begins with** that token
- Analyzed at query time using the field's analyzer (or an overridden one)
- Relies on position data stored at index time, same as `match_phrase`
- Not a substitute for a dedicated autocomplete solution at scale; see `search_as_you_type` field type or `completion` suggester for production use cases

---

### Basic Syntax

```json
GET /index_name/_search
{
  "query": {
    "match_phrase_prefix": {
      "field_name": "search tex"
    }
  }
}
```

Expanded form:

```json
GET /index_name/_search
{
  "query": {
    "match_phrase_prefix": {
      "field_name": {
        "query": "search tex"
      }
    }
  }
}
```

---

### Practical Example

Assume an index called `articles` with a `title` field mapped as `text`.

```json
GET /articles/_search
{
  "query": {
    "match_phrase_prefix": {
      "title": "elastic full tex"
    }
  }
}
```

**What happens internally:**
1. Query is analyzed → tokens: `elastic`, `full`, `tex`
2. `elastic` and `full` must appear in order as complete terms
3. `tex` is treated as a prefix — matches `text`, `texts`, `textual`, etc.
4. The phrase `"elastic full text"`, `"elastic full texts"`, etc. would match

**Output:**
Documents where the title contains the phrase starting with `"elastic full"` followed by any word beginning with `"tex"`, ranked by `_score`.

---

### The `slop` Parameter

As with `match_phrase`, `slop` allows positional flexibility between tokens.

```json
GET /articles/_search
{
  "query": {
    "match_phrase_prefix": {
      "title": {
        "query": "elastic tex",
        "slop": 1
      }
    }
  }
}
```

**Key Points:**
- `slop` applies to the positional relationship between all tokens, including the prefix-matched last token
- Default is `0` — strict adjacency required
- [Inference] Combining `slop` with prefix matching increases both recall and query complexity; behavior at higher slop values depends on index content and term distribution

---

### The `max_expansions` Parameter

Because the last token is a prefix, it can potentially match a very large number of indexed terms. `max_expansions` limits how many terms the prefix expands to.

```json
GET /articles/_search
{
  "query": {
    "match_phrase_prefix": {
      "title": {
        "query": "elastic full tex",
        "max_expansions": 10
      }
    }
  }
}
```

**Key Points:**
- Default value is `50`
- Elasticsearch collects up to `max_expansions` terms that match the prefix, then executes the phrase query against those terms
- [Inference] A low `max_expansions` value may cause relevant documents to be missed if the matching term is not among the first N expanded terms; the selection of which terms are expanded is not guaranteed to be predictable or ordered alphabetically in all cases
- [Inference] A very high `max_expansions` value may increase query latency on large indices; behavior depends on index size and term cardinality

| Value | Effect |
|---|---|
| Low (e.g., `5`) | Faster, but may miss relevant results |
| Default (`50`) | Balanced trade-off |
| High (e.g., `500`) | More complete, but potentially slower |

---

### The `analyzer` Parameter

Query-time analyzer can be overridden.

```json
GET /articles/_search
{
  "query": {
    "match_phrase_prefix": {
      "title": {
        "query": "Running Qui",
        "analyzer": "english"
      }
    }
  }
}
```

**Key Points:**
- The analyzer is applied to all tokens including the last one, **before** it is treated as a prefix
- [Inference] Stemming analyzers may transform the last token before prefix expansion in ways that produce unexpected matches or misses; behavior depends on the analyzer and the prefix entered

---

### The `slop` and `max_expansions` Interaction

These two parameters work independently but combine to shape result quality:

| Scenario | Slop | max_expansions | Effect |
|---|---|---|---|
| Strict autocomplete | `0` | `50` | Adjacent phrase, up to 50 prefix expansions |
| Flexible autocomplete | `1–2` | `50` | Some word gap allowed |
| Broad but fast | `0` | `10` | Fast, but may miss terms |
| Broad and thorough | `2` | `100` | Higher recall, higher resource use |

---

### The `zero_terms_query` Parameter

Same behavior as in `match` and `match_phrase`.

```json
GET /articles/_search
{
  "query": {
    "match_phrase_prefix": {
      "title": {
        "query": "to be",
        "zero_terms_query": "all"
      }
    }
  }
}
```

| Value | Behavior |
|---|---|
| `none` (default) | No documents returned if all tokens removed by analyzer |
| `all` | All documents returned if all tokens removed by analyzer |

---

### Comparison: match_phrase vs match_phrase_prefix

```json
// match_phrase — "tex" must appear exactly as a complete term
{
  "query": {
    "match_phrase": {
      "title": "elastic full tex"
    }
  }
}

// match_phrase_prefix — "tex" matches any term starting with "tex"
{
  "query": {
    "match_phrase_prefix": {
      "title": "elastic full tex"
    }
  }
}
```

| Behavior | `match_phrase` | `match_phrase_prefix` |
|---|---|---|
| Analyzes query | Yes | Yes |
| All tokens required | Yes | Yes |
| Order enforced | Yes | Yes |
| Last token as prefix | No | Yes |
| Suitable for autocomplete | No | Yes (with caveats) |

---

### Position Data Requirement

Like `match_phrase`, this query depends on term positions being stored at index time.

**Key Points:**
- Default `text` field mapping stores positions (`index_options: positions`)
- If positions are not stored, the query cannot enforce phrase order
- [Inference] Running `match_phrase_prefix` on a field without position data may return incorrect or empty results; behavior is not guaranteed

---

### Relevance Scoring

Scoring follows the same BM25-based approach as `match_phrase`.

**Key Points:**
- Documents where the phrase (including the prefix-matched final word) appears with tighter proximity score higher
- All expanded prefix terms contribute to scoring individually
- [Inference] Score distribution may vary significantly depending on which terms the prefix expands to and their frequency in the index; scores should not be treated as absolute relevance values

---

### Limitations and Alternatives

`match_phrase_prefix` is convenient but has known limitations at scale.

| Limitation | Detail |
|---|---|
| Prefix expansion overhead | Each query expands the last token into up to `max_expansions` terms at query time |
| No infix matching | Only the **last** token is treated as a prefix; middle-word prefixes are not supported |
| No ranking by popularity | Expanded terms are not ranked by frequency before the phrase query executes |
| Not optimized for high-concurrency autocomplete | [Inference] Under high query load, prefix expansion may contribute to latency; not confirmed across all configurations |

**Alternatives for production autocomplete:**

| Alternative | Approach |
|---|---|
| `search_as_you_type` field type | Index-time optimization for prefix and infix matching |
| `completion` suggester | Purpose-built for fast, ranked autocomplete |
| `edge_ngram` tokenizer | Pre-expands prefixes at index time for faster query execution |

---

### Common Mistakes

**Treating `max_expansions` as a result limit:**

`max_expansions` limits how many **terms** the prefix expands to, not how many **documents** are returned. Document count is controlled by the `size` parameter in the search request.

---

**Expecting infix matching:**

```json
{
  "query": {
    "match_phrase_prefix": {
      "title": "elas tex"
    }
  }
}
```

This does **not** match `"elasticsearch full text"` unless `"elas"` is itself a complete indexed term. Only the **last** token gets prefix treatment. Use `edge_ngram` or `search_as_you_type` for infix scenarios.

---

**Using on `keyword` fields:**

`keyword` fields are not analyzed and do not store positions. `match_phrase_prefix` is not appropriate for `keyword` fields. Use `prefix` query instead for unanalyzed prefix matching.

---

### Summary of Parameters

| Parameter | Type | Default | Purpose |
|---|---|---|---|
| `query` | string | *(required)* | The phrase (with potentially incomplete last word) |
| `slop` | integer | `0` | Positional moves allowed between tokens |
| `max_expansions` | integer | `50` | Maximum number of terms the prefix expands to |
| `analyzer` | string | Field default | Analyzer applied at query time |
| `zero_terms_query` | string | `none` | Behavior when all tokens removed by analyzer |

---

**Conclusion:**
`match_phrase_prefix` provides a quick path to search-as-you-type functionality by treating the final query token as a prefix. It requires minimal setup but carries query-time expansion costs that make it less suitable for high-scale or high-concurrency autocomplete. For those cases, index-time solutions such as `search_as_you_type` or `completion` suggester are more appropriate.

**Next Steps:**
- `multi_match` query — running `match`-style queries across multiple fields simultaneously
- `search_as_you_type` field type — index-time optimized alternative for autocomplete
- `completion` suggester — purpose-built ranked autocomplete
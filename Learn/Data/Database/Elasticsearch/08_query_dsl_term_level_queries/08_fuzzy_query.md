### Elasticsearch Query DSL – Fuzzy Query

#### Overview

The **fuzzy query** in Elasticsearch finds documents containing terms that are similar to the search term, based on a measure called **edit distance** (also known as Levenshtein distance). It is useful for handling typos, misspellings, and slight variations in user input.

---

#### Edit Distance and Fuzziness

Edit distance measures how many single-character changes are needed to transform one word into another. The supported operations are:

- Inserting a character
- Deleting a character
- Substituting a character
- Transposing two adjacent characters

The `fuzziness` parameter controls the maximum edit distance allowed.

| `fuzziness` Value | Meaning |
| --- | --- |
| `0` | Exact match only |
| `1` | Up to 1 edit allowed |
| `2` | Up to 2 edits allowed |
| `AUTO` | Automatically selects 0, 1, or 2 based on term length (recommended) |

**`AUTO` behavior (default thresholds):**

- Term length 0–2 → fuzziness `0`
- Term length 3–5 → fuzziness `1`
- Term length 6+ → fuzziness `2`

> **Note:** `AUTO` is the recommended value in most cases. Behavior may vary depending on term length and analyzer output. Fuzziness does not apply beyond `2`; Elasticsearch does not support edit distances greater than `2`.

---

#### Basic Syntax

json

```
GET /index_name/_search
{
  "query": {
    "fuzzy": {
      "field_name": {
        "value": "search_term"
      }
    }
  }
}
```

---

#### Full Parameter Reference

json

```
GET /products/_search
{
  "query": {
    "fuzzy": {
      "name": {
        "value": "laptoop",
        "fuzziness": "AUTO",
        "max_expansions": 50,
        "prefix_length": 0,
        "transpositions": true,
        "rewrite": "constant_score"
      }
    }
  }
}
```

##### Parameter Breakdown

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | string | *(required)* | The term to search for |
| `fuzziness` | string/int | `AUTO` | Maximum edit distance |
| `max_expansions` | integer | `50` | Maximum number of variations the query expands to |
| `prefix_length` | integer | `0` | Number of leading characters that must match exactly |
| `transpositions` | boolean | `true` | Whether transpositions count as a single edit |
| `rewrite` | string | `constant_score` | Controls how matched terms affect scoring |

---

#### Practical Example

**Scenario:** A user types `"laptoop"` instead of `"laptop"` in a product search.

json

```
GET /products/_search
{
  "query": {
    "fuzzy": {
      "name": {
        "value": "laptoop",
        "fuzziness": "AUTO",
        "prefix_length": 1
      }
    }
  }
}
```

**What happens:**

- `"laptoop"` has 7 characters → `AUTO` allows up to 2 edits
- `"laptop"` is 1 deletion away → within the allowed edit distance
- `prefix_length: 1` requires the first character (`l`) to match exactly, reducing unnecessary expansions

**Output**

json

```
{
  "hits": {
    "hits": [
      {
        "_source": {
          "name": "laptop",
          "price": 999
        }
      }
    ]
  }
}
```

> Actual output depends on indexed data and cluster configuration. Behavior is not guaranteed.

---

#### `prefix_length` — Reducing Noise

`prefix_length` specifies how many leading characters must match exactly before fuzziness is applied. Increasing this value:

- Reduces the number of irrelevant matches
- Improves query performance by narrowing expansion candidates

**Example:** With `prefix_length: 2` and search term `"laptoop"`, only terms beginning with `"la"` are candidates for fuzzy expansion.

> [Inference] Higher `prefix_length` values generally improve performance by limiting expansion scope. Actual performance impact may vary based on index size and hardware.

---

#### `max_expansions` — Controlling Expansion

Fuzzy queries work by expanding the search term into all terms within the allowed edit distance. `max_expansions` caps how many of those expanded terms are considered.

- Lower values → faster queries, but may miss some matches
- Higher values → broader matching, but higher resource usage

> **Caution:** Setting `max_expansions` very high on large indices may increase query latency. Behavior may vary.

---

#### `transpositions` Parameter

When `transpositions: true`, swapping two adjacent characters counts as **one edit** instead of two.

**Example:**

| Input | Target | `transpositions: true` | `transpositions: false` |
| --- | --- | --- | --- |
| `"aelsticsearch"` | `"elasticsearch"` | 1 edit (transposition) | 2 edits (delete + insert) |

This follows the **Damerau-Levenshtein** distance model when enabled, and the standard **Levenshtein** model when disabled.

---

#### Fuzzy Query vs. Other Queries

| Feature | `fuzzy` | `match` with fuzziness | `wildcard` |
| --- | --- | --- | --- |
| Typo tolerance | ✅ | ✅ | ❌ |
| Runs on analyzed terms | ✅ | ✅ | ❌ (not analyzed) |
| Prefix anchoring | Via `prefix_length` | Via `fuzzy_prefix_length` | Via pattern |
| Scoring | Yes | Yes | No (by default) |
| Performance | Moderate | Moderate | Can be slow |

> **Note:** The `match` query with a `fuzziness` parameter is generally preferred for full-text fields because it goes through the analysis chain. The `fuzzy` query operates on terms post-analysis and is better suited for `keyword` fields or already-analyzed terms.

---

#### When to Use the Fuzzy Query

- Searching `keyword` fields where you want typo tolerance
- Building search-as-you-type interfaces with minor spelling correction
- Situations where user input is known to be error-prone

#### When Not to Use It

- On large `text` fields where the `match` query with `fuzziness` is more appropriate
- When exact term matching is required
- When query performance is highly constrained and expansion cost is a concern

---

#### Important Limitations

- Fuzziness is capped at `2`; terms requiring more than 2 edits will not match
- The fuzzy query does **not** go through the analysis chain on its own — the `value` is matched against already-analyzed index terms
- Avoid using on `text` fields with complex analyzers without understanding how terms are stored in the inverted index

---

#### Key Points

- The fuzzy query matches terms within a specified edit distance from the search term
- `fuzziness: "AUTO"` is the recommended setting for most use cases
- `prefix_length` and `max_expansions` are the primary tuning parameters for performance
- `transpositions: true` (default) applies Damerau-Levenshtein distance
- For full-text fields, prefer `match` with `fuzziness` over a standalone fuzzy query
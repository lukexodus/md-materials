## Elasticsearch intervals Query

The `intervals` query provides fine-grained control over the **order, proximity, and positional relationships** between matching terms or phrases. It is the most expressive positional query in Elasticsearch, designed for cases where `match_phrase` and `slop` are insufficient to describe the required term arrangement.

---

### How It Works

The `intervals` query operates on **interval rules** — building blocks that define how terms, phrases, or groups of terms must appear relative to each other in a field. Rules can be nested and combined to express complex positional constraints.

**Key Points:**

- Operates on a single field per query clause
- Uses position data stored at index time (same requirement as `match_phrase`)
- Does not use BM25 scoring by default; matches are positional, not frequency-weighted
- Rules are composable — simple rules combine into complex positional expressions
- Introduced in Elasticsearch 7.0; not available in earlier versions

---

### Core Concepts: Intervals

An **interval** is a contiguous span of positions within a field. Each rule produces a set of intervals for a document. The `intervals` query checks whether the produced intervals satisfy the defined constraints.

**Key Points:**

- An interval has a start position, an end position, and a gaps count
- Rules can filter, constrain, or combine intervals from other rules
- [Inference] The efficiency of interval queries depends on the complexity of the rule tree and index size; deeply nested rules may have higher query latency than simpler positional queries

---

### Basic Syntax

```json
GET /index_name/_search
{
  "query": {
    "intervals": {
      "field_name": {
        "<rule_type>": { }
      }
    }
  }
}
```

The `intervals` query targets a **single field** and takes exactly one top-level rule.

---

### Interval Rules Overview

|Rule|Purpose|
|---|---|
|`match`|Matches analyzed terms or phrases|
|`prefix`|Matches terms starting with a given prefix|
|`wildcard`|Matches terms using a wildcard pattern|
|`fuzzy`|Matches terms within an edit distance|
|`all_of`|All sub-rules must match, with positional constraints|
|`any_of`|At least one sub-rule must match|

---

### Rule: match

The foundational rule. Matches a term or phrase within the field.

```json
GET /articles/_search
{
  "query": {
    "intervals": {
      "content": {
        "match": {
          "query": "quick brown fox"
        }
      }
    }
  }
}
```

**Key Points:**

- By default, treats the query as a phrase (terms must appear in order)
- `ordered` controls whether term order is enforced
- `max_gaps` controls how many positions may exist between terms

#### match Parameters

|Parameter|Type|Default|Purpose|
|---|---|---|---|
|`query`|string|_(required)_|Terms to match|
|`max_gaps`|integer|`-1` (unlimited)|Maximum allowed gaps between terms|
|`ordered`|boolean|`true`|Whether terms must appear in the specified order|
|`analyzer`|string|Field default|Analyzer to apply to the query|
|`filter`|object|—|Interval filter to apply|
|`use_field`|string|—|Match intervals from a different field|

---

#### max_gaps

```json
GET /articles/_search
{
  "query": {
    "intervals": {
      "content": {
        "match": {
          "query": "quick fox",
          "max_gaps": 2
        }
      }
    }
  }
}
```

**Key Points:**

- `max_gaps: 0` means terms must be adjacent (equivalent to a phrase with no slop)
- `max_gaps: -1` (default) means no gap restriction
- `max_gaps: N` allows up to N positions between the first and last matched term

|max_gaps|Behavior|
|---|---|
|`0`|Terms must be immediately adjacent|
|`1`|One word may appear between terms|
|`-1`|No gap restriction|

---

#### ordered

```json
GET /articles/_search
{
  "query": {
    "intervals": {
      "content": {
        "match": {
          "query": "fox quick",
          "ordered": false
        }
      }
    }
  }
}
```

**Key Points:**

- `ordered: true` (default) — terms must appear in the query order
- `ordered: false` — terms may appear in any order within the interval

---

### Rule: prefix

Matches any term in the field that begins with the specified prefix.

```json
GET /articles/_search
{
  "query": {
    "intervals": {
      "content": {
        "prefix": {
          "prefix": "elast"
        }
      }
    }
  }
}
```

#### prefix Parameters

|Parameter|Type|Default|Purpose|
|---|---|---|---|
|`prefix`|string|_(required)_|The prefix to match|
|`analyzer`|string|Field default|Analyzer applied to the prefix|
|`use_field`|string|—|Use intervals from a different field|

**Key Points:**

- Not analyzed by default in the same way as `match`; the prefix is matched against indexed terms
- [Inference] Prefix rules on high-cardinality fields may expand to a large number of terms; behavior depends on index term distribution

---

### Rule: wildcard

Matches terms using a wildcard pattern.

```json
GET /articles/_search
{
  "query": {
    "intervals": {
      "content": {
        "wildcard": {
          "pattern": "elast*search"
        }
      }
    }
  }
}
```

#### wildcard Parameters

|Parameter|Type|Default|Purpose|
|---|---|---|---|
|`pattern`|string|_(required)_|Wildcard pattern (`*` = any chars, `?` = one char)|
|`analyzer`|string|Field default|Analyzer applied to the pattern|
|`use_field`|string|—|Use intervals from a different field|

**Key Points:**

- Leading wildcards are permitted but may be resource-intensive
- [Inference] Wildcard patterns with leading `*` may require scanning all terms in the index; use with caution on large indices

---

### Rule: fuzzy

Matches terms within a specified edit distance.

```json
GET /articles/_search
{
  "query": {
    "intervals": {
      "content": {
        "fuzzy": {
          "term": "elasticsaerch",
          "fuzziness": "AUTO"
        }
      }
    }
  }
}
```

#### fuzzy Parameters

|Parameter|Type|Default|Purpose|
|---|---|---|---|
|`term`|string|_(required)_|The term to match fuzzily|
|`fuzziness`|string/int|`AUTO`|Allowed edit distance|
|`prefix_length`|integer|`0`|Characters that must match exactly|
|`transpositions`|boolean|`true`|Whether transpositions count as one edit|
|`analyzer`|string|Field default|Analyzer applied to the term|
|`use_field`|string|—|Use intervals from a different field|

---

### Rule: all_of

Requires **all** specified sub-rules to match, with optional positional constraints between them.

```json
GET /articles/_search
{
  "query": {
    "intervals": {
      "content": {
        "all_of": {
          "intervals": [
            { "match": { "query": "quick" } },
            { "match": { "query": "fox" } }
          ],
          "max_gaps": 3,
          "ordered": true
        }
      }
    }
  }
}
```

**What this expresses:**

- Both `quick` and `fox` must appear in the field
- `quick` must appear before `fox` (ordered)
- At most 3 positions may separate them

#### all_of Parameters

|Parameter|Type|Default|Purpose|
|---|---|---|---|
|`intervals`|array|_(required)_|List of sub-rules, all of which must match|
|`max_gaps`|integer|`-1`|Maximum positions between matched intervals|
|`ordered`|boolean|`false`|Whether sub-rules must match in listed order|
|`filter`|object|—|Interval filter to apply|

---

### Rule: any_of

Matches if **at least one** of the specified sub-rules matches. Equivalent to a positional OR.

```json
GET /articles/_search
{
  "query": {
    "intervals": {
      "content": {
        "any_of": {
          "intervals": [
            { "match": { "query": "elasticsearch" } },
            { "match": { "query": "opensearch" } }
          ]
        }
      }
    }
  }
}
```

#### any_of Parameters

|Parameter|Type|Default|Purpose|
|---|---|---|---|
|`intervals`|array|_(required)_|List of sub-rules; at least one must match|
|`filter`|object|—|Interval filter to apply|

---

### Interval Filters

Filters refine which intervals are considered valid. They are applied after intervals are produced by a rule.

```json
GET /articles/_search
{
  "query": {
    "intervals": {
      "content": {
        "match": {
          "query": "quick fox",
          "max_gaps": 5,
          "filter": {
            "not_containing": {
              "match": {
                "query": "brown"
              }
            }
          }
        }
      }
    }
  }
}
```

#### Available Filters

|Filter|Purpose|
|---|---|
|`containing`|Interval must contain a matching sub-interval|
|`not_containing`|Interval must not contain a matching sub-interval|
|`contained_by`|Interval must be contained within a matching sub-interval|
|`not_contained_by`|Interval must not be contained within a matching sub-interval|
|`overlapping`|Interval must overlap with a matching sub-interval|
|`not_overlapping`|Interval must not overlap with a matching sub-interval|
|`before`|Interval must appear before another matching interval|
|`after`|Interval must appear after another matching interval|
|`script`|Custom filter using a Painless script|

---

#### Filter: containing

Matches intervals that **contain** the specified sub-interval.

```json
{
  "match": {
    "query": "quick lazy fox",
    "max_gaps": 5,
    "filter": {
      "containing": {
        "match": {
          "query": "lazy"
        }
      }
    }
  }
}
```

Only intervals spanning `quick ... fox` that also contain `lazy` are returned.

---

#### Filter: not_containing

Matches intervals that do **not** contain the specified sub-interval.

```json
{
  "match": {
    "query": "quick fox",
    "max_gaps": 5,
    "filter": {
      "not_containing": {
        "match": {
          "query": "brown"
        }
      }
    }
  }
}
```

Matches `quick ... fox` spans that do not have `brown` between them.

---

#### Filter: before and after

```json
{
  "all_of": {
    "intervals": [
      {
        "match": {
          "query": "warning",
          "filter": {
            "before": {
              "match": { "query": "error" }
            }
          }
        }
      },
      {
        "match": { "query": "error" }
      }
    ]
  }
}
```

**Key Points:**

- `before` — the matched interval must start before the filter interval starts
- `after` — the matched interval must start after the filter interval ends
- [Inference] `before` and `after` filters operate on interval positions, not document-level field positions; behavior depends on how intervals are produced by the enclosing rule

---

#### Filter: script

Allows custom positional logic using a Painless script.

```json
{
  "match": {
    "query": "quick fox",
    "filter": {
      "script": {
        "source": "interval.start > 5 && interval.end < 20"
      }
    }
  }
}
```

Available script variables:

|Variable|Type|Description|
|---|---|---|
|`interval.start`|integer|Start position of the interval|
|`interval.end`|integer|End position of the interval|
|`interval.gaps`|integer|Number of gaps within the interval|
|`interval.internal_gaps`|integer|Internal gaps only|

**Key Points:**

- Script filters execute per interval candidate — not per document
- [Inference] Script filters may increase query latency proportional to the number of interval candidates evaluated; behavior depends on index content and rule complexity

---

### The `use_field` Parameter

Allows a rule to produce intervals from a **different field** than the one being queried. This is useful for multi-analyzer field setups.

```json
GET /articles/_search
{
  "query": {
    "intervals": {
      "content": {
        "match": {
          "query": "running quickly",
          "use_field": "content.stemmed"
        }
      }
    }
  }
}
```

**Key Points:**

- The query still targets `content` for document retrieval
- The intervals are derived from `content.stemmed`
- [Inference] Both fields must store position data for `use_field` to function correctly; behavior depends on both fields' index configurations

---

### Composing Complex Rules

Rules compose naturally by nesting `all_of` and `any_of`.

**Example: "warning" or "error" must appear within 5 words of "critical"**

```json
GET /logs/_search
{
  "query": {
    "intervals": {
      "message": {
        "all_of": {
          "intervals": [
            {
              "any_of": {
                "intervals": [
                  { "match": { "query": "warning" } },
                  { "match": { "query": "error" } }
                ]
              }
            },
            {
              "match": { "query": "critical" }
            }
          ],
          "max_gaps": 5,
          "ordered": false
        }
      }
    }
  }
}
```

---

### intervals vs match_phrase vs span_near

|Feature|`match_phrase`|`match_phrase_prefix`|`intervals`|
|---|---|---|---|
|Phrase matching|Yes|Yes|Yes|
|Slop / max_gaps|`slop`|`slop`|`max_gaps` per rule|
|Unordered matching|No|No|Yes (`ordered: false`)|
|Nested positional rules|No|No|Yes|
|Interval filters|No|No|Yes|
|Prefix/wildcard/fuzzy rules|No|Prefix only|Yes|
|Composable rule tree|No|No|Yes|
|Replaces `span_*` queries|No|No|Yes (recommended)|

**Key Points:**

- Elasticsearch documentation recommends `intervals` over `span_*` queries for new implementations
- `span_*` queries remain available but are considered lower-level and less ergonomic

---

### Scoring Behavior

By default, `intervals` uses a simple scoring model rather than BM25 term frequency scoring.

**Key Points:**

- Matching documents receive a score based on interval proximity and overlap
- [Inference] For relevance-ranked results combining intervals with BM25, wrapping the `intervals` query inside a `bool` query with other scoring clauses may produce more useful rankings; behavior depends on query composition
- Documents that do not satisfy the interval constraints receive a score of `0` and are excluded

---

### Common Use Cases

|Use Case|Rule Combination|
|---|---|
|Ordered phrase with gap allowance|`match` with `max_gaps`|
|Unordered proximity|`all_of` with `ordered: false` and `max_gaps`|
|Term A followed by Term B, not containing Term C|`all_of` + `filter: not_containing`|
|Phrase near one of several alternatives|`all_of` + `any_of`|
|Positional constraint from a different analyzer|`match` with `use_field`|
|Custom positional logic|`filter: script`|

---

### Common Mistakes

**Using `intervals` when `match_phrase` is sufficient:**

For straightforward phrase queries without complex positional constraints, `match_phrase` with `slop` is simpler and may perform better. `intervals` is appropriate when the positional logic exceeds what `slop` can express.

---

**Omitting `ordered` in `all_of` when order matters:**

`all_of` defaults to `ordered: false`. If term order is required, explicitly set `ordered: true`.

```json
"all_of": {
  "intervals": [...],
  "ordered": true
}
```

---

**Applying `intervals` to fields without position data:**

If `index_options` is set to `docs` or `freqs`, position data is absent and the query cannot function correctly.

---

### Summary of Rules and Parameters

#### match

|Parameter|Default|Purpose|
|---|---|---|
|`query`|_(required)_|Terms or phrase to match|
|`max_gaps`|`-1`|Maximum gaps between terms|
|`ordered`|`true`|Enforce term order|
|`analyzer`|Field default|Query-time analyzer|
|`filter`|—|Interval filter|
|`use_field`|—|Source field for intervals|

#### all_of

|Parameter|Default|Purpose|
|---|---|---|
|`intervals`|_(required)_|Sub-rules, all must match|
|`max_gaps`|`-1`|Maximum gaps between sub-intervals|
|`ordered`|`false`|Enforce sub-rule order|
|`filter`|—|Interval filter|

#### any_of

|Parameter|Default|Purpose|
|---|---|---|
|`intervals`|_(required)_|Sub-rules, at least one must match|
|`filter`|—|Interval filter|

#### prefix / wildcard / fuzzy

|Parameter|Default|Purpose|
|---|---|---|
|`prefix` / `pattern` / `term`|_(required)_|Match expression|
|`analyzer`|Field default|Analyzer applied|
|`use_field`|—|Source field for intervals|

---

**Conclusion:** The `intervals` query is the most expressive positional query available in Elasticsearch. By composing rules with `all_of`, `any_of`, and interval filters, it can express proximity constraints, ordering requirements, containment relationships, and exclusion conditions that are impossible to represent with `match_phrase` or `slop` alone. It is the recommended replacement for `span_*` queries in new implementations.

**Next Steps:**

- `simple_query_string` — fault-tolerant, user-facing query with simplified Lucene syntax
- `bool` query — compound query for combining full-text and filter clauses
- `span_near` / `span_*` queries — lower-level positional queries, largely superseded by `intervals`

===END_SYLLABOT_RESPONSE_067e8affb4bf48ad===
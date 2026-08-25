## Query DSL – Term Level Queries: Regexp Query

### Overview

The **regexp query** is a term-level query that matches documents containing terms conforming to a regular expression pattern. Like all term-level queries, it operates directly against the inverted index — the pattern is **not analyzed**, and matching happens against indexed terms as they were stored.

Elasticsearch uses its own regular expression engine, which is a subset of standard regex syntax. It is **not** compatible with PCRE (Perl-Compatible Regular Expressions) or Java's `java.util.regex` engine.

---

### Basic Syntax

```json
GET /index_name/_search
{
  "query": {
    "regexp": {
      "field_name": {
        "value": "regex_pattern"
      }
    }
  }
}
```

**Shorthand form:**

```json
GET /index_name/_search
{
  "query": {
    "regexp": {
      "field_name": "regex_pattern"
    }
  }
}
```

---

### Parameters

| Parameter | Required | Description |
|---|---|---|
| `value` | Yes | The regular expression pattern to match. |
| `flags` | No | Enables optional regex operators. Pipe-separated string (e.g., `"ALL"` or `"COMPLEMENT\|INTERSECTION"`). |
| `case_insensitive` | No | When `true`, matching ignores letter casing. Added in Elasticsearch 7.10. Defaults to `false`. |
| `max_determinized_states` | No | Upper limit on the number of automaton states generated during pattern compilation. Defaults to `10000`. Acts as a complexity safeguard. |
| `rewrite` | No | Controls internal query rewriting. Same options as `prefix` and `wildcard` queries. |
| `boost` | No | Floating-point score multiplier. Defaults to `1.0`. |

---

### Supported Regular Expression Syntax

Elasticsearch's regex engine is based on Lucene's automaton library. The following constructs are supported by default:

#### Core Operators

| Syntax | Description | Example | Matches |
|---|---|---|---|
| `.` | Any single character | `c.t` | `cat`, `cot`, `cut` |
| `*` | Zero or more of preceding | `ab*c` | `ac`, `abc`, `abbc` |
| `+` | One or more of preceding | `ab+c` | `abc`, `abbc` (not `ac`) |
| `?` | Zero or one of preceding | `colou?r` | `color`, `colour` |
| `{n}` | Exactly n repetitions | `a{3}` | `aaa` |
| `{n,m}` | Between n and m repetitions | `a{2,4}` | `aa`, `aaa`, `aaaa` |
| `[abc]` | Character class | `[abc]at` | `aat`, `bat`, `cat` |
| `[^abc]` | Negated character class | `[^abc]at` | `dat`, `eat`, `fat` |
| `[a-z]` | Character range | `[a-z]+` | any lowercase word |
| `(ab\|cd)` | Alternation (OR) | `(cat\|dog)` | `cat`, `dog` |
| `()` | Grouping | `(ab)+` | `ab`, `abab` |

#### Anchoring Behavior

Unlike many regex engines, Lucene's automaton **always matches the entire term**. There are no implicit `^` (start) or `$` (end) anchors — the pattern must account for the full term by default.

**Example:** The pattern `john` matches only the exact term `john`, not `john_doe` or `johnny`. To match terms containing `john` anywhere, use `.*john.*`.

```json
{
  "query": {
    "regexp": {
      "username": { "value": ".*john.*" }
    }
  }
}
```

This is a critical behavioral difference from most regex flavors and a common source of confusion.

---

### Optional Flags

Flags enable additional regex operators not available by default. Pass them as a pipe-separated string in the `flags` parameter.

| Flag | Enables | Syntax Example |
|---|---|---|
| `ALL` | All optional operators | — |
| `COMPLEMENT` | `~` negation operator | `~(foo)` — matches anything except `foo` |
| `INTERVAL` | `<n-m>` numeric range | `<1-99>` — matches numbers 1 through 99 |
| `INTERSECTION` | `&` intersection operator | `aaa.+&.+bbb` — matches terms satisfying both |
| `ANYSTRING` | `@` matches any string | `@` — matches every term |
| `NONE` | No optional operators (default) | — |

**Example using `COMPLEMENT` and `INTERVAL`:**

```json
GET /index_name/_search
{
  "query": {
    "regexp": {
      "code": {
        "value": "ITEM-<1-999>",
        "flags": "INTERVAL"
      }
    }
  }
}
```

This matches terms like `ITEM-1`, `ITEM-42`, `ITEM-999`.

---

### Practical Example

**Index mapping:**

```json
PUT /products
{
  "mappings": {
    "properties": {
      "sku":      { "type": "keyword" },
      "category": { "type": "keyword" }
    }
  }
}
```

**Sample documents:**

```json
{ "sku": "ELEC-001-A", "category": "electronics" }
{ "sku": "ELEC-002-B", "category": "electronics" }
{ "sku": "FURN-001-A", "category": "furniture" }
{ "sku": "ELEC-003-C", "category": "electronics" }
{ "sku": "APPL-001-A", "category": "appliances" }
```

---

#### Match SKUs Following a Specific Pattern

Find all SKUs in the `ELEC` group with a numeric code between `001` and `003` and any suffix letter:

```json
GET /products/_search
{
  "query": {
    "regexp": {
      "sku": {
        "value": "ELEC-00[1-3]-[A-Z]"
      }
    }
  }
}
```

**Output:**

```json
{
  "hits": {
    "total": { "value": 3 },
    "hits": [
      { "_source": { "sku": "ELEC-001-A" } },
      { "_source": { "sku": "ELEC-002-B" } },
      { "_source": { "sku": "ELEC-003-C" } }
    ]
  }
}
```

---

#### Match Categories Ending in `ics` or `ure`

```json
GET /products/_search
{
  "query": {
    "regexp": {
      "category": {
        "value": ".+(ics|ure)"
      }
    }
  }
}
```

**Output:**

```json
{
  "hits": {
    "total": { "value": 4 },
    "hits": [
      { "_source": { "category": "electronics" } },
      { "_source": { "category": "electronics" } },
      { "_source": { "category": "furniture" } },
      { "_source": { "category": "electronics" } }
    ]
  }
}
```

---

### Case-Insensitive Matching

```json
GET /products/_search
{
  "query": {
    "regexp": {
      "sku": {
        "value": "elec-[0-9]+-[a-z]",
        "case_insensitive": true
      }
    }
  }
}
```

**Key Points:**
- Without `case_insensitive: true`, the pattern must exactly match the case of indexed terms.
- [Inference] As with `wildcard`, case-insensitive regexp matching likely incurs additional query-time cost compared to a normalizer-based approach. Behavior is not guaranteed and may vary across versions.

---

### `max_determinized_states`

Lucene compiles regex patterns into a **deterministic finite automaton (DFA)**. Complex patterns — particularly those involving broad alternations, unbounded repetitions, or deeply nested groups — can produce extremely large automata during compilation.

The `max_determinized_states` parameter caps the number of states the compiled DFA is allowed to have. If a pattern exceeds this limit, Elasticsearch throws an error rather than executing a potentially unbounded operation.

```json
GET /products/_search
{
  "query": {
    "regexp": {
      "sku": {
        "value": "[A-Z]{2,6}-[0-9]{1,5}-[A-Z]",
        "max_determinized_states": 20000
      }
    }
  }
}
```

**Key Points:**
- The default limit is `10000` states.
- Raising this value allows more complex patterns but increases memory and CPU usage during pattern compilation.
- If a query consistently hits this limit, the pattern complexity should be reconsidered rather than simply raising the cap.
- [Inference] Very high values for `max_determinized_states` on complex patterns may cause significant memory pressure on the coordinating node. This is not guaranteed and depends on cluster configuration.

---

### Performance Considerations

Regexp queries share many of the same performance characteristics as wildcard queries, with some additional factors due to pattern complexity.

#### Patterns Without a Literal Prefix

When a pattern begins with `.*`, `[a-z]`, or any non-literal construct, Elasticsearch must evaluate every term in the inverted index for the field — similar to a leading wildcard.

```json
{ "value": ".*error.*" }   ← full index scan on the field
{ "value": "err.*" }       ← faster; can anchor to terms starting with "err"
```

[Inference] Anchoring the pattern with a literal prefix is likely to improve performance significantly on high-cardinality fields, as it narrows the candidate term set before applying the automaton. Behavior may vary based on data distribution and shard configuration.

#### Pattern Compilation Cost

Each unique regexp pattern must be compiled into an automaton at query time. Highly complex patterns take longer to compile and may require more memory.

#### `wildcard` Field Type Compatibility

The `wildcard` field type (introduced in 7.9) also accelerates `regexp` queries, similarly to how it helps `wildcard` queries. For use cases with frequent arbitrary-pattern matching, this field type is worth evaluating.

---

### Unsupported Syntax

The following constructs from common regex flavors are **not supported** by Lucene's engine:

| Unsupported | Notes |
|---|---|
| `^` and `$` anchors | Unnecessary — patterns always match full terms |
| Lookahead / lookbehind | Not available |
| Backreferences (`\1`) | Not available |
| Named groups (`(?P<name>...)`) | Not available |
| Non-greedy quantifiers (`*?`, `+?`) | Not available |
| `\d`, `\w`, `\s` shorthand classes | Not available; use `[0-9]`, `[a-zA-Z0-9_]`, etc. |

Attempting to use unsupported syntax will result in a parse error or unexpected matching behavior.

---

### Comparison: `regexp` vs. Related Queries

| Query | Pattern Support | Analysis | Leading Pattern Cost |
|---|---|---|---|
| `regexp` | Full Lucene regex syntax | No | High unless anchored with literal prefix |
| `wildcard` | `*` and `?` only | No | High on `keyword`; lower on `wildcard` field type |
| `prefix` | Start-anchored literal prefix | No | N/A |
| `fuzzy` | Edit-distance variation | No | N/A |
| `match` | Full-text token matching | Yes | N/A |

---

### Common Pitfalls

- **Forgetting full-term matching** — patterns must account for the entire term. `john` does not match `john_doe`; use `john.*` or `.*john.*` as appropriate.
- **Using unsupported shorthand classes** — `\d` and `\w` are not valid; use explicit character classes like `[0-9]` and `[a-zA-Z0-9_]`.
- **Unanchored patterns on high-cardinality fields** — patterns starting with `.*` or a character class force a full field term scan.
- **Exceeding `max_determinized_states`** — overly complex patterns will throw an error. Simplify the pattern or raise the limit cautiously.
- **Case mismatch on `keyword` fields** — without `case_insensitive: true` or a normalizer, the pattern must match the exact case of indexed terms.
- **Assuming PCRE or Java regex compatibility** — Lucene's engine is a distinct implementation with a different feature set.

---

### Summary

The regexp query offers the most expressive pattern-matching capability among term-level queries in Elasticsearch, at the cost of being the most resource-intensive. It is best suited for structured fields — typically `keyword` — where the pattern can be anchored with a literal prefix to limit term enumeration. For use cases requiring frequent arbitrary pattern matching, the `wildcard` field type can reduce query-time costs. Understanding Lucene's full-term matching behavior and the boundaries of its regex syntax are essential for writing correct and performant regexp queries.
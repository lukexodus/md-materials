## Explain API

### Overview

The Explain API is a diagnostic tool in Elasticsearch that returns a detailed breakdown of how a relevance score was computed for a specific document against a specific query. Rather than showing you a final score, it exposes every intermediate calculation—IDF values, term frequencies, normalization factors, and their combinations—so you can understand precisely why a document received the score it did.

This API is primarily a debugging and development tool. It helps you answer questions like:

- Why does document A rank higher than document B?
- Why is a document I expect to match not appearing in results?
- Are my custom similarity settings having the intended effect?
- Is a field boost working correctly?

### Basic Syntax

The Explain API operates on a single document at a time and requires both a document ID and a query:

```
GET /<index>/_explain/<document_id>
{
  "query": { ... }
}
```

**Key Points**:
- The document ID must be the exact `_id` of the target document
- The query is provided in the same format as a standard `_search` query
- The API returns an explanation regardless of whether the document matches—it will tell you if a document does not match and why

### Explain on a Single Document

#### Basic Match Query

```json
GET /articles/_explain/doc-001
{
  "query": {
    "match": {
      "title": "Elasticsearch cluster"
    }
  }
}
```

**Output** (abbreviated):

```json
{
  "_index": "articles",
  "_id": "doc-001",
  "matched": true,
  "explanation": {
    "value": 7.218,
    "description": "sum of:",
    "details": [
      {
        "value": 4.231,
        "description": "weight(title:elasticsearch in 0) [PerFieldSimilarity], result of:",
        "details": [
          {
            "value": 3.112,
            "description": "idf, computed as log(1 + (N - n + 0.5) / (n + 0.5)) from:",
            "details": [
              { "value": 5000, "description": "N, total number of documents with field" },
              { "value": 120, "description": "n, number of documents containing term" }
            ]
          },
          {
            "value": 1.360,
            "description": "tfNorm, computed as (freq * (k1 + 1)) / (freq + k1 * (1 - b + b * dl / avgdl)) from:",
            "details": [
              { "value": 2.0, "description": "freq, occurrences of term within document" },
              { "value": 1.2, "description": "k1, term saturation parameter" },
              { "value": 0.75, "description": "b, length normalization parameter" },
              { "value": 80, "description": "dl, length of field" },
              { "value": 110, "description": "avgdl, average length of field" }
            ]
          }
        ]
      },
      {
        "value": 2.987,
        "description": "weight(title:cluster in 0) [PerFieldSimilarity], result of:",
        "details": [ "..." ]
      }
    ]
  }
}
```

**Key Points**:
- `matched: true` confirms the document matches the query
- `value` at the top level is the final computed score
- `description` at each level describes what operation produced that value
- `details` is a recursive structure—each node may contain child nodes breaking down its own computation further
- Each query term is explained independently, then summed

### Response Structure

Understanding the response structure is essential for reading explanations effectively.

#### Top-Level Fields

| Field | Description |
|-------|-------------|
| `_index` | Index the document belongs to |
| `_id` | Document ID |
| `matched` | Whether the document matches the query |
| `explanation` | Root node of the scoring tree |

#### Explanation Node Fields

| Field | Description |
|-------|-------------|
| `value` | The numeric score contribution of this node |
| `description` | Human-readable description of the computation |
| `details` | Child nodes that were combined to produce `value` |

The explanation is a recursive tree. Each node's `value` is derived from its children's `value` fields through operations described in `description` (e.g., "sum of:", "product of:", "max of:").

### Non-Matching Documents

One of the most valuable uses of the Explain API is diagnosing why a document does not match a query you expect it to match:

```json
GET /articles/_explain/doc-042
{
  "query": {
    "match": {
      "title": "sharding strategy"
    }
  }
}
```

**Output** when the document does not match:

```json
{
  "_index": "articles",
  "_id": "doc-042",
  "matched": false,
  "explanation": {
    "value": 0.0,
    "description": "no matching term",
    "details": [
      {
        "value": 0.0,
        "description": "title:sharding is not found in the index"
      },
      {
        "value": 0.0,
        "description": "title:strategy is not found in the index"
      }
    ]
  }
}
```

This tells you immediately that the terms were not found—which could mean the document doesn't contain them, the analyzer tokenized them differently, or the field mapping is not `text` type.

### Using Explain During Search

Instead of querying a single document, you can request explanations for all results in a `_search` call using the `explain` parameter:

```
GET /articles/_search?explain=true
{
  "query": {
    "match": {
      "body": "distributed search"
    }
  }
}
```

**Output** includes an `_explanation` object on each hit:

```json
{
  "hits": {
    "hits": [
      {
        "_id": "doc-001",
        "_score": 9.341,
        "_explanation": {
          "value": 9.341,
          "description": "sum of:",
          "details": [ "..." ]
        }
      },
      {
        "_id": "doc-002",
        "_score": 6.112,
        "_explanation": {
          "value": 6.112,
          "description": "sum of:",
          "details": [ "..." ]
        }
      }
    ]
  }
}
```

**Key Points**:
- `explain=true` on `_search` returns explanations for every document in the result set, not just one
- This increases response size significantly and adds computational overhead
- Use this mode only during development and debugging—not in production queries

### Explain with Complex Queries

The Explain API handles compound and complex queries, decomposing each clause into its own explanation subtree.

#### Boolean Query

```json
GET /articles/_explain/doc-001
{
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "Elasticsearch" } }
      ],
      "should": [
        { "match": { "body": "cluster" } },
        { "match": { "tags": "distributed" } }
      ],
      "filter": [
        { "term": { "status": "published" } }
      ]
    }
  }
}
```

**Output** structure (abbreviated):

```json
{
  "matched": true,
  "explanation": {
    "value": 11.432,
    "description": "sum of:",
    "details": [
      {
        "value": 5.218,
        "description": "weight(title:elasticsearch in 0) [PerFieldSimilarity]",
        "details": [ "..." ]
      },
      {
        "value": 3.891,
        "description": "weight(body:cluster in 0) [PerFieldSimilarity]",
        "details": [ "..." ]
      },
      {
        "value": 2.323,
        "description": "weight(tags:distributed in 0) [PerFieldSimilarity]",
        "details": [ "..." ]
      },
      {
        "value": 0.0,
        "description": "match on required clause, product of:",
        "details": [
          {
            "value": 0.0,
            "description": "# clause, product of:",
            "details": [
              { "value": 0.0, "description": "boost" },
              { "value": 1.0, "description": "status:published" }
            ]
          }
        ]
      }
    ]
  }
}
```

**Key Points**:
- `must` clauses contribute to the score and appear in the explanation with their computed weight
- `filter` clauses appear in the explanation with a value of `0.0`—they affect matching but not scoring
- `should` clauses contribute to the score when matched but don't affect matching eligibility in the presence of `must`
- Each clause is a separate subtree in the explanation

#### Multi-Match Query with Boosting

```json
GET /articles/_explain/doc-001
{
  "query": {
    "multi_match": {
      "query": "cluster management",
      "fields": ["title^3", "body", "tags^2"]
    }
  }
}
```

The explanation will show separate scoring contributions for each field, with boosted fields having their scores multiplied by the boost factor. This lets you verify that your boost values are having the intended relative effect.

### Explain with Filters and Constant Scores

#### Filter-Only Query

```json
GET /articles/_explain/doc-001
{
  "query": {
    "term": {
      "status": "published"
    }
  }
}
```

**Output**:

```json
{
  "matched": true,
  "explanation": {
    "value": 1.0,
    "description": "status:published",
    "details": []
  }
}
```

Term queries used outside a filter context return a score of `1.0` when matched, which confirms a match without producing a meaningful relevance score. The explanation reflects this with no child details.

#### Constant Score Query

```json
GET /articles/_explain/doc-001
{
  "query": {
    "constant_score": {
      "filter": {
        "term": { "category": "infrastructure" }
      },
      "boost": 4.5
    }
  }
}
```

**Output**:

```json
{
  "matched": true,
  "explanation": {
    "value": 4.5,
    "description": "ConstantScore(category:infrastructure), product of:",
    "details": [
      { "value": 1.0, "description": "match filter: category:infrastructure" },
      { "value": 4.5, "description": "boost" }
    ]
  }
}
```

This confirms the constant score is applied correctly and the filter matched the document.

### Reading Explanation Descriptions

The `description` field uses a consistent set of phrases to describe operations. Recognizing these helps you navigate explanations efficiently:

| Description Pattern | Meaning |
|--------------------|---------|
| `sum of:` | Child values are added together |
| `product of:` | Child values are multiplied together |
| `max of:` | Highest child value is used |
| `weight(<field>:<term> in <docId>)` | BM25 score for a single term in a field |
| `idf, computed as ...` | IDF component of BM25 |
| `tfNorm, computed as ...` | Normalized TF component of BM25 |
| `PerFieldSimilarity` | Field-specific similarity model was applied |
| `boost` | A boost factor was multiplied in |
| `match on required clause` | A `must` or `filter` clause matched |
| `<term> is not found in the index` | Term didn't exist in the inverted index |

### Common Diagnostic Patterns

#### Investigating Unexpectedly Low Scores

When a document scores lower than expected:

1. Run the Explain API on the document
2. Check IDF values—if they are very low, the term may be too common in your corpus
3. Check `dl` vs `avgdl`—if `dl` is much larger than `avgdl`, the document is being penalized for length
4. Verify `freq` (term frequency)—if it's lower than expected, check your analyzer configuration

#### Investigating Non-Matching Documents

When a document should match but doesn't:

```json
GET /articles/_explain/doc-099
{
  "query": {
    "match": {
      "title": "indexing"
    }
  }
}
```

If `matched: false`, check the explanation description:
- `"<term> is not found in the index"` → The term doesn't exist at all in the index; check field content and analyzer
- `"no matching term"` → Query terms are not present in the field after analysis
- Filter-related descriptions → A filter clause is excluding the document

#### Verifying Analyzer Behavior

[Inference] A frequent cause of non-matching documents is an analyzer mismatch between index time and query time. For example, if the index analyzer stems "running" to "run" but the query analyzer does not, the terms won't align. The Explain API will show the term as not found. In these cases, the Analyze API (`_analyze`) is a complementary tool for verifying how text is tokenized.

#### Comparing Two Documents

To understand why document A ranks above document B, run separate Explain API calls for each against the same query, then compare:

- IDF values should be identical (same corpus statistics for the same terms)
- Differences in `freq` (term frequency) reflect how often each document uses the term
- Differences in `dl` vs `avgdl` reflect length normalization impact
- The combination of these determines the final ranking

### Explain API vs. Profile API

The Explain API and Profile API are both diagnostic tools but serve different purposes:

| Feature | Explain API | Profile API |
|---------|-------------|-------------|
| Purpose | Score breakdown for a document | Query execution performance |
| Scope | Single document | Entire query execution |
| Output | Mathematical score tree | Timing, shard-level stats |
| Use case | Relevance debugging | Performance optimization |
| Overhead | Low (single doc) | High (full query profiling) |

Use the Explain API when the question is about relevance—why does a document score the way it does. Use the Profile API when the question is about performance—why does a query take as long as it does.

### Limitations and Considerations

- **Single document scope**: Each Explain API call targets one document. Comparing many documents requires multiple calls, which can be slow and cumbersome at scale
- **Shard-local IDF**: By default, IDF values in the explanation reflect shard-local statistics, not global index statistics. [Inference] If your index has multiple shards and uneven data distribution, the IDF values shown may differ from those you'd calculate manually from global document counts
- **Explanation verbosity**: For complex nested queries, the explanation tree can be extremely deep and difficult to read manually. Consider processing it programmatically for complex scenarios
- **Not a search result**: The Explain API does not filter or rank documents—it only computes the score for the single specified document against the provided query. A high score from Explain does not mean the document would appear in the top results of an actual search if other documents score higher
- **Performance overhead**: Using `explain=true` on `_search` adds significant overhead. Behavior may vary depending on query complexity, index size, and shard count. Restrict its use to debugging sessions

### Best Practices

- **Use on specific suspect documents**: Target documents where score behavior is unexpected rather than running explain on all results
- **Always include the full query**: The query context must exactly match what you use in production, including boosts, filters, and analyzers, to get a meaningful explanation
- **Cross-reference with the Analyze API**: When the Explain API shows terms as not found, use `_analyze` to inspect how your text is tokenized and identify analyzer mismatches
- **Compare dl to avgdl**: Length normalization is a frequent cause of counterintuitive scores; always check these values when scores seem off
- **Do not use explain=true in production search**: The additional computation and response size affect performance and should be isolated to debugging workflows
- **Automate explanation parsing**: For systematic relevance tuning, consider scripting Explain API calls and extracting specific values (IDF, tfNorm) programmatically rather than reading raw JSON
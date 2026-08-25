## BM25 Scoring Model

### Overview

BM25 (Best Matching 25) is the default similarity algorithm used by Elasticsearch for full-text relevance scoring. It is a probabilistic ranking function that builds upon and addresses the limitations of classical TF-IDF. The "25" in its name refers to the 25th iteration in a series of experiments conducted during its development by researchers Stephen Robertson and Karen Spärck Jones in the 1990s.

BM25 is not a single formula but a family of related ranking functions. The variant used in practice—and in Elasticsearch—is BM25F, or BM25 with field-level term frequency normalization. It remains one of the most widely adopted relevance models in information retrieval due to its balance of simplicity, interpretability, and effectiveness.

### Why BM25 Replaced Classic TF-IDF

Classical TF-IDF has two well-known weaknesses:

**Term frequency unboundedness**: In classic TF-IDF, a document mentioning a term 100 times scores proportionally higher than one mentioning it 10 times. This behavior is rarely desirable—a document is not 10 times more relevant simply because a term repeats more.

**No field length normalization**: Classic TF-IDF does not account for document length. Longer documents naturally contain more terms, giving them a structural scoring advantage regardless of actual relevance.

BM25 addresses both problems through its formulation, making it a more robust and predictable relevance model.

### The BM25 Formula

The core BM25 scoring formula for a single term `t` in a document `d` is:

```
Score(t, d) = IDF(t) × [ TF(t,d) × (k1 + 1) ] / [ TF(t,d) + k1 × (1 - b + b × (|d| / avgdl)) ]
```

Where:
- `TF(t, d)` — raw term frequency of term `t` in document `d`
- `IDF(t)` — inverse document frequency of term `t`
- `|d|` — length of document `d` (number of tokens)
- `avgdl` — average document length across all documents in the index
- `k1` — term frequency saturation parameter (default: 1.2)
- `b` — field length normalization parameter (default: 0.75)

For a multi-term query, scores for each term are summed:

```
Score(query, d) = Σ Score(t_i, d)   for each term t_i in the query
```

### IDF in BM25

BM25 uses a slightly different IDF formula than classical TF-IDF, designed to avoid negative values and to handle edge cases more gracefully:

```
IDF(t) = log(1 + (N - n(t) + 0.5) / (n(t) + 0.5))
```

Where:
- `N` — total number of documents in the index
- `n(t)` — number of documents containing term `t`
- `0.5` — smoothing constant to prevent division by zero and reduce instability when `n(t)` is very small

**Example**: In a 10,000-document index:
- "the" appears in 9,800 documents: IDF = log(1 + (10,000 - 9,800 + 0.5) / (9,800 + 0.5)) ≈ 0.021
- "shard" appears in 200 documents: IDF = log(1 + (10,000 - 200 + 0.5) / (200 + 0.5)) ≈ 3.89
- "rebalancing" appears in 5 documents: IDF = log(1 + (10,000 - 5 + 0.5) / (5 + 0.5)) ≈ 7.50

Rare terms receive dramatically higher IDF weights, reinforcing their discriminative power.

### Term Frequency Saturation

The most distinctive feature of BM25 over TF-IDF is its term frequency saturation. Instead of allowing TF to grow linearly and unboundedly, BM25 applies a ceiling effect:

```
TF_saturated = TF(t,d) / (TF(t,d) + k1 × normalization_factor)
```

As TF increases, the marginal contribution to the score decreases. This is visualized conceptually as:

```
Score contribution
  |         ___________
  |       /
  |      /
  |    /
  |  /
  |/
  +-------------------→ Term Frequency (TF)
```

The curve flattens as TF grows. The rate of flattening is controlled by the `k1` parameter.

#### Effect of k1

| `k1` Value | Behavior |
|------------|----------|
| 0.0 | TF has no effect; only IDF matters |
| 1.2 (default) | Moderate saturation; typical for short fields |
| 2.0 | Slower saturation; TF matters more |
| 3.0+ | Approaches linear TF scaling; similar to classic TF-IDF |

**Key Point**: Lower `k1` suits fields where repetition is less meaningful (titles, tags). Higher `k1` suits fields where repetition matters more (long-form content, technical documents).

### Field Length Normalization

BM25 normalizes term frequency by comparing the document's length to the average document length in the index. The normalization is embedded in the denominator:

```
normalization_factor = (1 - b + b × (|d| / avgdl))
```

- When `|d| = avgdl`: normalization factor = 1 (no adjustment)
- When `|d| > avgdl`: normalization factor > 1 (penalizes longer documents)
- When `|d| < avgdl`: normalization factor < 1 (rewards shorter documents)

#### Effect of b

| `b` Value | Behavior |
|-----------|----------|
| 0.0 | No length normalization; document length ignored |
| 0.75 (default) | Moderate normalization |
| 1.0 | Full normalization; document length fully factored in |

**Key Point**: For fields where document length is meaningful (blog posts, articles), a higher `b` value may improve relevance. For fields where length carries no meaning (product codes, identifiers), setting `b = 0` avoids penalizing longer values unnecessarily.

### Worked Example

Consider two documents indexed in Elasticsearch with a search query for "cluster":

**Corpus statistics:**
- Total documents (N): 1,000
- Documents containing "cluster" (n): 50
- Average field length (avgdl): 100 tokens

**BM25 IDF for "cluster":**
```
IDF = log(1 + (1,000 - 50 + 0.5) / (50 + 0.5))
    = log(1 + 950.5 / 50.5)
    = log(1 + 18.82)
    = log(19.82)
    ≈ 2.986
```

**Document A:** 150 tokens, "cluster" appears 3 times
```
TF = 3
normalization = 1 - 0.75 + 0.75 × (150 / 100) = 0.25 + 1.125 = 1.375
TF_bm25 = 3 × (1.2 + 1) / (3 + 1.2 × 1.375) = 6.6 / (3 + 1.65) = 6.6 / 4.65 ≈ 1.419
Score_A = 2.986 × 1.419 ≈ 4.237
```

**Document B:** 50 tokens, "cluster" appears 2 times
```
TF = 2
normalization = 1 - 0.75 + 0.75 × (50 / 100) = 0.25 + 0.375 = 0.625
TF_bm25 = 2 × (1.2 + 1) / (2 + 1.2 × 0.625) = 4.4 / (2 + 0.75) = 4.4 / 2.75 ≈ 1.6
Score_B = 2.986 × 1.6 ≈ 4.778
```

**Output**: Document B ranks higher despite having fewer occurrences of "cluster", because it is significantly shorter relative to the average. The normalization rewards its density of relevant content.

### Configuring BM25 in Elasticsearch

#### Default Configuration

Elasticsearch applies BM25 with default parameters automatically. No explicit configuration is needed unless you want to customize behavior.

#### Custom Similarity Settings

You configure BM25 parameters at index creation time through index settings:

```json
PUT /my-index
{
  "settings": {
    "index": {
      "similarity": {
        "custom_bm25": {
          "type": "BM25",
          "k1": 1.5,
          "b": 0.5,
          "discount_overlaps": true
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "similarity": "default"
      },
      "body": {
        "type": "text",
        "similarity": "custom_bm25"
      }
    }
  }
}
```

**Key Points**:
- `discount_overlaps` (default: `true`): Ignores token position overlaps (e.g., from synonym filters) when computing field length, preventing artificial length inflation
- You can define multiple named similarity configurations and assign them to different fields
- Similarity settings cannot be changed on an existing index without reindexing

#### Changing the Default Similarity

To apply a custom BM25 globally as the default for all fields:

```json
PUT /my-index
{
  "settings": {
    "index": {
      "similarity": {
        "default": {
          "type": "BM25",
          "k1": 2.0,
          "b": 0.6
        }
      }
    }
  }
}
```

Any field without an explicit `similarity` mapping will use this configuration.

### Shard-Level Scoring and IDF Accuracy

#### How Shard Statistics Affect IDF

By default, Elasticsearch calculates IDF per shard. Each shard maintains its own document frequency statistics independently. This means IDF values—and therefore scores—can differ across shards if data is distributed unevenly.

[Inference] In practice, this is most noticeable during development or with small datasets where a few documents per shard can cause significant statistical skew. In large production indices with many documents per shard, score differences due to shard-level IDF tend to be small and rarely impact perceived relevance.

#### Using DFS to Improve Score Consistency

To force global IDF calculation across all shards before scoring, use the `dfs_query_then_fetch` search type:

```
GET /my-index/_search?search_type=dfs_query_then_fetch
{
  "query": {
    "match": {
      "title": "distributed cluster"
    }
  }
}
```

This adds an initial round-trip to gather global term frequencies before executing the actual search. It improves scoring consistency at the cost of additional network overhead.

**Key Point**: `dfs_query_then_fetch` is rarely necessary in production with large, well-distributed indices. It is most useful during testing, with small datasets, or when score consistency is critical to user experience.

### Debugging BM25 Scores

#### The Explain API

Elasticsearch exposes the full scoring breakdown through the explain API:

```json
GET /my-index/_explain/doc-id
{
  "query": {
    "match": {
      "body": "cluster rebalancing"
    }
  }
}
```

**Output** (abbreviated):

```json
{
  "_explanation": {
    "value": 9.234,
    "description": "sum of:",
    "details": [
      {
        "value": 5.432,
        "description": "weight(body:cluster in 0) [PerFieldSimilarity]",
        "details": [
          {
            "value": 2.986,
            "description": "idf, computed as log(1 + (N - n + 0.5) / (n + 0.5)) from:",
            "details": [
              { "value": 1000, "description": "N, total number of documents with field" },
              { "value": 50, "description": "n, number of documents containing term" }
            ]
          },
          {
            "value": 1.819,
            "description": "tfNorm, computed as (freq * (k1 + 1)) / (freq + k1 * (1 - b + b * dl / avgdl)) from:",
            "details": [
              { "value": 3.0, "description": "freq, occurrences of term within document" },
              { "value": 1.2, "description": "k1, term saturation parameter" },
              { "value": 0.75, "description": "b, length normalization parameter" },
              { "value": 150, "description": "dl, length of field" },
              { "value": 100, "description": "avgdl, average length of field" }
            ]
          }
        ]
      }
    ]
  }
}
```

This decomposition maps directly to the BM25 formula components. Reviewing this output is the most reliable way to diagnose unexpected scores.

### Comparing BM25 to Other Similarity Models

Elasticsearch supports alternative similarity models, each with different scoring characteristics:

| Model | Type | Best For |
|-------|------|----------|
| BM25 (default) | Probabilistic | General full-text search |
| Classic TF-IDF | Vector space | Legacy; educational reference |
| DFR | Divergence from Randomness | Experimental; specialized domains |
| IB | Information-Based | Experimental; research contexts |
| LM Dirichlet | Language Model | Short queries, long documents |
| Scripted | Custom | Arbitrary custom logic |
| Dense Vector | Approximate NN | Semantic/vector search |

[Inference] BM25 outperforms classic TF-IDF in most real-world search scenarios due to its saturation and normalization properties. The alternative probabilistic models (DFR, IB, LM Dirichlet) may offer marginal improvements in specific domains but require significant tuning and benchmarking effort to justify over BM25 defaults.

### Limitations of BM25

- **No semantic understanding**: BM25 scores based on exact term matches. Synonyms, paraphrases, and conceptual similarity are not captured without additional tooling (e.g., synonym filters or vector search)
- **Corpus dependency**: Scores depend on the statistics of the entire index. Adding or removing large numbers of documents shifts IDF values, changing scores for existing queries
- **No positional awareness**: BM25 does not consider where in a document terms appear or how close terms are to each other. A phrase query may rank differently than a BM25-based match query for related reasons
- **Parameter sensitivity**: Default `k1` and `b` values work well for general English text but may need tuning for specialized domains, short fields, or non-English languages

### Tuning Recommendations

| Scenario | Recommended Adjustment |
|----------|------------------------|
| Short title/tag fields | Lower `b` (0.3–0.5); lower `k1` (0.8–1.0) |
| Long document bodies | Default or higher `b` (0.75–1.0) |
| High-repetition domains | Higher `k1` (1.5–2.0) |
| Keyword/identifier fields | `b = 0`; consider `keyword` type instead |
| Small test indices | Use `dfs_query_then_fetch` for consistent scoring |
| Score inconsistency across shards | Use `dfs_query_then_fetch` or reindex with a single shard for testing |

Behavior may vary depending on your data distribution, index configuration, and Elasticsearch version. Always benchmark tuning changes against a representative query set before applying them to production.
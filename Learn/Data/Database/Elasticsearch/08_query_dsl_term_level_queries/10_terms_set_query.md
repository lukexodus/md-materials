## Query DSL – Term Level Queries: `terms_set` Query

### Overview

The `terms_set` query is a term-level query that matches documents where a specified field contains **a minimum number of exact terms** from a provided list. Unlike the standard `terms` query — which matches if *any* of the listed terms are present — `terms_set` lets you define a threshold: how many of the provided terms must match before a document qualifies.

This makes it especially useful for scenarios like skill matching, tag filtering, or requirement checking, where partial matches need a configurable minimum.

---

### How It Works

You provide:
1. A list of terms to look for in a field.
2. A **minimum match threshold** — either a fixed number or a value derived from another field in the document itself.

The query then returns only documents where the number of matching terms meets or exceeds that threshold.

---

### Minimum Match Configuration

There are two ways to set the minimum number of required matching terms:

#### Using a Static Field (`minimum_should_match_field`)

Points to a numeric field in the document that holds the minimum match count. This allows the threshold to vary per document.

#### Using a Script (`minimum_should_match_script`)

Computes the minimum match count dynamically using a Painless script. This gives you fine-grained control, such as capping the minimum at a certain value or deriving it from document metadata.

---

### Basic Syntax

```json
GET /index/_search
{
  "query": {
    "terms_set": {
      "<field_name>": {
        "terms": ["term1", "term2", "term3"],
        "minimum_should_match_field": "<numeric_field>",
        "boost": 1.0
      }
    }
  }
}
```

---

### Example: Skill Matching with a Document-Based Threshold

**Scenario:** A job postings index where each document lists required skills and specifies how many of those skills a candidate must have.

**Index mapping:**

```json
PUT /job_postings
{
  "mappings": {
    "properties": {
      "title": { "type": "text" },
      "required_skills": { "type": "keyword" },
      "min_skills_required": { "type": "integer" }
    }
  }
}
```

**Sample documents:**

```json
POST /job_postings/_bulk
{ "index": { "_id": "1" } }
{ "title": "Backend Developer", "required_skills": ["java", "spring", "sql", "docker"], "min_skills_required": 3 }
{ "index": { "_id": "2" } }
{ "title": "DevOps Engineer", "required_skills": ["docker", "kubernetes", "terraform"], "min_skills_required": 2 }
{ "index": { "_id": "3" } }
{ "title": "Data Engineer", "required_skills": ["python", "spark", "sql", "airflow"], "min_skills_required": 4 }
```

**Query:** Find jobs where a candidate with `java`, `docker`, and `sql` skills qualifies:

```json
GET /job_postings/_search
{
  "query": {
    "terms_set": {
      "required_skills": {
        "terms": ["java", "docker", "sql"],
        "minimum_should_match_field": "min_skills_required"
      }
    }
  }
}
```

**Output:**

| Doc | Title | Skills Matched | Min Required | Qualifies? |
|-----|-------|---------------|--------------|------------|
| 1 | Backend Developer | java, docker, sql (3) | 3 | ✅ Yes |
| 2 | DevOps Engineer | docker (1) | 2 | ❌ No |
| 3 | Data Engineer | sql (1) | 4 | ❌ No |

Only document 1 is returned, because it is the only job where the candidate's matching skills meet or exceed that job's `min_skills_required`.

---

### Example: Using a Script for Dynamic Thresholds

**Scenario:** Match at least half of the provided terms, regardless of what value is stored in the document.

```json
GET /job_postings/_search
{
  "query": {
    "terms_set": {
      "required_skills": {
        "terms": ["java", "docker", "sql", "kubernetes"],
        "minimum_should_match_script": {
          "source": "Math.ceil(params.num_terms / 2.0)"
        }
      }
    }
  }
}
```

Here, `params.num_terms` is a built-in parameter automatically injected by Elasticsearch, representing the total number of terms in the `terms` list. With 4 terms provided, the script evaluates to `Math.ceil(4 / 2.0) = 2`, so documents matching at least 2 of the 4 terms qualify.

> [Inference] `params.num_terms` is described in Elasticsearch documentation as an automatically available parameter in `minimum_should_match_script` context. Behavior may vary across versions.

---

### Available Script Parameters

| Parameter | Description |
|-----------|-------------|
| `params.num_terms` | Total count of terms provided in the `terms` array |
| `params.<field>` | Any custom parameter passed via `params` block |

**Example with a custom parameter:**

```json
"minimum_should_match_script": {
  "source": "Math.min(params.num_terms, params.cap)",
  "params": {
    "cap": 3
  }
}
```

This caps the minimum match at 3, regardless of how many terms are in the list.

---

### Important Behaviors and Constraints

- The target field (e.g., `required_skills`) should be mapped as `keyword` or another field type that supports exact term matching. Using `text` fields may produce unexpected results due to analysis.
- `minimum_should_match_field` must reference a **numeric** field present in the document. If the field is missing from a document, that document [Inference] may not match, though behavior may vary depending on Elasticsearch version.
- `minimum_should_match_script` and `minimum_should_match_field` are **mutually exclusive** — only one should be specified per query.
- The `terms_set` query is a **filter-context-compatible** query, meaning it can be used inside `filter` clauses without affecting relevance scoring.
- Term matching is **exact and case-sensitive** (consistent with other term-level queries). No analysis is applied.

---

### Using `terms_set` Inside a Boolean Query

```json
GET /job_postings/_search
{
  "query": {
    "bool": {
      "filter": [
        {
          "terms_set": {
            "required_skills": {
              "terms": ["python", "sql", "spark"],
              "minimum_should_match_script": {
                "source": "2"
              }
            }
          }
        }
      ]
    }
  }
}
```

Placing `terms_set` in a `filter` clause avoids relevance score calculation, which [Inference] may improve performance in large indices. Actual performance impact may vary.

---

### Comparison: `terms` vs `terms_set`

| Feature | `terms` | `terms_set` |
|--------|---------|-------------|
| Minimum match control | No (any match qualifies) | Yes (configurable threshold) |
| Per-document threshold | No | Yes (via field or script) |
| Dynamic threshold via script | No | Yes |
| Exact term matching | Yes | Yes |
| Analysis applied | No | No |
| Use case | Simple inclusion check | Partial requirement matching |

---

### Common Use Cases

- **Job/candidate matching** — require a minimum number of shared skills
- **Tag-based filtering** — documents must contain at least N relevant tags
- **Access control** — documents requiring a minimum set of permissions
- **Product filtering** — items must satisfy a minimum number of attribute criteria
- **Survey/quiz scoring** — match responses against a required answer set

---

**Conclusion**

The `terms_set` query extends the flexibility of term-level matching by introducing a configurable minimum match threshold. It is particularly powerful in domains where partial qualification is meaningful — such as talent matching, product filtering, or permission checking. By supporting both document-field-based and script-based thresholds, it handles both static and dynamic matching requirements within a single query type.
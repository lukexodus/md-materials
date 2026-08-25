## stats and extended_stats

### Overview

`stats` and `extended_stats` are multi-value metric aggregations that compute several statistical measures in a **single aggregation pass**. They are more efficient than requesting equivalent single-value aggregations individually, and they form the basis for understanding value distributions within a bucket.

---

### stats Aggregation

The `stats` aggregation returns five values simultaneously:

| Value | Description |
|---|---|
| `count` | Number of documents with a value for the field |
| `min` | Lowest value |
| `max` | Highest value |
| `avg` | Arithmetic mean |
| `sum` | Total sum |

These are identical in behavior to their individual counterparts. The advantage of `stats` is that all five are computed in one pass over the data.

#### Syntax

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "amount_stats": {
      "stats": { "field": "amount" }
    }
  }
}
```

#### Output

```json
{
  "aggregations": {
    "amount_stats": {
      "count": 3820,
      "min": 5.00,
      "max": 1200.00,
      "avg": 84.30,
      "sum": 322026.00
    }
  }
}
```

When no documents have a value for the field:

```json
{
  "count": 0,
  "min": null,
  "max": null,
  "avg": null,
  "sum": 0
}
```

---

### extended_stats Aggregation

`extended_stats` is a superset of `stats`. It returns everything `stats` returns, plus additional measures of **spread and distribution**:

| Value | Description |
|---|---|
| `count` | Number of documents with a value |
| `min` | Lowest value |
| `max` | Highest value |
| `avg` | Arithmetic mean |
| `sum` | Total sum |
| `sum_of_squares` | Sum of each value squared |
| `variance` | Population variance |
| `variance_population` | Alias for `variance` (explicit population variant) |
| `variance_sampling` | Sample variance (divides by N−1) |
| `std_deviation` | Population standard deviation |
| `std_deviation_population` | Alias for `std_deviation` |
| `std_deviation_sampling` | Sample standard deviation (divides by N−1) |
| `std_deviation_bounds` | Object containing upper and lower bounds around the mean |

#### Syntax

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "amount_extended": {
      "extended_stats": { "field": "amount" }
    }
  }
}
```

#### Output

```json
{
  "aggregations": {
    "amount_extended": {
      "count": 3820,
      "min": 5.00,
      "max": 1200.00,
      "avg": 84.30,
      "sum": 322026.00,
      "sum_of_squares": 89432100.00,
      "variance": 4821.44,
      "variance_population": 4821.44,
      "variance_sampling": 4822.70,
      "std_deviation": 69.44,
      "std_deviation_population": 69.44,
      "std_deviation_sampling": 69.45,
      "std_deviation_bounds": {
        "upper": 223.18,
        "lower": -54.58,
        "upper_population": 223.18,
        "lower_population": -54.58,
        "upper_sampling": 223.20,
        "lower_sampling": -54.60
      }
    }
  }
}
```

---

### std_deviation_bounds

`std_deviation_bounds` defines an interval around the mean based on a configurable number of standard deviations. It is returned as an object with upper and lower values.

**Formula**

```
upper = avg + (sigma × std_deviation)
lower = avg - (sigma × std_deviation)
```

The default `sigma` is `2`. It can be overridden with the `sigma` parameter.

#### Configuring sigma

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "amount_extended": {
      "extended_stats": {
        "field": "amount",
        "sigma": 3
      }
    }
  }
}
```

A `sigma` of `3` widens the bounds to three standard deviations from the mean. Common values used in practice are `1`, `2`, and `3`.

**Key Points**
- `lower` can be negative even when the field only contains positive values, because the bounds are computed arithmetically around the mean
- The bounds are not clamped to the actual data range
- [Inference] Bounds are most meaningful when the underlying data is approximately normally distributed. For skewed distributions, percentile-based approaches may be more informative. Interpretation depends on the data characteristics.

---

### Population vs. Sampling Variance and Standard Deviation

`extended_stats` exposes both population and sample variants.

| Variant | Formula denominator | When to use |
|---|---|---|
| Population (`_population`) | N | The dataset represents the entire population |
| Sampling (`_sampling`) | N − 1 (Bessel's correction) | The dataset is a sample drawn from a larger population |

[Inference] For large datasets where N is large, the difference between population and sampling variants is negligible. The distinction matters more for small document counts. Which variant to use depends on the analytical context, not on Elasticsearch configuration.

---

### Shared Parameters

Both `stats` and `extended_stats` support the same shared parameters as the individual metric aggregations.

#### missing

Substitute a default value for documents missing the field:

```json
"extended_stats": {
  "field": "response_time",
  "missing": 0
}
```

#### script

Compute values dynamically:

```json
"stats": {
  "script": {
    "source": "doc['price'].value * doc['quantity'].value"
  }
}
```

Or transform a field value using `_value`:

```json
"extended_stats": {
  "field": "price",
  "script": {
    "source": "_value * 1.18"
  }
}
```

---

### Using stats and extended_stats Inside Bucket Aggregations

Both aggregations work within any bucket aggregation, computing independently per bucket.

**Example — stats per product category**

```json
GET /products/_search
{
  "size": 0,
  "aggs": {
    "by_category": {
      "terms": { "field": "category" },
      "aggs": {
        "price_stats": {
          "stats": { "field": "price" }
        }
      }
    }
  }
}
```

**Output (one bucket shown)**

```json
{
  "key": "electronics",
  "doc_count": 142,
  "price_stats": {
    "count": 142,
    "min": 9.99,
    "max": 2499.00,
    "avg": 389.50,
    "sum": 55309.00
  }
}
```

---

### Referencing extended_stats Values in Pipeline Aggregations

Because `extended_stats` is a multi-value aggregation, pipeline aggregations must reference specific sub-values using dot notation in `buckets_path`.

**Valid sub-keys for buckets_path**

```
my_extended.count
my_extended.min
my_extended.max
my_extended.avg
my_extended.sum
my_extended.sum_of_squares
my_extended.variance
my_extended.variance_population
my_extended.variance_sampling
my_extended.std_deviation
my_extended.std_deviation_population
my_extended.std_deviation_sampling
my_extended.std_deviation_bounds.upper
my_extended.std_deviation_bounds.lower
```

**Example — find the month with the highest avg response time variance**

```json
GET /logs/_search
{
  "size": 0,
  "aggs": {
    "by_month": {
      "date_histogram": {
        "field": "timestamp",
        "calendar_interval": "month"
      },
      "aggs": {
        "rt_stats": {
          "extended_stats": { "field": "response_time" }
        }
      }
    },
    "most_variable_month": {
      "max_bucket": {
        "buckets_path": "by_month>rt_stats.variance"
      }
    }
  }
}
```

---

### Practical Patterns

#### Outlier Detection with std_deviation_bounds

Use the bounds to flag documents outside the expected range by combining `extended_stats` with a `range` query or filter aggregation:

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "amount_ext": {
      "extended_stats": {
        "field": "amount",
        "sigma": 2
      }
    }
  }
}
```

Retrieve the upper bound from the response, then issue a second query filtering documents where `amount > upper`. [Inference] This two-step approach is a common pattern for anomaly scoping but requires two round trips. Actual utility depends on the distribution of the data.

#### Comparing Spread Across Segments

Use `extended_stats` inside a `terms` aggregation to compare variability across categories:

```json
GET /products/_search
{
  "size": 0,
  "aggs": {
    "by_category": {
      "terms": { "field": "category" },
      "aggs": {
        "price_spread": {
          "extended_stats": { "field": "price" }
        }
      }
    }
  }
}
```

Compare `std_deviation` values across buckets to identify which categories have the most price variability.

---

### stats vs. extended_stats: Comparison

| Aspect | `stats` | `extended_stats` |
|---|---|---|
| Values returned | 5 | 13+ |
| Includes variance | No | Yes |
| Includes std deviation | No | Yes |
| Includes bounds | No | Yes |
| `sigma` parameter | Not applicable | Supported |
| Use case | General summary | Distribution analysis, outlier detection |
| Pipeline referencing | By agg name (single value not applicable — use sub-key) | Dot notation required for each sub-value |

**Note:** Both `stats` and `extended_stats` are multi-value aggregations. Pipeline aggregations must use dot notation to reference their sub-values (e.g., `my_stats.avg`, `my_stats.sum`).

---

### Mathematical Reference

| Measure | Formula |
|---|---|
| Mean (avg) | `Σx / N` |
| Sum of squares | `Σx²` |
| Population variance | `Σ(x − mean)² / N` |
| Sample variance | `Σ(x − mean)² / (N − 1)` |
| Population std deviation | `√(population variance)` |
| Sample std deviation | `√(sample variance)` |
| Upper bound | `mean + σ × std_deviation` |
| Lower bound | `mean − σ × std_deviation` |

---

**Conclusion**

`stats` is the efficient alternative to requesting `avg`, `sum`, `min`, `max`, and `value_count` individually. `extended_stats` extends this with variance, standard deviation, and configurable sigma bounds, making it suitable for distribution analysis and outlier detection. Both support scripting, `missing`, and integration with pipeline aggregations. The population vs. sampling distinction in `extended_stats` should be chosen based on whether the indexed data represents a full population or a sample.

**Next Steps**
- Use `percentiles` and `percentile_ranks` for non-parametric distribution analysis that does not assume normality
- Explore `median_absolute_deviation` as a robust alternative to standard deviation for skewed data
- Combine `extended_stats` bounds with `filter` aggregations to scope anomaly investigation
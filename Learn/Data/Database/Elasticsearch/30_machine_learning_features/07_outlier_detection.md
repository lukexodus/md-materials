## Outlier Detection

### Overview

Outlier detection is an unsupervised data frame analytics type that identifies rows in a dataset that are structurally different from the rest, based on the statistical relationships between their feature values — without requiring a labeled target field. Each row in the source data is scored with an `outlier_score` (roughly 0 to 1) indicating how much it deviates from the general population of rows, using distance- and density-based methods.

### Why "Unsupervised"

Unlike regression or classification, outlier detection does not need historical examples of "this row was an outlier" / "this row was normal" to learn from. It works purely from the structure of the feature space itself — rows sitting in sparsely populated regions of that space, far from clusters of similar rows, receive higher outlier scores. This makes it suitable when:

- No labeled ground truth exists for what counts as anomalous
- The definition of "outlier" is exactly "structurally unusual relative to the rest of this dataset," rather than a predefined category

### Configuring an Outlier Detection Job

```json
PUT /_ml/data_frame/analytics/transaction-outliers
{
  "source": {
    "index": "transactions"
  },
  "dest": {
    "index": "transactions-outliers"
  },
  "analysis": {
    "outlier_detection": {}
  }
}
```

An empty `outlier_detection: {}` object uses default settings for all parameters, which is a reasonable starting point before tuning.

### Key Parameters

```json
{
  "analysis": {
    "outlier_detection": {
      "n_neighbors": 10,
      "method": "distance_kth_nn",
      "feature_influence_threshold": 0.1,
      "compute_feature_influence": true,
      "standardization_enabled": true
    }
  }
}
```

| Parameter | Purpose |
| --- | --- |
| `n_neighbors` | Number of nearest neighbors considered when computing each row's outlier score; if unset, an appropriate value is chosen automatically based on the dataset [Unverified — exact auto-selection logic should be confirmed against current documentation] |
| `method` | The specific algorithm used (`lof`, `ldof`, `distance_kth_nn`, `distance_knn`, or an ensemble combining multiple methods when unset) [Unverified — exact default/ensemble behavior should be confirmed against the deployed version] |
| `feature_influence_threshold` | Minimum influence score required for a feature to be included in a row's feature influence output |
| `compute_feature_influence` | Whether to compute and store per-feature contribution to each row's outlier score |
| `standardization_enabled` | Whether features are standardized (scaled) before distance calculations, generally recommended when features are on different numeric scales |

### Understanding the Methods (Conceptually)

- **Distance-based methods** (`distance_kth_nn`, `distance_knn`) score a row based on how far it is from its nearest neighbors in feature space — rows far from any cluster get higher scores
- **Density-based methods** (`lof` — Local Outlier Factor, `ldof`) compare a row's local density (how tightly packed its neighborhood is) against the density of its neighbors' neighborhoods — a row in a sparse region surrounded by comparatively dense regions is flagged, even if it's not far in absolute distance terms
- When no specific `method` is set, results are typically derived from an ensemble of multiple methods, which tends to be more robust than relying on any single method alone [Unverified — exact ensemble composition and weighting should be confirmed against current documentation]

### Result Structure

Each document in the destination index contains the original source fields plus an `ml` object with outlier detection results.

```json
{
  "amount": 4850.00,
  "merchant_category": "electronics",
  "location": "unusual_region",
  "ml": {
    "outlier_score": 0.94,
    "feature_influence": [
      { "feature_name": "amount", "influence": 0.62 },
      { "feature_name": "location", "influence": 0.31 }
    ]
  }
}
```

`outlier_score` closer to 1 indicates a stronger outlier; `feature_influence` (when enabled) breaks down which specific fields contributed most to that row's elevated score, aiding interpretation of *why* a row was flagged.

### Field Selection

As with other data frame analytics types, controlling which fields participate in the analysis matters — including irrelevant or purely identifier fields can dilute the meaningfulness of distance/density calculations, since every included field contributes to the feature space the algorithm operates in.

```json
{
  "analyzed_fields": {
    "includes": ["amount", "merchant_category", "location", "time_of_day"],
    "excludes": ["transaction_id", "customer_name"]
  }
}
```

### Running and Reviewing Results

```json
POST /_ml/data_frame/analytics/transaction-outliers/_start
```

```json
GET /_ml/data_frame/analytics/transaction-outliers/_stats
```

Once complete, results are queried like any regular index, typically sorted by `outlier_score` descending to review the most extreme cases first.

```json
GET /transactions-outliers/_search
{
  "query": {
    "range": { "ml.outlier_score": { "gte": 0.9 } }
  },
  "sort": [{ "ml.outlier_score": "desc" }]
}
```

### Outlier Detection vs. Anomaly Detection (Clarifying the Distinction)

Both surface "unusual" data, but the mechanisms and framing differ substantially:

| Aspect | Outlier Detection (Data Frame Analytics) | Anomaly Detection (ML jobs) |
| --- | --- | --- |
| Data nature | Static snapshot, rows compared to each other | Continuous time series, points compared over time |
| Time awareness | Not inherent | Central (bucket_span, seasonality) |
| Comparison basis | Structural distance/density among rows | Deviation from a learned temporal baseline |
| Typical use | One-off dataset review (e.g., a batch of transactions) | Ongoing monitoring (e.g., real-time metric streams) |

A single dataset could reasonably be analyzed both ways depending on the question: "which of these existing transactions look structurally odd" (outlier detection) versus "is transaction volume behaving unusually right now compared to its history" (anomaly detection).

### Tuning Considerations

- Increasing `n_neighbors` generally smooths scores (less sensitive to very local variation), while decreasing it makes the model more sensitive to tight local clusters of anomalies
- Enabling `standardization_enabled` (generally recommended by default) prevents features with naturally larger numeric ranges from dominating distance calculations purely due to scale, rather than genuine importance
- Reviewing `feature_influence` output across many flagged rows can reveal whether certain fields are systematically driving most outlier scores, which may indicate a data quality issue (e.g., an inconsistently formatted field) rather than genuinely interesting outliers

### Common Pitfalls

- Including high-cardinality identifier fields in the analyzed feature set, distorting distance calculations with essentially meaningless dimensions
- Not enabling standardization when features have very different numeric scales (e.g., raw byte counts alongside a 0–1 ratio field), causing the larger-scale feature to dominate scoring
- Treating a high `outlier_score` as inherently meaning "bad" or "fraudulent" rather than simply "structurally unusual" — outliers still require domain judgment to interpret correctly
- Running outlier detection on a dataset too small to establish meaningful neighbor relationships, producing unstable or unreliable scores

### Diagram: Outlier Detection Concept

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740 320">
\<style\>
.title { font: bold 14px sans-serif; fill: #1a1a1a; }
.label { font: 12px sans-serif; fill: #1a1a1a; }
.sub { font: 11px sans-serif; fill: #555; }
.dotNormal { fill: #4a6fa5; }
.dotOutlier { fill: #a54a4a; stroke: #a54a4a; }
\</style\>

<text x="20" y="25" class="title">Outlier Detection: Distance from Clusters (svg_diagram)</text>

<circle cx="150" cy="150" r="6" class="dotNormal" />
<circle cx="165" cy="140" r="6" class="dotNormal" />
<circle cx="140" cy="165" r="6" class="dotNormal" />
<circle cx="175" cy="160" r="6" class="dotNormal" />
<circle cx="155" cy="175" r="6" class="dotNormal" />
<circle cx="130" cy="145" r="6" class="dotNormal" />
<text x="155" y="115" class="sub" text-anchor="middle">dense cluster (normal)</text>
<circle cx="400" cy="90" r="6" class="dotNormal" />
<circle cx="415" cy="100" r="6" class="dotNormal" />
<circle cx="390" cy="105" r="6" class="dotNormal" />
<circle cx="410" cy="80" r="6" class="dotNormal" />
<text x="405" y="65" class="sub" text-anchor="middle">second cluster (normal)</text>
<circle cx="600" cy="230" r="9" class="dotOutlier" />
<text x="600" y="255" class="label" text-anchor="middle" fill="#a54a4a">outlier_score: 0.94</text>
<text x="600" y="272" class="sub" text-anchor="middle">far from any cluster</text>
<circle cx="300" cy="240" r="7" fill="none" stroke="#a5854a" stroke-width="2" />
<text x="300" y="265" class="sub" text-anchor="middle" fill="#a5854a">outlier_score: 0.68</text>
<text x="300" y="280" class="sub" text-anchor="middle">sparse region, moderate</text>
<line x1="200" y1="160" x2="580" y2="225" stroke="#ccc" stroke-width="1" stroke-dasharray="3,3" />
</svg>

**Related Topics**

- Data frame analytics overview — regression and classification alongside outlier detection
- Feature influence interpretation and data quality investigation
- Anomaly detection jobs — the time-series-based counterpart to structural outlier detection
- Field selection and standardization best practices
- Model evaluation approaches for unsupervised results (since no ground truth exists to score against)
- Elastic Security applications of outlier detection
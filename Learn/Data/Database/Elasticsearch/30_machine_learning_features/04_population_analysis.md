## Population Analysis

### Overview

Population analysis is a mode of machine learning anomaly detection in Elasticsearch that identifies unusual behavior by comparing entities against the behavior of their peer group, rather than against each entity's own historical baseline. Instead of asking "is this host behaving unusually compared to how it normally behaves," population analysis asks "is this host behaving unusually compared to how other similar hosts are behaving right now."

This approach is particularly effective for detecting outlier entities in a large, relatively homogeneous population — for example, spotting the one server in a fleet of thousands exhibiting anomalous behavior, even when that behavior wouldn't look anomalous against its own historical pattern (or when insufficient history exists for that entity individually).

### Population Analysis vs. Individual Entity Analysis

| Aspect | Individual (by-field) analysis | Population analysis |
|---|---|---|
| Baseline | Each entity's own historical behavior | The behavior distribution across the whole population |
| Configuration field | `by_field_name` | `over_field_name` |
| Best suited for | Detecting change in behavior over time for known entities | Detecting outliers within a large, comparable group |
| New entity handling | Requires history to establish a baseline | Can flag anomalies for entities with limited history, since it compares against peers |
| Typical use case | "Is this specific server using more CPU than it usually does?" | "Is this server using more CPU than its peers, right now?" |

### The `over_field_name` Parameter

Population analysis is configured in an anomaly detection job's detector using `over_field_name`, which designates the field identifying the population's members:

```
PUT _ml/anomaly_detectors/population-cpu-job
{
  "analysis_config": {
    "bucket_span": "15m",
    "detectors": [
      {
        "function": "mean",
        "field_name": "cpu.usage.percent",
        "over_field_name": "host.name"
      }
    ]
  },
  "data_description": {
    "time_field": "@timestamp"
  }
}
```

Here, each unique value of `host.name` is treated as a member of the population, and the job models the collective distribution of mean CPU usage per bucket across all hosts, flagging individual hosts whose value diverges significantly from that distribution.

### Combining `by_field_name` and `over_field_name`

The two parameters can be combined for more nuanced analysis:

- **`by_field_name` alone** — models each entity's own historical baseline independently.
- **`over_field_name` alone** — models the population's collective distribution, flagging outlier members.
- **Both together** — partitions the analysis by `by_field_name`, then applies population comparison within each partition via `over_field_name`. This allows, for example, comparing hosts against their peers *within the same data center*, rather than across all data centers globally.

### Population Analysis and Influencers

Influencers remain relevant in population analysis and are often set to the same field used in `over_field_name` (e.g., `host.name`), since the influencer mechanism is what surfaces *which specific population member* is responsible for an anomalous bucket in the job's results. Without a matching influencer, the anomaly may be detected at the bucket level without clearly attributing it to the specific outlier entity.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 300">
  <text x="400" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Population vs Individual Baseline (svg_diagram)</text>

  <text x="200" y="55" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Individual analysis</text>
  <line x1="60" y1="150" x2="340" y2="150" stroke="#999" stroke-width="1" />
  <path d="M 60 130 Q 100 110, 140 130 T 220 135 T 300 120" stroke="#4285f4" stroke-width="2" fill="none" />
  <circle cx="300" cy="120" r="5" fill="#ea4335" />
  <text x="300" y="105" text-anchor="middle" font-size="10" fill="#ea4335">deviates from own history</text>
  <text x="200" y="175" text-anchor="middle" font-size="10" fill="#555">Host A compared to Host A's past</text>

  <text x="600" y="55" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Population analysis</text>
  <line x1="460" y1="160" x2="740" y2="160" stroke="#999" stroke-width="1" />
  <circle cx="490" cy="145" r="6" fill="#4285f4" />
  <circle cx="530" cy="150" r="6" fill="#4285f4" />
  <circle cx="570" cy="148" r="6" fill="#4285f4" />
  <circle cx="610" cy="152" r="6" fill="#4285f4" />
  <circle cx="650" cy="146" r="6" fill="#4285f4" />
  <circle cx="690" cy="100" r="7" fill="#ea4335" />
  <text x="690" y="85" text-anchor="middle" font-size="10" fill="#ea4335">outlier host</text>
  <text x="600" y="180" text-anchor="middle" font-size="10" fill="#555">One host compared to all peer hosts, same bucket</text>

  <text x="400" y="240" text-anchor="middle" font-size="12" fill="#555">Population analysis flags the member that diverges</text>
  <text x="400" y="258" text-anchor="middle" font-size="12" fill="#555">from its peers' collective distribution in the current window,</text>
  <text x="400" y="276" text-anchor="middle" font-size="12" fill="#555">rather than from its own historical pattern.</text>
</svg>

### Common Use Cases

- **Security/anomalous user behavior** — detecting a single user account exhibiting access patterns divergent from the broader user population (e.g., unusual login times, data volumes accessed).
- **Infrastructure monitoring** — spotting the one node, pod, or service instance in a large fleet behaving differently from its peers.
- **Fraud detection** — identifying transactions or accounts that deviate from the collective norm of similar transactions.
- **IoT/sensor fleets** — flagging a malfunctioning or miscalibrated sensor among a large group of otherwise-similar devices.

### Requirements and Practical Considerations

- Population analysis is most effective with a reasonably large and behaviorally consistent population; a very small or highly heterogeneous population undermines the value of comparing members against each other.
- The population field (`over_field_name`) should have moderate-to-high cardinality — a field with only two or three distinct values doesn't provide a meaningful distribution to compare against.
- Bucket span selection affects sensitivity: too short a span may not accumulate enough data per member per bucket for stable comparison; too long a span may smooth out short-lived anomalies. [Inference: optimal bucket span is workload- and cardinality-dependent, and typically requires iteration against real data.]
- Population jobs can be more resource-intensive than individual entity jobs at very high cardinality, since the model must track the collective distribution across all members.

### Interpreting Population Analysis Results

Anomaly results from a population job surface at the bucket level but attribute the anomaly to the specific influencer (population member) responsible. The anomaly score reflects how unusual that member's value is *relative to the rest of the population in that bucket*, not relative to any absolute or historical threshold — meaning the same raw value could be flagged as anomalous in one bucket (where peers are behaving consistently) but not in another (where the whole population's behavior has shifted together).

### Key Points

- Population analysis compares entities against their peer group's collective behavior, configured via `over_field_name`.
- Contrasts with individual (`by_field_name`) analysis, which compares an entity against its own history.
- The two parameters can be combined to partition-then-compare within groups.
- Best suited to large, behaviorally consistent populations with moderate-to-high cardinality.
- Influencers should typically align with the population field to properly attribute which member caused an anomaly.

### Related Topics

- Anomaly detection job detectors and `by_field_name`
- Influencers and anomaly attribution
- Bucket span selection and tuning
- Datafeed configuration for ML jobs
- Multi-metric and rare function anomaly detection
- Security use cases: user and entity behavior analytics (UEBA)
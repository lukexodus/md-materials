## Batch vs Streaming Preprocessing

### Defining the Two Paradigms

**Batch preprocessing** processes data in discrete, bounded chunks — typically a full dataset or a fixed time window — on a scheduled or triggered basis. **Streaming preprocessing** processes data continuously, record-by-record or in small micro-batches, as it arrives in near real time.

The distinction affects nearly every design decision in a preprocessing pipeline: how missing values are imputed, how statistics for normalization are computed, how outliers are detected, and how schema changes are handled.

---

### Core Comparison

| Dimension | Batch | Streaming |
|---|---|---|
| Data scope per run | Full dataset or fixed window | Individual records or micro-batches |
| Latency | Minutes to hours (or longer) | Milliseconds to seconds |
| Statistical computation | Computed over complete data | Computed incrementally or over a sliding window |
| Reprocessing | Straightforward — rerun on stored data | Harder — requires replay infrastructure (e.g., event logs) |
| Typical tools | Pandas, Spark, SQL-based ETL | Kafka Streams, Flink, Spark Structured Streaming |
| Failure recovery | Rerun the batch job | Requires checkpointing and state management |

I cannot verify that this table exhaustively covers every relevant dimension for all use cases — it reflects commonly discussed characteristics in data engineering literature, not a quotation from a specific named source.

---

### Batch Preprocessing

#### Characteristics

Batch jobs operate on data that has already landed in storage (a data warehouse, data lake, or file system), and are typically run on a schedule (hourly, daily) or triggered by an upstream event (e.g., a new file arriving).

```python
import pandas as pd

def batch_preprocess(filepath):
    df = pd.read_csv(filepath)

    # Compute statistics over the full batch
    mean_income = df['income'].mean()
    std_income = df['income'].std()

    df['income_zscore'] = (df['income'] - mean_income) / std_income
    df['income_missing'] = df['income'].isna()
    df['income'] = df['income'].fillna(mean_income)

    return df
```

Because the full dataset is available at computation time, statistics like mean, standard deviation, or quantiles are computed exactly over the entire batch — there is no approximation involved in this step. [Inference] Whether this is materially "more accurate" than a streaming equivalent depends on how much the incremental estimate in the streaming case has converged, which I cannot assess generically without a specific data distribution and window size.

#### Advantages

- Full visibility into the dataset enables exact statistical computation (true mean, true quantiles, exact outlier bounds).
- Easier to audit and reproduce — the same input file processed twice with the same code yields the same output, assuming no non-determinism in the code itself.
- Simpler tooling requirements; standard libraries like Pandas or Spark batch APIs are sufficient.

#### Disadvantages

- Latency between data arrival and processed availability, often ranging from minutes to a full day depending on schedule.
- Late-arriving data within a window can require reprocessing the entire batch.
- Not suitable for use cases requiring near-real-time model inference (e.g., fraud detection at transaction time).

---

### Streaming Preprocessing

#### Characteristics

Streaming pipelines process records as they arrive from a message queue or event log (e.g., Kafka, Kinesis), applying transformations incrementally without waiting for a complete dataset.

```python
# Conceptual example using a stateful streaming pattern
# (illustrative pseudocode — not a runnable framework-specific implementation)

class IncrementalStats:
    def __init__(self):
        self.n = 0
        self.mean = 0.0
        self.m2 = 0.0  # sum of squares of differences from the mean

    def update(self, value):
        self.n += 1
        delta = value - self.mean
        self.mean += delta / self.n
        delta2 = value - self.mean
        self.m2 += delta * delta2

    def variance(self):
        return self.m2 / self.n if self.n > 1 else 0.0

stats = IncrementalStats()

def process_record(record, stats):
    stats.update(record['income'])
    zscore = (record['income'] - stats.mean) / (stats.variance() ** 0.5 + 1e-9)
    record['income_zscore'] = zscore
    return record
```

This is Welford's online algorithm for computing running mean and variance incrementally, without storing the full dataset in memory. [Inference] I have reasoned through this formula from the standard definition of the algorithm as commonly presented in numerical computing references; I have not directly verified this specific code against the original Welford (1962) paper in this session, so treat the derivation as reasoned reconstruction rather than a confirmed quotation of that source.

#### Advantages

- Low latency between data arrival and availability of processed output, often on the order of milliseconds to seconds. [Inference] The exact latency achievable depends heavily on infrastructure, message queue configuration, and processing complexity — I cannot state a guaranteed latency figure for any general case.
- Suitable for use cases requiring near-real-time decisions, such as fraud scoring or recommendation updates.
- Can handle unbounded data volumes without requiring the full dataset to fit in memory at once.

#### Disadvantages

- Statistics (mean, variance, quantiles) are approximations that converge over time rather than exact values computed over a complete dataset — early records are scored against less-converged statistics.
- Handling late-arriving or out-of-order events requires additional mechanisms such as watermarking.
- Debugging and reproducing a specific historical state is more complex, typically requiring event replay from a persisted log.
- State management (e.g., the running mean/variance object) must be checkpointed to survive failures without data loss; this requires additional infrastructure I cannot describe generically without knowing the specific streaming framework in use.

---

### Handling Missing Values: Batch vs Streaming Contrast

| Approach | Batch | Streaming |
|---|---|---|
| Mean imputation | Exact mean computed once over full data | Running mean, updated incrementally; early imputations use a less-converged estimate |
| Mode imputation (categorical) | Exact mode from full frequency count | Requires an approximate frequency counter (e.g., Count-Min Sketch) for high-cardinality streams |
| Forward-fill | Straightforward with an ordered DataFrame | Requires maintaining last-seen-value state per key/entity |

[Inference] The characterization of streaming mode imputation requiring approximate structures like Count-Min Sketch applies specifically to high-cardinality categorical fields where exact per-value counts would be memory-prohibitive; for low-cardinality fields, exact incremental counting remains feasible. I have not tested this claim against a specific implementation in this session.

---

### Diagram: Batch vs Streaming Data Flow

```mermaid
flowchart TD
    subgraph Batch
    A1[Data Lands in Storage] --> A2[Scheduled Trigger]
    A2 --> A3[Load Full Dataset]
    A3 --> A4[Compute Exact Statistics]
    A4 --> A5[Apply Transformations]
    A5 --> A6[Write Processed Batch]
    end

    subgraph Streaming
    B1[Event Arrives] --> B2[Update Incremental State]
    B2 --> B3[Apply Transformation Using Current State]
    B3 --> B4[Emit Processed Record]
    B4 --> B5[Checkpoint State]
    end
```

---

### Hybrid Approaches

Many production systems combine both paradigms — often called the **Lambda architecture** (separate batch and streaming layers reconciled at query time) or **Kappa architecture** (a single streaming pipeline that also handles reprocessing via replay).

[Unverified] I cannot verify the precise, formal definitions of Lambda and Kappa architecture against Nathan Marz's or Jay Kreps's original writings in this session — the descriptions above reflect commonly circulated characterizations of these terms in data engineering discussion, not confirmed quotations from those original sources. If exact definitional accuracy matters for your use case, I'd recommend checking the original sources directly.

A common hybrid pattern for preprocessing specifically:
- Compute global statistics (mean, std, quantile boundaries) in a periodic batch job.
- Use those precomputed statistics as fixed parameters in a streaming pipeline for real-time scoring.
- Periodically refresh the batch-computed statistics to account for data drift.

```python
# Batch job computes and persists statistics
global_stats = {"income_mean": 52000.0, "income_std": 18000.0}
# (persisted to a config store, e.g., a feature store or key-value store)

# Streaming job loads and applies fixed statistics
def stream_transform(record, stats):
    record['income_zscore'] = (record['income'] - stats['income_mean']) / stats['income_std']
    return record
```

This pattern avoids the "cold start" problem of streaming statistics starting from zero. [Inference] I am reasoning this benefit from the mechanics of the approach itself, not from a benchmarked comparison — I have not measured or verified how much this improves outcomes in any specific deployment.

---

### Common Pitfalls

- **Train/serve skew**: Computing normalization statistics in batch during training but applying different (e.g., incrementally updated) statistics during streaming inference, causing inconsistent feature distributions between training and serving.
- **Ignoring data drift in streaming**: Fixed batch-computed statistics used indefinitely in a streaming pipeline can become stale as the underlying data distribution shifts over time.
- **Unbounded state growth**: Streaming pipelines that accumulate per-entity state (e.g., a running total per user) without eviction policies can face unbounded memory growth over long-running deployments.
- **Non-deterministic batch reprocessing**: Batch jobs assumed to be reproducible can silently become non-deterministic if they depend on external state (e.g., current wall-clock time, a live lookup table) without pinning that state.

[Speculation] I do not have data on the relative frequency of these pitfalls in real-world deployments, so no claim is made about which is most common.

---

### Related Topics

- Feature stores and their role in bridging batch and streaming feature computation
- Data drift detection and monitoring in production pipelines
- Watermarking and event-time processing in stream processing frameworks
- Checkpointing and exactly-once processing semantics in streaming systems
- Lambda vs Kappa architecture in depth
- Online learning algorithms as a modeling-side counterpart to streaming preprocessing
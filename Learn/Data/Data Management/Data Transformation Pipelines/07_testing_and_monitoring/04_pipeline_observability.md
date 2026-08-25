## Pipeline Observability


Pipeline observability refers to the comprehensive instrumentation, collection, and analysis of telemetry data derived from distributed data transformation workflows. Unlike generic application monitoring, pipeline observability must account for data correctness, throughput consistency, state management, and the temporal properties of data (event time vs. processing time) across decoupled compute and storage layers.

### Telemetry Layers and Context Propagation

Effective observability requires a multi-layered telemetry strategy that correlates infrastructure health with data reliability.

* **Infrastructure Metrics:** CPU steal times, heap memory fragmentation, network I/O saturation, and disk spill metrics. These must be tagged with specific `stage_id`, `task_id`, and `container_id` to correlate resource contention with pipeline skew.
* **Logical Execution Metrics:**
* **Throughput:** Records/sec, bytes/sec per partition.
* **Latency:** End-to-end latency, stage-level latency, and scheduler overhead.
* **Data Volume:** Input vs. output record counts (selectivity ratios).


* **Distributed Tracing & Context Propagation:**
Standard tracing libraries (e.g., OpenTelemetry) often lose context during asynchronous shuffles or persistent storage buffers (like Kafka topics). Advanced pipelines employ **context propagation** mechanisms that inject trace headers (e.g., W3C Trace Context) into record metadata or message envelopes.
* **Barrier Synchronization:** Traces must account for barrier alignments in bulk-synchronous parallel (BSP) systems (e.g., Spark stages) where the slowest task determines stage latency.
* **Cross-Boundary Lineage:** Trace IDs must persist across boundaries, such as a producer writing to a topic and a consumer reading from it, enabling end-to-end latency visualization.



### Data Reliability and Quality Observability

Data observability focuses on the payload itself, ensuring that the processed data adheres to defined contracts and statistical expectations.

* **Schema Drift Detection:** Real-time monitoring of schema registries to detect backward-incompatible changes (e.g., column deletion, type promotion failures).
* **Statistical Anomalies:**
* **Cardinality Shifts:** Sudden spikes in distinct values for grouping keys, which can lead to OOM errors or shuffle skew.
* **Distribution Drift:** Measuring Kullback-Leibler (KL) divergence or Population Stability Index (PSI) between current micro-batches and historical baselines.
* **Null/Error Rates:** Tracking the ratio of `malformed_records` sent to dead-letter queues (DLQ) versus successfully processed records.


* **Data Freshness (Lag):**
* **Pipeline Lag:**  (processing delay).
* **Data Lag:**  (arrival delay).



### Stateful Processing and Watermark Semantics

In stateful streaming architectures (e.g., Flink, Spark Structured Streaming), observability must extend to the internal state stores and temporal progress markers.

* **State Store Metrics:**
* **Size & Growth:** Bytes stored in local state backends (e.g., RocksDB SST files). Rapid growth indicates potential memory leaks or unbound windows.
* **Checkpoint Latency:** Duration to snapshot state to durable storage (HDFS/S3). High latency impacts end-to-end delivery guarantees.
* **Compaction Overhead:** CPU/Disk cycles spent compacting LSM trees in the state store.


* **Watermark Dynamics:**
* **Watermark Lag:** The time difference between the current wall clock and the current global watermark. Increasing lag implies the system is falling behind or waiting for late data.
* **Late Data Dropped:** Count of records discarded because their event time .



### Execution Models and Resource Isolation

Observability differs fundamentally based on the execution model.

* **Batch Processing:**
* **Skew Detection:** Variance in task duration within a single stage. High variance suggests partitioning keys causing data skew.
* **Spill-to-Disk:** Volume of data serialized to disk during shuffles when memory buffers are exceeded.


* **Streaming / Micro-batch:**
* **Backpressure Status:** Monitoring credit-based flow control mechanisms. If an operator's input buffer is full, it exerts backpressure upstream.
* **Consumer Group Lag:** The delta between the latest offset in the source topic and the committed offset of the consumer group.


* **Resource Management:**
* **Executor Loss:** Rate of preemption (Spot instances) or crash loops (OOM).
* **Garbage Collection (GC) Impact:** Percentage of CPU time spent in GC (Stop-the-world pauses) vs. execution time.



### Lineage and Impact Analysis

Automated lineage tracking maps the dependency graph between datasets, jobs, and runs.

* **Granularity:**
* **Dataset Level:** Table A depends on Table B.
* **Field Level:** Column `A.revenue` is derived from `B.price * B.quantity`.


* **Run-Time Lineage:** Captures the specific version of code, configuration, and input data partitions used for a specific execution. This is critical for **reproducibility** and debugging non-deterministic transformations.
* **OpenLineage Standard:** Adopting specifications like OpenLineage allows for the emission of lineage events (START, COMPLETE, FAIL) with facets for schema, source code hash, and input/output statistics to a centralized catalog.

### Fault Tolerance and Recovery Observability

* **Restart/Recovery Time:** The time taken to restore state from the last checkpoint and resume processing after a failure (RTO - Recovery Time Objective).
* **Idempotency Verification:** Monitoring for duplicate records generated during retry storms.
* **Source Starvation:** Detecting when source partitions are idle for extended periods, indicating upstream blockages or partition discovery issues.

### Related Topics

* Data Reliability Engineering (DRE)
* FinOps for Data Pipelines
* Distributed Tracing Standards (OpenTelemetry)
* Metadata Management and Data Catalogs
* Chaos Engineering for Data Systems

---


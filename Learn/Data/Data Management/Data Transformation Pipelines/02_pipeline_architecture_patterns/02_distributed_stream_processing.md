## Distributed Stream Processing


### Execution Semantics and Topology

Stream processing architectures fundamentally operate on unbound datasets, executing continuous transformations over infinite sequences of events. The logical topology is represented as a Directed Acyclic Graph (DAG) where vertices represent transformation operators (sources, transformations, sinks) and edges represent data streams.

- **Operator Chaining & Fusion:** To minimize serialization/deserialization overhead and network buffer latency, optimization engines fuse compatible sequential operators into a single physical task (e.g., filter followed by a map). This fusion executes within the same thread context, leveraging CPU cache locality.
    
- **Pipelined Execution:** Unlike batch processing's blocking stages, stream operators execute in a pipelined fashion. Upstream operators push records to downstream buffers immediately upon processing, governed by credit-based flow control mechanisms to handle backpressure.
    
- **Cyclic Dependencies:** While primarily DAG-based, advanced iteration support allows for cyclic data flows required by specific ML training algorithms or graph processing, typically managed via explicit feedback edges and iteration heads that synchronize supersteps.
    

### State Management and Consistency

Stateful stream processing requires maintaining contextual information (aggregations, pattern matching buffers, machine learning model weights) across events.

- **State Backends:**
    
    - **In-Memory (Heap/Off-Heap):** Provides microsecond-latency access but is bounded by volatile memory capacity. Suitable for low-latency, low-state scenarios.
        
    - **Embedded KV Stores (e.g., RocksDB):** Spills state to local disk (SSD/NVMe). Allows state sizes exceeding memory limits but incurs serialization/deserialization overhead during access.
        
- **Checkpointing & Barriers:** Fault tolerance is achieved via distributed snapshots, commonly implementing the Asynchronous Barrier Snapshotting (ABS) variant of the Chandy-Lamport algorithm. Checkpoint barriers flow with data records; upon receiving barriers from all input channels, an operator snapshots its local state to durable remote storage (S3, HDFS).
    
- **State Primitives:**
    
    - **Keyed State:** Sharded by key and physically co-located with the processing task responsible for that key range.
        
    - **Operator State:** Bound to parallel operator instances (e.g., Kafka consumer offsets), redistributed using specific strategies (round-robin, broadcast) during rescaling.
        
- **Exactly-Once Semantics (EOS):** End-to-end EOS requires alignment between internal state checkpoints and sink transaction commits. This is typically implemented via Two-Phase Commit (2PC) protocols where pre-commits occur on checkpoint completion and final commits occur on global coordinator acknowledgement.
    

### Time Domains, Windowing, and Watermarks

Deterministic processing of out-of-order data necessitates strict definitions of time domains.

- **Time Semantics:**
    
    - **Event Time:** The timestamp attached to the record at generation. Decouples results from processing speed.
        
    - **Processing Time:** The system clock time at the machine processing the event. Offers lower latency but zero determinism.
        
    - **Ingestion Time:** The timestamp assigned when the event enters the source operator.
        
- **Watermarks:** Monotonically increasing timestamps embedded in the stream that function as a global progress metric. A watermark $W(t)$ asserts that no events with timestamp $t' < t$ will arrive subsequently.
    
    - **Heuristic Generation:** Periodic generation based on max observed timestamp minus a bounded delay (slack).
        
    - **Propagation:** Operators forward the minimum watermark received from all input channels.
        
- **Late Data Handling:** Events arriving after the watermark passes the window boundary trigger specific strategies:
    
    - **Allowed Lateness:** Re-triggering window computations for a configurable duration.
        
    - **Side Outputs:** Diverting late records to a secondary stream (dead-letter queue) for manual reconciliation.
        
- **Window Assigners:**
    
    - **Tumbling:** Fixed-size, non-overlapping intervals.
        
    - **Sliding:** Fixed-size, overlapping intervals defined by size and slide parameters.
        
    - **Session:** Dynamic intervals bounded by periods of inactivity (session gap).
        

### Partitioning, Shuffling, and Data Locality

Scaling stream processing horizontally requires partitioning data streams across parallel worker nodes.

- **Key Groups:** To support dynamic rescaling, the key space is divided into atomic Key Groups, which are then assigned to parallel operator instances. Rescaling involves moving Key Groups rather than rehashing individual keys.
    
- **Exchange Strategies:**
    
    - **Forward:** Direct transmission to a local downstream operator (no network stack).
        
    - **Hash/Key Grouping:** Deterministic routing based on hash(key), essential for aggregations.
        
    - **Rebalance/Round-Robin:** Distributes load evenly to handle data skew, incurring network overhead.
        
    - **Broadcast:** Replicates records to all downstream parallel instances (e.g., broadcasting a dimension table or rule set to a fact stream).
        
- **Skew Mitigation:** Hot keys are handled by separating the aggregation into a "local" pre-aggregation step (upstream) and a "global" final aggregation, or by salting keys to distribute heavy-hitters across multiple partitions.
    

### Stream-Stream and Stream-Table Joins

Joining unbounded streams introduces complex state retention challenges.

- **Interval Joins:** Join elements from two streams (A and B) strictly within a defined time boundary (e.g., A.time between B.time - lowerBound and B.time + upperBound). State is retained only for the duration of the interval.
    
- **Temporal Table Joins:** Joining an append-only stream with a dynamic changing table (versioned table). The stream event joins against the version of the table valid at the event's time.
    
- **Dynamic Tables & Retractions:** When outputting results of non-monotonic operations (e.g., SQL aggregations on streams), the pipeline must support retraction messages (UPDATE/DELETE semantics) to correct previously emitted results in downstream systems.
    

### Schema Evolution and Compatibility

Long-running pipelines must handle changes in data structure without downtime.

- **Schema Registries:** Centralized repositories enforcing compatibility rules (Backward, Forward, Full) during serialization/deserialization.
    
- **In-Flight Evolution:** Pipelines utilizing self-describing formats (Avro, Protobuf) can accommodate schema drift if the execution engine supports schema-agnostic state access or state migration tools to map old state schemas to new definitions upon restart.
    

### Related Topics

- Kappa Architecture
    
- Lambda Architecture
    
- Change Data Capture (CDC) Pipelines
    
- Complex Event Processing (CEP)
    
- Micro-batch Processing Architectures

---


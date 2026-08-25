## Apache Beam Unified Execution Model and Pipeline Architecture


### Unified Programming Model and DAG Semantics

Apache Beam decouples pipeline logic from the underlying execution engine through the **Beam Model**, which treats batch and streaming processing as points on a continuous spectrum of latency and completeness. The pipeline is constructed as a Directed Acyclic Graph (DAG) of `PTransforms` acting on strictly immutable, distributed data sets known as `PCollections`.

- **PCollection Abstraction:** Represents a potentially unbounded, unordered bag of elements. In distributed execution, `PCollections` are physically sharded into **bundles** (micro-batches), which serve as the atomic unit of parallelization and failure recovery.
    
- **Graph Translation:** The User Code (SDK) constructs a logical DAG which is serialized into a language-agnostic Protocol Buffer format via the Runner API. This intermediate representation allows the **Runner** (Flink, Spark, Dataflow) to optimize the physical execution plan (e.g., via operator fusion) before deployment.
    
- **ParDo and Bundle Lifecycle:** The core parallel processing primitive (`ParDo`) invokes user-defined functions (`DoFn`). A `DoFn` instance is persistent across a bundle but is conceptually stateless between bundles unless utilizing the Stateful API. Runners manage the lifecycle (`Setup`, `StartBundle`, `ProcessElement`, `FinishBundle`, `Teardown`) to amortize initialization costs.
    

### Windowing, Watermarks, and Temporal Consistency

Beam addresses the non-deterministic nature of distributed data arrival (skew between Event Time and Processing Time) through a rigorous windowing and triggering model.

- **Watermark Semantics:** The watermark $W(t)$ is a monotonically increasing function $T \to T$ representing a global progress metric, asserting that no events with timestamp $t' < W(t)$ will arrive in the future.
    
    - **Source Watermarks:** Heuristic-based (e.g., Kafka partition offsets).
        
    - **Propagation:** Derived watermarks flow through the DAG; transformations like `GroupByKey` hold the output watermark until inputs for a specific window are satisfied.
        
- **Windowing Strategies:**
    
    - **Fixed/Tumbling:** Discrete, non-overlapping intervals.
        
    - **Sliding:** Overlapping intervals; an element belongs to $\lceil \frac{Size}{Slide} \rceil$ windows, increasing state storage requirements.
        
    - **Session:** Data-driven windows defined by gaps in activity (key-specific). Requires merging logic where overlapping windows for a key are unified dynamically.
        
- **Triggers and Pane Info:**
    
    - **Early Triggers:** Speculative results emitted before the watermark passes the end of the window (reducing latency).
        
    - **On-Time Triggers:** Emitted when the watermark passes the window boundary (completeness).
        
    - **Late Triggers:** Updates emitted when straggler data arrives after the watermark but within the `allowedLateness` horizon.
        
    - **Pane Accumulation:** Governs how refinements are handled—`Discarding` (deltas only) vs. `Accumulating` (total state).
        

### Stateful Processing and Timer Semantics

For complex ETL requiring cross-bundle data dependency (e.g., arbitrary state machines, temporal joins), Beam provides per-key state and timers strictly scoped to the `Key` and `Window`.

- **State Cells:**
    
    - `ValueState`: Single mutable value.
        
    - `BagState`: Append-only collection (optimized for high-throughput writes; reads require scanning).
        
    - `MapState`/`SetState`: Efficient lookups and membership tests without full deserialization.
        
    - **Storage locality:** State is co-located with the key on the worker node. Access involves local disk I/O (e.g., RocksDB) rather than network shuffles.
        
- **Timers (Event & Processing Time):** Allows a `DoFn` to self-schedule callbacks. Essential for implementing custom windowing logic, time-out patterns (e.g., "wait 10 minutes for a join match, else emit partial"), and buffer flushing. Timers are check-pointed and fault-tolerant.
    

### Portability Framework and Fn API

The Portability Framework enables cross-language pipelines (e.g., Python logic running on a Java-based Flink cluster) and isolates user code execution.

- **Runner Harness vs. SDK Harness:** The Runner (supervisor) manages parallelism, I/O, and sharding. The SDK Harness (worker) executes the actual UDF logic.
    
- **Fn Data API:** Facilitates data plane communication between Runner and SDK Harness over gRPC.
    
- **Fn State API:** Allows the SDK Harness to request state reads/writes from the Runner (which owns the state backend).
    
- **Environment Isolation:** SDK Harnesses typically run in Docker containers, ensuring dependency isolation between the execution cluster and the transformation logic.
    

### Data Encoding and Determinism

Serialization in Beam is handled by **Coders**. Unlike generic serialization, Beam Coders must adhere to strict properties for correctness during shuffling `GroupByKey`:

- **Determinism:** For `GroupByKey` to function correctly, the Coder _must_ be deterministic (same object $\to$ identical byte sequence). Non-deterministic coding of keys results in fragmented groups and data loss.
    
- **Context:** `Context.OUTER` vs `Context.NESTED` dictates whether length-prefixing is required (e.g., to distinguish boundaries in a stream of encoded objects).
    

### Fault Tolerance and Bundle Reprocessing

Beam delegates fault tolerance to the underlying Runner, but enforces specific semantic guarantees:

- **Bundle Atomicity:** A bundle is the unit of commit. If a bundle fails, the Runner retries the entire bundle.
    
- **Effect of Non-Determinism:** If user code is non-deterministic, retries may produce different outputs, potentially violating `exactly-once` semantics if downstream sinks are not idempotent.
    
- **Checkpointing:** In streaming Runners, state snapshots are coordinated (e.g., via Chandy-Lamport in Flink) to ensure consistent recovery points.
    

### Related Architectures

- Google Cloud Dataflow
    
- Apache Flink
    
- Apache Spark Structured Streaming
    
- Spotify Scio (Scala API for Beam)
    
- Akka Streams

---


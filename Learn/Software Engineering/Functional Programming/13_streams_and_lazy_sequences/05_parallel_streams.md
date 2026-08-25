## Parallel Streams


Parallel streams enable concurrent processing of data by dividing stream operations across multiple threads. The stream is split into segments, processed independently, and results are combined. This exploits multi-core processors to potentially reduce execution time for computationally intensive operations on large datasets.

The execution model involves:

- **Work splitting**: Data source is divided into chunks
- **Forking**: Chunks are distributed to worker threads from a common fork-join pool
- **Independent processing**: Each thread applies transformations to its chunk
- **Joining**: Results are combined using associative operations

Ordering guarantees depend on the stream source and operations. Ordered streams maintain encounter order but may sacrifice some parallelism. Unordered streams allow maximum parallelism but don't guarantee result sequence.

**Key considerations:**

- Operations must be stateless and non-interfering to avoid race conditions
- Combining operations must be associative for correct results
- Overhead of thread coordination can outweigh benefits for small datasets or simple operations
- The underlying fork-join pool is shared across the application by default

**Example:**

```scala
val numbers = (1 to 1000000).toList
val parallelSum = numbers.par.filter(_ % 2 == 0).map(_ * 2).sum
```

Performance gains materialize when:

- Dataset size justifies parallelization overhead
- Operations are computationally expensive per element
- Operations are independent and side-effect free
- Available CPU cores can be utilized

The cost model involves comparing sequential processing time against parallel processing time plus coordination overhead. Parallel streams become beneficial when the parallel execution time significantly undercuts sequential time despite synchronization costs.


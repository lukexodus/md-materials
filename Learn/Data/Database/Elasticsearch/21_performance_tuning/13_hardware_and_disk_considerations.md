## Hardware and Disk Considerations

### Overview

Elasticsearch performance and stability depend heavily on the underlying hardware, and the relative importance of CPU, RAM, disk type, and network varies by workload. Storage in particular has an outsized effect, since indexing, merging, and search all involve substantial I/O.

### Storage: SSD vs. HDD

**Key Points**

- SSDs are strongly preferred over spinning disks (HDDs) for Elasticsearch nodes, particularly for indexing-heavy or latency-sensitive workloads.
- Indexing involves frequent, small, random writes (segment creation, translog writes, merges), a pattern where SSDs vastly outperform HDDs.
- Search performance also benefits from SSDs due to random-access read patterns when reading postings lists, doc values, and stored fields from disk.
- NVMe SSDs generally outperform SATA SSDs for high-throughput indexing or search workloads, though the gap matters less once a workload is not I/O-bound.

### RAID and Storage Layout

**Key Points**

- Elasticsearch has built-in replication (via replica shards), so RAID for redundancy purposes is generally unnecessary and can be counterproductive — it adds a layer of abstraction and potential failure without providing benefit beyond what replicas already provide.
- RAID 0 (striping without redundancy) is sometimes used to increase throughput across multiple disks, at the cost of losing an entire node's data if any single disk fails — an acceptable trade-off given replica shards already provide durability.
- Multiple data paths (`path.data` as an array) is an alternative to RAID 0 supported directly by Elasticsearch, though [Unverified] the relative performance of multiple data paths versus RAID 0 depends on the specific storage hardware and filesystem, and Elasticsearch's own documentation has historically recommended RAID 0 over multiple data paths for predictability of shard allocation.
- Network-attached storage (NAS) and remote block storage introduce network latency into every disk operation and are generally discouraged for primary data storage, especially for latency-sensitive workloads.

### Heap Sizing

**Key Points**

- The JVM heap should typically be set to no more than 50% of available RAM, leaving the remainder for the OS filesystem cache, which Lucene relies on heavily for fast segment and doc-values access.
- Heap should generally not exceed roughly 32 GB, because of the JVM's compressed ordinary object pointers (compressed oops) optimization, which stops being usable once the heap crosses a threshold near 32 GB, causing a disproportionate effective capacity loss just above that boundary.
- [Inference] In practice this makes roughly 64 GB of total RAM (with ~30 GB heap) a commonly recommended practical ceiling per node for the classic heap-sizing guidance, past which additional RAM primarily benefits filesystem cache rather than heap.
- `Xms` and `Xmx` should be set to the same value to avoid heap resizing pauses during operation.

$$\text{heap_size} = \min(0.5 \times \text{RAM}, \sim32\text{ GB})$$

### CPU Considerations

**Key Points**

- Indexing (analysis, tokenization) and search (scoring, aggregations) are both CPU-intensive operations, so adequate CPU core count matters for throughput on busy clusters.
- Aggregations, especially bucket aggregations over high-cardinality fields, and scripted operations are particularly CPU-intensive relative to simple term lookups.
- [Inference] Workloads dominated by complex aggregations or heavy scripting tend to benefit more from additional CPU cores than from additional RAM beyond what's needed for heap and filesystem cache, though the actual bottleneck varies by specific query shape and should be confirmed with profiling rather than assumed.

### Memory Beyond Heap: The Filesystem Cache

The portion of RAM not allocated to heap is used by the operating system as filesystem cache, which Lucene depends on for fast access to segment files, doc values, and other on-disk structures. This is why the 50%-heap guideline exists — allocating too much RAM to heap starves the filesystem cache and can paradoxically slow down disk-backed reads like doc values access, even though more heap sounds like it should help.

### Network Considerations

**Key Points**

- Elasticsearch nodes communicate frequently for cluster state updates, replication, and cross-shard search coordination, so network latency and bandwidth between nodes matters, especially in multi-node clusters spanning racks, availability zones, or regions.
- Cross-availability-zone or cross-region deployments introduce higher latency between nodes than single-zone deployments, which affects replication acknowledgment time and cross-shard search coordination.
- 10 Gbps or faster networking is commonly recommended for nodes in throughput-sensitive clusters, particularly where large shard recovery or rebalancing operations are frequent.

### Diagram: RAM Allocation on a Node

<svg width="100%" viewBox="0 0 680 260" role="img"><title>RAM allocation between JVM heap and filesystem cache (svg_diagram)</title><desc>A node's total RAM is split between JVM heap, capped near 50 percent or 32 GB, and the remaining filesystem cache used by Lucene for fast disk access.</desc> <defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></marker></defs>

<g class="c-gray"> <rect x="40" y="40" width="600" height="100" rx="14" stroke-width="0.5"/> <text class="th" x="60" y="30" dominant-baseline="central">Node RAM (e.g. 64 GB)</text> </g> <g class="c-blue"> <rect x="56" y="56" width="280" height="68" rx="8" stroke-width="0.5"/> <text class="th" x="196" y="80" text-anchor="middle" dominant-baseline="central">JVM heap</text> <text class="ts" x="196" y="100" text-anchor="middle" dominant-baseline="central">~30 GB, capped near 32 GB</text> </g> <g class="c-teal"> <rect x="344" y="56" width="280" height="68" rx="8" stroke-width="0.5"/> <text class="th" x="484" y="80" text-anchor="middle" dominant-baseline="central">Filesystem cache</text> <text class="ts" x="484" y="100" text-anchor="middle" dominant-baseline="central">Remaining RAM, used by Lucene</text> </g>

<text class="ts" x="340" y="170" text-anchor="middle">Doc values, segment files, and postings lists are read through this cache layer</text> <line x1="196" y1="124" x2="240" y2="190" class="arr" marker-end="url(#arrow)"/> <line x1="484" y1="124" x2="440" y2="190" class="arr" marker-end="url(#arrow)"/> <g class="c-gray"> <rect x="190" y="190" width="300" height="40" rx="8" stroke-width="0.5"/> <text class="ts" x="340" y="210" text-anchor="middle" dominant-baseline="central">Both layers cooperate on disk-backed reads</text> </g> </svg>

### Hardware Sizing by Node Role

**Key Points**

- Dedicated master nodes handle cluster state and coordination and typically need less CPU, RAM, and disk than data nodes, since they don't hold shard data or serve search/index requests directly.
- Data nodes carry the bulk of hardware requirements, since they hold shard data and perform indexing and search work directly.
- Hot-tier data nodes (actively indexing, recent data) benefit most from SSDs and higher CPU/RAM allocations.
- Cold or frozen-tier data nodes, holding older, less-frequently-queried data, can generally use denser and cheaper storage since query latency requirements are typically lower for older data.
- Ingest nodes or nodes performing heavy ingest pipeline processing benefit from additional CPU allocation for pipeline processor execution.

### Related Topics

- **Node roles** (master, data, ingest, coordinating, ML) and how hardware needs differ across them
- **ILM hot-warm-cold-frozen architecture** and matching hardware tiers to data temperature
- **Translog settings** (`index.translog.durability`, `sync_interval`) and their interaction with disk write patterns
- **Searchable snapshots** and the reduced hardware footprint of the frozen tier
- **G1GC vs other garbage collectors** and JVM tuning beyond heap size alone
- **Disk watermark settings** (`cluster.routing.allocation.disk.watermark.*`) and their role in preventing disk exhaustion


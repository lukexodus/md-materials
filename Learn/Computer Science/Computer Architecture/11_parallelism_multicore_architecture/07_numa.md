## NUMA


Non-Uniform Memory Access describes a memory architecture in which access latency and bandwidth to physical memory depend on which processor is making the request and which memory bank is being addressed. It is the dominant memory topology in contemporary multiprocessor servers and is increasingly relevant even in single-socket designs with integrated I/O dies.

---

### Why NUMA Exists

In a Uniform Memory Access (UMA) system, all processors share a single memory bus and a single pool of DRAM. Every processor sees identical latency to every address. This model scales poorly: the shared bus becomes a bandwidth bottleneck as processor count grows, and the interconnect complexity required to provide uniform latency rises superlinearly.

NUMA resolves this by partitioning memory: each processor (or group of processors) is paired with a local memory bank attached directly to it. Access to local memory is fast; access to a remote node's memory must traverse an inter-node interconnect and incurs additional latency. The trade-off is explicit non-uniformity in exchange for scalable aggregate bandwidth.

The first widely deployed NUMA interconnect was the HyperTransport-based topology in AMD Opteron (2003). Intel adopted a point-to-point interconnect called QPI (QuickPath Interconnect, later UPI — UltraPath Interconnect) in the Nehalem architecture (2008), replacing the Front-Side Bus.

---

### NUMA Topology

A NUMA system is partitioned into **nodes**. Each node comprises:

- one or more processor sockets (or dies)
- a directly attached memory controller
- a local DRAM bank
- an interconnect port to other nodes

The diagram below shows a canonical two-node NUMA configuration.**NUMA distance** is the key metric. It is typically expressed as a dimensionless integer in the ACPI SLIT (System Locality Information Table), where 10 represents local access and higher values represent increasing hop counts. On a typical two-socket Intel system, local distance is 10 and remote is 21. On four-socket or eight-socket systems with ring or mesh interconnect topologies, remote distances vary by path length — a node may have a "near-remote" at distance 21 and a "far-remote" at distance 31 or more.

The SLIT is exposed to the OS at boot via ACPI and is queried by the kernel's NUMA subsystem to make placement decisions.

---

### Memory Access Latency and Bandwidth

Concrete numbers [Inference — representative, not a fixed hardware specification; actual values vary by platform and configuration]:

|Access type|Approximate latency|Bandwidth relative to local|
|---|---|---|
|Local DRAM|~70–80 ns|1×|
|Remote DRAM (1 hop, QPI/UPI)|~130–160 ns|~0.5–0.7×|
|Remote DRAM (2 hops)|~200–240 ns|~0.3–0.5×|

The latency penalty arises from: interconnect serialization delay, protocol overhead (request, snoop, response, data phases), and additional queuing at the remote memory controller.

Bandwidth degradation is more severe than latency degradation under load because the inter-node link is shared among all cores on both sockets that happen to access remote memory simultaneously.

---

### Cache Coherence in NUMA

NUMA does not change the cache coherence requirement — every core must still observe a consistent view of memory — but it makes coherence more expensive. In SMP (Uniform Memory Access) systems, all caches are typically connected to a single coherence fabric. In NUMA, a snoop for a cache line modified on the remote socket must traverse the inter-node interconnect.

Two primary coherence strategies are used in NUMA-aware processors:

**Directory-based coherence**: A directory entry per cache line (stored at the home node — the node that owns that physical address) tracks which remote caches hold copies. On a write, the directory invalidates all sharers before granting ownership. This avoids broadcasting snoops across all nodes; only relevant nodes are contacted. Intel's QPI/UPI uses a distributed directory protocol.

**Snoop-based coherence**: Each coherence transaction is broadcast to all nodes. Simpler but does not scale beyond 4–8 sockets because interconnect traffic grows with node count. AMD's HyperTransport-based systems used a variant of this (probe filtering was added in later generations to reduce broadcast traffic).

The MOESI protocol (Modified, Owned, Exclusive, Shared, Invalid) is commonly used; the Owned state is particularly important in NUMA because it allows a node to supply a cache line directly to a requesting node without first writing back to the home node's DRAM, reducing latency on the remote-hit path.

---

### NUMA-Aware OS Policies

The operating system is the primary agent for NUMA optimization. Key mechanisms:

**Node-local allocation (first-touch policy)**: Linux's default. Physical pages are allocated from the NUMA node on which the faulting thread is currently executing. The first thread to touch (write-fault) a page determines where that page lives. Implication: if initialization is done on node 0 but computation runs on node 1, all data sits remote.

**Memory policies (Linux `mbind` / `set_mempolicy`)**:

- `MPOL_BIND` — restrict allocation to a specified set of nodes
- `MPOL_PREFERRED` — prefer a node but fall back to others if full
- `MPOL_INTERLEAVE` — round-robin across nodes; trades peak local bandwidth for reduced variance, useful for workloads with unpredictable access patterns
- `MPOL_LOCAL` — always allocate on the node where the calling thread executes

**CPU affinity and NUMA pinning**: `numactl --cpunodebind=0 --membind=0` binds a process's threads to node 0's CPUs and restricts memory allocation to node 0's DRAM. This is the standard deployment pattern for latency-sensitive workloads.

**Automatic NUMA balancing (Linux `AutoNUMA`)**: Periodically unmaps pages and re-faults them, tracking which CPU accessed which page. Pages migrate toward the node where they are most frequently accessed. This is a heuristic and incurs overhead — it can be disabled for workloads with well-understood access patterns.

**Transparent huge pages and NUMA**: THP (2 MB huge pages) interact poorly with NUMA migration because migrating a 2 MB page is more expensive than migrating a 4 KB base page. Some deployments disable THP specifically to allow finer-grained NUMA page migration.

---

### NUMA Topology Variants

**Two-socket flat NUMA**: The canonical case. Two nodes, one interconnect hop between any two nodes.

**Four-socket / eight-socket multi-hop**: Common in high-end server configurations. With four sockets in a fully-connected topology, every pair of nodes is one hop apart. With four sockets in a ring topology, some pairs are two hops apart. With eight sockets, two-hop paths are unavoidable regardless of topology.

**Sub-NUMA clustering (SNC) / Cluster-on-Die (CoD)**: A single physical socket is divided into two or more NUMA nodes, each covering a subset of cores and the memory channels attached to that half of the die. On a 28-core Intel Xeon with two memory channel groups of six channels each, SNC-2 presents the OS with two nodes of 14 cores each. Local access is faster because fewer cores share each memory controller; cross-cluster access incurs an intra-socket hop that is cheaper than a full socket-to-socket hop. SNC-4 is also available on some Sapphire Rapids configurations, presenting four nodes per socket.

**AMD EPYC (chiplet-based NUMA)**: AMD's EPYC processors use a chiplet architecture — multiple Core Complex Dies (CCDs) connected to a central I/O die. Each CCD contains cores and L3 cache. Memory controllers live on the I/O die. Within a socket, all cores share access to all DRAM through the I/O die, but cache-to-cache latency varies by CCD placement. In NPS-4 mode (NUMA Per Socket = 4), a single EPYC socket presents four NUMA nodes, each corresponding to a subset of CCDs and a quadrant of the memory controllers. This exposes finer-grained locality to the OS.

```
NPS modes on EPYC (Genoa, for example):
  NPS1 — entire socket = 1 NUMA node  (uniform within socket, simpler)
  NPS2 — socket = 2 NUMA nodes
  NPS4 — socket = 4 NUMA nodes        (maximum local bandwidth exploitation)
```

The choice of NPS mode is a BIOS/firmware setting and is a significant tuning decision: higher NPS exposes more locality but requires the OS and application to be NUMA-aware to benefit.

---

### NUMA and I/O Devices

PCIe devices (NICs, NVMe controllers, GPUs) are physically attached to one NUMA node's PCIe root complex. DMA transfers between a device and memory are cheapest when the memory target is local to the device's node. Accessing memory on the remote node adds interconnect traversal to every DMA operation.

`/sys/bus/pci/devices/<BDF>/numa_node` reports the NUMA affinity of a PCI device. DPDK (Data Plane Development Kit), storage stacks (Seastar, SPDK), and ML frameworks (PyTorch) all implement NUMA-aware buffer allocation that co-locates DMA buffers with the device's local node.

GPU-NUMA is a distinct consideration: on systems where GPUs are connected via PCIe, GPU device memory is not part of any NUMA node's DRAM. On NVLink or CXL-attached systems, GPU memory may be presented as a separate NUMA node (heterogeneous memory), addressable by the CPU with very high latency.

---

### Diagnosing NUMA Behavior

**`numactl --hardware`**: Reports node count, CPU assignment, memory per node, and the NUMA distance matrix.

**`numastat`**: Per-node memory statistics including `numa_hit` (allocations satisfied locally), `numa_miss` (allocations that fell back to a remote node), and `numa_foreign` (allocations requested by a remote node but satisfied here).

**`perf stat -e cpu/offcore_response.*/`**: Hardware performance counter events for off-core (remote) memory accesses. Intel provides `offcore_response` events; AMD provides analogous uncore events. These expose the fraction of LLC misses serviced from remote nodes versus local DRAM.

**`/proc/buddyinfo`** and **`/proc/zoneinfo`**: Per-node free memory distribution. Useful for diagnosing memory pressure on one node while another has slack.

**Key Points**:

- A process that is NUMA-pinned but allocates from the wrong node (e.g., due to first-touch on the wrong thread) can see 2× or greater memory latency relative to local.
- Memory interleaving (`MPOL_INTERLEAVE`) reduces worst-case latency variance at the cost of peak local bandwidth — appropriate for latency-insensitive throughput workloads, inappropriate for low-tail-latency services.
- On EPYC systems, NPS mode selection has larger impact than OS-level policy tuning in many cases, because it determines the granularity at which the hardware itself exposes locality.
- `numastat -p <pid>` shows per-process NUMA allocation distribution and is the first diagnostic tool when a process exhibits unexpectedly high memory latency.

**Conclusion**: NUMA is not an optimization — it is the base hardware reality of every modern multi-socket and many single-socket server systems. Software that ignores NUMA topology incurs remote-access penalties silently; software that exploits it through explicit binding, first-touch discipline, and NUMA-aware allocation recovers that latency and bandwidth. The kernel, runtime, and application all participate in correct NUMA usage, and failures at any layer compound.

---


## Module 1: Distributed Training Fundamentals


### 1.1 Motivation & Core Concepts

- Scaling limitations of single-device training
- Memory vs compute bottlenecks
- Communication overhead fundamentals
- Bandwidth and latency considerations
- Amdahl's Law and parallel efficiency
- Strong vs weak scaling

### 1.2 Distributed System Architecture

- CPU-GPU communication patterns
- PCIe topology and bandwidth
- NVLink and NVSwitch technology
- InfiniBand networking fundamentals
- Network topology (ring, tree, mesh)
- RDMA (Remote Direct Memory Access)

### 1.3 Communication Primitives

- Point-to-point operations
- Collective operations overview
- Broadcast patterns
- Reduce and AllReduce
- Gather and AllGather
- Scatter and ReduceScatter
- All-to-All communication

### 1.4 Parallelism Strategy Selection

- Model size vs memory constraints
- Batch size vs convergence considerations
- Communication-computation overlap
- Hardware configuration analysis
- Workload characterization
- Decision trees for strategy selection

---


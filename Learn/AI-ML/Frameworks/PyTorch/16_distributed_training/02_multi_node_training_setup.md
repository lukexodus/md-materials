## Multi-Node Training Setup


**Process Group Initialization** Multi-node training requires coordinated process group setup using `torch.distributed.init_process_group()`. Each process must know its rank (global process ID), world size (total processes), and master node address for coordination.

**Backend Selection** PyTorch supports multiple communication backends: NCCL for GPU-to-GPU communication (recommended for CUDA), Gloo for CPU operations and mixed CPU/GPU setups, and MPI for HPC environments with existing MPI infrastructure.

**Environment Variable Configuration** Key environment variables include `MASTER_ADDR` (master node IP), `MASTER_PORT` (coordination port), `RANK` (process rank), `WORLD_SIZE` (total processes), and `LOCAL_RANK` (local GPU ID within each node).

**Launcher Scripts and Process Management** Tools like `torchrun` (formerly `torch.distributed.launch`) simplify multi-node job submission by automatically setting environment variables and managing process lifecycle. SLURM, Kubernetes, and other job schedulers provide additional orchestration capabilities.

**Network Configuration Requirements** Multi-node training requires high-bandwidth, low-latency interconnects between nodes. InfiniBand, high-speed Ethernet, or cloud-specific networking (AWS EFA, Google GPUDirect) optimize inter-node communication performance.

**Storage and Data Loading Considerations** Distributed file systems or shared storage ensure all nodes access identical datasets. Data loading must be coordinated to prevent duplicate sampling across processes, typically using `DistributedSampler` for proper data partitioning.

**Node Heterogeneity Handling** [Inference] Multi-node setups may encounter hardware heterogeneity (different GPU types, network speeds, or compute capabilities), requiring careful load balancing and potentially different batch sizes per node to maintain synchronized training.


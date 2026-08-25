## Module 7: Multi-GPU Training (Single Node)


### 7.1 Single-Node Architecture

- GPU topology mapping
- PCIe vs NVLink bandwidth
- GPU affinity configuration
- NUMA node awareness
- CPU pinning strategies
- Memory allocation patterns

### 7.2 NCCL (NVIDIA Collective Communications Library)

- NCCL architecture overview
- Ring algorithm implementation
- Tree algorithm for small messages
- NCCL environment variables
- Topology detection
- Performance tuning
- Debugging NCCL issues

### 7.3 PyTorch Multi-GPU Setup

- CUDA device management
- torch.distributed initialization
- Backend selection (NCCL, Gloo)
- Process spawning strategies
- DDP with multiple GPUs
- Model placement patterns
- Gradient synchronization

### 7.4 TensorFlow Multi-GPU Setup

- GPU visibility configuration
- MirroredStrategy setup
- Memory growth settings
- Device placement verification
- Performance optimization
- Multi-GPU debugging

### 7.5 Data Loading for Multi-GPU

- DistributedSampler usage
- Balanced data distribution
- Shuffle strategies
- Worker process configuration
- Prefetching optimization
- Pin memory considerations

### 7.6 Synchronization and Communication

- Barrier synchronization
- Gradient AllReduce
- Broadcast parameters
- Communication overlap
- Bucketing strategies
- Profiling communication

### 7.7 Memory Optimization

- Gradient checkpointing
- Activation memory management
- Mixed precision integration
- ZeRO optimizer stages
- Offloading strategies
- Memory fragmentation

### 7.8 Performance Tuning

- Batch size selection
- Communication frequency
- Computation-communication overlap
- Kernel fusion
- CUDA graph capture
- Profiling and bottleneck analysis

---


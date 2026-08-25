## Module 4: Pipeline Parallelism


### 4.1 Pipeline Parallelism Fundamentals

- Micro-batch concept
- Pipeline stages and partitions
- Forward and backward scheduling
- Bubble time analysis
- Flush vs non-flush pipelines
- Memory-compute tradeoffs

### 4.2 Pipeline Scheduling Strategies

- GPipe: Synchronous pipeline
- PipeDream: Asynchronous pipeline
- PipeDream-2BW optimization
- Interleaved pipeline schedules
- 1F1B (One-Forward-One-Backward)
- Breadth-first vs depth-first

### 4.3 PyTorch Pipeline Parallelism

- torch.distributed.pipeline
- GPipe implementation
- Manual pipeline construction
- Fairscale pipeline library
- DeepSpeed pipeline engine
- PiPPy (PyTorch native pipelines)
- Checkpoint-wrapped pipelines

### 4.4 TensorFlow Pipeline Parallelism

- Keras layer-based pipelines
- Custom pipeline implementations
- Lingvo pipeline support
- Mesh TensorFlow pipelines
- XLA pipeline fusion

### 4.5 GPipe Architecture

- Synchronous gradient accumulation
- Re-materialization (activation checkpointing)
- Micro-batch size selection
- Memory efficiency analysis
- Convergence characteristics
- Implementation details

### 4.6 PipeDream Architecture

- Weight version management
- Weight stashing strategy
- Asynchronous gradient application
- Pipeline stage assignment
- Profiling-based optimization
- Memory footprint analysis

### 4.7 Advanced Pipeline Techniques

- Interleaved scheduling (Megatron)
- Virtual pipeline stages
- Pipeline bubble reduction
- Dynamic micro-batch sizing
- Adaptive pipeline depth
- Hybrid pipeline-tensor parallelism

---


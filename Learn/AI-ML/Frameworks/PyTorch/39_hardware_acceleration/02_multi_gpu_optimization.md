## Multi-GPU Optimization


**Data Parallel Training**

`torch.nn.DataParallel` provides basic multi-GPU training by replicating models across devices and splitting batches. However, this approach has limitations including single-threaded data loading and gradient synchronization bottlenecks.

```python
model = nn.DataParallel(model, device_ids=[0, 1, 2, 3])
model.to(device)

# Training loop with automatic gradient synchronization
for batch in dataloader:
    optimizer.zero_grad()
    outputs = model(batch)
    loss = criterion(outputs, targets)
    loss.backward()  # Gradients automatically synchronized
    optimizer.step()
```

**Distributed Data Parallel**

`torch.nn.parallel.DistributedDataParallel` provides more efficient multi-GPU training with better scalability characteristics. DDP uses separate processes for each GPU and implements optimized gradient reduction algorithms.

```python
# Initialize distributed training
dist.init_process_group(backend='nccl', world_size=world_size, rank=rank)
torch.cuda.set_device(local_rank)

model = DistributedDataParallel(model, device_ids=[local_rank])
sampler = DistributedSampler(dataset, num_replicas=world_size, rank=rank)
```

**Model Parallel Strategies**

Large models that exceed single GPU memory require model parallelism techniques including layer-wise partitioning, pipeline parallelism, and tensor parallelism. Implementation complexity increases significantly with model parallel approaches.

**Communication Optimization**

Multi-GPU training performance depends heavily on inter-device communication efficiency. Optimization techniques include gradient compression, communication scheduling, and bandwidth-aware device placement.


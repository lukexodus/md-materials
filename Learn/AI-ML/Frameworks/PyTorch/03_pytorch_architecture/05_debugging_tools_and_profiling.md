## Debugging Tools and Profiling


**Native Python Debugging**

PyTorch's eager execution paradigm enables standard Python debugging techniques:

```python
import pdb

def forward(self, x):
    x = self.layer1(x)
    pdb.set_trace()  # Debugger breakpoint
    x = self.layer2(x)
    return x
```

**Gradient Debugging**

Common gradient-related issues can be debugged using built-in utilities:

```python
# Check for NaN gradients
def check_gradients(model):
    for name, param in model.named_parameters():
        if param.grad is not None:
            if torch.isnan(param.grad).any():
                print(f"NaN gradient detected in {name}")

# Gradient clipping for exploding gradients
torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
```

**Anomaly Detection**

PyTorch provides anomaly detection for automatic differentiation:

```python
# Enable anomaly detection
with torch.autograd.set_detect_anomaly(True):
    output = model(input)
    loss = criterion(output, target)
    loss.backward()  # Will raise error if anomaly detected
```

**Performance Profiling**

The PyTorch profiler provides comprehensive performance analysis:

```python
from torch.profiler import profile, record_function, ProfilerActivity

with profile(
    activities=[ProfilerActivity.CPU, ProfilerActivity.CUDA],
    schedule=torch.profiler.schedule(skip_first=10, wait=5, warmup=1, active=3, repeat=2),
    on_trace_ready=torch.profiler.tensorboard_trace_handler('./log/profiler'),
    record_shapes=True,
    profile_memory=True,
    with_stack=True
) as prof:
    for step, batch_data in enumerate(dataloader):
        output = model(batch_data)
        loss = criterion(output, targets)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        prof.step()  # Need to call this at each step
```

**TensorBoard Integration**

PyTorch integrates with TensorBoard for visualization and monitoring:

```python
from torch.utils.tensorboard import SummaryWriter

writer = SummaryWriter('runs/experiment_1')

for epoch in range(num_epochs):
    for i, (images, labels) in enumerate(dataloader):
        # Training code here
        writer.add_scalar('Loss/Train', loss, epoch * len(dataloader) + i)
        
        # Log model graph (once)
        if epoch == 0 and i == 0:
            writer.add_graph(model, images)

writer.close()
```

**Model Visualization**

Several tools help visualize model architecture and computation graphs:

```python
# Print model structure
print(model)

# Detailed parameter information
from torchsummary import summary
summary(model, (3, 224, 224))  # For image input of size 224x224x3

# Visualize computation graph [Unverified - requires external tools]
# Various third-party tools available for graph visualization
```

**Debugging Best Practices**

Effective debugging in PyTorch involves systematic approaches:

- **Start Simple**: Begin with small models and datasets to isolate issues
- **Validate Data**: Ensure data loading and preprocessing work correctly
- **Check Shapes**: Verify tensor dimensions at each step
- **Monitor Gradients**: Watch for vanishing or exploding gradients
- **Use Assertions**: Add shape and value assertions throughout code

**Key Points:**

- Standard Python debugging tools work naturally with PyTorch's eager execution
- Gradient debugging utilities help identify common training issues
- The PyTorch profiler provides detailed performance analysis capabilities
- TensorBoard integration enables comprehensive training monitoring


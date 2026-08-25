## TorchScript Compilation


TorchScript serves as PyTorch's production-ready representation that enables deployment independent of Python runtime dependencies. It creates a serializable and optimizable intermediate representation of PyTorch models.

**Key Points**

- TorchScript supports two primary conversion methods: tracing and scripting
- Tracing records operations during example execution, while scripting directly converts Python code
- The resulting models can run in C++ environments without Python overhead
- TorchScript preserves model semantics while enabling aggressive optimizations

**Tracing Approach**

```python
import torch

model = MyModel()
example_input = torch.randn(1, 3, 224, 224)
traced_script_module = torch.jit.trace(model, example_input)
traced_script_module.save("model.pt")
```

**Scripting Approach**

```python
scripted_model = torch.jit.script(model)
scripted_model.save("scripted_model.pt")
```

**Limitations and Considerations**

- Tracing cannot capture dynamic control flow accurately
- Scripting requires TorchScript-compatible Python subset
- Data-dependent operations may require manual annotation
- [Inference] Complex models may need hybrid approaches combining both methods


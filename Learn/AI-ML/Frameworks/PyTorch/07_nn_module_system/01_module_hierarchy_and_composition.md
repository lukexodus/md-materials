## Module Hierarchy and Composition


PyTorch's module system operates on a tree-like hierarchy where modules can contain other modules as children, creating complex neural network architectures through composition.

**Key points:**

- Every neural network component inherits from nn.Module base class
- Modules automatically track their children when assigned as attributes
- The module tree structure mirrors the computational graph during forward pass
- Parent modules can access and manipulate child modules recursively

**Module registration mechanisms:** When you assign a module to an instance attribute, PyTorch automatically registers it as a child module. This registration enables automatic parameter discovery, device movement, and serialization.

```python
class ConvBlock(nn.Module):
    def __init__(self, in_channels, out_channels):
        super().__init__()
        self.conv = nn.Conv2d(in_channels, out_channels, 3, padding=1)  # Auto-registered
        self.bn = nn.BatchNorm2d(out_channels)  # Auto-registered
        self.relu = nn.ReLU(inplace=True)  # Auto-registered
```

**ModuleList and ModuleDict:** For dynamic module collections, PyTorch provides specialized containers that maintain proper registration:

- `nn.ModuleList`: Ordered collection similar to Python lists
- `nn.ModuleDict`: Key-value collection similar to Python dictionaries
- Both ensure contained modules are properly registered and discoverable

**Nested composition patterns:** Complex architectures emerge from composing simple modules. ResNet blocks, transformer layers, and attention mechanisms all follow this compositional approach, where each level of the hierarchy encapsulates specific functionality while exposing a clean interface to parent modules.


## State Management and Modes


nn.Module maintains internal state that affects computation behavior, particularly the distinction between training and evaluation modes.

**Training vs evaluation modes:**

- `module.train()`: Enables training mode, affecting dropout, batch normalization, and other layers
- `module.eval()`: Switches to evaluation mode, disabling dropout and using running statistics for normalization
- Mode propagates to all child modules automatically

**State-dependent layer behavior:** Different layers respond to training mode in specific ways:

- Dropout: Active during training, disabled during evaluation
- BatchNorm: Updates running statistics during training, uses fixed statistics during evaluation
- Custom layers can implement mode-specific behavior by checking `self.training`

**Gradient requirements:**

- `requires_grad_(True/False)`: Controls whether parameters accumulate gradients
- Useful for freezing parts of pre-trained networks
- Can be applied selectively to specific parameters or entire modules

**Device and dtype management:**

- `module.to(device)`: Moves all parameters and buffers to specified device
- `module.half()`, `module.float()`: Converts parameter precision
- State changes propagate throughout the module hierarchy

**Custom state tracking:** Modules can maintain additional state through registered buffers, which are non-learnable tensors that should be saved/loaded with the model but don't participate in gradient updates.


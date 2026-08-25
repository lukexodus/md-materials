## Module 3: Activation Functions


### 3.1 Role and Purpose

- Non-linearity introduction
- Gradient flow importance
- Output range constraints
- Biological plausibility

### 3.2 Classical Activation Functions

- Sigmoid (logistic)
    - Mathematical form
    - Output range [0,1]
    - Vanishing gradient problem
    - Use cases (output layers, gates)
- Hyperbolic tangent (tanh)
    - Mathematical form
    - Output range [-1,1]
    - Zero-centered outputs
    - Comparison with sigmoid

### 3.3 Modern Activation Functions

- ReLU (Rectified Linear Unit)
    - Mathematical simplicity
    - Computational efficiency
    - Dead neuron problem
    - Sparsity properties
- Leaky ReLU and variants
    - Parametric ReLU (PReLU)
    - Exponential Linear Unit (ELU)
    - Scaled ELU (SELU)
- Swish and GELU
    - Smooth non-linearities
    - Self-gating mechanisms
    - Performance in deep networks

### 3.4 Specialized Activations

- Softmax for multi-class classification
- Softplus as smooth ReLU approximation
- Maxout networks
- Adaptive activations

### 3.5 Selection Criteria

- Task-dependent choices
- Layer position considerations
- Gradient flow characteristics
- Computational cost tradeoffs

---


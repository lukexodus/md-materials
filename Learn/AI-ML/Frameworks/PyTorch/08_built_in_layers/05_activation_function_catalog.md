## Activation Function Catalog


**ReLU and Variants**

- ReLU: Standard rectified linear unit
- LeakyReLU: Allows small negative slope to prevent dying neurons
- PReLU: Learnable negative slope parameter
- ReLU6: Capped at 6 for quantization-friendly networks
- ELU: Exponential linear unit with smooth negative values

**Sigmoid Functions**

- Sigmoid: Standard logistic function for binary classification
- Tanh: Hyperbolic tangent with zero-centered output
- Hardsigmoid: Piecewise linear approximation for efficiency

**Modern Activations**

- GELU: Gaussian Error Linear Unit, probabilistic activation
- Swish/SiLU: Self-gated activation (x * sigmoid(x))
- Mish: Self-regularized non-monotonic activation
- Hardswish: Hardware-efficient approximation of Swish

**Specialized Activations**

- Softmax: Converts logits to probability distribution
- LogSoftmax: Numerically stable log-probabilities
- Softplus: Smooth approximation of ReLU
- Softsign: Alternative to tanh with gentler saturation


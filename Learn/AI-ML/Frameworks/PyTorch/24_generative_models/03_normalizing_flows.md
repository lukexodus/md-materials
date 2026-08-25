## Normalizing Flows


Normalizing flows construct complex probability distributions by applying a sequence of invertible transformations to simple base distributions. This approach enables exact likelihood computation and efficient sampling while maintaining tractable density evaluation.

Flow-based models transform samples from a simple distribution (typically Gaussian) through a series of bijective functions, with each transformation preserving probability mass through the change of variables formula. The Jacobian determinant of each transformation accounts for volume changes during the mapping process.

### Architecture Components

**Coupling Layers** split input dimensions into two groups, applying affine transformations to one group conditioned on the other group. Real NVP (Non-Volume Preserving) introduced this architecture, enabling efficient computation of Jacobian determinants.

**Autoregressive Flows** use masked architectures to ensure causality, with each output dimension depending only on previous dimensions. Masked Autoregressive Flows (MAF) and Inverse Autoregressive Flows (IAF) represent prominent examples of this approach.

**Neural Spline Flows** replace affine transformations with rational-quadratic splines, providing more flexible transformations while maintaining computational efficiency and invertibility constraints.

### Implementation Considerations

Flow models require careful design to balance expressivity and computational efficiency. The number of coupling layers, dimension splitting strategies, and conditioning network architectures significantly impact model performance.

```python
class AffineCouplingLayer(nn.Module):
    def __init__(self, dim, hidden_dim, mask):
        super().__init__()
        self.mask = mask
        self.scale_translate_net = nn.Sequential(
            nn.Linear(dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, 2 * dim)
        )
    
    def forward(self, x):
        masked_x = x * self.mask
        scale_translate = self.scale_translate_net(masked_x)
        scale, translate = scale_translate.chunk(2, dim=1)
        
        ## Ensure positive scaling
        scale = torch.sigmoid(scale + 2.0)
        
        y = x * scale + translate * (1 - self.mask)
        log_det = torch.sum(torch.log(scale) * (1 - self.mask), dim=1)
        
        return y, log_det
```

**Key Points:**

- Normalizing flows enable exact likelihood computation unlike GANs and VAEs
- Training requires careful initialization and gradient flow management through multiple transformations
- Applications include density modeling, variational inference, and probabilistic programming


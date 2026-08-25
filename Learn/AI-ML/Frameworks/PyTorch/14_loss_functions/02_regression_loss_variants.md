## Regression Loss Variants


Regression losses quantify prediction errors for continuous targets, with different formulations exhibiting varying sensitivities to outliers and error magnitudes.

**Standard Regression Losses:**

_Mean Squared Error (MSE):_

- `nn.MSELoss`: L2 loss penalizing squared prediction errors
- High sensitivity to outliers due to quadratic penalty
- Smooth gradients facilitating stable optimization
- Assumes Gaussian noise in target variables

_Mean Absolute Error (MAE):_

- `nn.L1Loss`: L1 loss with linear penalty for prediction errors
- Robust to outliers compared to MSE
- Non-smooth gradients at zero can cause optimization challenges
- Assumes Laplacian noise distribution in targets

_Smooth L1 Loss:_

- `nn.SmoothL1Loss`: Combines L1 and L2 properties
- Quadratic for small errors, linear for large errors
- Balances outlier robustness with smooth optimization
- Widely used in object detection for bounding box regression

**Specialized Regression Formulations:**

_Huber Loss:_

- Robust loss combining MSE and MAE benefits
- Delta parameter controls transition between quadratic and linear regions
- Provides outlier robustness while maintaining smooth gradients near zero
- Optimal for scenarios with mixed noise characteristics

_Quantile Loss:_

- Enables prediction of specific quantiles rather than mean values
- Asymmetric penalty based on over- and under-prediction
- Useful for uncertainty quantification and risk-sensitive applications
- Multiple quantiles can be predicted simultaneously

_Log-Cosh Loss:_

- Smooth approximation of MAE with twice-differentiable properties
- Combines robustness properties of MAE with smoothness of MSE
- Logarithm of hyperbolic cosine provides balanced characteristics
- Effective for scenarios requiring both robustness and optimization stability

```python
class LogCoshLoss(nn.Module):
    def __init__(self):
        super().__init__()
        
    def forward(self, predictions, targets):
        loss = torch.log(torch.cosh(predictions - targets))
        return loss.mean()
```


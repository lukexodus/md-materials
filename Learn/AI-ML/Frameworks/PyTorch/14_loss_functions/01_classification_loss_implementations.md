## Classification Loss Implementations


Classification losses quantify prediction errors for discrete category assignments, with different formulations addressing specific challenges like class imbalance, confidence calibration, and multi-label scenarios.

**Fundamental Classification Losses:**

_Cross-Entropy Loss:_

- `nn.CrossEntropyLoss`: Combines LogSoftmax and NLLLoss for multi-class classification
- Penalizes confident wrong predictions more heavily than uncertain ones
- Built-in class weighting for handling imbalanced datasets
- Temperature scaling parameter for confidence calibration
- Supports label smoothing to prevent overconfident predictions

_Binary Cross-Entropy:_

- `nn.BCELoss`: Standard binary classification loss
- `nn.BCEWithLogitsLoss`: Numerically stable version combining sigmoid and BCE
- Pos_weight parameter for handling class imbalance in binary scenarios
- Multi-label classification support through independent binary decisions

_Negative Log-Likelihood:_

- `nn.NLLLoss`: Assumes log-probabilities as input
- Often used after LogSoftmax activation
- Direct probability interpretation without additional transformations
- Efficient computation when log-probabilities are readily available

**Advanced Classification Formulations:**

_Focal Loss:_

- Addresses class imbalance by down-weighting easy examples
- Focusing parameter α controls class balance, γ controls easy example suppression
- Particularly effective for dense object detection scenarios
- Dynamic loss weighting based on prediction confidence

```python
class FocalLoss(nn.Module):
    def __init__(self, alpha=1, gamma=2):
        super().__init__()
        self.alpha = alpha
        self.gamma = gamma
        
    def forward(self, inputs, targets):
        ce_loss = F.cross_entropy(inputs, targets, reduction='none')
        pt = torch.exp(-ce_loss)
        focal_loss = self.alpha * (1-pt)**self.gamma * ce_loss
        return focal_loss.mean()
```

_Label Smoothing:_

- Distributes probability mass from true label to other classes
- Prevents overconfident predictions and improves calibration
- Regularization effect that often improves generalization
- Implemented through modified target distributions or loss computation

_Dice Loss:_

- Originally designed for segmentation tasks with class imbalance
- Measures overlap between predicted and ground truth sets
- Differentiable approximation of Dice coefficient
- Effective for scenarios where precision and recall balance matters


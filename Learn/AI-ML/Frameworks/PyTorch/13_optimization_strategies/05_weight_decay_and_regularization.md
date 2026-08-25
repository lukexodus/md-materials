## Weight Decay and Regularization


Weight decay and regularization techniques prevent overfitting by constraining parameter magnitudes and encouraging simpler models.

**Key Points:**

- Weight decay adds L2 regularization to the loss function
- Different regularization techniques target different aspects of model complexity
- [Inference] Proper regularization balances model capacity with generalization capability
- Regularization strength typically requires empirical tuning

**L2 Weight Decay:**

```python
# Weight decay through optimizer
optimizer = optim.SGD(
    model.parameters(),
    lr=0.01,
    weight_decay=1e-4  # L2 regularization coefficient
)

# Manual L2 regularization
def l2_regularization(model, lambda_reg=1e-4):
    l2_loss = 0
    for param in model.parameters():
        l2_loss += torch.norm(param, p=2) ** 2
    return lambda_reg * l2_loss

# Training with manual regularization
total_loss = criterion_loss + l2_regularization(model, lambda_reg=1e-4)
```

**Advanced Regularization Techniques:**

```python
# L1 Regularization (Lasso)
def l1_regularization(model, lambda_reg=1e-4):
    l1_loss = 0
    for param in model.parameters():
        l1_loss += torch.norm(param, p=1)
    return lambda_reg * l1_loss

# Elastic Net (L1 + L2)
def elastic_net_regularization(model, l1_lambda=1e-4, l2_lambda=1e-4):
    return l1_regularization(model, l1_lambda) + l2_regularization(model, l2_lambda)

# Group regularization for structured sparsity
def group_lasso_regularization(model, groups, lambda_reg=1e-4):
    group_loss = 0
    for group in groups:
        group_params = [model.get_parameter(name) for name in group]
        group_norm = torch.sqrt(sum(torch.norm(p) ** 2 for p in group_params))
        group_loss += group_norm
    return lambda_reg * group_loss
```

**Dropout and Batch Normalization:** These techniques provide implicit regularization through different mechanisms during training.


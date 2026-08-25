## Transfer Learning with Pretrained Models


Transfer learning leverages pretrained models to accelerate training and improve performance on target tasks with limited data.

**Transfer Learning Strategies:**

_Feature Extraction:_

- Freeze pretrained model weights and train only final classifier layers
- Use pretrained features as fixed feature extractors
- Minimal computational requirements and fast training
- Effective when target dataset is small and similar to pretraining data

_Fine-tuning:_

- Initialize with pretrained weights and continue training on target data
- Lower learning rates for pretrained layers to preserve learned features
- Full network adaptation to target domain characteristics
- Balances pretrained knowledge with task-specific learning

_Progressive Fine-tuning:_

- Gradually unfreeze layers starting from the classifier
- Layer-wise learning rate scheduling
- Careful control of adaptation speed across network depth
- Prevents catastrophic forgetting of pretrained features

**Implementation Approaches:**

```python
# Loading pretrained model and modifying classifier
model = torchvision.models.resnet50(pretrained=True)
# Freeze feature extraction layers
for param in model.parameters():
    param.requires_grad = False
# Replace classifier for new task
model.fc = nn.Linear(model.fc.in_features, num_classes)
```

**Domain Adaptation Considerations:**

- Dataset similarity assessment between pretraining and target domains
- Layer selection for freezing based on transferability analysis
- Learning rate scheduling strategies for different network sections
- Regularization techniques to prevent overfitting with small target datasets


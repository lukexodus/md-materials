## Regularization Layer Options


**Dropout** Randomly zeros elements during training to prevent overfitting. Standard dropout for fully connected layers, with configurable probability parameter.

**Dropout2d/3d** Channel-wise dropout for convolutional layers. Zeros entire channels rather than individual elements, maintaining spatial coherence.

**AlphaDropout** Specialized dropout for SELU activations, maintaining self-normalizing properties by preserving mean and variance.

**FeatureAlphaDropout** Channel-wise version of AlphaDropout for convolutional networks with SELU activations.

**Weight Regularization** [Inference] While not separate layers, PyTorch supports L1 and L2 weight regularization through optimizer weight_decay parameters and manual penalty additions to loss functions.

**Key Points:**

- All layers support automatic differentiation and GPU acceleration
- Parameters are automatically registered and included in model.parameters()
- Most layers offer in-place variants for memory efficiency
- Batch processing is optimized across all layer types
- Custom initialization methods available for all parameter-containing layers

**Examples of layer combinations:**

```python
# Typical CNN block
nn.Sequential(
    nn.Conv2d(64, 128, kernel_size=3, padding=1),
    nn.BatchNorm2d(128),
    nn.ReLU(inplace=True),
    nn.Dropout2d(0.2)
)

# Transformer-style block
nn.Sequential(
    nn.Linear(512, 2048),
    nn.GELU(),
    nn.Dropout(0.1),
    nn.Linear(2048, 512),
    nn.LayerNorm(512)
)
```

The comprehensive layer ecosystem enables rapid prototyping and implementation of state-of-the-art architectures while maintaining flexibility for custom modifications and research experimentation.

---


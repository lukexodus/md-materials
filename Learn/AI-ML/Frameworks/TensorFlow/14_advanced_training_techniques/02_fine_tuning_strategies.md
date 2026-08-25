## Fine-tuning Strategies


### Systematic Approach

Fine-tuning involves updating pre-trained model weights on target tasks while preserving beneficial learned representations. Success depends on careful selection of layers to update, learning rates, and training procedures.

**Gradual Unfreezing**: Starts with frozen pre-trained layers, then progressively unfreezes layers from top to bottom, allowing gradual adaptation while preserving low-level features.

**Discriminative Learning Rates**: Applies different learning rates to different layers, typically using lower rates for earlier layers that contain more general features.

**Cyclical Learning Rates**: Varies learning rate during training to escape local minima and improve convergence properties.

### Layer Selection Strategies

**Top-layer Fine-tuning**: Updates only classification layers, suitable for similar domains with limited data.

**Partial Fine-tuning**: Unfreezes specific layer groups based on task requirements and available data quantity.

**Full Fine-tuning**: Updates entire network with careful learning rate scheduling, appropriate for large target datasets.

### TensorFlow Implementation

```python
# Gradual unfreezing strategy
def gradual_unfreezing(model, unfreeze_schedule):
    """
    unfreeze_schedule: dict mapping epoch to number of layers to unfreeze
    """
    class UnfreezeCallback(tf.keras.callbacks.Callback):
        def __init__(self, model, schedule):
            self.model = model
            self.schedule = schedule
            
        def on_epoch_begin(self, epoch, logs=None):
            if epoch in self.schedule:
                layers_to_unfreeze = self.schedule[epoch]
                for layer in self.model.layers[-layers_to_unfreeze:]:
                    layer.trainable = True
                
                # Recompile with new learning rate
                self.model.compile(
                    optimizer=tf.keras.optimizers.Adam(lr=1e-5),
                    loss='categorical_crossentropy',
                    metrics=['accuracy']
                )
    
    return UnfreezeCallback(model, unfreeze_schedule)

# Discriminative learning rates
def apply_discriminative_lr(model, base_lr=1e-3, decay_factor=0.5):
    layer_lrs = {}
    num_layers = len(model.layers)
    
    for i, layer in enumerate(model.layers):
        # Earlier layers get lower learning rates
        lr_multiplier = decay_factor ** (num_layers - i - 1)
        layer_lrs[layer.name] = base_lr * lr_multiplier
    
    return layer_lrs
```


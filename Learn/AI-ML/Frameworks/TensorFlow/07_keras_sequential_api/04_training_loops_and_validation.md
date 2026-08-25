## Training Loops and Validation


Model training involves iterative parameter optimization through forward and backward propagation cycles.

**Basic Training** The fit method handles the complete training process:

```python
# Simple training
history = model.fit(
    x_train, y_train,
    epochs=100,
    batch_size=32,
    validation_data=(x_val, y_val)
)

# Training with validation split
history = model.fit(
    x_train, y_train,
    epochs=50,
    batch_size=64,
    validation_split=0.2,  # Use 20% of training data for validation
    verbose=1              # Progress bar display
)
```

**Advanced Training Configuration** Additional parameters control training behavior:

```python
# Comprehensive training setup
history = model.fit(
    x_train, y_train,
    epochs=100,
    batch_size=32,
    validation_data=(x_val, y_val),
    shuffle=True,           # Shuffle training data each epoch
    class_weight={0: 1.0, 1: 2.0},  # Handle class imbalance
    sample_weight=sample_weights,    # Per-sample weights
    initial_epoch=0,        # Starting epoch (for resuming training)
    steps_per_epoch=None,   # Auto-calculate from data size
    validation_steps=None,  # Auto-calculate validation steps
    validation_freq=1,      # Validate every epoch
    max_queue_size=10,      # Data loading queue size
    workers=1,              # Number of parallel workers
    use_multiprocessing=False
)
```

**Callback Integration** Callbacks provide training process control and monitoring:

```python
# Define callbacks
callbacks = [
    tf.keras.callbacks.EarlyStopping(
        monitor='val_loss',
        patience=10,
        restore_best_weights=True
    ),
    tf.keras.callbacks.ReduceLROnPlateau(
        monitor='val_loss',
        factor=0.5,
        patience=5,
        min_lr=1e-7
    ),
    tf.keras.callbacks.ModelCheckpoint(
        'best_model.h5',
        monitor='val_accuracy',
        save_best_only=True
    )
]

history = model.fit(
    x_train, y_train,
    validation_data=(x_val, y_val),
    epochs=100,
    callbacks=callbacks
)
```

**Training History Analysis** Training history contains loss and metric values for analysis:

```python
# Access training history
train_loss = history.history['loss']
val_loss = history.history['val_loss']
train_accuracy = history.history['accuracy']
val_accuracy = history.history['val_accuracy']

# Plot training curves
import matplotlib.pyplot as plt

plt.figure(figsize=(12, 4))
plt.subplot(1, 2, 1)
plt.plot(train_loss, label='Training Loss')
plt.plot(val_loss, label='Validation Loss')
plt.legend()

plt.subplot(1, 2, 2)
plt.plot(train_accuracy, label='Training Accuracy')
plt.plot(val_accuracy, label='Validation Accuracy')
plt.legend()
```


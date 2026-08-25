## Saving and Loading Models


Model persistence enables deployment, sharing, and resuming training from saved states.

**Complete Model Saving** Save entire models including architecture, weights, and compilation configuration:

```python
# Save complete model in HDF5 format
model.save('my_model.h5')

# Save in TensorFlow SavedModel format (recommended)
model.save('my_model')
model.save('my_model.tf', save_format='tf')

# Load complete model
loaded_model = tf.keras.models.load_model('my_model.h5')
loaded_model = tf.keras.models.load_model('my_model')
```

**Weights-Only Saving** Save and load only model weights (requires identical architecture):

```python
# Save weights
model.save_weights('model_weights.h5')
model.save_weights('weights_checkpoint')

# Load weights into existing model
model.load_weights('model_weights.h5')

# Load weights with checkpoint manager
checkpoint = tf.train.Checkpoint(model=model)
checkpoint.save('training_checkpoint')
checkpoint.restore('training_checkpoint-1')
```

**Architecture Serialization** Save model architecture separately from weights:

```python
# Save architecture as JSON
model_json = model.to_json()
with open('model_architecture.json', 'w') as json_file:
    json_file.write(model_json)

# Load architecture and weights separately
with open('model_architecture.json', 'r') as json_file:
    loaded_model_json = json_file.read()

loaded_model = tf.keras.models.model_from_json(loaded_model_json)
loaded_model.load_weights('model_weights.h5')
loaded_model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
```

**Export for Production** Export models for production deployment:

```python
# Export for TensorFlow Serving
model.save('serving_model', save_format='tf')

# Export for TensorFlow Lite (mobile deployment)
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

with open('model.tflite', 'wb') as f:
    f.write(tflite_model)
```

**Custom Object Handling** Handle custom layers and functions during loading:

```python
# Define custom objects for loading
def custom_loss(y_true, y_pred):
    return tf.reduce_mean(tf.square(y_true - y_pred))

custom_objects = {'custom_loss': custom_loss}

# Load model with custom objects
loaded_model = tf.keras.models.load_model(
    'model_with_custom_loss.h5',
    custom_objects=custom_objects
)
```

**Checkpoint Management** Implement systematic checkpoint saving during training:

```python
# Checkpoint callback for automatic saving
checkpoint_callback = tf.keras.callbacks.ModelCheckpoint(
    filepath='training_checkpoint_{epoch:02d}_{val_accuracy:.2f}.h5',
    monitor='val_accuracy',
    save_best_only=True,
    save_weights_only=False,
    mode='max',
    save_freq='epoch'
)

model.fit(
    x_train, y_train,
    validation_data=(x_val, y_val),
    epochs=50,
    callbacks=[checkpoint_callback]
)
```

**Key Points**

- Sequential API enables straightforward linear layer stacking with automatic shape inference after the first layer
- Dense layers with various activation functions form the foundation of most neural architectures
- Model compilation configures optimization parameters including optimizer, loss function, and evaluation metrics
- Training loops support extensive customization through callbacks, validation strategies, and monitoring options
- Model evaluation provides comprehensive performance assessment using built-in and custom metrics
- Saving and loading mechanisms support complete models, weights-only, and architecture serialization for different deployment scenarios

**Related Topics for Further Study** Advanced Sequential API concepts include custom layers and activation functions, transfer learning with pre-trained Sequential models, model subclassing for complex architectures, distributed training strategies, and integration with tf.function for performance optimization.

---


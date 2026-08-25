## Keras Integration in TensorFlow 2.x


**Deep Integration Architecture** Keras is no longer an external library but forms TensorFlow 2.x's primary high-level API. This integration provides seamless interoperability between low-level TensorFlow operations and high-level model building.

**tf.keras vs External Keras**

- tf.keras receives optimizations specific to TensorFlow's backend
- Distribution strategies work natively with tf.keras models
- TensorFlow-specific features (like tf.data integration) are built into tf.keras
- tf.keras follows TensorFlow's versioning rather than independent Keras releases

**Model Building Approaches** **Sequential API**: Linear stack of layers for straightforward architectures **Functional API**: Flexible graph construction for complex architectures with multiple inputs/outputs **Model Subclassing**: Complete control through class inheritance for research and custom architectures

**Training and Inference Integration** tf.keras models integrate directly with TensorFlow's ecosystem:

- **tf.data** pipelines work seamlessly with model.fit()
- **tf.distribute** strategies enable multi-device training
- **tf.saved_model** format preserves complete model graphs
- **tf.lite** conversion maintains tf.keras model structure

**Custom Training Loops** tf.keras provides both high-level (model.fit()) and low-level (GradientTape) training approaches:

```python
# High-level training
model.compile(optimizer='adam', loss='sparse_categorical_crossentropy')
model.fit(train_dataset, epochs=10, validation_data=val_dataset)

# Low-level custom training
optimizer = tf.keras.optimizers.Adam()
for batch in train_dataset:
    with tf.GradientTape() as tape:
        predictions = model(batch['x'])
        loss = loss_fn(batch['y'], predictions)
    gradients = tape.gradient(loss, model.trainable_variables)
    optimizer.apply_gradients(zip(gradients, model.trainable_variables))
```


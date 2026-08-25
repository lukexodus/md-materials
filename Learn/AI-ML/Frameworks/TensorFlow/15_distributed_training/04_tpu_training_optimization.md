## TPU Training Optimization


Tensor Processing Units (TPUs) provide specialized acceleration for machine learning workloads with unique architectural considerations and optimization requirements.

**Key Points:**

- TPUs excel at large matrix operations and high-throughput training
- XLA compilation required for optimal TPU performance
- Static shapes and fixed batch sizes essential for TPU efficiency
- TPU pods enable massive scale distributed training

### TPU Strategy Configuration

```python
# TPU initialization and strategy
resolver = tf.distribute.cluster_resolver.TPUClusterResolver(tpu='grpc://' + os.environ['COLAB_TPU_ADDR'])
tf.config.experimental_connect_to_cluster(resolver)
tf.tpu.experimental.initialize_tpu_system(resolver)

strategy = tf.distribute.TPUStrategy(resolver)

# TPU-optimized model definition
with strategy.scope():
    model = tf.keras.Sequential([
        tf.keras.layers.Embedding(vocab_size, 512, input_length=max_length),
        tf.keras.layers.LSTM(512, return_sequences=True),
        tf.keras.layers.GlobalAveragePooling1D(),
        tf.keras.layers.Dense(256, activation='relu'),
        tf.keras.layers.Dense(num_classes, activation='softmax')
    ])
    
    optimizer = tf.keras.optimizers.Adam(learning_rate=0.001)
    model.compile(optimizer=optimizer, loss='sparse_categorical_crossentropy', metrics=['accuracy'])

# TPU-compatible dataset preparation
def preprocess_fn(features, label):
    # Ensure static shapes for TPU
    features = tf.ensure_shape(features, [max_length])
    label = tf.ensure_shape(label, [])
    return features, label

train_dataset = tf.data.Dataset.from_tensor_slices((x_train, y_train))
train_dataset = train_dataset.map(preprocess_fn, num_parallel_calls=tf.data.AUTOTUNE)
train_dataset = train_dataset.batch(batch_size, drop_remainder=True)  # Drop remainder for static shape
train_dataset = train_dataset.prefetch(tf.data.AUTOTUNE)

# TPU training with static shapes
model.fit(train_dataset, epochs=10, steps_per_epoch=steps_per_epoch)
```

### XLA Optimization for TPU

```python
# Enable XLA compilation
@tf.function(experimental_compile=True)
def tpu_train_step(model, optimizer, inputs, labels):
    with tf.GradientTape() as tape:
        predictions = model(inputs, training=True)
        loss = tf.keras.losses.sparse_categorical_crossentropy(labels, predictions)
        loss = tf.reduce_mean(loss)
    
    gradients = tape.gradient(loss, model.trainable_variables)
    optimizer.apply_gradients(zip(gradients, model.trainable_variables))
    return loss

# Custom training loop with XLA
@tf.function(experimental_compile=True)
def tpu_training_loop(model, optimizer, dataset, steps):
    total_loss = 0.0
    
    for step in tf.range(steps):
        iterator = iter(dataset)
        inputs, labels = next(iterator)
        loss = tpu_train_step(model, optimizer, inputs, labels)
        total_loss += loss
    
    return total_loss / tf.cast(steps, tf.float32)

# Execute training with XLA optimization
with strategy.scope():
    for epoch in range(num_epochs):
        avg_loss = tpu_training_loop(model, optimizer, train_dataset, steps_per_epoch)
        print(f'Epoch {epoch}, Loss: {avg_loss}')
```

### Mixed Precision Training on TPU

```python
# Enable mixed precision for TPU
policy = tf.keras.mixed_precision.Policy('mixed_bfloat16')
tf.keras.mixed_precision.set_global_policy(policy)

with strategy.scope():
    model = create_model()
    # Last layer should output float32 for numerical stability
    model.add(tf.keras.layers.Dense(num_classes, activation='softmax', dtype='float32'))
    
    optimizer = tf.keras.optimizers.Adam(learning_rate=0.001)
    # No loss scaling needed for bfloat16 on TPU
    
    model.compile(
        optimizer=optimizer,
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )

# Training remains the same - mixed precision handled automatically
model.fit(train_dataset, epochs=10, validation_data=val_dataset)
```


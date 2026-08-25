## Multi-GPU Training Strategies


Multi-GPU training distributes computational workload across multiple GPUs within a single machine or across multiple machines. TensorFlow supports several strategies for coordinating GPU resources effectively.

**Key Points:**

- Synchronous training maintains consistent gradients across all GPUs
- Asynchronous training allows GPUs to update parameters independently
- All-reduce algorithms efficiently aggregate gradients across devices
- Memory management crucial for optimal GPU utilization

**Examples:**

```python
# Basic multi-GPU setup
strategy = tf.distribute.MirroredStrategy()
print(f"Number of devices: {strategy.num_replicas_in_sync}")

with strategy.scope():
    model = tf.keras.Sequential([
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.Dense(10, activation='softmax')
    ])
    
    model.compile(
        optimizer='adam',
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )

# Training with distributed dataset
train_dataset = tf.data.Dataset.from_tensor_slices((x_train, y_train))
train_dataset = train_dataset.batch(batch_size * strategy.num_replicas_in_sync)
train_dist_dataset = strategy.experimental_distribute_dataset(train_dataset)

model.fit(train_dist_dataset, epochs=10)
```

GPU memory optimization requires careful batch size scaling and gradient accumulation strategies to maximize throughput while preventing out-of-memory errors.


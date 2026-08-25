## Data Parallelism Implementation


Data parallelism replicates the model across multiple devices and distributes different batches of data to each replica. Gradients are aggregated and synchronized across all replicas before parameter updates.

**Key Points:**

- Each device processes different data batches with identical model copies
- Global batch size equals local batch size multiplied by number of replicas
- Gradient synchronization occurs through all-reduce operations
- Learning rate scaling may be required for large batch training

### Synchronous Data Parallelism

```python
class DistributedModel(tf.keras.Model):
    def __init__(self, strategy):
        super().__init__()
        self.strategy = strategy
        
        with strategy.scope():
            self.dense1 = tf.keras.layers.Dense(512, activation='relu')
            self.dropout = tf.keras.layers.Dropout(0.2)
            self.dense2 = tf.keras.layers.Dense(256, activation='relu')
            self.output_layer = tf.keras.layers.Dense(num_classes, activation='softmax')
    
    @tf.function
    def distributed_train_step(self, dist_inputs):
        def train_step(inputs):
            features, labels = inputs
            with tf.GradientTape() as tape:
                predictions = self(features, training=True)
                loss = tf.keras.losses.sparse_categorical_crossentropy(labels, predictions)
                loss = tf.reduce_mean(loss)
                # Scale loss by number of replicas
                scaled_loss = loss / self.strategy.num_replicas_in_sync
            
            gradients = tape.gradient(scaled_loss, self.trainable_variables)
            optimizer.apply_gradients(zip(gradients, self.trainable_variables))
            return loss
        
        return self.strategy.run(train_step, args=(dist_inputs,))

# Custom training loop
@tf.function
def distributed_train_epoch(model, dataset, optimizer):
    total_loss = 0.0
    num_batches = 0
    
    for batch in dataset:
        loss = model.distributed_train_step(batch)
        total_loss += strategy.reduce(tf.distribute.ReduceOp.SUM, loss, axis=None)
        num_batches += 1
    
    return total_loss / num_batches
```

### Parameter Server Strategy

```python
# Parameter server configuration
cluster_resolver = tf.distribute.cluster_resolver.TFConfigClusterResolver()
strategy = tf.distribute.experimental.ParameterServerStrategy(cluster_resolver)

# Coordinator setup
coordinator = tf.distribute.experimental.coordinator.ClusterCoordinator(strategy)

with strategy.scope():
    model = create_model()
    optimizer = tf.keras.optimizers.Adam(learning_rate=0.001)

def dataset_fn(input_context):
    batch_size = 64
    dataset = tf.data.Dataset.from_tensor_slices((x_train, y_train))
    dataset = dataset.shard(input_context.num_input_pipelines, input_context.input_pipeline_id)
    dataset = dataset.batch(batch_size)
    return dataset

@tf.function
def train_step(iterator):
    def step_fn(inputs):
        features, labels = inputs
        with tf.GradientTape() as tape:
            predictions = model(features, training=True)
            loss = tf.keras.losses.sparse_categorical_crossentropy(labels, predictions)
            loss = tf.reduce_mean(loss)
        
        gradients = tape.gradient(loss, model.trainable_variables)
        optimizer.apply_gradients(zip(gradients, model.trainable_variables))
        return loss
    
    return strategy.run(step_fn, args=(next(iterator),))

# Distributed dataset
per_worker_dataset = coordinator.create_per_worker_dataset(dataset_fn)
per_worker_iter = iter(per_worker_dataset)

# Training coordination
for epoch in range(num_epochs):
    for step in range(steps_per_epoch):
        coordinator.schedule(train_step, args=(per_worker_iter,))
    coordinator.join()
```


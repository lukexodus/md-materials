## Distributed Strategy API


The TensorFlow Distributed Strategy API provides a unified interface for various distributed training approaches, abstracting hardware-specific details while maintaining performance optimization.

**Key Points:**

- Strategy scope ensures proper variable placement and synchronization
- Different strategies optimize for specific hardware configurations
- Cross-replica reductions aggregate values across devices
- Fault tolerance varies by strategy implementation

### Strategy Comparison and Selection

```python
# Strategy factory for different configurations
def create_strategy(strategy_type, **kwargs):
    if strategy_type == 'mirrored':
        return tf.distribute.MirroredStrategy(
            devices=kwargs.get('devices', None),
            cross_device_ops=kwargs.get('cross_device_ops', None)
        )
    elif strategy_type == 'multi_worker':
        return tf.distribute.MultiWorkerMirroredStrategy(
            communication=kwargs.get('communication', 'auto')
        )
    elif strategy_type == 'parameter_server':
        cluster_resolver = tf.distribute.cluster_resolver.TFConfigClusterResolver()
        return tf.distribute.experimental.ParameterServerStrategy(cluster_resolver)
    elif strategy_type == 'central_storage':
        return tf.distribute.experimental.CentralStorageStrategy(
            compute_devices=kwargs.get('compute_devices', None)
        )
    else:
        return tf.distribute.get_strategy()  # Default strategy

# Adaptive strategy selection
def select_optimal_strategy():
    gpus = tf.config.experimental.list_physical_devices('GPU')
    
    if len(gpus) > 1:
        # Multi-GPU single machine
        return create_strategy('mirrored')
    elif 'TF_CONFIG' in os.environ:
        # Multi-worker setup
        return create_strategy('multi_worker')
    else:
        # Single device
        return tf.distribute.get_strategy()

strategy = select_optimal_strategy()
```

### Custom Distributed Training Loop

```python
class DistributedTrainer:
    def __init__(self, strategy, model, optimizer, train_dataset, val_dataset=None):
        self.strategy = strategy
        self.model = model
        self.optimizer = optimizer
        self.train_dataset = train_dataset
        self.val_dataset = val_dataset
        
        # Distribute datasets
        self.train_dist_dataset = strategy.experimental_distribute_dataset(train_dataset)
        if val_dataset:
            self.val_dist_dataset = strategy.experimental_distribute_dataset(val_dataset)
    
    @tf.function
    def distributed_train_step(self, inputs):
        def train_step(inputs):
            features, labels = inputs
            with tf.GradientTape() as tape:
                predictions = self.model(features, training=True)
                per_example_loss = tf.keras.losses.sparse_categorical_crossentropy(labels, predictions)
                loss = tf.reduce_mean(per_example_loss)
                scaled_loss = loss / self.strategy.num_replicas_in_sync
            
            gradients = tape.gradient(scaled_loss, self.model.trainable_variables)
            self.optimizer.apply_gradients(zip(gradients, self.model.trainable_variables))
            
            return loss
        
        per_replica_loss = self.strategy.run(train_step, args=(inputs,))
        return self.strategy.reduce(tf.distribute.ReduceOp.SUM, per_replica_loss, axis=None)
    
    @tf.function
    def distributed_validation_step(self, inputs):
        def val_step(inputs):
            features, labels = inputs
            predictions = self.model(features, training=False)
            loss = tf.keras.losses.sparse_categorical_crossentropy(labels, predictions)
            accuracy = tf.keras.metrics.sparse_categorical_accuracy(labels, predictions)
            return tf.reduce_mean(loss), tf.reduce_mean(accuracy)
        
        per_replica_loss, per_replica_acc = self.strategy.run(val_step, args=(inputs,))
        
        return (
            self.strategy.reduce(tf.distribute.ReduceOp.MEAN, per_replica_loss, axis=None),
            self.strategy.reduce(tf.distribute.ReduceOp.MEAN, per_replica_acc, axis=None)
        )
    
    def train(self, epochs, steps_per_epoch=None, validation_steps=None):
        train_iterator = iter(self.train_dist_dataset)
        
        for epoch in range(epochs):
            # Training phase
            total_train_loss = 0.0
            num_train_batches = 0
            
            for step in range(steps_per_epoch or len(self.train_dataset)):
                try:
                    batch = next(train_iterator)
                    loss = self.distributed_train_step(batch)
                    total_train_loss += loss
                    num_train_batches += 1
                    
                    if step % 100 == 0:
                        print(f'Epoch {epoch}, Step {step}, Loss: {loss:.4f}')
                
                except StopIteration:
                    train_iterator = iter(self.train_dist_dataset)
                    batch = next(train_iterator)
                    loss = self.distributed_train_step(batch)
                    total_train_loss += loss
                    num_train_batches += 1
            
            avg_train_loss = total_train_loss / num_train_batches
            
            # Validation phase
            if self.val_dataset:
                val_iterator = iter(self.val_dist_dataset)
                total_val_loss = 0.0
                total_val_acc = 0.0
                num_val_batches = 0
                
                for step in range(validation_steps or len(self.val_dataset)):
                    try:
                        batch = next(val_iterator)
                        val_loss, val_acc = self.distributed_validation_step(batch)
                        total_val_loss += val_loss
                        total_val_acc += val_acc
                        num_val_batches += 1
                    except StopIteration:
                        break
                
                avg_val_loss = total_val_loss / num_val_batches
                avg_val_acc = total_val_acc / num_val_batches
                
                print(f'Epoch {epoch}: Train Loss: {avg_train_loss:.4f}, '
                      f'Val Loss: {avg_val_loss:.4f}, Val Acc: {avg_val_acc:.4f}')
            else:
                print(f'Epoch {epoch}: Train Loss: {avg_train_loss:.4f}')

# Usage
with strategy.scope():
    model = create_model()
    optimizer = tf.keras.optimizers.Adam(learning_rate=0.001)

trainer = DistributedTrainer(strategy, model, optimizer, train_dataset, val_dataset)
trainer.train(epochs=10, steps_per_epoch=1000)
```


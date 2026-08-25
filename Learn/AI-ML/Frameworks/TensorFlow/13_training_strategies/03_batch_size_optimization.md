## Batch Size Optimization


Batch size significantly affects training dynamics, convergence behavior, and computational efficiency. Optimal batch size selection balances gradient quality, memory constraints, and training speed.

**Batch Size Effects on Training**

[Inference] Small batch sizes provide noisier gradients that can help escape local minima but may slow convergence. Large batch sizes offer more stable gradients but may require learning rate adjustments and can lead to poor generalization.

**Dynamic Batch Size Strategies**

Adaptive batch size adjustment during training:

```python
class AdaptiveBatchSize:
    def __init__(self, initial_batch_size=32, min_batch_size=16, max_batch_size=512):
        self.current_batch_size = initial_batch_size
        self.min_batch_size = min_batch_size
        self.max_batch_size = max_batch_size
        self.loss_history = []
        self.adjustment_frequency = 10
    
    def update_batch_size(self, current_loss):
        self.loss_history.append(current_loss)
        
        if len(self.loss_history) >= self.adjustment_frequency:
            recent_losses = self.loss_history[-self.adjustment_frequency:]
            loss_trend = np.polyfit(range(len(recent_losses)), recent_losses, 1)[0]
            
            if loss_trend > 0:  # Loss increasing
                # Reduce batch size for more frequent updates
                self.current_batch_size = max(
                    self.current_batch_size // 2,
                    self.min_batch_size
                )
            elif abs(loss_trend) < 0.001:  # Loss plateauing
                # Increase batch size for more stable gradients
                self.current_batch_size = min(
                    self.current_batch_size * 2,
                    self.max_batch_size
                )
            
            self.loss_history = []
        
        return self.current_batch_size

# Progressive batch size increase
class ProgressiveBatchSize:
    def __init__(self, initial_batch_size=32, final_batch_size=256, total_epochs=100):
        self.initial_batch_size = initial_batch_size
        self.final_batch_size = final_batch_size
        self.total_epochs = total_epochs
    
    def get_batch_size(self, epoch):
        progress = epoch / self.total_epochs
        # Exponential growth
        factor = progress ** 2
        batch_size = self.initial_batch_size + factor * (self.final_batch_size - self.initial_batch_size)
        return int(batch_size)
```

**Memory-Efficient Batch Processing**

Gradient accumulation enables large effective batch sizes:

```python
class GradientAccumulation:
    def __init__(self, model, optimizer, accumulation_steps=4):
        self.model = model
        self.optimizer = optimizer
        self.accumulation_steps = accumulation_steps
        self.accumulated_gradients = []
    
    @tf.function
    def accumulate_gradients(self, x_batch, y_batch):
        with tf.GradientTape() as tape:
            predictions = self.model(x_batch, training=True)
            loss = tf.keras.losses.categorical_crossentropy(y_batch, predictions)
            # Scale loss by accumulation steps
            scaled_loss = loss / self.accumulation_steps
        
        gradients = tape.gradient(scaled_loss, self.model.trainable_variables)
        
        if not self.accumulated_gradients:
            self.accumulated_gradients = [tf.Variable(tf.zeros_like(grad)) for grad in gradients]
        
        # Accumulate gradients
        for acc_grad, grad in zip(self.accumulated_gradients, gradients):
            if grad is not None:
                acc_grad.assign_add(grad)
        
        return loss
    
    def apply_accumulated_gradients(self):
        # Apply accumulated gradients
        gradients_and_vars = [(grad, var) for grad, var in 
                             zip(self.accumulated_gradients, self.model.trainable_variables)]
        self.optimizer.apply_gradients(gradients_and_vars)
        
        # Reset accumulated gradients
        for acc_grad in self.accumulated_gradients:
            acc_grad.assign(tf.zeros_like(acc_grad))
    
    def train_step(self, dataset_batch):
        total_loss = 0
        
        for step, (x_batch, y_batch) in enumerate(dataset_batch):
            loss = self.accumulate_gradients(x_batch, y_batch)
            total_loss += loss
            
            # Apply gradients after accumulation_steps
            if (step + 1) % self.accumulation_steps == 0:
                self.apply_accumulated_gradients()
        
        return total_loss / len(dataset_batch)

# Usage example
accumulator = GradientAccumulation(model, optimizer, accumulation_steps=8)

for epoch in range(num_epochs):
    for batch_data in small_batches:  # Small batches due to memory constraints
        loss = accumulator.train_step(batch_data)
```

**Batch Size and Learning Rate Scaling**

Linear and square root scaling rules for large batches:

```python
class BatchSizeLRScaling:
    @staticmethod
    def linear_scaling(base_lr, base_batch_size, current_batch_size):
        """Linear scaling rule: lr = base_lr * (batch_size / base_batch_size)"""
        return base_lr * (current_batch_size / base_batch_size)
    
    @staticmethod
    def sqrt_scaling(base_lr, base_batch_size, current_batch_size):
        """Square root scaling rule for very large batches"""
        return base_lr * tf.sqrt(current_batch_size / base_batch_size)
    
    @staticmethod
    def polynomial_scaling(base_lr, base_batch_size, current_batch_size, power=0.5):
        """Polynomial scaling with configurable power"""
        return base_lr * tf.pow(current_batch_size / base_batch_size, power)

# Adaptive learning rate based on batch size
def create_batch_aware_optimizer(base_lr=0.01, base_batch_size=32, scaling_rule='linear'):
    def get_scaled_lr(current_batch_size):
        if scaling_rule == 'linear':
            return BatchSizeLRScaling.linear_scaling(base_lr, base_batch_size, current_batch_size)
        elif scaling_rule == 'sqrt':
            return BatchSizeLRScaling.sqrt_scaling(base_lr, base_batch_size, current_batch_size)
        else:
            return base_lr
    
    return get_scaled_lr
```


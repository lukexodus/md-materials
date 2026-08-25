## Early Stopping Strategies


Early stopping prevents overfitting by terminating training when validation performance stops improving. Sophisticated early stopping strategies balance training time with model performance.

**Basic Early Stopping Implementation**

Standard early stopping monitors validation metrics:

```python
class EarlyStopping:
    def __init__(self, monitor='val_loss', patience=10, min_delta=0.001, 
                 mode='min', restore_best_weights=True, baseline=None):
        self.monitor = monitor
        self.patience = patience
        self.min_delta = min_delta
        self.mode = mode
        self.restore_best_weights = restore_best_weights
        self.baseline = baseline
        
        self.wait = 0
        self.stopped_epoch = 0
        self.best_weights = None
        
        if mode == 'min':
            self.monitor_op = lambda a, b: (a - b) < -self.min_delta
            self.best = float('inf')
        else:
            self.monitor_op = lambda a, b: (a - b) > self.min_delta
            self.best = -float('inf')
    
    def on_train_begin(self, model):
        self.wait = 0
        self.stopped_epoch = 0
        if self.baseline is not None:
            self.best = self.baseline
        else:
            self.best = float('inf') if self.mode == 'min' else -float('inf')
    
    def on_epoch_end(self, epoch, logs, model):
        current = logs.get(self.monitor)
        
        if current is None:
            print(f"Early stopping conditioned on metric `{self.monitor}` which is not available.")
            return False
        
        if self.monitor_op(current, self.best):
            self.best = current
            self.wait = 0
            if self.restore_best_weights:
                self.best_weights = [w.numpy() for w in model.get_weights()]
        else:
            self.wait += 1
            if self.wait >= self.patience:
                self.stopped_epoch = epoch
                if self.restore_best_weights and self.best_weights is not None:
                    print(f"Restoring model weights from the end of the best epoch: {epoch - self.wait}")
                    model.set_weights(self.best_weights)
                return True  # Stop training
        
        return False
    
    def on_train_end(self):
        if self.stopped_epoch > 0:
            print(f"Epoch {self.stopped_epoch + 1}: early stopping")

# Usage in training loop
early_stopping = EarlyStopping(monitor='val_loss', patience=10, restore_best_weights=True)

for epoch in range(max_epochs):
    # Training step
    train_loss = train_step(model, train_dataset, optimizer)
    
    # Validation step
    val_loss = validate_step(model, val_dataset)
    
    logs = {'loss': train_loss, 'val_loss': val_loss}
    
    if early_stopping.on_epoch_end(epoch, logs, model):
        break
```

**Advanced Early Stopping Strategies**

Multi-metric and adaptive early stopping:

```python
class MultiMetricEarlyStopping:
    def __init__(self, metrics_config, combination_mode='all', patience=10):
        """
        metrics_config: dict of {'metric_name': {'mode': 'min'/'max', 'weight': float}}
        combination_mode: 'all' (all metrics must improve) or 'weighted' (weighted average)
        """
        self.metrics_config = metrics_config
        self.combination_mode = combination_mode
        self.patience = patience
        
        self.wait = 0
        self.best_metrics = {}
        self.best_score = None
        self.best_weights = None
        
        for metric, config in metrics_config.items():
            self.best_metrics[metric] = float('inf') if config['mode'] == 'min' else -float('inf')
    
    def _compute_combined_score(self, current_metrics):
        if self.combination_mode == 'weighted':
            score = 0
            total_weight = 0
            for metric, value in current_metrics.items():
                if metric in self.metrics_config:
                    config = self.metrics_config[metric]
                    weight = config.get('weight', 1.0)
                    # Normalize for minimization
                    normalized_value = value if config['mode'] == 'min' else -value
                    score += weight * normalized_value
                    total_weight += weight
            return score / total_weight if total_weight > 0 else 0
        
        return 0  # Not used for 'all' mode
    
    def _has_improved(self, current_metrics):
        if self.combination_mode == 'all':
            # All metrics must improve
            for metric, current_value in current_metrics.items():
                if metric in self.metrics_config:
                    config = self.metrics_config[metric]
                    best_value = self.best_metrics[metric]
                    
                    if config['mode'] == 'min':
                        if current_value >= best_value:
                            return False
                    else:
                        if current_value <= best_value:
                            return False
            return True
        
        elif self.combination_mode == 'weighted':
            current_score = self._compute_combined_score(current_metrics)
            return current_score < (self.best_score or float('inf'))
        
        return False
    
    def on_epoch_end(self, epoch, logs, model):
        current_metrics = {k: v for k, v in logs.items() if k in self.metrics_config}
        
        if self._has_improved(current_metrics):
            # Update best metrics
            for metric, value in current_metrics.items():
                if metric in self.metrics_config:
                    self.best_metrics[metric] = value
            
            if self.combination_mode == 'weighted':
                self.best_score = self._compute_combined_score(current_metrics)
            
            self.wait = 0
            self.best_weights = [w.numpy() for w in model.get_weights()]
        else:
            self.wait += 1
            if self.wait >= self.patience:
                if self.best_weights is not None:
                    model.set_weights(self.best_weights)
                return True
        
        return False

# Adaptive patience early stopping
class AdaptiveEarlyStopping:
    def __init__(self, monitor='val_loss', initial_patience=10, patience_increase=5, 
                 improvement_threshold=0.01, max_patience=50):
        self.monitor = monitor
        self.initial_patience = initial_patience
        self.patience_increase = patience_increase
        self.improvement_threshold = improvement_threshold
        self.max_patience = max_patience
        
        self.current_patience = initial_patience
        self.wait = 0
        self.best = float('inf')
        self.best_weights = None
        self.last_improvement = 0
    
    def on_epoch_end(self, epoch, logs, model):
        current = logs.get(self.monitor)
        
        if current is None:
            return False
        
        improvement = self.best - current
        
        if improvement > self.improvement_threshold:
            self.best = current
            self.wait = 0
            self.last_improvement = epoch
            self.best_weights = [w.numpy() for w in model.get_weights()]
            
            # Increase patience if significant improvement
            if improvement > self.improvement_threshold * 2:
                self.current_patience = min(
                    self.current_patience + self.patience_increase,
                    self.max_patience
                )
                print(f"Significant improvement detected. Increasing patience to {self.current_patience}")
        else:
            self.wait += 1
            
            # Decrease patience if no improvement for long time
            if self.wait > self.current_patience // 2:
                self.current_patience = max(
                    self.current_patience - 1,
                    self.initial_patience
                )
        
        if self.wait >= self.current_patience:
            if self.best_weights is not None:
                model.set_weights(self.best_weights)
            print(f"Early stopping at epoch {epoch + 1} with patience {self.current_patience}")
            return True
        
        return False
```

**Learning Rate Scheduling with Early Stopping**

Combining early stopping with learning rate reduction:

```python
class EarlyStoppingWithLRReduction:
    def __init__(self, monitor='val_loss', patience=10, lr_patience=5, 
                 lr_factor=0.5, min_lr=1e-7, cooldown=0, restore_best_weights=True,
                 min_delta=0.001, mode='min'):
        self.monitor = monitor
        self.patience = patience
        self.lr_patience = lr_patience
        self.lr_factor = lr_factor
        self.min_lr = min_lr
        self.cooldown = cooldown
        self.restore_best_weights = restore_best_weights
        self.min_delta = min_delta
        self.mode = mode
        
        # Early stopping state
        self.wait = 0
        self.lr_wait = 0
        self.cooldown_counter = 0
        self.stopped_epoch = 0
        self.best_weights = None
        
        # Set up monitoring operation based on mode
        if mode == 'min':
            self.monitor_op = lambda a, b: (a - b) < -self.min_delta
            self.best = float('inf')
        else:
            self.monitor_op = lambda a, b: (a - b) > self.min_delta
            self.best = -float('inf')
    
    def on_train_begin(self, model, optimizer):
        """Initialize state at the beginning of training"""
        self.wait = 0
        self.lr_wait = 0
        self.cooldown_counter = 0
        self.stopped_epoch = 0
        self.best = float('inf') if self.mode == 'min' else -float('inf')
        self.initial_lr = optimizer.learning_rate.numpy() if hasattr(optimizer.learning_rate, 'numpy') else optimizer.learning_rate
    
    def on_epoch_end(self, epoch, logs, model, optimizer):
        """Check metrics and update learning rate or stop training"""
        current = logs.get(self.monitor)
        
        if current is None:
            print(f"Early stopping conditioned on metric `{self.monitor}` which is not available.")
            return False
        
        # Check if metric improved
        if self.monitor_op(current, self.best):
            self.best = current
            self.wait = 0
            self.lr_wait = 0
            if self.restore_best_weights:
                self.best_weights = [w.numpy() for w in model.get_weights()]
        else:
            self.wait += 1
            if self.cooldown_counter > 0:
                self.cooldown_counter -= 1
                self.lr_wait = 0
            else:
                self.lr_wait += 1
        
        # Learning rate reduction logic
        if self.lr_wait >= self.lr_patience and self.cooldown_counter == 0:
            current_lr = optimizer.learning_rate.numpy() if hasattr(optimizer.learning_rate, 'numpy') else optimizer.learning_rate
            new_lr = max(current_lr * self.lr_factor, self.min_lr)
            
            if new_lr < current_lr:
                print(f"Epoch {epoch + 1}: reducing learning rate from {current_lr:.6f} to {new_lr:.6f}")
                optimizer.learning_rate.assign(new_lr)
                self.cooldown_counter = self.cooldown
                self.lr_wait = 0
        
        # Early stopping logic
        if self.wait >= self.patience:
            self.stopped_epoch = epoch
            if self.restore_best_weights and self.best_weights is not None:
                print(f"Restoring model weights from the end of the best epoch: {epoch - self.wait}")
                model.set_weights(self.best_weights)
            return True  # Stop training
        
        return False
    
    def on_train_end(self):
        """Print final message when training ends"""
        if self.stopped_epoch > 0:
            print(f"Epoch {self.stopped_epoch + 1}: early stopping")

# Usage example with TensorFlow/Keras-style training loop
def train_with_early_stopping_and_lr_reduction():
    """Example training function demonstrating usage"""
    import tensorflow as tf
    
    # Initialize model and optimizer
    model = create_model()  # Your model creation function
    optimizer = tf.keras.optimizers.Adam(learning_rate=0.001)
    
    # Initialize early stopping with LR reduction
    early_stopping = EarlyStoppingWithLRReduction(
        monitor='val_loss',
        patience=20,           # Stop after 20 epochs without improvement
        lr_patience=7,         # Reduce LR after 7 epochs without improvement
        lr_factor=0.5,         # Reduce LR by half
        min_lr=1e-7,          # Don't reduce below this value
        cooldown=3,           # Wait 3 epochs after LR reduction before reducing again
        restore_best_weights=True
    )
    
    early_stopping.on_train_begin(model, optimizer)
    
    max_epochs = 200
    for epoch in range(max_epochs):
        # Training step
        train_loss = train_step(model, train_dataset, optimizer)
        
        # Validation step
        val_loss = validate_step(model, val_dataset)
        
        # Additional metrics
        val_accuracy = compute_accuracy(model, val_dataset)
        
        logs = {
            'loss': train_loss,
            'val_loss': val_loss,
            'val_accuracy': val_accuracy
        }
        
        print(f"Epoch {epoch + 1}/{max_epochs} - "
              f"loss: {train_loss:.4f} - "
              f"val_loss: {val_loss:.4f} - "
              f"val_accuracy: {val_accuracy:.4f} - "
              f"lr: {optimizer.learning_rate.numpy():.6f}")
        
        # Check early stopping
        if early_stopping.on_epoch_end(epoch, logs, model, optimizer):
            break
    
    early_stopping.on_train_end()
    return model

# Alternative implementation for PyTorch
class PyTorchEarlyStoppingWithLRReduction:
    def __init__(self, monitor='val_loss', patience=10, lr_patience=5, 
                 lr_factor=0.5, min_lr=1e-7, cooldown=0, restore_best_weights=True,
                 min_delta=0.001, mode='min'):
        self.monitor = monitor
        self.patience = patience
        self.lr_patience = lr_patience
        self.lr_factor = lr_factor
        self.min_lr = min_lr
        self.cooldown = cooldown
        self.restore_best_weights = restore_best_weights
        self.min_delta = min_delta
        self.mode = mode
        
        self.wait = 0
        self.lr_wait = 0
        self.cooldown_counter = 0
        self.stopped_epoch = 0
        self.best_state_dict = None
        
        if mode == 'min':
            self.monitor_op = lambda a, b: (a - b) < -self.min_delta
            self.best = float('inf')
        else:
            self.monitor_op = lambda a, b: (a - b) > self.min_delta
            self.best = -float('inf')
    
    def on_epoch_end(self, epoch, logs, model, optimizer):
        """PyTorch version - works with torch.optim optimizers"""
        import copy
        
        current = logs.get(self.monitor)
        
        if current is None:
            print(f"Early stopping conditioned on metric `{self.monitor}` which is not available.")
            return False
        
        if self.monitor_op(current, self.best):
            self.best = current
            self.wait = 0
            self.lr_wait = 0
            if self.restore_best_weights:
                self.best_state_dict = copy.deepcopy(model.state_dict())
        else:
            self.wait += 1
            if self.cooldown_counter > 0:
                self.cooldown_counter -= 1
                self.lr_wait = 0
            else:
                self.lr_wait += 1
        
        # Learning rate reduction
        if self.lr_wait >= self.lr_patience and self.cooldown_counter == 0:
            current_lr = optimizer.param_groups[0]['lr']
            new_lr = max(current_lr * self.lr_factor, self.min_lr)
            
            if new_lr < current_lr:
                print(f"Epoch {epoch + 1}: reducing learning rate from {current_lr:.6f} to {new_lr:.6f}")
                for param_group in optimizer.param_groups:
                    param_group['lr'] = new_lr
                self.cooldown_counter = self.cooldown
                self.lr_wait = 0
        
        # Early stopping
        if self.wait >= self.patience:
            self.stopped_epoch = epoch
            if self.restore_best_weights and self.best_state_dict is not None:
                print(f"Restoring model weights from the end of the best epoch: {epoch - self.wait}")
                model.load_state_dict(self.best_state_dict)
            return True
        
        return False
```



---


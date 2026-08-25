## Custom Callbacks and Hooks


Callbacks provide hooks into the training process, enabling custom monitoring, scheduling, and intervention strategies. Custom callbacks extend TensorFlow's training capabilities with specialized functionality.

**Training Monitoring Callbacks**

Advanced monitoring and logging capabilities:

```python
class DetailedLogging(tf.keras.callbacks.Callback):
    def __init__(self, log_dir='./logs', log_freq=10):
        super(DetailedLogging, self).__init__()
        self.log_dir = log_dir
        self.log_freq = log_freq
        self.writer = tf.summary.create_file_writer(log_dir)
    
    def on_train_begin(self, logs=None):
        self.train_start_time = time.time()
        print(f"Training started at {time.strftime('%Y-%m-%d %H:%M:%S')}")
    
    def on_epoch_begin(self, epoch, logs=None):
        self.epoch_start_time = time.time()
    
    def on_batch_end(self, batch, logs=None):
        if batch % self.log_freq == 0:
            with self.writer.as_default():
                tf.summary.scalar('batch_loss', logs.get('loss'), step=batch)
                tf.summary.scalar('batch_accuracy', logs.get('accuracy'), step=batch)
                
                # Log learning rate
                if hasattr(self.model.optimizer, 'learning_rate'):
                    lr = self.model.optimizer.learning_rate
                    if callable(lr):
                        current_lr = lr(self.model.optimizer.iterations)
                    else:
                        current_lr = lr
                    tf.summary.scalar('learning_rate', current_lr, step=batch)
    
    def on_epoch_end(self, epoch, logs=None):
        epoch_time = time.time() - self.epoch_start_time
        
        with self.writer.as_default():
            tf.summary.scalar('epoch_time', epoch_time, step=epoch)
            
            # Log weight statistics
            for layer in self.model.layers:
                if hasattr(layer, 'kernel'):
                    weights = layer.get_weights()[0]
                    tf.summary.histogram(f'{layer.name}/weights', weights, step=epoch)
                    tf.summary.scalar(f'{layer.name}/weight_mean', 
                                    tf.reduce_mean(weights), step=epoch)
                    tf.summary.scalar(f'{layer.name}/weight_std', 
                                    tf.math.reduce_std(weights), step=epoch)
    
    def on_train_end(self, logs=None):
        total_time = time.time() - self.train_start_time
        print(f"Training completed in {total_time:.2f} seconds")
        self.writer.close()

class GradientClipping(tf.keras.callbacks.Callback):
    def __init__(self, clip_norm=1.0):
        super(GradientClipping, self).__init__()
        self.clip_norm = clip_norm
    
    def on_train_begin(self, logs=None):
        # Wrap the optimizer's apply_gradients method
        original_apply = self.model.optimizer.apply_gradients
        
        def clipped_apply_gradients(grads_and_vars, **kwargs):
            # Clip gradients
            gradients, variables = zip(*grads_and_vars)
            clipped_gradients = [
                tf.clip_by_norm(grad, self.clip_norm) if grad is not None else None
                for grad in gradients
            ]
            clipped_grads_and_vars = list(zip(clipped_gradients, variables))
            return original_apply(clipped_grads_and_vars, **kwargs)
        
        self.model.optimizer.apply_gradients = clipped_apply_gradients
```

**Advanced Scheduling Callbacks**

Sophisticated parameter scheduling strategies:

```python
class CyclicalLearningRate(tf.keras.callbacks.Callback):
    def __init__(self, base_lr=0.001, max_lr=0.006, step_size=2000, mode='triangular'):
        super(CyclicalLearningRate, self).__init__()
        self.base_lr = base_lr
        self.max_lr = max_lr
        self.step_size = step_size
        self.mode = mode
        self.iterations = 0
        
        self.lr_history = []
    
    def _triangular_lr(self, cycle):
        x = np.abs(cycle - 1)
        return self.base_lr + (self.max_lr - self.base_lr) * np.maximum(0, (1 - x))
    
    def _triangular2_lr(self, cycle):
        x = np.abs(cycle - 1)
        return self.base_lr + (self.max_lr - self.base_lr) * np.maximum(0, (1 - x)) / float(2 ** (cycle - 1))
    
    def _exp_range_lr(self, cycle, gamma=1.0):
        x = np.abs(cycle - 1)
        return self.base_lr + (self.max_lr - self.base_lr) * np.maximum(0, (1 - x)) * gamma ** self.iterations
    
    def on_batch_begin(self, batch, logs=None):
        self.iterations += 1
        cycle = np.floor(1 + self.iterations / (2 * self.step_size))
        x = np.abs(self.iterations / self.step_size - 2 * cycle + 1)
        
        if self.mode == 'triangular':
            lr = self._triangular_lr(x)
        elif self.mode == 'triangular2':
            lr = self._triangular2_lr(cycle)
        elif self.mode == 'exp_range':
            lr = self._exp_range_lr(cycle)
        else:
            raise ValueError(f"Unknown mode: {self.mode}")
        
        tf.keras.backend.set_value(self.model.optimizer.learning_rate, lr)
        self.lr_history.append(lr)

class WarmupSchedule(tf.keras.callbacks.Callback):
    def __init__(self, warmup_steps=1000, max_lr=0.001, min_lr=1e-6):
        super(WarmupSchedule, self).__init__()
        self.warmup_steps = warmup_steps
        self.max_lr = max_lr
        self.min_lr = min_lr
        self.global_step = 0
    
    def on_batch_begin(self, batch, logs=None):
        self.global_step += 1
        
        if self.global_step <= self.warmup_steps:
            # Linear warmup
            lr = self.min_lr + (self.max_lr - self.min_lr) * (self.global_step / self.warmup_steps)
        else:
            # Cosine annealing after warmup
            progress = (self.global_step - self.warmup_steps) / (10000 - self.warmup_steps)  # Assume 10000 total steps
            lr = self.min_lr + 0.5 * (self.max_lr - self.min_lr) * (1 + np.cos(np.pi * progress))
        
        tf.keras.backend.set_value(self.model.optimizer.learning_rate, lr)
```

**Model Intervention Callbacks**

Callbacks that modify model behavior during training:

```python
class AdaptiveDropout(tf.keras.callbacks.Callback):
    def __init__(self, target_layer_names, initial_rate=0.5, adjustment_factor=0.1):
        super(AdaptiveDropout, self).__init__()
        self.target_layer_names = target_layer_names
        self.initial_rate = initial_rate
        self.adjustment_factor = adjustment_factor
        self.best_val_loss = float('inf')
    
    def on_epoch_end(self, epoch, logs=None):
        val_loss = logs.get('val_loss')
        
        if val_loss is not None:
            if val_loss < self.best_val_loss:
                # Validation improved, slightly reduce dropout
                self.best_val_loss = val_loss
                self._adjust_dropout(-self.adjustment_factor)
            else:
                # Validation worsened, increase dropout
                self._adjust_dropout(self.adjustment_factor)
    
    def _adjust_dropout(self, adjustment):
        for layer in self.model.layers:
            if layer.name in self.target_layer_names and hasattr(layer, 'rate'):
                new_rate = tf.clip_by_value(layer.rate + adjustment, 0.0, 0.9)
                layer.rate = new_rate
                print(f"Adjusted {layer.name} dropout rate to {new_rate:.3f}")

class LayerFreezing(tf.keras.callbacks.Callback):
    def __init__(self, freeze_schedule):
        super(LayerFreezing, self).__init__()
        self.freeze_schedule = freeze_schedule  # Dict: {epoch: [layer_names]}
    
    def on_epoch_begin(self, epoch, logs=None):
        if epoch in self.freeze_schedule:
            layers_to_freeze = self.freeze_schedule[epoch]
            
            for layer_name in layers_to_freeze:
                layer = self.model.get_layer(layer_name)
                layer.trainable = False
                print(f"Epoch {epoch}: Frozen layer {layer_name}")
            
            # Recompile model with updated trainable parameters
            self.model.compile(
                optimizer=self.model.optimizer,
                loss=self.model.loss,
                metrics=self.model.metrics
            )

class ModelCheckpointing(tf.keras.callbacks.Callback):
    def __init__(self, filepath, monitor='val_loss', mode='min', save_best_only=True, 
                 save_weights_only=False, save_freq='epoch'):
        super(ModelCheckpointing, self).__init__()
        self.filepath = filepath
        self.monitor = monitor
        self.mode = mode
        self.save_best_only = save_best_only
        self.save_weights_only = save_weights_only
        self.save_freq = save_freq
        
        if mode == 'min':
            self.best = float('inf')
            self.monitor_op = np.less
        else:
            self.best = -float('inf')
            self.monitor_op = np.greater
    
    def on_epoch_end(self, epoch, logs=None):
        current = logs.get(self.monitor)
        
        if current is None:
            print(f"Warning: Monitor metric '{self.monitor}' not available")
            return
        
        if not self.save_best_only or self.monitor_op(current, self.best):
            if self.save_best_only:
                self.best = current
                print(f"Epoch {epoch+1}: {self.monitor} improved to {current:.5f}")
            
            # Create filepath with epoch and metric values
            filepath = self.filepath.format(epoch=epoch+1, **logs)
            
            if self.save_weights_only:
                self.model.save_weights(filepath)
            else:
                self.model.save(filepath)
            
            print(f"Model saved to {filepath}")
```

**Distributed Training Callbacks**

Specialized callbacks for multi-GPU and distributed training:

```python
class DistributedSyncCallback(tf.keras.callbacks.Callback):
    def __init__(self, sync_frequency=10):
        super(DistributedSyncCallback, self).__init__()
        self.sync_frequency = sync_frequency
        self.step_count = 0
    
    def on_batch_end(self, batch, logs=None):
        self.step_count += 1
        
        if self.step_count % self.sync_frequency == 0:
            # Synchronize gradients across replicas
            if tf.distribute.in_cross_replica_context():
                strategy = tf.distribute.get_strategy()
                
                # Perform all-reduce on model weights
                for layer in self.model.layers:
                    if hasattr(layer, 'kernel'):
                        kernel = layer.kernel
                        synced_kernel = strategy.reduce(
                            tf.distribute.ReduceOp.MEAN, kernel, axis=None
                        )
                        layer.kernel.assign(synced_kernel)

class ResourceMonitoring(tf.keras.callbacks.Callback):
    def __init__(self, log_frequency=100):
        super(ResourceMonitoring, self).__init__()
        self.log_frequency = log_frequency
        self.step_count = 0
    
    def on_batch_end(self, batch, logs=None):
        self.step_count += 1
        
        if self.step_count % self.log_frequency == 0:
            # Monitor GPU memory usage
            gpus = tf.config.experimental.list_physical_devices('GPU')
            
            for i, gpu in enumerate(gpus):
                memory_info = tf.config.experimental.get_memory_info(gpu.name)
                current_memory = memory_info['current'] / (1024**3)  # Convert to GB
                peak_memory = memory_info['peak'] / (1024**3)
                
                print(f"GPU {i}: Current memory: {current_memory:.2f}GB, "
                      f"Peak memory: {peak_memory:.2f}GB")
            
            # Monitor training speed
            if hasattr(self, 'last_time'):
                current_time = time.time()
                batches_per_second = self.log_frequency / (current_time - self.last_time)
                print(f"Training speed: {batches_per_second:.2f} batches/second")
            
            self.last_time = time.time()
```

**Custom Training Loop Integration**

Advanced callbacks for custom training procedures:

```python
class GradientAccumulation(tf.keras.callbacks.Callback):
    def __init__(self, accumulation_steps=4):
        super(GradientAccumulation, self).__init__()
        self.accumulation_steps = accumulation_steps
        self.accumulated_gradients = []
        self.current_step = 0
    
    def on_train_begin(self, logs=None):
        # Initialize accumulated gradients
        self.accumulated_gradients = [
            tf.Variable(tf.zeros_like(var), trainable=False)
            for var in self.model.trainable_variables
        ]
    
    def on_batch_begin(self, batch, logs=None):
        # Reset accumulated gradients at the start of accumulation cycle
        if self.current_step % self.accumulation_steps == 0:
            for acc_grad in self.accumulated_gradients:
                acc_grad.assign(tf.zeros_like(acc_grad))
    
    def on_batch_end(self, batch, logs=None):
        self.current_step += 1
        
        # Apply accumulated gradients when accumulation is complete
        if self.current_step % self.accumulation_steps == 0:
            # Average the accumulated gradients
            averaged_gradients = [
                acc_grad / self.accumulation_steps
                for acc_grad in self.accumulated_gradients
            ]
            
            # Apply gradients
            self.model.optimizer.apply_gradients(
                zip(averaged_gradients, self.model.trainable_variables)
            )

class MixedPrecisionCallback(tf.keras.callbacks.Callback):
    def __init__(self, loss_scale=1024):
        super(MixedPrecisionCallback, self).__init__()
        self.loss_scale = loss_scale
        self.dynamic_scale = tf.Variable(loss_scale, dtype=tf.float32)
        self.good_steps = tf.Variable(0, dtype=tf.int32)
        self.bad_steps = tf.Variable(0, dtype=tf.int32)
    
    def on_train_begin(self, logs=None):
        # Enable mixed precision
        policy = tf.keras.mixed_precision.Policy('mixed_float16')
        tf.keras.mixed_precision.set_global_policy(policy)
        
        # Wrap optimizer with loss scaling
        self.model.optimizer = tf.keras.mixed_precision.LossScaleOptimizer(
            self.model.optimizer,
            dynamic=True,
            initial_scale=self.loss_scale
        )
    
    def on_batch_end(self, batch, logs=None):
        # Monitor loss scaling stability
        if hasattr(self.model.optimizer, 'loss_scale'):
            current_scale = self.model.optimizer.loss_scale
            
            # Check for gradient overflow
            if tf.math.is_finite(logs.get('loss', 0)):
                self.good_steps.assign_add(1)
                self.bad_steps.assign(0)
                
                # Increase scale after sustained good steps
                if self.good_steps >= 2000:
                    new_scale = tf.minimum(current_scale * 2, 65536.0)
                    self.model.optimizer.loss_scale.assign(new_scale)
                    self.good_steps.assign(0)
            else:
                self.bad_steps.assign_add(1)
                self.good_steps.assign(0)
                
                # Decrease scale on gradient overflow
                new_scale = tf.maximum(current_scale / 2, 1.0)
                self.model.optimizer.loss_scale.assign(new_scale)
```

**Key Points**

- Custom layers provide architectural flexibility through subclassing `tf.keras.layers.Layer` with proper `build`, `call`, and configuration methods
- Custom activation functions enable specialized non-linearities and can be parameterized for learnable behavior
- Custom loss functions address domain-specific optimization objectives, supporting classification, regression, and specialized tasks like contrastive learning
- Custom metrics offer interpretable performance measures beyond standard accuracy, including F1-score, IoU, and domain-specific evaluations
- Custom optimizers implement specialized update rules, adaptive learning strategies, and techniques like layer-wise adaptive scaling
- Custom callbacks extend training capabilities with monitoring, scheduling, model intervention, and distributed training support

**Implementation Considerations**

[Inference] Custom components require careful consideration of computational efficiency, memory usage, and gradient flow. [Inference] Proper serialization support through `get_config` methods ensures model saving and loading functionality. [Inference] Integration with TensorFlow's graph execution and eager execution modes may require specific implementation approaches.

**Performance Optimization**

[Inference] Custom components should leverage TensorFlow's vectorized operations and avoid Python loops in computational paths. [Inference] GPU acceleration benefits from tensor operations that can be efficiently parallelized. [Inference] Memory management becomes critical for custom components processing large datasets or maintaining internal state.

---


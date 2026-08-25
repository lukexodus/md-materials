## Learning Rate Scheduling


Learning rate scheduling adjusts the learning rate during training to improve convergence and final performance. Proper scheduling balances exploration and exploitation throughout training.

**Step Decay Scheduling**

Step decay reduces learning rate at predetermined intervals:

```python
class StepDecay:
    def __init__(self, initial_lr=0.01, drop_rate=0.5, epochs_drop=10):
        self.initial_lr = initial_lr
        self.drop_rate = drop_rate
        self.epochs_drop = epochs_drop
    
    def __call__(self, epoch):
        return self.initial_lr * (self.drop_rate ** (epoch // self.epochs_drop))

# TensorFlow step decay
initial_learning_rate = 0.1
lr_schedule = tf.keras.optimizers.schedules.ExponentialDecay(
    initial_learning_rate,
    decay_steps=1000,
    decay_rate=0.9,
    staircase=True
)

optimizer = tf.keras.optimizers.Adam(learning_rate=lr_schedule)
```

**Exponential and Polynomial Decay**

Smooth decay functions provide gradual learning rate reduction:

```python
# Exponential decay
exponential_decay = tf.keras.optimizers.schedules.ExponentialDecay(
    initial_learning_rate=0.01,
    decay_steps=1000,
    decay_rate=0.95,
    staircase=False
)

# Polynomial decay
polynomial_decay = tf.keras.optimizers.schedules.PolynomialDecay(
    initial_learning_rate=0.01,
    decay_steps=5000,
    end_learning_rate=0.0001,
    power=0.5
)

# Inverse time decay
inverse_time_decay = tf.keras.optimizers.schedules.InverseTimeDecay(
    initial_learning_rate=0.01,
    decay_steps=1000,
    decay_rate=0.5,
    staircase=False
)
```

**Cosine Annealing**

Cosine annealing provides smooth learning rate transitions with periodic restarts:

```python
class CosineAnnealingSchedule(tf.keras.optimizers.schedules.LearningRateSchedule):
    def __init__(self, initial_learning_rate, T_max, eta_min=0):
        self.initial_learning_rate = initial_learning_rate
        self.T_max = T_max
        self.eta_min = eta_min
    
    def __call__(self, step):
        step = tf.cast(step, tf.float32)
        T_max = tf.cast(self.T_max, tf.float32)
        
        return self.eta_min + (self.initial_learning_rate - self.eta_min) * \
               (1 + tf.cos(tf.constant(np.pi) * step / T_max)) / 2
    
    def get_config(self):
        return {
            'initial_learning_rate': self.initial_learning_rate,
            'T_max': self.T_max,
            'eta_min': self.eta_min
        }

# Cosine annealing with restarts
class CosineAnnealingWarmRestarts(tf.keras.optimizers.schedules.LearningRateSchedule):
    def __init__(self, initial_learning_rate, T_0, T_mult=1, eta_min=0):
        self.initial_learning_rate = initial_learning_rate
        self.T_0 = T_0
        self.T_mult = T_mult
        self.eta_min = eta_min
    
    def __call__(self, step):
        step = tf.cast(step, tf.float32)
        
        # Calculate current cycle
        T_cur = step
        T_i = tf.cast(self.T_0, tf.float32)
        
        # Handle multiple restarts
        while T_cur >= T_i:
            T_cur = T_cur - T_i
            T_i = T_i * self.T_mult
        
        return self.eta_min + (self.initial_learning_rate - self.eta_min) * \
               (1 + tf.cos(tf.constant(np.pi) * T_cur / T_i)) / 2

# Usage
cosine_schedule = CosineAnnealingSchedule(
    initial_learning_rate=0.01,
    T_max=1000
)

optimizer = tf.keras.optimizers.Adam(learning_rate=cosine_schedule)
```

**Cyclical Learning Rates**

Cyclical learning rates oscillate between minimum and maximum values:

```python
class CyclicalLearningRate(tf.keras.optimizers.schedules.LearningRateSchedule):
    def __init__(self, base_lr=0.001, max_lr=0.006, step_size=2000, mode='triangular'):
        self.base_lr = base_lr
        self.max_lr = max_lr
        self.step_size = step_size
        self.mode = mode
    
    def __call__(self, step):
        step = tf.cast(step, tf.float32)
        step_size = tf.cast(self.step_size, tf.float32)
        
        cycle = tf.floor(1 + step / (2 * step_size))
        x = tf.abs(step / step_size - 2 * cycle + 1)
        
        if self.mode == 'triangular':
            lr = self.base_lr + (self.max_lr - self.base_lr) * tf.maximum(0.0, (1 - x))
        elif self.mode == 'triangular2':
            lr = self.base_lr + (self.max_lr - self.base_lr) * tf.maximum(0.0, (1 - x)) / tf.pow(2.0, cycle - 1)
        else:  # exp_range
            gamma = 1.0
            lr = self.base_lr + (self.max_lr - self.base_lr) * tf.maximum(0.0, (1 - x)) * tf.pow(gamma, step)
        
        return lr

# One-cycle learning rate policy
class OneCycleLR(tf.keras.optimizers.schedules.LearningRateSchedule):
    def __init__(self, max_lr, total_steps, pct_start=0.3, anneal_strategy='cos', div_factor=25):
        self.max_lr = max_lr
        self.total_steps = total_steps
        self.pct_start = pct_start
        self.anneal_strategy = anneal_strategy
        self.div_factor = div_factor
        
        self.initial_lr = max_lr / div_factor
        self.final_lr = self.initial_lr / 100
        self.step_up = int(total_steps * pct_start)
        self.step_down = total_steps - self.step_up
    
    def __call__(self, step):
        step = tf.cast(step, tf.float32)
        
        if step <= self.step_up:
            # Warmup phase
            return self.initial_lr + (self.max_lr - self.initial_lr) * step / self.step_up
        else:
            # Annealing phase
            step_down_progress = (step - self.step_up) / self.step_down
            
            if self.anneal_strategy == 'cos':
                return self.final_lr + (self.max_lr - self.final_lr) * \
                       (1 + tf.cos(tf.constant(np.pi) * step_down_progress)) / 2
            else:  # linear
                return self.max_lr - (self.max_lr - self.final_lr) * step_down_progress
```

**Adaptive Learning Rate Based on Performance**

Performance-based scheduling adjusts rates based on validation metrics:

```python
class ReduceLROnPlateau:
    def __init__(self, monitor='val_loss', factor=0.2, patience=10, 
                 min_lr=0, mode='min', threshold=1e-4, cooldown=0):
        self.monitor = monitor
        self.factor = factor
        self.patience = patience
        self.min_lr = min_lr
        self.mode = mode
        self.threshold = threshold
        self.cooldown = cooldown
        
        self.wait = 0
        self.cooldown_counter = 0
        self.best = float('inf') if mode == 'min' else -float('inf')
        
    def __call__(self, logs, current_lr):
        current = logs.get(self.monitor)
        
        if current is None:
            return current_lr
        
        if self.cooldown_counter > 0:
            self.cooldown_counter -= 1
            return current_lr
        
        if self.mode == 'min':
            if current < self.best - self.threshold:
                self.best = current
                self.wait = 0
            else:
                self.wait += 1
        else:
            if current > self.best + self.threshold:
                self.best = current
                self.wait = 0
            else:
                self.wait += 1
        
        if self.wait >= self.patience:
            new_lr = max(current_lr * self.factor, self.min_lr)
            self.wait = 0
            self.cooldown_counter = self.cooldown
            return new_lr
        
        return current_lr

# TensorFlow callback version
reduce_lr = tf.keras.callbacks.ReduceLROnPlateau(
    monitor='val_loss',
    factor=0.2,
    patience=5,
    min_lr=0.001
)
```

**Warmup Scheduling**

Warmup gradually increases learning rate at training start:

```python
class WarmupSchedule(tf.keras.optimizers.schedules.LearningRateSchedule):
    def __init__(self, initial_learning_rate, warmup_steps, target_lr=None):
        self.initial_learning_rate = initial_learning_rate
        self.warmup_steps = warmup_steps
        self.target_lr = target_lr or initial_learning_rate
    
    def __call__(self, step):
        step = tf.cast(step, tf.float32)
        warmup_steps = tf.cast(self.warmup_steps, tf.float32)
        
        warmup_progress = tf.minimum(step, warmup_steps) / warmup_steps
        
        return self.initial_learning_rate + (self.target_lr - self.initial_learning_rate) * warmup_progress
    
    def get_config(self):
        return {
            'initial_learning_rate': self.initial_learning_rate,
            'warmup_steps': self.warmup_steps,
            'target_lr': self.target_lr
        }

# Combined warmup and cosine decay
class WarmupCosineDecay(tf.keras.optimizers.schedules.LearningRateSchedule):
    def __init__(self, initial_learning_rate, decay_steps, warmup_steps, alpha=0.0):
        self.initial_learning_rate = initial_learning_rate
        self.decay_steps = decay_steps
        self.warmup_steps = warmup_steps
        self.alpha = alpha
    
    def __call__(self, step):
        step = tf.cast(step, tf.float32)
        warmup_steps = tf.cast(self.warmup_steps, tf.float32)
        decay_steps = tf.cast(self.decay_steps, tf.float32)
        
        # Warmup phase
        def warmup_lr():
            return self.initial_learning_rate * step / warmup_steps
        
        # Cosine decay phase
        def decay_lr():
            completed_fraction = (step - warmup_steps) / (decay_steps - warmup_steps)
            cosine_decayed = 0.5 * (1.0 + tf.cos(tf.constant(np.pi) * completed_fraction))
            return (self.initial_learning_rate - self.alpha) * cosine_decayed + self.alpha
        
        return tf.cond(step < warmup_steps, warmup_lr, decay_lr)
```


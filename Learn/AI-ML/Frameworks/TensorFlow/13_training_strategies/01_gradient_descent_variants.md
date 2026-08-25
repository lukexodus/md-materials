## Gradient Descent Variants


Gradient descent optimization forms the foundation of neural network training. Different variants address specific challenges in parameter optimization and convergence behavior.

**Stochastic Gradient Descent (SGD)**

Basic SGD updates parameters using individual sample gradients or mini-batches:

```python
class SGDOptimizer:
    def __init__(self, learning_rate=0.01):
        self.learning_rate = learning_rate
    
    def update(self, params, gradients):
        for param, grad in zip(params, gradients):
            param.assign_sub(self.learning_rate * grad)

# TensorFlow implementation
optimizer = tf.keras.optimizers.SGD(learning_rate=0.01)
model.compile(optimizer=optimizer, loss='categorical_crossentropy', metrics=['accuracy'])
```

**Momentum-based Methods**

Momentum accelerates gradient descent by accumulating past gradients:

```python
class MomentumSGD:
    def __init__(self, learning_rate=0.01, momentum=0.9):
        self.learning_rate = learning_rate
        self.momentum = momentum
        self.velocity = {}
    
    def update(self, params, gradients):
        for i, (param, grad) in enumerate(zip(params, gradients)):
            if i not in self.velocity:
                self.velocity[i] = tf.zeros_like(param)
            
            self.velocity[i] = self.momentum * self.velocity[i] + self.learning_rate * grad
            param.assign_sub(self.velocity[i])

# Nesterov momentum variant
optimizer = tf.keras.optimizers.SGD(
    learning_rate=0.01, 
    momentum=0.9, 
    nesterov=True
)
```

**Adaptive Learning Rate Methods**

AdaGrad adapts learning rates based on historical gradient information:

```python
class AdaGrad:
    def __init__(self, learning_rate=0.01, epsilon=1e-8):
        self.learning_rate = learning_rate
        self.epsilon = epsilon
        self.accumulated_gradients = {}
    
    def update(self, params, gradients):
        for i, (param, grad) in enumerate(zip(params, gradients)):
            if i not in self.accumulated_gradients:
                self.accumulated_gradients[i] = tf.zeros_like(param)
            
            self.accumulated_gradients[i] += tf.square(grad)
            adapted_lr = self.learning_rate / (tf.sqrt(self.accumulated_gradients[i]) + self.epsilon)
            param.assign_sub(adapted_lr * grad)

# TensorFlow AdaGrad
optimizer = tf.keras.optimizers.Adagrad(learning_rate=0.01)
```

**RMSprop and Adam Optimization**

RMSprop addresses AdaGrad's aggressive learning rate reduction:

```python
class RMSprop:
    def __init__(self, learning_rate=0.001, rho=0.9, epsilon=1e-8):
        self.learning_rate = learning_rate
        self.rho = rho
        self.epsilon = epsilon
        self.moving_avg = {}
    
    def update(self, params, gradients):
        for i, (param, grad) in enumerate(zip(params, gradients)):
            if i not in self.moving_avg:
                self.moving_avg[i] = tf.zeros_like(param)
            
            self.moving_avg[i] = self.rho * self.moving_avg[i] + (1 - self.rho) * tf.square(grad)
            adapted_lr = self.learning_rate / (tf.sqrt(self.moving_avg[i]) + self.epsilon)
            param.assign_sub(adapted_lr * grad)

# Adam combines momentum and RMSprop
optimizer = tf.keras.optimizers.Adam(
    learning_rate=0.001,
    beta_1=0.9,
    beta_2=0.999,
    epsilon=1e-7
)
```

**Advanced Optimization Algorithms**

AdamW incorporates decoupled weight decay:

```python
class AdamW:
    def __init__(self, learning_rate=0.001, beta_1=0.9, beta_2=0.999, 
                 weight_decay=0.01, epsilon=1e-8):
        self.learning_rate = learning_rate
        self.beta_1 = beta_1
        self.beta_2 = beta_2
        self.weight_decay = weight_decay
        self.epsilon = epsilon
        self.m = {}  # First moment
        self.v = {}  # Second moment
        self.t = 0   # Time step
    
    def update(self, params, gradients):
        self.t += 1
        
        for i, (param, grad) in enumerate(zip(params, gradients)):
            if i not in self.m:
                self.m[i] = tf.zeros_like(param)
                self.v[i] = tf.zeros_like(param)
            
            # Update biased first and second moment estimates
            self.m[i] = self.beta_1 * self.m[i] + (1 - self.beta_1) * grad
            self.v[i] = self.beta_2 * self.v[i] + (1 - self.beta_2) * tf.square(grad)
            
            # Bias correction
            m_hat = self.m[i] / (1 - self.beta_1 ** self.t)
            v_hat = self.v[i] / (1 - self.beta_2 ** self.t)
            
            # Apply weight decay
            param.assign_sub(self.weight_decay * self.learning_rate * param)
            
            # Apply Adam update
            param.assign_sub(self.learning_rate * m_hat / (tf.sqrt(v_hat) + self.epsilon))

# TensorFlow AdamW
optimizer = tf.keras.optimizers.AdamW(
    learning_rate=0.001,
    weight_decay=0.004
)
```

**Gradient Descent Comparison and Selection**

[Inference] Different optimizers excel in different scenarios. SGD with momentum often performs well on large datasets and provides good generalization. Adam variants typically converge faster on smaller datasets and complex architectures. AdamW addresses Adam's weight decay issues for better regularization.

**Second-order Methods**

L-BFGS approximates second-order information for faster convergence:

```python
# L-BFGS for small to medium problems
@tf.function
def lbfgs_training_step(model, x, y, optimizer_state):
    def loss_fn():
        predictions = model(x, training=True)
        return tf.keras.losses.categorical_crossentropy(y, predictions)
    
    return tfp.optimizer.lbfgs_minimize(
        loss_fn,
        initial_position=model.trainable_variables,
        num_correction_pairs=10,
        tolerance=1e-8
    )
```


## Dropout and Batch Normalization


Dropout and batch normalization are fundamental regularization techniques that address different aspects of training stability and overfitting prevention.

**Dropout Implementation and Variants**

Standard dropout randomly sets activations to zero during training:

```python
class CustomDropout(tf.keras.layers.Layer):
    def __init__(self, rate=0.5, noise_shape=None, seed=None, **kwargs):
        super(CustomDropout, self).__init__(**kwargs)
        self.rate = rate
        self.noise_shape = noise_shape
        self.seed = seed
    
    def call(self, inputs, training=None):
        if training:
            return tf.nn.dropout(inputs, rate=self.rate, noise_shape=self.noise_shape, seed=self.seed)
        return inputs
    
    def get_config(self):
        config = super(CustomDropout, self).get_config()
        config.update({
            'rate': self.rate,
            'noise_shape': self.noise_shape,
            'seed': self.seed
        })
        return config

# Spatial dropout for convolutional layers
class SpatialDropout2D(tf.keras.layers.Layer):
    def __init__(self, rate=0.5, **kwargs):
        super(SpatialDropout2D, self).__init__(**kwargs)
        self.rate = rate
    
    def call(self, inputs, training=None):
        if training:
            input_shape = tf.shape(inputs)
            noise_shape = (input_shape[0], 1, 1, input_shape[3])
            return tf.nn.dropout(inputs, rate=self.rate, noise_shape=noise_shape)
        return inputs

# DropConnect - randomly set weights to zero instead of activations
class DropConnect(tf.keras.layers.Layer):
    def __init__(self, units, drop_rate=0.5, **kwargs):
        super(DropConnect, self).__init__(**kwargs)
        self.units = units
        self.drop_rate = drop_rate
    
    def build(self, input_shape):
        self.kernel = self.add_weight(
            name='kernel',
            shape=(input_shape[-1], self.units),
            initializer='glorot_uniform',
            trainable=True
        )
        self.bias = self.add_weight(
            name='bias',
            shape=(self.units,),
            initializer='zeros',
            trainable=True
        )
    
    def call(self, inputs, training=None):
        if training:
            # Apply dropout to weights
            dropped_kernel = tf.nn.dropout(self.kernel, rate=self.drop_rate)
            outputs = tf.matmul(inputs, dropped_kernel) + self.bias
        else:
            # Scale weights by keep probability during inference
            scaled_kernel = self.kernel * (1 - self.drop_rate)
            outputs = tf.matmul(inputs, scaled_kernel) + self.bias
        
        return outputs

# Variational dropout with learnable rates
class VariationalDropout(tf.keras.layers.Layer):
    def __init__(self, units, initial_log_alpha=-10.0, **kwargs):
        super(VariationalDropout, self).__init__(**kwargs)
        self.units = units
        self.initial_log_alpha = initial_log_alpha
    
    def build(self, input_shape):
        self.kernel_mu = self.add_weight(
            name='kernel_mu',
            shape=(input_shape[-1], self.units),
            initializer='glorot_uniform',
            trainable=True
        )
        self.kernel_log_alpha = self.add_weight(
            name='kernel_log_alpha',
            shape=(input_shape[-1], self.units),
            initializer=tf.constant_initializer(self.initial_log_alpha),
            trainable=True
        )
        self.bias = self.add_weight(
            name='bias',
            shape=(self.units,),
            initializer='zeros',
            trainable=True
        )
    
    def call(self, inputs, training=None):
        if training:
            # Sample weights from variational distribution
            alpha = tf.exp(self.kernel_log_alpha)
            epsilon = tf.random.normal(tf.shape(self.kernel_mu))
            kernel = self.kernel_mu + epsilon * tf.sqrt(alpha * tf.square(self.kernel_mu))
            
            # Add KL divergence to losses
            kl_divergence = 0.5 * tf.reduce_sum(
                tf.math.log1p(alpha) - self.kernel_log_alpha
            )
            self.add_loss(kl_divergence)
            
            return tf.matmul(inputs, kernel) + self.bias
        else:
            return tf.matmul(inputs, self.kernel_mu) + self.bias
```

**Batch Normalization and Variants**

Batch normalization normalizes layer inputs to improve training stability:

```python
class CustomBatchNormalization(tf.keras.layers.Layer):
    def __init__(self, momentum=0.99, epsilon=1e-3, center=True, scale=True, **kwargs):
        super(CustomBatchNormalization, self).__init__(**kwargs)
        self.momentum = momentum
        self.epsilon = epsilon
        self.center = center
        self.scale = scale
    
    def build(self, input_shape):
        dim = input_shape[-1]
        
        if self.scale:
            self.gamma = self.add_weight(
                name='gamma',
                shape=(dim,),
                initializer='ones',
                trainable=True
            )
        else:
            self.gamma = None
        
        if self.center:
            self.beta = self.add_weight(
                name='beta',
                shape=(dim,),
                initializer='zeros',
                trainable=True
            )
        else:
            self.beta = None
        
        self.moving_mean = self.add_weight(
            name='moving_mean',
            shape=(dim,),
            initializer='zeros',
            trainable=False
        )
        self.moving_variance = self.add_weight(
            name='moving_variance',
            shape=(dim,),
            initializer='ones',
            trainable=False
        )
    
    def call(self, inputs, training=None):
        if training:
            # Compute batch statistics
            batch_mean = tf.reduce_mean(inputs, axis=0)
            batch_variance = tf.reduce_mean(tf.square(inputs - batch_mean), axis=0)
            
            # Update moving statistics
            self.moving_mean.assign(
                self.momentum * self.moving_mean + (1 - self.momentum) * batch_mean
            )
            self.moving_variance.assign(
                self.momentum * self.moving_variance + (1 - self.momentum) * batch_variance
            )
            
            # Normalize using batch statistics
            normalized = (inputs - batch_mean) / tf.sqrt(batch_variance + self.epsilon)
        else:
            # Normalize using moving statistics
            normalized = (inputs - self.moving_mean) / tf.sqrt(self.moving_variance + self.epsilon)
        
        # Scale and shift
        if self.scale:
            normalized = normalized * self.gamma
        if self.center:
            normalized = normalized + self.beta
        
        return normalized

# Layer normalization
class LayerNormalization(tf.keras.layers.Layer):
    def __init__(self, epsilon=1e-6, center=True, scale=True, **kwargs):
        super(LayerNormalization, self).__init__(**kwargs)
        self.epsilon = epsilon
        self.center = center
        self.scale = scale
    
    def build(self, input_shape):
        dim = input_shape[-1]
        
        if self.scale:
            self.gamma = self.add_weight(
                name='gamma',
                shape=(dim,),
                initializer='ones',
                trainable=True
            )
        else:
            self.gamma = None
        
        if self.center:
            self.beta = self.add_weight(
                name='beta',
                shape=(dim,),
                initializer='zeros',
                trainable=True
            )
        else:
            self.beta = None
    
    def call(self, inputs):
        # Normalize across feature dimension
        mean = tf.reduce_mean(inputs, axis=-1, keepdims=True)
        variance = tf.reduce_mean(tf.square(inputs - mean), axis=-1, keepdims=True)
        normalized = (inputs - mean) / tf.sqrt(variance + self.epsilon)
        
        # Scale and shift
        if self.scale:
            normalized = normalized * self.gamma
        if self.center:
            normalized = normalized + self.beta
        
        return normalized

# Group normalization
class GroupNormalization(tf.keras.layers.Layer):
    def __init__(self, groups=32, epsilon=1e-6, center=True, scale=True, **kwargs):
        super(GroupNormalization, self).__init__(**kwargs)
        self.groups = groups
        self.epsilon = epsilon
        self.center = center
        self.scale = scale
    
    def build(self, input_shape):
        dim = input_shape[-1]
        
        if dim % self.groups != 0:
            raise ValueError(f'Number of channels {dim} must be divisible by groups {self.groups}')
        
        if self.scale:
            self.gamma = self.add_weight(
                name='gamma',
                shape=(dim,),
                initializer='ones',
                trainable=True
            )
        else:
            self.gamma = None
        
        if self.center:
            self.beta = self.add_weight(
                name='beta',
                shape=(dim,),
                initializer='zeros',
                trainable=True
            )
        else:
            self.beta = None
    
    def call(self, inputs):
        input_shape = tf.shape(inputs)
        batch_size, height, width, channels = input_shape[0], input_shape[1], input_shape[2], input_shape[3]
        
        # Reshape for group normalization
        group_shape = [batch_size, height, width, self.groups, channels // self.groups]
        grouped_inputs = tf.reshape(inputs, group_shape)
        
        # Compute group statistics
        mean = tf.reduce_mean(grouped_inputs, axis=[1, 2, 4], keepdims=True)
        variance = tf.reduce_mean(tf.square(grouped_inputs - mean), axis=[1, 2, 4], keepdims=True)
        
        # Normalize
        normalized = (grouped_inputs - mean) / tf.sqrt(variance + self.epsilon)
        normalized = tf.reshape(normalized, input_shape)
        
        # Scale and shift
        if self.scale:
            normalized = normalized * self.gamma
        if self.center:
            normalized = normalized + self.beta
        
        return normalized

# Instance normalization
class InstanceNormalization(tf.keras.layers.Layer):
    def __init__(self, epsilon=1e-6, center=True, scale=True, **kwargs):
        super(InstanceNormalization, self).__init__(**kwargs)
        self.epsilon = epsilon
        self.center = center
        self.scale = scale
    
    def build(self, input_shape):
        dim = input_shape[-1]
        
        if self.scale:
            self.gamma = self.add_weight(
                name='gamma',
                shape=(dim,),
                initializer='ones',
                trainable=True
            )
        else:
            self.gamma = None
        
        if self.center:
            self.beta = self.add_weight(
                name='beta',
                shape=(dim,),
                initializer='zeros',
                trainable=True
            )
        else:
            self.beta = None
    
    def call(self, inputs):
        # Normalize per instance and channel
        axes = list(range(1, len(inputs.shape) - 1))  # All spatial dimensions
        mean = tf.reduce_mean(inputs, axis=axes, keepdims=True)
        variance = tf.reduce_mean(tf.square(inputs - mean), axis=axes, keepdims=True)
        normalized = (inputs - mean) / tf.sqrt(variance + self.epsilon)
        
        # Scale and shift
        if self.scale:
            normalized = normalized * self.gamma
        if self.center:
            normalized = normalized + self.beta
        
        return normalized
```

**Adaptive Normalization Techniques**

Advanced normalization methods that adapt to data characteristics:

```python
# Adaptive batch normalization
class AdaptiveBatchNormalization(tf.keras.layers.Layer):
    def __init__(self, momentum=0.99, epsilon=1e-3, **kwargs):
        super(AdaptiveBatchNormalization, self).__init__(**kwargs)
        self.momentum = momentum
        self.epsilon = epsilon
    
    def build(self, input_shape):
        dim = input_shape[-1]
        
        self.gamma = self.add_weight('gamma', shape=(dim,), initializer='ones', trainable=True)
        self.beta = self.add_weight('beta', shape=(dim,), initializer='zeros', trainable=True)
        self.moving_mean = self.add_weight('moving_mean', shape=(dim,), initializer='zeros', trainable=False)
        self.moving_variance = self.add_weight('moving_variance', shape=(dim,), initializer='ones', trainable=False)
        
        # Adaptive parameters
        self.adaptive_gamma = self.add_weight('adaptive_gamma', shape=(dim,), initializer='ones', trainable=True)
        self.adaptive_beta = self.add_weight('adaptive_beta', shape=(dim,), initializer='zeros', trainable=True)
    
    def call(self, inputs, training=None):
        if training:
            batch_mean = tf.reduce_mean(inputs, axis=0)
            batch_variance = tf.reduce_mean(tf.square(inputs - batch_mean), axis=0)
            
            # Update moving statistics
            self.moving_mean.assign(self.momentum * self.moving_mean + (1 - self.momentum) * batch_mean)
            self.moving_variance.assign(self.momentum * self.moving_variance + (1 - self.momentum) * batch_variance)
            
            # Compute adaptive parameters based on batch statistics
            batch_std = tf.sqrt(batch_variance + self.epsilon)
            adaptive_factor = tf.sigmoid(self.adaptive_gamma * batch_std + self.adaptive_beta)
            
            # Mix batch and instance normalization
            batch_norm = (inputs - batch_mean) / tf.sqrt(batch_variance + self.epsilon)
            instance_norm = (inputs - tf.reduce_mean(inputs, axis=-1, keepdims=True)) / \
                          tf.sqrt(tf.reduce_mean(tf.square(inputs - tf.reduce_mean(inputs, axis=-1, keepdims=True)), axis=-1, keepdims=True) + self.epsilon)
            
            normalized = adaptive_factor * batch_norm + (1 - adaptive_factor) * instance_norm
        else:
            normalized = (inputs - self.moving_mean) / tf.sqrt(self.moving_variance + self.epsilon)
        
        return normalized * self.gamma + self.beta
```


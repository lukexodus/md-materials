## Regularization Techniques


Regularization prevents overfitting by constraining model complexity and improving generalization. Various regularization techniques address different aspects of overfitting.

**Weight Regularization**

L1 and L2 regularization add penalty terms to the loss function:

```python
# L1 regularization (Lasso)
def l1_regularization(weights, lambda_reg=0.01):
    return lambda_reg * tf.reduce_sum(tf.abs(weights))

# L2 regularization (Ridge)
def l2_regularization(weights, lambda_reg=0.01):
    return lambda_reg * tf.reduce_sum(tf.square(weights))

# Elastic Net (L1 + L2)
def elastic_net_regularization(weights, lambda_l1=0.01, lambda_l2=0.01):
    l1_penalty = lambda_l1 * tf.reduce_sum(tf.abs(weights))
    l2_penalty = lambda_l2 * tf.reduce_sum(tf.square(weights))
    return l1_penalty + l2_penalty

# Apply regularization in custom training loop
@tf.function
def train_step_with_regularization(x, y, model, optimizer, lambda_reg=0.01):
    with tf.GradientTape() as tape:
        predictions = model(x, training=True)
        loss = tf.keras.losses.categorical_crossentropy(y, predictions)
        
        # Add L2 regularization
        regularization_loss = 0
        for layer in model.layers:
            if hasattr(layer, 'kernel'):
                regularization_loss += l2_regularization(layer.kernel, lambda_reg)
        
        total_loss = loss + regularization_loss
    
    gradients = tape.gradient(total_loss, model.trainable_variables)
    optimizer.apply_gradients(zip(gradients, model.trainable_variables))
    
    return total_loss, loss, regularization_loss

# Built-in Keras regularizers
from tensorflow.keras import regularizers

model = tf.keras.Sequential([
    tf.keras.layers.Dense(128, 
                         kernel_regularizer=regularizers.l2(0.01),
                         bias_regularizer=regularizers.l1(0.01),
                         activation='relu'),
    tf.keras.layers.Dense(64,
                         kernel_regularizer=regularizers.l1_l2(l1=0.01, l2=0.01),
                         activation='relu'),
    tf.keras.layers.Dense(10, activation='softmax')
])
```

**Activity Regularization**

Regularizing layer activations rather than weights:

```python
class ActivityRegularizedLayer(tf.keras.layers.Layer):
    def __init__(self, units, activity_regularizer=None, **kwargs):
        super(ActivityRegularizedLayer, self).__init__(**kwargs)
        self.units = units
        self.activity_regularizer = activity_regularizer
        self.dense = tf.keras.layers.Dense(units)
    
    def call(self, inputs, training=None):
        outputs = self.dense(inputs)
        
        if training and self.activity_regularizer:
            # Add activity regularization to losses
            regularization_loss = self.activity_regularizer(outputs)
            self.add_loss(regularization_loss)
        
        return outputs

# Sparsity-inducing activity regularization
def sparsity_regularizer(lambda_reg=0.01, target_sparsity=0.05):
    def regularizer(activations):
        mean_activation = tf.reduce_mean(activations, axis=0)
        kl_divergence = target_sparsity * tf.math.log(target_sparsity / (mean_activation + 1e-8)) + \
                       (1 - target_sparsity) * tf.math.log((1 - target_sparsity) / (1 - mean_activation + 1e-8))
        return lambda_reg * tf.reduce_sum(kl_divergence)
    
    return regularizer

# Usage with built-in activity regularization
model = tf.keras.Sequential([
    tf.keras.layers.Dense(128, 
                         activation='relu',
                         activity_regularizer=regularizers.l2(0.01)),
    tf.keras.layers.Dense(10, activation='softmax')
])
```

**Data Augmentation as Regularization**

Data augmentation increases training data diversity:

```python
# Image data augmentation
def create_augmented_dataset(images, labels, augmentation_factor=2):
    datagen = tf.keras.preprocessing.image.ImageDataGenerator(
        rotation_range=20,
        width_shift_range=0.2,
        height_shift_range=0.2,
        shear_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True,
        fill_mode='nearest'
    )
    
    augmented_images = []
    augmented_labels = []
    
    for _ in range(augmentation_factor):
        for batch in datagen.flow(images, labels, batch_size=len(images)):
            augmented_images.extend(batch[0])
            augmented_labels.extend(batch[1])
            break
    
    return np.array(augmented_images), np.array(augmented_labels)

# TensorFlow data augmentation pipeline
def augment_image(image, label):
    image = tf.image.random_flip_left_right(image)
    image = tf.image.random_brightness(image, max_delta=0.2)
    image = tf.image.random_contrast(image, lower=0.8, upper=1.2)
    image = tf.image.random_saturation(image, lower=0.8, upper=1.2)
    return image, label

dataset = dataset.map(augment_image, num_parallel_calls=tf.data.AUTOTUNE)

# MixUp data augmentation
def mixup_data(x, y, alpha=0.2):
    batch_size = tf.shape(x)[0]
    
    # Sample lambda from Beta distribution
    lam = tf.random.uniform([batch_size, 1, 1, 1]) * alpha
    
    # Create random permutation
    indices = tf.random.shuffle(tf.range(batch_size))
    mixed_x = lam * x + (1 - lam) * tf.gather(x, indices)
    
    # Mix labels
    y_a, y_b = y, tf.gather(y, indices)
    mixed_y = lam[:, 0, 0, 0:1] * y_a + (1 - lam[:, 0, 0, 0:1]) * y_b
    
    return mixed_x, mixed_y

# CutMix augmentation
def cutmix_data(x, y, alpha=1.0):
    batch_size = tf.shape(x)[0]
    image_height, image_width = tf.shape(x)[1], tf.shape(x)[2]
    
    # Sample lambda from Beta distribution
    lam = tf.random.uniform([], minval=0, maxval=alpha)
    
    # Calculate cut dimensions
    cut_ratio = tf.sqrt(1 - lam)
    cut_w = tf.cast(image_width * cut_ratio, tf.int32)
    cut_h = tf.cast(image_height * cut_ratio, tf.int32)
    
    # Random center point
    cx = tf.random.uniform([], minval=0, maxval=image_width, dtype=tf.int32)
    cy = tf.random.uniform([], minval=0, maxval=image_height, dtype=tf.int32)
    
    # Calculate boundaries
    x1 = tf.clip_by_value(cx - cut_w // 2, 0, image_width)
    y1 = tf.clip_by_value(cy - cut_h // 2, 0, image_height)
    x2 = tf.clip_by_value(cx + cut_w // 2, 0, image_width)
    y2 = tf.clip_by_value(cy + cut_h // 2, 0, image_height)
    
    # Create random permutation
    indices = tf.random.shuffle(tf.range(batch_size))
    shuffled_x = tf.gather(x, indices)
    shuffled_y = tf.gather(y, indices)
    
    # Apply cutmix
    mask = tf.zeros([image_height, image_width, 1], dtype=tf.bool)
    mask_patch = tf.ones([y2 - y1, x2 - x1, 1], dtype=tf.bool)
    mask = tf.tensor_scatter_nd_update(
        mask, 
        tf.stack([tf.range(y1, y2)[:, None], tf.range(x1, x2)[None, :]], axis=-1),
        mask_patch
    )
    
    mixed_x = tf.where(mask, shuffled_x, x)
    
    # Adjust lambda based on actual cut area
    lam_adjusted = 1 - tf.cast((x2 - x1) * (y2 - y1), tf.float32) / tf.cast(image_height * image_width, tf.float32)
    mixed_y = lam_adjusted * y + (1 - lam_adjusted) * shuffled_y
    
    return mixed_x, mixed_y
```

**Noise Injection**

Adding noise to inputs, weights, or gradients as regularization:

```python
# Input noise injection
class NoisyInput(tf.keras.layers.Layer):
    def __init__(self, noise_std=0.1, **kwargs):
        super(NoisyInput, self).__init__(**kwargs)
        self.noise_std = noise_std
    
    def call(self, inputs, training=None):
        if training:
            noise = tf.random.normal(tf.shape(inputs), stddev=self.noise_std)
            return inputs + noise
        return inputs

# Weight noise injection
class NoisyDense(tf.keras.layers.Layer):
    def __init__(self, units, weight_noise_std=0.01, **kwargs):
        super(NoisyDense, self).__init__(**kwargs)
        self.units = units
        self.weight_noise_std = weight_noise_std
        self.dense = tf.keras.layers.Dense(units)
    
    def call(self, inputs, training=None):
        if training and self.weight_noise_std > 0:
            # Add noise to weights
            original_kernel = self.dense.kernel
            noise = tf.random.normal(tf.shape(original_kernel), stddev=self.weight_noise_std)
            noisy_kernel = original_kernel + noise
            
            # Temporarily replace kernel
            self.dense.kernel.assign(noisy_kernel)
            outputs = self.dense(inputs)
            self.dense.kernel.assign(original_kernel)
            
            return outputs
        return self.dense(inputs)

# Gradient noise injection
class GradientNoiseOptimizer:
    def __init__(self, optimizer, noise_std=0.01, decay_rate=0.99):
        self.optimizer = optimizer
        self.noise_std = noise_std
        self.decay_rate = decay_rate
        self.current_std = noise_std
    
    def apply_gradients(self, grads_and_vars):
        # Add noise to gradients
        noisy_grads_and_vars = []
        for grad, var in grads_and_vars:
            if grad is not None:
                noise = tf.random.normal(tf.shape(grad), stddev=self.current_std)
                noisy_grad = grad + noise
                noisy_grads_and_vars.append((noisy_grad, var))
            else:
                noisy_grads_and_vars.append((grad, var))
        
        # Decay noise over time
        self.current_std *= self.decay_rate
        
        return self.optimizer.apply_gradients(noisy_grads_and_vars)
```

**Spectral Regularization**

Spectral normalization constrains the Lipschitz constant:

```python
class SpectralNormalization(tf.keras.layers.Wrapper):
    def __init__(self, layer, power_iterations=1, **kwargs):
        super(SpectralNormalization, self).__init__(layer, **kwargs)
        self.power_iterations = power_iterations
    
    def build(self, input_shape):
        self.layer.build(input_shape)
        
        # Initialize spectral normalization variables
        if hasattr(self.layer, 'kernel'):
            kernel_shape = self.layer.kernel.shape
            self.u = self.add_weight(
                name='sn_u',
                shape=(1, kernel_shape[-1]),
                initializer='random_normal',
                trainable=False
            )
        
        super(SpectralNormalization, self).build(input_shape)
    
    def call(self, inputs, training=None):
        if hasattr(self.layer, 'kernel'):
            kernel = self.layer.kernel
            
            # Power iteration method to find largest singular value
            w_reshaped = tf.reshape(kernel, [-1, kernel.shape[-1]])
            u = self.u
            
            for _ in range(self.power_iterations):
                v = tf.nn.l2_normalize(tf.matmul(u, w_reshaped, transpose_b=True))
                u = tf.nn.l2_normalize(tf.matmul(v, w_reshaped))
            
            # Update u
            self.u.assign(u)
            
            # Calculate spectral norm
            sigma = tf.matmul(tf.matmul(v, w_reshaped), u, transpose_b=True)
            
            # Normalize kernel by spectral norm
            self.layer.kernel.assign(kernel / sigma)
            
        outputs = self.layer(inputs, training=training)
        
        # Restore original kernel
        if hasattr(self.layer, 'kernel'):
            self.layer.kernel.assign(kernel)
        
        return outputs

# Usage
spectral_dense = SpectralNormalization(tf.keras.layers.Dense(128, activation='relu'))
```


## Model Compilation and Configuration


Model compilation configures the learning process by specifying optimizer, loss function, and evaluation metrics.

**Compilation Parameters** The compile method requires optimizer, loss function, and optional metrics:

```python
# Basic compilation
model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

# Advanced compilation with custom parameters
model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=0.001, beta_1=0.9, beta_2=0.999),
    loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=False),
    metrics=[
        tf.keras.metrics.SparseCategoricalAccuracy(),
        tf.keras.metrics.TopKCategoricalAccuracy(k=3)
    ]
)
```

**Optimizer Selection** Different optimizers suit various training scenarios:

```python
# Common optimizers
model.compile(optimizer='sgd', loss='mse')                          # Stochastic Gradient Descent
model.compile(optimizer='rmsprop', loss='binary_crossentropy')      # RMSprop
model.compile(optimizer='adam', loss='categorical_crossentropy')    # Adam optimizer
model.compile(optimizer='adamw', loss='sparse_categorical_crossentropy')  # AdamW

# Custom optimizer configuration
optimizer = tf.keras.optimizers.Adam(
    learning_rate=0.001,
    beta_1=0.9,
    beta_2=0.999,
    epsilon=1e-7,
    amsgrad=False
)
model.compile(optimizer=optimizer, loss='mse')
```

**Loss Function Selection** Loss functions depend on the problem type:

```python
# Classification losses
model.compile(optimizer='adam', loss='binary_crossentropy')                    # Binary classification
model.compile(optimizer='adam', loss='categorical_crossentropy')               # Multi-class (one-hot)
model.compile(optimizer='adam', loss='sparse_categorical_crossentropy')        # Multi-class (integer labels)

# Regression losses
model.compile(optimizer='adam', loss='mean_squared_error')                     # MSE
model.compile(optimizer='adam', loss='mean_absolute_error')                    # MAE
model.compile(optimizer='adam', loss='huber_loss')                            # Huber loss

# Custom loss functions
def custom_loss(y_true, y_pred):
    return tf.reduce_mean(tf.square(y_true - y_pred) + 0.1 * tf.abs(y_true - y_pred))

model.compile(optimizer='adam', loss=custom_loss)
```

**Metrics Configuration** Metrics provide training progress monitoring without affecting optimization:

```python
# Single metric
model.compile(optimizer='adam', loss='mse', metrics=['mae'])

# Multiple metrics
model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy', 'sparse_top_k_categorical_accuracy']
)

# Custom metrics
def f1_score(y_true, y_pred):
    # [Inference] - Custom F1 implementation would require precision/recall calculation
    pass

model.compile(optimizer='adam', loss='binary_crossentropy', metrics=[f1_score])
```


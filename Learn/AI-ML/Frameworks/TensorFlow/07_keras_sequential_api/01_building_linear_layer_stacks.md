## Building Linear Layer Stacks


The Sequential model represents a linear stack of layers where data flows sequentially from input to output through each layer in order.

**Sequential Model Creation** Multiple approaches exist for creating Sequential models:

```python
import tensorflow as tf
from tensorflow.keras import Sequential
from tensorflow.keras.layers import Dense, Dropout, BatchNormalization

# Method 1: Initialize empty and add layers
model = Sequential()
model.add(Dense(128, activation='relu', input_shape=(784,)))
model.add(Dropout(0.2))
model.add(Dense(64, activation='relu'))
model.add(Dense(10, activation='softmax'))

# Method 2: Pass layers as list during initialization
model = Sequential([
    Dense(128, activation='relu', input_shape=(784,)),
    Dropout(0.2),
    Dense(64, activation='relu'),
    Dense(10, activation='softmax')
])

# Method 3: Using layer names for identification
model = Sequential([
    Dense(128, activation='relu', input_shape=(784,), name='hidden_1'),
    Dropout(0.2, name='dropout_1'),
    Dense(64, activation='relu', name='hidden_2'),
    Dense(10, activation='softmax', name='output')
])
```

**Input Specification** The first layer requires input shape specification while subsequent layers automatically infer shapes:

```python
# Explicit input shape for first layer
model = Sequential([
    Dense(64, activation='relu', input_shape=(100,)),  # Input: 100 features
    Dense(32, activation='relu'),                       # Automatically infers input shape
    Dense(1, activation='sigmoid')                      # Binary classification output
])

# Alternative using Input layer
model = Sequential([
    tf.keras.Input(shape=(100,)),
    Dense(64, activation='relu'),
    Dense(32, activation='relu'),
    Dense(1, activation='sigmoid')
])
```

**Layer Ordering and Dependencies** Sequential models enforce strict linear ordering where each layer's output becomes the next layer's input:

```python
# Example: Image classification pipeline
model = Sequential([
    tf.keras.layers.Flatten(input_shape=(28, 28)),      # Flatten 2D to 1D
    Dense(128, activation='relu'),                       # Hidden layer
    BatchNormalization(),                                # Normalization
    Dropout(0.3),                                        # Regularization
    Dense(64, activation='relu'),                        # Second hidden layer
    Dense(10, activation='softmax')                      # Output layer
])
```


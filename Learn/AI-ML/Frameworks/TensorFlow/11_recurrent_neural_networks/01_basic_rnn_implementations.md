## Basic RNN Implementations


The fundamental RNN cell processes sequences by maintaining a hidden state that gets updated at each time step. In TensorFlow, basic RNNs can be implemented using `tf.keras.layers.SimpleRNN`.

**Key Points:**

- Simple RNN cells use a single hidden state vector
- Hidden state is computed as: h_t = tanh(W_hh * h_{t-1} + W_ih * x_t + b)
- Suitable for short sequences due to vanishing gradient problems
- Available activation functions include tanh, relu, and sigmoid

**Examples:**

```python
# Basic RNN layer
rnn_layer = tf.keras.layers.SimpleRNN(
    units=64,
    activation='tanh',
    return_sequences=True,
    return_state=False
)

# Complete model
model = tf.keras.Sequential([
    tf.keras.layers.Embedding(vocab_size, embedding_dim),
    tf.keras.layers.SimpleRNN(128, return_sequences=True),
    tf.keras.layers.Dense(num_classes, activation='softmax')
])
```

Basic RNNs suffer from vanishing gradients when processing long sequences, making them impractical for most real-world applications beyond simple pattern recognition tasks.


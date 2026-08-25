## Bidirectional RNN Networks


Bidirectional RNNs process sequences in both forward and backward directions, capturing context from both past and future time steps.

**Key Points:**

- Forward RNN processes sequence from beginning to end
- Backward RNN processes sequence from end to beginning
- Final output concatenates or combines both directions
- Effective for tasks where full sequence context is available

```python
# Bidirectional LSTM
bidirectional_lstm = tf.keras.layers.Bidirectional(
    tf.keras.layers.LSTM(64, return_sequences=True),
    merge_mode='concat'  # Options: 'sum', 'mul', 'ave', 'concat'
)

# Complete bidirectional model
model = tf.keras.Sequential([
    tf.keras.layers.Embedding(vocab_size, 100),
    tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(128)),
    tf.keras.layers.Dense(1, activation='sigmoid')
])
```

Bidirectional networks double the number of parameters and computation time but often provide significant performance improvements for classification and labeling tasks.


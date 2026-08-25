## Attention Mechanisms


Attention mechanisms address the bottleneck problem in seq2seq models by allowing the decoder to access all encoder hidden states, not just the final context vector.

**Key Points:**

- Attention weights computed based on decoder state and encoder outputs
- Weighted sum of encoder outputs provides dynamic context vector
- Bahdanau (additive) and Luong (multiplicative) are common attention types
- Significantly improves performance on long sequences

### Bahdanau Attention Implementation

```python
class BahdanauAttention(tf.keras.layers.Layer):
    def __init__(self, units):
        super().__init__()
        self.W1 = tf.keras.layers.Dense(units)
        self.W2 = tf.keras.layers.Dense(units)
        self.V = tf.keras.layers.Dense(1)
    
    def call(self, query, values):
        # Query: decoder hidden state [batch, hidden]
        # Values: encoder outputs [batch, seq_len, hidden]
        
        query_with_time_axis = tf.expand_dims(query, 1)  # [batch, 1, hidden]
        
        score = self.V(tf.nn.tanh(
            self.W1(query_with_time_axis) + self.W2(values)))  # [batch, seq_len, 1]
        
        attention_weights = tf.nn.softmax(score, axis=1)  # [batch, seq_len, 1]
        context_vector = attention_weights * values  # [batch, seq_len, hidden]
        context_vector = tf.reduce_sum(context_vector, axis=1)  # [batch, hidden]
        
        return context_vector, attention_weights
```

### Luong Attention Implementation

```python
class LuongAttention(tf.keras.layers.Layer):
    def __init__(self, units):
        super().__init__()
        self.W = tf.keras.layers.Dense(units)
    
    def call(self, query, values):
        # Multiplicative attention
        score = tf.matmul(query, self.W(values), transpose_b=True)  # [batch, seq_len]
        attention_weights = tf.nn.softmax(score, axis=1)  # [batch, seq_len]
        
        context_vector = tf.matmul(tf.expand_dims(attention_weights, 1), values)  # [batch, 1, hidden]
        context_vector = tf.squeeze(context_vector, axis=1)  # [batch, hidden]
        
        return context_vector, attention_weights
```


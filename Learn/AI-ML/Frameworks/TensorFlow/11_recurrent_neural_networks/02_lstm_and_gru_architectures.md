## LSTM and GRU Architectures


Long Short-Term Memory (LSTM) and Gated Recurrent Unit (GRU) networks address the vanishing gradient problem through sophisticated gating mechanisms that control information flow.

### LSTM Networks

LSTM cells contain three gates: forget gate, input gate, and output gate, plus a cell state that maintains long-term information.

**Key Points:**

- Forget gate determines what information to discard from cell state
- Input gate controls what new information to store in cell state
- Output gate determines what parts of cell state to output as hidden state
- Cell state provides a highway for gradient flow during backpropagation

```python
# LSTM implementation
lstm_layer = tf.keras.layers.LSTM(
    units=128,
    return_sequences=True,
    return_state=True,
    dropout=0.2,
    recurrent_dropout=0.2
)

# Stacked LSTM
model = tf.keras.Sequential([
    tf.keras.layers.LSTM(256, return_sequences=True),
    tf.keras.layers.LSTM(128, return_sequences=True),
    tf.keras.layers.LSTM(64),
    tf.keras.layers.Dense(num_classes)
])
```

### GRU Networks

GRU cells simplify the LSTM architecture by combining forget and input gates into an update gate and using a reset gate to control access to previous hidden states.

**Key Points:**

- Update gate combines forget and input gate functionality
- Reset gate determines how much past information to forget
- Computationally more efficient than LSTM with similar performance
- Often performs comparably to LSTM on many tasks

```python
# GRU implementation
gru_layer = tf.keras.layers.GRU(
    units=128,
    return_sequences=False,
    dropout=0.3,
    recurrent_dropout=0.3
)
```


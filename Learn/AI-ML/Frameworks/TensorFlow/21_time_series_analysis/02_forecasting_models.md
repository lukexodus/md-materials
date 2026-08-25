## Forecasting Models


### Recurrent Neural Networks (RNNs)

TensorFlow's RNN implementations include LSTM and GRU layers specifically designed for sequential data. These architectures maintain hidden states that capture temporal dependencies across different time horizons. The `tf.keras.layers.LSTM` layer supports bidirectional processing, dropout regularization, and return sequences configuration for multi-step predictions.

### Transformer-Based Architectures

The attention mechanism in transformers has revolutionized time series forecasting. TensorFlow's implementation allows for self-attention layers that can capture long-range dependencies without the vanishing gradient problems of traditional RNNs. Multi-head attention enables the model to focus on different aspects of the temporal patterns simultaneously.

### Convolutional Neural Networks for Time Series

1D convolutional layers in TensorFlow can extract local temporal patterns efficiently. These layers apply filters across the time dimension, identifying recurring patterns and trends. Dilated convolutions enable the model to capture patterns across different time scales without increasing computational complexity significantly.

**Key Points:**

- LSTM/GRU layers handle sequential dependencies through gating mechanisms
- Transformer attention captures long-range temporal relationships
- 1D CNNs extract local temporal features efficiently
- Ensemble methods combine multiple forecasting approaches


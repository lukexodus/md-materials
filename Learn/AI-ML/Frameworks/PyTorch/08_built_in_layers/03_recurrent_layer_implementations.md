## Recurrent Layer Implementations


**LSTM (Long Short-Term Memory)** Addresses vanishing gradient problem in sequential modeling through gating mechanisms. Includes forget gate, input gate, and output gate. Supports bidirectional processing, multiple layers, and dropout regularization.

**GRU (Gated Recurrent Unit)** Simplified alternative to LSTM with fewer parameters. Combines forget and input gates into update gate, plus reset gate. Often achieves comparable performance with reduced computational overhead.

**RNN (Vanilla Recurrent Neural Network)** Basic recurrent layer with tanh or ReLU activation. Suitable for simple sequential tasks but prone to vanishing gradients in long sequences.

**RNNCell, LSTMCell, GRUCell** Single-step variants allowing manual loop control and custom logic integration. Useful for complex architectures requiring step-by-step processing control.


## LSTM and GRU Architectures


Long Short-Term Memory networks and Gated Recurrent Units address the vanishing gradient problem through sophisticated gating mechanisms that control information flow.

**LSTM architecture:** LSTM cells maintain both a hidden state and a cell state, using three gates to control information flow:

**Forget gate:** Determines what information to discard from cell state

- f_t = σ(W_f * [h_{t-1}, x_t] + b_f)
- Sigmoid activation produces values between 0 and 1, representing retention probability

**Input gate:** Controls what new information to store in cell state

- i_t = σ(W_i * [h_{t-1}, x_t] + b_i)
- Works with candidate values: C̃_t = tanh(W_C * [h_{t-1}, x_t] + b_C)

**Output gate:** Determines what parts of cell state to output as hidden state

- o_t = σ(W_o * [h_{t-1}, x_t] + b_o)
- h_t = o_t * tanh(C_t)

**Cell state update:**

- C_t = f_t * C_{t-1} + i_t * C̃_t
- Maintains long-term memory through additive updates

**GRU architecture:** GRU simplifies LSTM design with two gates while maintaining comparable performance:

**Reset gate:** Controls how much past information to forget

- r_t = σ(W_r * [h_{t-1}, x_t] + b_r)

**Update gate:** Controls the balance between past and current information

- z_t = σ(W_z * [h_{t-1}, x_t] + b_z)

**Hidden state update:**

- h̃_t = tanh(W_h * [r_t * h_{t-1}, x_t] + b_h)
- h_t = (1 - z_t) * h_{t-1} + z_t * h̃_t

**Comparative analysis:**

- LSTM provides more fine-grained control over information flow
- GRU has fewer parameters and often trains faster
- Performance differences are task-dependent
- GRU often performs similarly to LSTM on many tasks while being computationally more efficient

**Implementation details:** PyTorch implementations use optimized kernels that compute all gates simultaneously, improving computational efficiency. Both architectures support multi-layer configurations, dropout between layers, and bidirectional processing.


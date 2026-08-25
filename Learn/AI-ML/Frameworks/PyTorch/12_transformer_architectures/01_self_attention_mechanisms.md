## Self-Attention Mechanisms


**Core Self-Attention Formula** Self-attention computes attention weights between all positions in a sequence: Attention(Q,K,V) = softmax(QK^T/√d_k)V. Each position attends to all positions, creating global context awareness without sequential processing constraints.

**Query-Key-Value Framework** Input representations are linearly projected into three matrices: queries (Q) representing what information to seek, keys (K) indicating what information is available, and values (V) containing the actual information content. The attention mechanism matches queries with keys to determine value weightings.

**Scaled Dot-Product Attention** The scaling factor √d_k prevents softmax saturation in high-dimensional spaces. Without scaling, dot products grow large in magnitude, pushing softmax into regions with extremely small gradients, hindering training effectiveness.

**Attention Score Computation** Raw attention scores are computed as matrix multiplication between queries and keys. These scores represent compatibility between different sequence positions, indicating which positions should influence each other most strongly.

**Softmax Normalization** Attention scores undergo softmax normalization across the key dimension, ensuring attention weights sum to 1.0 for each query position. This creates a probability distribution over all possible attention targets.

**Masked Attention Variants** Causal masking prevents positions from attending to future positions, essential for autoregressive language modeling. Padding masks ignore attention to padding tokens, ensuring meaningful attention distributions over variable-length sequences.


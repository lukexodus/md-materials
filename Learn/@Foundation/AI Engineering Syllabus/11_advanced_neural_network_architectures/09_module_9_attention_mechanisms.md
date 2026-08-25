## Module 9: Attention Mechanisms


### 9.1 Foundations

- Motivation: fixed-length bottleneck problem
- Soft vs hard attention
- Content-based addressing
- Attention as differentiable memory access

### 9.2 Basic Attention

- Additive (Bahdanau) attention: alignment model
- Score computation: learned compatibility
- Attention weights: softmax normalization
- Context vector: weighted sum
- Integration with RNNs/LSTMs

### 9.3 Scaled Dot-Product Attention

- Query, key, value paradigm
- Dot product similarity
- Scaling factor: √d_k rationale
- Softmax over scores
- Efficient matrix implementation

### 9.4 Multi-Head Attention

- Parallel attention layers
- Different representation subspaces
- Linear projections: WQ, WK, WV
- Concatenation and output projection
- Benefits: multiple relation types

### 9.5 Attention Variants

- Local attention: restricted window
- Global vs local trade-offs
- Hard attention: sampling strategies
- Sparse attention patterns: Reformer, Longformer
- Linear attention: kernel approximations
- Cross-attention: between sequences

### 9.6 Visualization & Interpretation

- Attention weight analysis
- Identifying focus patterns
- Head specialization
- Layer-wise attention evolution

---


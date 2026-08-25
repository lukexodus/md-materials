## Module 10: Self-Attention


### 10.1 Concept & Motivation

- Within-sequence relationships
- Permutation equivariance
- No sequential processing requirement
- Comparison to recurrence and convolution

### 10.2 Self-Attention Mechanism

- Query, key, value from same sequence
- Pairwise interactions: quadratic complexity
- Position-independent operations
- Absolute position encoding necessity

### 10.3 Computational Complexity

- Time complexity: O(n²·d)
- Memory complexity analysis
- Comparison with RNN: O(n·d²)
- Comparison with CNN: O(k·n·d²)
- Parallelization opportunities

### 10.4 Positional Information

- Need for position encoding
- Sinusoidal positional encoding: formula, properties
- Learned positional embeddings
- Relative position encoding: T5, DeBERTa
- Rotary position embedding (RoPE): LLaMA, GPT-Neo-X

### 10.5 Efficiency Improvements

- Linformer: low-rank approximation
- Reformer: locality-sensitive hashing
- Performer: FAVOR+ algorithm
- Longformer: sparse attention patterns
- BigBird: combination of attention types
- Flash Attention: IO-aware algorithms

### 10.6 Advanced Self-Attention

- Causal/masked self-attention: autoregressive models
- Bidirectional self-attention: BERT-style
- Cross-attention vs self-attention
- Self-attention in CNNs: non-local blocks
- Graph attention networks (GATs)

---


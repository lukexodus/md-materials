## Module 2: Pre-training Objectives


### 2.1 Pre-training Fundamentals

- What is pre-training?
- Self-supervised learning paradigm
- Transfer learning motivation
- Scale laws and emergent properties

### 2.2 Causal Language Modeling (CLM)

- Next-token prediction objective
- Autoregressive generation
- Loss function (cross-entropy)
- Training dynamics
- Used in: GPT series, LLaMA, Claude [Inference]

### 2.3 Masked Language Modeling (MLM)

- Random token masking strategy
- Bidirectional context utilization
- BERT's masking approach (15% tokens)
- Masking variations (whole word, span)
- Limitations for generation tasks

### 2.4 Prefix Language Modeling

- Combining bidirectional and unidirectional attention
- Prefix encoding with causal decoding
- Used in: GLM models
- Benefits for downstream tasks

### 2.5 Span Corruption

- T5's span masking approach
- Sentinel tokens
- Denoising objective
- Variable span lengths

### 2.6 Permutation Language Modeling

- XLNet's permutation approach
- Two-stream self-attention
- Addressing MLM limitations
- Computational complexity

### 2.7 Replaced Token Detection

- ELECTRA's discriminative approach
- Generator-discriminator framework
- Sample efficiency improvements
- Training cost reduction

### 2.8 Next Sentence Prediction (NSP)

- BERT's auxiliary objective
- Sentence coherence modeling
- Effectiveness debate [Unverified: mixed evidence]
- Sentence Order Prediction (SOP) alternative

### 2.9 Training Data Considerations

- Dataset composition and curation
- Data quality vs quantity trade-offs
- Deduplication strategies
- Filtering heuristics
- Multilingual data mixing
- Code and structured data inclusion

### 2.10 Training Dynamics

- Learning rate schedules (warmup, decay)
- Batch size effects
- Gradient accumulation
- Mixed precision training (FP16, BF16)
- Gradient clipping

### 2.11 Scaling Laws

- Chinchilla scaling laws
- Compute-optimal training
- Model size vs data size trade-offs
- Predicting model performance [Inference: based on empirical patterns]
- Loss curves and convergence

### 2.12 Emergent Capabilities

- In-context learning
- Few-shot learning
- Chain-of-thought reasoning
- Scale thresholds [Unverified: exact thresholds debated]

### 2.13 Pre-training Infrastructure

- Distributed training strategies
- Data parallelism
- Model parallelism (tensor, pipeline)
- ZeRO optimization
- Checkpointing strategies

---


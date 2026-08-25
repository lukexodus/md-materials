## Module 3: Fine-tuning Methods


### 3.1 Fine-tuning Fundamentals

- Transfer learning concepts
- Full model fine-tuning
- Catastrophic forgetting
- Task-specific adaptations

### 3.2 Full Fine-tuning

- Updating all model parameters
- Learning rate considerations (typically lower than pre-training)
- Overfitting risks with small datasets
- Computational requirements
- When full fine-tuning is appropriate

### 3.3 Parameter-Efficient Fine-Tuning (PEFT) Overview

- Motivation for PEFT methods
- Memory and compute advantages
- Performance comparison with full fine-tuning
- Use cases and trade-offs

### 3.4 Low-Rank Adaptation (LoRA)

- Low-rank decomposition concept
- Adapter matrices (A and B)
- Rank selection strategies
- Injection points in transformer layers
- Memory savings calculation
- QLoRA (Quantized LoRA)
- DoRA and other variants

### 3.5 Prefix Tuning

- Learnable prefix tokens
- Virtual tokens in key-value space
- Prefix length considerations
- Comparison with prompt tuning

### 3.6 Prompt Tuning

- Soft prompt embeddings
- Gradient-based prompt optimization
- Hard vs soft prompts
- Scale and effectiveness relationship

### 3.7 Adapter Layers

- Bottleneck architecture
- Insertion points in transformer blocks
- Adapter fusion techniques
- Modular task-specific learning

### 3.8 (IA)³ - Infused Adapter by Inhibiting and Amplifying

- Learned rescaling vectors
- Minimal parameter overhead
- Multiplicative intervention

### 3.9 BitFit

- Bias-only fine-tuning
- Extreme parameter efficiency
- Performance characteristics

### 3.10 Fine-tuning Strategies

- Layer freezing strategies
- Gradual unfreezing
- Discriminative learning rates
- Mixout and other regularization

### 3.11 Multi-task Fine-tuning

- Joint training on multiple tasks
- Task sampling strategies
- Negative transfer mitigation
- Task-specific heads vs unified output

### 3.12 Domain Adaptation

- Continued pre-training on domain data
- Domain-adversarial training
- Terminology and style adaptation
- Medical, legal, financial domains

### 3.13 Few-shot and Zero-shot Transfer

- In-context learning capabilities
- Meta-learning approaches
- Prompt engineering for transfer
- Performance without fine-tuning

### 3.14 Evaluation and Selection

- Validation set construction
- Hyperparameter tuning strategies
- Early stopping criteria
- Model selection techniques

---


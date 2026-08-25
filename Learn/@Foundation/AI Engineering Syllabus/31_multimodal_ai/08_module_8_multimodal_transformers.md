## Module 8: Multimodal Transformers


### 8.1 Transformer Architectures for Multimodal Data

#### 8.1.1 Adapting Transformers to Multimodal Input

- Tokenization across modalities
- Positional and modality encodings
- Attention across heterogeneous inputs
- Computational considerations

#### 8.1.2 Single-Stream vs Dual-Stream

- Single unified transformer
- Separate encoders with cross-attention
- Hybrid approaches
- Trade-offs and applications

### 8.2 Cross-Modal Attention Mechanisms

#### 8.2.1 Cross-Attention Design

- Query from one modality, keys/values from another
- Bottleneck cross-attention (Perceiver)
- Grouped cross-attention
- Efficient cross-attention variants

#### 8.2.2 Co-Attention Transformers

- Parallel attention streams
- Information exchange layers
- ViLBERT and LXMERT architectures
- Applications in VQA and retrieval

### 8.3 Multimodal Fusion in Transformers

#### 8.3.1 Early Fusion with Concatenation

- Token-level concatenation
- Sequence length challenges
- Computational complexity
- When to use early fusion

#### 8.3.2 Intermediate Fusion Layers

- Fusion at specific transformer layers
- Cross-modal transformer blocks
- Layer-wise fusion strategies
- Ablation insights

### 8.4 Vision Transformers for Multimodal Learning

#### 8.4.1 ViT-Based Multimodal Models

- Patch embeddings for images
- Combining with text tokens
- CLIP with Vision Transformers
- Scaling ViTs for multimodal tasks

#### 8.4.2 Swin Transformers for Multimodal

- Hierarchical vision features
- Multi-scale fusion
- Efficient attention mechanisms
- Applications in dense prediction

### 8.5 Large-Scale Multimodal Transformers

#### 8.5.1 Scaling Laws

- Model size, data size, compute trade-offs
- Emergent abilities at scale
- Multimodal scaling considerations
- Efficient scaling strategies

#### 8.5.2 FLAVA, CoCa, and Unified Models

- FLAVA: foundational language and vision alignment
- CoCa: contrastive captioners are image-text foundation models
- Unified pretraining objectives
- Multi-task capabilities

### 8.6 Efficient Multimodal Transformers

#### 8.6.1 Sparse Attention

- Local and strided attention patterns
- Longformer and BigBird for multimodal
- Mixture of attention patterns
- Computational savings

#### 8.6.2 Linear Attention Variants

- Performers and linear transformers
- Kernel-based approximations
- Applications to long multimodal sequences
- Quality vs efficiency trade-offs

### 8.7 Modality-Specific Adapters

#### 8.7.1 Adapter Modules

- Lightweight modality-specific layers
- Parameter-efficient fine-tuning
- Adapters vs prompt tuning
- Applications in transfer learning

#### 8.7.2 Prefix and Prompt Tuning

- Learnable prefix tokens
- Soft prompts for multimodal models
- Visual prompts
- Cross-modal prompt engineering

### 8.8 Multimodal Decoder Architectures

#### 8.8.1 Encoder-Decoder Transformers

- BART and T5 for multimodal tasks
- Cross-attention in decoders
- Generation with multimodal context
- Applications: captioning, VQA

#### 8.8.2 Autoregressive Multimodal Generation

- Token-by-token generation
- Conditioning on multiple modalities
- Beam search and sampling strategies
- Dall-E style discrete VAE + transformer

---


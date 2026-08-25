## Module 8: Attention is All You Need - Vision Transformers


### 8.1 From NLP to Vision

- Transformer architecture origins
- Self-attention mechanism
- Limitations of CNNs (inductive biases)
- Global receptive field motivation

### 8.2 Self-Attention Mechanism

- Query, Key, Value matrices
- Attention score calculation: Attention(Q,K,V) = softmax(QK^T/√d_k)V
- Multi-head attention
- Position-wise feed-forward networks
- Residual connections and layer normalization

### 8.3 Vision Transformer (ViT) Architecture

**Image Preprocessing:**

- Split image into patches (typically 16×16)
- Linear embedding of flattened patches
- Patch embedding dimension (e.g., 768)

**Architecture Components:**

- Learnable class token (prepended)
- Position embeddings (learnable 1D)
- Transformer encoder (L layers)
- Each layer: Multi-head self-attention + MLP
- MLP head for classification

**ViT Variants:**

- ViT-Base: 12 layers, 768 hidden, 12 heads, 86M params
- ViT-Large: 24 layers, 1024 hidden, 16 heads, 307M params
- ViT-Huge: 32 layers, 1280 hidden, 16 heads, 632M params

### 8.4 Key Concepts and Analysis

- Patch size impact (14×14 vs 16×16 vs 32×32)
- Position encoding strategies
- Inductive bias removal
- Attention distance vs CNN receptive field
- Attention map visualization
- Computational complexity: O(n²) in sequence length

### 8.5 Training Considerations

- Large-scale pretraining necessity (JFT-300M)
- Data augmentation importance
- Fine-tuning on smaller datasets
- Training instability at large scale
- Regularization requirements

### 8.6 Hybrid Architectures

- Early convolutional stem
- CNN feature maps as input patches
- Best of both worlds approach

### 8.7 Improvements and Variants

**DeiT (Data-efficient ViT):**

- Distillation token
- Teacher-student training
- ImageNet-only training
- Strong augmentation and regularization

**Swin Transformer:**

- Hierarchical structure
- Shifted window attention
- Local self-attention windows
- Linear complexity w.r.t. image size
- Pyramid feature maps for detection/segmentation

**Other Variants:**

- PVT (Pyramid Vision Transformer)
- Twins (spatial attention mechanisms)
- CrossViT (multi-scale patches)
- T2T-ViT (Tokens-to-Token)
- CaiT (Class-Attention in Image Transformers)

### 8.8 Technical Deep Dive

- Relative position encodings
- Window partitioning strategies
- Patch merging operations
- Attention bias and masking
- Mixed precision training

### 8.9 Advantages and Limitations

**Advantages:**

- Global receptive field from first layer
- Flexible architecture
- Strong transfer learning
- Interpretable attention patterns

**Limitations:**

- Data hunger (requires massive pretraining)
- Computational cost O(n²)
- Less effective on small datasets
- Lack of built-in translation equivariance

### 8.10 Comparison with CNNs

- Inductive biases comparison
- Sample efficiency
- Computational efficiency
- Performance on different data regimes
- Hybrid future [Inference]

---


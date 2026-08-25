## Module 8: Transformers


### 8.1 Foundations

- Limitations of RNNs for sequences
- Parallelization advantages
- Motivation: attention as primary mechanism
- Positional information handling

### 8.2 Core Architecture

- Input embeddings
- Positional encoding: sinusoidal, learned
- Multi-head attention layers
- Feed-forward networks
- Layer normalization
- Residual connections
- Complete encoder architecture
- Complete decoder architecture

### 8.3 Encoder-Decoder Structure

- Encoder stack: self-attention focus
- Decoder stack: masked self-attention, cross-attention
- Encoder-decoder attention
- Output projection and softmax
- Training: teacher forcing, masking

### 8.4 Architectural Variants

- Encoder-only: BERT, RoBERTa, DistilBERT
- Decoder-only: GPT family, causal transformers
- Encoder-decoder: T5, BART, MarianMT
- Vision Transformer (ViT): patch embeddings
- Swin Transformer: hierarchical structure, shifted windows
- Perceiver: cross-attention to latents

### 8.5 Training & Optimization

- Warmup learning rate schedule
- Adam optimizer variants: AdamW
- Gradient accumulation
- Mixed precision training
- Large batch training strategies
- Pre-training objectives: MLM, CLM, NSP, replaced token detection

### 8.6 Applications & Extensions

- Natural language processing: BERT, GPT
- Machine translation
- Text summarization
- Question answering
- Computer vision: ViT, DETR
- Multi-modal: CLIP, Flamingo
- Speech processing: Wav2Vec2, Whisper

---


## Vision Transformer Adaptations


**Image Patch Tokenization** Images are divided into non-overlapping patches (typically 16×16 pixels) that are flattened and linearly projected into token embeddings. This approach treats image patches as sequence elements for transformer processing.

**Classification Token** A special [CLS] token is prepended to patch sequences, similar to BERT. The final representation of this token is used for image classification tasks, aggregating information from all patches.

**2D Positional Embeddings** Vision transformers require position embeddings that capture 2D spatial relationships between patches. These can be learned embeddings, 2D sinusoidal encodings, or relative position encodings adapted for spatial dimensions.

**Inductive Bias Considerations** Vision transformers lack CNN's built-in translation equivariance and local connectivity biases. Large datasets and extensive pre-training are typically required to learn these spatial relationships from data.

**Hierarchical Vision Transformers** Models like Swin Transformer introduce hierarchical structure with shifted windowing, reducing computational complexity while maintaining global receptive fields. These approaches bridge CNN and transformer architectures.

**Hybrid CNN-Transformer Models** Some architectures use CNN feature extractors followed by transformer layers, combining CNN's spatial inductive biases with transformer's global attention capabilities. Examples include early ViT variants and ConvNeXT designs.


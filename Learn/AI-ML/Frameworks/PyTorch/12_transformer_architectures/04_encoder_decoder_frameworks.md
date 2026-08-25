## Encoder-Decoder Frameworks


**Encoder Architecture** Encoder processes input sequences through stacked self-attention and feed-forward layers. Each layer includes residual connections and layer normalization. The encoder builds contextualized representations of the entire input sequence.

**Decoder Architecture** Decoder generates output sequences autoregressively using masked self-attention, cross-attention to encoder outputs, and feed-forward layers. Cross-attention allows decoder to access encoder representations while maintaining causal generation constraints.

**Cross-Attention Mechanism** Decoder's cross-attention layers use decoder positions as queries and encoder outputs as keys and values. This mechanism enables the decoder to selectively attend to relevant parts of the input sequence during generation.

**Teacher Forcing vs. Autoregressive Generation** During training, teacher forcing uses ground truth previous tokens as decoder inputs for parallel processing. During inference, autoregressive generation uses model's own previous predictions, creating exposure bias between training and inference.

**Encoder-Only Models** Models like BERT use only encoder architecture for tasks requiring bidirectional context understanding. Suitable for classification, named entity recognition, and other discriminative tasks where full sequence context is available.

**Decoder-Only Models** GPT-style models use only decoder architecture with causal masking for autoregressive language modeling. These models have shown remarkable scaling properties and generalization capabilities across diverse tasks.


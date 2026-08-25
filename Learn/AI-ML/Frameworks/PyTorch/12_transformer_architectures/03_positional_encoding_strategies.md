## Positional Encoding Strategies


**Sinusoidal Positional Encoding** Original transformer uses fixed sinusoidal functions: PE(pos,2i) = sin(pos/10000^(2i/d_model)), PE(pos,2i+1) = cos(pos/10000^(2i/d_model)). Different frequencies encode different positional dimensions, enabling interpolation to unseen sequence lengths.

**Learned Positional Embeddings** Trainable positional embeddings learn position-specific representations during training. More flexible than fixed encodings but limited to maximum training sequence length without extrapolation capabilities.

**Relative Positional Encoding** Instead of absolute positions, relative positional encoding captures relationships between positions. Implementations include relative position embeddings in attention computation or separate relative position bias terms.

**Rotary Position Embedding (RoPE)** RoPE multiplies query and key vectors by rotation matrices based on position, naturally incorporating relative position information into attention computation. Enables better length extrapolation and has become standard in many modern models.

**Alibi (Attention with Linear Biases)** Adds position-dependent linear bias to attention scores without requiring explicit positional embeddings. Simple yet effective for length extrapolation, used in models like BLOOM and PaLM.

**2D and 3D Positional Encodings** Vision transformers require 2D positional encodings for spatial relationships. Extensions to 3D handle video or volumetric data. These encodings can be learned, fixed, or hybrid approaches combining both strategies.


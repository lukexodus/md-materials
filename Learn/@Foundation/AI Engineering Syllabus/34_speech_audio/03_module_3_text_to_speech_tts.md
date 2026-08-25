## Module 3: Text-to-Speech (TTS)


### 3.1 TTS System Overview

- Text analysis and normalization
- Phonetic conversion
- Prosody modeling
- Waveform synthesis
- Quality metrics (MOS, naturalness)

### 3.2 Text Processing Frontend

- Text normalization
- Phoneme conversion (grapheme-to-phoneme)
- Prosody prediction (pitch, duration, intensity)
- CMU Pronunciation Dictionary
- Handling non-standard words

### 3.3 Traditional TTS Approaches

- Concatenative synthesis
- Unit selection
- Diphone synthesis
- PSOLA (Pitch-Synchronous Overlap-Add)
- Formant synthesis

### 3.4 Statistical Parametric Speech Synthesis

- HMM-based synthesis
- Vocoder-based approach
- STRAIGHT vocoder
- WORLD vocoder
- Parameter generation from HMMs

### 3.5 Neural TTS: Sequence-to-Sequence Models

- Tacotron architecture
- Tacotron 2 improvements
- Encoder-decoder with attention
- Post-net refinement
- Reduction factor strategies

### 3.6 Neural Vocoders

- WaveNet architecture
- Autoregressive generation
- Dilated convolutions
- Conditional generation
- Training and inference challenges

### 3.7 Non-Autoregressive Vocoders

- Parallel WaveGAN
- MelGAN
- HiFi-GAN
- Multi-scale discriminators
- Adversarial training for audio

### 3.8 Advanced TTS Architectures

- FastSpeech 1 and 2
- Duration prediction
- Variance adaptor
- Glow-TTS (flow-based)
- VITS (end-to-end)

### 3.9 Transformer-Based TTS

- TransformerTTS
- Multi-head attention for TTS
- Positional encoding strategies
- Feed-forward Transformer (FastSpeech)

### 3.10 Prosody and Expressiveness

- Prosody modeling techniques
- Style tokens and GSTs
- Reference encoder
- Emotion control
- Speaking rate and pitch control

### 3.11 Multi-Speaker TTS

- Speaker embeddings (d-vectors, x-vectors)
- Speaker encoder architectures
- Zero-shot voice cloning
- Few-shot adaptation
- Speaker similarity metrics

### 3.12 Low-Resource and Adaptation

- Transfer learning for TTS
- Fine-tuning strategies
- Data augmentation for TTS
- Cross-lingual TTS
- Accent adaptation

### 3.13 Practical Implementation

- Mozilla TTS
- Coqui TTS
- ESPnet-TTS
- NVIDIA NeMo
- Commercial TTS APIs

### 3.14 Evaluation Methods

- Mean Opinion Score (MOS)
- Objective metrics (MCD, F0 error)
- Speaker similarity evaluation
- Naturalness assessment
- Intelligibility testing

---


## Module 1: Data Augmentation


### 1.1 Foundations

- Motivation: addressing limited training data
- Augmentation as implicit regularization
- Domain-specific vs domain-agnostic techniques
- Online vs offline augmentation
- Augmentation pipeline design

### 1.2 Image Augmentation Techniques

#### 1.2.1 Geometric Transformations

- Rotation: angle ranges, interpolation methods
- Translation: boundary handling strategies
- Scaling/zooming: aspect ratio preservation
- Shearing: affine transformation matrices
- Flipping: horizontal, vertical constraints
- Cropping: random crops, center crops, multi-crop

#### 1.2.2 Photometric Transformations

- Brightness adjustment: additive vs multiplicative
- Contrast modification: histogram stretching
- Saturation changes: HSV color space manipulation
- Hue shifting: color space rotations
- Gamma correction: non-linear intensity mapping
- Channel shuffling

#### 1.2.3 Advanced Image Augmentation

- Cutout: random rectangular masking
- MixUp: linear interpolation between samples and labels
- CutMix: combining spatial regions with label mixing
- AutoAugment: learned augmentation policies
- RandAugment: simplified search space
- AugMax: adversarial augmentation selection
- GridMask: structured dropping patterns
- Mosaic augmentation: combining multiple images

#### 1.2.4 Specialized Techniques

- Style transfer-based augmentation
- GAN-based synthetic data generation
- Domain randomization: texture, lighting
- Test-time augmentation (TTA): prediction averaging
- Adversarial augmentation

### 1.3 Text/NLP Augmentation

#### 1.3.1 Token-Level Operations

- Synonym replacement: WordNet, contextual embeddings
- Random insertion: context-aware word addition
- Random swap: position exchange
- Random deletion: controlled token removal

#### 1.3.2 Sentence-Level Operations

- Back-translation: round-trip translation
- Paraphrasing: semantic preservation
- Sentence shuffling: order permutation
- Contextual word embeddings augmentation (EDA)

#### 1.3.3 Advanced NLP Augmentation

- Token masking: BERT-style
- Span replacement: T5-style
- Mixup in embedding space
- Adversarial text generation
- Template-based augmentation

### 1.4 Audio Augmentation

- Time stretching: tempo modification
- Pitch shifting: frequency domain manipulation
- Adding noise: Gaussian, environmental
- Time masking: SpecAugment
- Frequency masking: SpecAugment
- Volume adjustment
- Room simulation: reverb, echo

### 1.5 Domain-Specific Augmentation

- Medical imaging: intensity normalization, elastic deformation
- Time series: jittering, scaling, rotation
- Graph data: node/edge perturbation
- Video: temporal consistency constraints
- Point clouds: rotation, jittering, sampling

### 1.6 Implementation Considerations

- Augmentation probability hyperparameters
- Preservation of label validity
- Computational cost vs benefit analysis
- Augmentation ordering in pipeline
- Batch-level vs sample-level augmentation
- GPU acceleration: NVIDIA DALI, Kornia

### 1.7 Theoretical Aspects

- Data augmentation as regularization
- Invariance vs equivariance learning
- Impact on generalization bounds
- Augmentation diversity metrics
- [Inference] Relationship to model capacity

---


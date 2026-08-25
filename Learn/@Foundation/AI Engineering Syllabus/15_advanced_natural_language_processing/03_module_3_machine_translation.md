## Module 3: Machine Translation


### 3.1 Machine Translation Fundamentals

- Translation types (human, machine, computer-assisted)
- MT paradigms overview
- Direct translation
- Transfer-based approaches
- Interlingua-based approaches
- Quality assessment in MT
- BLEU score and alternatives

### 3.2 Statistical Machine Translation (SMT)

- Noisy channel model
- Language models in SMT
- Translation models
- Word-based SMT
- Phrase-based SMT
    - Phrase extraction
    - Phrase tables
    - Reordering models
- Decoding algorithms
    - Beam search
    - Stack decoding
- Log-linear models
- Minimum Error Rate Training (MERT)

### 3.3 Word Alignment

- Alignment problem formulation
- IBM Models (Model 1-5)
- Expectation-Maximization for alignment
- Hidden Markov Model alignment
- Symmetrization techniques
- Fast align and eflomal
- Evaluation of alignments

### 3.4 Neural Machine Translation (NMT) Foundations

- Encoder-decoder architecture
- Sequence-to-sequence models
- Training objectives
- Teacher forcing
- Inference strategies
    - Greedy decoding
    - Beam search
- Length normalization
- Coverage mechanisms

### 3.5 Attention Mechanisms in NMT

- Motivation for attention
- Additive (Bahdanau) attention
- Multiplicative (Luong) attention
- Attention alignment visualization
- Self-attention concept
- Multi-head attention
- Local vs global attention

### 3.6 Transformer Architecture for MT

- Architecture overview
- Positional encoding
- Multi-head self-attention
- Feed-forward layers
- Layer normalization
- Residual connections
- Encoder-decoder attention
- Training transformers
- Scaling transformers

### 3.7 Advanced NMT Techniques

- Byte-pair encoding (BPE)
- SentencePiece tokenization
- Subword regularization
- Back-translation for data augmentation
- Knowledge distillation
- Multilingual NMT
- Zero-shot translation
- Pivot-based translation
- Document-level NMT
- Context-aware NMT

### 3.8 Low-Resource Machine Translation

- Transfer learning approaches
- Multilingual models for low-resource languages
- Unsupervised MT
- Semi-supervised MT
- Cross-lingual embeddings
- Data augmentation techniques
- Leveraging monolingual data
- Dictionary-based augmentation

### 3.9 Domain Adaptation in MT

- Domain mismatch problems
- Fine-tuning strategies
- Domain tags and tokens
- Multi-domain models
- Terminology handling
- Named entity preservation
- Style transfer in translation

### 3.10 Pre-trained Models for MT

- mBART (multilingual BART)
- mT5 (multilingual T5)
- M2M-100 (many-to-many translation)
- NLLB (No Language Left Behind)
- Fine-tuning pre-trained models
- Adapter layers for MT

### 3.11 Evaluation Methods

- Automatic metrics
    - BLEU, NIST, METEOR
    - ROUGE for MT
    - BERTScore
    - BLEURT, COMET
- Human evaluation
    - Adequacy and fluency
    - Post-editing effort
    - Error annotation
- Quality estimation without references
- Evaluation challenges and biases

### 3.12 Specialized Translation Tasks

- Simultaneous translation
- Speech-to-speech translation
- Image-to-text translation (OCR + MT)
- Code-switching translation
- Literary translation
- Sign language translation
- Multimodal translation

### 3.13 MT Systems and Tools

- OpenNMT framework
- Fairseq
- MarianMT
- Google Translate API
- Microsoft Translator
- DeepL
- Commercial vs open-source systems
- Integration and deployment

---


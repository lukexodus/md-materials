## Module 7: Optical Character Recognition (OCR)


### 7.1 OCR Fundamentals

- Problem definition: text detection + recognition
- Document OCR vs scene text OCR
- Pipeline architecture overview
- Applications: document digitization, autonomous vehicles, accessibility
- Challenges: fonts, languages, distortions, backgrounds

### 7.2 Text Detection

#### 7.2.1 Traditional Text Detection

- Connected component analysis
- MSER (Maximally Stable Extremal Regions)
- Stroke Width Transform (SWT)
- Sliding window approaches
- Limitations in complex scenes

#### 7.2.2 Deep Learning Text Detection

- EAST (Efficient and Accurate Scene Text detector)
- CTPN (Connectionist Text Proposal Network)
- TextBoxes and TextBoxes++
- SegLink: segment linking for text
- PixelLink: pixel-level linking

#### 7.2.3 Arbitrary-Shaped Text Detection

- PSENet (Progressive Scale Expansion Network)
- CRAFT (Character Region Awareness For Text)
- DB (Differentiable Binarization)
- TextSnake and ABCNet
- Handling curved and rotated text

#### 7.2.4 Transformer-Based Text Detection

- TESTR: end-to-end text spotting with transformers
- Detection Transformer adaptations for text
- Query-based text detection
- Unified detection and recognition frameworks

### 7.3 Text Recognition

#### 7.3.1 Traditional Recognition Methods

- Feature extraction (HOG, SIFT)
- Template matching approaches
- Tesseract OCR engine
- Classical machine learning classifiers
- Character segmentation challenges

#### 7.3.2 Deep Learning Recognition: CTC-Based

- CRNN (Convolutional Recurrent Neural Network)
- CTC (Connectionist Temporal Classification) loss
- Sequence modeling with LSTM/GRU
- Handling variable-length sequences
- Lexicon-free recognition

#### 7.3.3 Attention-Based Recognition

- Encoder-decoder with attention
- RARE (Robust text recognizer with Automatic REctification)
- R2AM (Recurrent Residual Attention Model)
- SAR (Show, Attend and Read)
- Focusing mechanism for character-level attention

#### 7.3.4 Transformer-Based Recognition

- Transformer encoders for visual features
- Transformer decoders for sequence generation
- Vision Transformer (ViT) adaptations
- TrOCR: transformer-based OCR
- Attention visualization and interpretability

#### 7.3.5 Sequence-to-Sequence Models

- Encoder-decoder architectures
- Beam search decoding
- Language model integration
- Handling long text sequences
- End-to-end differentiable training

### 7.4 End-to-End Text Spotting

- Joint detection and recognition
- Two-stage vs single-stage spotting
- FOTS (Fast Oriented Text Spotting)
- Mask TextSpotter
- ABCNet: adaptive bezier curve network
- CharNet: character-level spotting

### 7.5 Scene Text Understanding

#### 7.5.1 Scene Text Recognition Challenges

- Font variations and artistic text
- Perspective distortion and rotation
- Occlusion and blur
- Low resolution and compression artifacts
- Multilingual text recognition

#### 7.5.2 Text Rectification

- Spatial Transformer Networks (STN)
- Thin-Plate Spline (TPS) transformation
- Geometric correction modules
- Learning-based rectification
- Applications to curved text

### 7.6 Document Understanding

#### 7.6.1 Document Layout Analysis

- Document structure extraction
- Table detection and recognition
- Form understanding
- Reading order determination
- LayoutLM and document transformers

#### 7.6.2 Document OCR Engines

- Tesseract architecture and capabilities
- PaddleOCR: multilingual OCR toolkit
- EasyOCR: ready-to-use OCR
- Commercial solutions (Google Vision, AWS Textract)
- Comparative analysis

#### 7.6.3 Handwriting Recognition

- Offline vs online handwriting recognition
- IAM handwriting database
- Challenges: writer variation, cursive text
- Deep learning approaches (MDLSTMs)
- Applications: historical document analysis

### 7.7 Multilingual and Multi-Script OCR

- Language identification
- Script detection (Latin, Arabic, Chinese, etc.)
- Unicode handling
- Language-specific challenges
- Cross-lingual transfer learning
- Low-resource language OCR

### 7.8 Specialized OCR Applications

#### 7.8.1 Mathematical Expression Recognition

- Formula detection and recognition
- LaTeX generation from images
- Hierarchical structure recognition
- Datasets: CROHME, IM2LATEX

#### 7.8.2 License Plate Recognition (ALPR/ANPR)

- Vehicle detection and localization
- Plate detection and rectification
- Character segmentation and recognition
- Real-time processing requirements

#### 7.8.3 Receipt and Invoice OCR

- Key information extraction
- Named entity recognition for documents
- Template matching vs template-free
- Graph neural networks for documents

#### 7.8.4 Historical Document OCR

- Degraded document handling
- Ancient script recognition
- Binarization and enhancement
- Applications in digital humanities

### 7.9 Training Techniques and Data

#### 7.9.1 Synthetic Data Generation

- Font rendering for training data
- Synthetic scene text generation
- Background and distortion simulation
- Style transfer for domain adaptation
- SynthText and MJSynth datasets

#### 7.9.2 Data Augmentation

- Geometric transformations
- Photometric augmentations
- Elastic distortions
- Domain-specific augmentations
- Balancing synthetic and real data

#### 7.9.3 Weakly-Supervised and Semi-Supervised Learning

- Pseudo-labeling techniques
- Self-training strategies
- Consistency regularization
- Leveraging unlabeled data

### 7.10 Evaluation Metrics

#### 7.10.1 Detection Metrics

- Intersection over Union (IoU)
- Precision, recall, F1-score
- COCO-Text style evaluation
- Word-level vs character-level evaluation

#### 7.10.2 Recognition Metrics

- Character accuracy
- Word accuracy
- Edit distance (Levenshtein)
- Case-sensitive vs case-insensitive
- 1-N-L (1-Normalized Levenshtein)

#### 7.10.3 End-to-End Metrics

- Correct detection and recognition rate
- ICDAR evaluation protocols
- Per-sample vs aggregated metrics

### 7.11 Benchmark Datasets

- ICDAR datasets (2003, 2013, 2015, 2017, 2019)
- COCO-Text
- Street View Text (SVT)
- Total-Text (curved text)
- SCUT-CTW1500
- MLT (Multi-Lingual Text)
- FUNSD (form understanding)

### 7.12 Post-Processing and Refinement

- Language model integration
- Spell checking and correction
- Context-aware prediction
- Dictionary and lexicon constraints
- Confidence thresholding

### 7.13 Optimization and Deployment

#### 7.13.1 Model Optimization

- Knowledge distillation for OCR
- Pruning and quantization
- Mobile-friendly architectures
- TensorRT and ONNX conversion

#### 7.13.2 Production Systems

- Real-time processing pipelines
- Batch processing strategies
- GPU utilization and batching
- API design and microservices
- Handling large document volumes

#### 7.13.3 Edge Deployment

- Mobile OCR (ML Kit, Tesseract Mobile)
- On-device processing
- Offline OCR capabilities
- Power and memory constraints

### 7.14 Quality Control and Error Handling

- Confidence scores and thresholding
- Manual review workflows
- Active learning for annotation
- Error analysis and debugging
- Quality metrics and monitoring

### 7.15 Emerging Trends

- Vision-language models for OCR (Florence, CLIP)
- Few-shot text recognition
- Self-supervised pretraining for OCR
- Neural architecture search for OCR
- Multimodal document understanding

---


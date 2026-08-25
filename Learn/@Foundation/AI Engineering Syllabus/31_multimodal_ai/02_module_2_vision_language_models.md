## Module 2: Vision-Language Models


### 2.1 Vision-Language Fundamentals

#### 2.1.1 Problem Formulation

- Image captioning: image → text
- Visual question answering: image + question → answer
- Text-to-image generation: text → image
- Visual grounding: text + image → region
- Image-text matching and retrieval

#### 2.1.2 Architectural Components

- Vision encoders (CNN, ViT)
- Language encoders (RNN, Transformer)
- Cross-modal attention mechanisms
- Fusion strategies
- Task-specific heads

### 2.2 Image Captioning

#### 2.2.1 Encoder-Decoder Architectures

- CNN encoder + RNN decoder (Show and Tell)
- Visual attention mechanisms (Show, Attend and Tell)
- Bottom-up and top-down attention
- Transformer-based captioning
- Object-centric captioning

#### 2.2.2 Advanced Captioning Techniques

- Reinforcement learning for captioning (CIDEr optimization)
- Controllable and stylized captioning
- Dense captioning (multiple regions)
- Novel object captioning
- Evaluation metrics: BLEU, METEOR, CIDEr, SPICE

#### 2.2.3 Video Captioning

- Temporal modeling for video
- Hierarchical architectures
- Event detection and description
- Dense video captioning
- Challenges: long-term dependencies

### 2.3 Visual Question Answering (VQA)

#### 2.3.1 VQA Architectures

- Joint embedding approaches
- Attention-based VQA models
- Compositional reasoning networks
- Neural module networks
- Transformer-based VQA

#### 2.3.2 Reasoning Types

- Counting and spatial reasoning
- Relational reasoning
- Commonsense reasoning
- Textual reasoning in images (TextVQA)
- Outside knowledge VQA (OK-VQA)

#### 2.3.3 Advanced VQA Systems

- Graph neural networks for VQA
- Memory-augmented networks
- Multi-hop reasoning
- Explainable VQA
- Adversarial VQA

### 2.4 Contrastive Vision-Language Pretraining

#### 2.4.1 CLIP (Contrastive Language-Image Pre-training)

- Architecture: dual encoders
- Contrastive learning objective
- Large-scale noisy data training
- Zero-shot classification capabilities
- Prompt engineering for CLIP

#### 2.4.2 CLIP Variants and Extensions

- OpenCLIP: open-source implementations
- ALIGN: noisy image-text pairs at scale
- Florence: unified vision foundation model
- CoCa: contrastive captioners
- SigLIP and other improvements

#### 2.4.3 Applications of CLIP

- Zero-shot image classification
- Text-guided image manipulation
- Dense prediction tasks (segmentation)
- Video understanding
- Multimodal retrieval

### 2.5 Unified Vision-Language Models

#### 2.5.1 BERT-Style Vision-Language Models

- ViLBERT: vision and language BERT
- LXMERT: cross-modality encoder
- UNITER: universal image-text representation
- Oscar: object-semantics aligned pretraining
- VinVL: visual features with objects

#### 2.5.2 Single-Stream Architectures

- VisualBERT: single transformer for both modalities
- PIXEL: text as images
- Unified-IO: unified model for multiple tasks
- Position and modality embeddings

#### 2.5.3 Large-Scale Vision-Language Models

- BLIP (Bootstrapping Language-Image Pre-training)
- BLIP-2: efficient V-L pretraining with Q-Former
- Flamingo: few-shot multimodal learning
- GPT-4V and multimodal capabilities [Inference: based on public information]
- Gemini and multimodal understanding [Inference: architectural details not fully confirmed]

### 2.6 Generative Vision-Language Models

#### 2.6.1 Image Generation from Text

- DALL-E: discrete VAE + transformer
- DALL-E 2: CLIP + diffusion models
- Imagen: text-to-image with diffusion
- Stable Diffusion and variants
- Muse: masked generative transformers

#### 2.6.2 Controllable Image Generation

- Prompt engineering techniques
- Negative prompts and guidance
- Compositional generation
- Style control and transfer
- ControlNet and spatial control

#### 2.6.3 Image Editing and Manipulation

- InstructPix2Pix: instruction-based editing
- Text-guided inpainting
- Attribute editing with language
- Image variation generation

### 2.7 Visual Grounding and Referring Expression

#### 2.7.1 Referring Expression Comprehension

- Grounding text phrases to image regions
- Attention-based grounding
- Graph-based reasoning
- Transformer approaches
- Datasets: RefCOCO, RefCOCO+, RefCOCOg

#### 2.7.2 Phrase Localization

- Weakly-supervised grounding
- Multi-phrase grounding
- Temporal grounding in videos
- Applications: embodied AI, robotics

### 2.8 Vision-Language Navigation

#### 2.8.1 Embodied AI Tasks

- Vision-and-language navigation (VLN)
- Instruction following in 3D environments
- Room-to-room navigation
- Object navigation with language
- Outdoor navigation

#### 2.8.2 Navigation Architectures

- Recurrent models with attention
- Transformer-based navigation
- Graph-based spatial reasoning
- Memory and planning
- Simulation environments (Matterport3D, Habitat)

### 2.9 Visual Reasoning and Compositional Understanding

#### 2.9.1 Compositional Visual Reasoning

- GQA: compositional questions
- CLEVR: diagnostic reasoning
- Neural-symbolic approaches
- Program synthesis for reasoning
- Neuro-symbolic VQA

#### 2.9.2 Scene Understanding

- Scene graph generation
- Relationship detection
- Attribute recognition
- Hierarchical scene parsing

### 2.10 Document Understanding

#### 2.10.1 Document Intelligence Models

- LayoutLM: document layout understanding
- LayoutLMv2 and v3: vision + text + layout
- Donut: OCR-free document understanding
- DocFormer: multimodal transformers
- Applications: form understanding, invoice extraction

#### 2.10.2 Table Understanding

- Table detection and structure recognition
- Table question answering
- TableFormer and TUTA
- Cross-modal table reasoning

### 2.11 Vision-Language Pretraining Objectives

#### 2.11.1 Masked Language/Image Modeling

- Masked language modeling (MLM)
- Masked region modeling (MRM)
- Image-text matching (ITM)
- Word-region alignment

#### 2.11.2 Contrastive Objectives

- Image-text contrastive learning
- Hard negative mining
- Cross-modal momentum contrast
- Supervised contrastive learning

#### 2.11.3 Generative Objectives

- Autoregressive generation
- Masked generative pretraining
- Prefix language modeling
- Multi-task pretraining

### 2.12 Datasets and Benchmarks

#### 2.12.1 Pretraining Datasets

- Conceptual Captions (CC3M, CC12M)
- LAION-400M and LAION-5B
- YFCC100M
- RedCaps and localized narratives
- Data curation and filtering

#### 2.12.2 Downstream Task Datasets

- COCO Captions
- Visual Genome
- VQA 2.0 and GQA
- NLVR2 (visual reasoning)
- Flickr30K and MSCOCO retrieval

#### 2.12.3 Evaluation Benchmarks

- VL-BERT evaluation suite
- GLUE-style multimodal benchmarks
- Zero-shot evaluation protocols
- Robustness benchmarks

### 2.13 Efficient Vision-Language Models

#### 2.13.1 Parameter-Efficient Methods

- Adapter modules for V-L models
- Prompt tuning and prefix tuning
- LoRA for vision-language
- BitFit and bias tuning

#### 2.13.2 Knowledge Distillation

- Teacher-student frameworks
- Cross-modal distillation
- Feature alignment strategies
- Compact student architectures

#### 2.13.3 Quantization and Pruning

- Post-training quantization
- Quantization-aware training
- Structured and unstructured pruning
- Neural architecture search

---


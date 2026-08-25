## Vision Transformers

### Overview

Vision Transformers (ViT) apply the transformer architecture, originally designed for natural language processing, to image data. Rather than using convolutions to extract spatial features, ViT splits an image into fixed-size patches, treats each patch as a token, and processes the resulting sequence using self-attention layers.

$$z_0 = [x_{class}; x_p^1 E; x_p^2 E; \dots; x_p^N E] + E_{pos}$$

where $x_p^i$ represents the $i$-th flattened image patch, $E$ is a learned linear projection (patch embedding), $x_{class}$ is a learnable classification token, and $E_{pos}$ is a learned positional embedding.

### Problem Formulation

**Patch-based tokenization**An input image of size $H \times W$ is divided into $N$ non-overlapping patches of size $P \times P$, where $N = \frac{HW}{P^2}$. Each patch is flattened and linearly projected into an embedding vector.

**Sequence modeling of images**

Once tokenized, the sequence of patch embeddings is processed identically to how a transformer processes a sequence of word tokens in NLP, using self-attention to model relationships between patches regardless of spatial distance.

**Loss of built-in spatial inductive bias**

Unlike CNNs, which have locality and translation invariance built into the convolution operation itself, ViT does not inherently assume that nearby pixels are more related than distant ones. This relationship must instead be learned from data via positional embeddings and attention patterns. [Inference] This is a widely discussed architectural distinction in ViT literature; the practical effect of this difference on performance depends on training data scale and augmentation strategy, which I cannot verify as a fixed, universal outcome.

### Core Architecture Components

#### Patch Embedding

The image is reshaped into a sequence of flattened 2D patches, then linearly projected into a fixed-dimensional embedding space, analogous to word embeddings in NLP transformers.

#### Positional Embeddings

Since self-attention has no inherent notion of order or spatial position, learned (or fixed) positional embeddings are added to patch embeddings to inject spatial information.

#### Multi-Head Self-Attention (MHSA)

Each token attends to every other token in the sequence, allowing the model to capture long-range dependencies across the entire image from the earliest layers.

$$\text{Attention}(Q, K, V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V$$



$$\text{MultiHead}(Q, K, V) = \text{Concat}(\text{head}_1, \dots, \text{head}_h) W^O$$

#### Transformer Encoder Block

Each block typically consists of a multi-head self-attention layer, a feed-forward (MLP) layer, layer normalization, and residual connections around each sub-layer.

$$z'_l = \text{MHSA}(\text{LN}(z_{l-1})) + z_{l-1}$$



$$z_l = \text{MLP}(\text{LN}(z'_l)) + z'_l$$

#### Classification Head

The output embedding corresponding to the learnable $[CLS]$ token is passed through a final MLP layer to produce class predictions.

### ViT Architecture Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 460">
<text x="450" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Vision Transformer Architecture (svg_diagram)</text>
<rect x="40" y="60" width="160" height="90" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" />
<text x="120" y="90" font-size="12" text-anchor="middle" fill="#1a1a1a">Input Image</text>
<text x="120" y="110" font-size="10" text-anchor="middle" fill="#333">Split into</text>
<text x="120" y="125" font-size="10" text-anchor="middle" fill="#333">Fixed Patches</text>
<line x1="200" y1="105" x2="240" y2="105" stroke="#999" stroke-width="2" marker-end="url(#arrow1)" />
<rect x="240" y="60" width="160" height="90" rx="6" fill="#eef2fb" stroke="#5b8def" stroke-width="2" />
<text x="320" y="90" font-size="12" text-anchor="middle" fill="#1a1a1a">Patch Embedding</text>
<text x="320" y="110" font-size="10" text-anchor="middle" fill="#333">+ [CLS] Token</text>
<text x="320" y="125" font-size="10" text-anchor="middle" fill="#333">+ Position Embed</text>
<line x1="400" y1="105" x2="440" y2="105" stroke="#999" stroke-width="2" marker-end="url(#arrow1)" />
<rect x="440" y="60" width="420" height="280" rx="8" fill="#fef7e0" stroke="#f9ab00" stroke-width="2" />
<text x="650" y="90" font-size="13" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Transformer Encoder (x L blocks)</text>
<rect x="470" y="110" width="360" height="40" rx="4" fill="#fff" stroke="#f9ab00" />
<text x="650" y="135" font-size="11" text-anchor="middle">Layer Norm</text>
<line x1="650" y1="150" x2="650" y2="165" stroke="#f9ab00" stroke-width="2" />
<rect x="470" y="165" width="360" height="40" rx="4" fill="#fff" stroke="#f9ab00" />
<text x="650" y="190" font-size="11" text-anchor="middle">Multi-Head Self-Attention</text>
<line x1="650" y1="205" x2="650" y2="220" stroke="#f9ab00" stroke-width="2" />
<rect x="470" y="220" width="360" height="40" rx="4" fill="#fff" stroke="#f9ab00" />
<text x="650" y="245" font-size="11" text-anchor="middle">Layer Norm</text>
<line x1="650" y1="260" x2="650" y2="275" stroke="#f9ab00" stroke-width="2" />
<rect x="470" y="275" width="360" height="40" rx="4" fill="#fff" stroke="#f9ab00" />
<text x="650" y="300" font-size="11" text-anchor="middle">MLP (Feed-Forward)</text>

<text x="650" y="330" font-size="9" text-anchor="middle" fill="#555">Residual connections around each sub-layer</text>

<line x1="650" y1="340" x2="650" y2="360" stroke="#999" stroke-width="2" marker-end="url(#arrow1)" />
<rect x="530" y="380" width="240" height="50" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
<text x="650" y="410" font-size="12" text-anchor="middle" fill="#1a1a1a">MLP Head → Class Prediction</text>
</svg>

### Patch Embedding Flow

```mermaid
flowchart LR
    A[Input Image HxWxC] --> B[Split into N Patches]
    B --> C[Flatten Each Patch]
    C --> D[Linear Projection]
    D --> E[Add CLS Token]
    E --> F[Add Position Embeddings]
    F --> G[Transformer Encoder Stack]
    G --> H[CLS Token Output]
    H --> I[MLP Classification Head]
```

### Notable Variants

- **DeiT (Data-efficient Image Transformer)** — Introduces a distillation token and a training recipe intended to allow ViT-style models to be trained effectively on smaller datasets than the original ViT paper required. [Unverified] I cannot verify the exact dataset size thresholds referenced without citing the specific DeiT paper's reported experiments.
- **Swin Transformer** — Introduces a hierarchical structure with shifted, non-overlapping local windows for self-attention, producing multi-scale feature maps suitable as a general-purpose backbone for detection and segmentation, not only classification.
- **T2T-ViT (Tokens-to-Token ViT)** — Proposes a modified tokenization process intended to better capture local structure among neighboring patches. [Unverified] I cannot verify comparative performance claims against other variants without citing the specific original paper.
- **PVT (Pyramid Vision Transformer)** — Introduces a pyramid structure to progressively reduce sequence length across stages, aiming to produce multi-scale feature maps similar to CNN feature hierarchies.
- **CaiT, BEiT, and other later variants** — Introduce various training or architectural modifications (e.g., masked image modeling pretraining in BEiT). [Unverified] I cannot verify the specific comparative benchmark standing of each of these variants without citing their respective original papers.

### Training Considerations

**Data requirements**

The original ViT paper reported that ViT underperformed comparable CNNs when trained on mid-sized datasets, but became competitive or superior when trained on very large datasets (e.g., JFT-300M) or with sufficient data augmentation. [Unverified] I cannot verify these specific comparative figures without direct access to and citation of the original paper's exact reported numbers.

**Data augmentation and regularization**

Because ViT lacks certain built-in inductive biases present in CNNs, strong data augmentation (e.g., RandAugment, Mixup, CutMix) and regularization techniques are commonly used to help the model generalize, particularly when large-scale pretraining data is not available. [Inference] This is a widely repeated recommendation in ViT training literature; its effect size depends on model size, dataset, and specific augmentation configuration, which I cannot verify as a fixed quantitative relationship.

**Pretrain-then-fine-tune paradigm**

ViT models are commonly pretrained on large datasets and then fine-tuned on smaller downstream datasets, often at a higher input resolution than used during pretraining, which requires interpolating positional embeddings to match the new sequence length.

### Example: Loading a Pretrained ViT

```python
from transformers import ViTForImageClassification, ViTImageProcessor
from PIL import Image
import torch

processor = ViTImageProcessor.from_pretrained("google/vit-base-patch16-224")
model = ViTForImageClassification.from_pretrained("google/vit-base-patch16-224")

image = Image.open("example.jpg")
inputs = processor(images=image, return_tensors="pt")

with torch.no_grad():
    outputs = model(**inputs)
    predicted_class_idx = outputs.logits.argmax(-1).item()

print(model.config.id2label[predicted_class_idx])
```

[Unverified] This reflects standard, documented Hugging Face `transformers` API conventions as commonly published; I cannot verify that this exact model identifier or API signature remains unchanged in all current or future library versions without checking the specific installed version's documentation.

### Computational Considerations

**Quadratic self-attention complexity**

Standard self-attention has computational and memory complexity that scales quadratically with the number of tokens (patches), which becomes significant at higher image resolutions or smaller patch sizes.

$$\text{Complexity} = O(N^2 \cdot d)$$

where $N$ is the number of patches and $d$ is the embedding dimension. [Inference] This quadratic scaling is a documented mathematical property of standard self-attention; whether it constitutes a practical bottleneck in a specific deployment depends on hardware, implementation, and chosen resolution/patch size, which I cannot verify in general terms.

**Mitigations**

Hierarchical and windowed attention approaches (e.g., Swin Transformer) and linear-attention approximations have been proposed to reduce this computational cost. [Unverified] I cannot verify comparative efficiency figures between these specific mitigation approaches without citing their respective original papers.

### Evaluation Metrics

ViT models used for classification are typically evaluated using the same metrics as CNN-based classifiers: top-1 accuracy, top-5 accuracy, and, when used as backbones for detection or segmentation, task-specific metrics such as mAP or mIoU (covered in their respective topics).

### Practical Considerations

- **Input resolution mismatches** — Fine-tuning at a different resolution than pretraining requires interpolating positional embeddings, which is a documented technique in ViT literature but is not guaranteed to preserve pretrained performance in every case. [Unverified] I cannot verify the precise performance impact of positional embedding interpolation in general terms without citing a specific study.
- **Patch size selection** — Smaller patch sizes increase sequence length and computational cost but may capture finer spatial detail; larger patch sizes reduce cost but may lose fine detail. This is a structural tradeoff inherent to the tokenization design.
- **Backbone choice for downstream tasks** — Plain ViT produces single-scale feature maps, which can be less directly suited to dense prediction tasks (detection, segmentation) compared to hierarchical variants like Swin, though plain ViT backbones have also been adapted for such tasks in later research. [Unverified] I cannot verify comparative downstream task performance between plain and hierarchical ViT variants without citing specific benchmark papers.

### Common Pitfalls

- Training a ViT from scratch on a small dataset without adequate augmentation or pretraining, which is commonly associated with underperformance relative to CNNs in that specific regime. [Inference] This is a widely repeated characterization in ViT literature; the exact dataset size threshold at which this occurs is not fixed and depends on model size and training recipe, which I cannot verify as a universal number.
- Changing input resolution between pretraining and fine-tuning without properly handling positional embedding interpolation.
- Assuming ViT will outperform CNNs by default, without accounting for the dataset scale and training regime dependency documented in the original literature.
- Treating all ViT variants as interchangeable, when hierarchical and plain variants differ substantially in their suitability for dense prediction tasks.

> Correction note: All performance and behavior claims above regarding ViT are labeled as inference or unverified where they are not directly and precisely sourced; none should be read as guaranteed outcomes for any specific implementation.

**Related Topics**

- Swin Transformer and hierarchical vision transformers in depth
- Self-supervised pretraining for transformers (BEiT, MAE, DINO)
- Efficient attention mechanisms for vision (linear attention, windowed attention)
- Vision transformers as backbones for detection and segmentation
- Hybrid CNN-transformer architectures
- Vision-language transformers (CLIP, BLIP)
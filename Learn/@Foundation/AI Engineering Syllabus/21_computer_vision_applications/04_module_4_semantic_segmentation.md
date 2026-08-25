## Module 4: Semantic Segmentation


### 4.1 Semantic Segmentation Fundamentals

- Problem definition: pixel-wise classification
- Difference from instance and panoptic segmentation
- Output representations and formats
- Applications: autonomous driving, medical imaging, satellite imagery
- Challenges: class imbalance, boundary precision, computational cost

### 4.2 Fully Convolutional Networks (FCN)

- FCN architecture and design principles
- Encoder-decoder structure
- Skip connections for multi-scale features
- Upsampling techniques (transpose convolution, bilinear)
- Training FCNs: loss functions and strategies

### 4.3 U-Net and Medical Image Segmentation

- U-Net architecture: symmetric encoder-decoder
- Skip connections and feature concatenation
- 3D U-Net for volumetric data
- U-Net variants (Attention U-Net, U-Net++, ResUNet)
- Medical imaging applications

### 4.4 Advanced Encoder-Decoder Architectures

- SegNet: pooling indices for upsampling
- DeepLab family (v1, v2, v3, v3+)
- PSPNet: Pyramid Pooling Module
- FPN for semantic segmentation
- HRNet: maintaining high resolution

### 4.5 Atrous/Dilated Convolutions

- Dilated convolution operation
- Receptive field expansion without resolution loss
- Atrous Spatial Pyramid Pooling (ASPP)
- Multi-scale context aggregation
- Rate selection strategies

### 4.6 Attention Mechanisms for Segmentation

- Spatial attention modules
- Channel attention (SE blocks)
- Non-local neural networks
- CBAM (Convolutional Block Attention Module)
- DANet: dual attention networks

### 4.7 Transformer-Based Semantic Segmentation

- SETR (Segmentation Transformer)
- SegFormer: efficient transformer design
- Swin-Transformer for segmentation
- Segmenter: pure transformer approach
- Hybrid CNN-Transformer architectures

### 4.8 Real-Time Semantic Segmentation

- ENet: efficient neural network
- ICNet: image cascade network
- BiSeNet: bilateral segmentation network
- Fast-SCNN: fast semantic segmentation
- STDC: short-term dense concatenate network
- Trade-offs: accuracy vs speed

### 4.9 Multi-Scale and Context Aggregation

- Pyramid pooling strategies
- Multi-scale feature fusion
- Global context modeling
- Boundary refinement techniques
- CRF (Conditional Random Field) post-processing

### 4.10 Loss Functions for Segmentation

- Cross-entropy loss
- Weighted cross-entropy for class imbalance
- Dice loss and Jaccard loss
- Focal loss for hard examples
- Boundary loss functions
- Combined loss strategies

### 4.11 Data Augmentation for Segmentation

- Geometric transformations with label propagation
- Color space augmentations
- CutMix and ClassMix for segmentation
- Synthetic data generation
- Domain randomization

### 4.12 Weakly-Supervised Semantic Segmentation

- Image-level supervision
- Bounding box supervision
- Scribble and point annotations
- Class activation maps (CAM, Grad-CAM)
- Pseudo-label generation and refinement

### 4.13 Semi-Supervised and Self-Supervised Learning

- Consistency regularization
- Pseudo-labeling techniques
- Mean teacher and co-training
- Contrastive learning for segmentation
- Self-supervised pretraining benefits

### 4.14 Domain Adaptation for Segmentation

- Synthetic-to-real adaptation
- Adversarial training approaches
- Style transfer for domain adaptation
- Cross-domain segmentation
- Applications: sim-to-real transfer

### 4.15 Evaluation Metrics

- Pixel accuracy and mean accuracy
- Intersection over Union (IoU)
- Mean IoU (mIoU)
- Dice coefficient
- Boundary F1-score
- Frequency weighted IoU

### 4.16 3D and Volumetric Segmentation

- Medical volumetric data (CT, MRI)
- Point cloud segmentation
- 3D convolutions and architectures
- Memory-efficient 3D processing
- Slice-by-slice vs full 3D approaches

### 4.17 Domain-Specific Applications

- Autonomous driving (Cityscapes, KITTI)
- Medical imaging (organs, tumors, cells)
- Satellite and aerial imagery
- Scene parsing and understanding
- Industrial inspection

### 4.18 Production Deployment

- Model compression for segmentation
- TensorRT optimization
- Mobile deployment considerations
- Post-processing pipelines
- Real-time constraints and solutions

---


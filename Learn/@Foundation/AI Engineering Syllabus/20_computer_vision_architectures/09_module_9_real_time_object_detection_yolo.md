## Module 9: Real-Time Object Detection - YOLO


### 9.1 Object Detection Background

- Classification vs localization vs detection
- Two-stage detectors (R-CNN family)
- Single-stage detector motivation
- Speed-accuracy tradeoff
- Real-time requirement (>30 FPS)

### 9.2 Detection Problem Formulation

- Bounding box representation (x, y, w, h)
- Class probabilities
- Confidence scores
- Intersection over Union (IoU)
- Non-Maximum Suppression (NMS)
- Mean Average Precision (mAP)

### 9.3 YOLO v1 - You Only Look Once

**Core Concept:**

- Unified detection framework
- Single forward pass
- Frame detection as regression problem
- Grid-based prediction

**Architecture:**

- 24 convolutional layers + 2 FC layers
- Inspired by GoogLeNet
- Input: 448×448
- Output: S×S×(B*5 + C) tensor
    - S×S grid (7×7)
    - B bounding boxes per cell (2)
    - 5 values: x, y, w, h, confidence
    - C class probabilities (20 for PASCAL VOC)

**Loss Function:**

- Multi-part loss (localization + confidence + classification)
- Weighted sum squared error
- Different weights for coordinates, confidence, class
- Only penalize "responsible" predictor

**Limitations:**

- Struggles with small objects
- Limited to 2 boxes per grid cell
- Arbitrary aspect ratios difficulty
- Localization errors

### 9.4 YOLO v2 (YOLO9000)

**Improvements:**

- Batch normalization (2% mAP gain)
- High-resolution classifier (fine-tuning at 448×448)
- Anchor boxes (dimension priors)
- K-means clustering for anchor dimensions
- Direct location prediction (sigmoid constraints)
- Fine-grained features (passthrough layer)
- Multi-scale training (random input sizes)
- Darknet-19 backbone (19 conv + 5 maxpool)

**YOLO9000:**

- Joint training on detection + classification
- WordTree hierarchy
- 9000+ object categories

### 9.5 YOLO v3

**Architecture Changes:**

- Darknet-53 backbone (ResNet-style residual blocks)
- Feature Pyramid Network (FPN) inspired
- Multi-scale predictions (3 scales)
- Larger feature maps for small objects
- 9 anchor boxes (3 per scale)
- Logistic regression for objectness
- Independent logistic classifiers (multi-label)

**Performance:**

- Faster than SSD
- Comparable accuracy to RetinaNet
- Better small object detection

### 9.6 YOLO v4

**Bag of Freebies (training-only improvements):**

- Mosaic data augmentation
- Self-Adversarial Training (SAT)
- CutMix augmentation
- DropBlock regularization
- Class label smoothing
- CIoU loss

**Bag of Specials (inference cost, small accuracy gain):**

- Mish activation
- CSPDarknet53 backbone (Cross Stage Partial)
- SPP (Spatial Pyramid Pooling)
- PANet (Path Aggregation Network)
- SAM (Spatial Attention Module)

**Performance Optimization:**

- Optimized for GPU training
- Balance speed and accuracy
- 43.5% AP, 65 FPS (Tesla V100)

### 9.7 YOLO v5 (Ultralytics)

- PyTorch implementation (not official research)
- CSPDarknet backbone variants (s, m, l, x)
- Focus layer (efficient downsampling)
- Improved training pipeline
- AutoAnchor for anchor optimization
- Extensive augmentation
- Easy deployment and inference
- Model zoo with pretrained weights

### 9.8 YOLO v6-v8 Evolution

**YOLO v6:**

- Industry-focused (Meituan)
- Efficient Decoupled Head
- Enhanced backbone and neck
- Self-distillation

**YOLO v7:**

- Extended ELAN (efficient layer aggregation)
- Model scaling strategies
- Trainable bag-of-freebies
- State-of-the-art accuracy-speed tradeoff

**YOLO v8 (Ultralytics):**

- Anchor-free detection
- New backbone (C2f modules)
- Decoupled head refinement
- Improved loss functions
- Multiple task support (detect, segment, classify, pose)

### 9.9 Technical Components Deep Dive

**Anchor Boxes:**

- Prior box dimensions
- K-means clustering on training data
- Scale and aspect ratio variations
- Anchor-free alternatives

**Feature Pyramid Networks:**

- Top-down pathway
- Lateral connections
- Multi-scale feature fusion
- PANet bidirectional fusion

**Loss Functions:**

- Classification loss (cross-entropy)
- Localization loss (IoU-based: IoU, GIoU, DIoU, CIoU)
- Objectness/confidence loss
- Focal loss for class imbalance

**Post-Processing:**

- Confidence thresholding
- Non-Maximum Suppression (NMS)
- Soft-NMS variants
- Class-specific NMS

### 9.10 Training Strategies

- Transfer learning from classification
- Multi-scale training
- Learning rate schedules (warm-up, cosine annealing)
- Data augmentation techniques
- Hyperparameter optimization

### 9.11 Deployment and Optimization

- Model quantization (INT8)
- TensorRT optimization
- ONNX export
- Mobile deployment (YOLO-Lite, YOLO-Fastest)
- Edge device considerations
- Real-time inference pipelines

### 9.12 Applications and Use Cases

- Autonomous driving
- Surveillance systems
- Retail analytics
- Sports analysis
- Manufacturing quality control

---


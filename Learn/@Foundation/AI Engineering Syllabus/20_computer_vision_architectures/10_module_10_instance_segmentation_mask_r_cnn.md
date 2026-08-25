## Module 10: Instance Segmentation - Mask R-CNN


### 10.1 Segmentation Task Hierarchy

- Semantic segmentation (pixel-level classification)
- Instance segmentation (distinguish object instances)
- Panoptic segmentation (semantic + instance)
- Task complexity comparison

### 10.2 R-CNN Evolution

**R-CNN (2014):**

- Selective search region proposals
- CNN feature extraction per region
- SVM classification
- Bounding box regression
- Slow (47s per image)

**Fast R-CNN (2015):**

- Single CNN forward pass
- ROI pooling
- Multi-task loss (classification + bbox)
- 2s per image (excluding proposals)

**Faster R-CNN (2015):**

- Region Proposal Network (RPN)
- End-to-end training
- Anchor boxes
- ~200ms per image

### 10.3 Mask R-CNN Architecture

**Overview:**

- Extends Faster R-CNN
- Adds mask prediction branch
- Parallel branches: classification, bbox, mask
- ROI Align for precise spatial correspondence

**Backbone Networks:**

- ResNet-50-FPN
- ResNet-101-FPN
- ResNeXt-101-FPN
- Feature Pyramid Network for multi-scale

**Components:**

1. **Backbone + FPN:** Feature extraction at multiple scales
2. **Region Proposal Network (RPN):** Object proposals
3. **ROI Align:** Fixed-size feature extraction
4. **Head:**
    - Box head: Classification + bbox regression
    - Mask head: FCN for pixel-level mask

### 10.4 Region Proposal Network (RPN)

- Anchor generation (3 scales × 3 aspect ratios)
- Objectness classification (object/not object)
- Bounding box regression
- Non-Maximum Suppression
- Positive/negative anchor assignment (IoU thresholds)

### 10.5 ROI Align

**ROI Pooling Problems:**

- Quantization of ROI boundaries
- Quantization of bin divisions
- Misalignment issues for masks

**ROI Align Solution:**

- Bilinear interpolation
- Precise spatial locations
- No quantization
- Critical for mask prediction accuracy

### 10.6 Mask Prediction Branch

- Fully Convolutional Network (FCN)
- Input: 14×14 ROI features
- Architecture: 4× Conv(256, 3×3) + Deconv(256, 2×2, stride 2)
- Output: 28×28 masks per class
- Binary mask prediction (sigmoid)
- Class-specific masks
- Per-pixel loss (binary cross-entropy)

### 10.7 Multi-Task Loss

- L = L_cls + L_box + L_mask
- Classification loss: Cross-entropy
- Box regression loss: Smooth L1
- Mask loss: Average binary cross-entropy
- Only compute L_mask for predicted class
- Decouples mask and class prediction

### 10.8 Feature Pyramid Network (FPN)

**Bottom-Up Pathway:**

- ResNet forward pass
- Feature maps at multiple resolutions
- {C2, C3, C4, C5} from different stages

**Top-Down Pathway:**

- Start from smallest (most semantic) features
- Upsample (2×) and merge with lateral
- {P2, P3, P4, P5} pyramid levels

**Lateral Connections:**

- 1×1 convolutions to match channels
- Element-wise addition
- 3×3 conv to reduce aliasing

**Multi-Scale Predictions:**

- Different ROI sizes map to different pyramid levels
- Small objects → higher resolution features (P2)
- Large objects → lower resolution features (P5)

### 10.9 Training Details

**Data Augmentation:**

- Horizontal flipping
- Scale jittering
- Color jittering
- Random crops

**Positive/Negative Sampling:**

- Positive ROI: IoU > 0.5 with ground truth
- Negative ROI: IoU < 0.5
- Batch size per image (e.g., 512 ROIs)
- Positive-negative ratio (1:3)

**Learning Strategy:**

- Stage-wise training vs end-to-end
- Learning rate schedule
- Weight initialization
- Batch normalization considerations

### 10.10 Inference Pipeline

1. Forward pass through backbone + FPN
2. RPN generates proposals (~1000)
3. NMS reduces proposals (~300)
4. ROI Align extracts features
5. Parallel head predictions
6. Class-specific NMS (100 detections)
7. Mask generation for detections

### 10.11 Extensions and Variants

**Cascade Mask R-CNN:**

- Sequential refinement
- Multiple detection heads with increasing IoU thresholds
- Better localization quality

**HTC (Hybrid Task Cascade):**

- Interweaves bbox and mask branches
- Mask information helps bbox
- Cascade architecture
- Semantic segmentation integration

**Mask Scoring R-CNN:**

- Predicts mask quality score
- Better ranking of instance masks
- MaskIoU head

**PointRend:**

- Iterative subdivision strategy
- Efficient high-resolution prediction
- Point-based rendering
- Better boundary delineation

**Detectron2:**

- Facebook AI Research framework
- Optimized Mask R-CNN implementation
- Model zoo
- Extensible architecture

### 10.12 Performance Analysis

- COCO dataset benchmarks
- mAP for detection
- Mask AP for segmentation
- Speed-accuracy tradeoffs
- Backbone comparisons
- FPN impact analysis

### 10.13 Applications

- Video instance segmentation
- Human pose estimation (Keypoint R-CNN)
- Panoptic segmentation
- 3D scene understanding
- Medical image analysis
- Autonomous driving
- Augmented reality

### 10.14 Practical Considerations

- Memory requirements (large batches)
- Training time (days on multiple GPUs)
- Transfer learning strategies
- Custom dataset preparation (COCO format)
- Annotation requirements
- Class imbalance handling

---


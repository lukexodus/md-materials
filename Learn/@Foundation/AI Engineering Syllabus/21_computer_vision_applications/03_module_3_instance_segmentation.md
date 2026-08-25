## Module 3: Instance Segmentation


### 3.1 Instance Segmentation Fundamentals

- Definition: detect and delineate each object instance
- Difference from semantic and panoptic segmentation
- Mask representation (binary masks, polygons, RLE)
- Applications: medical imaging, robotics, autonomous vehicles
- Challenges: overlapping instances, varying scales

### 3.2 Mask R-CNN and Extensions

- Architecture: Faster R-CNN + mask branch
- RoI Align vs RoI Pooling
- Mask prediction head design
- Loss function: classification + box + mask
- Training strategies and hyperparameters

### 3.3 Mask R-CNN Improvements

- Cascade Mask R-CNN: multi-stage refinement
- HTC (Hybrid Task Cascade)
- Mask Scoring R-CNN
- PointRend: high-resolution mask rendering
- Tensor Mask: structured mask prediction

### 3.4 Single-Stage Instance Segmentation

- YOLACT (You Only Look At CoefficienTs)
- YOLACT++: improvements and optimizations
- SOLOv1 and SOLOv2: instance categories
- Condinst: conditional convolutions
- BlendMask: top-down and bottom-up blending

### 3.5 Transformer-Based Instance Segmentation

- DETR-based instance segmentation
- Mask2Former: universal image segmentation
- QueryInst: query-based instance segmentation
- ISTR (Instance Segmentation Transformer)
- Unified segmentation frameworks

### 3.6 Proposal-Free Methods

- PolarMask: polar coordinate representation
- SOLO: segmenting objects by locations
- Advantages of proposal-free approaches
- Center-based instance segmentation

### 3.7 Panoptic Segmentation

- Unifying stuff and things
- Panoptic FPN
- Panoptic-DeepLab
- EfficientPS
- Evaluation metrics: PQ (Panoptic Quality), SQ, RQ

### 3.8 3D Instance Segmentation

- Point cloud instance segmentation
- 3D bounding boxes and masks
- PointNet++ based approaches
- Sparse convolution methods (MinkowskiNet)
- Applications in robotics and AR/VR

### 3.9 Video Instance Segmentation

- Temporal consistency in masks
- MaskTrack R-CNN
- STEm-Seg
- Video Mask Transfiner
- Challenges: occlusion, appearance changes

### 3.10 Interactive and Weakly-Supervised Segmentation

- Interactive segmentation with clicks/scribbles
- Box-supervised instance segmentation
- Point-supervised methods
- Self-supervised pretraining for segmentation

### 3.11 Evaluation Metrics

- Average Precision (AP) for masks
- IoU thresholds for masks
- Boundary quality metrics
- Panoptic Quality metrics
- Per-category and overall performance

### 3.12 Domain-Specific Applications

- Medical image instance segmentation (cell, organ)
- Document instance segmentation
- Industrial defect segmentation
- Agricultural crop segmentation
- Microscopy image analysis

### 3.13 Optimization and Deployment

- Mask post-processing techniques
- Inference optimization strategies
- Real-time instance segmentation
- Mobile and edge deployment
- Memory-efficient mask representations

---


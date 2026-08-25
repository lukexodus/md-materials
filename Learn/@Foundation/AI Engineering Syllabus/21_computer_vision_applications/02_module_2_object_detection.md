## Module 2: Object Detection


### 2.1 Object Detection Fundamentals

- Problem formulation: localization + classification
- Bounding box representations (xyxy, xywh, cxcywh)
- Challenges: scale variation, occlusion, crowded scenes
- Evaluation metrics: IoU, precision-recall
- Applications: autonomous driving, surveillance, retail

### 2.2 Traditional Object Detection

- Sliding window approaches
- Selective search and region proposals
- HOG + SVM detectors
- Deformable Part Models (DPM)
- Viola-Jones face detector

### 2.3 Two-Stage Detectors: R-CNN Family

- R-CNN: region proposals + CNN features
- Fast R-CNN: RoI pooling and end-to-end training
- Faster R-CNN: Region Proposal Networks (RPN)
- Feature Pyramid Networks (FPN)
- Mask R-CNN extension (preview for segmentation)

### 2.4 Single-Stage Detectors: YOLO Family

- YOLO v1: unified detection framework
- YOLO v2/v3: improvements and darknet
- YOLO v4/v5: CSPNet, PANet, various optimizations
- YOLO v6/v7/v8: recent advances
- YOLOv10 and current state [Inference: based on progression pattern]

### 2.5 Single-Stage Detectors: SSD and RetinaNet

- SSD: multi-scale feature maps
- Anchor box design principles
- RetinaNet and Focal Loss
- Addressing class imbalance in detection
- Feature pyramid variations

### 2.6 Anchor-Free Detection

- CornerNet: keypoint-based detection
- CenterNet: center point detection
- FCOS: fully convolutional one-stage detection
- Advantages over anchor-based methods
- NMS-free approaches

### 2.7 Transformer-Based Detection

- DETR (Detection Transformer): set prediction approach
- Deformable DETR: efficient attention mechanisms
- Conditional DETR and improvements
- Hybrid CNN-Transformer detectors
- Query-based detection paradigm

### 2.8 Specialized Detection Scenarios

- Small object detection techniques
- Rotated object detection (oriented bounding boxes)
- 3D object detection from 2D images
- Video object detection (temporal coherence)
- Weakly-supervised and semi-supervised detection

### 2.9 Detection Training Techniques

- Data augmentation for detection (mosaic, copy-paste)
- Hard negative mining
- Multi-scale training
- Label assignment strategies (IoU-based, center-based)
- Loss functions (L1, smooth L1, IoU loss, GIoU, DIoU, CIoU)

### 2.10 Object Tracking Integration

- Single Object Tracking (SOT)
- Multiple Object Tracking (MOT)
- Tracking-by-detection paradigm
- SORT and DeepSORT
- ByteTrack and recent methods

### 2.11 Evaluation Metrics

- Intersection over Union (IoU)
- Average Precision (AP) at different IoU thresholds
- Mean Average Precision (mAP)
- COCO evaluation metrics (AP50, AP75, APS, APM, APL)
- Frames per second (FPS) and inference time

### 2.12 Domain-Specific Applications

- Face detection (MTCNN, RetinaFace)
- Pedestrian detection (special challenges)
- Text detection in images
- Medical image detection (lesions, tumors)
- Satellite and aerial image detection

### 2.13 Production Considerations

- Model selection: accuracy vs speed tradeoff
- TensorRT optimization for detectors
- Batch processing strategies
- Post-processing optimization (efficient NMS)
- Edge deployment (Jetson, mobile devices)

---


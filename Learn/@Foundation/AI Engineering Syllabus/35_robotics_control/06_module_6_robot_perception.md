## Module 6: Robot Perception


### 6.1 Perception Fundamentals

- Sensor modalities overview
- Perception-action loop
- Latency considerations
- Sensor fusion motivation
- Uncertainty in perception

### 6.2 Computer Vision for Robotics

- Classical vision techniques
    - Edge detection
    - Feature extraction (SIFT, SURF, ORB)
    - Template matching
    - Optical flow
- Deep learning for vision
    - Convolutional neural networks
    - Object detection (YOLO, Faster R-CNN, EfficientDet)
    - Semantic segmentation (U-Net, DeepLab)
    - Instance segmentation (Mask R-CNN)
- 3D vision
    - Stereo vision
    - Structure from motion
    - Multi-view geometry
    - Depth estimation from monocular images

### 6.3 Object Detection and Recognition

- 2D object detection
    - Bounding box prediction
    - Anchor-based vs anchor-free
    - Real-time detection requirements
- 3D object detection
    - Point cloud-based detection
    - Frustum-based methods
    - Multi-modal fusion (camera + LiDAR)
- 6D pose estimation
    - PnP algorithms
    - Deep learning approaches
    - Refinement techniques
- Category-level recognition
- Instance-level recognition

### 6.4 Point Cloud Processing

- Point cloud representation
- PointNet architecture
    - Permutation invariance
    - Spatial transformers
- PointNet++ with hierarchical features
- Voxel-based methods
- Point cloud registration
    - ICP (Iterative Closest Point)
    - Feature-based registration
    - Learning-based registration
- Point cloud segmentation
- Point cloud completion

### 6.5 Depth Sensing

- Stereo cameras
    - Disparity computation
    - Calibration procedures
    - Rectification
- Structured light sensors (Kinect)
- Time-of-Flight (ToF) cameras
- LiDAR sensors
    - Scanning patterns
    - Point cloud generation
    - Velodyne, Livox, solid-state LiDAR
- RGB-D processing
- Depth completion and refinement

### 6.6 Visual SLAM

- Simultaneous Localization and Mapping
- Feature-based SLAM
    - ORB-SLAM architecture
    - Loop closure detection
    - Bundle adjustment
- Direct methods (LSD-SLAM, DSO)
    - Photometric error minimization
    - Semi-dense mapping
- Visual-inertial SLAM
    - IMU integration
    - VINS-Mono, OKVIS
- Deep learning for SLAM
    - Learning-based feature extraction
    - Depth prediction integration

### 6.7 Scene Understanding

- Scene graphs
- Spatial relationship reasoning
- Affordance detection
- Free space estimation
- Obstacle detection and classification
- Traversability analysis

### 6.8 Tactile and Force Sensing

- Tactile sensor types
    - Resistive, capacitive, optical
    - GelSight, DIGIT sensors
- Force-torque sensors
- Proprioceptive sensing
- Haptic feedback
- Contact detection and estimation
- Slip detection

### 6.9 Multi-Modal Sensor Fusion

- Kalman filtering
    - Extended Kalman Filter (EKF)
    - Unscented Kalman Filter (UKF)
- Particle filters
- Sensor synchronization
- Camera-LiDAR fusion
- Vision-IMU fusion
- Uncertainty propagation

### 6.10 Active Perception

- Next-best-view planning
- Gaze control
- Information gain maximization
- Attention mechanisms
- Curiosity-driven perception

### 6.11 Perception for Manipulation

- Grasp detection
    - 2D grasp rectangles
    - 6-DOF grasp poses
    - GraspNet, Contact-GraspNet
- Object segmentation for manipulation
- Transparent and reflective objects
- Occlusion handling
- Pile manipulation perception

### 6.12 Real-Time Perception

- Computational efficiency
- Hardware acceleration (GPU, TPU)
- Model optimization
    - Quantization
    - Pruning
    - Knowledge distillation
- Edge deployment considerations
- Latency-accuracy trade-offs

---


## Video Analysis Models


**Action Recognition Architectures** 3D CNNs extend 2D convolutions to space-time volumes, capturing temporal dynamics directly. Two-stream networks process RGB and optical flow separately then combine predictions. I3D (Inflated 3D ConvNet) inflates 2D ImageNet pre-trained models to 3D. SlowFast networks use dual pathways operating at different temporal resolutions to capture both slow semantic changes and fast motions.

**Temporal Modeling Approaches** Recurrent networks like LSTMs and GRUs model temporal sequences but may struggle with very long sequences. Temporal Segment Networks (TSN) sample sparse frames from videos and aggregate their features. Temporal Shift Module (TSM) enables 2D CNNs to model temporal information efficiently by shifting channels along time dimension. Transformer architectures like TimeSformer apply attention across spatial and temporal dimensions.

**Video Object Detection and Tracking** Video object detection extends static detection to temporal sequences, leveraging motion information and temporal consistency. Feature aggregation across frames improves detection robustness. Tracking-by-detection approaches link detections across frames using appearance and motion cues. End-to-end tracking networks jointly optimize detection and association. Multi-object tracking requires handling object appearances, disappearances, and identity switches.

**Video Segmentation Tasks** Video instance segmentation extends object detection and segmentation to temporal sequences. Video semantic segmentation assigns pixel-level class labels across video frames while maintaining temporal consistency. Video panoptic segmentation combines instance and semantic segmentation. Propagation-based methods leverage optical flow or learned correspondences to maintain consistency.

**Efficiency and Real-Time Processing** Mobile-optimized architectures like MobileVideo use depthwise separable convolutions and efficient temporal modeling. Early exit strategies allow variable computational budgets based on input complexity. Frame sampling strategies reduce computational requirements while maintaining performance. Knowledge distillation transfers knowledge from complex models to efficient ones.

**Self-Supervised Learning** Video provides rich self-supervision signals through temporal consistency, motion patterns, and multi-modal information. Contrastive learning approaches learn representations by distinguishing between different temporal segments. Predictive coding methods learn to predict future frames or features. Multi-modal approaches leverage audio-visual correspondence for representation learning.

**Key Points:**

- 3D convolutions and two-stream approaches are fundamental architectures for video analysis
- Temporal modeling requires balancing short-term dynamics with long-term context
- Video tracking introduces complex association and identity management challenges
- Self-supervised learning from video provides powerful representation learning opportunities


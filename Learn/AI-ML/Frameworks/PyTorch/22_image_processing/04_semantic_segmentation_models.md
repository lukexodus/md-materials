## Semantic Segmentation Models


Semantic segmentation assigns class labels to every pixel in an image, requiring dense prediction architectures that maintain spatial resolution throughout the network.

**Encoder-Decoder Architectures:** U-Net uses symmetric encoder-decoder structure with skip connections that combine low-level and high-level features. The encoder downsamples through convolution and pooling while the decoder upsamples using transposed convolutions or interpolation. Skip connections preserve spatial details lost during downsampling by concatenating encoder features with corresponding decoder features.

**Dilated Convolutions:** DeepLab uses atrous (dilated) convolutions to increase receptive field without reducing spatial resolution. Atrous Spatial Pyramid Pooling (ASPP) captures multi-scale context by applying dilated convolutions with different dilation rates in parallel. Depthwise separable convolutions in MobileNet-based encoders reduce computational requirements while maintaining performance.

**Feature Pyramid Approaches:** Pyramid Scene Parsing Network (PSPNet) aggregates global context through pyramid pooling modules that capture information at multiple scales. Feature Pyramid Networks adapt object detection concepts for segmentation by combining features across different network depths. PAN (Path Aggregation Network) improves information flow between feature levels through additional bottom-up pathways.

**Training Considerations:** Cross-entropy loss handles pixel-wise classification with class balancing to address imbalanced datasets. Dice loss directly optimizes intersection-over-union metrics for better boundary delineation. Focal loss addresses class imbalance by focusing learning on hard examples. Data augmentation includes random cropping, scaling, and color jittering while maintaining pixel-label correspondence.


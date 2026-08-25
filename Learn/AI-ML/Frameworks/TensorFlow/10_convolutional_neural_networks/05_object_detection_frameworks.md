## Object Detection Frameworks


### Two-Stage Detectors

**R-CNN Family**: Region-based detectors that first generate object proposals, then classify and refine bounding boxes.

- **R-CNN**: Uses selective search for proposals, processes each region independently
- **Fast R-CNN**: Shares convolutional features, introduces ROI pooling
- **Faster R-CNN**: End-to-end training with Region Proposal Network (RPN)

### Single-Stage Detectors

**YOLO (You Only Look Once)**: Divides image into grid cells, predicts bounding boxes and class probabilities simultaneously.

**SSD (Single Shot MultiBox Detector)**: Uses multiple feature maps at different scales for detecting objects of various sizes.

**RetinaNet**: Addresses class imbalance problem using focal loss, achieving state-of-the-art performance.

### Modern Approaches

**EfficientDet**: Compound scaling applied to object detection, balancing accuracy and efficiency.

**CenterNet**: Keypoint-based detection treating objects as center points with regression to other properties.

### TensorFlow Object Detection API

```python
# Using TensorFlow Object Detection API
import tensorflow as tf
from object_detection.utils import config_util
from object_detection.builders import model_builder

# Load pre-trained model
pipeline_config = config_util.get_configs_from_pipeline_file(config_path)
detection_model = model_builder.build(
    model_config=pipeline_config['model'], 
    is_training=False
)

# Restore checkpoint
ckpt = tf.compat.v2.train.Checkpoint(model=detection_model)
ckpt.restore(checkpoint_path)

def detect_objects(image):
    input_tensor = tf.convert_to_tensor(image)
    input_tensor = input_tensor[tf.newaxis, ...]
    
    detections = detection_model(input_tensor)
    return detections
```


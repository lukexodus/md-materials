## Object Detection Models


Object detection simultaneously localizes and classifies multiple objects within images, requiring both spatial precision and semantic understanding. Modern architectures balance speed and accuracy through sophisticated design choices.

**Two-Stage Detection (R-CNN Family):** R-CNN approaches first generate region proposals, then classify each proposal. This two-stage process achieves high accuracy but requires significant computational resources.

**TensorFlow Object Detection API:**

```python
import tensorflow as tf
from object_detection.utils import config_util
from object_detection.builders import model_builder

# Load pre-trained model configuration
CONFIG_PATH = 'models/ssd_mobilenet_v2/pipeline.config'
CHECKPOINT_PATH = 'models/ssd_mobilenet_v2/checkpoint'

config = config_util.get_configs_from_pipeline_file(CONFIG_PATH)
model_config = config['model']
detection_model = model_builder.build(model_config=model_config, is_training=False)

# Restore checkpoint
ckpt = tf.compat.v2.train.Checkpoint(model=detection_model)
ckpt.restore(CHECKPOINT_PATH).expect_partial()

@tf.function
def detect_objects(image):
    image, shapes = detection_model.preprocess(image)
    prediction_dict = detection_model.predict(image, shapes)
    detections = detection_model.postprocess(prediction_dict, shapes)
    return detections

# Custom training loop
def train_step(images, groundtruth):
    with tf.GradientTape() as tape:
        prediction_dict = detection_model.predict(images, training=True)
        losses_dict = detection_model.loss(prediction_dict, groundtruth)
        total_loss = losses_dict['Loss/localization_loss'] + losses_dict['Loss/classification_loss']
    
    gradients = tape.gradient(total_loss, detection_model.trainable_variables)
    optimizer.apply_gradients(zip(gradients, detection_model.trainable_variables))
    return total_loss
```

**Single-Stage Detection (YOLO, SSD):** Single-stage detectors predict bounding boxes and class probabilities directly from feature maps, achieving real-time performance with competitive accuracy.

**YOLOv5 Implementation:**

```python
def create_yolo_model(input_shape, num_classes, num_anchors=3):
    inputs = tf.keras.Input(shape=input_shape)
    
    # Backbone (CSPDarknet53)
    x = darknet_backbone(inputs)
    
    # Feature Pyramid Network
    features = fpn_neck(x)
    
    # Detection heads
    outputs = []
    for i, feature in enumerate(features):
        # Classification head
        cls_output = layers.Conv2D(
            num_anchors * num_classes, 1, activation='sigmoid'
        )(feature)
        
        # Regression head
        reg_output = layers.Conv2D(
            num_anchors * 4, 1
        )(feature)
        
        # Objectness head
        obj_output = layers.Conv2D(
            num_anchors, 1, activation='sigmoid'
        )(feature)
        
        # Combine outputs
        combined = tf.concat([reg_output, obj_output, cls_output], axis=-1)
        outputs.append(combined)
    
    return tf.keras.Model(inputs, outputs)

# YOLO loss function
def yolo_loss(y_true, y_pred, anchors, num_classes):
    # Extract predictions
    pred_boxes = y_pred[..., :4]
    pred_obj = y_pred[..., 4:5]
    pred_cls = y_pred[..., 5:]
    
    # Extract ground truth
    true_boxes = y_true[..., :4]
    true_obj = y_true[..., 4:5]
    true_cls = y_true[..., 5:]
    
    # Box regression loss
    box_loss = tf.reduce_sum(
        true_obj * tf.keras.losses.mse(true_boxes, pred_boxes)
    )
    
    # Objectness loss
    obj_loss = tf.keras.losses.binary_crossentropy(true_obj, pred_obj)
    
    # Classification loss
    cls_loss = tf.reduce_sum(
        true_obj * tf.keras.losses.categorical_crossentropy(true_cls, pred_cls)
    )
    
    return box_loss + obj_loss + cls_loss
```

**Anchor-Free Detection:** Modern approaches like CenterNet and FCOS eliminate anchor boxes, predicting object centers and dimensions directly, simplifying architecture design and improving performance.

**3D Object Detection:** Extensions to 3D scenarios require depth estimation and pose prediction, often utilizing LiDAR data or stereo vision for spatial understanding.


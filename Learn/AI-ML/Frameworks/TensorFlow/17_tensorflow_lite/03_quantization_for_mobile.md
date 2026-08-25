## Quantization for Mobile


### Quantization Techniques

Quantization reduces model size and improves inference speed by representing weights and activations with lower precision data types. This technique significantly reduces memory footprint and enables hardware acceleration.

**Post-training Quantization**: Applies quantization after training without requiring retraining. Supports dynamic range quantization (weights only) and full integer quantization (weights and activations).

**Quantization-aware Training**: Simulates quantization effects during training, allowing model to adapt to precision loss and maintain higher accuracy.

**Mixed Precision**: Uses different precision levels for different operations, balancing accuracy and efficiency based on sensitivity analysis.

### Implementation Strategies

**Dynamic Range Quantization**: Quantizes weights from float32 to int8 while keeping activations as float32, providing 4x model size reduction with minimal accuracy loss.

**Full Integer Quantization**: Quantizes both weights and activations to int8, enabling integer-only inference on specialized hardware accelerators.

**Float16 Quantization**: Uses 16-bit floating point representation, providing 2x size reduction while maintaining high accuracy for most models.

### TensorFlow Lite Quantization

```python
# Post-training quantization implementations
import tensorflow as tf
import numpy as np

def dynamic_range_quantization(model):
    """Convert model with dynamic range quantization"""
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    tflite_quant_model = converter.convert()
    return tflite_quant_model

def full_integer_quantization(model, representative_data_gen):
    """Convert model with full integer quantization"""
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.representative_dataset = representative_data_gen
    
    # Enforce integer only inference
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    converter.inference_input_type = tf.uint8
    converter.inference_output_type = tf.uint8
    
    tflite_quant_model = converter.convert()
    return tflite_quant_model

def float16_quantization(model):
    """Convert model with float16 quantization"""
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float16]
    
    tflite_quant_model = converter.convert()
    return tflite_quant_model

# Quantization-aware training
def quantization_aware_training(model, train_dataset, val_dataset):
    """Apply quantization-aware training"""
    import tensorflow_model_optimization as tfmot
    
    # Apply quantization to model
    quantize_model = tfmot.quantization.keras.quantize_model
    q_aware_model = quantize_model(model)
    
    # Compile with appropriate optimizer
    q_aware_model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-5),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    # Train quantized model
    q_aware_model.fit(
        train_dataset,
        validation_data=val_dataset,
        epochs=5,
        callbacks=[
            tf.keras.callbacks.EarlyStopping(patience=3),
            tf.keras.callbacks.ReduceLROnPlateau()
        ]
    )
    
    # Convert to TensorFlow Lite
    converter = tf.lite.TFLiteConverter.from_keras_model(q_aware_model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    quantized_tflite_model = converter.convert()
    return quantized_tflite_model

# Representative dataset generation
def create_representative_dataset(dataset, num_calibration_samples=100):
    """Create representative dataset for quantization calibration"""
    def representative_data_gen():
        sample_count = 0
        for input_value in dataset.take(num_calibration_samples):
            # Ensure proper shape and type
            if isinstance(input_value, tuple):
                input_value = input_value[0]  # Take only input, ignore labels
            
            yield [tf.cast(input_value, tf.float32)]
            sample_count += 1
            
            if sample_count >= num_calibration_samples:
                break
                
    return representative_data_gen
```


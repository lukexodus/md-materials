## Model Conversion Processes


### Conversion Pipeline

TensorFlow Lite conversion transforms trained models into optimized format suitable for mobile and edge deployment. The process involves graph optimization, operator mapping, and format transformation.

**SavedModel Conversion**: Converts TensorFlow SavedModel format to TensorFlow Lite flatbuffer format with automatic optimization passes.

**Keras Model Conversion**: Direct conversion from Keras models with preservation of training configuration and metadata.

**Frozen Graph Conversion**: Legacy conversion path for TensorFlow 1.x frozen graphs with manual optimization control.

### Graph Optimization

**Constant Folding**: Pre-computes constant operations during conversion, reducing runtime computational overhead.

**Dead Code Elimination**: Removes unused operations and variables from computation graph, reducing model size and memory usage.

**Operator Fusion**: Combines multiple operations into single optimized kernels, reducing memory transfers and improving cache efficiency.

### TensorFlow Lite Converter

```python
# Comprehensive model conversion examples
import tensorflow as tf

# Convert from SavedModel
def convert_from_savedmodel(saved_model_dir):
    converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_dir)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Enable GPU delegate support
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
        tf.lite.OpsSet.SELECT_TF_OPS  # Fallback for unsupported ops
    ]
    
    tflite_model = converter.convert()
    return tflite_model

# Convert with custom optimization
def convert_with_custom_optimization(model, representative_dataset=None):
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Advanced optimization settings
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    if representative_dataset:
        converter.representative_dataset = representative_dataset
        # Enable full integer quantization
        converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
        converter.inference_input_type = tf.uint8
        converter.inference_output_type = tf.uint8
    
    # Enable experimental optimizations
    converter.experimental_new_converter = True
    converter.experimental_new_quantizer = True
    
    try:
        tflite_model = converter.convert()
        return tflite_model
    except Exception as e:
        print(f"Conversion failed: {e}")
        # Fallback to less aggressive optimization
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,
            tf.lite.OpsSet.SELECT_TF_OPS
        ]
        return converter.convert()

# Model metadata addition
def add_model_metadata(tflite_model, metadata_dict):
    """Add metadata to TensorFlow Lite model"""
    from tflite_support import metadata as _metadata
    from tflite_support import metadata_schema_py_generated as _metadata_fb
    
    # Create metadata builder
    model_meta = _metadata_fb.ModelMetadataT()
    model_meta.name = metadata_dict.get('name', 'TensorFlow Lite Model')
    model_meta.description = metadata_dict.get('description', '')
    model_meta.version = metadata_dict.get('version', '1.0.0')
    
    # Add input/output metadata
    input_meta = _metadata_fb.TensorMetadataT()
    input_meta.name = metadata_dict.get('input_name', 'input')
    input_meta.description = metadata_dict.get('input_description', '')
    
    output_meta = _metadata_fb.TensorMetadataT()
    output_meta.name = metadata_dict.get('output_name', 'output')
    output_meta.description = metadata_dict.get('output_description', '')
    
    # Build metadata
    builder = _metadata.MetadataDisplayer.with_model_file(tflite_model)
    builder.add_model_metadata(model_meta)
    
    return builder.get_model_buffer()
```


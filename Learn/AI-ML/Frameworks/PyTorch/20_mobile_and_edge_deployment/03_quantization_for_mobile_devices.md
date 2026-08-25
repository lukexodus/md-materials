## Quantization for Mobile Devices


Quantization reduces model size and computational requirements by converting floating-point weights and activations to lower-precision integer representations, typically 8-bit integers.

### Static Quantization

Static quantization requires a calibration dataset to determine optimal quantization parameters. This approach provides the most significant performance improvements but requires representative data for calibration.

```python
import torch.quantization as quantization

## Prepare model for quantization
model.qconfig = quantization.get_default_qconfig('fbgemm')
quantization.prepare(model, inplace=True)

## Calibrate with representative data
with torch.no_grad():
    for data in calibration_dataset:
        model(data)

## Convert to quantized model
quantized_model = quantization.convert(model, inplace=False)
```

### Dynamic Quantization

Dynamic quantization quantizes weights statically but computes activation quantization parameters dynamically during inference. This approach requires no calibration data but provides moderate performance gains.

### Quantization-Aware Training (QAT)

QAT simulates quantization during training, allowing the model to adapt to quantization effects and typically achieving better accuracy than post-training quantization.

**Key Points:**

- Static quantization typically provides 4x model size reduction and 2-4x inference speedup
- Dynamic quantization offers easier implementation with moderate performance gains
- QAT generally achieves the best accuracy-performance trade-off for quantized models


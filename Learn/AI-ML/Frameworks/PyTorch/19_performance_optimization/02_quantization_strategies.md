## Quantization Strategies


**Post-Training Quantization** This approach converts a trained full-precision model to lower precision without additional training. PyTorch's `torch.quantization` module supports INT8 quantization through `torch.quantization.quantize_dynamic` for dynamic quantization and `torch.quantization.quantize` for static quantization. Dynamic quantization quantizes weights ahead of time but computes activations in floating point, while static quantization pre-calibrates activation quantization parameters using representative datasets.

**Quantization-Aware Training (QAT)** QAT simulates quantization effects during training by adding fake quantization operations that model the rounding behavior of actual quantized inference. This allows the model to learn to be robust to quantization noise. PyTorch implements QAT through `torch.quantization.prepare_qat` and supports both eager mode and FX graph mode quantization.

**Mixed Precision Strategies** Different layers may have varying sensitivity to quantization. Sensitive layers like the first and last layers often remain in higher precision, while intermediate layers use lower precision. Some approaches use automated sensitivity analysis to determine optimal bit-widths per layer.

**Advanced Quantization Techniques** Knowledge distillation can be combined with quantization where a full-precision teacher model guides the training of a quantized student model. Binary and ternary quantization push quantization to extreme levels, using only 1 or 2 bits per weight. Vector quantization approaches quantize groups of weights together rather than individually.

**Key Points:**

- Post-training quantization requires no retraining but may lose accuracy
- QAT typically achieves better accuracy-efficiency trade-offs
- Mixed precision allows fine-grained control over accuracy-speed trade-offs
- INT8 quantization commonly provides 2-4x speedup with minimal accuracy loss


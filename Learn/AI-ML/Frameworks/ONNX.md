# Comprehensive Guide to ONNX

## What ONNX Is

ONNX (Open Neural Network Exchange) is an open-source format for representing machine learning models. It defines a common computation graph format plus a set of standardized operators, so a model trained in one framework (PyTorch, TensorFlow, Keras, scikit-learn, etc.) can be exported once and then run in a completely different runtime or deployed on different hardware — without needing the original training framework installed.

The core value proposition is **interoperability** and **deployment portability**: train anywhere, run anywhere.

---

## 1. Core Concepts

### 1.1 The ONNX Graph

An ONNX model is a serialized computation graph (protobuf format, `.onnx` file) consisting of:

- **Nodes** — operators (e.g., `Conv`, `MatMul`, `Relu`) forming the graph
- **Inputs/Outputs** — named tensors with defined shapes and data types
- **Initializers** — the trained weights/parameters, stored as tensors within the graph
- **Value info** — shape/type metadata for intermediate tensors
- **Opset version** — which version of the ONNX operator specification the model targets (operators can change behavior or gain features across opset versions)

### 1.2 Why It Matters

- **Framework independence**: export from PyTorch, load and run in a C++ app, Java, JavaScript, or a different Python stack entirely — no PyTorch install required at inference time.
- **Hardware/runtime independence**: ONNX Runtime (the reference execution engine) supports pluggable "execution providers" — CPU, CUDA, TensorRT, DirectML, CoreML, OpenVINO, and more — so the same `.onnx` file can be accelerated differently per deployment target.
- **Optimization opportunities**: because the graph is static and standardized, tools can apply graph-level optimizations (operator fusion, constant folding, quantization) that are harder to do generically inside a dynamic framework.

---

## 2. Installation

```bash
# Core ONNX library (graph representation, model checking, ops)
pip install onnx

# ONNX Runtime (execution engine) - CPU version
pip install onnxruntime

# GPU version (CUDA execution provider)
pip install onnxruntime-gpu

# For exporting from PyTorch (built in, no extra package needed beyond torch)
# For exporting from TensorFlow/Keras
pip install tf2onnx

# For exporting from scikit-learn
pip install skl2onnx

# For visualizing graphs
pip install netron
```

Check your install:

```python
import onnx
import onnxruntime as ort

print(onnx.__version__)
print(ort.get_available_providers())  # e.g. ['CPUExecutionProvider', 'CUDAExecutionProvider']
```

---

## 3. Exporting Models to ONNX

### 3.1 From PyTorch

PyTorch has built-in ONNX export via `torch.onnx.export`. As of recent PyTorch versions, there are two exporter backends: the legacy TorchScript-based exporter and the newer **TorchDynamo-based exporter** (`dynamo=True`), which is more robust for models with dynamic control flow.

```python
import torch
import torch.nn as nn

class SimpleModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.fc1 = nn.Linear(784, 128)
        self.relu = nn.ReLU()
        self.fc2 = nn.Linear(128, 10)

    def forward(self, x):
        return self.fc2(self.relu(self.fc1(x)))

model = SimpleModel()
model.eval()

dummy_input = torch.randn(1, 784)

torch.onnx.export(
    model,
    dummy_input,
    "simple_model.onnx",
    export_params=True,          # store trained weights
    opset_version=17,            # ONNX opset version
    do_constant_folding=True,    # fold constants for optimization
    input_names=["input"],
    output_names=["output"],
    dynamic_axes={               # allow variable batch size
        "input": {0: "batch_size"},
        "output": {0: "batch_size"},
    },
)
```

Using the newer dynamo-based exporter (recommended going forward):

```python
onnx_program = torch.onnx.export(
    model,
    dummy_input,
    dynamo=True,
)
onnx_program.optimize()
onnx_program.save("simple_model.onnx")
```

**Key parameters:**

- `dynamic_axes` — without this, the exported graph bakes in fixed shapes (e.g., always batch size 1), which breaks if you feed a different batch size at inference.
- `opset_version` — higher opsets support more/newer operators; pick the lowest version that supports everything your model needs, for maximum runtime compatibility.
- Model must be in `.eval()` mode before export so layers like `Dropout` and `BatchNorm` behave correctly (inference mode, not training mode).

### 3.2 From TensorFlow / Keras

Using `tf2onnx`:

```bash
python -m tf2onnx.convert --saved-model saved_model_dir --output model.onnx --opset 17
```

Or from Python, converting a Keras model:

```python
import tf2onnx
import tensorflow as tf

model = tf.keras.models.load_model("my_model.keras")

spec = (tf.TensorSpec((None, 28, 28, 1), tf.float32, name="input"),)
output_path = "model.onnx"

model_proto, _ = tf2onnx.convert.from_keras(
    model, input_signature=spec, opset=17, output_path=output_path
)
```

### 3.3 From scikit-learn

Using `skl2onnx`:

```python
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType
from sklearn.ensemble import RandomForestClassifier

clf = RandomForestClassifier()
clf.fit(X_train, y_train)

initial_type = [("float_input", FloatTensorType([None, X_train.shape[1]]))]
onnx_model = convert_sklearn(clf, initial_types=initial_type)

with open("rf_model.onnx", "wb") as f:
    f.write(onnx_model.SerializeToString())
```

### 3.4 From Hugging Face Transformers

Hugging Face provides `optimum` for straightforward transformer-to-ONNX export:

```bash
pip install optimum[exporters]

optimum-cli export onnx --model bert-base-uncased bert_onnx/
```

Or programmatically:

```python
from optimum.onnxruntime import ORTModelForSequenceClassification

model = ORTModelForSequenceClassification.from_pretrained(
    "distilbert-base-uncased-finetuned-sst-2-english", export=True
)
model.save_pretrained("distilbert_onnx/")
```

---

## 4. Validating an Exported Model

### 4.1 Structural Check

```python
import onnx

onnx_model = onnx.load("model.onnx")
onnx.checker.check_model(onnx_model)  # raises if invalid
print("Model is valid!")
```

### 4.2 Inspecting the Graph

```python
import onnx

model = onnx.load("model.onnx")

print(model.graph.input)   # input tensor specs (name, shape, dtype)
print(model.graph.output)  # output tensor specs

for node in model.graph.node:
    print(node.op_type, node.name, node.input, node.output)

# Human-readable summary
print(onnx.helper.printable_graph(model.graph))
```

### 4.3 Numerical Correctness Check

Compare the ONNX model's output against the original framework's output on the same input — this is the step people skip and later regret:

```python
import numpy as np
import onnxruntime as ort
import torch

dummy_input = torch.randn(1, 784)

# Original PyTorch output
with torch.no_grad():
    torch_out = model(dummy_input).numpy()

# ONNX Runtime output
sess = ort.InferenceSession("simple_model.onnx")
onnx_out = sess.run(None, {"input": dummy_input.numpy()})[0]

np.testing.assert_allclose(torch_out, onnx_out, rtol=1e-3, atol=1e-5)
print("Outputs match!")
```

### 4.4 Visual Inspection

[Netron](https://netron.app) is the standard tool for visualizing ONNX graphs — either the web app (drag-and-drop `.onnx` file) or the local `netron` pip package:

```python
import netron
netron.start("model.onnx")  # opens a local viewer in your browser
```

---

## 5. Running Inference with ONNX Runtime

### 5.1 Basic Inference

```python
import onnxruntime as ort
import numpy as np

sess = ort.InferenceSession("model.onnx", providers=["CPUExecutionProvider"])

# Discover input/output names and shapes
for inp in sess.get_inputs():
    print(inp.name, inp.shape, inp.type)
for out in sess.get_outputs():
    print(out.name, out.shape, out.type)

input_data = np.random.randn(1, 784).astype(np.float32)
outputs = sess.run(
    output_names=None,  # None = return all outputs
    input_feed={"input": input_data},
)
print(outputs[0])
```

### 5.2 Execution Providers (Hardware Acceleration)

ONNX Runtime picks providers in the order you list them, falling back if one isn't available on the machine:

```python
providers = [
    "CUDAExecutionProvider",   # NVIDIA GPU
    "CPUExecutionProvider",    # fallback
]
sess = ort.InferenceSession("model.onnx", providers=providers)
```

Other notable providers:

- `TensorrtExecutionProvider` — NVIDIA TensorRT, aggressive GPU optimization
- `OpenVINOExecutionProvider` — Intel CPUs/iGPUs/VPUs
- `DmlExecutionProvider` — DirectML, Windows GPU (any vendor)
- `CoreMLExecutionProvider` — Apple Silicon/Neural Engine
- `ROCMExecutionProvider` — AMD GPUs

You must install the matching `onnxruntime` build (or the correct extra) for non-CPU providers — the plain CPU package won't include CUDA/TensorRT support.

### 5.3 Session Options (Performance Tuning)

```python
import onnxruntime as ort

opts = ort.SessionOptions()
opts.intra_op_num_threads = 4
opts.execution_mode = ort.ExecutionMode.ORT_SEQUENTIAL
opts.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL

sess = ort.InferenceSession("model.onnx", sess_options=opts, providers=["CPUExecutionProvider"])
```

`graph_optimization_level` options:

- `ORT_DISABLE_ALL`
- `ORT_ENABLE_BASIC` — constant folding, redundant node elimination
- `ORT_ENABLE_EXTENDED` — operator fusion (e.g., Conv+BatchNorm+ReLU → single fused op)
- `ORT_ENABLE_ALL` — includes layout optimizations

### 5.4 IO Binding (Avoiding Copy Overhead)

For repeated inference or GPU workloads, `IOBinding` avoids unnecessary host↔device memory copies:

```python
io_binding = sess.io_binding()
io_binding.bind_cpu_input("input", input_data)
io_binding.bind_output("output")
sess.run_with_iobinding(io_binding)
result = io_binding.copy_outputs_to_cpu()
```

---

## 6. Dynamic Shapes and Batching

If you exported with `dynamic_axes` (PyTorch) or an equivalent mechanism, the graph accepts variable input dimensions:

```python
# Works with any batch size at inference time
outputs_batch1 = sess.run(None, {"input": np.random.randn(1, 784).astype(np.float32)})
outputs_batch32 = sess.run(None, {"input": np.random.randn(32, 784).astype(np.float32)})
```

If you didn't mark a dimension as dynamic, the shape is frozen at export time and feeding a different shape will raise a runtime shape-mismatch error.

---

## 7. Graph Manipulation and Optimization

### 7.1 ONNX's Built-in Optimizer / Shape Inference

```python
import onnx
from onnx import shape_inference

model = onnx.load("model.onnx")
inferred_model = shape_inference.infer_shapes(model)  # fills in intermediate tensor shapes
onnx.save(inferred_model, "model_with_shapes.onnx")
```

### 7.2 onnxoptimizer

A separate package that provides classic graph-rewrite passes:

```bash
pip install onnxoptimizer
```

```python
import onnx
import onnxoptimizer

model = onnx.load("model.onnx")
passes = ["eliminate_identity", "eliminate_nop_dropout", "fuse_bn_into_conv"]
optimized_model = onnxoptimizer.optimize(model, passes)
onnx.save(optimized_model, "model_optimized.onnx")
```

### 7.3 onnx-simplifier

Simplifies graphs by folding constants and removing redundant operators — very commonly used after export, especially from PyTorch, where the raw export often contains unnecessary `Shape`/`Gather`/`Unsqueeze` chains:

```bash
pip install onnxsim
```

```python
from onnxsim import simplify
import onnx

model = onnx.load("model.onnx")
model_simplified, check = simplify(model)
assert check, "Simplified model could not be validated"
onnx.save(model_simplified, "model_simplified.onnx")
```

Or via CLI:

```bash
onnxsim model.onnx model_simplified.onnx
```

### 7.4 Manually Editing a Graph

You can build/modify graphs directly with `onnx.helper` — useful for surgery (removing a node, renaming I/O, splitting a model):

```python
import onnx
from onnx import helper, TensorProto

# Example: constructing a node manually
node = helper.make_node(
    "Relu",
    inputs=["x"],
    outputs=["y"],
    name="relu_node",
)

graph = helper.make_graph(
    nodes=[node],
    name="simple_graph",
    inputs=[helper.make_tensor_value_info("x", TensorProto.FLOAT, [None, 10])],
    outputs=[helper.make_tensor_value_info("y", TensorProto.FLOAT, [None, 10])],
)

model = helper.make_model(graph, producer_name="manual_example")
onnx.checker.check_model(model)
onnx.save(model, "manual_model.onnx")
```

---

## 8. Quantization

Quantization reduces model precision (e.g., FP32 → INT8) to shrink size and speed up inference, usually with some accuracy tradeoff.

### 8.1 Dynamic Quantization

Weights are quantized ahead of time; activations are quantized on-the-fly during inference. Simplest to apply, good for CPU inference of models like transformers:

```python
from onnxruntime.quantization import quantize_dynamic, QuantType

quantize_dynamic(
    model_input="model.onnx",
    model_output="model_quantized.onnx",
    weight_type=QuantType.QInt8,
)
```

### 8.2 Static Quantization

Both weights and activations are quantized ahead of time, using a calibration dataset to determine activation ranges. Generally more accurate than dynamic quantization for the same bit-width, but requires representative calibration data:

```python
from onnxruntime.quantization import quantize_static, CalibrationDataReader, QuantType, QuantFormat

class MyCalibrationDataReader(CalibrationDataReader):
    def __init__(self, calibration_data):
        self.data = iter(calibration_data)

    def get_next(self):
        batch = next(self.data, None)
        if batch is None:
            return None
        return {"input": batch}

calib_reader = MyCalibrationDataReader(calibration_samples)

quantize_static(
    model_input="model.onnx",
    model_output="model_static_quantized.onnx",
    calibration_data_reader=calib_reader,
    quant_format=QuantFormat.QDQ,
    weight_type=QuantType.QInt8,
    activation_type=QuantType.QInt8,
)
```

### 8.3 Float16 Conversion

A simpler, often lower-risk optimization for GPU inference — halves memory footprint with typically minimal accuracy loss:

```python
from onnxconverter_common import float16
import onnx

model = onnx.load("model.onnx")
model_fp16 = float16.convert_float_to_float16(model)
onnx.save(model_fp16, "model_fp16.onnx")
```

---

## 9. Deployment Targets

One of ONNX's biggest strengths is the breadth of places the same `.onnx` file can run:

|Target|How|
|---|---|
|Python|`onnxruntime` pip package|
|C++|ONNX Runtime C++ API|
|C# / .NET|`Microsoft.ML.OnnxRuntime` NuGet package|
|Java|`onnxruntime` Java package|
|JavaScript / Browser|`onnxruntime-web` (WASM or WebGL/WebGPU backend)|
|React Native / Mobile|`onnxruntime-react-native`, `onnxruntime-mobile` (Android/iOS)|
|Edge / IoT|ONNX Runtime with minimal build, or hardware-specific SDKs (e.g., NVIDIA Jetson via TensorRT EP)|
|Rust|`ort` crate (community bindings around ONNX Runtime)|
|Serving infrastructure|Triton Inference Server (NVIDIA) supports ONNX as a backend directly|

### Browser example (onnxruntime-web)

```javascript
import * as ort from 'onnxruntime-web';

async function runInference() {
  const session = await ort.InferenceSession.create('./model.onnx');
  const inputTensor = new ort.Tensor('float32', inputData, [1, 784]);
  const results = await session.run({ input: inputTensor });
  console.log(results.output.data);
}
```

---

## 10. Common Operator/Compatibility Issues

Exporting isn't always frictionless — here are the recurring pain points:

- **Unsupported ops**: some framework-specific ops (custom CUDA kernels, exotic indexing, certain control-flow constructs) have no direct ONNX equivalent. Fixes: rewrite the op using supported primitives, register a custom ONNX op, or use a symbolic function override (PyTorch: `torch.onnx.register_custom_op_symbolic`).
- **Dynamic control flow**: `if`/`for` statements that depend on tensor _values_ (not just shapes) are tricky for the older TorchScript-based tracer, since tracing only records the path taken for the example input. `torch.jit.script` mode or the newer dynamo-based exporter handle this better than plain tracing.
- **Opset mismatches**: an operator's behavior or required attributes can change between opset versions. If your runtime is older than the opset your model targets, some ops may be unrecognized — check `onnxruntime`'s supported opset range against your export's `opset_version`.
- **In-place operations**: some in-place tensor ops trace poorly; prefer out-of-place equivalents in the model definition when exporting.
- **Non-deterministic ops**: things like unordered scatter operations may produce results that differ subtly across runtimes/hardware due to floating-point summation order.
- **String/tokenizer logic**: preprocessing that lives in Python (e.g., custom tokenization) often isn't exportable — this logic typically has to be reimplemented in the deployment environment or handled by a companion library, since ONNX represents tensor computation, not arbitrary Python.

---

## 11. Practical End-to-End Example (PyTorch → ONNX → Inference)

```python
import torch
import torch.nn as nn
import onnx
import onnxruntime as ort
import numpy as np

# 1. Define and "train" a toy model
class CNN(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv1 = nn.Conv2d(1, 32, 3)
        self.pool = nn.MaxPool2d(2)
        self.conv2 = nn.Conv2d(32, 64, 3)
        self.fc = nn.Linear(64 * 5 * 5, 10)

    def forward(self, x):
        x = self.pool(torch.relu(self.conv1(x)))
        x = self.pool(torch.relu(self.conv2(x)))
        x = x.flatten(1)
        return self.fc(x)

model = CNN()
model.eval()

# 2. Export
dummy_input = torch.randn(1, 1, 28, 28)
torch.onnx.export(
    model, dummy_input, "cnn.onnx",
    input_names=["input"], output_names=["output"],
    dynamic_axes={"input": {0: "batch"}, "output": {0: "batch"}},
    opset_version=17,
)

# 3. Validate
onnx_model = onnx.load("cnn.onnx")
onnx.checker.check_model(onnx_model)

# 4. Compare numerical outputs
with torch.no_grad():
    torch_out = model(dummy_input).numpy()

sess = ort.InferenceSession("cnn.onnx", providers=["CPUExecutionProvider"])
onnx_out = sess.run(None, {"input": dummy_input.numpy()})[0]

np.testing.assert_allclose(torch_out, onnx_out, rtol=1e-3, atol=1e-5)
print("Export verified. Outputs match.")

# 5. Run inference on a batch of different size (thanks to dynamic_axes)
batch_input = np.random.randn(16, 1, 28, 28).astype(np.float32)
batch_out = sess.run(None, {"input": batch_input})[0]
print(batch_out.shape)  # (16, 10)
```

---

## 12. ONNX vs. Alternatives — Quick Positioning

|Approach|Tradeoff|
|---|---|
|**ONNX**|Broadest cross-framework/cross-runtime portability; mature tooling; good CPU/GPU/edge support|
|**TorchScript**|PyTorch-native, no conversion loss, but locked to LibTorch/PyTorch ecosystem|
|**TensorFlow SavedModel / TFLite**|TF-native; TFLite specifically strong for mobile/edge but TF-only|
|**Framework-native serving (e.g., TF Serving, TorchServe)**|Simpler if you're staying in one framework's ecosystem the whole way|
|**TensorRT (direct)**|Maximum NVIDIA GPU performance, but NVIDIA-only and less portable; often used _via_ ONNX as an intermediate|
|**CoreML**|Apple-only, but best-in-class on Apple hardware; conversion tools exist from ONNX/PyTorch|

In practice, ONNX is frequently the **intermediate hop**: train in PyTorch/TF → export to ONNX → convert further to TensorRT/CoreML/TFLite for final hardware-specific deployment, since many of those hardware-specific converters accept ONNX as input.

---

## 13. Debugging Tips

- **Shape mismatch errors at inference**: check whether the dimension you're varying was marked `dynamic_axes` (or dynamic dimension equivalent) at export time.
- **Silently wrong outputs (no error, just bad numbers)**: almost always means `model.eval()` was forgotten before export (BatchNorm/Dropout in training mode), or a preprocessing step (normalization, resizing) differs between training and the ONNX inference pipeline.
- **"Unsupported operator" during export**: check the opset version first (bump it up); if still unsupported, search whether the op has a symbolic registration available, or restructure the model to avoid it.
- **Slow inference despite "using GPU"**: confirm the actual provider in use — `sess.get_providers()` — since ONNX Runtime silently falls back to CPU if the requested provider isn't properly installed/available, without necessarily raising an error.
- **Netron is your friend**: when something looks wrong structurally, visualize the exported graph before assuming the runtime is at fault — many bugs are visible immediately as an unexpected op sequence or a dangling/duplicate node.

---

## 14. Where to Go Next

- Official site: [onnx.ai](https://onnx.ai)
- ONNX Runtime docs: [onnxruntime.ai](https://onnxruntime.ai)
- Model zoo (pretrained ONNX models): [github.com/onnx/models](https://github.com/onnx/models)
- Netron (graph viewer): [netron.app](https://netron.app)
- Operator spec reference: [github.com/onnx/onnx/blob/main/docs/Operators.md](https://github.com/onnx/onnx/blob/main/docs/Operators.md)


# Comprehensive Guide to Keras

## What Keras Is

Keras is a high-level deep learning API written in Python. Since TensorFlow 2.0, Keras has been TensorFlow's official high-level API (`tf.keras`), and as of Keras 3 (released 2023), it's become a **multi-backend** framework that can run on top of TensorFlow, PyTorch, or JAX interchangeably. It's designed around the principle of progressive disclosure of complexity: simple things should be simple, and complex things should be possible.

---

## 1. Installation and Setup

```bash
# Install Keras 3 (multi-backend)
pip install keras

# Install a backend (at least one required)
pip install tensorflow    # for TensorFlow backend
pip install torch         # for PyTorch backend
pip install jax jaxlib    # for JAX backend
```

Selecting a backend:

```python
import os
os.environ["KERAS_BACKEND"] = "tensorflow"  # or "torch", "jax"

import keras
print(keras.__version__)
print(keras.backend.backend())  # confirms active backend
```

You can also set this permanently via the `~/.keras/keras.json` config file or the `KERAS_BACKEND` environment variable in your shell.

---

## 2. Core Concepts

### 2.1 Tensors and Backend Ops

Keras 3 provides a backend-agnostic tensor API (`keras.ops`), so code you write works regardless of which backend is active.

```python
import keras
import keras.ops as ops

x = ops.array([[1.0, 2.0], [3.0, 4.0]])
y = ops.matmul(x, x)
print(y)
```

### 2.2 Layers

The `Layer` is the fundamental building block — it encapsulates state (weights) and a computation (forward pass).

```python
import keras
from keras import layers

dense = layers.Dense(units=64, activation="relu")
```

Common layers:

|Layer|Purpose|
|---|---|
|`Dense`|Fully connected layer|
|`Conv2D` / `Conv1D` / `Conv3D`|Convolutional layers|
|`MaxPooling2D` / `AveragePooling2D`|Pooling|
|`LSTM` / `GRU` / `SimpleRNN`|Recurrent layers|
|`Embedding`|Maps integers to dense vectors|
|`Dropout`|Regularization via random zeroing|
|`BatchNormalization`|Normalizes activations|
|`Flatten`|Reshapes to 1D|
|`Attention` / `MultiHeadAttention`|Attention mechanisms|
|`Normalization`|Feature-wise normalization (adaptable)|

### 2.3 Models

A `Model` groups layers into an object with training/inference features (`fit`, `evaluate`, `predict`).

---

## 3. Building Models: Three APIs

Keras offers three ways to build models, each suited to different levels of flexibility.

### 3.1 Sequential API

The simplest approach — for a plain stack of layers with one input and one output.

```python
from keras import Sequential
from keras import layers

model = Sequential([
    layers.Input(shape=(784,)),
    layers.Dense(128, activation="relu"),
    layers.Dropout(0.3),
    layers.Dense(64, activation="relu"),
    layers.Dense(10, activation="softmax"),
])

model.summary()
```

**Limitations:** No support for multiple inputs/outputs, shared layers, or non-linear topology (e.g., residual connections).

### 3.2 Functional API

Treats layers as functions that transform tensors, allowing arbitrary directed acyclic graphs (DAGs) of layers — supports multi-input/output, shared layers, and branching/merging.

```python
from keras import layers, Model, Input

inputs = Input(shape=(784,))
x = layers.Dense(128, activation="relu")(inputs)
x = layers.Dropout(0.3)(x)
residual = x
x = layers.Dense(64, activation="relu")(x)
x = layers.Dense(64, activation="relu")(x)
x = layers.add([x, layers.Dense(64)(residual)])  # skip connection
outputs = layers.Dense(10, activation="softmax")(x)

model = Model(inputs=inputs, outputs=outputs, name="functional_model")
model.summary()
```

Multi-input/output example:

```python
title_input = Input(shape=(None,), name="title")
body_input = Input(shape=(None,), name="body")
tags_input = Input(shape=(num_tags,), name="tags")

title_features = layers.Embedding(vocab_size, 64)(title_input)
title_features = layers.LSTM(32)(title_features)

body_features = layers.Embedding(vocab_size, 64)(body_input)
body_features = layers.LSTM(32)(body_features)

x = layers.concatenate([title_features, body_features, tags_input])

priority_pred = layers.Dense(1, name="priority")(x)
department_pred = layers.Dense(num_departments, name="department")(x)

model = Model(
    inputs=[title_input, body_input, tags_input],
    outputs=[priority_pred, department_pred],
)
```

### 3.3 Model Subclassing API

Fully imperative, object-oriented style — define layers in `__init__` and the forward pass in `call()`. Maximum flexibility, useful for custom logic (loops, conditionals, dynamic architectures) but loses some of Keras's automatic features (like plotting the model graph) unless you implement `get_config`.

```python
from keras import layers, Model

class MLP(Model):
    def __init__(self, num_classes=10, **kwargs):
        super().__init__(**kwargs)
        self.dense1 = layers.Dense(128, activation="relu")
        self.dropout = layers.Dropout(0.3)
        self.dense2 = layers.Dense(num_classes, activation="softmax")

    def call(self, inputs, training=False):
        x = self.dense1(inputs)
        x = self.dropout(x, training=training)
        return self.dense2(x)

model = MLP(num_classes=10)
model.build(input_shape=(None, 784))
model.summary()
```

---

## 4. Compiling a Model

Before training, configure the learning process with `compile()`.

```python
model.compile(
    optimizer="adam",
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"],
)
```

You can pass strings (Keras resolves them to defaults) or instantiated objects (for custom hyperparameters):

```python
from keras import optimizers, losses, metrics

model.compile(
    optimizer=optimizers.Adam(learning_rate=1e-3),
    loss=losses.SparseCategoricalCrossentropy(),
    metrics=[metrics.SparseCategoricalAccuracy(name="acc")],
)
```

### Common Optimizers

- `SGD` — with optional momentum/Nesterov
- `Adam` — adaptive moment estimation (most common default)
- `AdamW` — Adam with decoupled weight decay
- `RMSprop` — good for RNNs
- `Adagrad`, `Adadelta`, `Nadam`

### Common Losses

- `binary_crossentropy` — binary classification
- `categorical_crossentropy` — multi-class, one-hot labels
- `sparse_categorical_crossentropy` — multi-class, integer labels
- `mean_squared_error` (`mse`) — regression
- `mean_absolute_error` (`mae`) — regression, robust to outliers
- `huber` — regression, robust hybrid of MSE/MAE

### Multi-output compile (matching the functional example above)

```python
model.compile(
    optimizer="adam",
    loss={
        "priority": "mean_squared_error",
        "department": "categorical_crossentropy",
    },
    loss_weights={"priority": 1.0, "department": 0.5},
    metrics={"department": ["accuracy"]},
)
```

---

## 5. Training: `fit()`

```python
history = model.fit(
    x_train, y_train,
    batch_size=32,
    epochs=20,
    validation_data=(x_val, y_val),
    callbacks=[...],
)
```

Key arguments:

- `validation_split=0.2` — auto-carve a validation set from training data (alternative to `validation_data`)
- `shuffle=True` — shuffle training data each epoch (default)
- `class_weight={0: 1.0, 1: 2.5}` — handle class imbalance
- `sample_weight` — per-sample weighting
- `verbose=1` — progress bar (0=silent, 2=one line per epoch)

`history.history` is a dict of per-epoch metric lists, useful for plotting loss/accuracy curves.

### Working with `tf.data.Dataset` or generators

```python
train_ds = keras.utils.image_dataset_from_directory(
    "data/train",
    image_size=(180, 180),
    batch_size=32,
)
model.fit(train_ds, epochs=10)
```

### Custom training loop

When `fit()` isn't flexible enough, you can write the loop manually — this is backend-dependent but Keras 3 supports overriding `train_step()` for a middle ground:

```python
class CustomModel(keras.Model):
    def train_step(self, data):
        x, y = data
        with keras.backend.GradientTape() if keras.backend.backend() == "tensorflow" else None:
            y_pred = self(x, training=True)
            loss = self.compute_loss(y=y, y_pred=y_pred)
        # gradient computation is backend-specific; see docs for torch/jax patterns
        ...
        return {m.name: m.result() for m in self.metrics}
```

For fully manual loops (any backend), Keras 3 documentation provides backend-specific patterns for TensorFlow (`GradientTape`), PyTorch (`loss.backward()`), and JAX (`jax.grad`).

---

## 6. Evaluation and Prediction

```python
loss, accuracy = model.evaluate(x_test, y_test, batch_size=32)

predictions = model.predict(x_test)          # returns numpy arrays
pred_classes = ops.argmax(predictions, axis=1)
```

---

## 7. Callbacks

Callbacks hook into the training loop at various points (epoch start/end, batch start/end, etc.).

```python
from keras import callbacks

callback_list = [
    callbacks.EarlyStopping(
        monitor="val_loss", patience=5, restore_best_weights=True
    ),
    callbacks.ModelCheckpoint(
        filepath="best_model.keras", save_best_only=True, monitor="val_loss"
    ),
    callbacks.ReduceLROnPlateau(
        monitor="val_loss", factor=0.5, patience=3, min_lr=1e-6
    ),
    callbacks.TensorBoard(log_dir="./logs"),
    callbacks.CSVLogger("training_log.csv"),
    callbacks.LearningRateScheduler(lambda epoch, lr: lr * 0.95 if epoch > 10 else lr),
]

model.fit(x_train, y_train, epochs=50, callbacks=callback_list, validation_split=0.2)
```

**Most commonly used:**

- `EarlyStopping` — stop training when a monitored metric stops improving
- `ModelCheckpoint` — save the model periodically or on best performance
- `ReduceLROnPlateau` — reduce learning rate when progress stalls
- `TensorBoard` — logging for visualization

### Custom callback

```python
class PrintLR(callbacks.Callback):
    def on_epoch_end(self, epoch, logs=None):
        lr = self.model.optimizer.learning_rate
        print(f"Epoch {epoch}: learning rate is {lr}")
```

---

## 8. Saving and Loading

Keras 3's native format is `.keras` (a zip archive containing architecture, weights, and optimizer state).

```python
# Save entire model
model.save("my_model.keras")

# Load it back
loaded_model = keras.models.load_model("my_model.keras")

# Save/load weights only
model.save_weights("my_weights.weights.h5")
model.load_weights("my_weights.weights.h5")
```

For custom objects (custom layers, losses, etc.), register them so loading can find them:

```python
@keras.saving.register_keras_serializable()
class MyCustomLayer(layers.Layer):
    ...

loaded_model = keras.models.load_model(
    "my_model.keras",
    custom_objects={"MyCustomLayer": MyCustomLayer},
)
```

Exporting for inference-only serving (TensorFlow SavedModel format, useful for TF Serving):

```python
model.export("saved_model_dir")
```

---

## 9. Custom Layers, Losses, and Metrics

### Custom Layer

```python
from keras import layers, ops

class MyDense(layers.Layer):
    def __init__(self, units, **kwargs):
        super().__init__(**kwargs)
        self.units = units

    def build(self, input_shape):
        self.w = self.add_weight(
            shape=(input_shape[-1], self.units),
            initializer="glorot_uniform",
            trainable=True,
            name="kernel",
        )
        self.b = self.add_weight(
            shape=(self.units,), initializer="zeros", trainable=True, name="bias"
        )

    def call(self, inputs):
        return ops.matmul(inputs, self.w) + self.b

    def get_config(self):
        config = super().get_config()
        config.update({"units": self.units})
        return config
```

### Custom Loss

```python
from keras import losses, ops

class CustomMSE(losses.Loss):
    def call(self, y_true, y_pred):
        return ops.mean(ops.square(y_true - y_pred))

# Or functional style
def custom_mse(y_true, y_pred):
    return ops.mean(ops.square(y_true - y_pred))
```

### Custom Metric

```python
from keras import metrics, ops

class F1Score(metrics.Metric):
    def __init__(self, name="f1_score", **kwargs):
        super().__init__(name=name, **kwargs)
        self.precision = metrics.Precision()
        self.recall = metrics.Recall()

    def update_state(self, y_true, y_pred, sample_weight=None):
        self.precision.update_state(y_true, y_pred, sample_weight)
        self.recall.update_state(y_true, y_pred, sample_weight)

    def result(self):
        p, r = self.precision.result(), self.recall.result()
        return 2 * (p * r) / (p + r + keras.backend.epsilon())

    def reset_state(self):
        self.precision.reset_state()
        self.recall.reset_state()
```

---

## 10. Data Preprocessing

### Preprocessing layers (composable, can live inside the model)

```python
from keras import layers

normalizer = layers.Normalization()
normalizer.adapt(x_train)  # computes mean/variance from data

text_vectorizer = layers.TextVectorization(
    max_tokens=20000, output_mode="int", output_sequence_length=200
)
text_vectorizer.adapt(text_dataset)

image_augmentation = keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.1),
    layers.RandomZoom(0.1),
])
```

Embedding preprocessing directly in the model means it's exported with the model and applied consistently at inference:

```python
inputs = Input(shape=(1,), dtype="string")
x = text_vectorizer(inputs)
x = layers.Embedding(20000, 128)(x)
...
```

### Utility loaders

```python
keras.utils.image_dataset_from_directory(...)
keras.utils.text_dataset_from_directory(...)
keras.utils.timeseries_dataset_from_array(...)
```

---

## 11. Transfer Learning and Fine-Tuning

Standard workflow: load a pretrained model without its top classification layer, freeze it, add new layers, train the new layers, then optionally unfreeze and fine-tune with a low learning rate.

```python
from keras import applications

base_model = applications.EfficientNetB0(
    weights="imagenet", include_top=False, input_shape=(224, 224, 3)
)
base_model.trainable = False  # freeze

inputs = Input(shape=(224, 224, 3))
x = applications.efficientnet.preprocess_input(inputs)
x = base_model(x, training=False)
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dropout(0.2)(x)
outputs = layers.Dense(num_classes, activation="softmax")(x)
model = Model(inputs, outputs)

model.compile(optimizer="adam", loss="categorical_crossentropy", metrics=["accuracy"])
model.fit(train_ds, epochs=10, validation_data=val_ds)

# Fine-tuning phase
base_model.trainable = True
model.compile(optimizer=keras.optimizers.Adam(1e-5), loss="categorical_crossentropy", metrics=["accuracy"])
model.fit(train_ds, epochs=5, validation_data=val_ds)
```

Available pretrained models in `keras.applications`: `ResNet50`, `VGG16/19`, `InceptionV3`, `MobileNetV2/V3`, `EfficientNetB0-B7`, `DenseNet`, `Xception`, and more. `keras_hub` (formerly `keras_nlp`/`keras_cv`) extends this to transformer-based models (BERT, GPT-2, etc.).

---

## 12. KerasTuner (Hyperparameter Tuning)

```python
import keras_tuner as kt

def build_model(hp):
    model = Sequential()
    model.add(layers.Input(shape=(784,)))
    for i in range(hp.Int("num_layers", 1, 3)):
        model.add(layers.Dense(
            units=hp.Int(f"units_{i}", min_value=32, max_value=256, step=32),
            activation="relu",
        ))
    model.add(layers.Dense(10, activation="softmax"))
    model.compile(
        optimizer=keras.optimizers.Adam(
            hp.Choice("lr", [1e-2, 1e-3, 1e-4])
        ),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    return model

tuner = kt.Hyperband(
    build_model, objective="val_accuracy", max_epochs=20, directory="tuner_dir"
)
tuner.search(x_train, y_train, validation_data=(x_val, y_val))
best_model = tuner.get_best_models(1)[0]
```

---

## 13. Multi-Backend Considerations

Since Keras 3 supports TensorFlow, PyTorch, and JAX:

- Use `keras.ops` instead of backend-specific ops (`tf.*`, `torch.*`) for portable code.
- Some features remain backend-specific: `tf.data.Dataset` pipelines work natively with TF; PyTorch `DataLoader` works with the torch backend; distribution strategies differ per backend.
- You can still import backend-specific code inside custom layers if you only intend to run on one backend — but this breaks portability.
- Mixed precision, distributed training (`keras.distribution` API), and device placement APIs are all being unified across backends but with varying maturity per backend.

---

## 14. Model Introspection Utilities

```python
model.summary()                          # architecture overview
keras.utils.plot_model(model, "model.png", show_shapes=True)  # requires pydot + graphviz
model.get_weights()                      # list of numpy arrays
model.count_params()
model.layers                             # list of Layer objects
model.get_layer("dense_1")               # retrieve by name
```

---

## 15. Practical End-to-End Example (MNIST)

```python
import keras
from keras import layers

# Load and preprocess data
(x_train, y_train), (x_test, y_test) = keras.datasets.mnist.load_data()
x_train = x_train.reshape(-1, 28, 28, 1).astype("float32") / 255.0
x_test = x_test.reshape(-1, 28, 28, 1).astype("float32") / 255.0

# Build model
model = keras.Sequential([
    layers.Input(shape=(28, 28, 1)),
    layers.Conv2D(32, 3, activation="relu"),
    layers.MaxPooling2D(2),
    layers.Conv2D(64, 3, activation="relu"),
    layers.MaxPooling2D(2),
    layers.Flatten(),
    layers.Dropout(0.5),
    layers.Dense(10, activation="softmax"),
])

model.compile(
    optimizer="adam",
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"],
)

history = model.fit(
    x_train, y_train,
    batch_size=128,
    epochs=10,
    validation_split=0.1,
    callbacks=[
        keras.callbacks.EarlyStopping(monitor="val_loss", patience=3, restore_best_weights=True)
    ],
)

test_loss, test_acc = model.evaluate(x_test, y_test)
print(f"Test accuracy: {test_acc:.4f}")

model.save("mnist_cnn.keras")
```

---

## 16. Common Pitfalls and Tips

- **`sparse_categorical_crossentropy` vs `categorical_crossentropy`**: use sparse for integer labels, non-sparse for one-hot labels.
- **Input shape mismatches**: `Input(shape=...)` excludes the batch dimension; always double-check with `model.summary()`.
- **Overfitting**: watch train vs. validation loss divergence; use `Dropout`, `EarlyStopping`, data augmentation, or `L1L2` regularization (`kernel_regularizer=keras.regularizers.l2(0.01)`).
- **Learning rate too high/low**: if loss oscillates or diverges, lower LR; if training is very slow to converge, try increasing it or use `ReduceLROnPlateau`.
- **Forgetting `training=False/True`** in custom `call()` methods — layers like `Dropout` and `BatchNormalization` behave differently in training vs. inference.
- **Data leakage**: fit preprocessing layers (like `Normalization`) only on training data, not the full dataset.
- **Mixed precision**: `keras.mixed_precision.set_global_policy("mixed_float16")` can speed up training on compatible GPUs.

---

## 17. Where to Go Next

- Official docs: [keras.io](https://keras.io)
- `keras.io/guides` — in-depth guides on each topic above
- `keras.io/examples` — full worked examples across vision, text, structured data, generative models, RL
- `keras_hub` — pretrained transformer models and NLP/CV utilities built on Keras 3

---

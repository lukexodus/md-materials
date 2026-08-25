## Functional Model Definitions


Functional model definitions describe neural network architectures as compositions of pure mathematical transformations, separating model structure from training state and enabling declarative, reusable, and inspectable architecture specifications.

**Declarative Architecture:**

Models are defined as directed acyclic graphs (DAGs) of operations where each node represents a pure transformation. The definition specifies what computations occur, not how or when they execute. This declarative approach separates architecture from implementation details like device placement, batch processing, or optimization strategies.

**Functional API Pattern:**

```python
# Functional model definition (Keras/JAX style)
def create_model(input_shape, num_classes):
    inputs = Input(shape=input_shape)
    x = Conv2D(32, (3, 3), activation='relu')(inputs)
    x = MaxPooling2D((2, 2))(x)
    x = Conv2D(64, (3, 3), activation='relu')(x)
    x = Flatten()(x)
    x = Dense(128, activation='relu')(x)
    outputs = Dense(num_classes, activation='softmax')(x)
    return Model(inputs=inputs, outputs=outputs)
```

**Layer Composition:**

Layers compose as mathematical functions. Given layers `f`, `g`, and `h`, the composition `h ∘ g ∘ f` represents sequential application. This composition is associative: `(h ∘ g) ∘ f = h ∘ (g ∘ f)`. Complex architectures emerge from composing simple transformations, with each layer maintaining purity by not mutating inputs.

**Parameterization Separation:**

Functional definitions separate architecture (the computational graph) from parameters (weights and biases). The architecture is a pure function that takes parameters and inputs to produce outputs: `output = model(params, input)`. This separation enables parameter sharing, model versioning, and independent manipulation of structure versus learned weights.

**JAX-style Pure Functions:**

```python
# Pure functional model (JAX)
def model_fn(params, x):
    # Layer 1
    x = jnp.dot(x, params['w1']) + params['b1']
    x = jax.nn.relu(x)
    # Layer 2
    x = jnp.dot(x, params['w2']) + params['b2']
    return jax.nn.softmax(x)

# Forward pass is pure function application
predictions = model_fn(params, batch_data)
```

**Higher-Order Architecture Functions:**

Model builders can be higher-order functions that return model functions based on configuration. Residual connections, attention mechanisms, and other architectural patterns become composable building blocks:

```python
def residual_block(layer_fn):
    def block(params, x):
        return x + layer_fn(params, x)
    return block

def attention_layer(dim, num_heads):
    def layer(params, x):
        q = linear(params['q'], x)
        k = linear(params['k'], x)
        v = linear(params['v'], x)
        return multi_head_attention(q, k, v, num_heads)
    return layer
```

**Graph Representation:**

Functional definitions naturally represent models as computation graphs where nodes are operations and edges are tensor flows. This representation enables graph-level optimizations (operation fusion, pruning, quantization), distributed execution planning, and hardware-specific compilation. Frameworks can analyze the pure functional definition to generate optimized execution strategies.

**Model Reusability:**

Functional definitions enable architecture reuse independent of specific parameter instances. Transfer learning becomes straightforward—the same architectural definition pairs with different parameter sets. Ensemble methods combine multiple parameter instances of the same functional definition. Architecture search explores the space of functional definitions while maintaining consistent evaluation.

**Type Safety and Validation:**

Functional definitions expose architecture structure for static analysis. Shape inference propagates tensor dimensions through the computation graph, catching dimensionality mismatches before execution. Type systems can verify that layer inputs and outputs match expected signatures, preventing runtime errors from incompatible compositions.


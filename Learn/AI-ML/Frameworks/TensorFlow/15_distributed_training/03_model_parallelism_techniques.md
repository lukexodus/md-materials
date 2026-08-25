## Model Parallelism Techniques


Model parallelism splits the model architecture across multiple devices, useful when models are too large to fit on a single device or when different model components have varying computational requirements.

**Key Points:**

- Pipeline parallelism divides model into sequential stages
- Tensor parallelism splits individual layers across devices
- Expert parallelism distributes different model components
- Communication overhead can limit scalability

### Pipeline Parallelism Implementation

```python
class PipelineParallelModel(tf.keras.Model):
    def __init__(self, num_stages=4):
        super().__init__()
        self.num_stages = num_stages
        
        # Distribute layers across devices
        with tf.device('/GPU:0'):
            self.stage_1 = tf.keras.Sequential([
                tf.keras.layers.Embedding(vocab_size, 512),
                tf.keras.layers.LSTM(512, return_sequences=True)
            ])
        
        with tf.device('/GPU:1'):
            self.stage_2 = tf.keras.Sequential([
                tf.keras.layers.LSTM(512, return_sequences=True),
                tf.keras.layers.LSTM(512, return_sequences=True)
            ])
        
        with tf.device('/GPU:2'):
            self.stage_3 = tf.keras.Sequential([
                tf.keras.layers.LSTM(512, return_sequences=True),
                tf.keras.layers.GlobalAveragePooling1D()
            ])
        
        with tf.device('/GPU:3'):
            self.stage_4 = tf.keras.Sequential([
                tf.keras.layers.Dense(256, activation='relu'),
                tf.keras.layers.Dense(num_classes, activation='softmax')
            ])
    
    def call(self, inputs, training=None):
        x = self.stage_1(inputs, training=training)
        x = self.stage_2(x, training=training)
        x = self.stage_3(x, training=training)
        x = self.stage_4(x, training=training)
        return x

# Gradient accumulation for pipeline parallelism
@tf.function
def pipeline_train_step(model, inputs, labels, optimizer, num_microbatches):
    microbatch_size = tf.shape(inputs)[0] // num_microbatches
    
    accumulated_gradients = [tf.zeros_like(var) for var in model.trainable_variables]
    
    for i in range(num_microbatches):
        start_idx = i * microbatch_size
        end_idx = (i + 1) * microbatch_size
        
        microbatch_inputs = inputs[start_idx:end_idx]
        microbatch_labels = labels[start_idx:end_idx]
        
        with tf.GradientTape() as tape:
            predictions = model(microbatch_inputs, training=True)
            loss = tf.keras.losses.sparse_categorical_crossentropy(microbatch_labels, predictions)
            loss = tf.reduce_mean(loss) / num_microbatches
        
        gradients = tape.gradient(loss, model.trainable_variables)
        accumulated_gradients = [acc_grad + grad for acc_grad, grad in zip(accumulated_gradients, gradients)]
    
    optimizer.apply_gradients(zip(accumulated_gradients, model.trainable_variables))
    return loss
```

### Tensor Parallelism for Transformers

```python
class DistributedTransformerLayer(tf.keras.layers.Layer):
    def __init__(self, d_model, num_heads, devices):
        super().__init__()
        self.devices = devices
        self.num_devices = len(devices)
        self.head_dim = d_model // num_heads
        self.heads_per_device = num_heads // self.num_devices
        
        # Distribute attention heads across devices
        self.attention_layers = []
        for i, device in enumerate(devices):
            with tf.device(device):
                self.attention_layers.append(
                    tf.keras.layers.MultiHeadAttention(
                        num_heads=self.heads_per_device,
                        key_dim=self.head_dim
                    )
                )
        
        # Distribute feed-forward network
        self.ffn_layers = []
        for device in devices:
            with tf.device(device):
                self.ffn_layers.append(
                    tf.keras.Sequential([
                        tf.keras.layers.Dense(d_model * 4, activation='relu'),
                        tf.keras.layers.Dense(d_model)
                    ])
                )
    
    def call(self, inputs, training=None):
        # Parallel attention computation
        attention_outputs = []
        for i, layer in enumerate(self.attention_layers):
            with tf.device(self.devices[i]):
                output = layer(inputs, inputs, training=training)
                attention_outputs.append(output)
        
        # Concatenate attention outputs
        attention_output = tf.concat(attention_outputs, axis=-1)
        
        # All-reduce across devices
        attention_output = tf.distribute.get_strategy().reduce(
            tf.distribute.ReduceOp.MEAN, attention_output, axis=None
        )
        
        # Parallel feed-forward computation
        ffn_outputs = []
        chunk_size = tf.shape(inputs)[0] // self.num_devices
        
        for i, layer in enumerate(self.ffn_layers):
            start_idx = i * chunk_size
            end_idx = (i + 1) * chunk_size if i < self.num_devices - 1 else tf.shape(inputs)[0]
            
            with tf.device(self.devices[i]):
                chunk = attention_output[start_idx:end_idx]
                ffn_output = layer(chunk, training=training)
                ffn_outputs.append(ffn_output)
        
        # Concatenate feed-forward outputs
        final_output = tf.concat(ffn_outputs, axis=0)
        
        return final_output
```


## Batch Inference Optimization


Batch processing significantly improves serving throughput by amortizing model execution overhead across multiple requests. TensorFlow Serving provides sophisticated batching mechanisms with configurable parameters.

**Key Points:**

- Server-side batching automatically groups individual requests
- Batch timeout prevents excessive latency for incomplete batches
- Padding strategies handle variable-length inputs within batches
- Memory management prevents out-of-memory errors with large batches

### Batching Configuration

```protobuf
# batching_config.proto
max_batch_size { value: 64 }
batch_timeout_micros { value: 10000 }  # 10ms timeout
max_enqueued_batches { value: 100 }
num_batch_threads { value: 8 }

# Advanced batching options
pad_variable_length_inputs: true
batch_padding_policy {
  pad_up: true
  pad_shape { dimension: { size: -1 } }  # Dynamic padding for first dimension
}

enable_large_batch_splitting: true
max_execution_batch_size { value: 32 }
split_input_task_func: "split_by_batch_dimension"
```

### Custom Batching Implementation

```python
# Custom batching layer for variable-length sequences
class AdaptiveBatchingLayer(tf.keras.layers.Layer):
    def __init__(self, max_batch_size=32, pad_token=0, **kwargs):
        super().__init__(**kwargs)
        self.max_batch_size = max_batch_size
        self.pad_token = pad_token
    
    def call(self, inputs, training=None):
        # Handle variable-length sequences in batch
        if isinstance(inputs, tf.RaggedTensor):
            # Convert ragged tensor to padded tensor
            padded_inputs = inputs.to_tensor(default_value=self.pad_token)
            return padded_inputs
        
        return inputs
    
    def get_config(self):
        config = super().get_config()
        config.update({
            'max_batch_size': self.max_batch_size,
            'pad_token': self.pad_token
        })
        return config

# Model with adaptive batching
def create_batch_optimized_model(vocab_size, max_length):
    inputs = tf.keras.layers.Input(shape=(None,), dtype=tf.int32, ragged=True)
    
    # Adaptive batching layer
    batched_inputs = AdaptiveBatchingLayer(max_batch_size=64)(inputs)
    
    # Model layers
    embedded = tf.keras.layers.Embedding(vocab_size, 128, mask_zero=True)(batched_inputs)
    lstm_out = tf.keras.layers.LSTM(256, return_sequences=False)(embedded)
    dropout_out = tf.keras.layers.Dropout(0.3)(lstm_out)
    outputs = tf.keras.layers.Dense(num_classes, activation='softmax')(dropout_out)
    
    model = tf.keras.Model(inputs=inputs, outputs=outputs)
    return model

# Batch processing utilities
class BatchProcessor:
    def __init__(self, model_client, max_batch_size=32, timeout_ms=10):
        self.client = model_client
        self.max_batch_size = max_batch_size
        self.timeout_ms = timeout_ms
        self.batch_queue = []
        self.batch_futures = {}
        self.batch_lock = threading.Lock()
    
    def predict(self, inputs):
        """Add request to batch queue and return future"""
        future = concurrent.futures.Future()
        
        with self.batch_lock:
            request_id = len(self.batch_futures)
            self.batch_queue.append((request_id, inputs))
            self.batch_futures[request_id] = future
            
            # Trigger batch processing if queue is full
            if len(self.batch_queue) >= self.max_batch_size:
                self._process_batch()
        
        return future
    
    def _process_batch(self):
        """Process accumulated batch requests"""
        if not self.batch_queue:
            return
        
        # Extract batch data
        request_ids = [item[0] for item in self.batch_queue]
        batch_inputs = np.array([item[1] for item in self.batch_queue])
        
        try:
            # Send batch request
            batch_results = self.client.predict(batch_inputs)
            predictions = batch_results['predictions']
            
            # Distribute results to individual futures
            for i, request_id in enumerate(request_ids):
                if request_id in self.batch_futures:
                    self.batch_futures[request_id].set_result(predictions[i])
                    del self.batch_futures[request_id]
        
        except Exception as e:
            # Handle batch failure
            for request_id in request_ids:
                if request_id in self.batch_futures:
                    self.batch_futures[request_id].set_exception(e)
                    del self.batch_futures[request_id]
        
        finally:
            self.batch_queue.clear()
    
    def start_batch_timer(self):
        """Start periodic batch processing for timeout handling"""
        def timer_worker():
            while True:
                time.sleep(self.timeout_ms / 1000.0)
                with self.batch_lock:
                    if self.batch_queue:
                        self._process_batch()
        
        timer_thread = threading.Thread(target=timer_worker, daemon=True)
        timer_thread.start()

# Memory-efficient batch processing
class MemoryEfficientBatcher:
    def __init__(self, client, memory_limit_mb=1000):
        self.client = client
        self.memory_limit_bytes = memory_limit_mb * 1024 * 1024
    
    def process_large_batch(self, inputs, estimate_memory_per_item=None):
        """Process large batches with memory constraints"""
        if estimate_memory_per_item is None:
            # [Inference] - estimate based on input size
            sample_size = np.array(inputs[0]).nbytes if inputs else 1000
            estimate_memory_per_item = sample_size * 4  # Account for intermediate computations
        
        max_items = max(1, self.memory_limit_bytes // estimate_memory_per_item)
        
        results = []
        for i in range(0, len(inputs), max_items):
            batch = inputs[i:i + max_items]
            batch_result = self.client.predict(np.array(batch))
            results.extend(batch_result['predictions'])
            
            # Force garbage collection after each chunk
            import gc
            gc.collect()
        
        return {'predictions': results}
```


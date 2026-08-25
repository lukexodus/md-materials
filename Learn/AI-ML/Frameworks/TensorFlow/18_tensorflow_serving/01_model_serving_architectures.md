## Model Serving Architectures


TensorFlow Serving supports various deployment architectures to accommodate different performance requirements, scalability needs, and infrastructure constraints. The system can operate in standalone mode, distributed configurations, or cloud-native deployments.

**Key Points:**

- Server-side batching aggregates individual requests for improved throughput
- Multi-model serving enables resource sharing across different models
- Load balancing distributes requests across multiple serving instances
- Caching mechanisms reduce latency for frequently requested predictions

### Standalone Serving Configuration

```python
# Model preparation for serving
import tensorflow as tf
import os

# Create and train a model
model = tf.keras.Sequential([
    tf.keras.layers.Dense(128, activation='relu', input_shape=(784,)),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(64, activation='relu'),
    tf.keras.layers.Dense(10, activation='softmax')
])

model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

# Export model in SavedModel format
export_path = './models/mnist_classifier/1'
tf.saved_model.save(model, export_path)

# Add serving signatures for flexible input handling
@tf.function
def serve_fn(inputs):
    # Preprocess inputs if needed
    processed_inputs = tf.cast(inputs, tf.float32) / 255.0
    predictions = model(processed_inputs)
    return {
        'predictions': predictions,
        'probabilities': tf.nn.softmax(predictions),
        'predicted_class': tf.argmax(predictions, axis=1)
    }

# Save with custom signature
signatures = {
    'serving_default': serve_fn.get_concrete_function(
        tf.TensorSpec(shape=[None, 784], dtype=tf.float32, name='inputs')
    )
}

tf.saved_model.save(model, export_path, signatures=signatures)
```

### Docker Deployment Configuration

```dockerfile
# Dockerfile for TensorFlow Serving
FROM tensorflow/serving:2.13.0

# Copy model to serving directory
COPY ./models /models

# Environment configuration
ENV MODEL_NAME=mnist_classifier
ENV MODEL_BASE_PATH=/models/mnist_classifier

# Expose serving ports
EXPOSE 8501 8500

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8501/v1/models/${MODEL_NAME} || exit 1

# Start serving with optimized configuration
CMD tensorflow_model_server \
    --rest_api_port=8501 \
    --grpc_api_port=8500 \
    --model_name=${MODEL_NAME} \
    --model_base_path=${MODEL_BASE_PATH} \
    --monitoring_config_file=/config/monitoring.config \
    --batching_parameters_file=/config/batching.config
```

### Kubernetes Deployment Architecture

```yaml
# kubernetes-serving-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tensorflow-serving
  labels:
    app: tensorflow-serving
spec:
  replicas: 3
  selector:
    matchLabels:
      app: tensorflow-serving
  template:
    metadata:
      labels:
        app: tensorflow-serving
    spec:
      containers:
      - name: tensorflow-serving
        image: tensorflow/serving:2.13.0
        ports:
        - containerPort: 8501
          name: rest-api
        - containerPort: 8500
          name: grpc-api
        env:
        - name: MODEL_NAME
          value: "mnist_classifier"
        - name: MODEL_BASE_PATH
          value: "/models/mnist_classifier"
        volumeMounts:
        - name: model-storage
          mountPath: /models
        - name: config-volume
          mountPath: /config
        resources:
          requests:
            cpu: "500m"
            memory: "1Gi"
          limits:
            cpu: "2000m"
            memory: "4Gi"
        livenessProbe:
          httpGet:
            path: /v1/models/mnist_classifier
            port: 8501
          initialDelaySeconds: 30
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /v1/models/mnist_classifier/metadata
            port: 8501
          initialDelaySeconds: 15
          periodSeconds: 10
      volumes:
      - name: model-storage
        persistentVolumeClaim:
          claimName: model-storage-pvc
      - name: config-volume
        configMap:
          name: serving-config

---
apiVersion: v1
kind: Service
metadata:
  name: tensorflow-serving-service
spec:
  selector:
    app: tensorflow-serving
  ports:
  - name: rest-api
    protocol: TCP
    port: 8501
    targetPort: 8501
  - name: grpc-api
    protocol: TCP
    port: 8500
    targetPort: 8500
  type: LoadBalancer

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: serving-config
data:
  batching.config: |
    max_batch_size { value: 32 }
    batch_timeout_micros { value: 1000 }
    max_enqueued_batches { value: 100 }
    num_batch_threads { value: 4 }
  monitoring.config: |
    prometheus_config {
      enable: true
      path: "/monitoring/prometheus/metrics"
    }
```


## REST and gRPC APIs


TensorFlow Serving provides both REST and gRPC interfaces for model inference, each optimized for different use cases and client requirements.

**Key Points:**

- REST API offers HTTP-based access with JSON payloads for web applications
- gRPC provides high-performance binary protocol for low-latency applications
- Both APIs support synchronous and asynchronous request handling
- Request batching improves throughput for both protocols

### REST API Implementation

```python
# Client implementation for REST API
import requests
import json
import numpy as np
import time

class TensorFlowServingRESTClient:
    def __init__(self, base_url, model_name, model_version=None):
        self.base_url = base_url.rstrip('/')
        self.model_name = model_name
        self.model_version = model_version or 'latest'
        self.predict_url = f"{self.base_url}/v1/models/{model_name}"
        if model_version and model_version != 'latest':
            self.predict_url += f"/versions/{model_version}"
        self.predict_url += ":predict"
    
    def predict(self, inputs, signature_name=None):
        """Send prediction request to TensorFlow Serving REST API"""
        payload = {
            "instances": inputs.tolist() if isinstance(inputs, np.ndarray) else inputs
        }
        
        if signature_name:
            payload["signature_name"] = signature_name
        
        headers = {'Content-Type': 'application/json'}
        
        try:
            response = requests.post(
                self.predict_url, 
                data=json.dumps(payload), 
                headers=headers,
                timeout=30
            )
            response.raise_for_status()
            return response.json()
        
        except requests.exceptions.RequestException as e:
            raise Exception(f"REST API request failed: {e}")
    
    def predict_batch(self, batch_inputs, batch_size=32):
        """Handle large batches with automatic chunking"""
        if len(batch_inputs) <= batch_size:
            return self.predict(batch_inputs)
        
        results = []
        for i in range(0, len(batch_inputs), batch_size):
            chunk = batch_inputs[i:i + batch_size]
            chunk_result = self.predict(chunk)
            results.extend(chunk_result['predictions'])
        
        return {'predictions': results}
    
    def get_model_status(self):
        """Check model status and metadata"""
        status_url = f"{self.base_url}/v1/models/{self.model_name}"
        response = requests.get(status_url)
        response.raise_for_status()
        return response.json()
    
    def get_model_metadata(self):
        """Retrieve model metadata including input/output specifications"""
        metadata_url = f"{self.base_url}/v1/models/{self.model_name}/metadata"
        response = requests.get(metadata_url)
        response.raise_for_status()
        return response.json()

# Usage example
client = TensorFlowServingRESTClient(
    base_url="http://localhost:8501",
    model_name="mnist_classifier",
    model_version="1"
)

# Single prediction
test_input = np.random.random((1, 784)).astype(np.float32)
result = client.predict(test_input)
print(f"Prediction: {result['predictions'][0]}")

# Batch prediction
batch_input = np.random.random((100, 784)).astype(np.float32)
batch_result = client.predict_batch(batch_input, batch_size=32)
print(f"Batch predictions shape: {len(batch_result['predictions'])}")

# Model information
status = client.get_model_status()
metadata = client.get_model_metadata()
print(f"Model status: {status}")
print(f"Input signature: {metadata['metadata']['signature_def']}")
```

### gRPC API Implementation

```python
# Client implementation for gRPC API
import grpc
import numpy as np
from tensorflow_serving.apis import predict_pb2
from tensorflow_serving.apis import prediction_service_pb2_grpc
import tensorflow as tf

class TensorFlowServingGRPCClient:
    def __init__(self, server_url, model_name, model_version=None, timeout=30):
        self.server_url = server_url
        self.model_name = model_name
        self.model_version = model_version or 1
        self.timeout = timeout
        
        # Create gRPC channel with optimization
        options = [
            ('grpc.keepalive_time_ms', 30000),
            ('grpc.keepalive_timeout_ms', 5000),
            ('grpc.keepalive_permit_without_calls', True),
            ('grpc.http2.max_pings_without_data', 0),
            ('grpc.http2.min_time_between_pings_ms', 10000),
            ('grpc.http2.min_ping_interval_without_data_ms', 300000)
        ]
        
        self.channel = grpc.insecure_channel(server_url, options=options)
        self.stub = prediction_service_pb2_grpc.PredictionServiceStub(self.channel)
    
    def predict(self, inputs, signature_name='serving_default'):
        """Send prediction request via gRPC"""
        request = predict_pb2.PredictRequest()
        request.model_spec.name = self.model_name
        request.model_spec.version.value = self.model_version
        request.model_spec.signature_name = signature_name
        
        # Convert numpy array to tensor proto
        if isinstance(inputs, np.ndarray):
            request.inputs['inputs'].CopyFrom(
                tf.make_tensor_proto(inputs, dtype=tf.float32)
            )
        else:
            # Handle dictionary inputs
            for key, value in inputs.items():
                request.inputs[key].CopyFrom(
                    tf.make_tensor_proto(value, dtype=tf.float32)
                )
        
        try:
            response = self.stub.Predict(request, timeout=self.timeout)
            return self._parse_response(response)
        
        except grpc.RpcError as e:
            raise Exception(f"gRPC request failed: {e.code()}: {e.details()}")
    
    def predict_async(self, inputs, signature_name='serving_default'):
        """Asynchronous prediction for non-blocking requests"""
        request = predict_pb2.PredictRequest()
        request.model_spec.name = self.model_name
        request.model_spec.version.value = self.model_version
        request.model_spec.signature_name = signature_name
        
        if isinstance(inputs, np.ndarray):
            request.inputs['inputs'].CopyFrom(
                tf.make_tensor_proto(inputs, dtype=tf.float32)
            )
        
        future = self.stub.Predict.future(request, timeout=self.timeout)
        return future
    
    def _parse_response(self, response):
        """Parse gRPC response to numpy arrays"""
        results = {}
        for key, tensor_proto in response.outputs.items():
            results[key] = tf.make_ndarray(tensor_proto)
        return results
    
    def predict_stream(self, input_stream, signature_name='serving_default'):
        """Handle streaming predictions for continuous inputs"""
        def request_generator():
            for inputs in input_stream:
                request = predict_pb2.PredictRequest()
                request.model_spec.name = self.model_name
                request.model_spec.version.value = self.model_version
                request.model_spec.signature_name = signature_name
                
                request.inputs['inputs'].CopyFrom(
                    tf.make_tensor_proto(inputs, dtype=tf.float32)
                )
                yield request
        
        # [Inference] - streaming capability depends on specific TF Serving configuration
        responses = self.stub.Predict(request_generator(), timeout=self.timeout)
        for response in responses:
            yield self._parse_response(response)
    
    def close(self):
        """Close gRPC channel"""
        self.channel.close()

# Performance comparison and benchmarking
class ServingBenchmark:
    def __init__(self, rest_client, grpc_client):
        self.rest_client = rest_client
        self.grpc_client = grpc_client
    
    def benchmark_latency(self, test_input, num_requests=100):
        """Compare latency between REST and gRPC"""
        import time
        
        # REST latency
        rest_times = []
        for _ in range(num_requests):
            start_time = time.time()
            self.rest_client.predict(test_input)
            rest_times.append(time.time() - start_time)
        
        # gRPC latency
        grpc_times = []
        for _ in range(num_requests):
            start_time = time.time()
            self.grpc_client.predict(test_input)
            grpc_times.append(time.time() - start_time)
        
        return {
            'rest': {
                'mean_latency': np.mean(rest_times),
                'p95_latency': np.percentile(rest_times, 95),
                'p99_latency': np.percentile(rest_times, 99)
            },
            'grpc': {
                'mean_latency': np.mean(grpc_times),
                'p95_latency': np.percentile(grpc_times, 95),
                'p99_latency': np.percentile(grpc_times, 99)
            }
        }
    
    def benchmark_throughput(self, test_inputs, duration=60):
        """Compare throughput between protocols"""
        import threading
        import time
        
        def rest_worker(results):
            start_time = time.time()
            count = 0
            while time.time() - start_time < duration:
                for batch in test_inputs:
                    self.rest_client.predict(batch)
                    count += len(batch)
                    if time.time() - start_time >= duration:
                        break
            results['rest'] = count
        
        def grpc_worker(results):
            start_time = time.time()
            count = 0
            while time.time() - start_time < duration:
                for batch in test_inputs:
                    self.grpc_client.predict(batch)
                    count += len(batch)
                    if time.time() - start_time >= duration:
                        break
            results['grpc'] = count
        
        results = {}
        rest_thread = threading.Thread(target=rest_worker, args=(results,))
        grpc_thread = threading.Thread(target=grpc_worker, args=(results,))
        
        rest_thread.start()
        grpc_thread.start()
        
        rest_thread.join()
        grpc_thread.join()
        
        return {
            'rest_throughput': results['rest'] / duration,
            'grpc_throughput': results['grpc'] / duration
        }

# Usage
grpc_client = TensorFlowServingGRPCClient(
    server_url="localhost:8500",
    model_name="mnist_classifier",
    model_version=1
)

# Single prediction
result = grpc_client.predict(test_input)
print(f"gRPC prediction: {result['predictions']}")

# Asynchronous prediction
future = grpc_client.predict_async(test_input)
result = future.result()
print(f"Async prediction: {result['predictions']}")
```


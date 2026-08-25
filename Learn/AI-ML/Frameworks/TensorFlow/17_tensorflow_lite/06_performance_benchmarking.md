## Performance Benchmarking


### Benchmarking Metrics

Performance evaluation requires comprehensive measurement of multiple metrics across different deployment scenarios and hardware configurations.

**Latency Measurement**: Measures end-to-end inference time including preprocessing, model execution, and postprocessing stages.

**Throughput Analysis**: Evaluates number of inferences per second under continuous operation conditions.

**Memory Usage**: Monitors peak memory consumption, model size, and runtime memory allocation patterns.

**Energy Consumption**: Measures battery drain and thermal characteristics during sustained inference operations.

### Benchmarking Tools

**TensorFlow Lite Benchmark Tool**: Command-line utility for systematic performance measurement across different hardware configurations.

**Model Benchmark**: Automated benchmarking framework for comparing multiple models and optimization configurations.

**Custom Profiling**: Application-specific benchmarking integrated into deployment applications for real-world performance measurement.

### Implementation and Analysis

```python
# Comprehensive benchmarking framework
import tensorflow as tf
import time
import psutil
import numpy as np
from contextlib import contextmanager

class TensorFlowLiteBenchmark:
    def __init__(self, model_path, num_threads=1):
        self.model_path = model_path
        self.interpreter = tf.lite.Interpreter(
            model_path=model_path,
            num_threads=num_threads
        )
        self.interpreter.allocate_tensors()
        
        self.input_details = self.interpreter.get_input_details()
        self.output_details = self.interpreter.get_output_details()
        
    def generate_random_input(self):
        """Generate random input matching model requirements"""
        input_shape = self.input_details[0]['shape']
        input_dtype = self.input_details[0]['dtype']
        
        if input_dtype == np.uint8:
            return np.random.randint(0, 255, input_shape, dtype=input_dtype)
        elif input_dtype == np.float32:
            return np.random.random(input_shape).astype(input_dtype)
        else:
            return np.random.random(input_shape).astype(input_dtype)
    
    def measure_latency(self, num_runs=100, warmup_runs=10):
        """Measure inference latency with statistical analysis"""
        input_data = self.generate_random_input()
        
        # Warmup runs
        for _ in range(warmup_runs):
            self.interpreter.set_tensor(self.input_details[0]['index'], input_data)
            self.interpreter.invoke()
        
        # Benchmark runs
        latencies = []
        for _ in range(num_runs):
            start_time = time.perf_counter()
            
            self.interpreter.set_tensor(self.input_details[0]['index'], input_data)
            self.interpreter.invoke()
            output_data = self.interpreter.get_tensor(self.output_details[0]['index'])
            
            end_time = time.perf_counter()
            latencies.append((end_time - start_time) * 1000)  # Convert to milliseconds
        
        return {
            'mean_latency_ms': np.mean(latencies),
            'std_latency_ms': np.std(latencies),
            'min_latency_ms': np.min(latencies),
            'max_latency_ms': np.max(latencies),
            'p95_latency_ms': np.percentile(latencies, 95),
            'p99_latency_ms': np.percentile(latencies, 99)
        }
    
    def measure_throughput(self, duration_seconds=30):
        """Measure sustained throughput"""
        input_data = self.generate_random_input()
        
        start_time = time.time()
        end_time = start_time + duration_seconds
        inference_count = 0
        
        while time.time() < end_time:
            self.interpreter.set_tensor(self.input_details[0]['index'], input_data)
            self.interpreter.invoke()
            inference_count += 1
        
        actual_duration = time.time() - start_time
        throughput = inference_count / actual_duration
        
        return {
            'throughput_fps': throughput,
            'total_inferences': inference_count,
            'actual_duration_s': actual_duration
        }
    
    @contextmanager
    def memory_monitor(self):
        """Context manager for memory usage monitoring"""
        process = psutil.Process()
        initial_memory = process.memory_info().rss / 1024 / 1024  # MB
        peak_memory = initial_memory
        
        def update_peak():
            nonlocal peak_memory
            current_memory = process.memory_info().rss / 1024 / 1024
            peak_memory = max(peak_memory, current_memory)
        
        # Start monitoring
        yield update_peak
        
        # Final measurement
        final_memory = process.memory_info().rss / 1024 / 1024
        
        return {
            'initial_memory_mb': initial_memory,
            'peak_memory_mb': peak_memory,
            'final_memory_mb': final_memory,
            'memory_increase_mb': final_memory - initial_memory
        }
    
    def comprehensive_benchmark(self):
        """Run comprehensive benchmark suite"""
        results = {}
        
        # Model information
        results['model_info'] = {
            'model_size_mb': os.path.getsize(self.model_path) / 1024 / 1024,
            'input_shape': self.input_details[0]['shape'].tolist(),
            'output_shape': self.output_details[0]['shape'].tolist(),
            'input_dtype': str(self.input_details[0]['dtype']),
            'output_dtype': str(self.output_details[0]['dtype'])
        }
        
        # Latency benchmark
        print("Running latency benchmark...")
        results['latency'] = self.measure_latency()
        
        # Throughput benchmark
        print("Running throughput benchmark...")
        results['throughput'] = self.measure_throughput()
        
        # Memory benchmark
        print("Running memory benchmark...")
        with self.memory_monitor() as monitor:
            # Run some inferences to measure memory usage
            for _ in range(50):
                input_data = self.generate_random_input()
                self.interpreter.set_tensor(self.input_details[0]['index'], input_data)
                self.interpreter.invoke()
                monitor()
        
        return results

# Comparative benchmarking
def compare_models(model_configs):
    """Compare multiple model configurations"""
    results = {}
    
    for name, config in model_configs.items():
        print(f"Benchmarking {name}...")
        
        benchmark = TensorFlowLiteBenchmark(
            config['model_path'],
            config.get('num_threads', 1)
        )
        
        results[name] = benchmark.comprehensive_benchmark()
        results[name]['config'] = config
    
    return results

# Hardware-specific benchmarking
def benchmark_with_delegates(model_path, delegates=['cpu', 'gpu', 'nnapi']):
    """Benchmark model with different hardware delegates"""
    results = {}
    
    for delegate in delegates:
        try:
            print(f"Benchmarking with {delegate} delegate...")
            
            if delegate == 'gpu':
                gpu_delegate = tf.lite.experimental.load_delegate('libGpuDelegate.so')
                interpreter = tf.lite.Interpreter(
                    model_path=model_path,
                    experimental_delegates=[gpu_delegate]
                )
            elif delegate == 'nnapi':
                nnapi_delegate = tf.lite.experimental.load_delegate('libnnapi_delegate.so')
                interpreter = tf.lite.Interpreter(
                    model_path=model_path,
                    experimental_delegates=[nnapi_delegate]
                )
            else:  # CPU
                interpreter = tf.lite.Interpreter(model_path=model_path)
            
            interpreter.allocate_tensors()
            
            # Create benchmark instance with configured interpreter
            benchmark = TensorFlowLiteBenchmark.__new__(TensorFlowLiteBenchmark)
            benchmark.model_path = model_path
            benchmark.interpreter = interpreter
            benchmark.input_details = interpreter.get_input_details()
            benchmark.output_details = interpreter.get_output_details()
            
            results[delegate] = benchmark.comprehensive_benchmark()
            results[delegate]['delegate'] = delegate
            
        except Exception as e:
            print(f"Failed to benchmark with {delegate} delegate: {e}")
            results[delegate] = {'error': str(e)}
    
    return results

# Energy consumption measurement (Android-specific)
def measure_energy_consumption(model_path, duration_minutes=5):
    """
    [Unverified] Energy measurement requires platform-specific APIs
    This is a conceptual framework - actual implementation depends on device capabilities
    """
    try:
        # [Inference] This would require Android Battery Historian or similar tools
        import subprocess
        
        # Start battery monitoring
        subprocess.run(['adb', 'shell', 'dumpsys', 'batterystats', '--reset'])
        
        # Run inference workload
        benchmark = TensorFlowLiteBenchmark(model_path)
        start_time = time.time()
        inference_count = 0
        
        while time.time() - start_time < duration_minutes * 60:
            input_data = benchmark.generate_random_input()
            benchmark.interpreter.set_tensor(benchmark.input_details[0]['index'], input_data)
            benchmark.interpreter.invoke()
            inference_count += 1
        
        # Collect battery statistics
        result = subprocess.run(
            ['adb', 'shell', 'dumpsys', 'batterystats'],
            capture_output=True,
            text=True
        )
        
        # [Inference] Parse battery statistics - implementation would depend on output format
        battery_stats = result.stdout
        
        return {
            'inference_count': inference_count,
            'duration_minutes': duration_minutes,
            'battery_stats': battery_stats,
            'inferences_per_minute': inference_count / duration_minutes
        }
        
    except Exception as e:
        return {'error': f'Energy measurement failed: {e}'}

# Automated benchmark reporting
def generate_benchmark_report(benchmark_results, output_path='benchmark_report.html'):
    """Generate comprehensive HTML benchmark report"""
    html_template = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>TensorFlow Lite Benchmark Report</title>
        <style>
            body {{ font-family: Arial, sans-serif; margin: 40px; }}
            table {{ border-collapse: collapse; width: 100%; margin: 20px 0; }}
            th, td {{ border: 1px solid #ddd; padding: 12px; text-align: left; }}
            th {{ background-color: #f2f2f2; }}
            .metric {{ font-weight: bold; color: #333; }}
            .value {{ color: #666; }}
            .section {{ margin: 30px 0; }}
            .chart {{ width: 100%; height: 300px; margin: 20px 0; }}
        </style>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    </head>
    <body>
        <h1>TensorFlow Lite Performance Benchmark Report</h1>
        <div class="section">
            <h2>Model Information</h2>
            <table>
                <tr><th>Metric</th><th>Value</th></tr>
                {model_info_rows}
            </table>
        </div>
        
        <div class="section">
            <h2>Performance Metrics</h2>
            <table>
                <tr><th>Metric</th><th>Value</th><th>Unit</th></tr>
                {performance_rows}
            </table>
        </div>
        
        <div class="section">
            <h2>Latency Distribution</h2>
            <canvas id="latencyChart" class="chart"></canvas>
        </div>
        
        <div class="section">
            <h2>Delegate Comparison</h2>
            <canvas id="delegateChart" class="chart"></canvas>
        </div>
        
        <script>
            // Latency distribution chart
            const latencyCtx = document.getElementById('latencyChart').getContext('2d');
            new Chart(latencyCtx, {{
                type: 'bar',
                data: {{
                    labels: ['Mean', 'Min', 'Max', 'P95', 'P99'],
                    datasets: [{{
                        label: 'Latency (ms)',
                        data: {latency_data},
                        backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF']
                    }}]
                }},
                options: {{
                    responsive: true,
                    scales: {{
                        y: {{ beginAtZero: true }}
                    }}
                }}
            }});
            
            // Delegate comparison chart
            const delegateCtx = document.getElementById('delegateChart').getContext('2d');
            new Chart(delegateCtx, {{
                type: 'bar',
                data: {{
                    labels: {delegate_labels},
                    datasets: [{{
                        label: 'Mean Latency (ms)',
                        data: {delegate_data},
                        backgroundColor: '#36A2EB'
                    }}]
                }},
                options: {{
                    responsive: true,
                    scales: {{
                        y: {{ beginAtZero: true }}
                    }}
                }}
            }});
        </script>
    </body>
    </html>
    """
    
    # Extract data for report generation
    if isinstance(benchmark_results, dict) and 'model_info' in benchmark_results:
        # Single model benchmark
        model_info = benchmark_results['model_info']
        latency = benchmark_results['latency']
        throughput = benchmark_results['throughput']
        
        model_info_rows = ''.join([
            f"<tr><td class='metric'>{k}</td><td class='value'>{v}</td></tr>"
            for k, v in model_info.items()
        ])
        
        performance_rows = f"""
            <tr><td class='metric'>Mean Latency</td><td class='value'>{latency['mean_latency_ms']:.2f}</td><td>ms</td></tr>
            <tr><td class='metric'>Std Latency</td><td class='value'>{latency['std_latency_ms']:.2f}</td><td>ms</td></tr>
            <tr><td class='metric'>P95 Latency</td><td class='value'>{latency['p95_latency_ms']:.2f}</td><td>ms</td></tr>
            <tr><td class='metric'>P99 Latency</td><td class='value'>{latency['p99_latency_ms']:.2f}</td><td>ms</td></tr>
            <tr><td class='metric'>Throughput</td><td class='value'>{throughput['throughput_fps']:.2f}</td><td>FPS</td></tr>
        """
        
        latency_data = [
            latency['mean_latency_ms'],
            latency['min_latency_ms'],
            latency['max_latency_ms'],
            latency['p95_latency_ms'],
            latency['p99_latency_ms']
        ]
        
        delegate_labels = "['Single Model']"
        delegate_data = f"[{latency['mean_latency_ms']}]"
        
    else:
        # Multiple model or delegate comparison
        model_info_rows = "<tr><td colspan='2'>Multiple Models Compared</td></tr>"
        performance_rows = ""
        
        delegate_labels = []
        delegate_data = []
        
        for name, result in benchmark_results.items():
            if 'error' not in result:
                delegate_labels.append(name)
                delegate_data.append(result['latency']['mean_latency_ms'])
                
                performance_rows += f"""
                    <tr><td class='metric'>{name} - Mean Latency</td><td class='value'>{result['latency']['mean_latency_ms']:.2f}</td><td>ms</td></tr>
                    <tr><td class='metric'>{name} - Throughput</td><td class='value'>{result['throughput']['throughput_fps']:.2f}</td><td>FPS</td></tr>
                """
        
        delegate_labels = str(delegate_labels)
        delegate_data = str(delegate_data)
        latency_data = "[0]"  # Placeholder for multi-model case
    
    # Generate HTML report
    html_content = html_template.format(
        model_info_rows=model_info_rows,
        performance_rows=performance_rows,
        latency_data=latency_data,
        delegate_labels=delegate_labels,
        delegate_data=delegate_data
    )
    
    with open(output_path, 'w') as f:
        f.write(html_content)
    
    return output_path

# Real-world performance testing
def production_benchmark(model_path, test_data_path, batch_sizes=[1, 8, 16, 32]):
    """Benchmark model with real production data and various batch sizes"""
    results = {}
    
    # Load real test data
    test_data = np.load(test_data_path) if test_data_path.endswith('.npy') else None
    
    for batch_size in batch_sizes:
        print(f"Testing batch size: {batch_size}")
        
        benchmark = TensorFlowLiteBenchmark(model_path)
        
        if test_data is not None:
            # Use real data
            num_samples = min(len(test_data), 100)
            total_time = 0
            
            for i in range(0, num_samples, batch_size):
                batch_end = min(i + batch_size, num_samples)
                batch_data = test_data[i:batch_end]
                
                start_time = time.perf_counter()
                
                for sample in batch_data:
                    benchmark.interpreter.set_tensor(
                        benchmark.input_details[0]['index'], 
                        np.expand_dims(sample, axis=0)
                    )
                    benchmark.interpreter.invoke()
                
                total_time += time.perf_counter() - start_time
            
            avg_latency = (total_time / num_samples) * 1000  # Convert to ms
            
        else:
            # Use synthetic data
            latency_results = benchmark.measure_latency(num_runs=50)
            avg_latency = latency_results['mean_latency_ms']
        
        results[f'batch_{batch_size}'] = {
            'avg_latency_ms': avg_latency,
            'throughput_fps': 1000 / avg_latency if avg_latency > 0 else 0
        }
    
    return results

# Memory profiling utilities
def profile_memory_usage(model_path, duration_seconds=60):
    """Profile memory usage over time during continuous inference"""
    import matplotlib.pyplot as plt
    
    benchmark = TensorFlowLiteBenchmark(model_path)
    process = psutil.Process()
    
    timestamps = []
    memory_usage = []
    inference_counts = []
    
    start_time = time.time()
    inference_count = 0
    
    while time.time() - start_time < duration_seconds:
        # Record memory usage
        current_time = time.time() - start_time
        current_memory = process.memory_info().rss / 1024 / 1024  # MB
        
        timestamps.append(current_time)
        memory_usage.append(current_memory)
        inference_counts.append(inference_count)
        
        # Run inference
        input_data = benchmark.generate_random_input()
        benchmark.interpreter.set_tensor(benchmark.input_details[0]['index'], input_data)
        benchmark.interpreter.invoke()
        inference_count += 1
        
        time.sleep(0.1)  # Small delay for measurement
    
    # Create memory usage plot
    plt.figure(figsize=(12, 8))
    
    plt.subplot(2, 1, 1)
    plt.plot(timestamps, memory_usage, 'b-', linewidth=2)
    plt.title('Memory Usage Over Time')
    plt.xlabel('Time (seconds)')
    plt.ylabel('Memory Usage (MB)')
    plt.grid(True, alpha=0.3)
    
    plt.subplot(2, 1, 2)
    plt.plot(timestamps, inference_counts, 'g-', linewidth=2)
    plt.title('Cumulative Inference Count')
    plt.xlabel('Time (seconds)')
    plt.ylabel('Number of Inferences')
    plt.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('memory_profile.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    return {
        'max_memory_mb': max(memory_usage),
        'min_memory_mb': min(memory_usage),
        'avg_memory_mb': np.mean(memory_usage),
        'memory_std_mb': np.std(memory_usage),
        'total_inferences': inference_count,
        'avg_inference_rate': inference_count / duration_seconds
    }
```

### Advanced Benchmarking Analysis

**Statistical Significance Testing**: Implements statistical tests to determine if performance differences between configurations are statistically significant, avoiding conclusions based on measurement noise.

**Performance Regression Detection**: Monitors performance metrics over time to detect performance regressions in model updates or deployment changes.

**Hardware Variability Analysis**: Accounts for performance variations across different device models, operating system versions, and hardware configurations.

### Deployment Optimization Recommendations

**Model Selection Criteria**: Based on benchmark results, provides automated recommendations for optimal model configurations considering accuracy-performance trade-offs.

**Hardware Utilization Analysis**: Identifies bottlenecks and underutilized hardware resources to guide optimization strategies.

**Power Efficiency Scoring**: Combines performance metrics with energy consumption to provide holistic efficiency ratings for different deployment scenarios.

**Key points:**

- TensorFlow Lite enables efficient deployment of ML models on mobile and edge devices
- Quantization techniques significantly reduce model size with minimal accuracy loss
- Hardware acceleration through delegates improves inference performance substantially
- Comprehensive benchmarking ensures optimal performance across diverse deployment scenarios
- [Inference] Deployment success depends on careful optimization for specific hardware constraints and use case requirements

**Related topics:** TensorFlow Lite Micro for microcontrollers, federated learning on mobile devices, on-device training techniques, model compression beyond quantization, privacy-preserving inference, and cross-platform deployment strategies.

---


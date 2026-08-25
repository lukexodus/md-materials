## Production Monitoring


Production monitoring provides comprehensive visibility into serving performance, model behavior, and system health. TensorFlow Serving integrates with various monitoring systems for real-time alerting and analysis.

**Key Points:**

- Metrics collection tracks latency, throughput, error rates, and resource utilization
- Request/response logging enables debugging and model performance analysis
- Alerting systems notify operators of performance degradations or failures
- Distributed tracing helps diagnose issues across microservice architectures

### Comprehensive Monitoring System

```python
# Production monitoring and alerting system
import prometheus_client
from prometheus_client import Counter, Histogram, Gauge, start_http_server
import logging
import json
from datetime import datetime
import threading
import queue

class TensorFlowServingMonitor:
    def __init__(self, metrics_port=8080, log_level=logging.INFO):
        self.metrics_port = metrics_port
        self.setup_logging(log_level)
        self.setup_metrics()
        self.alert_rules = []
        self.request_log_queue = queue.Queue(maxsize=10000)
        
        # Start metrics server
        start_http_server(self.metrics_port)
        
        # Start request logging worker
        self.start_logging_worker()
    
    def setup_logging(self, log_level):
        """Configure structured logging"""
        logging.basicConfig(
            level=log_level,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('/var/log/tensorflow_serving/serving.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def setup_metrics(self):
        """Initialize Prometheus metrics"""
        # Request metrics
        self.request_count = Counter(
            'serving_request_total',
            'Total number of serving requests',
            ['model_name', 'model_version', 'method', 'status']
        )
        
        self.request_duration = Histogram(
            'serving_request_duration_seconds',
            'Request duration in seconds',
            ['model_name', 'model_version', 'method'],
            buckets=[0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0]
        )
        
        self.request_size = Histogram(
            'serving_request_size_bytes',
            'Request payload size in bytes',
            ['model_name', 'model_version'],
            buckets=[100, 1000, 10000, 100000, 1000000, 10000000]
        )
        
        self.response_size = Histogram(
            'serving_response_size_bytes',
            'Response payload size in bytes',
            ['model_name', 'model_version'],
            buckets=[100, 1000, 10000, 100000, 1000000]
        )
        
        # System metrics
        self.active_requests = Gauge(
            'serving_active_requests',
            'Number of currently active requests',
            ['model_name', 'model_version']
        )
        
        self.model_load_time = Histogram(
            'serving_model_load_duration_seconds',
            'Time taken to load model',
            ['model_name', 'model_version']
        )
        
        self.memory_usage = Gauge(
            'serving_memory_usage_bytes',
            'Memory usage in bytes',
            ['model_name', 'model_version', 'type']  # type: model, cache, etc.
        )
        
        # Error metrics
        self.error_count = Counter(
            'serving_error_total',
            'Total number of serving errors',
            ['model_name', 'model_version', 'error_type']
        )
    
    def record_request(self, model_name, model_version, method, start_time, 
                      end_time, status, request_size=None, response_size=None,
                      error_type=None, additional_metrics=None):
        """Record request metrics and logs"""
        duration = end_time - start_time
        
        # Update Prometheus metrics
        self.request_count.labels(
            model_name=model_name,
            model_version=str(model_version),
            method=method,
            status=status
        ).inc()
        
        self.request_duration.labels(
            model_name=model_name,
            model_version=str(model_version),
            method=method
        ).observe(duration)
        
        if request_size:
            self.request_size.labels(
                model_name=model_name,
                model_version=str(model_version)
            ).observe(request_size)
        
        if response_size:
            self.response_size.labels(
                model_name=model_name,
                model_version=str(model_version)
            ).observe(response_size)
        
        if error_type:
            self.error_count.labels(
                model_name=model_name,
                model_version=str(model_version),
                error_type=error_type
            ).inc()
        
        # Queue for detailed logging
        log_entry = {
            'timestamp': datetime.fromtimestamp(start_time).isoformat(),
            'model_name': model_name,
            'model_version': str(model_version),
            'method': method,
            'duration': duration,
            'status': status,
            'request_size': request_size,
            'response_size': response_size,
            'error_type': error_type,
            **additional_metrics or {}
        }
        
        try:
            self.request_log_queue.put_nowait(log_entry)
        except queue.Full:
            self.logger.warning("Request log queue full, dropping log entry")
    
    def start_logging_worker(self):
        """Start background worker for request logging"""
        def logging_worker():
            batch = []
            batch_size = 100
            
            while True:
                try:
                    # Collect batch of log entries
                    while len(batch) < batch_size:
                        try:
                            entry = self.request_log_queue.get(timeout=1.0)
                            batch.append(entry)
                        except queue.Empty:
                            break
                    
                    if batch:
                        # Write batch to log
                        for entry in batch:
                            self.logger.info(f"REQUEST_LOG: {json.dumps(entry)}")
                        batch.clear()
                
                except Exception as e:
                    self.logger.error(f"Logging worker error: {e}")
        
        worker_thread = threading.Thread(target=logging_worker, daemon=True)
        worker_thread.start()
    
    def update_system_metrics(self, model_name, model_version, memory_stats):
        """Update system-level metrics"""
        for memory_type, usage in memory_stats.items():
            self.memory_usage.labels(
                model_name=model_name,
                model_version=str(model_version),
                type=memory_type
            ).set(usage)
    
    def add_alert_rule(self, rule_name, condition_func, alert_func, check_interval=60):
        """Add custom alerting rule"""
        rule = {
            'name': rule_name,
            'condition': condition_func,
            'alert': alert_func,
            'interval': check_interval,
            'last_check': 0
        }
        self.alert_rules.append(rule)
    
    def check_alerts(self):
        """Check all alert rules and trigger notifications"""
        current_time = time.time()
        
        for rule in self.alert_rules:
            if current_time - rule['last_check'] >= rule['interval']:
                try:
                    if rule['condition']():
                        rule['alert'](rule['name'])
                    rule['last_check'] = current_time
                except Exception as e:
                    self.logger.error(f"Alert rule {rule['name']} failed: {e}")

# Model performance analyzer
class ModelPerformanceAnalyzer:
    def __init__(self, monitor):
        self.monitor = monitor
        self.performance_history = {}
        self.drift_detectors = {}
    
    def analyze_prediction_distribution(self, model_name, model_version, predictions, 
                                      reference_distribution=None):
        """Analyze prediction distribution for drift detection"""
        predictions_array = np.array(predictions)
        
        # Calculate distribution statistics
        current_stats = {
            'mean': np.mean(predictions_array),
            'std': np.std(predictions_array),
            'percentiles': np.percentile(predictions_array, [25, 50, 75, 95, 99]),
            'entropy': self._calculate_entropy(predictions_array)
        }
        
        model_key = f"{model_name}_{model_version}"
        if model_key not in self.performance_history:
            self.performance_history[model_key] = []
        
        self.performance_history[model_key].append({
            'timestamp': time.time(),
            'stats': current_stats,
            'sample_size': len(predictions)
        })
        
        # Drift detection
        if reference_distribution:
            drift_score = self._detect_distribution_drift(
                current_stats, reference_distribution
            )
            
            if drift_score > 0.1:  # Configurable threshold
                self.monitor.logger.warning(
                    f"Distribution drift detected for {model_key}: score={drift_score:.3f}"
                )
                
                # Record drift metric
                self.monitor.error_count.labels(
                    model_name=model_name,
                    model_version=str(model_version),
                    error_type='distribution_drift'
                ).inc()
        
        return current_stats
    
    def _calculate_entropy(self, predictions):
        """Calculate entropy of prediction distribution"""
        # Bin predictions into histogram
        hist, _ = np.histogram(predictions, bins=50, density=True)
        hist = hist[hist > 0]  # Remove zero bins
        
        # Calculate entropy
        entropy = -np.sum(hist * np.log2(hist + 1e-10))
        return entropy
    
    def _detect_distribution_drift(self, current_stats, reference_stats):
        """Detect drift between current and reference distributions"""
        # Simple drift score based on statistical differences
        mean_drift = abs(current_stats['mean'] - reference_stats['mean'])
        std_drift = abs(current_stats['std'] - reference_stats['std'])
        
        # Normalize by reference values
        mean_drift_norm = mean_drift / (abs(reference_stats['mean']) + 1e-10)
        std_drift_norm = std_drift / (reference_stats['std'] + 1e-10)
        
        # Combined drift score
        drift_score = (mean_drift_norm + std_drift_norm) / 2
        return drift_score
    
    def generate_performance_report(self, model_name, model_version, time_window_hours=24):
        """Generate comprehensive performance report"""
        model_key = f"{model_name}_{model_version}"
        
        if model_key not in self.performance_history:
            return None
        
        # Filter data within time window
        cutoff_time = time.time() - (time_window_hours * 3600)
        recent_data = [
            entry for entry in self.performance_history[model_key]
            if entry['timestamp'] >= cutoff_time
        ]
        
        if not recent_data:
            return None
        
        # Aggregate statistics
        total_predictions = sum(entry['sample_size'] for entry in recent_data)
        mean_values = [entry['stats']['mean'] for entry in recent_data]
        std_values = [entry['stats']['std'] for entry in recent_data]
        
        report = {
            'model_name': model_name,
            'model_version': model_version,
            'time_window_hours': time_window_hours,
            'total_predictions': total_predictions,
            'mean_prediction': {
                'avg': np.mean(mean_values),
                'min': np.min(mean_values),
                'max': np.max(mean_values),
                'std': np.std(mean_values)
            },
            'prediction_variability': {
                'avg_std': np.mean(std_values),
                'stability': np.std(std_values)  # Lower is more stable
            },
            'data_points': len(recent_data)
        }
        
        return report

# Monitoring instrumentation decorator
class MonitoringInstrumentation:
    def __init__(self, monitor, performance_analyzer):
        self.monitor = monitor
        self.performance_analyzer = performance_analyzer
    
    def instrument_serving_client(self, client_class):
        """Decorator to add monitoring to serving client methods"""
        original_predict = client_class.predict
        
        def monitored_predict(self, inputs, **kwargs):
            start_time = time.time()
            request_size = len(json.dumps(inputs.tolist() if isinstance(inputs, np.ndarray) else inputs).encode())
            
            # Update active requests gauge
            monitor.active_requests.labels(
                model_name=self.model_name,
                model_version=str(self.model_version or 'latest')
            ).inc()
            
            try:
                result = original_predict(self, inputs, **kwargs)
                end_time = time.time()
                
                response_size = len(json.dumps(result).encode()) if result else 0
                
                # Record successful request
                monitor.record_request(
                    model_name=self.model_name,
                    model_version=self.model_version or 'latest',
                    method='predict',
                    start_time=start_time,
                    end_time=end_time,
                    status='success',
                    request_size=request_size,
                    response_size=response_size
                )
                
                # Analyze predictions for drift
                if 'predictions' in result:
                    performance_analyzer.analyze_prediction_distribution(
                        model_name=self.model_name,
                        model_version=self.model_version or 'latest',
                        predictions=result['predictions']
                    )
                
                return result
            
            except Exception as e:
                end_time = time.time()
                
                # Determine error type
                error_type = 'timeout' if 'timeout' in str(e).lower() else 'server_error'
                
                # Record failed request
                monitor.record_request(
                    model_name=self.model_name,
                    model_version=self.model_version or 'latest',
                    method='predict',
                    start_time=start_time,
                    end_time=end_time,
                    status='error',
                    request_size=request_size,
                    error_type=error_type
                )
                
                raise
            
            finally:
                # Decrement active requests
                monitor.active_requests.labels(
                    model_name=self.model_name,
                    model_version=str(self.model_version or 'latest')
                ).dec()
        
        client_class.predict = monitored_predict
        return client_class

# Alert configuration and notification system
class AlertManager:
    def __init__(self, monitor, notification_channels):
        self.monitor = monitor
        self.notification_channels = notification_channels  # email, slack, etc.
        self.alert_history = {}
        self.setup_default_alerts()
    
    def setup_default_alerts(self):
        """Configure standard production alerts"""
        
        # High error rate alert
        def check_error_rate():
            # [Inference] - would need to query metrics backend for actual implementation
            error_rate = 0.05  # Placeholder
            return error_rate > 0.02  # 2% threshold
        
        def error_rate_alert(rule_name):
            message = f"High error rate detected: {rule_name}"
            self.send_alert('high_error_rate', message, severity='critical')
        
        self.monitor.add_alert_rule(
            'high_error_rate',
            check_error_rate,
            error_rate_alert,
            check_interval=30
        )
        
        # High latency alert
        def check_latency():
            # [Inference] - would query actual P95 latency metrics
            p95_latency = 0.8  # Placeholder
            return p95_latency > 0.5  # 500ms threshold
        
        def latency_alert(rule_name):
            message = f"High latency detected: {rule_name}"
            self.send_alert('high_latency', message, severity='warning')
        
        self.monitor.add_alert_rule(
            'high_latency',
            check_latency,
            latency_alert,
            check_interval=60
        )
    
    def send_alert(self, alert_type, message, severity='info', cooldown_minutes=15):
        """Send alert with cooldown to prevent spam"""
        current_time = time.time()
        
        # Check cooldown
        if alert_type in self.alert_history:
            last_sent = self.alert_history[alert_type]
            if current_time - last_sent < cooldown_minutes * 60:
                return  # Skip due to cooldown
        
        # Send to all configured channels
        for channel in self.notification_channels:
            try:
                channel.send_notification(alert_type, message, severity)
            except Exception as e:
                self.monitor.logger.error(f"Failed to send alert via {channel}: {e}")
        
        # Update history
        self.alert_history[alert_type] = current_time

# Usage example
monitor = TensorFlowServingMonitor(metrics_port=8080)
performance_analyzer = ModelPerformanceAnalyzer(monitor)

# Instrument serving clients with monitoring
@MonitoringInstrumentation(monitor, performance_analyzer).instrument_serving_client
class MonitoredServingClient(TensorFlowServingRESTClient):
    pass

# Create monitored client
client = MonitoredServingClient("http://localhost:8501", "mnist_classifier", "1")

# Set up alerting
alert_manager = AlertManager(monitor, notification_channels=[])

# Start monitoring
monitor_thread = threading.Thread(target=lambda: monitor.check_alerts(), daemon=True)
monitor_thread.start()
```

**Output:** TensorFlow Serving provides a comprehensive production-ready serving platform with support for multiple architectures, protocols, and operational requirements. The system integrates REST and gRPC APIs for flexible client access, implements sophisticated batching for optimal throughput, provides robust version management for safe deployments, and includes comprehensive monitoring capabilities for production visibility.

---


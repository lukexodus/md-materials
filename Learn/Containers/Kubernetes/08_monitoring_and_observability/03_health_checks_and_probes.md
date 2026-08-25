## Health Checks and Probes


Kubernetes health checks provide essential mechanisms for ensuring application reliability and availability through automated monitoring and remediation. The probe system enables Kubernetes to make informed decisions about pod lifecycle management, traffic routing, and service availability, creating self-healing distributed systems that can automatically recover from failures.

### Liveness, Readiness, and Startup Probes

Liveness probes determine whether a running container is healthy and should continue executing. These probes detect scenarios where applications become unresponsive, deadlocked, or otherwise corrupted while still consuming resources. When liveness probes fail, Kubernetes restarts the container, providing automatic recovery from application-level failures.

Liveness probe configuration requires careful consideration of application characteristics and failure modes. The probe must reliably distinguish between temporary slowdowns and genuine application failures. False positives can cause unnecessary restarts that disrupt service, while false negatives allow failed containers to continue consuming resources without providing functionality.

Readiness probes indicate whether a container is ready to accept incoming traffic. Unlike liveness probes that focus on application health, readiness probes evaluate whether an application can successfully handle requests. Containers that fail readiness checks are removed from service endpoints, preventing traffic from reaching instances that cannot properly respond.

The distinction between liveness and readiness becomes crucial during application startup, dependency initialization, and resource loading phases. Applications may be alive but not ready to serve traffic due to ongoing initialization processes, external dependency checks, or resource preloading requirements.

Startup probes provide specialized handling for containers with long initialization times. These probes disable liveness and readiness checks during the startup phase, preventing premature container termination while applications perform extended initialization processes. Once startup probes succeed, normal liveness and readiness probe scheduling begins.

Probe types include HTTP requests, TCP socket checks, and command execution. HTTP probes send GET requests to specified endpoints and evaluate response codes, making them suitable for web applications and REST APIs. TCP probes attempt socket connections to verify port availability, appropriate for database connections and non-HTTP services. Command probes execute custom scripts or binaries within containers, providing maximum flexibility for complex health determination logic.

**Example:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: health-check-pod
spec:
  containers:
  - name: app
    image: myapp:latest
    ports:
    - containerPort: 8080
    startupProbe:
      httpGet:
        path: /health/startup
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 5
      failureThreshold: 30
    livenessProbe:
      httpGet:
        path: /health/live
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
      failureThreshold: 3
    readinessProbe:
      httpGet:
        path: /health/ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
      failureThreshold: 3
```

### Health Check Best Practices

Health check endpoint design should focus on lightweight operations that accurately reflect application health without consuming excessive resources. Health checks run frequently throughout the application lifecycle, making performance optimization crucial for overall system efficiency. Endpoints should avoid expensive operations like database queries, external API calls, or complex computations unless these operations are essential for determining application health.

Dependency checking in health endpoints requires careful balance between accuracy and reliability. Deep dependency checks that verify external service connectivity provide comprehensive health assessment but can create cascading failures when upstream services become unavailable. Shallow checks that focus on local application state provide more stable health reporting but may miss critical dependency failures.

Timeout and retry configuration must account for normal application response time variability while quickly detecting genuine failures. Conservative timeout values prevent false positives during temporary performance degradation, while aggressive timeouts enable faster failure detection and recovery. Retry policies should balance quick failure detection with system stability.

Health check differentiation enables more sophisticated availability management. Liveness checks should focus on detecting irrecoverable failures that require container restart, such as deadlocks, memory corruption, or critical resource exhaustion. Readiness checks should evaluate whether applications can successfully handle new requests, considering factors like dependency availability, resource capacity, and initialization state.

Monitoring and alerting for health check failures provides operational visibility into application behavior and failure patterns. Health check metrics reveal application stability trends, failure frequencies, and recovery patterns that inform capacity planning and architecture decisions. Alert thresholds should account for expected failure rates while promptly notifying operators of concerning patterns.

**Key points:**

- Health endpoints should be lightweight and focused on essential health indicators
- Dependency checking requires balance between accuracy and cascade failure prevention
- Timeout configuration must account for normal response variability
- Different probe types serve distinct purposes in availability management
- Health check metrics provide valuable operational insights

### Graceful Shutdown Handling

Graceful shutdown ensures that applications complete in-flight requests and properly clean up resources before termination. Kubernetes sends SIGTERM signals to container processes when pods are deleted, providing applications an opportunity to perform cleanup operations before forced termination occurs.

Signal handling in applications requires implementing proper signal handlers that respond to SIGTERM by initiating shutdown procedures. Applications should stop accepting new connections, complete existing request processing, close database connections, and release other resources during the shutdown sequence. The shutdown process should be idempotent to handle multiple signal deliveries.

Termination grace periods control how long Kubernetes waits for graceful shutdown completion before sending SIGKILL signals. The default 30-second grace period suits most applications, but longer periods may be necessary for applications with extended cleanup requirements. Grace periods should be configured based on typical request processing times and resource cleanup complexity.

PreStop hooks provide additional shutdown control by executing commands or HTTP requests before sending SIGTERM signals. These hooks can perform application-specific cleanup tasks, notify external systems about shutdown, or coordinate with other containers in multi-container pods. PreStop hooks extend the total shutdown time beyond the termination grace period.

Load balancer integration ensures that traffic stops flowing to terminating pods before shutdown begins. Readiness probe failures immediately remove pods from service endpoints, preventing new requests from reaching containers that are shutting down. This coordination prevents request failures during the shutdown process.

Connection draining allows existing connections to complete naturally while preventing new connection establishment. Applications should implement connection draining by closing listening sockets, completing in-flight requests, and waiting for existing connections to close before terminating processes.

**Example:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: graceful-shutdown-pod
spec:
  terminationGracePeriodSeconds: 45
  containers:
  - name: app
    image: myapp:latest
    lifecycle:
      preStop:
        exec:
          command:
          - /bin/sh
          - -c
          - "sleep 10; /app/graceful-shutdown.sh"
    readinessProbe:
      httpGet:
        path: /health/ready
        port: 8080
      periodSeconds: 5
      failureThreshold: 1
```

### Circuit Breaker Patterns

Circuit breaker patterns provide fault tolerance by preventing cascading failures when downstream services become unavailable or degraded. These patterns monitor failure rates and response times, automatically blocking requests to failing services while allowing the system to recover gracefully.

Circuit breaker states include closed, open, and half-open modes that control request flow based on service health. The closed state allows normal request processing while monitoring failure rates and response times. When failure thresholds are exceeded, the circuit opens, immediately failing requests without attempting downstream communication. The half-open state periodically tests service recovery by allowing limited requests through.

Failure detection mechanisms evaluate various metrics to determine when circuit breakers should trip. Response timeouts indicate service availability issues, while HTTP error rates reveal application-level failures. Combined metrics provide comprehensive service health assessment that accounts for both availability and performance degradation.

Recovery strategies determine how circuit breakers return to normal operation after failures. Time-based recovery allows circuits to close after specified durations, assuming that temporary issues have resolved. Success-based recovery requires a certain number of consecutive successful requests before closing circuits. Adaptive recovery adjusts thresholds based on recent failure patterns.

Bulkhead patterns complement circuit breakers by isolating different service interactions to prevent failure propagation. Thread pool isolation prevents one failing service from consuming all application threads, while connection pool isolation limits resource usage per service. These patterns ensure that failures in one service don't impact the entire application.

Fallback mechanisms provide alternative responses when circuit breakers are open, maintaining partial functionality during service outages. Cached responses serve previously successful results, while default responses provide basic functionality. Degraded mode operation reduces feature sets while maintaining core services.

**Key points:**

- Circuit breakers prevent cascading failures through automatic request blocking
- State transitions control request flow based on downstream service health
- Failure detection combines multiple metrics for comprehensive health assessment
- Recovery strategies balance quick restoration with stability
- Bulkhead patterns isolate failures to prevent system-wide impact
- Fallback mechanisms maintain partial functionality during outages

**Example:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: circuit-breaker-config
data:
  config.yaml: |
    circuit_breaker:
      failure_threshold: 5
      recovery_timeout: 30s
      success_threshold: 3
      timeout: 10s
      max_requests: 100
    fallback:
      enabled: true
      cache_ttl: 300s
      default_response: |
        {
          "status": "degraded",
          "message": "Service temporarily unavailable"
        }
```

**Next steps:**

- Implement comprehensive monitoring for health check metrics and failure patterns
- Configure distributed tracing to understand request flow through circuit breakers
- Set up alerting for circuit breaker state changes and failure threshold breaches
- Implement chaos engineering practices to test circuit breaker effectiveness
- Design fallback strategies that maintain critical business functionality during outages

---


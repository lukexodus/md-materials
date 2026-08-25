## Overview

docker run -d \
  --label SERVICE_NAME=payment-service \
  --label SERVICE_TAGS=v1,production \
  -p 8080:8080 \
  payment-service:latest
```

Registrator detects new container, registers in Consul as `payment-service` with tags `v1,production` and port `8080`.

### Best Practices

#### Design for Failure

**Assume Registry Will Be Unavailable:**

- Implement client-side caching with reasonable TTLs
- Graceful degradation when registry down
- Health checks should not cause cascading failures
- Services should handle discovery failures

**Example Resilience Pattern:**

```javascript
class ResilientServiceRegistry {
  async getServiceInstances(serviceName) {
    try {
      // Try registry with timeout
      return await this.registry.getInstances(serviceName, { timeout: 2000 });
    } catch (error) {
      // Fallback to cache
      const cached = this.cache.get(serviceName);
      if (cached) {
        this.logger.warn(`Using cached instances for ${serviceName}`);
        return cached;
      }
      // Last resort: hardcoded fallback
      if (this.fallbackHosts[serviceName]) {
        this.logger.error(`Using fallback hosts for ${serviceName}`);
        return this.fallbackHosts[serviceName];
      }
      throw new ServiceDiscoveryError(`Cannot discover ${serviceName}`);
    }
  }
}
```

#### Keep Health Checks Lightweight

**Avoid:**

- Deep dependency checks in health endpoints
- Expensive computations
- External API calls
- Database queries with complex joins

**Prefer:**

- Simple connectivity checks
- Application readiness indicators
- Cached status when possible
- Separate liveness and readiness checks

**Example:**

```java
// Good: lightweight check
@GetMapping("/health")
public ResponseEntity<String> health() {
    if (applicationContext.isRunning()) {
        return ResponseEntity.ok("UP");
    }
    return ResponseEntity.status(503).body("DOWN");
}

// Better: separate checks
@GetMapping("/health/live")
public ResponseEntity<String> liveness() {
    // Just check if process is running
    return ResponseEntity.ok("UP");
}

@GetMapping("/health/ready")
public ResponseEntity<String> readiness() {
    // Check if ready to accept traffic
    if (databaseConnectionPool.isHealthy() && 
        cacheWarmed && 
        !shuttingDown) {
        return ResponseEntity.ok("READY");
    }
    return ResponseEntity.status(503).body("NOT_READY");
}
```

#### Use Appropriate TTLs

**Short TTLs (5-10 seconds):**

- Frequently changing environments
- Auto-scaling scenarios
- Development environments
- Services with rapid deployment cycles

**Medium TTLs (30-60 seconds):**

- Production environments
- Stable service topologies
- Balance between freshness and load

**Long TTLs (2-5 minutes):**

- Very stable environments
- High query volume scenarios
- When registry availability is concern

**Key Points:**

- Shorter TTLs = fresher data but more registry load
- Longer TTLs = reduced load but staler data
- Use background refresh to avoid blocking queries
- Adjust based on actual churn rate

#### Implement Gradual Shutdown

Services should deregister before stopping to avoid sending traffic to terminating instances.

**Graceful Shutdown Pattern:**

1. Receive shutdown signal (SIGTERM)
2. Deregister from service registry
3. Wait for in-flight requests to complete
4. Stop accepting new requests
5. Clean up resources
6. Exit

**Example:**

```javascript
let isShuttingDown = false;

process.on('SIGTERM', async () => {
  console.log('SIGTERM received, starting graceful shutdown');
  isShuttingDown = true;
  
  // Stop health checks from passing
  server.close(async () => {
    try {
      // Deregister from registry
      await serviceRegistry.deregister(serviceId);
      console.log('Deregistered from service registry');
      
      // Wait for existing requests (max 30s)
      await waitForActiveRequests(30000);
      
      // Close connections
      await database.close();
      await cache.disconnect();
      
      console.log('Graceful shutdown complete');
      process.exit(0);
    } catch (error) {
      console.error('Error during shutdown:', error);
      process.exit(1);
    }
  });
  
  // Force shutdown after timeout
  setTimeout(() => {
    console.error('Forced shutdown after timeout');
    process.exit(1);
  }, 35000);
});

// Health check respects shutdown state
app.get('/health', (req, res) => {
  if (isShuttingDown) {
    res.status(503).send('SHUTTING_DOWN');
  } else {
    res.status(200).send('OK');
  }
});
```

**Output:**

1. Kubernetes sends SIGTERM to pod
2. Service immediately starts returning 503 on health checks
3. After 10 seconds, Consul marks service unhealthy (missed 1 health check)
4. Service deregisters from Consul
5. No new traffic routed to this instance
6. Service waits for 15 active requests to complete (takes 3 seconds)
7. Service closes database connections and exits
8. Total graceful shutdown time: 13 seconds
9. Zero dropped requests

#### Version Your Service Contracts

Use metadata to support multiple API versions during transitions.

**Example:**

```json
{
  "name": "api-gateway",
  "instances": [
    {
      "id": "gateway-1",
      "host": "10.0.1.10",
      "metadata": {
        "api_version": "v1",
        "deprecated": "true",
        "sunset_date": "2026-03-01"
      }
    },
    {
      "id": "gateway-2",
      "host": "10.0.1.11",
      "metadata": {
        "api_version": "v2"
      }
    }
  ]
}
```

Clients can request specific version or get latest. Gradual migration path from v1 to v2.

### Common Pitfalls

#### Shared Databases Between Services

If services share a database, service registry doesn't provide true independence.

**Problem:**

- Services coupled through database schema
- Can't deploy services independently
- Database becomes single point of failure

**Solution:**

- Each service should own its data
- Communicate through APIs or events
- Use service registry for service-to-service discovery, not database discovery

#### Not Handling Registry Unavailability

Services that fail immediately when registry is down create cascading failures.

**Problem:**

- All services fail simultaneously
- System completely unavailable
- Recovery difficult

**Solution:**

- Client-side caching
- Fallback mechanisms
- Graceful degradation
- Circuit breakers

#### Over-Aggressive Health Checks

Health checks that are too frequent or too complex can cause problems.

**Problem:**

- Health check traffic overwhelms services
- False positives from transient issues
- Flapping services (repeatedly marked healthy/unhealthy)

**Solution:**

- Reasonable check intervals (10-30 seconds)
- Lightweight check implementation
- Separate liveness and readiness
- Threshold-based marking (fail N consecutive times)

#### Ignoring Security

Running service registry without authentication or encryption.

**Problem:**

- Unauthorized service registration
- Malicious services impersonating legitimate ones
- Service discovery information leaked
- Man-in-the-middle attacks

**Solution:**

- Enable authentication and authorization
- Use TLS for all communication
- Regular security audits
- Principle of least privilege

**Conclusion:** Service registry is a foundational component of microservices architecture that enables dynamic service discovery, load balancing, and health monitoring. While adding operational complexity, it provides essential capabilities for building resilient, scalable distributed systems. Success requires choosing the right registry implementation for your environment, implementing proper health checking and security, designing for failure scenarios, and following best practices for graceful operations. The key is balancing the benefits of dynamic discovery with the operational overhead and potential failure modes introduced by this additional infrastructure component.

**Next Steps:**

1. Evaluate service registry options based on your infrastructure (Consul, Eureka, etcd, Cloud Map)
2. Set up a test registry cluster with high availability configuration
3. Implement health check endpoints in your services (separate liveness and readiness)
4. Create service registration logic (self-registration or third-party)
5. Implement client-side discovery with caching and fallback mechanisms
6. Configure appropriate health check intervals and TTLs
7. Enable authentication and encryption for security
8. Set up monitoring and alerting for registry health
9. Test failure scenarios (registry down, service failures, network partitions)
10. Document your service discovery patterns and standards for teams

---

## Service Discovery

### Overview

Service Discovery is a mechanism that enables services in a distributed system to automatically find and communicate with each other without hardcoded network locations. In microservices architectures, services need to locate other services dynamically as instances are created, destroyed, or relocated across different hosts and ports. Service Discovery provides a registry where services register their locations and a mechanism for clients to query and retrieve these locations at runtime.

### Problem Statement

In traditional monolithic applications, components communicate through direct method calls or known network locations. However, microservices architectures introduce several challenges:

- **Dynamic IP addresses**: Cloud environments and container orchestrators assign IP addresses dynamically
- **Auto-scaling**: Services scale up and down based on load, changing the number of available instances
- **Service mobility**: Containers move between hosts due to failures, updates, or resource optimization
- **Multiple instances**: Services run multiple instances for high availability and load distribution
- **Environment differences**: Services run on different hosts and ports across development, staging, and production
- **Network failures**: Service instances may become unhealthy or unreachable
- **Load distribution**: Clients need to distribute requests across healthy service instances

Hardcoding service locations becomes impossible when instances are constantly changing, and manual configuration becomes a maintenance burden that doesn't scale.

### Solution

Service Discovery solves these problems through two main components:

**Service Registry**: A centralized or distributed database that maintains a real-time directory of available service instances, their network locations, and health status.

**Discovery Mechanism**: A method for services to register themselves and for clients to query the registry to find available instances.

The pattern enables services to:

- Automatically register when they start
- Deregister when they stop or become unhealthy
- Query the registry to find other services
- Receive updated location information when services change
- Distribute load across multiple instances

### Architecture Components

#### Service Registry

The registry maintains information about service instances:

- **Service name**: Logical identifier for the service (e.g., "order-service")
- **Instance ID**: Unique identifier for each service instance
- **Network location**: IP address and port number
- **Health status**: Whether the instance is healthy and accepting requests
- **Metadata**: Additional information like version, region, tags, or capabilities
- **Registration timestamp**: When the instance registered
- **Lease/TTL**: Time-to-live for the registration

#### Registration Process

Services register themselves through:

- **Self-registration**: Service instances directly register with the registry when they start
- **Third-party registration**: An external component (like a sidecar or orchestrator) registers services
- **Health checks**: Periodic checks to verify instance health and update status
- **Heartbeats**: Regular signals to confirm instances are still alive
- **Deregistration**: Explicit removal when instances shut down gracefully

#### Discovery Process

Clients discover services through:

- **Client-side discovery**: Clients query the registry and choose an instance
- **Server-side discovery**: Clients send requests to a load balancer that queries the registry
- **DNS-based discovery**: Service names resolve to IP addresses through DNS
- **Cache-based discovery**: Clients cache registry information to reduce lookup latency

#### Health Monitoring

The registry tracks instance health through:

- **Active health checks**: Registry actively polls instances to verify they're responsive
- **Passive health checks**: Instances send heartbeats to confirm they're alive
- **Application-level checks**: Custom health endpoints that verify application readiness
- **Infrastructure checks**: Monitoring of CPU, memory, and network connectivity
- **Automatic deregistration**: Unhealthy instances are removed from the registry

### Implementation Patterns

#### Client-Side Discovery Pattern

Clients directly query the service registry and select an instance.

**Flow**:

```
1. Service instances register with registry on startup
2. Client queries registry for "payment-service"
3. Registry returns list of healthy instances
4. Client selects instance using load balancing algorithm
5. Client makes direct request to selected instance
```

**Advantages**:

- Clients have full control over load balancing logic
- No additional network hop through a load balancer
- Clients can implement sophisticated routing (sticky sessions, canary routing)
- Lower latency since clients connect directly to services

**Disadvantages**:

- Clients must implement discovery logic in every service
- Service discovery library must be available for all programming languages
- Clients are tightly coupled to the registry
- More complex client implementation

#### Server-Side Discovery Pattern

Clients send requests to a load balancer or router that queries the registry.

**Flow**:

```
1. Service instances register with registry on startup
2. Client sends request to load balancer at known location
3. Load balancer queries registry for healthy instances
4. Load balancer selects instance and forwards request
5. Load balancer returns response to client
```

**Advantages**:

- Clients remain simple and don't need discovery logic
- Centralized load balancing and routing logic
- Load balancer can provide additional features (SSL termination, rate limiting)
- Easier to change discovery mechanism without updating clients

**Disadvantages**:

- Additional network hop adds latency
- Load balancer becomes a potential bottleneck and single point of failure
- Requires highly available load balancer infrastructure
- Less flexibility in client-side routing decisions

#### DNS-Based Discovery

Service names are resolved through DNS queries.

**Flow**:

```
1. Services register with registry
2. DNS server synchronizes with registry
3. Client performs DNS lookup for "payment-service.local"
4. DNS returns IP addresses of healthy instances
5. Client connects to one of the returned addresses
```

**Advantages**:

- Uses standard DNS protocol, no special client libraries
- Works with any programming language or platform
- Can leverage existing DNS infrastructure
- Simpler client implementation

**Disadvantages**:

- DNS caching can cause stale information
- Limited to round-robin load balancing
- No built-in health checking at DNS level
- TTL configuration trade-off between freshness and DNS load

#### Service Mesh Discovery

A service mesh handles service discovery transparently.

**Flow**:

```
1. Services register with control plane (automatically or explicitly)
2. Sidecar proxies receive configuration from control plane
3. Client sends request to local sidecar proxy
4. Sidecar proxy discovers instances and routes request
5. Destination sidecar proxy receives and forwards to service
```

**Advantages**:

- Discovery is transparent to application code
- Advanced traffic management (retries, circuit breakers, timeouts)
- Consistent observability across all services
- Language-agnostic implementation

**Disadvantages**:

- Additional infrastructure complexity
- Resource overhead from sidecar proxies
- Learning curve for service mesh technology
- Potential performance impact from proxy hops

### Popular Service Discovery Tools

#### Consul

A distributed service mesh solution with service discovery, health checking, and key-value store.

**Features**:

- Multi-datacenter support
- Health checking with multiple check types
- DNS and HTTP interfaces
- Service segmentation and access control
- Key-value store for configuration

**Registration example**:

```json
{
  "service": {
    "name": "order-service",
    "tags": ["v1", "production"],
    "port": 8080,
    "check": {
      "http": "http://localhost:8080/health",
      "interval": "10s",
      "timeout": "1s"
    }
  }
}
```

#### Eureka

Netflix's service discovery solution, commonly used with Spring Cloud.

**Features**:

- Client-side load balancing with Ribbon
- Built-in dashboard for monitoring
- Self-preservation mode during network partitions
- Region and zone awareness
- REST-based API

**Registration example**:

```java
@EnableEurekaClient
@SpringBootApplication
public class OrderServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }
}
```

#### etcd

A distributed key-value store often used for service discovery and configuration.

**Features**:

- Strong consistency with Raft consensus
- Watch API for real-time updates
- TTL-based key expiration
- Transaction support
- Used by Kubernetes for service discovery

**Registration example**:

```go
client.Put(ctx, "/services/order-service/instance-1", 
    `{"host": "10.0.1.5", "port": 8080}`,
    clientv3.WithLease(lease))
```

#### Zookeeper

A distributed coordination service that can be used for service discovery.

**Features**:

- Hierarchical namespace
- Ephemeral nodes for automatic deregistration
- Watches for change notifications
- Strong consistency guarantees
- Battle-tested in production environments

#### Kubernetes Service Discovery

Built-in service discovery in Kubernetes.

**Features**:

- DNS-based discovery automatically configured
- Service objects provide stable endpoints
- Endpoints track pod IP addresses
- Integrated with kube-proxy for load balancing
- No additional service registry needed

**Service definition**:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: order-service
spec:
  selector:
    app: order-service
  ports:
  - port: 80
    targetPort: 8080
```

#### AWS Cloud Map

AWS managed service discovery for cloud resources.

**Features**:

- Integration with ECS, EKS, and EC2
- DNS-based and API-based discovery
- Health checking with Route 53
- Automatic registration for AWS services
- Custom attributes and filtering

### Load Balancing Strategies

Once services are discovered, clients or load balancers must choose which instance to use:

#### Round Robin

Distributes requests evenly across all healthy instances in sequence.

[Inference] Characteristics:

- Simple to implement
- Even distribution assuming equal instance capacity
- No consideration of current load or latency
- Works well when instances are homogeneous

#### Random

Selects a random instance for each request.

[Inference] Characteristics:

- Very simple implementation
- Statistically even distribution over time
- No coordination needed between clients
- May not be perfectly balanced for low request volumes

#### Weighted Round Robin

Distributes requests based on assigned weights (capacity, performance).

[Inference] Characteristics:

- Allows heterogeneous instance sizes
- Can gradually shift traffic (blue-green, canary)
- Requires weight configuration and updates
- Better utilization of different instance types

#### Least Connections

Routes to the instance with the fewest active connections.

[Inference] Characteristics:

- Better for long-lived connections
- Requires tracking connection state
- More complex implementation
- Better load distribution for varying request durations

#### Response Time Based

Routes to instances with the lowest response times.

[Inference] Characteristics:

- Adaptive to instance performance
- Requires latency tracking
- Naturally avoids slow or overloaded instances
- More complex but better user experience

#### Geographic/Zone-Aware

Prefers instances in the same datacenter, region, or availability zone.

[Inference] Characteristics:

- Reduces latency and cross-zone traffic costs
- Improves resilience within a zone
- Requires zone metadata in registry
- Should have fallback to other zones

#### Consistent Hashing

Maps requests to instances using a hash function, maintaining affinity.

[Inference] Characteristics:

- Sticky sessions for stateful services
- Minimizes disruption when instances change
- Useful for caching scenarios
- More complex implementation

### Health Checking Strategies

#### HTTP/HTTPS Health Checks

Service exposes a health endpoint that returns status.

```
GET /health
Response: 200 OK
{
  "status": "UP",
  "checks": {
    "database": "UP",
    "cache": "UP",
    "diskSpace": "UP"
  }
}
```

[Inference] Considerations:

- Can check application dependencies
- Allows graduated health states
- May add load to the service
- Should be lightweight and fast

#### TCP Connection Checks

Verify that a service accepts TCP connections on its port.

[Inference] Considerations:

- Very lightweight
- Only checks network reachability
- Doesn't verify application functionality
- Fast and simple to implement

#### gRPC Health Checks

Use gRPC health checking protocol for gRPC services.

```protobuf
service Health {
  rpc Check(HealthCheckRequest) returns (HealthCheckResponse);
  rpc Watch(HealthCheckRequest) returns (stream HealthCheckResponse);
}
```

[Inference] Considerations:

- Standard protocol for gRPC services
- Supports streaming health updates
- Language-agnostic
- Efficient binary protocol

#### Heartbeat Mechanism

Services send periodic signals to indicate they're alive.

[Inference] Considerations:

- Service initiates the check
- Reduces load on registry
- Requires services to implement heartbeat logic
- May not detect all failure modes

#### External Monitoring

Third-party monitoring tools perform health checks.

[Inference] Considerations:

- Independent view of service health
- Can check from multiple locations
- Requires additional infrastructure
- May have different perspective than internal checks

### Registration Lifecycle

#### Startup Registration

**Self-Registration**:

```
1. Service starts and initializes
2. Service verifies its own health
3. Service registers with registry
4. Service starts accepting requests
```

**Third-Party Registration**:

```
1. Service starts
2. Platform (Kubernetes, orchestrator) detects service
3. Platform registers service with registry
4. Service begins receiving traffic
```

#### Ongoing Maintenance

```
1. Service sends periodic heartbeats (every 10-30 seconds)
2. Registry performs health checks (every 10-60 seconds)
3. Registry updates instance status based on results
4. Clients receive updated service lists
```

#### Graceful Shutdown

```
1. Service receives shutdown signal
2. Service deregisters from registry
3. Service stops accepting new requests
4. Service completes in-flight requests
5. Service shuts down
```

#### Failure Handling

```
1. Instance stops responding to health checks
2. Registry marks instance as unhealthy after threshold
3. Registry removes instance from available pool
4. Clients stop routing to failed instance
5. Failed instance attempts to recover or is replaced
```

### Caching and Performance

#### Client-Side Caching

Clients cache service locations to reduce registry queries.

**Strategy**:

```
1. Client queries registry for service locations
2. Client caches results with TTL (30-120 seconds)
3. Client uses cached locations for subsequent requests
4. Client refreshes cache when TTL expires
5. Client falls back to registry if cached instances fail
```

[Inference] Benefits:

- Reduced load on service registry
- Lower latency for service lookups
- Continued operation if registry is temporarily unavailable
- Better performance under high load

[Inference] Trade-offs:

- Potential for stale service information
- TTL balancing between freshness and performance
- Memory overhead for caching
- Complexity in cache invalidation

#### Registry Replication

Service registry uses multiple nodes for availability.

**Strategy**:

```
1. Multiple registry nodes form a cluster
2. Service registrations replicate across nodes
3. Clients query any registry node
4. Consensus protocol ensures consistency
5. System tolerates individual node failures
```

[Inference] Benefits:

- High availability of the registry itself
- Geographic distribution for lower latency
- Load distribution across registry nodes
- No single point of failure

#### Watch/Subscribe Mechanisms

Clients subscribe to registry changes instead of polling.

**Strategy**:

```
1. Client subscribes to service updates
2. Client receives initial service list
3. Registry pushes updates when services change
4. Client updates local cache immediately
5. Client maintains subscription connection
```

[Inference] Benefits:

- Real-time updates without polling
- Reduced registry load
- Lower latency for detecting changes
- More efficient network usage

### Security Considerations

#### Registry Access Control

Restrict who can register and query services.

**Measures**:

- Authentication for service registration
- Authorization based on service identity
- TLS encryption for registry communication
- API tokens or certificates for access
- Audit logging of registry operations

#### Service Authentication

Verify that services are legitimate before routing requests.

**Measures**:

- Mutual TLS (mTLS) between services
- Service tokens or API keys
- Certificate-based authentication
- Integration with identity providers
- Short-lived credentials with rotation

#### Network Segmentation

Isolate services based on sensitivity and trust levels.

**Measures**:

- Service mesh policies for traffic control
- Network policies in Kubernetes
- Security groups in cloud environments
- Zone-based access restrictions
- Zero-trust networking principles

#### Encryption in Transit

Protect data as it moves between services.

**Measures**:

- TLS/SSL for all service communication
- Certificate management and rotation
- Strong cipher suites
- Perfect forward secrecy
- Certificate pinning where appropriate

### Advantages

**Dynamic Infrastructure Management**

- Services automatically adapt to infrastructure changes
- No manual updates to configuration files
- Seamless handling of auto-scaling events
- Support for rolling deployments and updates
- Easy migration between environments

**High Availability**

- Multiple service instances for redundancy
- Automatic failover to healthy instances
- Quick detection and removal of failed instances
- No single points of failure in service communication
- Continued operation during instance failures

**Flexibility and Agility**

- Services can be deployed anywhere without reconfiguration
- Easy addition and removal of service instances
- Support for heterogeneous environments (cloud, on-premise, hybrid)
- Rapid experimentation with new deployments
- Simplified disaster recovery

**Load Distribution**

- Requests distributed across multiple instances
- Better resource utilization
- Improved performance and response times
- Ability to handle traffic spikes
- Support for different load balancing strategies

**Developer Productivity**

- Developers don't manage IP addresses and ports
- Simplified local development with dynamic discovery
- Consistent behavior across environments
- Reduced configuration errors
- Faster deployment cycles

### Challenges and Trade-offs

#### Complexity

**Challenge**: Additional infrastructure component to deploy and maintain

[Inference] Implications:

- Learning curve for team members
- More components to monitor and debug
- Potential for registry-related outages
- Requires operational expertise
- Additional failure modes to handle

**Trade-off**: Operational complexity vs dynamic infrastructure benefits

#### Consistency and Availability

**Challenge**: CAP theorem applies to service registries

[Inference] Considerations:

- Strong consistency may reduce availability during partitions
- Eventual consistency may serve stale service information
- Different registries make different trade-offs
- Split-brain scenarios possible in network partitions
- Recovery time after failures affects service availability

**Trade-off**: Consistency guarantees vs availability and partition tolerance

#### Dependency and Single Point of Failure

**Challenge**: Service registry becomes a critical dependency

[Inference] Implications:

- Services cannot discover each other if registry is down
- Registry must be highly available
- Caching can mitigate but not eliminate dependency
- Fallback strategies needed
- Registry failures impact entire system

**Trade-off**: Centralized discovery vs resilience to registry failures

#### Network Latency

**Challenge**: Additional network calls for service discovery

[Inference] Considerations:

- Registry query adds latency to requests
- More significant for client-side discovery
- Caching helps but adds staleness
- Geographic distribution of registry affects latency
- Impact depends on request patterns

**Trade-off**: Discovery flexibility vs request latency

#### Security Surface

**Challenge**: Service registry is an attractive target for attacks

[Inference] Risks:

- Unauthorized service registration could route traffic maliciously
- Registry compromise exposes service topology
- Man-in-the-middle attacks if communication not encrypted
- Denial of service attacks against registry
- Information disclosure about internal architecture

**Trade-off**: Dynamic discovery convenience vs security hardening effort

### When to Use This Pattern

**Appropriate scenarios**:

- Deploying microservices in cloud or container environments
- Using auto-scaling to handle variable load
- Running multiple instances of services for high availability
- Services frequently deploy, update, or relocate
- Dynamic infrastructure with ephemeral instances
- Large number of services that need to communicate
- Blue-green or canary deployment strategies
- Multi-environment deployments (dev, staging, production)

**When simpler alternatives might suffice**:

- Small number of services with stable locations
- Services deployed on fixed, known infrastructure
- Monolithic application with few external dependencies
- Internal network with static IP addressing
- Development or proof-of-concept environments
- Services already behind well-configured load balancers
- Kubernetes environment (where built-in discovery may be sufficient)

### Best Practices

#### Registry Configuration

- **Deploy multiple registry nodes**: Ensure high availability through clustering
- **Use appropriate consistency model**: Choose based on requirements (CP vs AP)
- **Configure health check intervals**: Balance between freshness and overhead
- **Set appropriate TTLs**: Tune time-to-live values for registrations
- **Enable monitoring and alerting**: Track registry health and performance
- **Backup registry data**: Protect against data loss
- **Use DNS for registry endpoints**: Allow registry location flexibility

#### Service Registration

- **Register late, deregister early**: Only register when ready, deregister promptly when shutting down
- **Implement graceful shutdown**: Deregister before stopping request handling
- **Include comprehensive metadata**: Add version, region, capabilities as needed
- **Use meaningful service names**: Consistent naming conventions across services
- **Register multiple ports if needed**: Distinguish between application and management ports
- **Include health check endpoints**: Make health status easy to verify
- **Handle registration failures**: Retry with exponential backoff

#### Health Checking

- **Implement deep health checks**: Verify dependencies, not just process liveness
- **Keep health checks lightweight**: Avoid expensive operations in health endpoints
- **Use graduated health states**: Distinguish between starting up, healthy, degraded, and unhealthy
- **Check critical dependencies**: Include database, cache, downstream service health
- **Set appropriate timeouts**: Balance between sensitivity and false positives
- **Implement circuit breakers**: Prevent cascading health check failures
- **Return detailed status for debugging**: Include component-level health in response

#### Client Discovery

- **Implement retry logic**: Handle transient failures when contacting discovered services
- **Cache service locations**: Reduce registry queries and latency
- **Refresh cache periodically**: Balance freshness with performance
- **Handle discovery failures gracefully**: Provide degraded functionality when possible
- **Use circuit breakers**: Protect against cascading failures
- **Implement fallback mechanisms**: Have backup strategies if discovery fails
- **Load balance across instances**: Distribute requests evenly

#### Monitoring and Observability

- **Monitor registry health**: Track registry availability and performance
- **Track service registration metrics**: Count registrations, deregistrations, health changes
- **Monitor discovery latency**: Measure time to discover and connect to services
- **Alert on registry failures**: Immediate notification of registry issues
- **Track service instance counts**: Detect unexpected scaling or failures
- **Log discovery events**: Maintain audit trail for troubleshooting
- **Use distributed tracing**: Correlate service discovery with request flows

### Real-World Example

**E-Commerce Platform with Service Discovery**

**Architecture Components**:

**Consul Cluster** (Service Registry)

- 3-node cluster for high availability
- Health checking every 10 seconds
- HTTP and DNS interfaces
- Distributed across availability zones

**Services**:

- Order Service (3 instances)
- Payment Service (2 instances)
- Inventory Service (4 instances)
- Notification Service (2 instances)
- API Gateway (2 instances)

**Service Registration**:

```javascript
// Order Service startup code
const consul = require('consul')({ host: 'consul.internal' });

async function registerService() {
    const serviceId = `order-service-${process.env.HOSTNAME}`;
    
    await consul.agent.service.register({
        id: serviceId,
        name: 'order-service',
        address: process.env.SERVICE_IP,
        port: 8080,
        tags: ['v2', 'production', 'zone-us-east-1a'],
        meta: {
            version: '2.1.0',
            environment: 'production',
            commitHash: process.env.GIT_COMMIT
        },
        check: {
            http: `http://${process.env.SERVICE_IP}:8080/health`,
            interval: '10s',
            timeout: '2s',
            deregister_critical_service_after: '1m'
        }
    });
    
    console.log(`Registered service: ${serviceId}`);
}

// Graceful shutdown
process.on('SIGTERM', async () => {
    await consul.agent.service.deregister(serviceId);
    console.log('Deregistered from Consul');
    process.exit(0);
});
```

**Service Discovery (Client-Side)**:

```javascript
// Payment Service discovering Inventory Service
const consul = require('consul')({ host: 'consul.internal' });

class InventoryClient {
    constructor() {
        this.cache = new Map();
        this.cacheTTL = 30000; // 30 seconds
    }
    
    async discoverInstances() {
        const cacheEntry = this.cache.get('inventory-service');
        
        // Return cached if still valid
        if (cacheEntry && Date.now() - cacheEntry.timestamp < this.cacheTTL) {
            return cacheEntry.instances;
        }
        
        // Query Consul for healthy instances
        const result = await consul.health.service({
            service: 'inventory-service',
            passing: true  // Only healthy instances
        });
        
        const instances = result.map(entry => ({
            id: entry.Service.ID,
            address: entry.Service.Address,
            port: entry.Service.Port,
            tags: entry.Service.Tags,
            meta: entry.Service.Meta
        }));
        
        // Update cache
        this.cache.set('inventory-service', {
            instances,
            timestamp: Date.now()
        });
        
        return instances;
    }
    
    async checkStock(productId, quantity) {
        const instances = await this.discoverInstances();
        
        if (instances.length === 0) {
            throw new Error('No healthy inventory-service instances available');
        }
        
        // Simple round-robin load balancing
        const instance = instances[Math.floor(Math.random() * instances.length)];
        
        const url = `http://${instance.address}:${instance.port}/api/inventory/check`;
        
        try {
            const response = await fetch(url, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ productId, quantity }),
                timeout: 3000
            });
            
            return await response.json();
        } catch (error) {
            // Remove failed instance from cache
            console.error(`Failed to contact ${instance.id}:`, error);
            this.cache.delete('inventory-service');
            throw error;
        }
    }
}
```

**Health Check Endpoint**:

```javascript
// Order Service health check implementation
const express = require('express');
const app = express();

// Detailed health check
app.get('/health', async (req, res) => {
    const health = {
        status: 'UP',
        timestamp: new Date().toISOString(),
        checks: {}
    };
    
    // Check database connection
    try {
        await db.query('SELECT 1');
        health.checks.database = { status: 'UP' };
    } catch (error) {
        health.checks.database = { 
            status: 'DOWN', 
            error: error.message 
        };
        health.status = 'DOWN';
    }
    
    // Check Redis cache
    try {
        await redis.ping();
        health.checks.cache = { status: 'UP' };
    } catch (error) {
        health.checks.cache = { 
            status: 'DOWN', 
            error: error.message 
        };
        health.status = 'DEGRADED';  // Can operate without cache
    }
    
    // Check disk space
    const diskUsage = await checkDiskSpace('/');
    health.checks.diskSpace = {
        status: diskUsage.free > 1024 * 1024 * 1024 ? 'UP' : 'DOWN',  // 1GB minimum
        free: diskUsage.free,
        total: diskUsage.total
    };
    
    if (health.checks.diskSpace.status === 'DOWN') {
        health.status = 'DOWN';
    }
    
    // Check downstream service availability
    try {
        const inventoryInstances = await discoverService('inventory-service');
        health.checks.inventoryService = {
            status: inventoryInstances.length > 0 ? 'UP' : 'DOWN',
            instances: inventoryInstances.length
        };
    } catch (error) {
        health.checks.inventoryService = {
            status: 'DOWN',
            error: error.message
        };
        health.status = 'DEGRADED';  // Can queue orders even if inventory is down
    }
    
    const statusCode = health.status === 'UP' ? 200 : 
                       health.status === 'DEGRADED' ? 200 : 503;
    
    res.status(statusCode).json(health);
});
```

**DNS-Based Discovery**:

```javascript
// Simple DNS-based discovery using Consul DNS interface
const dns = require('dns').promises;

async function discoverServiceDNS(serviceName) {
    try {
        // Query Consul DNS interface
        // Returns only healthy instances
        const addresses = await dns.resolve4(`${serviceName}.service.consul`);
        
        return addresses.map(address => ({
            address,
            port: 8080  // Default port, or use SRV records for port discovery
        }));
    } catch (error) {
        console.error(`DNS discovery failed for ${serviceName}:`, error);
        return [];
    }
}

// Usage
const instances = await discoverServiceDNS('payment-service');
```

**API Gateway with Service Discovery**:

```javascript
// API Gateway discovers backend services dynamically
const express = require('express');
const httpProxy = require('http-proxy');
const consul = require('consul')({ host: 'consul.internal' });

const app = express();
const proxy = httpProxy.createProxyServer();

// Service discovery cache
const serviceCache = new Map();

async function getServiceInstance(serviceName) {
    // Check cache first
    const cached = serviceCache.get(serviceName);
    if (cached && Date.now() - cached.timestamp < 30000) {
        return selectInstance(cached.instances);
    }
    
    // Query Consul
    const result = await consul.health.service({
        service: serviceName,
        passing: true
    });
    
    const instances = result.map(entry => ({
        address: entry.Service.Address,
        port: entry.Service.Port,
        weight: parseInt(entry.Service.Meta?.weight || '1')
    }));
    
    // Update cache
    serviceCache.set(serviceName, {
        instances,
        timestamp: Date.now()
    });
    
    return selectInstance(instances);
}

function selectInstance(instances) {
    if (instances.length === 0) return null;
    
    // Weighted random selection
    const totalWeight = instances.reduce((sum, i) => sum + i.weight, 0);
    let random = Math.random() * totalWeight;
    
    for (const instance of instances) {
        random -= instance.weight;
        if (random <= 0) return instance;
    }
    
    return instances[0];  // Fallback
}

// Proxy requests to discovered services
app.use('/api/orders/*', async (req, res) => {
    const instance = await getServiceInstance('order-service');
    
    if (!instance) {
        return res.status(503).json({ 
            error: 'Service temporarily unavailable' 
        });
    }
    
    proxy.web(req, res, {
        target: `http://${instance.address}:${instance.port}`,
        timeout: 5000
    });
});

app.use('/api/payments/*', async (req, res) => {
    const instance = await getServiceInstance('payment-service');
    
    if (!instance) {
        return res.status(503).json({ 
            error: 'Service temporarily unavailable' 
        });
    }
    
    proxy.web(req, res, {
        target: `http://${instance.address}:${instance.port}`,
        timeout: 5000
    });
});

// Handle proxy errors
proxy.on('error', (err, req, res) => {
    console.error('Proxy error:', err);
    // Invalidate cache for this service
    const serviceName = req.url.split('/')[2];
    serviceCache.delete(`${serviceName}-service`);
    
    if (!res.headersSent) {
        res.status(502).json({ 
            error: 'Bad gateway',
            message: 'Failed to contact backend service'
        });
    }
});
```

**Kubernetes Service Discovery Example**:

```yaml

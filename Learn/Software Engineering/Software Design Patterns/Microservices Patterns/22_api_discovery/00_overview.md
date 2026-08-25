## Overview

aws servicediscovery discover-instances \
  --namespace-name local \
  --service-name payment-service
```

**Use Cases:**

- AWS-native deployments
- Teams wanting managed solutions
- ECS and EKS workloads
- Organizations prioritizing operational simplicity

### Health Checking Mechanisms

#### Passive Health Checks

Monitor actual traffic to determine service health.

**How It Works:**

- Load balancer or client tracks request success/failure
- After N consecutive failures, mark instance unhealthy
- After N consecutive successes, mark healthy again
- No additional health check traffic

**Key Points:**

- Reflects real traffic patterns
- No overhead when service not receiving requests
- Slower to detect failures (needs actual requests)
- Good for user-facing services

**Example:** Nginx passive health check configuration:

```nginx
upstream backend {
    server 10.0.1.10:8080 max_fails=3 fail_timeout=30s;
    server 10.0.1.11:8080 max_fails=3 fail_timeout=30s;
    server 10.0.1.12:8080 max_fails=3 fail_timeout=30s;
}
```

**Output:** If 10.0.1.10:8080 returns errors for 3 consecutive requests, Nginx marks it unhealthy for 30 seconds. No traffic sent during this period. After 30 seconds, Nginx retries the instance.

#### Active Health Checks

Registry or load balancer actively probes service endpoints.

**HTTP/HTTPS Checks:**

```json
{
  "check": {
    "http": "http://localhost:8080/health",
    "interval": "10s",
    "timeout": "2s"
  }
}
```

**TCP Checks:**

```json
{
  "check": {
    "tcp": "localhost:8080",
    "interval": "5s",
    "timeout": "1s"
  }
}
```

**Script-Based Checks:**

```json
{
  "check": {
    "script": "/usr/local/bin/check_service.sh",
    "interval": "30s"
  }
}
```

**Key Points:**

- Detects failures even without traffic
- Configurable check frequency
- Can verify application logic, not just connectivity
- Adds monitoring overhead

**Example:** Spring Boot Actuator health endpoint:

```java
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    @Autowired
    private DataSource dataSource;
    
    @Override
    public Health health() {
        try (Connection conn = dataSource.getConnection()) {
            if (conn.isValid(2)) {
                return Health.up()
                    .withDetail("database", "responsive")
                    .build();
            }
        } catch (Exception e) {
            return Health.down()
                .withDetail("error", e.getMessage())
                .build();
        }
        return Health.down().build();
    }
}
```

**Output:**

```json
{
  "status": "UP",
  "components": {
    "database": {
      "status": "UP",
      "details": {
        "database": "responsive"
      }
    },
    "diskSpace": {
      "status": "UP",
      "details": {
        "total": 500GB,
        "free": 250GB
      }
    }
  }
}
```

Consul polls `/actuator/health` every 10 seconds. If response is not 200 OK or times out, marks service unhealthy after 3 consecutive failures.

#### TTL-Based Health Checks

Services send heartbeats within a time window to stay registered.

**How It Works:**

1. Service registers with TTL (e.g., 30 seconds)
2. Service must send heartbeat before TTL expires
3. Registry removes service if no heartbeat received
4. Service must re-register if TTL expires

**Key Points:**

- Service controls its own health status
- Reduces registry load (no active polling)
- Risk of false negatives if network issues prevent heartbeats
- Requires reliable heartbeat mechanism in service

**Example:** etcd TTL registration:

```go
// Create lease with 30-second TTL
lease, _ := client.Grant(context.Background(), 30)

// Register service with lease
client.Put(context.Background(), 
    "/services/auth/instance-1",
    serviceData,
    clientv3.WithLease(lease.ID))

// Keep lease alive (heartbeat)
ch, _ := client.KeepAlive(context.Background(), lease.ID)

// Process responses
for range ch {
    // Lease renewed
}
```

**Output:** Service sends heartbeat every 10 seconds. If process crashes or becomes unresponsive, no heartbeat sent. After 30 seconds, etcd automatically removes service entry. Clients querying `/services/auth/` no longer see this instance.

### Load Balancing Strategies

#### Round Robin

Distribute requests evenly across all instances in order.

**Algorithm:**

- Maintain counter of last instance used
- Select next instance in list
- Wrap around to first instance after reaching end

**Key Points:**

- Simple and predictable
- Works well when instances have similar capacity
- Doesn't consider instance load or response time
- Fair distribution over time

**Example:** Available instances: A (10.0.1.5), B (10.0.1.6), C (10.0.1.7)

- Request 1 → A
- Request 2 → B
- Request 3 → C
- Request 4 → A
- Request 5 → B

#### Random

Select random instance for each request.

**Key Points:**

- Very simple to implement
- Good distribution with many requests
- No state to maintain
- Can create temporary imbalances

**Example:**

```javascript
function selectInstance(instances) {
    const randomIndex = Math.floor(Math.random() * instances.length);
    return instances[randomIndex];
}
```

#### Least Connections

Route to instance with fewest active connections.

**Key Points:**

- Better for long-lived connections
- Requires tracking connection counts
- Adapts to varying request durations
- More complex implementation

**Example:** Available instances with connection counts:

- Instance A: 5 active connections
- Instance B: 12 active connections
- Instance C: 3 active connections

New request routed to Instance C (least connections).

#### Weighted Round Robin

Assign weights to instances based on capacity, then distribute proportionally.

**Key Points:**

- Accounts for heterogeneous instance sizes
- More powerful instances receive more traffic
- Requires capacity information
- More complex configuration

**Example:** Instances with weights:

- Instance A (8 cores): weight 8
- Instance B (4 cores): weight 4
- Instance C (2 cores): weight 2

Distribution over 14 requests:

- Instance A: 8 requests (57%)
- Instance B: 4 requests (29%)
- Instance C: 2 requests (14%)

#### Consistent Hashing

Map requests to instances using hash function for sticky routing.

**Key Points:**

- Same request always goes to same instance (when healthy)
- Useful for caching and session affinity
- Minimizes cache invalidation when instances change
- Requires hash key (user ID, session ID, etc.)

**Example:** Hash user ID to determine instance:

- User "user123" → hash(user123) mod 3 = 1 → Instance B
- User "user456" → hash(user456) mod 3 = 2 → Instance C
- User "user789" → hash(user789) mod 3 = 0 → Instance A

Same user always routed to same instance for session consistency.

#### Geographic/Zone-Aware Routing

Route requests to instances in same region or availability zone.

**Key Points:**

- Reduces latency
- Improves reliability (stays within zone)
- Requires metadata about instance locations
- Fallback to other zones if local unavailable

**Example:** Client in us-east-1a queries order-service:

1. Registry returns instances tagged with zones
2. Client filters for us-east-1a instances
3. Client applies round-robin among local instances
4. If no local instances, fallback to us-east-1b

### Service Metadata

#### Purpose of Metadata

Metadata provides additional context about service instances beyond network location.

**Common Metadata:**

- Version (1.2.3, v2)
- Environment (production, staging, development)
- Region/Zone (us-east-1, eu-west-1a)
- Capabilities/Features (payment-v2, internationalization)
- Performance characteristics (latency-optimized, batch-processor)
- Resource information (cpu=8, memory=16GB)

#### Using Metadata for Routing

**Version-Based Routing:**

```javascript
// Get instances of specific version
const instances = registry.getInstances('order-service', {
    version: 'v2'
});
```

**Feature-Based Routing:**

```javascript
// Route to instances supporting specific feature
const instances = registry.getInstances('payment-service', {
    capabilities: 'recurring-payments'
});
```

**Canary Deployments:**

```javascript
// 90% traffic to stable version, 10% to canary
const stableInstances = registry.getInstances('api-service', {
    version: 'stable'
});
const canaryInstances = registry.getInstances('api-service', {
    version: 'canary'
});

const instance = Math.random() < 0.9
    ? selectFrom(stableInstances)
    : selectFrom(canaryInstances);
```

**Example:** A/B testing with metadata:

```json
{
  "name": "recommendation-service",
  "instances": [
    {
      "id": "rec-1",
      "host": "10.0.1.10",
      "metadata": {
        "version": "v1",
        "algorithm": "collaborative-filtering"
      }
    },
    {
      "id": "rec-2",
      "host": "10.0.1.11",
      "metadata": {
        "version": "v2",
        "algorithm": "deep-learning"
      }
    }
  ]
}
```

**Output:** Client routing logic:

- 50% of users (user_id % 2 == 0) → v1 collaborative-filtering
- 50% of users (user_id % 2 == 1) → v2 deep-learning
- Compare metrics between algorithms
- Gradually shift traffic based on results

### Registry Replication and High Availability

#### Why High Availability Matters

Service registry is critical infrastructure. If unavailable, services cannot discover each other, causing widespread failures.

#### Replication Strategies

**Master-Slave Replication:**

- One master handles writes
- Multiple slaves handle reads
- Automatic failover to slave if master fails
- [Inference] Potential brief unavailability during failover

**Multi-Master Replication:**

- Multiple nodes accept writes
- Conflict resolution mechanisms
- Higher availability
- More complex consistency management

**Quorum-Based Consensus:**

- Raft or Paxos consensus protocols
- Writes committed when majority agrees
- Strong consistency guarantees
- Used by etcd, Consul

**Key Points:**

- Deploy registry in cluster mode (3-5 nodes typical)
- Distribute nodes across availability zones
- Client-side caching reduces registry dependency
- Graceful degradation when registry unavailable

**Example:** Consul 3-node cluster:

```
Node 1 (us-east-1a): Leader
Node 2 (us-east-1b): Follower
Node 3 (us-east-1c): Follower

Write request arrives at Node 2:
1. Node 2 forwards to Node 1 (leader)
2. Node 1 replicates to Node 2 and Node 3
3. Once majority (2/3) acknowledge, write committed
4. Node 1 responds to client

If Node 1 fails:
1. Node 2 and Node 3 detect missing heartbeats
2. Election timeout triggers new election
3. Node 2 becomes new leader (has latest logs)
4. Clients automatically redirect to Node 2
Total failover time: ~5 seconds
```

#### Client-Side Caching

Clients cache registry responses to reduce dependency and improve performance.

**Cache Strategies:**

- Cache full service instance list
- TTL-based expiration
- Background refresh
- Fallback to cache if registry unreachable

**Key Points:**

- Reduces registry load
- Improves latency
- Provides resilience during registry outages
- Risk of serving stale data

**Example:**

```java
public class CachedServiceRegistry {
    private final Map<String, CachedEntry> cache = new ConcurrentHashMap<>();
    private final ServiceRegistry registry;
    
    public List<ServiceInstance> getInstances(String serviceName) {
        CachedEntry entry = cache.get(serviceName);
        
        // Return cached if fresh
        if (entry != null && entry.isValid()) {
            return entry.instances;
        }
        
        try {
            // Fetch from registry
            List<ServiceInstance> instances = 
                registry.getInstances(serviceName);
            
            // Update cache
            cache.put(serviceName, new CachedEntry(instances, 60)); // 60s TTL
            
            return instances;
        } catch (RegistryUnavailableException e) {
            // Fallback to stale cache
            if (entry != null) {
                logger.warn("Registry unavailable, using stale cache");
                return entry.instances;
            }
            throw e;
        }
    }
}
```

**Output:** Normal operation: Cache hit rate 95%, registry latency 2ms, total latency 0.1ms Registry outage: Cache hit rate 100%, serving potentially stale data (up to 60s old), zero registry calls Registry recovery: Background refresh updates cache, clients unaware of outage

### Security Considerations

#### Registry Authentication

Control who can register, query, and modify services.

**Authentication Methods:**

- API tokens
- TLS client certificates
- OAuth 2.0
- Integration with identity providers (LDAP, Active Directory)

**Example:** Consul with ACL tokens:

```hcl

## Horizontal Scaling Patterns

Horizontal scaling distributes workload across multiple instances, increasing system capacity through parallelism rather than upgrading individual machines. Implementation requires addressing state management, data consistency, load distribution, and inter-node coordination.

### Stateless Service Design

Stateless services maintain no session or request-specific data between calls, enabling arbitrary request routing:

```csharp
// CORRECT: Stateless service
public class OrderService
{
    private readonly IOrderRepository _repository;
    private readonly IDistributedCache _cache;
    
    public OrderService(IOrderRepository repository, IDistributedCache cache)
    {
        _repository = repository;
        _cache = cache;
    }
    
    public async Task<Order> GetOrderAsync(int orderId)
    {
        // All state from external stores
        var cacheKey = $"order:{orderId}";
        var cached = await _cache.GetStringAsync(cacheKey);
        
        if (cached != null)
            return JsonSerializer.Deserialize<Order>(cached);
        
        var order = await _repository.GetByIdAsync(orderId);
        await _cache.SetStringAsync(cacheKey, JsonSerializer.Serialize(order));
        
        return order;
    }
}
```

**Anti-Pattern:** In-memory state preventing horizontal scaling:

```csharp
// WRONG: Instance-local state
public class OrderService
{
    private readonly Dictionary<int, Order> _orderCache = new(); // Not shared
    private int _requestCount; // Lost on instance restart
    
    public Order GetOrder(int orderId)
    {
        _requestCount++; // Different per instance
        return _orderCache.GetValueOrDefault(orderId);
    }
}
```

### Shared-Nothing Architecture

Instances operate independently without shared memory or direct communication:

```csharp
public class EventProcessor
{
    private readonly IMessageQueue _queue;
    private readonly IDatabase _database;
    
    public async Task ProcessMessagesAsync(CancellationToken cancellationToken)
    {
        // Each instance processes from shared queue
        while (!cancellationToken.IsCancellationRequested)
        {
            var message = await _queue.DequeueAsync(cancellationToken);
            
            if (message != null)
            {
                await ProcessMessageAsync(message);
                await _queue.AcknowledgeAsync(message.Id);
            }
        }
    }
    
    private async Task ProcessMessageAsync(Message message)
    {
        // Process independently, persist to shared database
        var result = Transform(message);
        await _database.SaveAsync(result);
    }
}
```

**Characteristics:**

1. No inter-instance dependencies
2. Failures isolated to single instance
3. Add/remove instances without coordination
4. Linear scalability for embarrassingly parallel workloads

### Session Affinity (Sticky Sessions)

Routes requests from same client to same instance, enabling temporary state caching:

```csharp
// Load balancer configuration (nginx example)
upstream backend {
    ip_hash; // Route by client IP
    server instance1:5000;
    server instance2:5000;
    server instance3:5000;
}
```

**Application-level affinity:**

```csharp
public class AffinityMiddleware
{
    private readonly RequestDelegate _next;
    
    public async Task InvokeAsync(HttpContext context)
    {
        // Generate affinity cookie
        if (!context.Request.Cookies.ContainsKey("instance-affinity"))
        {
            var instanceId = Environment.MachineName;
            context.Response.Cookies.Append("instance-affinity", instanceId, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                MaxAge = TimeSpan.FromHours(1)
            });
        }
        
        await _next(context);
    }
}
```

**Limitations:**

1. Unbalanced load distribution with uneven traffic
2. Instance failures disrupt user sessions
3. Scaling events may remap sessions
4. Not effective for API-to-API communication

**Mitigation:** Combine with distributed session state:

```csharp
services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = configuration["Redis:ConnectionString"];
    options.InstanceName = "SessionCache:";
});

services.AddSession(options =>
{
    options.Cookie.IsEssential = true;
    options.IdleTimeout = TimeSpan.FromMinutes(30);
});
```

### Distributed Caching

Centralized cache shared across instances eliminates local cache inconsistency:

```csharp
public class CachedProductService
{
    private readonly IDistributedCache _cache;
    private readonly IProductRepository _repository;
    private readonly DistributedCacheEntryOptions _cacheOptions;
    
    public CachedProductService(
        IDistributedCache cache,
        IProductRepository repository)
    {
        _cache = cache;
        _repository = repository;
        _cacheOptions = new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10),
            SlidingExpiration = TimeSpan.FromMinutes(2)
        };
    }
    
    public async Task<Product> GetProductAsync(int productId)
    {
        var cacheKey = $"product:{productId}";
        var cachedBytes = await _cache.GetAsync(cacheKey);
        
        if (cachedBytes != null)
            return MessagePackSerializer.Deserialize<Product>(cachedBytes);
        
        var product = await _repository.GetByIdAsync(productId);
        
        if (product != null)
        {
            var serialized = MessagePackSerializer.Serialize(product);
            await _cache.SetAsync(cacheKey, serialized, _cacheOptions);
        }
        
        return product;
    }
    
    public async Task InvalidateProductAsync(int productId)
    {
        var cacheKey = $"product:{productId}";
        await _cache.RemoveAsync(cacheKey);
    }
}
```

**Cache Eviction Coordination:** Broadcasting invalidations across instances:

```csharp
public class CacheInvalidationService
{
    private readonly IDistributedCache _cache;
    private readonly IMessageBus _messageBus;
    
    public async Task InvalidateAsync(string pattern)
    {
        // Remove from distributed cache
        await _cache.RemoveAsync(pattern);
        
        // Notify other instances to clear local caches
        await _messageBus.PublishAsync("cache.invalidate", new
        {
            Pattern = pattern,
            Timestamp = DateTime.UtcNow
        });
    }
}

public class CacheInvalidationHandler
{
    private readonly IMemoryCache _localCache;
    
    public void Handle(CacheInvalidationMessage message)
    {
        // Clear matching entries from local cache
        _localCache.Remove(message.Pattern);
    }
}
```

### Database Connection Pooling at Scale

Connection pool sizing for multiple instances:

```csharp
services.AddDbContextPool<ApplicationDbContext>(options =>
{
    options.UseSqlServer(connectionString, sqlOptions =>
    {
        // Per-instance pool size
        sqlOptions.MaxBatchSize(100);
        sqlOptions.EnableRetryOnFailure(
            maxRetryCount: 3,
            maxRetryDelay: TimeSpan.FromSeconds(5),
            errorNumbersToAdd: null);
    });
}, poolSize: 128); // Pool size per instance
```

**Calculation:**

```
Total DB Connections = Instance Count × Pool Size Per Instance
Max Connections = Expected Peak Concurrent Requests × Average Query Time × Instance Count
```

**Anti-Pattern:** Undersized database connection limits causing contention:

```sql
-- SQL Server max connections check
SELECT name, value, value_in_use
FROM sys.configurations
WHERE name = 'user connections';

-- Ensure: Max Connections > (Instance Count × Pool Size) + Buffer
```

### Data Partitioning (Sharding)

Distribute data across multiple database instances to eliminate single-database bottleneck:

```csharp
public class ShardedOrderRepository
{
    private readonly IEnumerable<IDbConnection> _shards;
    private readonly IShardRouter _router;
    
    public ShardedOrderRepository(IEnumerable<IDbConnection> shards, IShardRouter router)
    {
        _shards = shards;
        _router = router;
    }
    
    public async Task<Order> GetOrderAsync(int orderId)
    {
        var shard = _router.GetShard(orderId);
        return await shard.QuerySingleAsync<Order>(
            "SELECT * FROM Orders WHERE Id = @Id",
            new { Id = orderId });
    }
    
    public async Task SaveOrderAsync(Order order)
    {
        var shard = _router.GetShard(order.Id);
        await shard.ExecuteAsync(
            "INSERT INTO Orders (...) VALUES (...)",
            order);
    }
}

public class HashBasedShardRouter : IShardRouter
{
    private readonly IDbConnection[] _shards;
    
    public HashBasedShardRouter(IDbConnection[] shards)
    {
        _shards = shards;
    }
    
    public IDbConnection GetShard(int key)
    {
        var hash = HashCode.Combine(key);
        var index = Math.Abs(hash) % _shards.Length;
        return _shards[index];
    }
}
```

**Consistent Hashing:** Minimize data movement during shard addition/removal:

```csharp
public class ConsistentHashRouter : IShardRouter
{
    private readonly SortedDictionary<int, IDbConnection> _ring;
    private readonly int _virtualNodes;
    
    public ConsistentHashRouter(IDbConnection[] shards, int virtualNodes = 150)
    {
        _ring = new SortedDictionary<int, IDbConnection>();
        _virtualNodes = virtualNodes;
        
        foreach (var shard in shards)
        {
            AddShard(shard);
        }
    }
    
    private void AddShard(IDbConnection shard)
    {
        for (int i = 0; i < _virtualNodes; i++)
        {
            var hash = HashCode.Combine(shard.GetHashCode(), i);
            _ring[hash] = shard;
        }
    }
    
    public IDbConnection GetShard(int key)
    {
        var hash = HashCode.Combine(key);
        
        foreach (var kvp in _ring)
        {
            if (kvp.Key >= hash)
                return kvp.Value;
        }
        
        return _ring.First().Value; // Wrap around
    }
}
```

**Cross-Shard Queries:** Avoid when possible; fan-out and aggregate when necessary:

```csharp
public async Task<IEnumerable<Order>> SearchOrdersAsync(OrderSearchCriteria criteria)
{
    // Query all shards in parallel
    var tasks = _shards.Select(async shard =>
    {
        return await shard.QueryAsync<Order>(
            "SELECT * FROM Orders WHERE Status = @Status",
            new { criteria.Status });
    });
    
    var results = await Task.WhenAll(tasks);
    
    // Aggregate and sort
    return results
        .SelectMany(r => r)
        .OrderByDescending(o => o.CreatedAt)
        .Take(criteria.Limit);
}
```

[Inference] Cross-shard queries sacrifice locality benefits of sharding. Design shard keys to colocate related data when query patterns permit.

### Load Balancing Algorithms

**Round Robin:** Distributes requests sequentially:

```csharp
public class RoundRobinLoadBalancer
{
    private readonly List<Uri> _instances;
    private int _currentIndex;
    private readonly object _lock = new();
    
    public Uri GetNextInstance()
    {
        lock (_lock)
        {
            var instance = _instances[_currentIndex];
            _currentIndex = (_currentIndex + 1) % _instances.Count;
            return instance;
        }
    }
}
```

**Least Connections:** Routes to instance with fewest active connections:

```csharp
public class LeastConnectionsLoadBalancer
{
    private readonly ConcurrentDictionary<Uri, int> _connections;
    
    public Uri GetNextInstance()
    {
        return _connections
            .OrderBy(kvp => kvp.Value)
            .First()
            .Key;
    }
    
    public void RecordConnection(Uri instance)
    {
        _connections.AddOrUpdate(instance, 1, (_, count) => count + 1);
    }
    
    public void ReleaseConnection(Uri instance)
    {
        _connections.AddOrUpdate(instance, 0, (_, count) => Math.Max(0, count - 1));
    }
}
```

**Weighted Round Robin:** Accounts for heterogeneous instance capacity:

```csharp
public class WeightedRoundRobinLoadBalancer
{
    private readonly List<(Uri Instance, int Weight)> _instances;
    private int _currentWeight;
    private int _currentIndex;
    private readonly int _maxWeight;
    private readonly int _gcd;
    
    public WeightedRoundRobinLoadBalancer(List<(Uri, int)> instances)
    {
        _instances = instances;
        _maxWeight = instances.Max(i => i.Weight);
        _gcd = instances.Select(i => i.Weight).Aggregate(GCD);
    }
    
    public Uri GetNextInstance()
    {
        while (true)
        {
            _currentIndex = (_currentIndex + 1) % _instances.Count;
            
            if (_currentIndex == 0)
            {
                _currentWeight -= _gcd;
                if (_currentWeight <= 0)
                    _currentWeight = _maxWeight;
            }
            
            if (_instances[_currentIndex].Weight >= _currentWeight)
                return _instances[_currentIndex].Instance;
        }
    }
    
    private static int GCD(int a, int b) => b == 0 ? a : GCD(b, a % b);
}
```

### Health Checks and Circuit Breaking

Remove unhealthy instances from load balancing pool:

```csharp
public class HealthCheckService : BackgroundService
{
    private readonly ILoadBalancer _loadBalancer;
    private readonly HttpClient _httpClient;
    private readonly TimeSpan _checkInterval = TimeSpan.FromSeconds(10);
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            await CheckInstancesHealthAsync();
            await Task.Delay(_checkInterval, stoppingToken);
        }
    }
    
    private async Task CheckInstancesHealthAsync()
    {
        var instances = _loadBalancer.GetAllInstances();
        
        var tasks = instances.Select(async instance =>
        {
            try
            {
                var response = await _httpClient.GetAsync(
                    $"{instance}/health",
                    TimeSpan.FromSeconds(5));
                
                if (response.IsSuccessStatusCode)
                    _loadBalancer.MarkHealthy(instance);
                else
                    _loadBalancer.MarkUnhealthy(instance);
            }
            catch
            {
                _loadBalancer.MarkUnhealthy(instance);
            }
        });
        
        await Task.WhenAll(tasks);
    }
}

public class CircuitBreakerLoadBalancer
{
    private readonly ConcurrentDictionary<Uri, CircuitBreakerState> _states = new();
    
    public Uri GetNextInstance()
    {
        var healthyInstances = _states
            .Where(kvp => kvp.Value.State == CircuitState.Closed)
            .Select(kvp => kvp.Key)
            .ToList();
        
        if (healthyInstances.Count == 0)
            throw new NoHealthyInstancesException();
        
        return healthyInstances[Random.Shared.Next(healthyInstances.Count)];
    }
    
    public void RecordSuccess(Uri instance)
    {
        _states.GetOrAdd(instance, _ => new CircuitBreakerState())
            .RecordSuccess();
    }
    
    public void RecordFailure(Uri instance)
    {
        _states.GetOrAdd(instance, _ => new CircuitBreakerState())
            .RecordFailure();
    }
}
```

### Service Discovery

Dynamic instance registration and discovery:

```csharp
public class ConsulServiceRegistry : IServiceRegistry
{
    private readonly IConsulClient _consul;
    private readonly string _serviceName;
    
    public async Task RegisterAsync(ServiceInstance instance)
    {
        var registration = new AgentServiceRegistration
        {
            ID = instance.Id,
            Name = _serviceName,
            Address = instance.Address,
            Port = instance.Port,
            Check = new AgentServiceCheck
            {
                HTTP = $"http://{instance.Address}:{instance.Port}/health",
                Interval = TimeSpan.FromSeconds(10),
                Timeout = TimeSpan.FromSeconds(5),
                DeregisterCriticalServiceAfter = TimeSpan.FromMinutes(1)
            }
        };
        
        await _consul.Agent.ServiceRegister(registration);
    }
    
    public async Task<IEnumerable<ServiceInstance>> DiscoverAsync()
    {
        var services = await _consul.Health.Service(_serviceName, tag: null, passingOnly: true);
        
        return services.Response.Select(s => new ServiceInstance
        {
            Id = s.Service.ID,
            Address = s.Service.Address,
            Port = s.Service.Port
        });
    }
    
    public async Task DeregisterAsync(string instanceId)
    {
        await _consul.Agent.ServiceDeregister(instanceId);
    }
}

public class DynamicLoadBalancer : BackgroundService
{
    private readonly IServiceRegistry _registry;
    private readonly ILoadBalancer _loadBalancer;
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var instances = await _registry.DiscoverAsync();
            _loadBalancer.UpdateInstances(instances);
            
            await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
        }
    }
}
```

### Auto-Scaling Triggers

Metrics-based scaling decisions:

```csharp
public class AutoScalerService : BackgroundService
{
    private readonly IMetricsCollector _metrics;
    private readonly IScalingExecutor _executor;
    private readonly AutoScalingPolicy _policy;
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var metrics = await _metrics.GetCurrentMetricsAsync();
            var decision = EvaluateScalingDecision(metrics);
            
            if (decision != ScalingDecision.None)
            {
                await _executor.ExecuteScalingAsync(decision);
            }
            
            await Task.Delay(_policy.EvaluationInterval, stoppingToken);
        }
    }
    
    private ScalingDecision EvaluateScalingDecision(SystemMetrics metrics)
    {
        if (metrics.CpuUtilization > _policy.ScaleUpCpuThreshold &&
            metrics.RequestQueueDepth > _policy.ScaleUpQueueThreshold)
        {
            return ScalingDecision.ScaleUp;
        }
        
        if (metrics.CpuUtilization < _policy.ScaleDownCpuThreshold &&
            metrics.RequestQueueDepth < _policy.ScaleDownQueueThreshold &&
            metrics.InstanceCount > _policy.MinInstances)
        {
            return ScalingDecision.ScaleDown;
        }
        
        return ScalingDecision.None;
    }
}

public class AutoScalingPolicy
{
    public int MinInstances { get; set; } = 2;
    public int MaxInstances { get; set; } = 10;
    public double ScaleUpCpuThreshold { get; set; } = 0.75;
    public double ScaleDownCpuThreshold { get; set; } = 0.30;
    public int ScaleUpQueueThreshold { get; set; } = 100;
    public int ScaleDownQueueThreshold { get; set; } = 10;
    public TimeSpan EvaluationInterval { get; set; } = TimeSpan.FromMinutes(1);
    public TimeSpan CooldownPeriod { get; set; } = TimeSpan.FromMinutes(5);
}
```

### Request Deduplication

Prevent duplicate processing during retries or failovers:

```csharp
public class IdempotentRequestHandler
{
    private readonly IDistributedCache _cache;
    private readonly TimeSpan _idempotencyWindow = TimeSpan.FromHours(24);
    
    public async Task<TResponse> HandleAsync<TRequest, TResponse>(
        TRequest request,
        string idempotencyKey,
        Func<TRequest, Task<TResponse>> handler)
    {
        var cacheKey = $"idempotency:{idempotencyKey}";
        
        // Check if request already processed
        var cachedResponse = await _cache.GetStringAsync(cacheKey);
        if (cachedResponse != null)
        {
            return JsonSerializer.Deserialize<TResponse>(cachedResponse);
        }
        
        // Process request
        var response = await handler(request);
        
        // Cache response
        await _cache.SetStringAsync(
            cacheKey,
            JsonSerializer.Serialize(response),
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = _idempotencyWindow
            });
        
        return response;
    }
}

[ApiController]
public class OrdersController : ControllerBase
{
    private readonly IdempotentRequestHandler _idempotentHandler;
    
    [HttpPost]
    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderRequest request)
    {
        var idempotencyKey = Request.Headers["Idempotency-Key"].FirstOrDefault();
        
        if (string.IsNullOrEmpty(idempotencyKey))
            return BadRequest("Idempotency-Key header required");
        
        var order = await _idempotentHandler.HandleAsync(
            request,
            idempotencyKey,
            async req => await ProcessOrderAsync(req));
        
        return Ok(order);
    }
}
```

### Rate Limiting Across Instances

Distributed rate limiting using token bucket algorithm:

```csharp
public class DistributedRateLimiter
{
    private readonly IDistributedCache _cache;
    private readonly RateLimitPolicy _policy;
    
    public async Task<bool> AllowRequestAsync(string clientId)
    {
        var key = $"ratelimit:{clientId}";
        var now = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        
        // Atomic increment using Redis Lua script
        var script = @"
            local tokens = redis.call('get', KEYS[1])
            local last_refill = redis.call('get', KEYS[2])
            
            if not tokens then
                tokens = ARGV[1]
                last_refill = ARGV[3]
            end
            
            local elapsed = ARGV[3] - last_refill
            local refill = math.floor(elapsed * ARGV[2])
            tokens = math.min(tonumber(tokens) + refill, tonumber(ARGV[1]))
            
            if tokens >= 1 then
                tokens = tokens - 1
                redis.call('set', KEYS[1], tokens, 'EX', ARGV[4])
                redis.call('set', KEYS[2], ARGV[3], 'EX', ARGV[4])
                return 1
            else
                return 0
            end
        ";
        
        var allowed = await ExecuteLuaScriptAsync(
            script,
            new[] { key, $"{key}:refill" },
            new object[]
            {
                _policy.BucketSize,
                _policy.RefillRate,
                now,
                (int)_policy.Window.TotalSeconds
            });
        
        return allowed == 1;
    }
}

public class RateLimitPolicy
{
    public int BucketSize { get; set; } = 100;
    public double RefillRate { get; set; } = 10.0; // tokens per second
    public TimeSpan Window { get; set; } = TimeSpan.FromMinutes(1);
}
```

### Work Queue Distribution

Competing consumers pattern for horizontal task processing:

```csharp
public class WorkerService : BackgroundService
{
    private readonly IMessageQueue _queue;
    private readonly ITaskProcessor _processor;
    private readonly int _concurrency;
    
    public WorkerService(
        IMessageQueue queue,
        ITaskProcessor processor,
        int concurrency = 10)
    {
        _queue = queue;
        _processor = processor;
        _concurrency = concurrency;
    }
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var semaphore = new SemaphoreSlim(_concurrency);
        var tasks = new List<Task>();
        
        while (!stoppingToken.IsCancellationRequested)
        {
            await semaphore.WaitAsync(stoppingToken);
            
            var task = Task.Run(async () =>
            {
                try
                {
                    var message = await _queue.DequeueAsync(
                        TimeSpan.FromSeconds(30),
                        stoppingToken);
                    
                    if (message != null)
                    {
                        await _processor.ProcessAsync(message, stoppingToken);
                        await _queue.AcknowledgeAsync(message.Id);
                    }
                }
                catch (Exception ex)
                {
                    // Log error, message returns to queue
                }
                finally
                {
                    semaphore.Release();
                }
            }, stoppingToken);
            
            tasks.Add(task);
            
            // Clean completed tasks
            tasks.RemoveAll(t => t.IsCompleted);
        }
        
        await Task.WhenAll(tasks);
    }
}
```

### Anti-Pattern: Instance-Local Scheduling

```csharp
// WRONG: Each instance schedules independently
public class ScheduledTaskService : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            await Task.Delay(TimeSpan.FromHours(1), stoppingToken);
            await ProcessDailyReportAsync(); // Runs N times for N instances
        }
    }
}

// CORRECT: Distributed locking for scheduled tasks
public class DistributedScheduledTaskService : BackgroundService
{
    private readonly IDistributedLockProvider _lockProvider;
    
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            await Task.Delay(TimeSpan.FromHours(1), stoppingToken);
            
            await using (var @lock = await _lockProvider.AcquireLockAsync(
                "daily-report-task",
                TimeSpan.FromMinutes(10),
                stoppingToken))
            {
                if (@lock != null)
                {
                    await ProcessDailyReportAsync(); // Only one instance executes
                }
            }
        }
    }
}
```

### Distributed Locking

Coordinate exclusive operations across instances:

```csharp
public class RedisDistributedLock : IDistributedLock
{
    private readonly IDatabase _redis;
    private readonly string _key;
    private readonly string _lockId;
    private readonly TimeSpan _expiry;
    
    public async Task<bool> AcquireAsync(CancellationToken cancellationToken = default)
    {
        _lockId = Guid.NewGuid().ToString();
        
        return await _redis.StringSetAsync(
            _key,
            _lockId,
            _expiry,
            When.NotExists);
    }
    
    public async Task ReleaseAsync()
    {
        // Lua script ensures only lock owner can release
        var script = @"
            if redis.call('get', KEYS[1]) == ARGV[1] then
                return redis.call('del', KEYS[1])
            else
                return 0
            end
        ";
        
        await _redis.ScriptEvaluateAsync(
            script,
            new RedisKey[] { _key },
            new RedisValue[] { _lockId });
    }
    
    public async Task<bool> RenewAsync()
    {
        var script = @"
            if redis.call('get', KEYS[1]) == ARGV[1] then
                return redis.call('expire', KEYS[1], ARGV[2])
            else
                return 0
            end
        ";
        
        var renewed = await _redis.ScriptEvaluateAsync(
            script,
            new RedisKey[] { _key },
            new RedisValue[] { _lockId, (int)_expiry.TotalSeconds });
        
        return (int)renewed == 1;
    }
}
```

[Inference] Distributed locks introduce coordination overhead and single points of failure. Design systems to minimize lock dependency through partitioning or optimistic concurrency when feasible.

### Database Read Replicas

Offload read traffic to replica instances:

```csharp
public class ReadWriteDbContextFactory
{
    private readonly string _writeConnectionString;
    private readonly IEnumerable<string> _readConnectionStrings;
    private int _readIndex;
    
    public DbContext CreateWriteContext()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseSqlServer(_writeConnectionString)
            .Options;
        
        return new ApplicationDbContext(options);
    }
    
    public DbContext CreateReadContext()
    {
        // Round-robin read replica selection
        var connectionString = _readConnectionStrings
            .Skip(Interlocked.Increment(ref _readIndex) % _readConnectionStrings.Count())
            .First();
        
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseSqlServer(connectionString)
            .Options;
        
        return new ApplicationDbContext(options);
    }
}

public class ProductService
{
    private readonly ReadWriteDbContextFactory _dbFactory;
    
    public async Task<Product> GetProductAsync(int id)
    {
        // Use read replica for queries
        await using var context = _dbFactory.CreateReadContext();
        return await context.Products.FindAsync(id);
    }
    
    public async Task UpdateProductAsync(Product product)
    {
        // Use primary for writes
        await using var context = _dbFactory.CreateWriteContext();
        context.Products.Update(product);
        await context.SaveChangesAsync();
    }
}
```

**Replication Lag Considerations:**

```csharp
public class EventuallyConsistentReadService
{
    private readonly ReadWriteDbContextFactory _dbFactory;
    private readonly IDistributedCache _cache;

    public EventuallyConsistentReadService(
        ReadWriteDbContextFactory dbFactory,
        IDistributedCache cache
    )
    {
        _dbFactory = dbFactory;
        _cache = cache;
    }

    public async Task<Order> GetOrderAfterWriteAsync(int orderId)
    {
        // After write, read from primary for consistency
        var cacheKey = $"order:recent:{orderId}";
        var isRecentWrite = await _cache.GetAsync(cacheKey) != null;

        await using var context = isRecentWrite
            ? _dbFactory.CreateWriteContext() // Read from primary
            : _dbFactory.CreateReadContext(); // Read from replica

        return await context.Orders.FindAsync(orderId);
    }

    public async Task CreateOrderAsync(Order order)
    {
        await using var context = _dbFactory.CreateWriteContext();

        context.Orders.Add(order);
        await context.SaveChangesAsync();

        // Mark as recent write
        var cacheKey = $"order:recent:{order.Id}";
        await _cache.SetAsync(
            cacheKey,
            Array.Empty<byte>(),
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow =
                    TimeSpan.FromSeconds(30) // Expected replication lag
            }
        );
    }
}
```

Related topics: CQRS with horizontal scaling, Event sourcing for distributed state management, Saga pattern for distributed transactions, CAP theorem implications on horizontal scaling, Geo-distributed horizontal scaling with multi-region deployment.

---

## Vertical Scaling Patterns

### Core Vertical Scaling Concepts

Vertical scaling increases system capacity by adding resources (CPU, RAM, disk I/O, network bandwidth) to existing nodes rather than adding more nodes. Effective vertical scaling requires identifying and eliminating bottlenecks in resource utilization.

**Resource Utilization Hierarchy**

1. **CPU-bound**: Computation-intensive operations (cryptography, compression, data transformation)
2. **Memory-bound**: Operations limited by RAM capacity or bandwidth (large in-memory caches, data structures)
3. **I/O-bound**: Disk or network throughput limitations (database queries, file operations)
4. **Lock-bound**: Contention on synchronization primitives (mutex, semaphores)

### CPU Optimization Patterns

**Multi-threading for I/O-Bound Operations**

```python
from concurrent.futures import ThreadPoolExecutor
import threading

class ThreadPooledProcessor:
    """Scale I/O-bound operations across multiple threads."""
    def __init__(self, max_workers=None):
        # Default to 5x CPU count for I/O-bound work
        self.max_workers = max_workers or (os.cpu_count() * 5)
        self.executor = ThreadPoolExecutor(max_workers=self.max_workers)
    
    def process_batch(self, items):
        """Process multiple I/O operations concurrently."""
        futures = [self.executor.submit(self._process_item, item) 
                   for item in items]
        return [future.result() for future in futures]
    
    def _process_item(self, item):
        # I/O operation (database query, HTTP request, file I/O)
        return fetch_data(item)
```

**Multi-processing for CPU-Bound Operations**

```python
from multiprocessing import Pool, cpu_count
import numpy as np

class CPUBoundProcessor:
    """Scale CPU-intensive operations across multiple cores."""
    def __init__(self, workers=None):
        self.workers = workers or cpu_count()
    
    def parallel_compute(self, data_chunks):
        """Distribute computation across CPU cores."""
        with Pool(processes=self.workers) as pool:
            results = pool.map(self._compute_intensive_task, data_chunks)
        return results
    
    @staticmethod
    def _compute_intensive_task(chunk):
        # CPU-intensive operation
        return np.fft.fft(chunk)  # Example: FFT computation
```

**SIMD Vectorization**

[Inference] Leveraging CPU vector instructions through NumPy/libraries compiled with SIMD support can provide significant speedups for numerical operations:

```python
import numpy as np

# Vectorized operations utilize SIMD instructions
def vectorized_computation(data):
    """Process arrays using SIMD-optimized operations."""
    # Single instruction processes multiple data points
    return np.sqrt(data ** 2 + 1) * np.exp(-data / 10)

# ANTI-PATTERN: Scalar operations
def scalar_computation(data):
    return [math.sqrt(x**2 + 1) * math.exp(-x/10) for x in data]
```

**Note:** [Inference] Actual SIMD utilization depends on NumPy's underlying BLAS/LAPACK implementation and CPU capabilities.

### Memory Optimization Patterns

**Object Pool Pattern**

```python
from queue import Queue, Empty
import threading

class ObjectPool:
    """Reuse expensive objects to reduce allocation overhead."""
    def __init__(self, factory, max_size=100):
        self.factory = factory
        self.pool = Queue(maxsize=max_size)
        self.size = 0
        self.max_size = max_size
        self.lock = threading.Lock()
    
    def acquire(self, timeout=None):
        """Get object from pool or create new one."""
        try:
            return self.pool.get(block=True, timeout=timeout)
        except Empty:
            with self.lock:
                if self.size < self.max_size:
                    self.size += 1
                    return self.factory()
            raise RuntimeError("Pool exhausted")
    
    def release(self, obj):
        """Return object to pool."""
        try:
            self.pool.put(obj, block=False)
        except:
            with self.lock:
                self.size -= 1

# Usage
connection_pool = ObjectPool(
    factory=lambda: create_database_connection(),
    max_size=50
)

conn = connection_pool.acquire()
try:
    conn.execute(query)
finally:
    connection_pool.release(conn)
```

**Memory-Mapped Files**

```python
import mmap
import os

class MemoryMappedArray:
    """Access large datasets without loading into RAM."""
    def __init__(self, filepath, shape, dtype=np.float64):
        self.filepath = filepath
        self.shape = shape
        self.dtype = dtype
        self.itemsize = np.dtype(dtype).itemsize
        self.size = np.prod(shape) * self.itemsize
        
        # Create file if doesn't exist
        if not os.path.exists(filepath):
            with open(filepath, 'wb') as f:
                f.seek(self.size - 1)
                f.write(b'\0')
        
        self.file = open(filepath, 'r+b')
        self.mmap = mmap.mmap(self.file.fileno(), 0)
        self.array = np.ndarray(shape, dtype=dtype, buffer=self.mmap)
    
    def __getitem__(self, key):
        return self.array[key]
    
    def __setitem__(self, key, value):
        self.array[key] = value
    
    def flush(self):
        """Persist changes to disk."""
        self.mmap.flush()
    
    def close(self):
        self.mmap.close()
        self.file.close()
```

**Weak References for Caching**

```python
import weakref

class WeakValueCache:
    """Cache that doesn't prevent garbage collection."""
    def __init__(self):
        self._cache = weakref.WeakValueDictionary()
    
    def get(self, key):
        """Retrieve cached value if still alive."""
        return self._cache.get(key)
    
    def set(self, key, value):
        """Cache value with weak reference."""
        self._cache[key] = value
    
    def __len__(self):
        return len(self._cache)
```

**Slots for Memory-Efficient Classes**

```python
class EfficientDataRecord:
    """Reduce memory overhead by 40-50% using __slots__."""
    __slots__ = ['id', 'timestamp', 'value', 'status']
    
    def __init__(self, id, timestamp, value, status):
        self.id = id
        self.timestamp = timestamp
        self.value = value
        self.status = status

# Without __slots__, each instance has __dict__ overhead
# With __slots__, memory usage reduced significantly for large collections
```

### I/O Optimization Patterns

**Asynchronous I/O with asyncio**

```python
import asyncio
import aiofiles

class AsyncIOHandler:
    """Scale I/O operations using async/await."""
    def __init__(self, concurrency_limit=100):
        self.semaphore = asyncio.Semaphore(concurrency_limit)
    
    async def fetch_all(self, urls):
        """Fetch multiple URLs concurrently."""
        tasks = [self.fetch_with_limit(url) for url in urls]
        return await asyncio.gather(*tasks)
    
    async def fetch_with_limit(self, url):
        """Limit concurrent operations with semaphore."""
        async with self.semaphore:
            return await self._fetch(url)
    
    async def _fetch(self, url):
        # Async HTTP request
        async with aiohttp.ClientSession() as session:
            async with session.get(url) as response:
                return await response.text()

# File I/O optimization
async def process_files_async(filepaths):
    """Process multiple files concurrently."""
    tasks = [process_single_file(fp) for fp in filepaths]
    return await asyncio.gather(*tasks)

async def process_single_file(filepath):
    async with aiofiles.open(filepath, mode='r') as f:
        content = await f.read()
        return transform(content)
```

**Buffered I/O**

```python
class BufferedWriter:
    """Batch writes to reduce I/O system calls."""
    def __init__(self, filepath, buffer_size=65536):
        self.filepath = filepath
        self.buffer = []
        self.buffer_size = buffer_size
        self.current_size = 0
        self.file = open(filepath, 'wb', buffering=buffer_size)
    
    def write(self, data):
        """Buffer writes and flush when threshold reached."""
        self.buffer.append(data)
        self.current_size += len(data)
        
        if self.current_size >= self.buffer_size:
            self.flush()
    
    def flush(self):
        """Write buffered data to disk."""
        if self.buffer:
            self.file.write(b''.join(self.buffer))
            self.buffer.clear()
            self.current_size = 0
    
    def close(self):
        self.flush()
        self.file.close()
```

**Direct I/O (Bypassing OS Cache)**

```python
import os

def direct_io_read(filepath, block_size=4096):
    """Read with O_DIRECT flag to bypass page cache."""
    # O_DIRECT requires aligned buffers and sizes
    fd = os.open(filepath, os.O_RDONLY | os.O_DIRECT)
    try:
        while True:
            data = os.read(fd, block_size)
            if not data:
                break
            yield data
    finally:
        os.close(fd)
```

**Note:** [Unverified] O_DIRECT availability and behavior varies by operating system and filesystem.

### Database Connection Pooling

```python
from contextlib import contextmanager
import psycopg2.pool

class DatabaseConnectionPool:
    """Reuse database connections for improved throughput."""
    def __init__(self, minconn=5, maxconn=20, **db_params):
        self.pool = psycopg2.pool.ThreadedConnectionPool(
            minconn=minconn,
            maxconn=maxconn,
            **db_params
        )
    
    @contextmanager
    def get_connection(self):
        """Context manager for connection acquisition."""
        conn = self.pool.getconn()
        try:
            yield conn
        finally:
            self.pool.putconn(conn)
    
    def execute_query(self, query, params=None):
        """Execute query using pooled connection."""
        with self.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(query, params)
                return cursor.fetchall()
    
    def close_all(self):
        """Close all connections in pool."""
        self.pool.closeall()
```

### Caching Strategies

**Multi-Level Cache Hierarchy**

```python
from functools import lru_cache
import redis

class TieredCache:
    """L1 (memory) + L2 (Redis) cache hierarchy."""
    def __init__(self, redis_client, l1_size=1000, ttl=3600):
        self.redis = redis_client
        self.l1_size = l1_size
        self.ttl = ttl
    
    @lru_cache(maxsize=None)
    def _get_l1_cache(self, key):
        """L1 cache using LRU."""
        return self._fetch_from_l2(key)
    
    def _fetch_from_l2(self, key):
        """L2 cache using Redis."""
        value = self.redis.get(key)
        if value is None:
            value = self._compute_value(key)
            self.redis.setex(key, self.ttl, value)
        return value
    
    def get(self, key):
        """Retrieve from L1, fallback to L2, compute if miss."""
        if self._get_l1_cache.cache_info().currsize >= self.l1_size:
            self._get_l1_cache.cache_clear()
        return self._get_l1_cache(key)
    
    def _compute_value(self, key):
        """Expensive computation or database query."""
        return expensive_operation(key)
```

**Write-Through vs Write-Behind Caching**

```python
class WriteThroughCache:
    """Synchronously update cache and backing store."""
    def __init__(self, cache, store):
        self.cache = cache
        self.store = store
    
    def set(self, key, value):
        """Write to both cache and store synchronously."""
        self.store.set(key, value)  # Write to persistent store first
        self.cache.set(key, value)  # Then update cache

class WriteBehindCache:
    """Asynchronously flush cache updates to backing store."""
    def __init__(self, cache, store, flush_interval=60):
        self.cache = cache
        self.store = store
        self.dirty_keys = set()
        self.flush_interval = flush_interval
        self._start_background_flush()
    
    def set(self, key, value):
        """Write to cache immediately, mark for async flush."""
        self.cache.set(key, value)
        self.dirty_keys.add(key)
    
    def _start_background_flush(self):
        """Periodically flush dirty entries to store."""
        def flush_worker():
            while True:
                time.sleep(self.flush_interval)
                self._flush_dirty_entries()
        
        thread = threading.Thread(target=flush_worker, daemon=True)
        thread.start()
    
    def _flush_dirty_entries(self):
        """Batch write dirty entries to persistent store."""
        keys_to_flush = list(self.dirty_keys)
        self.dirty_keys.clear()
        
        for key in keys_to_flush:
            value = self.cache.get(key)
            if value is not None:
                self.store.set(key, value)
```

### Lock-Free Data Structures

**Compare-And-Swap (CAS) Based Counter**

```python
import threading
from ctypes import c_long

class AtomicCounter:
    """Lock-free counter using atomic operations."""
    def __init__(self, initial=0):
        self._value = c_long(initial)
    
    def increment(self, delta=1):
        """Atomically increment counter."""
        while True:
            current = self._value.value
            new_value = current + delta
            # Atomic compare-and-swap
            if threading._CASCompareAndSwap(self._value, current, new_value):
                return new_value
    
    @property
    def value(self):
        return self._value.value
```

**Note:** [Unverified] Python's GIL limits true lock-free performance gains compared to languages with native atomic operations.

**Lock-Free Queue (Single Producer, Single Consumer)**

```python
from collections import deque
import threading

class SPSCQueue:
    """Lock-free queue for single producer/consumer."""
    def __init__(self, maxsize=1000):
        self._queue = deque(maxlen=maxsize)
        self._read_pos = 0
        self._write_pos = 0
    
    def enqueue(self, item):
        """Producer enqueues item (single thread only)."""
        if len(self._queue) >= self._queue.maxlen:
            return False
        self._queue.append(item)
        self._write_pos += 1
        return True
    
    def dequeue(self):
        """Consumer dequeues item (single thread only)."""
        if self._read_pos >= self._write_pos:
            return None
        item = self._queue[self._read_pos % self._queue.maxlen]
        self._read_pos += 1
        return item
```

### Read-Write Locks

```python
import threading

class ReadWriteLock:
    """Allow multiple concurrent readers or single writer."""
    def __init__(self):
        self._readers = 0
        self._writers = 0
        self._read_ready = threading.Condition(threading.Lock())
        self._write_ready = threading.Condition(threading.Lock())
    
    def acquire_read(self):
        """Acquire read lock (multiple readers allowed)."""
        with self._read_ready:
            while self._writers > 0:
                self._read_ready.wait()
            self._readers += 1
    
    def release_read(self):
        """Release read lock."""
        with self._read_ready:
            self._readers -= 1
            if self._readers == 0:
                self._write_ready.notify_all()
    
    def acquire_write(self):
        """Acquire write lock (exclusive access)."""
        with self._write_ready:
            while self._writers > 0 or self._readers > 0:
                self._write_ready.wait()
            self._writers += 1
    
    def release_write(self):
        """Release write lock."""
        with self._write_ready:
            self._writers -= 1
            self._write_ready.notify_all()
            self._read_ready.notify_all()

# Usage
class CachedData:
    def __init__(self):
        self._data = {}
        self._lock = ReadWriteLock()
    
    def read(self, key):
        self._lock.acquire_read()
        try:
            return self._data.get(key)
        finally:
            self._lock.release_read()
    
    def write(self, key, value):
        self._lock.acquire_write()
        try:
            self._data[key] = value
        finally:
            self._lock.release_write()
```

### JIT Compilation Optimization

**PyPy for Computation-Intensive Code**

[Unverified] PyPy's JIT compiler can provide significant speedups for pure Python computational code:

```python
# Code that benefits from JIT compilation:
# - Loops with many iterations
# - Numeric computations
# - Recursive algorithms

def fibonacci_recursive(n):
    """JIT-friendly recursive implementation."""
    if n <= 1:
        return n
    return fibonacci_recursive(n-1) + fibonacci_recursive(n-2)

# Run with PyPy instead of CPython for potential speedup
```

**Numba JIT Compilation**

```python
from numba import jit, prange
import numpy as np

@jit(nopython=True, parallel=True)
def parallel_computation(data):
    """Compile to machine code with automatic parallelization."""
    result = np.zeros_like(data)
    for i in prange(len(data)):
        result[i] = complex_calculation(data[i])
    return result

@jit(nopython=True)
def complex_calculation(x):
    """Compiled function for numerical computation."""
    total = 0.0
    for i in range(1000):
        total += np.sqrt(x ** 2 + i) * np.exp(-i / 100.0)
    return total
```

### Memory Allocation Optimization

**Pre-allocation of Data Structures**

```python
import numpy as np

class PreallocatedBuffer:
    """Reduce allocation overhead by reusing buffers."""
    def __init__(self, buffer_size, dtype=np.float64):
        self.buffer = np.zeros(buffer_size, dtype=dtype)
        self.position = 0
    
    def append(self, data):
        """Append to pre-allocated buffer."""
        data_len = len(data)
        if self.position + data_len > len(self.buffer):
            # Grow buffer (expensive operation, minimize frequency)
            new_size = max(len(self.buffer) * 2, self.position + data_len)
            new_buffer = np.zeros(new_size, dtype=self.buffer.dtype)
            new_buffer[:self.position] = self.buffer[:self.position]
            self.buffer = new_buffer
        
        self.buffer[self.position:self.position + data_len] = data
        self.position += data_len
    
    def get_data(self):
        """Return valid data portion."""
        return self.buffer[:self.position]
```

**String Building Optimization**

```python
# ANTI-PATTERN: String concatenation in loop
def build_string_slow(items):
    result = ""
    for item in items:
        result += str(item) + ","  # Creates new string each iteration
    return result

# CORRECT: Use list and join
def build_string_fast(items):
    parts = []
    for item in items:
        parts.append(str(item))
    return ",".join(parts)  # Single allocation

# CORRECT: Use io.StringIO for complex building
from io import StringIO

def build_string_complex(items):
    buffer = StringIO()
    for item in items:
        buffer.write(str(item))
        buffer.write(",")
    return buffer.getvalue()
```

### Profiling-Guided Optimization

**CPU Profiling**

```python
import cProfile
import pstats
from pstats import SortKey

def profile_function(func, *args, **kwargs):
    """Profile function execution to identify bottlenecks."""
    profiler = cProfile.Profile()
    profiler.enable()
    
    result = func(*args, **kwargs)
    
    profiler.disable()
    stats = pstats.Stats(profiler)
    stats.sort_stats(SortKey.CUMULATIVE)
    stats.print_stats(20)  # Top 20 functions
    
    return result
```

**Memory Profiling**

```python
from memory_profiler import profile

@profile
def memory_intensive_function():
    """Decorator profiles memory usage line-by-line."""
    large_list = [i for i in range(10000000)]
    processed = [x * 2 for x in large_list]
    return sum(processed)
```

### Vertical Scaling Anti-Patterns

**Unbounded Thread Pool Growth**

```python
# ANTI-PATTERN: Creating unlimited threads
def process_requests_bad(requests):
    threads = []
    for request in requests:
        thread = threading.Thread(target=process_request, args=(request,))
        threads.append(thread)
        thread.start()  # May create thousands of threads
    for thread in threads:
        thread.join()

# CORRECT: Bounded thread pool
def process_requests_good(requests):
    with ThreadPoolExecutor(max_workers=50) as executor:
        executor.map(process_request, requests)
```

**Global Interpreter Lock (GIL) Contention**

```python
# ANTI-PATTERN: CPU-bound work in threads (GIL bottleneck)
def parallel_cpu_work_bad(data_chunks):
    with ThreadPoolExecutor() as executor:
        return list(executor.map(cpu_intensive_task, data_chunks))

# CORRECT: Use multiprocessing for CPU-bound work
def parallel_cpu_work_good(data_chunks):
    with Pool() as pool:
        return pool.map(cpu_intensive_task, data_chunks)
```

**Excessive Locking Granularity**

```python
# ANTI-PATTERN: Single global lock
class SharedData:
    def __init__(self):
        self._data = {}
        self._lock = threading.Lock()
    
    def update(self, key, value):
        with self._lock:  # Locks entire data structure
            self._data[key] = value

# CORRECT: Fine-grained locking
class SharedDataOptimized:
    def __init__(self, num_shards=16):
        self._shards = [{'data': {}, 'lock': threading.Lock()} 
                        for _ in range(num_shards)]
        self._num_shards = num_shards
    
    def _get_shard(self, key):
        return self._shards[hash(key) % self._num_shards]
    
    def update(self, key, value):
        shard = self._get_shard(key)
        with shard['lock']:  # Only locks relevant shard
            shard['data'][key] = value
```

**Related Topics:** NUMA-aware memory allocation, CPU affinity and pinning strategies, Huge pages for memory optimization, io_uring for async I/O, DPDK for network I/O bypass, Cache coherency protocols (MESI), False sharing in multi-core systems, Copy-on-write optimization, Memory bandwidth optimization techniques, Compiler optimization flags and PGO

---

## Load Balancing

A scalability pattern that distributes incoming requests, computational workload, or data processing tasks across multiple resources to optimize throughput, minimize response time, prevent resource overutilization, and ensure fault tolerance. Critical for horizontal scaling where system capacity grows by adding instances rather than upgrading individual components.

### Distribution Algorithms

**Round Robin**

```java
public class RoundRobinBalancer<T> {
    private final List<T> resources;
    private final AtomicInteger counter = new AtomicInteger(0);
    
    public T next() {
        if (resources.isEmpty()) {
            throw new NoAvailableResourceException();
        }
        
        int index = Math.abs(counter.getAndIncrement() % resources.size());
        return resources.get(index);
    }
}
```

Distributes requests sequentially across resources in circular order. Provides uniform distribution assuming homogeneous resources and request processing time. Fails to account for varying resource capacity or current load. The modulo operation with `Math.abs` prevents negative indices from integer overflow.

**Weighted Round Robin**

```java
public class WeightedRoundRobinBalancer<T> {
    private final List<WeightedResource<T>> resources;
    private final AtomicInteger currentIndex = new AtomicInteger(0);
    private final AtomicInteger currentWeight = new AtomicInteger(0);
    private final int maxWeight;
    private final int gcd;
    
    public WeightedRoundRobinBalancer(List<WeightedResource<T>> resources) {
        this.resources = resources;
        this.maxWeight = resources.stream()
            .mapToInt(WeightedResource::getWeight)
            .max()
            .orElse(1);
        this.gcd = computeGCD(resources.stream()
            .mapToInt(WeightedResource::getWeight)
            .toArray());
    }
    
    public T next() {
        while (true) {
            int index = currentIndex.get();
            int weight = currentWeight.addAndGet(-gcd);
            
            if (weight <= 0) {
                currentIndex.set((index + 1) % resources.size());
                weight = maxWeight + currentWeight.get();
                currentWeight.set(weight);
                
                if (currentIndex.get() == 0 && weight <= 0) {
                    currentWeight.set(maxWeight);
                    weight = maxWeight;
                }
            }
            
            if (resources.get(currentIndex.get()).getWeight() >= weight) {
                return resources.get(currentIndex.get()).getResource();
            }
        }
    }
}
```

Distributes requests proportionally to assigned weights, accommodating heterogeneous resource capacity. The GCD optimization reduces iteration count when weights share common factors. [Inference] Smooth weighted round robin (SWRR) variants prevent burst allocation to high-weight resources by interleaving selections.

**Least Connections**

```java
public class LeastConnectionsBalancer<T> {
    private final ConcurrentMap<T, AtomicInteger> connections = new ConcurrentHashMap<>();
    private final List<T> resources;
    
    public T acquire() {
        return resources.stream()
            .min(Comparator.comparingInt(r -> 
                connections.computeIfAbsent(r, k -> new AtomicInteger(0)).get()
            ))
            .map(resource -> {
                connections.get(resource).incrementAndGet();
                return resource;
            })
            .orElseThrow(NoAvailableResourceException::new);
    }
    
    public void release(T resource) {
        connections.computeIfPresent(resource, (k, count) -> {
            count.decrementAndGet();
            return count;
        });
    }
}
```

Routes requests to resources with fewest active connections. Optimal for long-lived connections with variable processing time. Requires connection lifecycle tracking and synchronized state updates. [Inference] Susceptible to thundering herd when multiple requests simultaneously observe identical minimum connection counts.

**Weighted Least Connections**

```java
public class WeightedLeastConnectionsBalancer<T> {
    private final ConcurrentMap<T, ResourceMetrics> metrics = new ConcurrentHashMap<>();
    
    static class ResourceMetrics {
        final int weight;
        final AtomicInteger connections;
        
        ResourceMetrics(int weight) {
            this.weight = weight;
            this.connections = new AtomicInteger(0);
        }
        
        double getLoadRatio() {
            return (double) connections.get() / weight;
        }
    }
    
    public T acquire() {
        return metrics.entrySet().stream()
            .min(Comparator.comparingDouble(e -> e.getValue().getLoadRatio()))
            .map(Map.Entry::getKey)
            .map(resource -> {
                metrics.get(resource).connections.incrementAndGet();
                return resource;
            })
            .orElseThrow(NoAvailableResourceException::new);
    }
}
```

Normalizes connection count by resource capacity. Load ratio `connections/weight` provides fair distribution across heterogeneous resources. Higher-capacity resources accept proportionally more connections.

**Least Response Time**

```java
public class LeastResponseTimeBalancer<T> {
    private final ConcurrentMap<T, ResponseTimeTracker> trackers = new ConcurrentHashMap<>();
    
    static class ResponseTimeTracker {
        private final AtomicInteger activeConnections = new AtomicInteger(0);
        private final LongAdder totalResponseTime = new LongAdder();
        private final LongAdder completedRequests = new LongAdder();
        
        double getAverageResponseTime() {
            long completed = completedRequests.sum();
            return completed == 0 ? 0 : (double) totalResponseTime.sum() / completed;
        }
        
        double getScore() {
            return activeConnections.get() * (1 + getAverageResponseTime());
        }
    }
    
    public T acquire() {
        return trackers.entrySet().stream()
            .min(Comparator.comparingDouble(e -> e.getValue().getScore()))
            .map(Map.Entry::getKey)
            .map(resource -> {
                trackers.get(resource).activeConnections.incrementAndGet();
                return resource;
            })
            .orElseThrow(NoAvailableResourceException::new);
    }
    
    public void recordCompletion(T resource, long responseTimeMs) {
        ResponseTimeTracker tracker = trackers.get(resource);
        tracker.activeConnections.decrementAndGet();
        tracker.totalResponseTime.add(responseTimeMs);
        tracker.completedRequests.increment();
    }
}
```

Combines active connections with historical response time. Score formula balances immediate load with observed performance characteristics. [Inference] Exponentially weighted moving average (EWMA) for response time provides better adaptation to changing conditions than simple averaging.

**Hash-Based (Consistent Hashing)**

```java
public class ConsistentHashBalancer<T> {
    private final TreeMap<Integer, T> ring = new TreeMap<>();
    private final int virtualNodes;
    private final HashFunction hashFunction;
    
    public ConsistentHashBalancer(List<T> resources, int virtualNodes) {
        this.virtualNodes = virtualNodes;
        this.hashFunction = Hashing.murmur3_128();
        
        for (T resource : resources) {
            addResource(resource);
        }
    }
    
    public void addResource(T resource) {
        for (int i = 0; i < virtualNodes; i++) {
            String virtualKey = resource.toString() + "#" + i;
            int hash = hashFunction.hashString(virtualKey, StandardCharsets.UTF_8)
                .asInt();
            ring.put(hash, resource);
        }
    }
    
    public T getResource(String key) {
        if (ring.isEmpty()) {
            throw new NoAvailableResourceException();
        }
        
        int hash = hashFunction.hashString(key, StandardCharsets.UTF_8).asInt();
        Map.Entry<Integer, T> entry = ring.ceilingEntry(hash);
        
        return entry != null ? entry.getValue() : ring.firstEntry().getValue();
    }
    
    public void removeResource(T resource) {
        for (int i = 0; i < virtualNodes; i++) {
            String virtualKey = resource.toString() + "#" + i;
            int hash = hashFunction.hashString(virtualKey, StandardCharsets.UTF_8)
                .asInt();
            ring.remove(hash);
        }
    }
}
```

Maps requests to resources based on hash of request key (session ID, user ID, etc.). Ensures same key always routes to same resource, critical for session affinity and cache locality. Virtual nodes distribute load more evenly and minimize redistribution when resources are added/removed. [Inference] Standard deviation of load decreases proportionally to √(virtual nodes).

**Rendezvous Hashing (Highest Random Weight)**

```java
public class RendezvousHashBalancer<T> {
    private final List<T> resources;
    private final HashFunction hashFunction;
    
    public T getResource(String key) {
        return resources.stream()
            .max(Comparator.comparingLong(resource -> 
                computeWeight(key, resource)
            ))
            .orElseThrow(NoAvailableResourceException::new);
    }
    
    private long computeWeight(String key, T resource) {
        String combined = key + resource.toString();
        return hashFunction.hashString(combined, StandardCharsets.UTF_8)
            .asLong();
    }
}
```

Alternative to consistent hashing that avoids ring data structure. Each request-resource pair generates a weight; request routes to highest-weight resource. Adding/removing resources only affects requests that previously mapped to changed resources. [Inference] Simpler implementation than consistent hashing with similar redistribution properties.

### Dynamic Load Awareness

**Adaptive Load Balancing**

```java
public class AdaptiveLoadBalancer<T> {
    private final ConcurrentMap<T, ResourceHealth> healthMetrics = new ConcurrentHashMap<>();
    private final ScheduledExecutorService healthChecker;
    
    static class ResourceHealth {
        volatile double cpuUsage;
        volatile double memoryUsage;
        volatile long activeRequests;
        volatile long errorRate;
        volatile boolean healthy = true;
        
        double computeScore() {
            if (!healthy) return Double.MAX_VALUE;
            
            return (cpuUsage * 0.3) + 
                   (memoryUsage * 0.2) + 
                   (activeRequests * 0.3) + 
                   (errorRate * 0.2);
        }
    }
    
    public AdaptiveLoadBalancer(List<T> resources) {
        resources.forEach(r -> healthMetrics.put(r, new ResourceHealth()));
        
        healthChecker = Executors.newScheduledThreadPool(1);
        healthChecker.scheduleAtFixedRate(
            this::updateHealthMetrics, 0, 5, TimeUnit.SECONDS
        );
    }
    
    public T next() {
        return healthMetrics.entrySet().stream()
            .min(Comparator.comparingDouble(e -> e.getValue().computeScore()))
            .map(Map.Entry::getKey)
            .orElseThrow(NoAvailableResourceException::new);
    }
    
    private void updateHealthMetrics() {
        healthMetrics.forEach((resource, health) -> {
            try {
                ResourceStats stats = queryResourceStats(resource);
                health.cpuUsage = stats.getCpuUsage();
                health.memoryUsage = stats.getMemoryUsage();
                health.activeRequests = stats.getActiveRequests();
                health.errorRate = stats.getErrorRate();
                health.healthy = stats.isHealthy();
            } catch (Exception e) {
                health.healthy = false;
            }
        });
    }
}
```

Periodically queries resource metrics to inform routing decisions. Composite score combines multiple dimensions (CPU, memory, active requests, errors). Weight coefficients tunable based on workload characteristics. [Unverified] Health check interval balances freshness against monitoring overhead; typical values range 1-30 seconds.

**Circuit Breaker Integration**

```java
public class CircuitBreakerLoadBalancer<T> {
    private final ConcurrentMap<T, CircuitBreaker> breakers = new ConcurrentHashMap<>();
    private final List<T> resources;
    
    static class CircuitBreaker {
        enum State { CLOSED, OPEN, HALF_OPEN }
        
        private volatile State state = State.CLOSED;
        private final AtomicInteger failureCount = new AtomicInteger(0);
        private final AtomicInteger successCount = new AtomicInteger(0);
        private volatile Instant openedAt;
        
        private static final int FAILURE_THRESHOLD = 5;
        private static final int SUCCESS_THRESHOLD = 2;
        private static final Duration TIMEOUT = Duration.ofSeconds(60);
        
        boolean allowRequest() {
            State currentState = state;
            
            if (currentState == State.CLOSED) {
                return true;
            } else if (currentState == State.OPEN) {
                if (Duration.between(openedAt, Instant.now()).compareTo(TIMEOUT) > 0) {
                    state = State.HALF_OPEN;
                    return true;
                }
                return false;
            } else { // HALF_OPEN
                return true;
            }
        }
        
        void recordSuccess() {
            if (state == State.HALF_OPEN) {
                if (successCount.incrementAndGet() >= SUCCESS_THRESHOLD) {
                    state = State.CLOSED;
                    failureCount.set(0);
                    successCount.set(0);
                }
            } else {
                failureCount.set(0);
            }
        }
        
        void recordFailure() {
            int failures = failureCount.incrementAndGet();
            
            if (failures >= FAILURE_THRESHOLD) {
                state = State.OPEN;
                openedAt = Instant.now();
                successCount.set(0);
            }
        }
    }
    
    public T next() {
        return resources.stream()
            .filter(r -> breakers.computeIfAbsent(r, k -> new CircuitBreaker())
                .allowRequest())
            .findFirst()
            .orElseThrow(() -> new AllResourcesUnavailableException());
    }
    
    public void recordOutcome(T resource, boolean success) {
        CircuitBreaker breaker = breakers.get(resource);
        if (success) {
            breaker.recordSuccess();
        } else {
            breaker.recordFailure();
        }
    }
}
```

Prevents cascading failures by temporarily removing unhealthy resources from rotation. Three-state model: CLOSED (normal), OPEN (failing, requests blocked), HALF_OPEN (testing recovery). Configurable thresholds and timeout periods adapt to failure characteristics.

**Power of Two Choices**

```java
public class PowerOfTwoBalancer<T> {
    private final List<T> resources;
    private final ConcurrentMap<T, AtomicInteger> loads = new ConcurrentHashMap<>();
    private final Random random = ThreadLocalRandom.current();
    
    public T next() {
        if (resources.size() <= 2) {
            return resources.get(random.nextInt(resources.size()));
        }
        
        int idx1 = random.nextInt(resources.size());
        int idx2 = random.nextInt(resources.size());
        while (idx2 == idx1) {
            idx2 = random.nextInt(resources.size());
        }
        
        T resource1 = resources.get(idx1);
        T resource2 = resources.get(idx2);
        
        int load1 = loads.computeIfAbsent(resource1, k -> new AtomicInteger(0)).get();
        int load2 = loads.computeIfAbsent(resource2, k -> new AtomicInteger(0)).get();
        
        T selected = load1 <= load2 ? resource1 : resource2;
        loads.get(selected).incrementAndGet();
        
        return selected;
    }
    
    public void release(T resource) {
        loads.computeIfPresent(resource, (k, load) -> {
            load.decrementAndGet();
            return load;
        });
    }
}
```

[Inference] Probabilistic algorithm that achieves near-optimal load distribution with O(1) complexity. Randomly samples two resources and selects the less-loaded. Reduces maximum load exponentially compared to pure random selection (θ(log log n) vs θ(log n)).

### Network Layer Load Balancing

**Layer 4 (Transport Layer)**

```java
public class L4LoadBalancer {
    private final List<InetSocketAddress> backends;
    private final Selector selector;
    
    public void start(int listenPort) throws IOException {
        ServerSocketChannel serverChannel = ServerSocketChannel.open();
        serverChannel.bind(new InetSocketAddress(listenPort));
        serverChannel.configureBlocking(false);
        
        selector = Selector.open();
        serverChannel.register(selector, SelectionKey.OP_ACCEPT);
        
        while (true) {
            selector.select();
            Iterator<SelectionKey> keys = selector.selectedKeys().iterator();
            
            while (keys.hasNext()) {
                SelectionKey key = keys.next();
                keys.remove();
                
                if (key.isAcceptable()) {
                    accept(serverChannel);
                } else if (key.isReadable()) {
                    forward(key);
                }
            }
        }
    }
    
    private void accept(ServerSocketChannel serverChannel) throws IOException {
        SocketChannel clientChannel = serverChannel.accept();
        clientChannel.configureBlocking(false);
        
        InetSocketAddress backend = selectBackend();
        SocketChannel backendChannel = SocketChannel.open(backend);
        backendChannel.configureBlocking(false);
        
        // Register for bidirectional forwarding
        clientChannel.register(selector, SelectionKey.OP_READ, backendChannel);
        backendChannel.register(selector, SelectionKey.OP_READ, clientChannel);
    }
    
    private void forward(SelectionKey key) throws IOException {
        SocketChannel source = (SocketChannel) key.channel();
        SocketChannel destination = (SocketChannel) key.attachment();
        
        ByteBuffer buffer = ByteBuffer.allocate(8192);
        int bytesRead = source.read(buffer);
        
        if (bytesRead == -1) {
            source.close();
            destination.close();
            return;
        }
        
        buffer.flip();
        destination.write(buffer);
    }
}
```

Operates at TCP/UDP level without parsing application protocols. Low latency and high throughput due to minimal processing. Maintains connection state but cannot inspect payload for routing decisions. Session persistence via source IP hashing or connection tracking.

**Layer 7 (Application Layer)**

```java
public class L7LoadBalancer {
    private final HttpClient httpClient = HttpClient.newHttpClient();
    
    public void handleRequest(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        // Parse application-level data
        String path = request.getRequestURI();
        String sessionId = extractSessionId(request);
        
        // Route based on application logic
        URI backend = selectBackend(path, sessionId);
        
        // Forward request
        HttpRequest proxyRequest = HttpRequest.newBuilder()
            .uri(backend.resolve(path))
            .method(request.getMethod(), bodyPublisher(request))
            .headers(copyHeaders(request))
            .build();
        
        HttpResponse<InputStream> backendResponse = httpClient.send(
            proxyRequest, HttpResponse.BodyHandlers.ofInputStream()
        );
        
        // Return response
        response.setStatus(backendResponse.statusCode());
        backendResponse.headers().map().forEach((name, values) -> 
            values.forEach(value -> response.addHeader(name, value))
        );
        
        try (InputStream body = backendResponse.body()) {
            body.transferTo(response.getOutputStream());
        }
    }
    
    private URI selectBackend(String path, String sessionId) {
        if (sessionId != null) {
            // Session affinity
            return getBackendBySession(sessionId);
        }
        
        if (path.startsWith("/api/")) {
            // Path-based routing
            return getApiBackend();
        }
        
        // Default routing
        return getDefaultBackend();
    }
}
```

Full protocol awareness enables content-based routing, SSL termination, request modification, and caching. Higher CPU cost due to parsing HTTP headers/bodies. Supports sophisticated routing rules (path patterns, header matching, weighted splits for canary deployments).

### Health Checking and Failover

**Active Health Checks**

```java
public class HealthCheckManager<T> {
    private final ConcurrentMap<T, HealthStatus> healthStatus = new ConcurrentHashMap<>();
    private final ScheduledExecutorService scheduler = 
        Executors.newScheduledThreadPool(4);
    
    static class HealthStatus {
        volatile boolean healthy = true;
        volatile Instant lastCheck;
        final AtomicInteger consecutiveFailures = new AtomicInteger(0);
        final AtomicInteger consecutiveSuccesses = new AtomicInteger(0);
    }
    
    public void startMonitoring(List<T> resources) {
        resources.forEach(resource -> {
            healthStatus.put(resource, new HealthStatus());
            
            scheduler.scheduleAtFixedRate(
                () -> performHealthCheck(resource),
                0, 10, TimeUnit.SECONDS
            );
        });
    }
    
    private void performHealthCheck(T resource) {
        HealthStatus status = healthStatus.get(resource);
        
        try {
            boolean checkPassed = executeHealthCheck(resource);
            status.lastCheck = Instant.now();
            
            if (checkPassed) {
                int successes = status.consecutiveSuccesses.incrementAndGet();
                status.consecutiveFailures.set(0);
                
                if (!status.healthy && successes >= 3) {
                    status.healthy = true;
                    logResourceRecovered(resource);
                }
            } else {
                handleHealthCheckFailure(resource, status);
            }
        } catch (Exception e) {
            handleHealthCheckFailure(resource, status);
        }
    }
    
    private void handleHealthCheckFailure(T resource, HealthStatus status) {
        int failures = status.consecutiveFailures.incrementAndGet();
        status.consecutiveSuccesses.set(0);
        
        if (status.healthy && failures >= 2) {
            status.healthy = false;
            logResourceFailed(resource);
        }
    }
    
    public boolean isHealthy(T resource) {
        HealthStatus status = healthStatus.get(resource);
        return status != null && status.healthy;
    }
}
```

Periodic probes verify resource availability independently of traffic. Consecutive failure/success thresholds prevent flapping from transient errors. Health check types: TCP connection, HTTP endpoint, custom protocol validation.

**Passive Health Checks**

```java
public class PassiveHealthMonitor<T> {
    private final ConcurrentMap<T, ErrorTracker> errorTrackers = new ConcurrentHashMap<>();
    
    static class ErrorTracker {
        private final RingBuffer<Boolean> recentRequests = new RingBuffer<>(100);
        private final AtomicInteger totalRequests = new AtomicInteger(0);
        private final AtomicInteger errorCount = new AtomicInteger(0);
        
        void recordRequest(boolean success) {
            Boolean evicted = recentRequests.add(success);
            if (evicted != null && !evicted) {
                errorCount.decrementAndGet();
            }
            
            totalRequests.incrementAndGet();
            if (!success) {
                errorCount.incrementAndGet();
            }
        }
        
        double getErrorRate() {
            int total = Math.min(totalRequests.get(), recentRequests.capacity());
            return total == 0 ? 0 : (double) errorCount.get() / total;
        }
    }
    
    public void recordOutcome(T resource, boolean success) {
        errorTrackers.computeIfAbsent(resource, k -> new ErrorTracker())
            .recordRequest(success);
    }
    
    public boolean shouldQuarantine(T resource) {
        ErrorTracker tracker = errorTrackers.get(resource);
        if (tracker == null) return false;
        
        return tracker.getErrorRate() > 0.5 && 
               tracker.totalRequests.get() >= 20;
    }
}
```

Monitors production traffic outcomes to detect failures. Lower overhead than active checks but slower detection since it requires traffic to flow. Sliding window of recent requests provides temporal error rate. Combines with active health checks for comprehensive monitoring.

**Graceful Degradation**

```java
public class GracefulDegradationBalancer<T> {
    private final List<T> primaryResources;
    private final List<T> fallbackResources;
    private final HealthCheckManager<T> healthChecker;
    
    public T next() {
        List<T> healthyPrimary = primaryResources.stream()
            .filter(healthChecker::isHealthy)
            .collect(Collectors.toList());
        
        if (!healthyPrimary.isEmpty()) {
            return selectRoundRobin(healthyPrimary);
        }
        
        // Fallback to degraded resources
        List<T> healthyFallback = fallbackResources.stream()
            .filter(healthChecker::isHealthy)
            .collect(Collectors.toList());
        
        if (!healthyFallback.isEmpty()) {
            logDegradedMode();
            return selectRoundRobin(healthyFallback);
        }
        
        throw new AllResourcesUnavailableException();
    }
}
```

Multi-tier resource pools enable continued operation during partial failures. Primary resources handle normal load; fallback resources (potentially lower capacity or higher latency) activate when primary fails. Alternative: reduced functionality mode where non-critical features disable.

### Anti-Patterns

**Ignoring Resource Heterogeneity**

```java
// INEFFICIENT - Uniform distribution to non-uniform resources
public class NaiveBalancer {
    public Server next() {
        // Server A: 32 cores, 128GB RAM
        // Server B: 4 cores, 16GB RAM
        // Both receive 50% of traffic
        return servers.get(requestCount++ % servers.size());
    }
}
```

Round-robin assumes identical capacity. Heterogeneous environments require weighted algorithms proportional to resource capability. Alternatively, resource-based auto-scaling normalizes capacity.

**Sticky Session Imbalance**

```java
// PROBLEMATIC - Session affinity without rebalancing
public class StickySessionBalancer {
    private final Map<String, Server> sessions = new ConcurrentHashMap<>();
    
    public Server getServer(String sessionId) {
        return sessions.computeIfAbsent(sessionId, sid -> {
            // Initial assignment fine, but long-lived sessions accumulate
            return selectLeastLoaded();
        });
        // Sessions never rebalance even if server becomes overloaded
    }
}
```

Session affinity (sticky sessions) concentrates long-lived sessions on subset of resources. Solution: bounded session lifetime, session migration on extreme imbalance, or consistent hashing that redistributes only affected sessions when capacity changes.

**Thundering Herd on Health Recovery**

```java
// PROBLEMATIC - All traffic immediately shifts to recovered resource
public class AbruptRecoveryBalancer {
    public Server next() {
        List<Server> healthy = servers.stream()
            .filter(Server::isHealthy)
            .collect(Collectors.toList());
        
        // Recovered server immediately receives full share
        // May overwhelm during warmup period
        return selectRandom(healthy);
    }
}
```

Immediately routing full traffic share to newly recovered resources may trigger immediate re-failure during cache warmup or connection pool initialization. Solution: gradual traffic increase (5% → 25% → 50% → 100%) over recovery window.

**Global State Synchronization Bottleneck**

```java
// INEFFICIENT - Synchronized access on every request
public class SynchronizedBalancer {
    private int currentIndex = 0;
    
    public synchronized Server next() {
        // Single lock serializes all routing decisions
        Server server = servers.get(currentIndex);
        currentIndex = (currentIndex + 1) % servers.size();
        return server;
    }
}
```

Coarse-grained locking on hot path limits throughput. Atomic operations (`AtomicInteger`) provide lock-free coordination. For read-heavy scenarios, copy-on-write collections amortize update costs.

### Advanced Patterns

**Least Loaded with Bounded Queue**

```java
public class BoundedQueueBalancer<T> {
    private final ConcurrentMap<T, BoundedQueue<Request>> queues = 
        new ConcurrentHashMap<>();
    private final int maxQueueSize;
    
    static class BoundedQueue<R> {
        private final Queue<R> queue = new ConcurrentLinkedQueue<>();
        private final AtomicInteger size = new AtomicInteger(0);
        private final int capacity;
        
        boolean offer(R request) {
            if (size.get() >= capacity) {
                return false;
            }
            
            if (queue.offer(request)) {
                size.incrementAndGet();
                return true;
            }
            
            return false;
        }
        
        R poll() {
            R request = queue.poll();
            if (request != null) {
                size.decrementAndGet();
            }
            return request;
        }
        
        int size() {
            return size.get();
        }
    }
    
    public boolean submit(Request request) {
        return queues.entrySet().stream()
            .min(Comparator.comparingInt(e -> e.getValue().size()))
            .map(Map.Entry::getValue)
            .map(queue -> queue.offer(request))
            .orElse(false);
    }
}
```

Per-resource queues with size limits prevent cascading overload. Requests rejected when all queues full, providing explicit backpressure. Queue depth indicates resource saturation; monitoring queue sizes informs capacity planning.

**Geographic Load Balancing**

```java
public class GeographicLoadBalancer {
    private final Map<Region, LoadBalancer<Server>> regionalBalancers;
    
    public Server route(Request request) {
        Region region = determineClientRegion(request);
        LoadBalancer<Server> regionalBalancer = regionalBalancers.get(region);
        
        if (regionalBalancer.hasHealthyServers()) {
            return regionalBalancer.next();
        }
        
        // Failover to adjacent regions
        return findNearestHealthyRegion(region)
            .map(nearbyRegion -> regionalBalancers.get(nearbyRegion).next())
            .orElseThrow(AllResourcesUnavailableException::new);
    }
    
    private Region determineClientRegion(Request request) {
        String clientIp = request.getClientIp();
        GeoLocation location = geoIpDatabase.lookup(clientIp);
        return location.closestRegion();
    }
}
```

Routes traffic to geographically proximate resources, minimizing network latency. Multi-region deployment with cross-region failover provides disaster recovery. DNS-based geographic routing (GeoDNS) operates at lower layer but cannot perform application-aware health checks.

**Request Splitting for Tail Latency**

```java
public class HedgedRequestBalancer<T> {

    private final ExecutorService executor =
        Executors.newCachedThreadPool();

    private final Duration hedgingDelay =
        Duration.ofMillis(50);

    public CompletableFuture<Response> execute(Request request) {

        CompletableFuture<Response> primary =
            sendRequest(selectResource(), request);

        CompletableFuture<Response> hedged =
            primary.completeOnTimeout(
                    null,
                    hedgingDelay.toMillis(),
                    TimeUnit.MILLISECONDS
                )
                .thenCompose(response -> {
                    if (response == null) {
                        // Primary hasn't completed, send hedged request
                        return sendRequest(
                            selectResource(),
                            request
                        );
                    }
                    return CompletableFuture.completedFuture(response);
                });

        return CompletableFuture.anyOf(primary, hedged)
            .thenApply(result -> (Response) result);
    }
}
````

[Inference] Sends duplicate requests after timeout threshold to reduce tail latency. First response wins; duplicate canceled. Increases resource utilization but significantly improves P99 latency in systems with high variance. Requires idempotent operations.

**Adaptive Concurrency Limiting**

```java
public class AdaptiveConcurrencyBalancer<T> {
    private final ConcurrentMap<T, AdaptiveLimiter> limiters = new ConcurrentHashMap<>();
    
    static class AdaptiveLimiter {
        private final AtomicInteger inFlight = new AtomicInteger(0);
        private final AtomicInteger limit = new AtomicInteger(100);
        private final EWMA latency = new EWMA(0.2);
        
        boolean tryAcquire() {
            int current = inFlight.get();
            if (current >= limit.get()) {
                return false;
            }
            return inFlight.compareAndSet(current, current + 1);
        }
        
        void release(long latencyMs) {
            inFlight.decrementAndGet();
            latency.update(latencyMs);
            
            // Gradient descent: increase limit if latency stable
            if (latency.getRate() < 1.05) {
                limit.updateAndGet(l -> Math.min(l + 1, 1000));
            } else {
                limit.updateAndGet(l -> Math.max((int)(l * 0.9), 10));
            }
        }
    }
    
    public Optional<T> acquire() {
        return limiters.entrySet().stream()
            .filter(e -> e.getValue().tryAcquire())
            .map(Map.Entry::getKey)
            .findFirst();
    }
}
````

[Inference] Dynamically adjusts per-resource concurrency limits based on observed latency. As latency increases (indicating saturation), limit decreases; as latency stabilizes, limit increases. Implements additive increase, multiplicative decrease (AIMD) similar to TCP congestion control.

### Testing Strategies

**Distribution Uniformity Testing**

```java
@Test
public void testLoadDistribution() {
    LoadBalancer<String> balancer = new RoundRobinBalancer<>(
        Arrays.asList("server1", "server2", "server3")
    );
    
    Map<String, Integer> distribution = new HashMap<>();
    int requests = 10000;
    
    for (int i = 0; i < requests; i++) {
        String server = balancer.next();
        distribution.merge(server, 1, Integer::sum);
    }
    
    // Verify uniform distribution within tolerance
    distribution.values().forEach(count -> {
        double expected = requests / 3.0;
        double deviation = Math.abs(count - expected) / expected;
        assertTrue(deviation < 0.05); // 5% tolerance
    });
}
```

Statistical validation of distribution properties. Chi-squared test provides rigorous uniformity validation for probabilistic algorithms.

**Failover Behavior Testing**

```java
@Test
public void testFailoverHandling() {
    List<MockServer> servers = Arrays.asList(
        new MockServer("server1"),
        new MockServer("server2"),
        new MockServer("server3")
    );
    
    LoadBalancer<MockServer> balancer = new HealthAwareBalancer<>(servers);
    
    // All servers healthy
    Set<MockServer> selectedServers = IntStream.range(0, 100)
        .mapToObj(i -> balancer.next())
        .collect(Collectors.toSet());
    assertEquals(3, selectedServers.size());
    
    // Mark one server unhealthy
    servers.get(0).setHealthy(false);
    
    selectedServers = IntStream.range(0, 100)
        .mapToObj(i -> balancer.next())
        .collect(Collectors.toSet());
    assertEquals(2, selectedServers.size());
    assertFalse(selectedServers.contains(servers.get(0)));
    
    // Recover server
    servers.get(0).setHealthy(true);
    
    selectedServers = IntStream.range(0, 1000)
        .mapToObj(i -> balancer.next())
        .collect(Collectors.toSet());
    assertEquals(3, selectedServers.size());
}
```

Validates correct routing exclusion and recovery inclusion. Tests should verify gradual recovery if implemented rather than immediate full load.

**Concurrent Access Testing**

```java
@Test
public void testConcurrentSafety() throws Exception {
    LoadBalancer<String> balancer = new LeastConnectionsBalancer<>(
        Arrays.asList("server1", "server2", "server3")
    );
    
    int threadCount = 50;
    int operationsPerThread = 1000;
    ExecutorService executor = Executors.newFixedThreadPool(threadCount);
    CountDownLatch latch = new CountDownLatch(threadCount);
    
    ConcurrentHashMap<String, AtomicInteger> acquisitions = new ConcurrentHashMap<>();
    
    for (int i = 0; i < threadCount; i++) {
        executor.submit(() -> {
            try {
                for (int j = 0; j < operationsPerThread; j++) {
                    String server = balancer.acquire();
                    acquisitions.computeIfAbsent(server, k -> new AtomicInteger())
                        .incrementAndGet();
                    
                    // Simulate work
                    Thread.sleep(random.nextInt(10));
                    
                    balancer.release(server);
                }
            } finally {
                latch.countDown();
            }
        });
    }
    
    latch.await();
    executor.shutdown();
    
    // Verify no lost updates or race conditions
    int totalAcquisitions = acquisitions.values().stream()
        .mapToInt(AtomicInteger::get)
        .sum();
    assertEquals(threadCount * operationsPerThread, totalAcquisitions);
}
```

Stress testing under high concurrency exposes race conditions in connection counting or state management. Assertions verify conservation of resources (acquisitions equal releases).

Related topics: Service discovery, Health check patterns, Circuit breaker pattern, Rate limiting, Connection pooling, Sticky sessions and session affinity, Consistent hashing, DNS load balancing, Anycast routing, Content delivery networks

---

## Round-Robin

Round-robin distributes requests sequentially across available resources in circular order, providing deterministic load distribution without runtime state evaluation. This pattern prioritizes simplicity and fairness over dynamic optimization based on resource health or capacity.

### Core Implementation

**Basic Sequential Distribution**

```java
public class RoundRobinLoadBalancer<T> {
    private final List<T> resources;
    private final AtomicInteger counter = new AtomicInteger(0);
    
    public T next() {
        int index = Math.abs(counter.getAndIncrement() % resources.size());
        return resources.get(index);
    }
}
```

The modulo operation ensures index wrapping without bounds checking. `AtomicInteger` provides lock-free thread-safety through compare-and-swap (CAS) operations, avoiding contention under high concurrency.

**Integer Overflow Handling**

`AtomicInteger` wraps from `Integer.MAX_VALUE` (2,147,483,647) to `Integer.MIN_VALUE` (-2,147,483,648). The `Math.abs()` call handles negative values:

```java
Math.abs(Integer.MIN_VALUE) // Returns Integer.MIN_VALUE (still negative!)
```

[Inference] This edge case occurs after 2+ billion requests. Robust implementations use `Integer.remainderUnsigned()`:

```java
public T next() {
    int current = counter.getAndIncrement();
    int index = Integer.remainderUnsigned(current, resources.size());
    return resources.get(index);
}
```

### Weighted Round-Robin

**Static Weight Assignment**

Distribute load proportionally based on resource capacity:

```java
public class WeightedRoundRobin<T> {
    private final List<WeightedResource<T>> resources;
    private final AtomicInteger counter = new AtomicInteger(0);
    private final int totalWeight;
    
    public WeightedRoundRobin(Map<T, Integer> weights) {
        this.totalWeight = weights.values().stream().mapToInt(i -> i).sum();
        this.resources = weights.entrySet().stream()
            .flatMap(e -> Collections.nCopies(e.getValue(), e.getKey()).stream())
            .map(WeightedResource::new)
            .collect(Collectors.toList());
    }
    
    public T next() {
        int index = Integer.remainderUnsigned(
            counter.getAndIncrement(), totalWeight);
        return resources.get(index).getResource();
    }
}
```

This approach expands the resource list by weight multipliers. A resource with weight 3 appears three times in the list, receiving 3x traffic compared to weight 1 resources.

**Memory Overhead**

Weighted expansion creates memory proportional to total weight sum. A configuration with weights [1000, 2000, 3000] generates a 6000-element list consuming:

- 6000 references × 8 bytes (compressed OOPs) = 48 KB
- Plus list overhead and object headers

[Inference] Configurations with weights >100 per resource should use smooth weighted round-robin to avoid excessive memory allocation.

**Smooth Weighted Round-Robin (SWRR)**

NGINX's algorithm provides better distribution without list expansion:

```java
public class SmoothWeightedRoundRobin<T> {
    private static class WeightedResource<T> {
        final T resource;
        final int weight;
        int currentWeight;
        
        WeightedResource(T resource, int weight) {
            this.resource = resource;
            this.weight = weight;
            this.currentWeight = 0;
        }
    }
    
    private final List<WeightedResource<T>> resources;
    private final int totalWeight;
    
    public synchronized T next() {
        WeightedResource<T> selected = null;
        
        for (WeightedResource<T> resource : resources) {
            resource.currentWeight += resource.weight;
            
            if (selected == null || 
                resource.currentWeight > selected.currentWeight) {
                selected = resource;
            }
        }
        
        selected.currentWeight -= totalWeight;
        return selected.resource;
    }
}
```

SWRR distributes requests more evenly over short time windows. For weights [5, 1, 1], basic weighted round-robin produces sequence `AAAAA BB`, while SWRR produces `A B A A C A A`, avoiding bursts.

**Synchronization Requirement**

SWRR requires synchronization because `currentWeight` modifications are not atomic. Lock contention becomes bottleneck under high concurrency (>1000 req/s). [Inference] High-throughput scenarios should use lock-free alternatives or partition by connection/thread.

### Dynamic Resource Management

**Handling Resource Addition/Removal**

Modifying the resource list during operation requires safe publication:

```java
public class DynamicRoundRobin<T> {
    private volatile List<T> resources;
    private final AtomicInteger counter = new AtomicInteger(0);
    
    public void updateResources(List<T> newResources) {
        if (newResources.isEmpty()) {
            throw new IllegalArgumentException("Resource list cannot be empty");
        }
        this.resources = List.copyOf(newResources); // Immutable copy
    }
    
    public T next() {
        List<T> snapshot = this.resources; // Local copy
        int index = Integer.remainderUnsigned(
            counter.getAndIncrement(), snapshot.size());
        return snapshot.get(index);
    }
}
```

The `volatile` keyword ensures visibility across threads. Local snapshot prevents inconsistencies from concurrent updates during selection.

**Counter Reset on Resize**

Resource list size changes can cause counter overflow to produce uneven distribution:

```
Initial: 10 resources, counter at 1,000,000
Resize to: 3 resources
Next index: 1,000,000 % 3 = 1 (skips resource 0)
```

[Inference] Resetting the counter on updates improves fairness but may cause temporary imbalance. Production systems typically tolerate this transient unfairness to avoid coordination overhead.

### Connection Pooling Integration

**Database Connection Distribution**

```java
public class RoundRobinConnectionPool {
    private final List<DataSource> dataSources;
    private final AtomicInteger counter = new AtomicInteger(0);
    
    public Connection getConnection() throws SQLException {
        int attempts = dataSources.size();
        
        for (int i = 0; i < attempts; i++) {
            int index = Integer.remainderUnsigned(
                counter.getAndIncrement(), dataSources.size());
            DataSource ds = dataSources.get(index);
            
            try {
                Connection conn = ds.getConnection();
                if (conn.isValid(1)) { // 1 second timeout
                    return conn;
                }
                conn.close();
            } catch (SQLException e) {
                // Try next datasource
            }
        }
        
        throw new SQLException("No available connections");
    }
}
```

This pattern attempts each resource once before failing. Round-robin continues from the last position, preventing cascading failures from repeatedly hitting the same unhealthy resource.

**Circuit Breaker Integration**

Combine round-robin with circuit breakers to skip unhealthy resources:

```java
public class CircuitBreakerRoundRobin<T> {
    private final List<ResourceWithCircuitBreaker<T>> resources;
    private final AtomicInteger counter = new AtomicInteger(0);
    
    public T next() {
        int startIndex = Integer.remainderUnsigned(
            counter.get(), resources.size());
        
        for (int i = 0; i < resources.size(); i++) {
            int index = (startIndex + i) % resources.size();
            ResourceWithCircuitBreaker<T> resource = resources.get(index);
            
            if (resource.circuitBreaker.allowRequest()) {
                counter.set(index + 1); // Update counter
                return resource.resource;
            }
        }
        
        throw new NoAvailableResourceException();
    }
}
```

This implementation tries successive resources without skipping. [Unverified: Specific circuit breaker state transition logic varies across implementations].

### Sticky Session Handling

**Session Affinity with Round-Robin**

Distributed sessions require consistent routing:

```java
public class StickyRoundRobin<T> {
    private final List<T> resources;
    private final ConcurrentHashMap<String, T> sessionMap;
    private final AtomicInteger counter = new AtomicInteger(0);
    
    public T nextForSession(String sessionId) {
        return sessionMap.computeIfAbsent(sessionId, id -> {
            int index = Integer.remainderUnsigned(
                counter.getAndIncrement(), resources.size());
            return resources.get(index);
        });
    }
    
    public void invalidateSession(String sessionId) {
        sessionMap.remove(sessionId);
    }
}
```

**Memory Leak Prevention**

Session maps grow unbounded without eviction. Implement size-based or time-based expiration:

```java
private final Cache<String, T> sessionMap = CacheBuilder.newBuilder()
    .maximumSize(100_000)
    .expireAfterAccess(30, TimeUnit.MINUTES)
    .build();
```

### Anti-Patterns

**Using Round-Robin for Heterogeneous Resources**

Distributing load equally across resources with different capacities:

```java
// Anti-pattern: Treating different instance types equally
List<Server> servers = List.of(
    new Server("m5.large", 2, 8),   // 2 vCPU, 8 GB RAM
    new Server("m5.xlarge", 4, 16),  // 4 vCPU, 16 GB RAM
    new Server("m5.2xlarge", 8, 32)  // 8 vCPU, 32 GB RAM
);
RoundRobinLoadBalancer<Server> lb = new RoundRobinLoadBalancer<>(servers);
```

Equal distribution overloads smaller instances while underutilizing larger ones. Use weighted round-robin with weights proportional to capacity.

**Ignoring Request Processing Time**

Round-robin assumes uniform request cost:

```java
// Anti-pattern: All requests treated equally
server1.handle(quickQuery());   // 10ms
server2.handle(longQuery());    // 5000ms  
server3.handle(quickQuery());   // 10ms
```

Server 2 receives equal request count but disproportionate load. [Inference] Workloads with high variance in processing time (>10x difference between p50 and p99) require least-connections or adaptive algorithms instead.

**Global Counter for Multi-Threaded Selection**

Single atomic counter creates contention:

```java
// Anti-pattern: Single counter for high concurrency
public class GlobalCounterRoundRobin<T> {
    private final AtomicInteger globalCounter = new AtomicInteger(0);
    
    public T next() {
        // All threads contend on same counter
        int index = globalCounter.getAndIncrement() % resources.size();
        return resources.get(index);
    }
}
```

Atomic operations scale poorly beyond 4-8 concurrent threads due to cache line bouncing. Per-thread or striped counters reduce contention:

```java
public class StripedRoundRobin<T> {
    private final List<T> resources;
    private final AtomicInteger[] counters;
    
    public StripedRoundRobin(List<T> resources, int stripes) {
        this.resources = resources;
        this.counters = new AtomicInteger[stripes];
        for (int i = 0; i < stripes; i++) {
            counters[i] = new AtomicInteger(0);
        }
    }
    
    public T next() {
        int stripe = Thread.currentThread().hashCode() % counters.length;
        int index = Integer.remainderUnsigned(
            counters[stripe].getAndIncrement(), resources.size());
        return resources.get(index);
    }
}
```

**Failing on Empty Resource List**

Production services must handle empty states gracefully:

```java
// Anti-pattern: NullPointerException on empty list
public T next() {
    return resources.get(counter.getAndIncrement() % resources.size());
    // throws ArithmeticException: / by zero when resources.size() == 0
}
```

Validate non-empty resources at construction and during updates. Throw explicit exceptions with actionable messages.

### DNS Round-Robin

**A Record Rotation**

DNS servers rotate IP addresses in response order:

```
; Zone file configuration
service.example.com. IN A 192.0.2.1
service.example.com. IN A 192.0.2.2
service.example.com. IN A 192.0.2.3
```

DNS round-robin distributes initial connections but lacks:

- Health checking (returns failed IPs)
- Session persistence (clients cache different IPs)
- Weight support (all IPs treated equally)

[Inference] DNS round-robin serves as coarse-grained distribution suitable for CDN edge selection but inadequate for application-level load balancing.

**TTL Impact on Distribution**

Short TTLs (30-60s) enable faster failover but increase query load. Long TTLs (300-3600s) reduce DNS traffic but delay failure detection. [Unverified: Optimal TTL values depend on change frequency and client retry behavior].

### Kubernetes Service Implementation

**kube-proxy iptables Mode**

Kubernetes uses round-robin for ClusterIP services via iptables rules:

```bash
# iptables chains for service with 3 endpoints
-A KUBE-SVC-X -m statistic --mode random --probability 0.33 -j KUBE-SEP-A
-A KUBE-SVC-X -m statistic --mode random --probability 0.50 -j KUBE-SEP-B
-A KUBE-SVC-X -j KUBE-SEP-C
```

This implements probabilistic round-robin through statistic module. Each connection independently selects an endpoint, approximating even distribution across many connections.

**IPVS Mode**

IPVS provides true round-robin scheduling:

```bash
ipvsadm -A -t 10.96.0.1:80 -s rr
ipvsadm -a -t 10.96.0.1:80 -r 10.244.0.5:8080
ipvsadm -a -t 10.96.0.1:80 -r 10.244.0.6:8080
```

IPVS maintains connection state in kernel space, reducing per-packet overhead compared to iptables. [Inference] IPVS becomes more efficient than iptables beyond ~1000 services due to O(1) vs O(n) lookup complexity.

### Performance Characteristics

**Selection Latency**

Round-robin selection complexity: O(1) time, O(n) space where n = resource count.

Weighted expansion: O(1) selection, O(Σw) space where Σw = sum of all weights.

Smooth weighted: O(n) selection (iterates all resources), O(n) space.

**Throughput Under Contention**

Single-threaded benchmark selecting from 10 resources:

- Basic round-robin: ~50M selections/second
- Weighted (expansion): ~45M selections/second
- Smooth weighted: ~5M selections/second (synchronization overhead)

[Unverified: Performance varies significantly across JVM versions and hardware; these represent relative magnitude differences]

**Cache Locality**

Sequential access pattern benefits from CPU cache prefetching. List-based round-robin exhibits better cache hit rates compared to tree-based structures used in random selection algorithms.

### Monitoring and Observability

**Distribution Fairness Metrics**

Track request distribution variance:

```java
public class RoundRobinMetrics {
    private final ConcurrentHashMap<T, LongAdder> requestCounts;
    
    public void recordSelection(T resource) {
        requestCounts.computeIfAbsent(resource, k -> new LongAdder())
            .increment();
    }
    
    public double calculateVariance() {
        long[] counts = requestCounts.values().stream()
            .mapToLong(LongAdder::sum)
            .toArray();
        
        double mean = Arrays.stream(counts).average().orElse(0);
        double variance = Arrays.stream(counts)
            .mapToDouble(c -> Math.pow(c - mean, 2))
            .average()
            .orElse(0);
        
        return Math.sqrt(variance) / mean; // Coefficient of variation
    }
}
```

Coefficient of variation <0.1 indicates good distribution. Values >0.3 suggest imbalanced load requiring investigation.

**Resource Utilization Correlation**

Measure correlation between round-robin selections and actual resource utilization:

```
Pearson correlation = Cov(selections, utilization) / (σ_sel × σ_util)
```

Low correlation (<0.5) indicates round-robin distributes requests but resources experience different load, suggesting heterogeneous processing times or external factors.

### Comparison with Alternative Algorithms

|Algorithm|Selection Cost|Dynamic Adaptation|Fairness|Use Case|
|---|---|---|---|---|
|Round-Robin|O(1)|None|High|Homogeneous resources, uniform requests|
|Weighted RR|O(1) or O(n)|Static weights|Medium|Known capacity differences|
|Least Connections|O(n) or O(log n)|Dynamic|Medium|Variable request duration|
|Random|O(1)|None|Medium|Stateless, high concurrency|
|Consistent Hashing|O(log n)|Topology-aware|Low|Cache distribution, sharding|
|Power of Two|O(1)|Sample-based|High|Simple dynamic balancing|

[Inference] Round-robin serves as baseline algorithm when operational complexity of dynamic algorithms cannot be justified.

Related topics: Least connections algorithm, Power of two choices, Consistent hashing, Load balancer health checking, Connection pooling strategies, Service mesh traffic management.

---

## Least Connections

A load balancing algorithm that routes incoming requests to the backend server currently handling the fewest active connections, optimizing resource utilization and response time in heterogeneous or variable-workload environments.

### Core Algorithm Mechanics

**Selection Logic**:

```python
class LeastConnectionsBalancer:
    def __init__(self, servers):
        self.servers = servers
        self.connections = {server: 0 for server in servers}
        self.lock = threading.Lock()
    
    def select_server(self):
        with self.lock:
            # Find server with minimum active connections
            return min(self.connections.items(), key=lambda x: x[1])[0]
    
    def on_request_start(self, server):
        with self.lock:
            self.connections[server] += 1
    
    def on_request_complete(self, server):
        with self.lock:
            self.connections[server] -= 1
```

**Complexity**: O(n) per selection where n = server count. Linear scan across all servers to find minimum. Acceptable for dozens of servers; problematic at scale (1000+ servers).

**State Synchronization**: Load balancer must track connection state accurately. Requires hooks into connection lifecycle: establishment, termination, timeout. Stale counts cause suboptimal routing.

### Weighted Least Connections

Accounts for heterogeneous server capacity by incorporating weight factors:

```python
def select_weighted_server(self):
    with self.lock:
        # connections/weight ratio determines load
        return min(
            self.servers,
            key=lambda s: self.connections[s] / s.weight
        )
```

**Weight Assignment Strategies**:

- **Static**: Based on hardware specs (CPU cores, RAM, network bandwidth)
- **Dynamic**: Adjusted based on observed latency, CPU utilization, or throughput
- **Hybrid**: Base weight modified by health check performance metrics

[Inference] Weighted variant critical for mixed instance types (e.g., cloud environments with c5.large and c5.4xlarge). Without weighting, powerful servers underutilized while weak servers saturate.

### Connection Counting Strategies

**TCP Connection Tracking**:

```c
// HAProxy-style connection tracking
struct server {
    char *hostname;
    int active_connections;
    int max_connections;
    time_t last_activity;
};

struct server* select_least_conn(struct server *servers, int count) {
    struct server *selected = NULL;
    int min_conn = INT_MAX;
    
    for (int i = 0; i < count; i++) {
        if (servers[i].active_connections < servers[i].max_connections &&
            servers[i].active_connections < min_conn) {
            min_conn = servers[i].active_connections;
            selected = &servers[i];
        }
    }
    return selected;
}
```

**HTTP/1.1 Persistence**: Single TCP connection may carry multiple sequential HTTP requests. Track active HTTP requests, not just connections. Connection count misrepresents actual load.

**HTTP/2 Multiplexing**: Single connection carries multiple concurrent streams. Connection count completely misrepresents load. Must track active streams per connection:

```go
type HTTP2Server struct {
    Address        string
    ActiveStreams  int32  // atomic
    MaxConcurrent  int32
}

func (lb *LoadBalancer) SelectServer() *HTTP2Server {
    var selected *HTTP2Server
    minStreams := int32(math.MaxInt32)
    
    for _, srv := range lb.servers {
        streams := atomic.LoadInt32(&srv.ActiveStreams)
        if streams < srv.MaxConcurrent && streams < minStreams {
            minStreams = streams
            selected = srv
        }
    }
    return selected
}
```

**WebSocket Considerations**: Long-lived connections skew connection counts. Server with many idle WebSockets appears loaded but has capacity. [Inference] Hybrid metric: weight by connection age or recent message throughput.

### Performance Characteristics

**Optimal Load Distribution**: [Inference] Converges to near-optimal distribution when request durations vary significantly. Servers naturally balance as fast-completing requests free capacity faster than slow ones.

**Comparison with Round Robin**:

- Round robin: Equal distribution regardless of server capability or current load
- Least connections: Adapts to heterogeneous performance and bursty traffic

**Latency Impact**: Selection overhead minimal (microseconds) compared to request processing (milliseconds). Becomes significant only at extreme scale (100k+ requests/second per load balancer instance).

**Cold Start Problem**: [Inference] Initially all servers have zero connections. First N requests (where N = server count) distribute round-robin. Subsequent requests leverage connection tracking. Minimal impact except in short-lived scenarios.

### Distributed Load Balancing Challenges

**Shared State Requirements**: Multiple load balancer instances require synchronized connection counts. Options:

1. **Independent Tracking**: Each load balancer maintains local view. Inconsistency acceptable; averages out across requests. Simple, no coordination overhead.
    
2. **Centralized State Store**:
    

```python
import redis

class DistributedLeastConnections:
    def __init__(self, redis_client, servers):
        self.redis = redis_client
        self.servers = servers
    
    def select_server(self):
        # Atomic read of all connection counts
        counts = self.redis.mget([f"conn:{s}" for s in self.servers])
        min_idx = counts.index(min(counts))
        return self.servers[min_idx]
    
    def on_request_start(self, server):
        self.redis.incr(f"conn:{server}")
    
    def on_request_complete(self, server):
        self.redis.decr(f"conn:{server}")
```

**Consistency Overhead**: [Inference] Redis operations add 1-2ms latency. Two round trips per request (incr on start, decr on complete). Network partition risks stale counts. Trade-off rarely justifies cost; local tracking with gossip preferred.

3. **Gossip Protocol Synchronization**:

```go
type GossipState struct {
    ServerID     string
    Connections  map[string]int
    Timestamp    time.Time
}

func (lb *LoadBalancer) GossipTick() {
    state := GossipState{
        ServerID:    lb.ID,
        Connections: lb.localConnections,
        Timestamp:   time.Now(),
    }
    
    // Send to random peer
    peer := lb.selectRandomPeer()
    peer.Send(state)
    
    // Merge received states
    lb.mergeRemoteStates()
}
```

[Inference] Eventually consistent view across load balancers. Convergence time: seconds to tens of seconds depending on gossip frequency and cluster size. Acceptable for most use cases given statistical averaging.

### Health Check Integration

**Connection Limit Enforcement**:

```nginx
upstream backend {
    least_conn;
    
    server backend1.example.com max_conns=100;
    server backend2.example.com max_conns=200;
    server backend3.example.com max_conns=150;
}
```

**Unhealthy Server Handling**: [Inference] Failed health checks should immediately zero weight or remove from pool. Gradual drain: stop new connections, allow existing to complete. Prevents request failures during server degradation.

**Slow Start After Recovery**:

```python
def calculate_effective_weight(server, base_weight):
    if server.recently_recovered:
        time_since_recovery = time.time() - server.recovery_time
        ramp_duration = 60  # seconds
        
        if time_since_recovery < ramp_duration:
            # Linear ramp from 10% to 100%
            factor = 0.1 + 0.9 * (time_since_recovery / ramp_duration)
            return base_weight * factor
    
    return base_weight
```

[Inference] Prevents thundering herd to recovered server. Gradually increases load allowing JIT compilation, cache warming, connection pool establishment.

### Anti-Patterns

**Ignoring Request Heterogeneity**: [Inference] Least connections assumes requests have similar resource consumption. If 99% are cheap reads and 1% are expensive writes, connection count misrepresents load. Solution: weighted request types or use least-requests-in-flight with request cost factors.

**Over-Synchronized State**: Implementing distributed consensus (Raft, Paxos) for connection counts. Coordination overhead exceeds benefit. Eventually consistent local tracking sufficient.

**Connection Count Without Timeouts**: Stale connections from crashed clients inflate counts indefinitely. Implement idle timeouts:

```python
def cleanup_stale_connections(self):
    current_time = time.time()
    with self.lock:
        for server in self.servers:
            for conn_id in list(self.active_connections[server].keys()):
                last_activity = self.active_connections[server][conn_id]
                if current_time - last_activity > self.idle_timeout:
                    del self.active_connections[server][conn_id]
                    self.connections[server] -= 1
```

**Fine-Grained Locking Contention**: Single lock protecting connection counts becomes bottleneck at high concurrency. Solutions:

```cpp
// Lock-free atomic operations
std::atomic<int> connection_count[MAX_SERVERS];

int select_server() {
    int min_conn = INT_MAX;
    int selected = -1;
    
    for (int i = 0; i < server_count; i++) {
        int conn = connection_count[i].load(std::memory_order_relaxed);
        if (conn < min_conn) {
            min_conn = conn;
            selected = i;
        }
    }
    return selected;
}

void on_request_start(int server) {
    connection_count[server].fetch_add(1, std::memory_order_relaxed);
}
```

**Ignoring Connection Establishment Cost**: TCP handshake, TLS negotiation add latency. Reusing existing connections via connection pooling amortizes cost. Least connections at pool level, not individual request level.

### Layer 4 vs Layer 7 Implementation

**Layer 4 (Transport Layer)**:

- Operates on TCP/UDP connections
- No visibility into HTTP requests
- Lower latency (no packet inspection)
- Cannot distinguish between idle and active connections with traffic

**Layer 7 (Application Layer)**:

- HTTP request/response awareness
- Accurate request-in-flight tracking
- Session affinity support (sticky sessions)
- Higher CPU overhead (TLS termination, header parsing)

[Inference] L4 appropriate for homogeneous traffic (e.g., database connections). L7 necessary for HTTP with variable request durations or when routing decisions depend on request content.

### Implementation in Load Balancers

**NGINX**:

```nginx
upstream backend {
    least_conn;
    
    server backend1.example.com:8080;
    server backend2.example.com:8080 weight=2;
    server backend3.example.com:8080 max_fails=3 fail_timeout=30s;
    
    keepalive 32;  # Connection pooling
}
```

**HAProxy**:

```haproxy
backend app_servers
    balance leastconn
    
    option httpchk GET /health
    
    server app1 10.0.1.10:8080 check weight 100 maxconn 500
    server app2 10.0.1.11:8080 check weight 150 maxconn 750
    server app3 10.0.1.12:8080 check weight 100 maxconn 500 backup
```

**AWS Application Load Balancer**: Uses variant called "least outstanding requests" tracking HTTP requests in flight rather than TCP connections. [Unverified] Proprietary implementation details undisclosed; behavior suggests request duration weighting.

**Envoy Proxy**:

```yaml
cluster:
  name: service_backend
  type: STRICT_DNS
  lb_policy: LEAST_REQUEST  # Envoy's variant
  lb_config:
    least_request_config:
      choice_count: 2  # Power of Two Choices optimization
```

### Power of Two Choices Optimization

**Random Subset Selection**: [Inference] Instead of scanning all N servers, randomly select K servers and choose least loaded among them. Reduces selection from O(n) to O(k).

```python
import random

def select_server_p2c(self, choice_count=2):
    candidates = random.sample(self.servers, min(choice_count, len(self.servers)))
    with self.lock:
        return min(candidates, key=lambda s: self.connections[s])
```

**Theoretical Foundation**: [Unverified] Research shows choosing least loaded from 2 random servers achieves exponentially better load balance than pure random selection, approaching optimal distribution with logarithmic overhead.

**Practical Impact**: [Inference] With 100 servers and choice_count=2:

- Scan reduction: 98% fewer servers examined
- Latency reduction: ~50x faster selection
- Distribution quality: 90%+ as good as full least-connections

### Adaptive Algorithms

**Latency-Weighted Least Connections**:

```python
def select_server_adaptive(self):
    with self.lock:
        scores = {}
        for server in self.servers:
            conn_factor = self.connections[server] / server.max_connections
            latency_factor = server.avg_latency_ms / 100.0  # Normalize
            scores[server] = conn_factor * 0.6 + latency_factor * 0.4
        
        return min(scores.items(), key=lambda x: x[1])[0]
```

[Inference] Hybrid approaches account for both queue depth (connections) and processing speed (latency). Weights tunable based on workload characteristics.

**Auto-Scaling Integration**:

```python
def evaluate_scale_up_need(self):
    avg_load = sum(self.connections.values()) / len(self.servers)
    max_load = max(self.connections.values())
    
    # Scale up if any server consistently above 80% capacity
    if max_load / self.capacity_per_server > 0.8:
        return True
    
    # Or if average load above 70%
    if avg_load / self.capacity_per_server > 0.7:
        return True
    
    return False
```

Connection metrics drive autoscaling decisions. [Inference] Low connection counts signal over-provisioning; consistent high counts trigger scale-out.

### Edge Cases and Failure Modes

**Thundering Herd on Restart**: All servers restart simultaneously, connection counts reset to zero. First wave of requests distributes evenly, but arrival timing determines distribution. [Inference] Staggered restarts prevent synchronization.

**Connection Leak Detection**:

```python
def detect_connection_leaks(self):
    for server, count in self.connections.items():
        if count > server.max_connections * 1.1:
            logger.error(f"Connection leak detected on {server}: {count}")
            # Force recount from actual connections
            actual = self.query_actual_connections(server)
            self.connections[server] = actual
```

**Cascading Failure Scenario**: [Inference] One server becomes slow but not unhealthy. Accumulates connections as requests queue. Other servers drain faster, receive more new requests, increasing total throughput while slow server starves. Monitoring must detect latency increase, not just connection count.

**Session Affinity Conflict**: Sticky sessions override least connections. User always routed to same server regardless of load. [Inference] Hybrid approach: consistent hashing with bounded load spreading overloaded server's sessions across multiple backends.

### Monitoring and Observability

**Key Metrics**:

- Per-server active connection count distribution
- Connection acceptance/rejection rate
- Connection duration percentiles (p50, p95, p99)
- Queue depth at application layer
- Load balancer selection latency

**Alert Thresholds**: [Inference]

- Connection imbalance ratio > 2.0 (max/min across servers) indicates algorithm failure or capacity heterogeneity
- Connection age > 5 minutes suggests connection pooling issues or stuck requests
- Selection latency > 1ms indicates locking contention or excessive server count

**Debugging Connection Leaks**:

```bash
# HAProxy stats socket
echo "show stat" | socat stdio /var/run/haproxy.sock | grep backend

# NGINX stub_status
curl http://localhost/nginx_status

# Application-level tracking
curl http://load-balancer:9090/metrics | grep active_connections
```

### Comparison with Alternative Algorithms

**Round Robin**: Simpler, no state. Appropriate for homogeneous servers with uniform request patterns. [Inference] 50%+ faster selection but 20-40% worse tail latency under variable load.

**Random**: Stateless, trivial implementation. [Inference] Acceptable for large server pools (100+) where statistical distribution adequate. Poor with small pools (< 10).

**Consistent Hashing**: Session affinity without state in load balancer. [Inference] Poor load distribution compared to least connections; used when affinity required, not performance optimal.

**Resource-Based (CPU/Memory)**: More accurate load representation. Requires agent on backend servers publishing metrics. [Inference] 10-100x slower selection due to metric collection latency. Reserved for batch processing workloads where latency tolerance exists.

**Related Topics**: Load balancing algorithms, Connection pooling, HTTP/2 multiplexing, Health check strategies, Service mesh routing, Consistent hashing, Power of two choices, Thundering herd problem, Autoscaling policies, Layer 4 vs Layer 7 load balancing, Circuit breaker pattern, Rate limiting

---

## IP hash

A deterministic load balancing algorithm that maps client IP addresses to backend servers using hash functions, ensuring requests from the same client consistently route to the same server instance. Achieves session affinity without centralized state coordination by computing server selection from immutable client network identifiers.

### Mechanism

The load balancer extracts the source IP address from incoming packets, applies a hash function (typically modulo operation over server pool size), and routes to the server corresponding to the hash output:

```
server_index = hash(client_ip) % server_count
```

Common hash function choices:

- **Modulo arithmetic:** `crc32(ip) % n` or `fnv1a(ip) % n`
- **Consistent hashing:** Maps IPs to ring positions, assigns to nearest server
- **Jump hash:** Google's stateless consistent hash with minimal disruption

Example with simple modulo:

```
Client IP: 192.168.1.42 → hash(192.168.1.42) = 2847156294
Server pool: [srv1, srv2, srv3, srv4] (n=4)
2847156294 % 4 = 2 → route to srv3
```

All subsequent requests from 192.168.1.42 route to srv3, maintaining session locality.

### Session Affinity Guarantees

**Sticky sessions without state:** Unlike cookie-based or session ID tracking, IP hash requires no session store or coordination between load balancers. Multiple load balancers independently compute identical mappings given the same server pool configuration.

**Determinism constraint:** Hash function must be deterministic and consistent across all load balancer instances. Non-deterministic elements (timestamps, random seeds) break affinity.

**Affinity scope:** Binds to source IP, not user session. Multiple users behind NAT/proxy share the same IP hash, routing to the same backend. Single user switching networks (WiFi → cellular) changes IP, breaking affinity.

### Distribution Uniformity

Hash quality determines load distribution. Poor hash functions create hotspots where disproportionate traffic concentrates on few servers.

**Collision rate:** With modulo hashing over n servers, expected collision rate approaches 1/n for uniformly distributed IPs. IPv4 address space (~4B addresses) provides sufficient entropy for even distribution across typical server pools (10-1000 servers).

**Non-uniform IP distribution:** Real-world traffic exhibits geographic clustering. If 60% of users originate from subnet 10.0.0.0/8, and hash(10.0.x.y) concentrates in range mapping to server1-2, those servers carry 60% load while others idle.

[Inference] Measuring actual distribution requires monitoring per-server request rates and comparing variance to theoretical uniform distribution. Chi-square goodness-of-fit test quantifies deviation.

### Server Pool Changes

**Reshuffling problem:** Adding/removing servers changes `n` in `hash(ip) % n`, remapping most IPs to different servers. Previous affinities break, sessions scatter.

Example: 4 servers → 5 servers

```
IP 192.168.1.42: hash=2847156294
Before: 2847156294 % 4 = 2 → srv3
After:  2847156294 % 5 = 4 → srv5  (moved)
```

Approximately `(n-1)/n` sessions remap on single server addition. For n=10, adding one server disrupts 90% of sessions.

**Impact quantification:**

- Session-based applications: Users logged out, shopping carts lost
- Cached data: In-memory caches miss, causing database load spike
- Long-running operations: WebSocket connections drop, file uploads abort

### Consistent Hashing Mitigation

Consistent hashing reduces disruption by mapping servers to ring positions rather than array indices. Adding server affects only immediate neighbors on ring.

```
Ring: [0 ─ srv1 ─ srv2 ─ srv3 ─ srv4 ─ 2^32-1]
      └─────────────────────────────────────┘

Client IP hashes to ring position → route to next clockwise server
```

Adding srv5 between srv2 and srv3: only IPs hashing to that arc remap from srv3 to srv5. Disruption: ~1/n of sessions.

**Virtual nodes:** Each physical server maps to multiple ring positions (typically 100-500 virtual nodes). Improves distribution uniformity and further reduces disruption during pool changes.

**Trade-off:** Consistent hashing increases computational complexity (O(log n) lookup vs O(1) modulo) and memory overhead (maintaining ring structure). Negligible for typical load balancer throughput (<100K req/s), measurable at high scale (>1M req/s).

### IPv6 Considerations

IPv6 addresses are 128-bit vs IPv4's 32-bit. Naive hashing over full IPv6 address works but introduces complications:

**Privacy extensions (RFC 4941):** Clients generate temporary addresses changing every 24 hours. IP hash treats each temporary address as distinct client, breaking session affinity within the lifetime of a session.

**Prefix stability:** Hashing on /64 prefix instead of full /128 address maintains affinity across temporary address changes. Requires extracting prefix:

```
IPv6: 2001:0db8:85a3:0000:0000:8a2e:0370:7334
/64 prefix: 2001:0db8:85a3:0000
hash(prefix) % n
```

[Inference] Prefix hashing may reduce distribution uniformity if many clients share the same /64 subnet (e.g., enterprise network), concentrating load.

### Proxy and NAT Effects

**Corporate NAT:** Thousands of users behind single egress IP all hash to same server. Creates severe load imbalance. Example: 10,000-employee company, single NAT IP, all traffic to one backend server while others idle.

**CDN and reverse proxies:** If CDN sits before load balancer, source IP becomes CDN edge server IP, not end user IP. CDN's distributed edge nodes collapse to handful of IPs, negating distribution benefits.

**X-Forwarded-For header:** Application load balancers (L7) can hash on original client IP from XFF header:

```
X-Forwarded-For: 203.0.113.42, 198.51.100.17
                 └──────┬──────┘
                  Original client IP
```

Requires trusting proxy chain. Malicious clients can spoof XFF headers if proxy doesn't sanitize. Security: only trust XFF from verified proxy IPs.

### Layer 4 vs Layer 7 Hashing

**L4 (network load balancer):** Hashes IP from packet headers without inspecting payload. Minimal latency (~1ms), high throughput (10+ Gbps), stateless. Cannot parse application headers (XFF, cookies).

**L7 (application load balancer):** Terminates TCP, parses HTTP headers, extracts IPs from XFF or hashes on other attributes (User-Agent, session cookies). Higher latency (~5-10ms), lower throughput (~1 Gbps), stateful. Enables sophisticated routing.

Use L4 IP hash when:

- Sub-millisecond latency critical
- Throughput exceeds L7 capacity
- Direct client IPs available (no proxies)

Use L7 alternatives when:

- Proxies obscure true client IPs
- Need hybrid routing (IP hash + URL path)
- Application requires header inspection

### Hash Function Selection

**Cryptographic hashes (MD5, SHA-1):** Overkill for load balancing. High computational cost without security benefit (no adversarial input resistance needed). Throughput penalty: 10-50× slower than non-cryptographic hashes.

**Non-cryptographic hashes:**

- **CRC32:** Fast, adequate distribution. Collision-prone for small n (<10 servers).
- **MurmurHash3:** Better distribution, minimal computational overhead. Industry standard for non-adversarial scenarios.
- **FNV-1a:** Simple, fast, good distribution. Easy to implement.

**Benchmark example (pseudo-code):**

```
CRC32:       ~1 GB/s throughput
MurmurHash3: ~5 GB/s throughput
SHA-256:     ~100 MB/s throughput
```

[Unverified] Specific throughput depends on CPU architecture, compiler optimizations, and implementation quality.

### Monitoring and Observability

**Distribution metrics:**

- Per-server request rate: `requests/sec` by server
- Coefficient of variation: `stddev(requests) / mean(requests)`. <0.1 indicates good distribution, >0.5 indicates hotspots.
- Maximum deviation: `(max_rate - min_rate) / mean_rate`

**Session disruption tracking:**

- Session reset rate spike during server pool changes
- Error rate increase (401 Unauthorized, session expired)
- Cache miss ratio post-deployment

**IP concentration analysis:**

- Top N IPs by request volume
- Requests from single IP / total requests ratio
- Geographic distribution of source IPs

Alert when:

- Single server handles >150% of expected uniform load
- Session disruption rate >5% during planned pool changes
- > 20% of traffic originates from single IP (potential NAT hotspot)
    

### Anti-Patterns

**Frequent pool reconfigurations:** Continuous auto-scaling adding/removing servers every few minutes. Each change disrupts sessions. Solution: Scale in larger increments, set minimum scaling intervals (15-30 minutes), use consistent hashing.

**Ignoring NAT implications:** Deploying IP hash for applications with predominantly corporate users behind NAT. Results in 80/20 load distribution (80% of load on 20% of servers). Solution: L7 hashing on session cookies or user identifiers.

**No graceful server removal:** Immediately removing server from pool drops in-flight connections. Better: drain connections (stop sending new requests, wait for existing to complete) before removal.

**Using IP hash with stateless applications:** If application maintains no local state (fully RESTful, external session store), IP hash provides no benefit over round-robin while introducing distribution risks. Premature optimization.

**Hashing on IPv6 temporary addresses:** Full /128 address hashing breaks affinity within hours. Use prefix hashing or alternative session tracking.

### Security Implications

**DDoS amplification:** Attacker targeting single server can't directly specify server in simple IP hash (server selection deterministic but opaque to attacker). However, attacker can brute-force IPs until finding one mapping to target server.

```python
for ip in ip_range:
    if hash(ip) % n == target_server_index:
        attack_from(ip)  # All attacks concentrate on target_server
```

**Mitigation:** Rate limiting per source IP, DDoS protection at edge (Cloudflare, AWS Shield), consistent hashing spreads attack impact via virtual nodes.

**Session hijacking:** If attacker spoofs victim's IP and sits behind same load balancer, they route to victim's server, potentially accessing cached session data. Requires network-level IP spoofing (difficult across internet routing).

**Privacy:** IP addresses are PII in many jurisdictions (GDPR). Logging source IPs for load balancing decisions requires data retention policies. Hashing IPs before logging (one-way function) may satisfy compliance while enabling debugging.

### Database Connection Pooling

IP hash combined with database connection pools creates predictable connection distribution. If application servers maintain pools of 10 connections each, and 20 servers exist, database sees maximum 200 connections (vs. 200-400 with random distribution creating per-server variance).

**Problem:** If database has 100 max connections and 20 app servers with 10-connection pools, IP hash provides no advantage—total connections deterministic regardless of distribution. The benefit emerges in elastically scaling server pools where connection count varies.

[Inference] Connection pool sizing must account for worst-case server concentration. If NAT causes 5 servers to handle 80% of load, those servers need proportionally larger pools.

### Failover Behavior

**Server failure:** Dead server no longer receives traffic, but its assigned IPs remap to remaining servers. With modulo hashing, all IPs rehash. With consistent hashing, only failed server's IPs remap to successors (~1/n sessions disrupted).

**Health check latency:** Time between server failure and load balancer detection. During this window, IPs mapping to failed server experience errors. Typical: 5-30 seconds depending on health check intervals.

**Active health checks:** Load balancer probes servers (HTTP GET /health). False negatives: healthy server marked dead due to transient network blip, causing unnecessary disruption.

**Passive health checks:** Monitor actual traffic responses. Server returning errors triggers removal. Lower false negatives but slower detection (requires accumulating error threshold, e.g., 5 consecutive failures).

### Comparison to Alternatives

**Round-robin:** Simpler, better distribution, but no session affinity. Use when applications are stateless or use external session stores.

**Least connections:** Dynamically routes to server with fewest active connections. Better for heterogeneous server performance or long-lived connections (WebSockets). Requires stateful load balancer tracking per-server connection counts.

**Cookie-based affinity:** Application sets cookie with server identifier. Load balancer reads cookie and routes accordingly. More flexible than IP hash (survives IP changes) but requires L7 processing and cookie management.

**Session ID in URL:** Encode server ID in session URL (`https://app.com/srv3/session123`). Simple but exposes infrastructure topology to clients and complicates URL routing.

### Geographic Load Balancing

Combining IP hash with geographic routing: hash within region, not globally.

```
Client IP → GeoIP lookup → Region selection
         → IP hash within regional server pool
```

Benefits:

- Latency reduction (regional proximity)
- Regulatory compliance (data locality)
- Independent regional scaling

Complexity: Requires accurate GeoIP database (99%+ accuracy at country level, 90%+ at city level per commercial databases). VPN/proxy users may misroute.

### Applicability

Optimal for:

- Session-based applications requiring sticky sessions (shopping carts, multi-step workflows)
- Applications caching user-specific data in memory
- WebSocket/long-lived connection workloads where connection stability matters
- Scenarios where consistent hashing can mitigate pool change disruption

Inappropriate for:

- Fully stateless RESTful APIs with external session storage
- User bases predominantly behind corporate NAT/proxies
- High-churn server pools (aggressive auto-scaling)
- When load imbalance risks exceed session affinity benefits

**Related topics:** Consistent hashing, rendezvous hashing (HRW), Maglev hashing, connection draining strategies, session replication across servers, sticky session alternatives (session stores, JWT tokens), geographic load balancing, anycast routing.

---

## Weighted Load Balancing

Weighted load balancing distributes traffic across backend resources using proportional weights reflecting capacity, performance characteristics, or operational states. Unlike round-robin algorithms that assume homogeneous backends, weighted distribution accounts for heterogeneous infrastructure where servers possess varying computational power, network bandwidth, or deliberate capacity allocation.

### Weight Assignment Strategies

**Static Weight Configuration:**

```nginx
upstream backend {
    server backend1.example.com weight=5;
    server backend2.example.com weight=3;
    server backend3.example.com weight=2;
}
```

Static weights represent fixed capacity ratios. A weight of 5:3:2 directs 50%, 30%, and 20% of requests respectively. Weight values are relative; absolute magnitudes are irrelevant (5:3:2 ≡ 50:30:20).

**Capacity-Based Weighting:**

```python
def calculate_weight(server):
    # Weight proportional to CPU cores and memory
    return (server.cpu_cores * server.memory_gb) / baseline_capacity

server_weights = {
    'server1': calculate_weight(ServerSpec(cpu_cores=16, memory_gb=64)),  # weight: 4
    'server2': calculate_weight(ServerSpec(cpu_cores=8, memory_gb=32)),   # weight: 2
    'server3': calculate_weight(ServerSpec(cpu_cores=4, memory_gb=16)),   # weight: 1
}
```

Normalize weights to hardware specifications to maintain proportional distribution as infrastructure scales. Update weights when server configurations change.

**Geographic Weight Adjustment:**

```yaml
# HAProxy configuration with geographic weights
backend geo_backend
    server us-east-1 10.0.1.10:80 weight 100
    server us-west-2 10.0.2.10:80 weight 80
    server eu-west-1 10.0.3.10:80 weight 50
```

Reduce weights for geographically distant servers to account for latency penalties. Users tolerate higher latency from remote regions; compensate with lower traffic allocation.

### Weighted Round Robin Algorithm

Weighted round robin (WRR) distributes requests in cycles proportional to assigned weights. Implementation requires maintaining per-server request counters.

```python
class WeightedRoundRobin:
    def __init__(self, servers):
        # servers: list of (server, weight) tuples
        self.servers = servers
        self.current_weight = [0] * len(servers)
        self.max_weight = max(w for _, w in servers)
        self.gcd_weight = self._gcd_all([w for _, w in servers])
        self.current_index = -1
        
    def next_server(self):
        while True:
            self.current_index = (self.current_index + 1) % len(self.servers)
            
            if self.current_index == 0:
                self.current_weight[0] -= self.gcd_weight
                if self.current_weight[0] <= 0:
                    self.current_weight = [self.max_weight] * len(self.servers)
            
            server, weight = self.servers[self.current_index]
            if self.current_weight[self.current_index] > 0:
                self.current_weight[self.current_index] -= weight
                return server
```

**Smooth Weighted Round Robin:**

Standard WRR produces bursts where high-weight servers receive consecutive requests. Smooth WRR (NGINX algorithm) distributes requests more evenly.

```python
class SmoothWeightedRoundRobin:
    def __init__(self, servers):
        self.servers = [(srv, weight, 0) for srv, weight in servers]  # (server, weight, current_weight)
        
    def next_server(self):
        total_weight = sum(w for _, w, _ in self.servers)
        
        # Increment all current_weights by their weights
        for i in range(len(self.servers)):
            srv, weight, current = self.servers[i]
            self.servers[i] = (srv, weight, current + weight)
        
        # Select server with highest current_weight
        max_idx = max(range(len(self.servers)), key=lambda i: self.servers[i][2])
        selected_server = self.servers[max_idx][0]
        
        # Decrease selected server's current_weight by total
        srv, weight, current = self.servers[max_idx]
        self.servers[max_idx] = (srv, weight, current - total_weight)
        
        return selected_server
```

Example distribution for weights [5, 1, 1]:

- Standard WRR: A A A A A B C (bursty)
- Smooth WRR: A A B A C A A (distributed)

### Dynamic Weight Adjustment

Dynamic weighting adapts to runtime conditions including response time, error rates, and resource utilization.

**Response Time-Based Weighting:**

```python
class AdaptiveWeightCalculator:
    def __init__(self, target_response_time_ms=100):
        self.target_rt = target_response_time_ms
        self.response_times = {}  # server -> exponential moving average
        self.alpha = 0.3  # EMA smoothing factor
        
    def update_response_time(self, server, response_time_ms):
        if server not in self.response_times:
            self.response_times[server] = response_time_ms
        else:
            # Exponential moving average
            self.response_times[server] = (
                self.alpha * response_time_ms + 
                (1 - self.alpha) * self.response_times[server]
            )
    
    def calculate_weight(self, server, base_weight):
        rt = self.response_times.get(server, self.target_rt)
        
        # Inverse relationship: higher response time = lower weight
        performance_factor = self.target_rt / max(rt, 1)
        
        # Clamp between 0.1x and 2.0x base weight
        adjusted = base_weight * max(0.1, min(2.0, performance_factor))
        return int(adjusted)
```

Adjust weights on time intervals (10-60 seconds) rather than per-request to prevent oscillation. Exponential moving averages smooth transient spikes.

**Health-Based Weight Degradation:**

```python
class HealthAwareWeighting:
    def __init__(self):
        self.health_scores = {}  # server -> health score [0.0, 1.0]
        
    def update_health(self, server, success_rate, cpu_utilization):
        # Composite health score
        health = (
            success_rate * 0.7 +  # 70% weight on success rate
            (1 - cpu_utilization) * 0.3  # 30% weight on available capacity
        )
        self.health_scores[server] = max(0.0, min(1.0, health))
    
    def get_effective_weight(self, server, configured_weight):
        health = self.health_scores.get(server, 1.0)
        
        # Non-linear degradation: healthy servers maintain full weight
        if health > 0.9:
            return configured_weight
        elif health > 0.5:
            return int(configured_weight * health)
        else:
            # Aggressive reduction for unhealthy servers
            return max(1, int(configured_weight * health * 0.5))
```

Gradual weight reduction prevents abrupt traffic shifts that destabilize remaining servers. Maintain minimum weight of 1 to preserve health check traffic and enable recovery detection.

### Least Connections with Weights

Weighted least connections accounts for both active connection count and server capacity when distributing new requests.

```python
class WeightedLeastConnections:
    def __init__(self, servers):
        self.servers = {srv: {'weight': w, 'connections': 0} for srv, w in servers}
    
    def next_server(self):
        # Select server with minimum (connections / weight) ratio
        selected = min(
            self.servers.items(),
            key=lambda x: x[1]['connections'] / x[1]['weight']
        )
        
        server_name = selected[0]
        self.servers[server_name]['connections'] += 1
        return server_name
    
    def release_connection(self, server):
        self.servers[server]['connections'] -= 1
```

This algorithm achieves optimal distribution for long-lived connections (WebSockets, database connections, streaming) where connection duration varies significantly.

**Connection Load Metric:**

```
Load Factor = Active Connections / (Weight × Baseline Capacity)
```

Select the server with the minimum load factor. Baseline capacity represents connections a standard server handles at target performance levels.

### Power of Two Choices with Weights

Power of two choices (P2C) randomly samples two servers and selects the better candidate. Weighted variant considers capacity ratios.

```python
import random

class WeightedPowerOfTwoChoices:
    def __init__(self, servers):
        self.servers = servers  # list of (server, weight) tuples
        self.loads = {srv: 0 for srv, _ in servers}
        self.weights = {srv: w for srv, w in servers}
    
    def next_server(self):
        # Random sampling weighted by server weights
        total_weight = sum(w for _, w in self.servers)
        
        # Sample two servers with probability proportional to weights
        candidates = random.choices(
            [srv for srv, _ in self.servers],
            weights=[w for _, w in self.servers],
            k=2
        )
        
        # Select candidate with lower (load / weight) ratio
        selected = min(
            candidates,
            key=lambda s: self.loads[s] / self.weights[s]
        )
        
        self.loads[selected] += 1
        return selected
    
    def release(self, server):
        self.loads[server] -= 1
```

**[Inference]** P2C with weights approaches optimal load distribution with O(log log n) convergence rate, significantly faster than pure random selection, while avoiding global synchronization required by least connections algorithms.

### Weighted Consistent Hashing

Weighted consistent hashing distributes keys across nodes while respecting capacity differences. Virtual nodes (vnodes) replicate high-capacity servers more frequently on the hash ring.

```python
import hashlib

class WeightedConsistentHash:
    def __init__(self, servers, vnodes_per_weight=100):
        self.vnodes_per_weight = vnodes_per_weight
        self.ring = {}  # hash_value -> server
        
        for server, weight in servers:
            # Create vnodes proportional to weight
            num_vnodes = int(weight * vnodes_per_weight)
            for i in range(num_vnodes):
                vnode_key = f"{server}:{i}"
                hash_value = self._hash(vnode_key)
                self.ring[hash_value] = server
        
        self.sorted_keys = sorted(self.ring.keys())
    
    def _hash(self, key):
        return int(hashlib.md5(key.encode()).hexdigest(), 16)
    
    def get_server(self, key):
        if not self.ring:
            return None
        
        hash_value = self._hash(str(key))
        
        # Binary search for next server on ring
        idx = self._binary_search(hash_value)
        return self.ring[self.sorted_keys[idx]]
    
    def _binary_search(self, hash_value):
        left, right = 0, len(self.sorted_keys) - 1
        
        while left < right:
            mid = (left + right) // 2
            if self.sorted_keys[mid] < hash_value:
                left = mid + 1
            else:
                right = mid
        
        # Wrap around if hash exceeds all keys
        return left % len(self.sorted_keys)
```

Virtual node count determines distribution granularity. Higher vnode counts improve balance at the cost of increased memory consumption and lookup overhead. Typical ratios: 100-500 vnodes per weight unit.

### Session Affinity with Weighted Distribution

Session affinity (sticky sessions) requires routing requests from the same client to the same server. Weighted distribution applies during initial session assignment.

```python
class WeightedStickyLoadBalancer:
    def __init__(self, servers):
        self.servers = servers  # (server, weight) tuples
        self.wrr = SmoothWeightedRoundRobin(servers)
        self.session_map = {}  # session_id -> server
        self.server_sessions = {srv: set() for srv, _ in servers}
    
    def get_server(self, session_id):
        # Return existing assignment if session exists
        if session_id in self.session_map:
            server = self.session_map[session_id]
            # Verify server still healthy
            if self._is_server_available(server):
                return server
            else:
                # Reassign if server failed
                self._remove_session(session_id)
        
        # New session: use weighted round robin
        server = self.wrr.next_server()
        self.session_map[session_id] = server
        self.server_sessions[server].add(session_id)
        return server
    
    def _remove_session(self, session_id):
        if session_id in self.session_map:
            server = self.session_map[session_id]
            self.server_sessions[server].discard(session_id)
            del self.session_map[session_id]
    
    def get_session_count(self, server):
        return len(self.server_sessions[server])
```

**Session Redistribution on Weight Changes:**

When increasing a server's weight, avoid disrupting existing sessions. Only apply new weights to new session assignments. When decreasing weight, gradually migrate sessions to maintain target ratios.

```python
def rebalance_sessions(self, target_weights):
    for server, target_weight in target_weights.items():
        current_sessions = self.get_session_count(server)
        total_sessions = sum(len(sessions) for sessions in self.server_sessions.values())
        
        target_count = int(total_sessions * (target_weight / sum(target_weights.values())))
        
        if current_sessions > target_count:
            # Migrate excess sessions
            excess = current_sessions - target_count
            sessions_to_migrate = list(self.server_sessions[server])[:excess]
            
            for session_id in sessions_to_migrate:
                new_server = self._select_underweighted_server(target_weights)
                self.session_map[session_id] = new_server
                self.server_sessions[server].discard(session_id)
                self.server_sessions[new_server].add(session_id)
```

### Weighted Priority Queuing

Priority-weighted load balancing combines request priority levels with server weights to optimize resource allocation for heterogeneous workloads.

```python
from queue import PriorityQueue
from dataclasses import dataclass, field
from typing import Any

@dataclass(order=True)
class PrioritizedRequest:
    priority: int
    timestamp: float = field(compare=False)
    request: Any = field(compare=False)

class WeightedPriorityBalancer:
    def __init__(self, servers):
        self.servers = {srv: w for srv, w in servers}
        self.queues = {srv: PriorityQueue() for srv in self.servers}
        self.processing = {srv: 0 for srv in self.servers}
    
    def enqueue_request(self, request, priority):
        # Select server with most available weighted capacity
        selected = max(
            self.servers.items(),
            key=lambda x: (x[1] - self.processing[x[0]] / x[1])
        )
        
        server = selected[0]
        self.queues[server].put(
            PrioritizedRequest(priority, time.time(), request)
        )
        return server
    
    def dequeue_request(self, server):
        if not self.queues[server].empty():
            prioritized = self.queues[server].get()
            self.processing[server] += 1
            return prioritized.request
        return None
    
    def complete_request(self, server):
        self.processing[server] -= 1
```

High-priority requests receive preferential routing to high-capacity servers, while lower-priority requests utilize remaining capacity. This pattern prevents priority inversion where low-priority tasks monopolize high-capacity resources.

### Weight Decay and Recovery

Gradually reduce weights for degraded servers while monitoring recovery signals. Prevents oscillation between healthy and unhealthy states.

```python
class WeightDecayManager:
    def __init__(self, servers, decay_rate=0.5, recovery_rate=0.1):
        self.configured_weights = {srv: w for srv, w in servers}
        self.current_weights = self.configured_weights.copy()
        self.decay_rate = decay_rate
        self.recovery_rate = recovery_rate
        self.error_counts = {srv: 0 for srv, _ in servers}
    
    def record_error(self, server):
        self.error_counts[server] += 1
        
        # Decay weight on error
        self.current_weights[server] = max(
            1,  # Minimum weight
            int(self.current_weights[server] * (1 - self.decay_rate))
        )
    
    def record_success(self, server):
        self.error_counts[server] = max(0, self.error_counts[server] - 1)
        
        # Gradual recovery toward configured weight
        if self.error_counts[server] == 0:
            configured = self.configured_weights[server]
            current = self.current_weights[server]
            
            if current < configured:
                self.current_weights[server] = int(
                    current + (configured - current) * self.recovery_rate
                )
    
    def get_effective_weight(self, server):
        return self.current_weights[server]
```

Exponential decay with linear recovery creates hysteresis preventing rapid weight fluctuations. Tune decay/recovery rates based on acceptable false positive tolerance and desired responsiveness.

### Distributed Weighted Load Balancing

Multiple load balancers coordinating weighted distribution require shared state synchronization or gossip protocols.

**Gossip-Based Weight Synchronization:**

```python
import time

class GossipWeightSync:
    def __init__(self, node_id, peers, servers):
        self.node_id = node_id
        self.peers = peers  # Other load balancer nodes
        self.server_weights = {srv: w for srv, w in servers}
        self.server_metrics = {srv: {'load': 0, 'timestamp': time.time()} 
                               for srv, _ in servers}
    
    def gossip_tick(self):
        # Select random peer
        peer = random.choice(self.peers)
        
        # Exchange server metrics
        peer_metrics = self._request_metrics(peer)
        
        for server, metrics in peer_metrics.items():
            # Update if peer has newer information
            if metrics['timestamp'] > self.server_metrics[server]['timestamp']:
                self.server_metrics[server] = metrics
    
    def calculate_distributed_weight(self, server):
        # Adjust weight based on globally observed load
        global_load = self.server_metrics[server]['load']
        base_weight = self.server_weights[server]
        
        # Reduce weight proportionally to observed load
        load_factor = 1.0 - min(0.9, global_load / base_weight)
        return int(base_weight * load_factor)
```

**[Inference]** Gossip convergence latency typically ranges from 3-10 gossip rounds depending on cluster size. Weight adjustments lag reality by this interval, requiring conservative adjustment rates to prevent overreaction.

### Monitoring and Observability

Track distribution effectiveness through metrics quantifying weight adherence and performance correlation.

**Key Metrics:**

```python
class WeightedBalancerMetrics:
    def __init__(self):
        self.request_counts = {}
        self.response_times = {}
        self.target_weights = {}
    
    def calculate_distribution_variance(self):
        """Measure deviation from target weight distribution"""
        total_requests = sum(self.request_counts.values())
        
        variance = 0
        for server, count in self.request_counts.items():
            actual_ratio = count / total_requests
            target_ratio = self.target_weights[server] / sum(self.target_weights.values())
            variance += (actual_ratio - target_ratio) ** 2
        
        return variance
    
    def calculate_weighted_response_time(self):
        """Aggregate response time weighted by server weights"""
        weighted_sum = 0
        total_weight = sum(self.target_weights.values())
        
        for server, rt in self.response_times.items():
            weight = self.target_weights[server]
            weighted_sum += rt * (weight / total_weight)
        
        return weighted_sum
```

Low distribution variance (<0.01) indicates effective weight enforcement. Weighted response time reveals whether high-weight servers deliver proportionally better performance.

**Weight Effectiveness Ratio:**

```
Effectiveness = (Expected Performance Improvement) / (Actual Performance Improvement)
```

Values near 1.0 confirm weight assignments accurately reflect capacity. Persistent deviations signal misconfigured weights or unmodeled performance factors.

### Related Topics

Load balancing algorithms, consistent hashing implementation, connection pool management, circuit breaker patterns, health check strategies, autoscaling integration with load balancers, geographic load distribution, anycast routing, BGP-based load balancing, Layer 4 vs Layer 7 load balancing, server capacity planning, request queuing theory, exponential moving averages for metrics, distributed consensus protocols for state synchronization, graceful degradation strategies.

---

## Auto-Scaling Patterns

### Horizontal Pod Autoscaler (HPA) Mechanics

**Metrics-Based Scaling**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 3
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
```

Scaling algorithm: `desiredReplicas = ceil(currentReplicas * (currentMetricValue / targetMetricValue))`

**Stabilization windows prevent flapping**: scale-up has 0s window (immediate response to load spikes), scale-down has 300s window (prevents premature reduction during temporary dips). Scale-up policies permit aggressive expansion (100% increase or +4 pods per 15s, whichever is greater). Scale-down applies conservative 50% reduction per minute.

**Custom Metrics Scaling**

```yaml
metrics:
- type: Pods
  pods:
    metric:
      name: http_requests_per_second
    target:
      type: AverageValue
      averageValue: "1000"
- type: External
  external:
    metric:
      name: queue_depth
      selector:
        matchLabels:
          queue_name: "processing_queue"
    target:
      type: Value
      value: "30"
```

External metrics enable scaling based on queue depth, message lag, or external service metrics. Requires metrics adapter (Prometheus Adapter, Datadog Cluster Agent).

**Multiple Metrics Interaction**

When multiple metrics are specified, HPA calculates desired replicas for each metric independently and selects the **maximum** value. Prevents under-provisioning when different metrics indicate different scaling needs.

### Predictive Scaling Algorithms

**Time-Series Forecasting Pattern**

```python
from sklearn.ensemble import RandomForestRegressor
import pandas as pd
import numpy as np

class PredictiveScaler:
    def __init__(self, lookback_hours=168):  # 1 week
        self.model = RandomForestRegressor(n_estimators=100)
        self.lookback_hours = lookback_hours
        
    def prepare_features(self, timestamps):
        """Extract temporal features for prediction"""
        df = pd.DataFrame({'timestamp': timestamps})
        df['hour'] = df['timestamp'].dt.hour
        df['day_of_week'] = df['timestamp'].dt.dayofweek
        df['day_of_month'] = df['timestamp'].dt.day
        df['is_weekend'] = df['day_of_week'].isin([5, 6]).astype(int)
        df['is_business_hours'] = df['hour'].between(9, 17).astype(int)
        return df[['hour', 'day_of_week', 'day_of_month', 
                   'is_weekend', 'is_business_hours']]
    
    def train(self, historical_data):
        """Train on historical load patterns"""
        X = self.prepare_features(historical_data['timestamp'])
        y = historical_data['request_rate']
        self.model.fit(X, y)
    
    def predict_load(self, target_time, current_capacity):
        """Predict load and calculate required capacity"""
        features = self.prepare_features(pd.Series([target_time]))
        predicted_load = self.model.predict(features)[0]
        
        # Add 20% buffer for prediction uncertainty
        required_capacity = predicted_load * 1.2
        
        # Calculate required replicas
        capacity_per_replica = 1000  # requests/sec per replica
        required_replicas = int(np.ceil(
            required_capacity / capacity_per_replica
        ))
        
        return max(required_replicas, 3)  # minimum 3 replicas
```

**Scheduled Scaling for Known Patterns**

```yaml
# Kubernetes CronJob for pre-emptive scaling
apiVersion: batch/v1
kind: CronJob
metadata:
  name: scale-up-business-hours
spec:
  schedule: "0 8 * * 1-5"  # 8 AM weekdays
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: scaler
            image: bitnami/kubectl
            command:
            - /bin/sh
            - -c
            - kubectl scale deployment web-app --replicas=20
          restartPolicy: OnFailure
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: scale-down-after-hours
spec:
  schedule: "0 18 * * 1-5"  # 6 PM weekdays
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: scaler
            image: bitnami/kubectl
            command:
            - /bin/sh
            - -c
            - kubectl scale deployment web-app --replicas=5
          restartPolicy: OnFailure
```

Combines reactive (HPA) and proactive (scheduled) scaling. Scheduled scaling sets baseline capacity before anticipated load, HPA handles unexpected variance.

### Queue-Based Worker Scaling

**KEDA ScaledObject Pattern**

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: worker-scaler
spec:
  scaleTargetRef:
    name: background-worker
  minReplicaCount: 2
  maxReplicaCount: 100
  pollingInterval: 15
  cooldownPeriod: 300
  triggers:
  - type: rabbitmq
    metadata:
      queueName: tasks
      mode: QueueLength
      value: "50"
      activationValue: "10"
    authenticationRef:
      name: rabbitmq-trigger-auth
  advanced:
    horizontalPodAutoscalerConfig:
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 300
          policies:
          - type: Percent
            value: 50
            periodSeconds: 120
```

**Scaling formula**: `desiredReplicas = ceil(queueLength / targetQueueLength)`

`activationValue: "10"` defines threshold to scale from 0→1 replicas (scale-from-zero capability). Below 10 messages: 0 replicas. Above 10: scale to handle load based on `value: "50"` target.

**SQS-Based Scaling Calculation**

```python
import boto3
from datetime import datetime, timedelta

class SQSWorkerScaler:
    def __init__(self, queue_url, target_processing_time_seconds=300):
        self.sqs = boto3.client('sqs')
        self.queue_url = queue_url
        self.target_time = target_processing_time_seconds
        
    def get_scaling_metrics(self):
        """Calculate required workers based on queue metrics"""
        response = self.sqs.get_queue_attributes(
            QueueUrl=self.queue_url,
            AttributeNames=[
                'ApproximateNumberOfMessages',
                'ApproximateNumberOfMessagesNotVisible',
                'ApproximateAgeOfOldestMessage'
            ]
        )
        
        attrs = response['Attributes']
        visible = int(attrs.get('ApproximateNumberOfMessages', 0))
        in_flight = int(attrs.get('ApproximateNumberOfMessagesNotVisible', 0))
        oldest_age = int(attrs.get('ApproximateAgeOfOldestMessage', 0))
        
        total_backlog = visible + in_flight
        
        # If oldest message exceeds target processing time, scale aggressively
        if oldest_age > self.target_time:
            urgency_multiplier = min(oldest_age / self.target_time, 3.0)
        else:
            urgency_multiplier = 1.0
        
        return {
            'backlog': total_backlog,
            'oldest_age': oldest_age,
            'urgency_multiplier': urgency_multiplier
        }
    
    def calculate_desired_workers(self, avg_processing_time_seconds,
                                   current_workers):
        """
        Calculate workers needed to drain queue within target time
        
        Formula:
        workers = (total_messages * avg_processing_time) / target_time
        """
        metrics = self.get_scaling_metrics()
        backlog = metrics['backlog']
        
        if backlog == 0:
            return max(1, current_workers // 2)  # Scale down conservatively
        
        # Calculate throughput needed
        total_processing_seconds = backlog * avg_processing_time_seconds
        required_workers = total_processing_seconds / self.target_time
        
        # Apply urgency multiplier if backlog is aging
        required_workers *= metrics['urgency_multiplier']
        
        # Round up and apply bounds
        return max(2, min(int(required_workers) + 1, 100))
```

**Backpressure-Aware Scaling**

```python
class BackpressureScaler:
    def __init__(self, max_queue_age_seconds=600):
        self.max_age = max_queue_age_seconds
        
    def calculate_scaling_decision(self, metrics):
        """
        Scale based on multiple signals:
        1. Queue depth
        2. Message age
        3. Worker utilization
        4. Processing latency
        """
        queue_depth = metrics['queue_depth']
        oldest_message_age = metrics['oldest_message_age']
        worker_cpu_utilization = metrics['worker_cpu_avg']
        p95_processing_latency = metrics['p95_latency']
        current_workers = metrics['current_workers']
        
        # Signal 1: Queue depth pressure
        if queue_depth > 1000:
            depth_signal = 2.0  # Aggressive scale-up
        elif queue_depth > 500:
            depth_signal = 1.5
        elif queue_depth < 50:
            depth_signal = 0.5  # Scale down signal
        else:
            depth_signal = 1.0
        
        # Signal 2: Age-based urgency
        if oldest_message_age > self.max_age:
            age_signal = 2.0
        elif oldest_message_age > self.max_age * 0.7:
            age_signal = 1.5
        else:
            age_signal = 1.0
        
        # Signal 3: Worker saturation
        if worker_cpu_utilization > 85:
            saturation_signal = 1.5
        elif worker_cpu_utilization < 30:
            saturation_signal = 0.5
        else:
            saturation_signal = 1.0
        
        # Signal 4: Processing latency degradation
        baseline_latency = metrics['baseline_p95_latency']
        if p95_processing_latency > baseline_latency * 2:
            latency_signal = 1.5
        else:
            latency_signal = 1.0
        
        # Combine signals (multiplicative for aggressive response)
        combined_multiplier = (
            depth_signal * age_signal * saturation_signal * latency_signal
        )
        
        desired_workers = int(current_workers * combined_multiplier)
        
        # Apply rate limits
        max_scale_up = int(current_workers * 2)  # Max 2x per cycle
        max_scale_down = int(current_workers * 0.7)  # Max 30% reduction
        
        if desired_workers > current_workers:
            return min(desired_workers, max_scale_up)
        else:
            return max(desired_workers, max_scale_down)
```

### Database Connection Pool Scaling

**Dynamic Pool Sizing Pattern**

```python
import psycopg2.pool
import threading
import time

class AdaptiveConnectionPool:
    def __init__(self, dsn, initial_size=5, max_size=50):
        self.dsn = dsn
        self.current_size = initial_size
        self.max_size = max_size
        self.min_size = 2
        
        self.pool = psycopg2.pool.ThreadedConnectionPool(
            minconn=self.min_size,
            maxconn=self.current_size,
            dsn=dsn
        )
        
        self.metrics = {
            'wait_time_ms': [],
            'active_connections': 0,
            'total_requests': 0
        }
        self.lock = threading.Lock()
        
        # Start monitoring thread
        self.monitor_thread = threading.Thread(
            target=self._monitor_and_adjust,
            daemon=True
        )
        self.monitor_thread.start()
    
    def get_connection(self):
        start_time = time.time()
        conn = self.pool.getconn()
        wait_time_ms = (time.time() - start_time) * 1000
        
        with self.lock:
            self.metrics['wait_time_ms'].append(wait_time_ms)
            self.metrics['active_connections'] += 1
            self.metrics['total_requests'] += 1
        
        return conn
    
    def return_connection(self, conn):
        self.pool.putconn(conn)
        with self.lock:
            self.metrics['active_connections'] -= 1
    
    def _monitor_and_adjust(self):
        """Adjust pool size based on usage patterns"""
        while True:
            time.sleep(30)  # Check every 30 seconds
            
            with self.lock:
                if not self.metrics['wait_time_ms']:
                    continue
                
                avg_wait_ms = sum(self.metrics['wait_time_ms']) / len(
                    self.metrics['wait_time_ms']
                )
                p95_wait_ms = sorted(self.metrics['wait_time_ms'])[
                    int(len(self.metrics['wait_time_ms']) * 0.95)
                ]
                utilization = (
                    self.metrics['active_connections'] / self.current_size
                )
                
                # Clear metrics for next window
                self.metrics['wait_time_ms'] = []
            
            # Scaling decision logic
            if p95_wait_ms > 100 and utilization > 0.8:
                # High wait time + high utilization = need more connections
                new_size = min(
                    int(self.current_size * 1.5),
                    self.max_size
                )
                self._resize_pool(new_size)
                
            elif avg_wait_ms < 10 and utilization < 0.3:
                # Low wait time + low utilization = too many connections
                new_size = max(
                    int(self.current_size * 0.7),
                    self.min_size
                )
                self._resize_pool(new_size)
    
    def _resize_pool(self, new_size):
        """Recreate pool with new size"""
        if new_size == self.current_size:
            return
        
        old_pool = self.pool
        self.pool = psycopg2.pool.ThreadedConnectionPool(
            minconn=self.min_size,
            maxconn=new_size,
            dsn=self.dsn
        )
        self.current_size = new_size
        
        # Close old pool after grace period
        threading.Timer(60, old_pool.closeall).start()
```

**Connection Pool Anti-Pattern**

```python
# ANTI-PATTERN: Fixed pool size regardless of application scale
pool = psycopg2.pool.SimpleConnectionPool(
    minconn=10,
    maxconn=10,  # Fixed at 10
    dsn=connection_string
)

# Problem 1: Application scales to 50 replicas
# 50 replicas × 10 connections = 500 total connections
# Database max_connections = 100
# Result: Connection exhaustion errors

# Problem 2: Single replica during low traffic
# Maintains 10 idle connections unnecessarily
# Wastes database resources
```

**Optimal Strategy**: Pool size should scale with replica count inversely.

```python
# Calculate per-replica pool size
database_max_connections = 100
expected_max_replicas = 50
reserved_connections = 10  # For admin, monitoring

available_connections = database_max_connections - reserved_connections
connections_per_replica = available_connections // expected_max_replicas

# Result: 90 / 50 = 1-2 connections per replica
# At max scale: 50 replicas × 2 = 100 connections (within limit)
```

### Circuit Breaker Integration with Auto-Scaling

**Failure-Driven Scaling Pattern**

```python
from circuitbreaker import circuit
import time

class ResilientScaler:
    def __init__(self):
        self.failure_threshold = 0.5  # 50% error rate
        self.scale_up_triggered = False
        self.window_size = 60  # seconds
        self.requests = []
        
    @circuit(failure_threshold=5, recovery_timeout=30)
    def call_downstream_service(self, request):
        """Circuit breaker protects downstream service"""
        response = requests.post(
            'http://downstream-api/process',
            json=request,
            timeout=5
        )
        response.raise_for_status()
        return response.json()
    
    def track_request(self, success):
        """Track request outcomes for scaling decisions"""
        now = time.time()
        self.requests.append({'timestamp': now, 'success': success})
        
        # Remove old requests outside window
        cutoff = now - self.window_size
        self.requests = [
            r for r in self.requests if r['timestamp'] > cutoff
        ]
        
        # Check if scaling needed
        if len(self.requests) > 20:
            error_rate = sum(
                1 for r in self.requests if not r['success']
            ) / len(self.requests)
            
            if error_rate > self.failure_threshold:
                self._trigger_emergency_scale()
    
    def _trigger_emergency_scale(self):
        """Scale up aggressively when circuit breaker activates"""
        if self.scale_up_triggered:
            return
        
        self.scale_up_triggered = True
        
        # Call Kubernetes API to scale up immediately
        # Bypasses normal HPA reaction time
        import subprocess
        subprocess.run([
            'kubectl', 'scale', 'deployment', 'api-service',
            '--replicas=50'  # Emergency capacity
        ])
        
        # Reset flag after cooldown
        threading.Timer(300, self._reset_emergency_flag).start()
    
    def _reset_emergency_flag(self):
        self.scale_up_triggered = False
```

**Cascading Failure Prevention**

```yaml
# Service mesh configuration (Istio)
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: downstream-api-circuit-breaker
spec:
  host: downstream-api
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        http2MaxRequests: 100
        maxRequestsPerConnection: 2
    outlierDetection:
      consecutiveErrors: 5
      interval: 30s
      baseEjectionTime: 60s
      maxEjectionPercent: 50
      minHealthPercent: 40
```

When 5 consecutive errors occur, eject pod from load balancer for 60s. Prevents cascade by isolating failing instances. Triggers auto-scaling if too many pods ejected (below `minHealthPercent`).

### Vertical Pod Autoscaler (VPA) Patterns

**VPA Configuration**

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: api-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-service
  updatePolicy:
    updateMode: "Auto"  # Recreate pods with new resources
  resourcePolicy:
    containerPolicies:
    - containerName: api
      minAllowed:
        cpu: 100m
        memory: 128Mi
      maxAllowed:
        cpu: 4
        memory: 8Gi
      controlledResources: ["cpu", "memory"]
      mode: Auto
```

**VPA vs HPA Trade-offs**

|Dimension|HPA|VPA|
|---|---|---|
|Scaling Direction|Horizontal (replica count)|Vertical (resource limits)|
|Response Time|Fast (seconds)|Slow (requires pod restart)|
|Stateful Workloads|Challenging|Better suited|
|Cost Efficiency|Lower (smaller instances)|Higher (larger instances)|
|Failure Domain|Distributed|Concentrated|

**Combined HPA + VPA Strategy**

```yaml
# VPA handles baseline resource optimization
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: worker-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: worker
  updatePolicy:
    updateMode: "Initial"  # Only set resources at creation
  resourcePolicy:
    containerPolicies:
    - containerName: worker
      mode: Auto
---
# HPA handles traffic bursts
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: worker-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: worker
  minReplicas: 5
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

VPA with `updateMode: Initial` sets optimal baseline resources without restarts. HPA scales replicas for load variance. Avoids conflicts between controllers.

### Cloud Provider Auto-Scaling Groups

**AWS Auto Scaling Group with Target Tracking**

```json
{
  "AutoScalingGroupName": "web-app-asg",
  "MinSize": 3,
  "MaxSize": 50,
  "DesiredCapacity": 5,
  "HealthCheckType": "ELB",
  "HealthCheckGracePeriod": 300,
  "TargetGroupARNs": ["arn:aws:elasticloadbalancing:..."],
  "VPCZoneIdentifier": "subnet-abc123,subnet-def456,subnet-ghi789",
  "Tags": [
    {
      "Key": "Environment",
      "Value": "production",
      "PropagateAtLaunch": true
    }
  ]
}
```

**Target Tracking Policy**

```json
{
  "TargetValue": 70.0,
  "PredefinedMetricSpecification": {
    "PredefinedMetricType": "ASGAverageCPUUtilization"
  },
  "ScaleInCooldown": 300,
  "ScaleOutCooldown": 60
}
```

Algorithm: If `AvgCPU > 70%`, scale out. If `AvgCPU < 63%` (70 × 0.9), scale in. 10% buffer prevents oscillation.

**Step Scaling Policy**

```json
{
  "MetricAggregationType": "Average",
  "AdjustmentType": "PercentChangeInCapacity",
  "StepAdjustments": [
    {
      "MetricIntervalLowerBound": 0,
      "MetricIntervalUpperBound": 10,
      "ScalingAdjustment": 10
    },
    {
      "MetricIntervalLowerBound": 10,
      "MetricIntervalUpperBound": 20,
      "ScalingAdjustment": 20
    },
    {
      "MetricIntervalLowerBound": 20,
      "ScalingAdjustment": 30
    }
  ]
}
```

CPU 70-80%: +10% capacity. CPU 80-90%: +20% capacity. CPU >90%: +30% capacity. Proportional response to severity.

**Cluster Autoscaler Interaction**

```yaml
# EKS Node Group with Cluster Autoscaler
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: production-cluster
  region: us-west-2
nodeGroups:
  - name: general-workers
    instanceType: m5.xlarge
    minSize: 3
    maxSize: 50
    desiredCapacity: 5
    iam:
      withAddonPolicies:
        autoScaler: true
    labels:
      workload-type: general
    tags:
      k8s.io/cluster-autoscaler/enabled: "true"
      k8s.io/cluster-autoscaler/production-cluster: "owned"
```

**Cluster Autoscaler Logic**

1. Pod scheduling fails due to insufficient node resources
2. Cluster Autoscaler detects pending pods
3. Calculates required node count based on pod resource requests
4. Triggers ASG scale-out
5. New nodes join cluster within 2-5 minutes
6. Pending pods scheduled to new nodes

**Scale-Down Prevention**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stateful-app
spec:
  template:
    metadata:
      annotations:
        cluster-autoscaler.kubernetes.io/safe-to-evict: "false"
    spec:
      containers:
      - name: app
        image: stateful-app:v1
```

Prevents Cluster Autoscaler from evicting pods during scale-down. Critical for stateful workloads without graceful migration.

### Rate Limiting Integration

**Adaptive Rate Limiting with Scaling**

```python
import redis
import time
from datetime import datetime, timedelta

class AdaptiveRateLimiter:
    def __init__(self, redis_client, base_limit_per_minute=1000):
        self.redis = redis_client
        self.base_limit = base_limit_per_minute
        
    def get_current_capacity(self):
        """Query Kubernetes API for current replica count"""
        import subprocess
        result = subprocess.run(
            ['kubectl', 'get', 'deployment', 'api-service', 
             '-o', 'jsonpath={.spec.replicas}'],
            capture_output=True,
            text=True
        )
        return int(result.stdout.strip())
    
    def calculate_rate_limit(self):
        """Scale rate limit with capacity"""
        current_replicas = self.get_current_capacity()
        
        # Each replica can handle base_limit requests/minute
        total_capacity = current_replicas * self.base_limit
        
        # Apply 80% utilization target to leave headroom
        effective_limit = int(total_capacity * 0.8)
        
        return effective_limit
    
    def check_rate_limit(self, user_id):
        """Token bucket algorithm with dynamic refill rate"""
        key = f"rate_limit:{user_id}"
        now = time.time()
        
        # Get current bucket state
        pipe = self.redis.pipeline()
        pipe.get(f"{key}:tokens")
        pipe.get(f"{key}:last_refill")
        tokens, last_refill = pipe.execute()
        
        tokens = float(tokens) if tokens else self.base_limit
        last_refill = float(last_refill) if last_refill else now
        
        # Calculate dynamic refill rate based on current capacity
        current_limit = self.calculate_rate_limit()
        refill_rate = current_limit / 60.0  # tokens per second
        
        # Refill tokens
        elapsed = now - last_refill
        tokens = min(
            current_limit,
            tokens + (elapsed * refill_rate)
        )
        
        # Check if request allowed
        if tokens >= 1:
            tokens -= 1
            pipe = self.redis.pipeline()
            pipe.set(f"{key}:tokens", tokens, ex=120)
            pipe.set(f"{key}:last_refill", now, ex=120)
            pipe.execute()
            return True
        else:
            return False
```

Rate limits scale proportionally with capacity. Prevents overload while maximizing throughput.

### Warm-Up and Cool-Down Periods

**Gradual Scale-Up Pattern**

```python
class GradualScaler:
    def __init__(self, initial_replicas=3, warmup_duration_minutes=10):
        self.initial_replicas = initial_replicas
        self.warmup_duration = warmup_duration_minutes * 60
        self.scale_start_time = None
        
    def calculate_warmup_replicas(self, target_replicas):
        """
        Gradually increase replicas during warmup period
        Prevents cold start cascading failures
        """
        if self.scale_start_time is None:
            self.scale_start_time = time.time()
        
        elapsed = time.time() - self.scale_start_time
        
        if elapsed >= self.warmup_duration:
            return target_replicas
        
        # Linear warmup progression
        progress = elapsed / self.warmup_duration
        current_replicas = self.initial_replicas + (
            (target_replicas - self.initial_replicas) * progress
        )
        
        return int(current_replicas)
    
    def apply_scaling(self, target_replicas):
        """Apply scaling with warmup consideration"""
        import subprocess
        
        warmup_replicas = self.calculate_warmup_replicas(target_replicas)
        
        subprocess.run([
            'kubectl', 'scale', 'deployment', 'api-service',
            f'--replicas={warmup_replicas}'
        ])
        
        print(f"Scaled to {warmup_replicas}/{target_replicas} "
              f"(warmup in progress)")
```

**JVM Warm-Up Consideration**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: java-app
spec:
  template:
    spec:
      containers:
      - name: app
        image: java-app:v1
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 60  # Wait for JVM warmup
          periodSeconds: 5
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8080
          initialDelaySeconds: 90
          periodSeconds: 10
        lifecycle:
          postStart:
            exec:
              command:
              - /bin/sh
              - -c
              - |
                # Trigger JIT compilation warmup
                curl -X POST http://localhost:8080/admin/warmup
```

Delays traffic routing until JIT compiler optimizes hot paths. Prevents performance degradation during scale-up.

### Cost-Aware Scaling Strategies

**Spot Instance Integration**

```yaml
# Karpenter NodePool with spot instances
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: spot-workers
spec:
  template:
    spec:
      requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values: ["spot"]
      - key: kubernetes.io/arch
        operator: In
        values: ["amd64"]
      - key: node.kubernetes.io/instance-type
        operator: In
        values: ["m5.xlarge", "m5.2xlarge", "m5a.xlarge", "m5a.2xlarge"]
  limits:
    cpu: 1000
  disruption:
    consolidationPolicy: WhenUnderutilized
    expireAfter: 720h
```

**Priority-Based Workload Placement**

```yaml
# High-priority workloads on on-demand instances
apiVersion: v1
kind: Pod
metadata:
  name: critical-api
spec:
  priorityClassName: high-priority
  nodeSelector:
    karpenter.sh/capacity-type: on-demand
  tolerations:
  - key: workload-priority
    operator: Equal
    value: high
    effect: NoSchedule
---
# Low-priority workloads on spot instances
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-processing
spec:
  template:
    spec:
      priorityClassName: low-priority
      nodeSelector:
        karpenter.sh/capacity-type: spot
      tolerations:
      - key: karpenter.sh/disruption
        operator: Exists
```

**Cost-Optimized Scaling Algorithm**

```python
class CostOptimizedScaler:
    def __init__(self):
        self.on_demand_cost_per_hour = 0.192  # m5.xlarge
        self.spot_cost_per_hour = 0.058       # ~70% savings
        self.spot_interruption_rate = 0.05    # 5% per hour
        
    def calculate_optimal_mix(self, required_capacity, 
                              criticality_score):
        """
        Determine spot vs on-demand ratio based on workload criticality
        
        criticality_score: 0.0 (batch) to 1.0 (critical API)
        """
        # High criticality = more on-demand instances
        on_demand_ratio = criticality_score
        spot_ratio = 1 - criticality_score
        
        on_demand_instances = int(required_capacity * on_demand_ratio)
        spot_instances = int(required_capacity * spot_ratio)
        
        # Always maintain minimum on-demand capacity
        on_demand_instances = max(on_demand_instances, 2)
        
        # Calculate expected cost
        on_demand_cost = on_demand_instances * self.on_demand_cost_per_hour
        spot_cost = spot_instances * self.spot_cost_per_hour
        
        # Factor in interruption risk cost
        interruption_cost = (
            spot_instances * 
            self.spot_interruption_rate * 
            100  # Cost of service disruption
        )
        
        total_cost = on_demand_cost + spot_cost + interruption_cost
        
        return {
            'on_demand': on_demand_instances,
            'spot': spot_instances,
            'estimated_hourly_cost': total_cost
        }
```

### Anti-Patterns

**Thrashing: Overly Aggressive Scaling**

```yaml
# ANTI-PATTERN: No stabilization window
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: thrashing-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: unstable-app
  minReplicas: 5
  maxReplicas: 100
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0  # Immediate reaction
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 0  # Immediate reaction
      policies:
      - type: Percent
        value: 50
        periodSeconds: 15
```

**Problem**: CPU spikes trigger rapid scale-up. New pods start, CPU drops. Triggers immediate scale-down. Cycle repeats. Results in constant pod churn, degraded performance during termination.

**Solution**: Asymmetric stabilization windows (fast scale-up, slow scale-down).

**Incorrect Metric Selection**

```yaml
# ANTI-PATTERN: Memory-based scaling for stateless apps
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: memory-based-hpa
spec:
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

**Problem**: Memory utilization increases gradually with uptime (caching, internal state). Not correlated with traffic. Triggers scale-up even during low traffic. Scaled pods also accumulate memory over time, triggering further scale-ups.

**Solution**: Scale on request rate, queue depth, or CPU utilization for stateless apps. Use memory limits to prevent OOM, not as scaling trigger.

**Cold Start Amplification**

```python
# ANTI-PATTERN: Scaling without health checks
def scale_workers(target_count):
    # Immediately add workers
    for i in range(target_count):
        start_worker()
    
    # Workers begin processing immediately
    # But initialization incomplete:
    # - Connection pools not established
    # - Caches empty
    # - JIT not warmed up
    
    # Result: All new workers fail requests
    # Triggers further scale-up
    # Cascading failure
```

**Solution**: Implement readiness probes, gradual traffic shifting, warmup periods.

### Related Topics

Load balancing algorithms, service mesh traffic management, chaos engineering for scaling validation, cost optimization strategies, Kubernetes resource quotas and limits, database connection pooling, distributed caching layers, container orchestration patterns, observability and metrics collection, capacity planning methodologies

---

## Scale-Out Database Patterns (Scalability Patterns)

### Horizontal Partitioning (Sharding)

Sharding distributes data across multiple database instances based on a partition key, enabling linear scalability beyond single-server hardware limits.

**Shard Key Selection Criteria:**

- High cardinality prevents hotspot concentration
- Even distribution across key space avoids imbalanced shards
- Query pattern alignment minimizes cross-shard operations
- Immutability prevents costly resharding operations

```python
# Hash-based sharding
def get_shard(user_id, num_shards=16):
    return hash(user_id) % num_shards

# Range-based sharding
def get_shard_by_range(user_id):
    if user_id < 1000000:
        return 'shard_0'
    elif user_id < 2000000:
        return 'shard_1'
    else:
        return 'shard_2'

# Geography-based sharding
def get_shard_by_region(user_id):
    region = get_user_region(user_id)
    return REGION_SHARD_MAP[region]  # {'us-east': 'shard_0', 'eu-west': 'shard_1'}
```

**Anti-pattern: Naive Modulo Sharding:**

```python
# Adding/removing shards requires complete data redistribution
shard_id = user_id % 4  # Works for 4 shards
# Scaling to 5 shards: 80% of data moves to different shards
```

**Correct: Consistent Hashing:**

```python
import hashlib
from bisect import bisect_right

class ConsistentHashRing:
    def __init__(self, nodes, virtual_nodes=150):
        self.virtual_nodes = virtual_nodes
        self.ring = {}
        self.sorted_keys = []
        
        for node in nodes:
            self.add_node(node)
    
    def _hash(self, key):
        return int(hashlib.md5(str(key).encode()).hexdigest(), 16)
    
    def add_node(self, node):
        for i in range(self.virtual_nodes):
            virtual_key = f"{node}:{i}"
            hash_value = self._hash(virtual_key)
            self.ring[hash_value] = node
            self.sorted_keys.append(hash_value)
        self.sorted_keys.sort()
    
    def get_node(self, key):
        if not self.ring:
            return None
        hash_value = self._hash(key)
        index = bisect_right(self.sorted_keys, hash_value) % len(self.sorted_keys)
        return self.ring[self.sorted_keys[index]]

# Adding node redistributes only K/N keys (K=total keys, N=nodes)
ring = ConsistentHashRing(['shard_0', 'shard_1', 'shard_2', 'shard_3'])
shard = ring.get_node(user_id)
```

### Shard Routing Layer

Centralized routing logic isolates application code from sharding topology changes.

```python
class ShardRouter:
    def __init__(self, shard_map):
        self.shard_map = shard_map  # {shard_id: connection_string}
        self.connections = {}
        self._initialize_connections()
    
    def _initialize_connections(self):
        for shard_id, conn_string in self.shard_map.items():
            self.connections[shard_id] = create_engine(
                conn_string,
                pool_size=10,
                max_overflow=20
            )
    
    def route(self, shard_key):
        shard_id = self._get_shard_id(shard_key)
        return self.connections[shard_id]
    
    def execute_on_shard(self, shard_key, query, params):
        engine = self.route(shard_key)
        with engine.connect() as conn:
            return conn.execute(query, params)
    
    def scatter_gather(self, query, params, aggregator=None):
        """Execute query on all shards and aggregate results"""
        results = []
        with ThreadPoolExecutor(max_workers=len(self.connections)) as executor:
            futures = {
                executor.submit(self._execute_on_shard, shard_id, query, params): shard_id
                for shard_id in self.connections.keys()
            }
            
            for future in as_completed(futures):
                results.append(future.result())
        
        return aggregator(results) if aggregator else results
    
    def _execute_on_shard(self, shard_id, query, params):
        with self.connections[shard_id].connect() as conn:
            return conn.execute(query, params).fetchall()
```

**Query Router with Shard Awareness:**

```python
class QueryAnalyzer:
    def analyze(self, query, params):
        """Determine which shards are required for query"""
        if 'user_id' in params:
            # Single shard query
            return [self.router.get_shard_id(params['user_id'])]
        elif 'user_ids' in params:
            # Multi-shard query with known keys
            return list(set(
                self.router.get_shard_id(uid) for uid in params['user_ids']
            ))
        else:
            # Broadcast query (all shards)
            return self.router.get_all_shard_ids()

# Application usage
def get_users(user_ids):
    shards = analyzer.analyze(query, {'user_ids': user_ids})
    results = []
    
    for shard_id in shards:
        shard_user_ids = [uid for uid in user_ids if router.get_shard_id(uid) == shard_id]
        shard_results = router.execute_on_shard(
            shard_id,
            "SELECT * FROM users WHERE id = ANY(:ids)",
            {'ids': shard_user_ids}
        )
        results.extend(shard_results)
    
    return results
```

### Cross-Shard Transactions

Distributed transactions across shards require coordination protocols with significant complexity and performance overhead.

**Two-Phase Commit (2PC):**

```python
class TwoPhaseCommitCoordinator:
    def __init__(self, shard_router):
        self.router = shard_router
    
    def execute_distributed_transaction(self, operations):
        """
        operations: [(shard_key, sql, params), ...]
        """
        transaction_id = uuid.uuid4()
        participating_shards = {}
        
        # Phase 1: Prepare
        try:
            for shard_key, sql, params in operations:
                shard_id = self.router.get_shard_id(shard_key)
                if shard_id not in participating_shards:
                    participating_shards[shard_id] = []
                participating_shards[shard_id].append((sql, params))
            
            prepared_shards = []
            for shard_id, ops in participating_shards.items():
                if self._prepare(shard_id, transaction_id, ops):
                    prepared_shards.append(shard_id)
                else:
                    raise TransactionAbortError(f"Shard {shard_id} failed prepare")
            
            # Phase 2: Commit
            for shard_id in prepared_shards:
                self._commit(shard_id, transaction_id)
            
            return True
            
        except Exception as e:
            # Rollback all prepared shards
            for shard_id in prepared_shards:
                self._rollback(shard_id, transaction_id)
            raise
    
    def _prepare(self, shard_id, txn_id, operations):
        conn = self.router.get_connection(shard_id)
        try:
            conn.execute("BEGIN")
            for sql, params in operations:
                conn.execute(sql, params)
            conn.execute("PREPARE TRANSACTION %s", (str(txn_id),))
            return True
        except Exception:
            conn.execute("ROLLBACK")
            return False
    
    def _commit(self, shard_id, txn_id):
        conn = self.router.get_connection(shard_id)
        conn.execute("COMMIT PREPARED %s", (str(txn_id),))
    
    def _rollback(self, shard_id, txn_id):
        conn = self.router.get_connection(shard_id)
        conn.execute("ROLLBACK PREPARED %s", (str(txn_id),))
```

**Saga Pattern (Compensating Transactions):**

```python
class SagaCoordinator:
    def __init__(self, shard_router):
        self.router = shard_router
    
    def execute_saga(self, steps):
        """
        steps: [(forward_fn, compensate_fn), ...]
        Each function returns (shard_id, success)
        """
        executed_steps = []
        
        try:
            for forward_fn, compensate_fn in steps:
                result = forward_fn()
                executed_steps.append((result, compensate_fn))
                
                if not result['success']:
                    raise SagaFailureError(f"Step failed: {result}")
            
            return True
            
        except Exception as e:
            # Execute compensating transactions in reverse
            for result, compensate_fn in reversed(executed_steps):
                try:
                    compensate_fn(result)
                except Exception as comp_error:
                    # Log compensation failure - requires manual intervention
                    logger.critical(f"Compensation failed: {comp_error}")
            raise

# Usage example: Transfer money across shards
def transfer_money(from_user_id, to_user_id, amount):
    def debit_forward():
        shard = router.get_shard_id(from_user_id)
        conn = router.get_connection(shard)
        conn.execute(
            "UPDATE accounts SET balance = balance - :amount WHERE user_id = :user_id",
            {'amount': amount, 'user_id': from_user_id}
        )
        return {'success': True, 'user_id': from_user_id, 'amount': amount}
    
    def debit_compensate(result):
        shard = router.get_shard_id(result['user_id'])
        conn = router.get_connection(shard)
        conn.execute(
            "UPDATE accounts SET balance = balance + :amount WHERE user_id = :user_id",
            {'amount': result['amount'], 'user_id': result['user_id']}
        )
    
    def credit_forward():
        shard = router.get_shard_id(to_user_id)
        conn = router.get_connection(shard)
        conn.execute(
            "UPDATE accounts SET balance = balance + :amount WHERE user_id = :user_id",
            {'amount': amount, 'user_id': to_user_id}
        )
        return {'success': True, 'user_id': to_user_id, 'amount': amount}
    
    def credit_compensate(result):
        shard = router.get_shard_id(result['user_id'])
        conn = router.get_connection(shard)
        conn.execute(
            "UPDATE accounts SET balance = balance - :amount WHERE user_id = :user_id",
            {'amount': result['amount'], 'user_id': result['user_id']}
        )
    
    saga = SagaCoordinator(router)
    saga.execute_saga([
        (debit_forward, debit_compensate),
        (credit_forward, credit_compensate)
    ])
```

### Shard Rebalancing

Redistributing data when adding/removing shards or addressing imbalance.

**Online Resharding Strategy:**

```python
class ReshardingCoordinator:
    def __init__(self, source_shard, target_shard):
        self.source = source_shard
        self.target = target_shard
        self.state = 'PREPARING'
    
    def reshard_range(self, key_range_start, key_range_end):
        """
        1. Dual-write phase: writes go to both shards
        2. Bulk copy phase: copy existing data
        3. Catch-up phase: copy missed updates
        4. Cutover phase: redirect reads to new shard
        """
        
        # Phase 1: Enable dual writes
        self._enable_dual_write(key_range_start, key_range_end)
        
        # Phase 2: Bulk copy
        batch_size = 10000
        cursor = key_range_start
        
        while cursor < key_range_end:
            batch = self._read_batch(self.source, cursor, batch_size)
            self._write_batch(self.target, batch)
            cursor = batch[-1]['id'] if batch else key_range_end
        
        # Phase 3: Catch-up
        changelog = self._get_changelog(key_range_start, key_range_end)
        for change in changelog:
            self._apply_change(self.target, change)
        
        # Phase 4: Cutover
        self._update_routing_table(key_range_start, key_range_end, self.target)
        
        # Phase 5: Cleanup
        self._disable_dual_write(key_range_start, key_range_end)
        self._delete_migrated_data(self.source, key_range_start, key_range_end)
    
    def _enable_dual_write(self, start, end):
        """Configure routing layer to write to both shards"""
        routing_config = {
            'range': (start, end),
            'primary': self.target.id,
            'secondary': self.source.id,
            'mode': 'DUAL_WRITE'
        }
        self.routing_table.update(routing_config)
    
    def _get_changelog(self, start, end):
        """Get changes since bulk copy started"""
        return self.source.query(
            """
            SELECT * FROM changelog 
            WHERE key >= :start AND key < :end 
            AND timestamp > :bulk_copy_start
            ORDER BY timestamp
            """,
            {'start': start, 'end': end, 'bulk_copy_start': self.bulk_copy_start}
        )
```

**Vitess-Style Resharding:**

```python
# Vitess uses filtered replication for resharding
class VitessResharding:
    def split_shard(self, source_shard, target_shards):
        """
        Split single shard into multiple target shards
        """
        # 1. Create target shards
        for target in target_shards:
            self._create_shard_schema(target)
        
        # 2. Start filtered replication
        for target in target_shards:
            keyrange = target.keyrange
            self._start_filtered_replication(
                source=source_shard,
                target=target,
                filter=f"WHERE keyspace_id >= {keyrange[0]} AND keyspace_id < {keyrange[1]}"
            )
        
        # 3. Wait for replication to catch up
        self._wait_for_catchup(target_shards)
        
        # 4. Stop writes to source
        self._set_read_only(source_shard)
        
        # 5. Wait for final catch-up
        self._wait_for_catchup(target_shards)
        
        # 6. Update serving graph
        self._update_serving_graph(source_shard, target_shards)
        
        # 7. Start serving from targets
        for target in target_shards:
            self._set_serving(target)
        
        # 8. Remove source shard
        self._remove_shard(source_shard)
```

### Read Scaling with Replicas

Distribute read load across replica instances while maintaining write consistency on primary.

**Primary-Replica Routing:**

```python
class PrimaryReplicaRouter:
    def __init__(self, primary_conn, replica_conns):
        self.primary = primary_conn
        self.replicas = replica_conns
        self.replica_index = 0
    
    def execute_write(self, query, params):
        """All writes go to primary"""
        return self.primary.execute(query, params)
    
    def execute_read(self, query, params, consistency='eventual'):
        """Route reads based on consistency requirement"""
        if consistency == 'strong':
            return self.primary.execute(query, params)
        elif consistency == 'eventual':
            return self._get_replica().execute(query, params)
        elif consistency == 'bounded':
            # Read from replica with bounded staleness check
            replica = self._get_replica()
            lag = self._check_replication_lag(replica)
            if lag > 5:  # 5 second threshold
                return self.primary.execute(query, params)
            return replica.execute(query, params)
    
    def _get_replica(self):
        """Round-robin load balancing"""
        replica = self.replicas[self.replica_index]
        self.replica_index = (self.replica_index + 1) % len(self.replicas)
        return replica
    
    def _check_replication_lag(self, replica):
        """Check seconds behind primary"""
        result = replica.execute(
            "SELECT EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp()))"
        )
        return result.scalar()
```

**Session Consistency (Read-Your-Writes):**

```python
class SessionConsistentRouter:
    def __init__(self, primary, replicas):
        self.primary = primary
        self.replicas = replicas
        self.session_lsn = {}  # session_id -> last LSN written
    
    def execute_write(self, session_id, query, params):
        result = self.primary.execute(query, params)
        # Store LSN for this session
        lsn = self.primary.execute("SELECT pg_current_wal_lsn()").scalar()
        self.session_lsn[session_id] = lsn
        return result
    
    def execute_read(self, session_id, query, params):
        required_lsn = self.session_lsn.get(session_id)
        
        if required_lsn is None:
            # No writes in this session, use any replica
            return self._get_replica().execute(query, params)
        
        # Find replica that has caught up to required LSN
        for replica in self.replicas:
            replay_lsn = replica.execute("SELECT pg_last_wal_replay_lsn()").scalar()
            if replay_lsn >= required_lsn:
                return replica.execute(query, params)
        
        # Fall back to primary if no replica is caught up
        return self.primary.execute(query, params)
```

### Geographic Distribution

Distribute data across regions for latency reduction and regulatory compliance.

**Multi-Region Active-Active:**

```python
class MultiRegionRouter:
    def __init__(self, region_clusters):
        """
        region_clusters: {
            'us-east': {'primary': conn, 'replicas': [conn1, conn2]},
            'eu-west': {'primary': conn, 'replicas': [conn1, conn2]},
            'ap-south': {'primary': conn, 'replicas': [conn1, conn2]}
        }
        """
        self.clusters = region_clusters
        self.local_region = self._detect_region()
    
    def execute_write(self, key, query, params):
        """Route write to owning region's primary"""
        owning_region = self._get_owning_region(key)
        cluster = self.clusters[owning_region]
        
        # Write to local region's primary
        result = cluster['primary'].execute(query, params)
        
        # Asynchronously replicate to other regions
        self._replicate_to_other_regions(owning_region, query, params)
        
        return result
    
    def execute_read(self, key, query, params):
        """Read from local region for lowest latency"""
        cluster = self.clusters[self.local_region]
        
        # Check if data exists locally
        local_result = cluster['replicas'][0].execute(query, params)
        
        if local_result:
            return local_result
        
        # Fall back to owning region
        owning_region = self._get_owning_region(key)
        if owning_region != self.local_region:
            cluster = self.clusters[owning_region]
            return cluster['replicas'][0].execute(query, params)
        
        return None
    
    def _get_owning_region(self, key):
        """Determine data home region based on key"""
        # Option 1: Hash-based
        region_count = len(self.clusters)
        region_idx = hash(key) % region_count
        return list(self.clusters.keys())[region_idx]
        
        # Option 2: User-defined affinity
        # return USER_REGION_MAP.get(key, self.local_region)
```

**GDPR-Compliant Data Residency:**

```python
class DataResidencyRouter:
    def __init__(self):
        self.region_regulations = {
            'EU': ['eu-west-1', 'eu-central-1'],
            'US': ['us-east-1', 'us-west-2'],
            'APAC': ['ap-south-1', 'ap-southeast-1']
        }
        self.user_region_map = {}  # user_id -> regulatory_region
    
    def execute_query(self, user_id, query, params):
        """Ensure data stays within regulatory boundaries"""
        regulatory_region = self._get_regulatory_region(user_id)
        allowed_regions = self.region_regulations[regulatory_region]
        
        # Route to compliant region
        target_region = self._select_region(allowed_regions)
        return self._execute_in_region(target_region, query, params)
    
    def migrate_user_data(self, user_id, from_region, to_region):
        """Handle GDPR data portability requests"""
        if not self._validate_migration(from_region, to_region):
            raise ComplianceError("Migration violates data residency")
        
        # Extract user data
        data = self._extract_user_data(user_id, from_region)
        
        # Write to target region
        self._write_user_data(user_id, to_region, data)
        
        # Update routing
        self.user_region_map[user_id] = to_region
        
        # Delete from source (after verification)
        self._delete_user_data(user_id, from_region)
```

### Federated Queries

Execute queries across multiple shards and aggregate results.

**Query Federation Engine:**

```python
class FederatedQueryEngine:
    def __init__(self, shard_router):
        self.router = shard_router
    
    def execute_federated_query(self, sql, params=None):
        """Execute query across all shards and merge results"""
        plan = self._create_execution_plan(sql, params)
        
        if plan['type'] == 'SINGLE_SHARD':
            shard_id = plan['shard_id']
            return self.router.execute_on_shard(shard_id, sql, params)
        
        elif plan['type'] == 'SCATTER_GATHER':
            return self._scatter_gather(sql, params, plan['aggregation'])
        
        elif plan['type'] == 'HIERARCHICAL':
            return self._hierarchical_aggregation(sql, params, plan)
    
    def _scatter_gather(self, sql, params, aggregation):
        """Parallel execution across shards"""
        shard_ids = self.router.get_all_shard_ids()
        
        with ThreadPoolExecutor(max_workers=len(shard_ids)) as executor:
            futures = {
                executor.submit(
                    self.router.execute_on_shard, shard_id, sql, params
                ): shard_id
                for shard_id in shard_ids
            }
            
            results = []
            for future in as_completed(futures):
                try:
                    results.append(future.result())
                except Exception as e:
                    logger.error(f"Shard query failed: {e}")
        
        return self._merge_results(results, aggregation)
    
    def _merge_results(self, results, aggregation):
        """Merge shard results based on aggregation type"""
        if aggregation == 'SUM':
            return sum(r[0]['total'] for r in results)
        
        elif aggregation == 'COUNT':
            return sum(r[0]['count'] for r in results)
        
        elif aggregation == 'AVG':
            total_sum = sum(r[0]['sum'] for r in results)
            total_count = sum(r[0]['count'] for r in results)
            return total_sum / total_count if total_count > 0 else 0
        
        elif aggregation == 'ORDER_BY':
            # Merge sorted results
            all_rows = [row for result in results for row in result]
            return sorted(all_rows, key=lambda x: x['sort_key'])
        
        elif aggregation == 'LIMIT':
            # Top-K from each shard
            all_rows = [row for result in results for row in result]
            return sorted(all_rows, key=lambda x: x['sort_key'])[:aggregation['limit']]
    
    def _create_execution_plan(self, sql, params):
        """Analyze query to determine execution strategy"""
        parsed = sqlparse.parse(sql)[0]
        
        # Extract WHERE clause for shard key
        where_clause = self._extract_where(parsed)
        if self._contains_shard_key(where_clause, params):
            return {'type': 'SINGLE_SHARD', 'shard_id': self._get_shard_from_where(where_clause, params)}
        
        # Check for aggregation
        if self._is_aggregation(parsed):
            agg_type = self._get_aggregation_type(parsed)
            return {'type': 'SCATTER_GATHER', 'aggregation': agg_type}
        
        # Default: scatter-gather with merge
        return {'type': 'SCATTER_GATHER', 'aggregation': 'MERGE'}
```

**Distributed JOIN Optimization:**

```python
class DistributedJoinOptimizer:
    def __init__(self, shard_router):
        self.router = shard_router
    
    def execute_distributed_join(self, left_table, right_table, join_condition):
        """
        Strategies:
        1. Broadcast join: Small table broadcast to all shards
        2. Repartition join: Shuffle both tables by join key
        3. Collocated join: Tables already co-partitioned
        """
        
        left_size = self._estimate_table_size(left_table)
        right_size = self._estimate_table_size(right_table)
        
        if left_size < 1000000:  # 1M rows threshold
            return self._broadcast_join(left_table, right_table, join_condition)
        elif self._is_collocated(left_table, right_table, join_condition):
            return self._collocated_join(left_table, right_table, join_condition)
        else:
            return self._repartition_join(left_table, right_table, join_condition)
    
    def _broadcast_join(self, small_table, large_table, join_condition):
        """Broadcast small table to all shards"""
        # Load entire small table
        small_data = self._load_table(small_table)
        
        # Execute join on each shard with broadcasted data
        shard_ids = self.router.get_all_shard_ids()
        results = []
        
        for shard_id in shard_ids:
            shard_result = self.router.execute_on_shard(
                shard_id,
                f"""
                SELECT * FROM {large_table} l
                JOIN temp_broadcast b ON {join_condition}
                """,
                {'broadcast_data': small_data}
            )
            results.extend(shard_result)
        
        return results
    
    def _collocated_join(self, left_table, right_table, join_condition):
        """Execute join locally on each shard"""
        shard_ids = self.router.get_all_shard_ids()
        results = []
        
        with ThreadPoolExecutor(max_workers=len(shard_ids)) as executor:
            futures = [
                executor.submit(
                    self.router.execute_on_shard,
                    shard_id,
                    f"SELECT * FROM {left_table} l JOIN {right_table} r ON {join_condition}",
                    None
                )
                for shard_id in shard_ids
            ]
            
            for future in as_completed(futures):
                results.extend(future.result())
        
        return results
```

### Shard Metadata Management

Centralized metadata store tracks shard topology, routing rules, and state.

```python
class ShardMetadataStore:
    def __init__(self, metadata_db):
        self.db = metadata_db
        self._initialize_schema()
    
    def _initialize_schema(self):
        self.db.execute("""
            CREATE TABLE IF NOT EXISTS shards (
                shard_id VARCHAR(50) PRIMARY KEY,
                host VARCHAR(255) NOT NULL,
                port INTEGER NOT NULL,
                status VARCHAR(20) NOT NULL,
                weight INTEGER DEFAULT 100,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            
            CREATE TABLE IF NOT EXISTS shard_ranges (
                range_id SERIAL PRIMARY KEY,
                shard_id VARCHAR(50) REFERENCES shards(shard_id),
                key_start BIGINT NOT NULL,
                key_end BIGINT NOT NULL,
                status VARCHAR(20) NOT NULL,
                UNIQUE(key_start, key_end)
            );
            
            CREATE TABLE IF NOT EXISTS shard_topology_version (
                version INTEGER PRIMARY KEY,
                applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
    
    def register_shard(self, shard_id, host, port):
        """Add new shard to cluster"""
        self.db.execute(
            """
            INSERT INTO shards (shard_id, host, port, status)
            VALUES (:shard_id, :host, :port, 'ACTIVE')
            """,
            {'shard_id': shard_id, 'host': host, 'port': port}
        )
        self._increment_topology_version()
    
    def assign_range(self, shard_id, key_start, key_end):
        """Assign key range to shard"""
        self.db.execute(
            """
            INSERT INTO shard_ranges (shard_id, key_start, key_end, status)
            VALUES (:shard_id, :start, :end, 'ACTIVE')
            """,
            {'shard_id': shard_id, 'start': key_start, 'end': key_end}
        )
    
    def get_shard_for_key(self, key):
        """Lookup shard for given key"""
        result = self.db.execute(
            """
            SELECT s.shard_id, s.host, s.port
            FROM shard_ranges sr
            JOIN shards s ON sr.shard_id = s.shard_id
            WHERE :key >= sr.key_start AND :key < sr.key_end
            AND sr.status = 'ACTIVE' AND s.status = 'ACTIVE'
            LIMIT 1
            """,
            {'key': key}
        ).fetchone()
        
        return result
    
    def get_topology_version(self):
        """Get current topology version for cache invalidation"""
        return self.db.execute( "SELECT MAX(version) FROM shard_topology_version" ).scalar()

	def _increment_topology_version(self):
	    current = self.get_topology_version() or 0
	    self.db.execute(
	        "INSERT INTO shard_topology_version (version) VALUES (:v)",
	        {'v': current + 1}
	    )
````

**Topology Change Propagation:**

```python
class TopologyWatcher:
    def __init__(self, metadata_store, poll_interval=5):
        self.store = metadata_store
        self.interval = poll_interval
        self.current_version = 0
        self.callbacks = []
    
    def register_callback(self, callback):
        """Register callback for topology changes"""
        self.callbacks.append(callback)
    
    def start_watching(self):
        """Poll for topology changes"""
        while True:
            new_version = self.store.get_topology_version()
            
            if new_version > self.current_version:
                logger.info(f"Topology changed: {self.current_version} -> {new_version}")
                
                # Notify all registered callbacks
                for callback in self.callbacks:
                    try:
                        callback(new_version)
                    except Exception as e:
                        logger.error(f"Callback failed: {e}")
                
                self.current_version = new_version
            
            time.sleep(self.interval)

# Usage
def on_topology_change(new_version):
    # Refresh routing cache
    router.refresh_shard_map()
    logger.info(f"Router updated to version {new_version}")

watcher = TopologyWatcher(metadata_store)
watcher.register_callback(on_topology_change)
threading.Thread(target=watcher.start_watching, daemon=True).start()
````

### Global Secondary Indexes

Maintain indexes across sharded data for non-shard-key queries.

**Scatter-Gather Index:**

```python
class GlobalSecondaryIndex:
    def __init__(self, shard_router):
        self.router = shard_router
    
    def query_by_secondary_key(self, index_name, value):
        """Query all shards and aggregate results"""
        shard_ids = self.router.get_all_shard_ids()
        
        results = []
        with ThreadPoolExecutor(max_workers=len(shard_ids)) as executor:
            futures = [
                executor.submit(
                    self._query_shard_index,
                    shard_id,
                    index_name,
                    value
                )
                for shard_id in shard_ids
            ]
            
            for future in as_completed(futures):
                shard_results = future.result()
                results.extend(shard_results)
        
        return results
    
    def _query_shard_index(self, shard_id, index_name, value):
        return self.router.execute_on_shard(
            shard_id,
            f"SELECT * FROM users WHERE {index_name} = :value",
            {'value': value}
        )
```

**Materialized Global Index:**

```python
class MaterializedGlobalIndex:
    def __init__(self, shard_router, index_shard):
        self.router = shard_router
        self.index_shard = index_shard  # Dedicated shard for index
    
    def maintain_index(self, table_name, index_column):
        """Keep global index synchronized with data shards"""
        # Listen to changes on data shards
        for shard_id in self.router.get_all_shard_ids():
            self._setup_trigger(shard_id, table_name, index_column)
    
    def _setup_trigger(self, shard_id, table_name, index_column):
        """Create trigger to propagate changes to global index"""
        self.router.execute_on_shard(
            shard_id,
            f"""
            CREATE OR REPLACE FUNCTION update_global_index()
            RETURNS TRIGGER AS $$
            BEGIN
                -- Publish change event to message queue
                PERFORM pg_notify('global_index_update',
                    json_build_object(
                        'table', '{table_name}',
                        'column', '{index_column}',
                        'old_value', OLD.{index_column},
                        'new_value', NEW.{index_column},
                        'shard_id', '{shard_id}',
                        'primary_key', NEW.id
                    )::text
                );
                RETURN NEW;
            END;
            $$ LANGUAGE plpgsql;
            
            CREATE TRIGGER global_index_trigger
            AFTER INSERT OR UPDATE OR DELETE ON {table_name}
            FOR EACH ROW EXECUTE FUNCTION update_global_index();
            """,
            None
        )
    
    def query_index(self, index_column, value):
        """Query global index to find data location"""
        result = self.index_shard.execute(
            """
            SELECT shard_id, primary_key
            FROM global_index
            WHERE index_column = :column AND index_value = :value
            """,
            {'column': index_column, 'value': value}
        ).fetchall()
        
        # Fetch actual data from identified shards
        data = []
        for row in result:
            shard_data = self.router.execute_on_shard(
                row['shard_id'],
                "SELECT * FROM users WHERE id = :id",
                {'id': row['primary_key']}
            )
            data.extend(shard_data)
        
        return data
```

**Related topics:** Distributed consensus protocols, Shard migration strategies, Multi-version concurrency control, Cross-datacenter replication, Automatic failover mechanisms

---

## Database Sharding

Database sharding partitions data horizontally across multiple independent database instances (shards), distributing both data and query load. Each shard contains a subset of the total dataset, operates autonomously, and shares nothing with other shards. Sharding enables linear scalability beyond single-server limits but introduces significant complexity in data distribution, query routing, and operational management.

### Sharding Fundamentals

**Shard Key Selection** The shard key determines data distribution and query routing efficiency. Critical characteristics:

- **High Cardinality**: Sufficient distinct values to distribute evenly across shards
- **Query Pattern Alignment**: Most queries should filter on shard key to enable single-shard routing
- **Immutability**: Changing shard keys requires expensive data migration
- **Even Distribution**: Avoid hotspots from skewed value distribution

**Shard Key Anti-Patterns**

```sql
-- Bad: Low cardinality (boolean/enum)
shard_key: user.is_premium  -- Only 2 shards possible

-- Bad: Sequential/temporal
shard_key: order.created_at  -- Recent data concentrates on newest shard

-- Bad: Correlated with access patterns
shard_key: user.country WHERE popular_countries = ['US', 'UK']  -- Geographic hotspots
```

**Effective Shard Key Examples**

```sql
-- Good: High cardinality user identifier
shard_key: user_id (UUID/BIGINT with hash function)

-- Good: Composite key for multi-tenant systems
shard_key: (tenant_id, user_id)

-- Good: Hash of sequential key to break monotonicity
shard_key: HASH(order_id) % shard_count
```

### Sharding Strategies

**Range-Based Sharding**

```python
class RangeShardRouter:
    def __init__(self, ranges: List[Tuple[int, int, str]]):
        # List of (min, max, shard_id) tuples
        self.ranges = sorted(ranges, key=lambda x: x[0])
    
    def get_shard(self, key: int) -> str:
        for min_val, max_val, shard_id in self.ranges:
            if min_val <= key <= max_val:
                return shard_id
        raise ValueError(f"No shard found for key {key}")
    
    def add_shard(self, new_shard_id: str):
        # Rebalancing requires splitting existing ranges
        # Typically splits the largest range
        largest_range = max(self.ranges, key=lambda x: x[1] - x[0])
        min_val, max_val, old_shard = largest_range
        
        split_point = (min_val + max_val) // 2
        
        self.ranges.remove(largest_range)
        self.ranges.append((min_val, split_point, old_shard))
        self.ranges.append((split_point + 1, max_val, new_shard_id))
        self.ranges.sort(key=lambda x: x[0])
```

**Advantages:**

- Simple range queries span minimal shards
- Natural data locality (e.g., time-series data)
- Efficient for sequential scans within ranges

**Disadvantages:**

- Vulnerable to hotspots with skewed distributions
- Complex rebalancing when adding shards
- Requires monitoring for range boundary adjustments

**Hash-Based Sharding**

```python
class ConsistentHashRouter:
    def __init__(self, shards: List[str], virtual_nodes: int = 150):
        self.virtual_nodes = virtual_nodes
        self.ring = {}
        self.sorted_keys = []
        
        for shard in shards:
            self.add_shard(shard)
    
    def _hash(self, key: str) -> int:
        return int(hashlib.md5(key.encode()).hexdigest(), 16)
    
    def add_shard(self, shard_id: str):
        for i in range(self.virtual_nodes):
            virtual_key = f"{shard_id}:{i}"
            hash_val = self._hash(virtual_key)
            self.ring[hash_val] = shard_id
        
        self.sorted_keys = sorted(self.ring.keys())
    
    def remove_shard(self, shard_id: str):
        for i in range(self.virtual_nodes):
            virtual_key = f"{shard_id}:{i}"
            hash_val = self._hash(virtual_key)
            if hash_val in self.ring:
                del self.ring[hash_val]
        
        self.sorted_keys = sorted(self.ring.keys())
    
    def get_shard(self, key: str) -> str:
        if not self.ring:
            raise ValueError("No shards available")
        
        hash_val = self._hash(str(key))
        
        # Binary search for next position on ring
        idx = bisect.bisect(self.sorted_keys, hash_val)
        if idx == len(self.sorted_keys):
            idx = 0
        
        return self.ring[self.sorted_keys[idx]]
    
    def get_distribution(self, sample_size: int = 10000) -> Dict[str, int]:
        distribution = defaultdict(int)
        for i in range(sample_size):
            shard = self.get_shard(str(i))
            distribution[shard] += 1
        return dict(distribution)
```

**Advantages:**

- Uniform distribution with good hash function
- Minimal data movement when adding/removing shards (consistent hashing)
- No hotspot risk from sequential keys

**Disadvantages:**

- Range queries require scatter-gather across all shards
- No data locality
- Hash function must remain stable across schema versions

**Directory-Based Sharding**

```python
class DirectoryShardRouter:
    def __init__(self, directory_db_config: dict):
        self.directory_db = self._connect(directory_db_config)
        self.cache = LRUCache(maxsize=10000)
    
    def get_shard(self, key: int) -> str:
        # Check cache first
        cached = self.cache.get(key)
        if cached:
            return cached
        
        # Query directory database
        result = self.directory_db.execute(
            'SELECT shard_id FROM shard_directory WHERE key = ?',
            (key,)
        ).fetchone()
        
        if not result:
            raise ValueError(f"No shard mapping for key {key}")
        
        shard_id = result['shard_id']
        self.cache.put(key, shard_id)
        return shard_id
    
    def migrate_key(self, key: int, target_shard: str):
        # Update directory
        self.directory_db.execute(
            'UPDATE shard_directory SET shard_id = ? WHERE key = ?',
            (target_shard, key)
        )
        
        # Invalidate cache
        self.cache.delete(key)
    
    def rebalance(self, source_shard: str, target_shard: str, key_count: int):
        # Select keys to migrate (e.g., least recently accessed)
        keys = self.directory_db.execute('''
            SELECT key FROM shard_directory
            WHERE shard_id = ?
            ORDER BY last_accessed ASC
            LIMIT ?
        ''', (source_shard, key_count)).fetchall()
        
        # Batch update
        self.directory_db.executemany(
            'UPDATE shard_directory SET shard_id = ? WHERE key = ?',
            [(target_shard, k['key']) for k in keys]
        )
        
        # Clear cache for migrated keys
        for k in keys:
            self.cache.delete(k['key'])
```

**Advantages:**

- Flexible mapping allows arbitrary data distribution
- Easy migration of individual keys between shards
- Supports complex sharding strategies (geographic, customer tier)

**Disadvantages:**

- Directory database becomes single point of failure
- Additional latency from directory lookup
- Directory can become bottleneck under high load
- Requires caching strategy for performance

**Geo-Based Sharding**

```python
class GeoShardRouter:
    def __init__(self, geo_mapping: Dict[str, str]):
        # Map region codes to shard IDs
        self.geo_mapping = geo_mapping
        self.default_shard = 'global-shard'
    
    def get_shard(self, user_region: str) -> str:
        return self.geo_mapping.get(user_region, self.default_shard)
    
    def get_shards_for_regions(self, regions: List[str]) -> List[str]:
        return list(set(
            self.geo_mapping.get(r, self.default_shard) 
            for r in regions
        ))

# Usage
router = GeoShardRouter({
    'US-EAST': 'shard-us-east-1',
    'US-WEST': 'shard-us-west-1',
    'EU': 'shard-eu-central-1',
    'ASIA': 'shard-asia-pacific-1'
})
```

**Advantages:**

- Reduced latency through geographic proximity
- Regulatory compliance (data residency requirements)
- Fault isolation by geography

**Disadvantages:**

- Uneven load distribution across regions
- Complex cross-region queries
- Difficult capacity planning per region

### Query Routing Architecture

**Application-Level Routing**

```python
class ShardedDatabase:
    def __init__(self, router: ShardRouter, shard_configs: Dict[str, dict]):
        self.router = router
        self.connections = {
            shard_id: self._create_connection(config)
            for shard_id, config in shard_configs.items()
        }
    
    def execute(self, query: str, params: dict):
        shard_key = params.get('shard_key')
        if not shard_key:
            raise ValueError("Query must include shard_key parameter")
        
        shard_id = self.router.get_shard(shard_key)
        conn = self.connections[shard_id]
        
        return conn.execute(query, params)
    
    def execute_scatter_gather(self, query: str, params: dict) -> List[dict]:
        """Execute query across all shards and merge results"""
        futures = []
        
        with ThreadPoolExecutor(max_workers=len(self.connections)) as executor:
            for shard_id, conn in self.connections.items():
                future = executor.submit(conn.execute, query, params)
                futures.append((shard_id, future))
        
        results = []
        errors = []
        
        for shard_id, future in futures:
            try:
                shard_results = future.result(timeout=30)
                results.extend(shard_results)
            except Exception as e:
                errors.append(f"Shard {shard_id} failed: {str(e)}")
        
        if errors:
            raise ShardQueryError(errors)
        
        return results
    
    def execute_aggregation(
        self, 
        query: str, 
        params: dict,
        merge_fn: Callable[[List[dict]], dict]
    ) -> dict:
        """Execute aggregation across shards with custom merge logic"""
        shard_results = self.execute_scatter_gather(query, params)
        return merge_fn(shard_results)
```

**Proxy-Level Routing (Vitess/ProxySQL Pattern)**

```yaml
# Vitess VSchema configuration
shards:
  - name: "user_shard"
    sharded: true
    vindexes:
      hash:
        type: "hash"
    tables:
      - name: "users"
        column_vindexes:
          - column: "user_id"
            name: "hash"
      - name: "orders"
        column_vindexes:
          - column: "user_id"
            name: "hash"
        # Co-locate orders with users
```

**Middleware Routing Layer**

```python
class ShardingMiddleware:
    def __init__(self, app, router: ShardRouter):
        self.app = app
        self.router = router
    
    def __call__(self, environ, start_response):
        request = Request(environ)
        
        # Extract shard key from request
        shard_key = self._extract_shard_key(request)
        
        if shard_key:
            shard_id = self.router.get_shard(shard_key)
            # Inject shard context into request
            request.environ['shard.id'] = shard_id
            request.environ['shard.key'] = shard_key
        
        return self.app(environ, start_response)
    
    def _extract_shard_key(self, request: Request) -> Optional[str]:
        # Check JWT token
        token = request.headers.get('Authorization')
        if token:
            payload = jwt.decode(token)
            return payload.get('user_id')
        
        # Check URL path
        match = re.match(r'/users/(\d+)/', request.path)
        if match:
            return match.group(1)
        
        # Check query parameters
        return request.args.get('user_id')
```

### Cross-Shard Operations

**Distributed Transactions (Two-Phase Commit)**

```python
class DistributedTransaction:
    def __init__(self, shards: List[DatabaseConnection]):
        self.shards = shards
        self.prepared = set()
    
    def execute(self, operations: List[Tuple[str, str, dict]]) -> bool:
        """
        operations: List of (shard_id, query, params)
        """
        try:
            # Phase 1: Prepare
            for shard_id, query, params in operations:
                shard = self._get_shard(shard_id)
                shard.execute('BEGIN')
                shard.execute(query, params)
                shard.execute('PREPARE TRANSACTION ?', (self._tx_id(),))
                self.prepared.add(shard_id)
            
            # Phase 2: Commit
            for shard_id in self.prepared:
                shard = self._get_shard(shard_id)
                shard.execute('COMMIT PREPARED ?', (self._tx_id(),))
            
            return True
            
        except Exception as e:
            # Rollback all prepared transactions
            for shard_id in self.prepared:
                try:
                    shard = self._get_shard(shard_id)
                    shard.execute('ROLLBACK PREPARED ?', (self._tx_id(),))
                except Exception as rollback_error:
                    # Log rollback failure - requires manual intervention
                    logger.error(f"Failed to rollback {shard_id}: {rollback_error}")
            
            raise TransactionError(f"Distributed transaction failed: {e}")
    
    def _tx_id(self) -> str:
        return f"dtx_{uuid.uuid4()}"
    
    def _get_shard(self, shard_id: str) -> DatabaseConnection:
        return next(s for s in self.shards if s.id == shard_id)
```

**[Inference]** Two-phase commit provides strong consistency but introduces significant latency and availability concerns. Each participating shard must remain available throughout both phases, and coordinator failure requires complex recovery procedures.

**Saga Pattern for Eventual Consistency**

```python
class SagaOrchestrator:
    def __init__(self, shards: Dict[str, DatabaseConnection]):
        self.shards = shards
        self.compensations = []
    
    def execute_saga(self, steps: List[SagaStep]) -> bool:
        """
        Execute saga with compensation on failure
        """
        completed_steps = []
        
        try:
            for step in steps:
                shard = self.shards[step.shard_id]
                result = shard.execute(step.forward_query, step.params)
                
                completed_steps.append(step)
                
                # Store compensation action
                if step.compensation_query:
                    self.compensations.append((
                        step.shard_id,
                        step.compensation_query,
                        result  # May need result data for compensation
                    ))
            
            return True
            
        except Exception as e:
            # Execute compensations in reverse order
            logger.warning(f"Saga failed at step {len(completed_steps)}, compensating...")
            
            for shard_id, compensation_query, context in reversed(self.compensations):
                try:
                    shard = self.shards[shard_id]
                    shard.execute(compensation_query, context)
                except Exception as comp_error:
                    # Log compensation failure - system may be inconsistent
                    logger.error(f"Compensation failed for {shard_id}: {comp_error}")
            
            raise SagaError(f"Saga execution failed: {e}")

@dataclass
class SagaStep:
    shard_id: str
    forward_query: str
    compensation_query: Optional[str]
    params: dict

# Usage example: Transfer balance between sharded accounts
saga = SagaOrchestrator(shards)
saga.execute_saga([
    SagaStep(
        shard_id='shard-1',
        forward_query='UPDATE accounts SET balance = balance - ? WHERE id = ?',
        compensation_query='UPDATE accounts SET balance = balance + ? WHERE id = ?',
        params={'amount': 100, 'account_id': 'A123'}
    ),
    SagaStep(
        shard_id='shard-2',
        forward_query='UPDATE accounts SET balance = balance + ? WHERE id = ?',
        compensation_query='UPDATE accounts SET balance = balance - ? WHERE id = ?',
        params={'amount': 100, 'account_id': 'B456'}
    )
])
```

**Scatter-Gather with Result Merging**

```python
class ScatterGatherExecutor:
    def __init__(self, shards: Dict[str, DatabaseConnection]):
        self.shards = shards
        self.timeout = 30  # seconds
    
    def query_all_shards(
        self,
        query: str,
        params: dict,
        merge_strategy: str = 'union'
    ) -> List[dict]:
        """
        Execute query across all shards in parallel
        """
        with ThreadPoolExecutor(max_workers=len(self.shards)) as executor:
            futures = {
                executor.submit(shard.execute, query, params): shard_id
                for shard_id, shard in self.shards.items()
            }
            
            results = []
            failed_shards = []
            
            for future in as_completed(futures, timeout=self.timeout):
                shard_id = futures[future]
                try:
                    shard_result = future.result()
                    results.extend(shard_result)
                except Exception as e:
                    failed_shards.append((shard_id, str(e)))
            
            if failed_shards:
                logger.error(f"Shards failed: {failed_shards}")
                # Decide whether to return partial results or fail completely
                if len(failed_shards) > len(self.shards) * 0.5:
                    raise ShardQueryError("Majority of shards failed")
        
        return self._merge_results(results, merge_strategy)
    
    def _merge_results(self, results: List[dict], strategy: str) -> List[dict]:
        if strategy == 'union':
            return results
        
        elif strategy == 'distinct':
            # Remove duplicates based on ID
            seen = set()
            unique = []
            for row in results:
                row_id = row.get('id')
                if row_id not in seen:
                    seen.add(row_id)
                    unique.append(row)
            return unique
        
        elif strategy == 'ordered':
            # Merge sorted results (assumes each shard returns sorted data)
            return list(heapq.merge(
                *[iter(results)],
                key=lambda x: x.get('sort_key')
            ))
        
        else:
            raise ValueError(f"Unknown merge strategy: {strategy}")
    
    def aggregate_count(self, query: str, params: dict) -> int:
        """Count aggregation across shards"""
        results = self.query_all_shards(query, params)
        return sum(row.get('count', 0) for row in results)
    
    def aggregate_sum(self, query: str, params: dict, field: str) -> float:
        """Sum aggregation across shards"""
        results = self.query_all_shards(query, params)
        return sum(float(row.get(field, 0)) for row in results)
    
    def aggregate_avg(self, query: str, params: dict, field: str) -> float:
        """
        Average aggregation - requires count and sum from each shard
        Query must return both sum and count
        """
        results = self.query_all_shards(query, params)
        total_sum = sum(float(row.get(f'{field}_sum', 0)) for row in results)
        total_count = sum(int(row.get(f'{field}_count', 0)) for row in results)
        
        return total_sum / total_count if total_count > 0 else 0
```

### Data Co-location Strategies

**Hierarchical Sharding**

```python
"""
Co-locate related entities on same shard using parent's shard key
Example: Users and their orders on same shard
"""

class HierarchicalShardRouter:
    def __init__(self, base_router: ShardRouter):
        self.base_router = base_router
        self.hierarchy = {
            'orders': 'users',
            'order_items': 'orders',
            'reviews': 'users'
        }
    
    def get_shard(self, entity_type: str, entity_id: int, parent_id: Optional[int] = None) -> str:
        # Navigate to root entity
        root_type = self._get_root_entity(entity_type)
        root_id = parent_id if parent_id else entity_id
        
        # Route based on root entity's shard key
        return self.base_router.get_shard(root_id)
    
    def _get_root_entity(self, entity_type: str) -> str:
        current = entity_type
        while current in self.hierarchy:
            current = self.hierarchy[current]
        return current

# Schema design for co-location
"""
CREATE TABLE users (
    user_id BIGINT PRIMARY KEY,
    name VARCHAR(255),
    -- Shard key: user_id
);

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    user_id BIGINT,  -- Co-location key
    total DECIMAL(10,2),
    -- Composite shard key: user_id
    -- Physical storage on same shard as user
);

CREATE TABLE order_items (
    item_id BIGINT PRIMARY KEY,
    order_id BIGINT,
    user_id BIGINT,  -- Denormalized for routing
    product_id BIGINT,
    -- Composite shard key: user_id
);
"""
```

**Denormalization for Single-Shard Queries**

```sql
-- Anti-pattern: Requires cross-shard join
SELECT o.*, u.name, u.email
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE o.order_id = ?;

-- Pattern: Denormalize frequently accessed fields
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    user_id BIGINT,
    user_name VARCHAR(255),  -- Denormalized
    user_email VARCHAR(255), -- Denormalized
    total DECIMAL(10,2)
);

-- Now single-shard query
SELECT * FROM orders WHERE order_id = ?;
```

### Shard Rebalancing

**Live Migration with Dual Writes**

```python
class ShardMigration:
    def __init__(
        self,
        source_shard: DatabaseConnection,
        target_shard: DatabaseConnection,
        router: ShardRouter
    ):
        self.source = source_shard
        self.target = target_shard
        self.router = router
        self.migration_state = {}
    
    def migrate_key_range(
        self,
        table: str,
        shard_key: str,
        start_key: int,
        end_key: int
    ):
        """
        Four-phase migration:
        1. Bulk copy historical data
        2. Enable dual writes
        3. Catch-up replication
        4. Switch reads and disable dual writes
        """
        
        # Phase 1: Bulk copy
        logger.info(f"Phase 1: Bulk copying {table} [{start_key}, {end_key}]")
        batch_size = 1000
        current_key = start_key
        
        while current_key <= end_key:
            rows = self.source.execute(f'''
                SELECT * FROM {table}
                WHERE {shard_key} >= ? AND {shard_key} < ?
                ORDER BY {shard_key}
                LIMIT ?
            ''', (current_key, min(current_key + batch_size, end_key + 1), batch_size))
            
            if rows:
                self._bulk_insert(self.target, table, rows)
                current_key = rows[-1][shard_key] + 1
            else:
                break
        
        # Phase 2: Enable dual writes
        logger.info(f"Phase 2: Enabling dual writes for {table}")
        self.migration_state[(table, start_key, end_key)] = 'dual_write'
        
        # Phase 3: Catch-up replication for changes during bulk copy
        logger.info(f"Phase 3: Catch-up replication for {table}")
        self._replicate_changes(table, shard_key, start_key, end_key)
        
        # Phase 4: Switch reads
        logger.info(f"Phase 4: Switching reads to target shard")
        self.router.update_mapping(start_key, end_key, self.target.shard_id)
        
        # Verify data consistency
        if self._verify_migration(table, shard_key, start_key, end_key):
            logger.info(f"Migration complete for {table} [{start_key}, {end_key}]")
            self.migration_state[(table, start_key, end_key)] = 'complete'
            # Can now delete from source after retention period
        else:
            raise MigrationError("Data verification failed")
    
    def dual_write(self, table: str, operation: str, data: dict):
        """Write to both source and target during migration"""
        shard_key_value = data.get(self._get_shard_key(table))
        
        # Check if this key is being migrated
        is_migrating = any(
            start <= shard_key_value <= end and state == 'dual_write'
            for (tbl, start, end), state in self.migration_state.items()
            if tbl == table
        )
        
        if is_migrating:
            # Write to both shards
            self.source.execute(self._build_query(operation, table), data)
            self.target.execute(self._build_query(operation, table), data)
        else:
            # Normal single-shard write
            shard = self.router.get_shard(shard_key_value)
            shard.execute(self._build_query(operation, table), data)
    
    def _verify_migration(
        self,
        table: str,
        shard_key: str,
        start_key: int,
        end_key: int
    ) -> bool:
        """Verify data consistency between source and target"""
        source_checksum = self.source.execute(f'''
            SELECT COUNT(*), SUM(CAST(id AS BIGINT)) as checksum
            FROM {table}
            WHERE {shard_key} >= ? AND {shard_key} <= ?
        ''', (start_key, end_key)).fetchone()
        
        target_checksum = self.target.execute(f'''
            SELECT COUNT(*), SUM(CAST(id AS BIGINT)) as checksum
            FROM {table}
            WHERE {shard_key} >= ? AND {shard_key} <= ?
        ''', (start_key, end_key)).fetchone()
        
        return (source_checksum['COUNT'] == target_checksum['COUNT'] and
                source_checksum['checksum'] == target_checksum['checksum'])
```

**Consistent Hashing for Minimal Disruption** Virtual nodes in consistent hashing minimize data movement:

```
Adding 1 shard to 10-shard cluster:
- Without consistent hashing: ~10% of all data moves (to new shard)
- With consistent hashing (100 vnodes): ~1/101 = 0.99% moves per vnode
```

### Monitoring and Observability

**Shard Metrics Collection**

```python
class ShardMetrics:
    def __init__(self, metrics_backend):
        self.backend = metrics_backend
    
    def track_query(
        self,
        shard_id: str,
        query_type: str,
        duration_ms: float,
        is_cross_shard: bool
    ):
        self.backend.histogram(
            'shard.query.duration',
            duration_ms,
            tags={
                'shard_id': shard_id,
                'query_type': query_type,
                'cross_shard': is_cross_shard
            }
        )
    
    def track_shard_size(self, shard_id: str, table: str, row_count: int, size_bytes: int):
        self.backend.gauge('shard.size.rows', row_count, tags={'shard_id': shard_id, 'table': table})
        self.backend.gauge('shard.size.bytes', size_bytes, tags={'shard_id': shard_id, 'table': table})
    
    def track_hotspot(self, shard_id: str, qps: float):
        self.backend.gauge('shard.qps', qps, tags={'shard_id': shard_id})
        
        # Alert if shard QPS > 2x cluster average
        avg_qps = self._get_cluster_avg_qps()
        if qps > avg_qps * 2:
            self.backend.event('shard.hotspot', {
                'shard_id': shard_id,
                'qps': qps,
                'avg_qps': avg_qps
            })
    
    def track_cross_shard_query(self, shard_count: int, duration_ms: float):
        self.backend.histogram(
            'query.cross_shard.duration',
            duration_ms,
            tags={'shard_count': shard_count}
        )
```

**Shard Health Monitoring**

```python
class ShardHealthCheck:
    def __init__(self, shards: Dict[str, DatabaseConnection]):
        self.shards = shards
        self.health_status = {}
    
    def check_all_shards(self) -> Dict[str, str]:
        """Returns health status for each shard"""
        with ThreadPoolExecutor(max_workers=len(self.shards)) as executor:
            futures = {
                executor.submit(self._check_shard, shard_id, conn): shard_id
                for shard_id, conn in self.shards.items()
            }
            
            for future in as_completed(futures):
                shard_id = futures[future]
                try:
                    status = future.result(timeout=5)
                    self.health_status[shard_id] = status
                except Exception as e:
                    self.health_status[shard_id] = f'UNHEALTHY: {str(e)}'
        
        return self.health_status
    
    def _check_shard(self, shard_id: str, conn: DatabaseConnection) -> str:
        # Basic connectivity
        try:
            conn.execute('SELECT 1')
        except Exception as e: 
	        return f'UNREACHABLE: {str(e)}'

	    # Replication lag (if applicable)
	    lag = self._check_replication_lag(conn)
	    if lag > 10:  # seconds
	        return f'LAGGING: {lag}s behind'
	    
	    # Disk space
	    disk_usage = self._check_disk_usage(conn)
	    if disk_usage > 0.85:
	        return f'LOW_DISK: {disk_usage*100:.1f}% used'
	    
	    # Connection pool
	    pool_usage = conn.pool.active_connections / conn.pool.max_size
	    if pool_usage > 0.9:
	        return f'POOL_EXHAUSTED: {pool_usage*100:.1f}% used'
	    
	    return 'HEALTHY'
````

### Anti-Patterns and Pitfalls

**Inappropriate Shard Key Selection**
```python
# Anti-pattern: Using tenant_id as shard key in multi-tenant system
# Problem: Large tenants create hotspots
shard_key = tenant_id

# Better: Composite key distributes large tenants
shard_key = HASH(tenant_id, user_id)
````

**Cross-Shard Foreign Keys**

```sql
-- Anti-pattern: Foreign key references across shards
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    user_id BIGINT,
    product_id BIGINT REFERENCES products(id)  -- products may be on different shard
);

-- Pattern: Denormalize or use application-level referential integrity
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    user_id BIGINT,
    product_id BIGINT,  -- No FK constraint
    product_name VARCHAR(255),  -- Denormalized
    product_price DECIMAL(10,2)  -- Snapshot at order time
);
```

**Global Secondary Indexes**

```python
# Anti-pattern: Attempting to maintain global index across shards
# Query: "Find all orders with status='pending' across all shards"
# Solution 1: Scatter-gather (slow but accurate)
# Solution 2: Duplicate data to dedicated search index (Elasticsearch)
# Solution 3: Include shard key in queries: "Find pending orders for user X"
```

**Ignoring Clock Skew**

```python
# Anti-pattern: Using server-generated timestamps across shards
CREATE TABLE events (
    id BIGINT PRIMARY KEY,
    user_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Different on each shard
);

# Pattern: Use client-provided timestamp or distributed clock
# Or use hybrid logical clocks (HLC) for ordering
```

**Over-Sharding**

```python
# Anti-pattern: Creating too many shards prematurely
# Problem: Operational overhead, increased latency, wasted resources
shards = [f"shard-{i}" for i in range(1000)]  # Excessive for small dataset

# Pattern: Start with appropriate shard count based on data size
# Rule of thumb: 1 shard per 50-100GB of data
# Can always split shards later
```

### Advanced Patterns

**Hot Shard Mitigation**

```python
class HotShardDetector:
    def __init__(self, threshold_multiplier: float = 3.0):
        self.threshold_multiplier = threshold_multiplier
        self.metrics_window = deque(maxlen=60)  # 1 minute
    
    def record_metrics(self, shard_metrics: Dict[str, float]):
        """Record QPS per shard"""
        self.metrics_window.append(shard_metrics)
    
    def detect_hot_shards(self) -> List[str]:
        if not self.metrics_window:
            return []
        
        # Calculate average QPS across all shards
        avg_qps = {}
        for metrics in self.metrics_window:
            for shard_id, qps in metrics.items():
                if shard_id not in avg_qps:
                    avg_qps[shard_id] = []
                avg_qps[shard_id].append(qps)
        
        mean_qps = {
            shard: sum(values) / len(values)
            for shard, values in avg_qps.items()
        }
        
        cluster_mean = sum(mean_qps.values()) / len(mean_qps)
        
        # Identify shards exceeding threshold
        hot_shards = [
            shard for shard, qps in mean_qps.items()
            if qps > cluster_mean * self.threshold_multiplier
        ]
        
        return hot_shards
    
    def split_hot_shard(self, shard_id: str, split_strategy: str = 'median'):
        """Recommend split strategy for hot shard"""
        if split_strategy == 'median':
            # Find median key value and split range
            pass
        elif split_strategy == 'top_keys':
            # Identify specific hot keys and isolate them
            pass

# Usage with cache warming
class HotKeyCache:
    def __init__(self, cache_size: int = 1000):
        self.cache = LRUCache(maxsize=cache_size)
        self.access_frequency = Counter()
    
    def get(self, shard_id: str, key: str):
        cache_key = f"{shard_id}:{key}"
        
        # Track access frequency
        self.access_frequency[cache_key] += 1
        
        # Check cache
        if cache_key in self.cache:
            return self.cache.get(cache_key)
        
        # Cache miss - fetch from shard
        value = self._fetch_from_shard(shard_id, key)
        
        # Cache if frequently accessed
        if self.access_frequency[cache_key] > 10:
            self.cache.put(cache_key, value)
        
        return value
```

**Read Replicas for Shard Scaling**

```python
class ShardWithReplicas:
    def __init__(
        self,
        primary: DatabaseConnection,
        replicas: List[DatabaseConnection]
    ):
        self.primary = primary
        self.replicas = replicas
        self.replica_index = 0
    
    def execute_write(self, query: str, params: dict):
        """All writes go to primary"""
        return self.primary.execute(query, params)
    
    def execute_read(
        self,
        query: str,
        params: dict,
        consistency: str = 'eventual'
    ):
        """Reads can use replicas"""
        if consistency == 'strong':
            # Read from primary for strong consistency
            return self.primary.execute(query, params)
        
        # Round-robin across replicas for load distribution
        replica = self.replicas[self.replica_index % len(self.replicas)]
        self.replica_index += 1
        
        try:
            return replica.execute(query, params)
        except ReplicaLagError:
            # Fallback to primary if replica is too far behind
            return self.primary.execute(query, params)
```

Related topics: consistent hashing algorithms, distributed transactions, CAP theorem implications, database partitioning strategies, connection pooling at scale, query federation, data locality optimization, multi-tenancy patterns.

---

## Partitioning Strategies

### Core Partitioning Concepts

Partitioning divides datasets across multiple physical or logical boundaries to enable horizontal scaling, improve query performance, and manage data lifecycle. Effective partitioning requires understanding access patterns, data distribution characteristics, and consistency requirements.

**Partitioning vs Sharding:**

- Partitioning: General division of data (horizontal or vertical)
- Sharding: Specific horizontal partitioning across independent nodes/databases

**Key Design Dimensions:**

- Partition key selection (distribution uniformity, query efficiency)
- Partition count (fixed vs dynamic)
- Cross-partition operations (joins, transactions, aggregations)
- Rebalancing strategy (data movement cost, availability impact)

### Horizontal Partitioning Schemes

**Range Partitioning:** Divides data by continuous key ranges. Simple implementation, efficient for range queries, but susceptible to hotspots.

```sql
-- Time-series partitioning
CREATE TABLE orders (
    order_id BIGINT,
    order_date DATE,
    customer_id BIGINT,
    amount DECIMAL(10,2)
) PARTITION BY RANGE (order_date) (
    PARTITION p2024_q1 VALUES LESS THAN ('2024-04-01'),
    PARTITION p2024_q2 VALUES LESS THAN ('2024-07-01'),
    PARTITION p2024_q3 VALUES LESS THAN ('2024-10-01'),
    PARTITION p2024_q4 VALUES LESS THAN ('2025-01-01')
);

-- Query planner eliminates partitions
SELECT * FROM orders 
WHERE order_date BETWEEN '2024-05-01' AND '2024-05-31';
-- Only scans p2024_q2
```

**Range Partitioning Challenges:**

- Uneven data distribution when key values cluster
- Hotspot on most recent partition for time-series data
- Manual partition management overhead

**Hash Partitioning:** Applies hash function to partition key, distributing data uniformly across fixed number of partitions.

```sql
CREATE TABLE users (
    user_id BIGINT,
    username VARCHAR(255),
    email VARCHAR(255)
) PARTITION BY HASH(user_id) PARTITIONS 16;

-- Distribution formula: partition = hash(user_id) % 16
```

**Hash Function Properties:**

```java
class PartitionRouter {
    private final int partitionCount;
    
    public int getPartition(long key) {
        // Murmur3 hash for uniform distribution
        long hash = MurmurHash3.hash64(key);
        return (int) (Math.abs(hash) % partitionCount);
    }
    
    // Jump consistent hash: minimal remapping on resize
    public int getPartitionConsistent(long key, int buckets) {
        long b = -1, j = 0;
        while (j < buckets) {
            b = j;
            key = key * 2862933555777941757L + 1;
            j = (long) ((b + 1) * (double) (1L << 31) / 
                ((key >>> 33) + 1));
        }
        return (int) b;
    }
}
```

**Consistent Hashing:** Maps both data keys and nodes to hash ring, minimizing data movement during cluster changes.

```java
class ConsistentHashRing {
    private final TreeMap<Long, String> ring = new TreeMap<>();
    private final int virtualNodesPerPhysical;
    private final MessageDigest md5;
    
    public void addNode(String nodeId) {
        for (int i = 0; i < virtualNodesPerPhysical; i++) {
            long hash = hash(nodeId + ":" + i);
            ring.put(hash, nodeId);
        }
    }
    
    public void removeNode(String nodeId) {
        for (int i = 0; i < virtualNodesPerPhysical; i++) {
            long hash = hash(nodeId + ":" + i);
            ring.remove(hash);
        }
    }
    
    public String getNode(String key) {
        if (ring.isEmpty()) return null;
        
        long hash = hash(key);
        Map.Entry<Long, String> entry = ring.ceilingEntry(hash);
        
        // Wrap around to first node
        return entry != null ? entry.getValue() : ring.firstEntry().getValue();
    }
    
    private long hash(String key) {
        md5.reset();
        md5.update(key.getBytes());
        byte[] digest = md5.digest();
        
        return ((long) (digest[3] & 0xFF) << 24) |
               ((long) (digest[2] & 0xFF) << 16) |
               ((long) (digest[1] & 0xFF) << 8)  |
               ((long) (digest[0] & 0xFF));
    }
}
```

[Inference] Virtual nodes typically range from 100-500 per physical node, balancing distribution uniformity against ring size overhead.

**List Partitioning:** Explicit mapping of discrete values to partitions. Useful for categorical data with known distribution.

```sql
CREATE TABLE sales (
    sale_id BIGINT,
    region VARCHAR(50),
    amount DECIMAL(10,2)
) PARTITION BY LIST(region) (
    PARTITION p_north VALUES IN ('US-NORTH', 'CA-NORTH'),
    PARTITION p_south VALUES IN ('US-SOUTH', 'MX'),
    PARTITION p_europe VALUES IN ('UK', 'DE', 'FR'),
    PARTITION p_asia VALUES IN ('JP', 'CN', 'IN')
);
```

**Composite Partitioning:** Multi-level partitioning combining strategies.

```sql
-- Range-hash composite
CREATE TABLE metrics (
    timestamp TIMESTAMP,
    device_id BIGINT,
    metric_value DOUBLE
) PARTITION BY RANGE (timestamp)
  SUBPARTITION BY HASH (device_id) SUBPARTITIONS 8 (
    PARTITION p2024_01 VALUES LESS THAN ('2024-02-01'),
    PARTITION p2024_02 VALUES LESS THAN ('2024-03-01')
);

-- First level: prune by time
-- Second level: distribute load within time range
```

### Vertical Partitioning

Separates columns into different storage structures, optimizing for access patterns and storage characteristics.

**Column Family Partitioning:**

```java
// HBase/Cassandra column families
CREATE TABLE user_profile (
    user_id BIGINT PRIMARY KEY,
    
    -- Frequently accessed
    basic_info: {
        username TEXT,
        email TEXT,
        created_at TIMESTAMP
    },
    
    -- Infrequently accessed, large
    extended_info: {
        bio TEXT,
        preferences BLOB,
        settings JSON
    }
);

// Query only needed column family
SELECT user_id, basic_info FROM user_profile WHERE user_id = 123;
```

**Microservices Data Partitioning:**

```java
// Order service database
class OrderService {
    @Table("orders")
    class Order {
        Long orderId;
        Long customerId;  // Foreign key reference only
        BigDecimal total;
        OrderStatus status;
    }
}

// Customer service database (separate partition)
class CustomerService {
    @Table("customers")
    class Customer {
        Long customerId;
        String name;
        String email;
    }
}

// Cross-service joins eliminated, joined at application layer
```

### Partition Key Selection

**Distribution Uniformity:** Key must distribute data evenly to prevent hotspots.

```java
// Poor: monotonically increasing ID causes hotspot
UUID orderId = UUID.randomUUID();  // All writes hit latest partition

// Better: hash-based compound key
String partitionKey = hash(customerId) + ":" + timestamp;

// Optimal: incorporate high-cardinality attribute
String compositeKey = customerId + ":" + timestamp + ":" + UUID.randomUUID();
```

**Query Pattern Optimization:** Partition key should align with most common query filters.

```sql
-- Access pattern: queries always filter by tenant_id
CREATE TABLE app_data (
    tenant_id VARCHAR(50),
    record_id BIGINT,
    data JSON,
    PRIMARY KEY ((tenant_id), record_id)  -- Cassandra partition key
);

-- Efficient: single partition access
SELECT * FROM app_data WHERE tenant_id = 'tenant-123' AND record_id > 1000;

-- Inefficient: scatter-gather across all partitions
SELECT * FROM app_data WHERE record_id = 5000;
```

**Cardinality Considerations:**

```java
// Low cardinality: poor distribution
partition_key = user_country;  // ~200 values globally

// High cardinality: good distribution
partition_key = user_id;  // Millions of unique values

// Balanced: composite key
partition_key = country + ":" + hash(user_id) % 100;
// 200 countries * 100 buckets = 20,000 partitions
```

### Cross-Partition Operations

**Scatter-Gather Queries:** Query coordinator fans out to all partitions, aggregates results.

```java
class PartitionedQueryExecutor {
    private final List<DataSource> partitions;
    private final ExecutorService executor;
    
    public List<Result> query(Query query) {
        List<CompletableFuture<List<Result>>> futures = 
            partitions.stream()
                .map(partition -> CompletableFuture.supplyAsync(
                    () -> partition.execute(query),
                    executor
                ))
                .collect(Collectors.toList());
        
        return futures.stream()
            .map(CompletableFuture::join)
            .flatMap(List::stream)
            .collect(Collectors.toList());
    }
}
```

Performance characteristics:

- Latency: determined by slowest partition (tail latency amplification)
- Throughput: limited by coordinator capacity
- Resource usage: proportional to partition count

**Distributed Joins:**

```java
// Broadcast join: small table replicated to all partitions
class BroadcastJoin {
    public Dataset join(Dataset large, Dataset small) {
        // Replicate small table to all executors
        Broadcast<Map<K, V>> broadcastSmall = 
            sparkContext.broadcast(small.collectAsMap());
        
        return large.map(row -> {
            Map<K, V> smallMap = broadcastSmall.value();
            return joinRow(row, smallMap.get(row.key()));
        });
    }
}

// Shuffle join: both tables repartitioned by join key
class ShuffleJoin {
    public Dataset join(Dataset left, Dataset right) {
        Dataset leftPartitioned = left.repartition(joinKey);
        Dataset rightPartitioned = right.repartition(joinKey);
        
        // Co-located partitions joined locally
        return leftPartitioned.join(rightPartitioned, joinKey);
    }
}
```

**Cross-Partition Transactions:** Two-phase commit for distributed ACID guarantees.

```java
class TwoPhaseCommitCoordinator {
    public void executeTransaction(List<Partition> participants, 
                                   Transaction txn) {
        String txnId = UUID.randomUUID().toString();
        
        // Phase 1: Prepare
        List<Boolean> votes = participants.stream()
            .map(p -> p.prepare(txnId, txn))
            .collect(Collectors.toList());
        
        if (votes.stream().allMatch(v -> v)) {
            // Phase 2: Commit
            participants.forEach(p -> p.commit(txnId));
        } else {
            // Abort
            participants.forEach(p -> p.abort(txnId));
        }
    }
}
```

[Inference] Two-phase commit significantly increases latency and reduces availability due to blocking behavior. Many systems trade strong consistency for performance using eventual consistency patterns.

**Saga Pattern:** Compensating transactions for cross-partition consistency without distributed locks.

```java
class OrderSaga {
    public void processOrder(Order order) {
        try {
            // Step 1: Reserve inventory
            inventoryService.reserve(order.items);
            
            // Step 2: Charge payment
            paymentService.charge(order.amount);
            
            // Step 3: Create shipment
            shippingService.createShipment(order);
            
        } catch (Exception e) {
            // Compensating transactions in reverse order
            shippingService.cancelShipment(order);
            paymentService.refund(order.amount);
            inventoryService.release(order.items);
            throw e;
        }
    }
}
```

### Dynamic Partitioning

**Split Operations:** Partition becomes too large, split into multiple smaller partitions.

```java
class PartitionSplitter {
    private static final long MAX_PARTITION_SIZE = 10_000_000_000L; // 10GB
    
    public void checkAndSplit(Partition partition) {
        if (partition.size() > MAX_PARTITION_SIZE) {
            // Find split point (median key)
            Key splitKey = partition.findMedianKey();
            
            // Create new partitions
            Partition left = partition.splitLeft(splitKey);
            Partition right = partition.splitRight(splitKey);
            
            // Update routing metadata
            routingTable.replace(partition.range(), 
                Arrays.asList(left.range(), right.range()));
        }
    }
}
```

**Merge Operations:** Adjacent small partitions combined to reduce overhead.

```java
class PartitionMerger {
    private static final long MIN_PARTITION_SIZE = 1_000_000_000L; // 1GB
    
    public void checkAndMerge(Partition p1, Partition p2) {
        if (p1.size() + p2.size() < MIN_PARTITION_SIZE && 
            p1.range().isAdjacentTo(p2.range())) {
            
            Partition merged = Partition.merge(p1, p2);
            
            routingTable.replace(
                Arrays.asList(p1.range(), p2.range()),
                merged.range()
            );
        }
    }
}
```

**Live Migration:** Move partition between nodes without downtime.

```java
class PartitionMigration {
    public void migrate(Partition partition, Node source, Node target) {
        // Phase 1: Start replication
        target.startReplication(partition, source);
        
        // Phase 2: Wait for synchronization
        while (!target.isSynchronized(partition)) {
            Thread.sleep(100);
        }
        
        // Phase 3: Redirect writes to target (double-write)
        routingTable.setDualWrite(partition, source, target);
        
        // Phase 4: Wait for pending reads on source
        source.drainReads(partition);
        
        // Phase 5: Switch routing to target only
        routingTable.setSingleWrite(partition, target);
        
        // Phase 6: Cleanup source
        source.dropPartition(partition);
    }
}
```

### Database-Specific Implementations

**PostgreSQL Declarative Partitioning:**

```sql
-- Parent table
CREATE TABLE measurements (
    id SERIAL,
    device_id INT,
    timestamp TIMESTAMP,
    value DOUBLE PRECISION
) PARTITION BY RANGE (timestamp);

-- Child partitions
CREATE TABLE measurements_2024_01 
    PARTITION OF measurements
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE measurements_2024_02 
    PARTITION OF measurements
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Indexes on each partition
CREATE INDEX ON measurements_2024_01 (device_id);
CREATE INDEX ON measurements_2024_02 (device_id);

-- Constraint exclusion enables partition pruning
SET constraint_exclusion = partition;
```

**MySQL Partitioning:**

```sql
CREATE TABLE logs (
    id BIGINT AUTO_INCREMENT,
    log_date DATE,
    message TEXT,
    PRIMARY KEY (id, log_date)
) PARTITION BY RANGE (YEAR(log_date) * 100 + MONTH(log_date)) (
    PARTITION p_2024_01 VALUES LESS THAN (202402),
    PARTITION p_2024_02 VALUES LESS THAN (202403),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Partition management
ALTER TABLE logs DROP PARTITION p_2024_01;  -- Fast deletion
ALTER TABLE logs ADD PARTITION (
    PARTITION p_2024_03 VALUES LESS THAN (202404)
);
```

**MongoDB Sharding:**

```javascript
// Enable sharding on database
sh.enableSharding("mydb");

// Shard collection with hashed key
sh.shardCollection("mydb.users", { user_id: "hashed" });

// Range-based sharding
sh.shardCollection("mydb.orders", { order_date: 1 });

// Compound shard key
sh.shardCollection("mydb.events", { 
    tenant_id: 1, 
    timestamp: 1 
});

// Zone sharding (geographic partitioning)
sh.addShardToZone("shard0", "NA");
sh.addShardToZone("shard1", "EU");
sh.updateZoneKeyRange(
    "mydb.users",
    { country: "US" },
    { country: "US" },
    "NA"
);
```

**Cassandra Partitioning:**

```sql
-- Partition key determines data distribution
CREATE TABLE user_events (
    user_id UUID,
    event_time TIMESTAMP,
    event_type TEXT,
    event_data TEXT,
    PRIMARY KEY ((user_id), event_time)
) WITH CLUSTERING ORDER BY (event_time DESC);

-- Composite partition key for better distribution
CREATE TABLE sensor_data (
    sensor_id INT,
    day DATE,
    timestamp TIMESTAMP,
    reading DOUBLE,
    PRIMARY KEY ((sensor_id, day), timestamp)
);

-- All data for (sensor_id, day) stored on same partition
```

### Partition Routing

**Client-Side Routing:** Application directly determines target partition.

```java
class ClientSideRouter {
    private final List<DataSource> shards;
    private final ConsistentHashRing hashRing;
    
    public DataSource getShardFor(String key) {
        String nodeId = hashRing.getNode(key);
        return shards.stream()
            .filter(s -> s.getNodeId().equals(nodeId))
            .findFirst()
            .orElseThrow();
    }
    
    public Result query(String key, Query query) {
        DataSource shard = getShardFor(key);
        return shard.execute(query);
    }
}
```

**Proxy-Based Routing:** Dedicated routing layer abstracts partition topology from clients.

```java
class RoutingProxy {
    private final PartitionMap partitionMap;
    private final ConnectionPool pool;
    
    public Result route(Request request) {
        String partitionKey = extractPartitionKey(request);
        Partition partition = partitionMap.lookup(partitionKey);
        
        Connection conn = pool.getConnection(partition.getNode());
        return conn.execute(request);
    }
    
    // Hot-reload partition map without client changes
    public void updatePartitionMap(PartitionMap newMap) {
        this.partitionMap = newMap;
    }
}
```

**Metadata Service:** Centralized partition mapping service.

```java
class PartitionMetadataService {
    private final ZooKeeper zk;
    private final Cache<String, PartitionLocation> cache;
    
    public PartitionLocation locate(String key) {
        // Check local cache first
        PartitionLocation cached = cache.getIfPresent(key);
        if (cached != null) return cached;
        
        // Query ZooKeeper for authoritative mapping
        String path = "/partitions/" + getPartitionId(key);
        byte[] data = zk.getData(path, false, null);
        PartitionLocation location = deserialize(data);
        
        // Cache with TTL
        cache.put(key, location);
        return location;
    }
    
    // Watch for partition map changes
    public void watchPartitionChanges() {
        zk.getChildren("/partitions", event -> {
            if (event.getType() == Event.EventType.NodeChildrenChanged) {
                cache.invalidateAll();
            }
        });
    }
}
```

### Rebalancing Strategies

**Triggering Conditions:**

- Storage capacity threshold exceeded on partition
- Query load imbalance across partitions
- Addition/removal of nodes
- Scheduled maintenance windows

**Minimal Data Movement:**

```java
class MinimalRebalancer {
    public RebalancePlan computePlan(
            ClusterState current, 
            ClusterState target) {
        
        List<PartitionMove> moves = new ArrayList<>();
        
        // Only move partitions needed to reach target state
        for (Partition p : current.getPartitions()) {
            Node currentNode = current.getNodeFor(p);
            Node targetNode = target.getNodeFor(p);
            
            if (!currentNode.equals(targetNode)) {
                moves.add(new PartitionMove(p, currentNode, targetNode));
            }
        }
        
        // Optimize move order to prevent hotspots
        return optimizeMoveOrder(moves);
    }
}
```

**Throttled Rebalancing:**

```java
class ThrottledRebalancer {
    private final RateLimiter rebalanceRate;
    
    public void rebalance(List<PartitionMove> moves) {
        for (PartitionMove move : moves) {
            // Throttle to prevent overwhelming network/disk
            rebalanceRate.acquire(move.getPartitionSize());
            
            // Priority: serve live traffic over rebalancing
            if (systemLoad() > LOAD_THRESHOLD) {
                Thread.sleep(BACKOFF_MS);
            }
            
            movePartition(move);
        }
    }
}
```

### Anti-patterns

**Hotspot Partitions:** Partition key with skewed distribution causes disproportionate load.

```java
// Poor: celebrity user gets all traffic
partition_key = user_id;  // Single partition for celebrity's followers

// Better: add randomization for hot keys
if (isHotKey(user_id)) {
    partition_key = user_id + ":" + random.nextInt(10);  // Spread across 10 partitions
}
```

**Excessive Partition Count:** Too many small partitions increases metadata overhead, coordination cost, and query planning time.

[Inference] Partition count typically ranges from 10s to 1000s depending on system scale. Each partition should manage at least 1GB-10GB of data to justify overhead.

**Cross-Partition Joins in OLTP:** Frequent joins across partitions negate partitioning benefits, introducing high latency and complexity.

**Partition Key Immutability Violation:** Changing partition key values requires expensive cross-partition data movement.

```java
// Problematic: user changes country (partition key)
UPDATE users SET country = 'CA' WHERE user_id = 123;
// Requires: delete from US partition, insert into CA partition

// Better: use immutable partition key
// Store country as non-partition attribute, partition by user_id
```

**Ignoring Time-Based Deletion:** Range partitioning on timestamps enables efficient bulk deletion via partition drop, orders of magnitude faster than row-by-row deletion.

```sql
-- Slow: millions of individual deletes
DELETE FROM logs WHERE timestamp < '2023-01-01';

-- Fast: instant partition drop
ALTER TABLE logs DROP PARTITION p_2022;
```

### Monitoring and Operations

**Key Metrics:**

- Partition size distribution (histogram)
- Query latency per partition (P50, P95, P99)
- Cross-partition query percentage
- Partition migration duration and frequency
- Storage skew (largest partition / average partition size)
- Hotspot detection (requests per partition)

**Automated Partition Management:**

```java
class PartitionManager {
    private final MetricsCollector metrics;
    
    @Scheduled(fixedDelay = 3600000) // Hourly
    public void analyzePartitions() {
        List<Partition> partitions = getAllPartitions();
        
        // Detect size-based splits
        partitions.stream()
            .filter(p -> p.size() > SIZE_THRESHOLD)
            .forEach(this::scheduleSplit);
        
        // Detect hotspots
        partitions.stream()
            .filter(p -> metrics.getQPS(p) > QPS_THRESHOLD)
            .forEach(this::scheduleHotspotMitigation);
        
        // Detect storage skew
        double avgSize = partitions.stream()
            .mapToLong(Partition::size)
            .average()
            .orElse(0);
        
        partitions.stream()
            .filter(p -> p.size() > avgSize * SKEW_THRESHOLD)
            .forEach(p -> scheduleRebalance(p));
    }
}
```

### Related Topics

Consistent Hashing, Data Replication Strategies, Query Optimization, Distributed Transactions, Load Balancing Algorithms, Cache Partitioning, Stream Partitioning, Database Indexing Strategies, Multi-Tenancy Patterns, Geographic Distribution

---

## Hash-based Partitioning

### Fundamental Mechanism

Hash-based partitioning distributes data across nodes by applying a hash function to a partition key, mapping the resulting hash value to a specific partition. The partition assignment follows: `partition = hash(key) mod N` where N represents the total partition count. This deterministic mapping ensures identical keys always route to the same partition while achieving approximately uniform distribution across the partitioning space.

### Hash Function Selection

**Cryptographic vs. Non-Cryptographic Functions**

Production systems typically employ non-cryptographic hash functions (MurmurHash3, xxHash, CityHash) over cryptographic alternatives (SHA-256, MD5) due to computational efficiency requirements. Cryptographic hashes provide collision resistance unnecessary for partitioning while introducing 10-100x performance overhead. Non-cryptographic functions deliver sufficient avalanche properties—minor input changes producing drastically different hash values—with substantially lower CPU cycles.

**Critical Hash Function Properties**

- **Uniform Distribution:** Prevent hotspots by ensuring hash outputs distribute evenly across the output range
- **Determinism:** Identical inputs must always produce identical outputs across all nodes and implementations
- **Avalanche Effect:** Single-bit input changes should affect approximately 50% of output bits
- **Performance:** Sub-microsecond computation for high-throughput systems

### Consistent Hashing Implementation

Standard modulo-based partitioning (`hash(key) mod N`) creates catastrophic redistribution when N changes—adding or removing a single node requires rehashing nearly all keys. Consistent hashing limits redistribution to `K/N` keys (K = total keys, N = nodes) by mapping both keys and nodes onto a circular hash ring.

**Ring-based Architecture**

Nodes occupy positions on a ring of size 2^160 or 2^256. Each key hashes to a ring position and assigns to the first node encountered when traversing clockwise. Virtual nodes (vnodes) multiply each physical node's ring presence—typically 128-512 vnodes per physical node—improving distribution uniformity and load balancing granularity.

**Replication Strategy Integration**

Replicas extend clockwise from primary assignment positions. With replication factor R, a key stores on R consecutive distinct physical nodes. Vnode distribution naturally spaces replicas across failure domains when vnodes randomize positions rather than clustering.

### Partition Count Determination

**[Inference]** Optimal partition counts balance operational flexibility against coordination overhead. Systems commonly provision 10-100x more partitions than initial nodes, enabling fine-grained rebalancing without partition splitting.

**Trade-off Analysis**

- **Too Few Partitions:** Limited rebalancing granularity, potential hotspots, inflexible scaling
- **Too Many Partitions:** Increased metadata overhead, resource fragmentation, gossip protocol amplification
- **Industry Practice:** Cassandra defaults to 256 vnodes per node; Kafka typically provisions 30-50 partitions per topic per broker

### Hotspot Mitigation Strategies

Hash-based partitioning cannot eliminate hotspots caused by skewed access patterns—uniform key distribution does not guarantee uniform access distribution.

**Composite Partition Keys**

Append high-cardinality suffixes to low-cardinality partition keys. Example: `tenant_id + random(0, 10)` transforms single-tenant hotspots into 10 distributed partitions. Query scatter-gather overhead increases proportionally to suffix cardinality.

**Salting Techniques**

Deterministically derive salt values from key attributes rather than random generation to maintain query predictability. Time-based salting (`key + hour_of_day`) enables time-range queries while distributing load temporally.

**Adaptive Partitioning**

Monitor per-partition metrics (request rate, data volume, CPU utilization) and dynamically split hot partitions. Requires sophisticated split logic to maintain query routing correctness during transitions.

### Rebalancing and Data Migration

**Partition Movement Protocols**

1. **Pre-copy Phase:** Stream partition data to destination node while continuing to serve reads/writes from source
2. **Delta Synchronization:** Incrementally transfer mutations occurring during pre-copy
3. **Atomic Switchover:** Redirect traffic to destination after achieving acceptable lag threshold
4. **Cleanup Phase:** Delete source partition data after confirming destination stability

**Consistency Implications**

- **Eventual Consistency Systems:** Permit dual-writes during migration with anti-entropy resolution
- **Strong Consistency Systems:** Require distributed consensus (Paxos/Raft) to atomically transfer partition ownership
- **Linearizability:** Mandate exclusive ownership—no concurrent access during switchover

### Range Partitioning Comparison

Hash-based partitioning sacrifices range query efficiency for uniform distribution. Range partitioning enables efficient range scans but concentrates sequential writes and time-series data on specific partitions. Hybrid approaches (range partitioning with hash-based sub-partitioning) address both concerns at increased complexity cost.

### Anti-Patterns

**Non-deterministic Hash Functions**

Using hash functions with implementation-specific behavior (Java's `hashCode()` across JVM versions) breaks cross-version compatibility and causes incorrect routing after upgrades.

**Ignoring Hash Collision Handling**

While hash collisions rarely affect partition assignment (hash space exceeds partition count by orders of magnitude), systems must explicitly define collision resolution policies rather than assuming perfect distribution.

**Premature Partition Count Optimization**

Choosing partition counts based on current cluster size rather than projected maximum size forces future partition splits—operationally expensive procedures requiring data redistribution and potential downtime.

**Direct Modulo Partitioning in Dynamic Clusters**

Applying `hash(key) mod N` without consistent hashing abstractions causes massive data movement during scale operations. Every cluster topology change invalidates existing partition assignments.

**Partition Key Immutability Violations**

Allowing partition key mutations necessitates complex record deletion and reinsertion logic across partitions. Enforce partition key immutability through schema constraints and application-level validation.

### Monitoring and Observability

**Critical Metrics**

- **Partition Size Distribution:** Standard deviation from mean partition size; high variance indicates poor hash distribution or skewed data
- **Request Rate Per Partition:** Identify hotspots requiring splitting or key redesign
- **Rebalancing Progress:** Data transferred, estimated completion time, error rates during migrations
- **Hash Collision Rate:** Track collisions in the partition assignment space (distinct from application-level key collisions)

**Operational Alerts**

- Partition size exceeding 80% of configured maximum
- Request rate deviation beyond 3 standard deviations from cluster average
- Failed rebalancing operations requiring manual intervention
- Increasing query latency correlated with specific partition access patterns

### Related Topics

Virtual Node Allocation Algorithms, Rendezvous Hashing (HRW), Jump Consistent Hashing, Token-based Partitioning, Partition Splitting Strategies, Cross-Datacenter Replication with Partitioning, Read Repair in Partitioned Systems, Tombstone Management Across Partitions

---

## Range-based Partitioning

Range-based partitioning distributes data across nodes by assigning continuous ranges of partition key values to specific nodes or shards. Each partition owns an exclusive, non-overlapping range (e.g., A-F, G-M, N-Z for alphabetic keys, or timestamp intervals for temporal data). This strategy enables efficient range queries and ordered scans but introduces complexities around hotspot mitigation, rebalancing, and boundary management.

### Partition Key Selection

The partition key determines data distribution quality. Poor key selection creates unbalanced partitions and performance degradation.

**Criteria for effective keys:**

- High cardinality to enable granular distribution
- Uniform value distribution across the key space
- Correlation with query patterns to minimize cross-partition operations
- Temporal stability to avoid frequent rebalancing

**Anti-patterns:**

- Sequential IDs or timestamps as sole keys create monotonically increasing writes concentrated on the "hot" partition owning the highest range
- Low-cardinality keys (status codes, boolean flags) produce skewed distributions
- Composite keys with dominant low-cardinality prefixes inherit the same skew problem

**Mitigation strategies:**

- Prefix sequential keys with hash values or random segments to scatter writes
- Use compound keys with high-cardinality leading components
- Implement write-time salting where timestamps are bucketed or randomly suffixed
- Monitor partition size metrics and key distribution histograms continuously

### Range Boundary Management

Range boundaries define partition ownership and directly impact query routing efficiency.

**Boundary definition approaches:**

- **Fixed boundaries:** Predetermined splits (e.g., by alphabet, numeric ranges) simplify routing but cannot adapt to data distribution changes
- **Dynamic boundaries:** Adjusted based on partition size, write rate, or query load enable better balance at the cost of increased coordination overhead
- **Hierarchical ranges:** Nested range structures (B+ tree-like) support efficient range splitting and merging

**Boundary metadata requirements:**

- Mappings between ranges and physical nodes must be consistent across all routing components
- Metadata updates during rebalancing require atomic visibility or versioned reads to prevent routing errors
- Stale boundary caches cause misrouted requests; implement cache invalidation protocols or short TTLs

**Implementation considerations:**

- Store range metadata in a strongly consistent metadata store (ZooKeeper, etcd, Raft-based systems)
- Routing layers must handle boundary transitions gracefully during splits, detecting and retrying requests that land on stale mappings
- Secondary indexes referencing partition keys require updates when boundaries change

### Hotspot Detection and Mitigation

Hotspots occur when workload concentrates on specific ranges, overwhelming individual partitions.

**Detection metrics:**

- Per-partition request rate, throughput (bytes/sec), CPU utilization, and queue depth
- Key access frequency histograms to identify concentrated read/write patterns
- Temporal analysis revealing time-based access spikes (e.g., daily batch jobs hitting recent timestamp ranges)

**Mitigation techniques:**

**Range splitting:** Divide overloaded ranges into smaller sub-ranges distributed to separate nodes. Requires data migration and boundary metadata updates. Splitting decisions should consider:

- Minimum partition size thresholds to avoid excessive fragmentation
- Split points derived from actual key distribution (median key, percentile boundaries)
- Rate limiting on splits to prevent cascading rebalancing overhead

**Load shedding and throttling:** Apply backpressure to clients targeting hot partitions. Implementations include token bucket rate limiters per partition or adaptive quotas based on real-time load.

**Read replicas for hot ranges:** Deploy additional read-only replicas for heavily queried ranges. Requires eventual consistency tolerance and replica lag monitoring.

**Request scatter/gather optimization:** For range queries spanning multiple partitions, parallelize sub-queries and aggregate results. Avoid sequential partition traversal that amplifies tail latencies.

**Caching hot keys:** Front partitions with distributed caches (Redis, Memcached) to absorb read load. Cache invalidation on writes introduces consistency challenges.

### Rebalancing and Data Migration

Rebalancing redistributes ranges across nodes to address imbalance or accommodate cluster topology changes.

**Rebalancing triggers:**

- Partition size exceeds threshold (storage capacity, row count)
- Load imbalance detected via request rate or latency percentiles
- Node addition/removal during scaling operations
- Proactive rebalancing based on predicted growth trends

**Migration strategies:**

**Stop-the-world migration:** Freeze writes to source partition, copy data, update metadata, resume operations on target. Minimizes complexity but introduces downtime.

**Online migration:** Serve reads/writes from source while copying data to target. Techniques include:

- **Dual-write phase:** Write to both source and target, reconcile differences post-copy
- **Catch-up replication:** Stream write logs from source to target until lag converges
- **Shadow traffic:** Route percentage of requests to target for validation before cutover

**Consistency during migration:**

- Use distributed transactions or two-phase commit to atomically update data and metadata
- Implement redirection at routing layer: forward requests to new partition after boundary updates
- Maintain write-ahead logs (WAL) to replay missed writes if migration fails mid-process

**Performance impact:**

- Data migration consumes bandwidth and I/O, degrading foreground request latencies
- Throttle migration throughput using rate limiters or schedule during low-traffic windows
- Monitor replication lag and pause migrations if lag exceeds acceptable bounds

### Query Routing and Execution

Range queries benefit from partition pruning when query predicates align with partition key ranges.

**Routing logic:**

- Query planner analyzes predicates to determine relevant partitions
- Single-partition queries route directly to owning node
- Multi-partition queries spawn parallel sub-queries, aggregating results at coordinator

**Challenges:**

**Partition pruning effectiveness:** Non-leading key predicates (e.g., filtering on secondary attributes in composite key) cannot prune partitions, forcing full scans.

**Cross-partition transactions:** Distributed transactions spanning ranges require two-phase commit or consensus protocols, introducing latency and coordination overhead.

**Ordering and pagination:** Global ordering across partitions demands result merging with heap-based priority queues. Pagination requires stable snapshots or cursor tokens encoding partition positions.

**Scatter-gather amplification:** Queries touching all partitions multiply coordinator overhead and tail latency. P99 latency degrades proportionally to partition count.

### Failure Handling and Availability

Range partitions must tolerate node failures without data loss or prolonged unavailability.

**Replication strategies:**

- Replicate each range to N nodes using consensus protocols (Raft, Multi-Paxos)
- Maintain leader-follower topologies where leader serves writes, followers handle reads
- Quorum-based writes (W replicas acknowledge) and reads (R replicas consulted) ensure consistency if W + R > N

**Failover procedures:**

- Leader election promotes follower to leader when primary fails
- Routing layer detects failures via heartbeats or request timeouts, redirects traffic to new leader
- Follower lag during failover may expose stale reads; implement read-your-writes consistency via version vectors or session tokens

**Split-brain prevention:** Network partitions can create multiple leaders. Use fencing tokens or epoch numbers to invalidate stale leaders.

### Monitoring and Observability

**Critical metrics:**

- Per-partition storage size, write amplification, compaction rates
- Request distribution histograms showing load per partition
- Range scan latency percentiles (P50, P95, P99)
- Rebalancing progress: data migrated, remaining bytes, estimated completion time
- Metadata consistency: routing error rates, stale cache hit rates

**Alerting conditions:**

- Partition size approaching capacity thresholds
- Sustained load imbalance (coefficient of variation > threshold)
- Elevated replication lag or follower unavailability
- Increased cross-partition query rates indicating poor key selection

### Comparison with Hash-based Partitioning

Range partitioning trades uniform distribution guarantees for range query efficiency. Hash partitioning randomizes key placement, eliminating hotspots from sequential keys but destroying ordering, making range scans require full table scans. Choose range partitioning when:

- Range queries or ordered scans are frequent
- Partition key exhibits natural ordering (timestamps, lexicographic IDs)
- Application can tolerate rebalancing complexity

Hash partitioning suits workloads dominated by point lookups where key distribution uniformity outweighs ordering requirements.

**Related topics:** Consistent hashing, virtual nodes (vnodes), partition-aware client routing, distributed query optimization, partition pruning strategies, adaptive partitioning algorithms.

---

## List-Based Partitioning

A deterministic data distribution strategy where records are assigned to specific partitions based on explicit enumeration of discrete values in a partition key column. Unlike range partitioning (continuous intervals) or hash partitioning (algorithmic distribution), list partitioning uses predefined sets of values to define partition boundaries.

### Core Mechanics

**Partition Definition Structure:**

```sql
CREATE TABLE orders (
    order_id BIGINT,
    region VARCHAR(50),
    order_date DATE,
    amount DECIMAL(10,2)
) PARTITION BY LIST (region) (
    PARTITION p_north VALUES IN ('NY', 'MA', 'CT', 'VT', 'NH', 'ME'),
    PARTITION p_south VALUES IN ('FL', 'GA', 'AL', 'MS', 'LA', 'TX'),
    PARTITION p_west VALUES IN ('CA', 'OR', 'WA', 'NV', 'AZ'),
    PARTITION p_default VALUES IN (DEFAULT)
);
```

**Distribution Algorithm:**

1. Extract partition key value from incoming record
2. Perform exact match against enumerated value lists
3. Route record to corresponding partition
4. Fall back to default partition for unmatched values (if configured)

### Architectural Characteristics

**Optimal Use Cases:**

- Categorical data with stable, well-defined domains (countries, status codes, product categories)
- Query patterns dominated by equality predicates on partition key
- Data segregation requirements based on business logic boundaries
- Regulatory compliance requiring physical data separation by jurisdiction
- Multi-tenant architectures with explicit tenant-to-partition mapping

**Performance Profile:**

- **Partition Pruning Efficiency:** O(1) lookup for exact match queries; full scan for non-partitioned predicates
- **Write Throughput:** No computational overhead compared to hash partitioning; partition routing is direct dictionary lookup
- **Read Latency:** Optimal when queries filter on partition key with equality operators
- **Storage Efficiency:** No data skew mitigation unless values naturally distribute evenly

### Implementation Patterns

**Static Enumeration Pattern:**

```sql
-- Geographic partitioning with exhaustive enumeration
PARTITION BY LIST (country_code) (
    PARTITION p_usa VALUES IN ('US'),
    PARTITION p_emea VALUES IN ('GB', 'DE', 'FR', 'IT', 'ES', 'NL', 'SE', 'NO'),
    PARTITION p_apac VALUES IN ('JP', 'CN', 'IN', 'AU', 'SG', 'KR')
);
```

**Dynamic Value Management:**

- Requires DDL operations (ALTER TABLE ADD PARTITION) for new categorical values
- Schema migration complexity increases with partition count
- No automatic rebalancing on partition additions

**Multi-Column List Partitioning:**

```sql
-- Composite partition key using tuple matching
PARTITION BY LIST COLUMNS (region, status) (
    PARTITION p_north_active VALUES IN (('NORTH', 'ACTIVE'), ('NORTH', 'PENDING')),
    PARTITION p_north_closed VALUES IN (('NORTH', 'CLOSED'), ('NORTH', 'CANCELLED')),
    PARTITION p_south_active VALUES IN (('SOUTH', 'ACTIVE'), ('SOUTH', 'PENDING'))
);
```

### Anti-Patterns

**Unbounded Value Domains:** Using list partitioning for high-cardinality categorical data (e.g., user IDs, email addresses) results in:

- Excessive partition count leading to metadata overhead
- Degraded query planner performance due to partition metadata scanning
- Increased DDL lock contention on partition structure modifications

**Temporal Data Partitioning:**

```sql
-- INCORRECT: Using LIST for date-based partitioning
PARTITION BY LIST (order_year) (
    PARTITION p_2022 VALUES IN (2022),
    PARTITION p_2023 VALUES IN (2023),
    PARTITION p_2024 VALUES IN (2024)
);
```

Range partitioning is always superior for ordered, continuous domains due to automatic interval-based pruning.

**Unbalanced Value Distribution:**

```sql
-- SKEWED: One partition receives 80% of traffic
PARTITION BY LIST (customer_tier) (
    PARTITION p_premium VALUES IN ('GOLD', 'PLATINUM'),
    PARTITION p_standard VALUES IN ('SILVER', 'BRONZE', 'FREE')  -- 80% of customers
);
```

Results in hot partition bottlenecks, asymmetric I/O load, and ineffective parallelism.

### Partition Maintenance Operations

**Value Reorganization:**

```sql
-- Splitting overpopulated partitions
ALTER TABLE orders SPLIT PARTITION p_standard INTO (
    PARTITION p_silver VALUES IN ('SILVER'),
    PARTITION p_bronze VALUES IN ('BRONZE'),
    PARTITION p_free VALUES IN ('FREE')
);
```

**Partition Merging:**

```sql
-- Consolidating underutilized partitions
ALTER TABLE orders MERGE PARTITIONS (p_north, p_northeast) 
INTO PARTITION p_north_combined VALUES IN ('NY', 'MA', 'CT', 'VT', 'NH', 'ME', 'PA', 'NJ');
```

**Performance Degradation Factors:**

- Partition splitting requires full table scan and data movement
- No online reorganization in most RDBMS implementations
- Exclusive locks held during partition DDL operations

### Query Optimization Considerations

**Partition Pruning Requirements:**

```sql
-- PRUNES: Direct partition key equality
SELECT * FROM orders WHERE region = 'CA';  -- Scans only p_west

-- PRUNES: IN clause with partition key
SELECT * FROM orders WHERE region IN ('CA', 'OR', 'WA');  -- Scans only p_west

-- FULL SCAN: Non-partition key predicate
SELECT * FROM orders WHERE order_date = '2024-01-15';  -- All partitions

-- FULL SCAN: Function application on partition key
SELECT * FROM orders WHERE UPPER(region) = 'CA';  -- Prune prevention
```

**Join Performance Implications:**

- **Co-located joins:** Partition-wise joins when both tables partitioned identically on join key
- **Cross-partition joins:** Broadcast smaller table or use partition-wise parallelism with redistribution
- **Partition key mismatch:** Forces shuffle operations equivalent to non-partitioned join

### Distributed System Considerations

**Shard-to-Partition Mapping:**

```
LIST partition → Physical shard allocation:
- p_north (NY, MA, CT) → Shard-1 (US-East-1)
- p_south (FL, GA, AL) → Shard-2 (US-East-1)
- p_west (CA, OR, WA)  → Shard-3 (US-West-2)
```

**Cross-Region Compliance:**

- GDPR: European user data partitioned to EU-resident shards
- Data sovereignty: Country-specific partitions physically isolated
- Latency optimization: Geographic partition-to-datacenter affinity

**Failure Isolation:**

- Partition-level replication policies (e.g., premium tier with higher replication factor)
- Independent backup schedules per partition
- Selective disaster recovery based on partition criticality

### Migration Strategies

**Converting Hash to List Partitioning:**

```sql
-- Step 1: Create shadow table with list partitioning
CREATE TABLE orders_list PARTITION BY LIST (region) AS SELECT * FROM orders_hash WHERE 1=0;

-- Step 2: Populate via partition-specific INSERT SELECT
INSERT INTO orders_list SELECT * FROM orders_hash WHERE region IN ('NY', 'MA', 'CT');

-- Step 3: Atomic swap with rename
RENAME TABLE orders_hash TO orders_hash_old, orders_list TO orders;
```

**Zero-Downtime Partition Addition:**

- Use DEFAULT partition as temporary catch-all
- Backfill new partition from DEFAULT partition data
- Remove values from DEFAULT partition post-migration
- Monitor for DEFAULT partition growth indicating missing values

### Monitoring and Observability

**Critical Metrics:**

- Partition size distribution (coefficient of variation)
- Query partition pruning ratio (pruned/total partitions accessed)
- Partition-level write throughput and hotspot detection
- DDL operation frequency and duration
- DEFAULT partition growth rate (indicates missing value categories)

**Skew Detection:**

```sql
-- Identify unbalanced partitions
SELECT 
    partition_name,
    table_rows,
    data_length / 1024 / 1024 AS size_mb,
    ROUND(100.0 * table_rows / SUM(table_rows) OVER(), 2) AS pct_rows
FROM information_schema.partitions
WHERE table_name = 'orders'
ORDER BY table_rows DESC;
```

### Related Topics

- Range-List composite partitioning for hierarchical data distribution
- Partition-wise parallel execution optimization
- Adaptive partition pruning with runtime statistics
- Partition exchange loading for bulk data ingestion

---

## Composite Partitioning

Composite partitioning combines multiple partitioning strategies to distribute data across nodes, addressing limitations of single-strategy approaches in large-scale distributed systems. This pattern enables hierarchical data distribution where initial partitioning uses one strategy (typically range or hash) and subsequent sub-partitioning applies another, optimizing for both query performance and balanced load distribution.

### Implementation Mechanics

**Two-Level Partitioning Structure**

Primary partitioning establishes coarse-grained data distribution. Secondary partitioning subdivides primary partitions into smaller units. The partition key composition determines routing: `partition_id = hash(primary_key) % primary_partitions` followed by `sub_partition_id = range(secondary_key) % sub_partitions_per_primary`.

Database systems implement this through partition hierarchies. PostgreSQL supports declarative partitioning where a range-partitioned table contains hash-partitioned sub-tables. Cassandra uses compound partition keys where the first component determines node placement and subsequent components control clustering order within partitions.

**Common Composite Strategies**

- **Hash-Range**: Hash distribute by tenant/customer ID, range partition by timestamp within each hash bucket. Ensures even tenant distribution while maintaining time-ordered data locality for efficient range queries.
- **Range-Hash**: Range partition by date/region, hash sub-partition by entity ID. Supports efficient time-based or geographical queries while preventing hotspots within time windows.
- **List-Hash**: List partition by category/type, hash sub-partition by identifier. Enables categorical isolation with balanced distribution per category.

### Partition Key Design

**Key Cardinality Requirements**

Primary keys require high cardinality (thousands to millions of distinct values) for effective distribution. Low cardinality primary keys (e.g., boolean flags, small enums) create imbalanced partitions regardless of secondary strategy. Secondary keys need sufficient cardinality within each primary partition to justify sub-partitioning overhead.

**Avoiding Cascading Hotspots**

Composite keys must prevent temporal hotspots at both levels. Time-based primary partitioning with monotonically increasing secondary keys (auto-increment IDs, timestamps) concentrates writes in newest partitions. Mitigation: hash or reverse the secondary key, prepend primary key with hash prefix, or use UUID v7 combining timestamp with random components.

**Query Access Pattern Alignment**

Partition key selection must match dominant query patterns. If queries predominantly filter by single dimensions, composite partitioning adds routing complexity without benefit. Optimal scenarios involve multi-dimensional queries where different dimensions have different access characteristics (e.g., tenant isolation + time-series analysis).

### Routing and Query Optimization

**Partition Pruning Strategies**

Query planners must evaluate both partition levels. Providing values for both primary and secondary keys enables direct partition targeting. Queries specifying only primary keys scan all sub-partitions within matched primary partitions. Secondary-key-only queries require scanning all primary partitions unless metadata indexes track value distributions across partitions.

**Metadata Management**

Distributed systems maintain partition maps tracking the hierarchy: primary partition boundaries, sub-partition ranges per primary, and physical node assignments. Metadata updates occur during partition splits, merges, or rebalancing. Stale metadata causes query routing errors or performance degradation. Implementation requires metadata versioning with atomic updates and cache invalidation protocols.

**Cross-Partition Operations**

Aggregations spanning multiple composite partitions require scatter-gather execution. Coordinator nodes fan out requests to all relevant partitions, merge partial results, and apply final aggregation. Performance degrades linearly with partition count. Optimization: pre-aggregate at sub-partition level, maintain materialized views spanning partition boundaries, or denormalize frequently aggregated data.

### Rebalancing and Elasticity

**Partition Splitting Mechanics**

Growth triggers partition splits at either level. Primary partition splits require redistributing entire sub-partition sets to new nodes. Sub-partition splits affect single primary partitions, keeping data movement localized. Split strategies: predetermined split points based on key ranges, dynamic splitting at median values from statistics, or consistent hashing with virtual nodes for gradual rebalancing.

**Data Movement Complexity**

Composite partitioning multiplies data movement overhead. Rebalancing N primary partitions with M sub-partitions each potentially moves N×M partition replicas. [Inference] This amplifies network bandwidth consumption and rebalancing duration compared to single-level partitioning. Mitigation: limit rebalancing to specific partition levels, use background copy processes with double-write reconciliation, or implement virtual node mapping to redistribute sub-partitions without physical data movement.

**Hotspot Remediation**

Detecting hotspots requires monitoring at both partition levels. Primary partition hotspots necessitate key redistribution or additional hash bucketing. Sub-partition hotspots may indicate secondary key skew, requiring re-partitioning with different secondary strategies or splitting specific sub-partitions. Automated remediation risks cascading rebalances; conservative thresholds (e.g., 3x average load sustained over hours) prevent oscillation.

### Consistency and Transaction Boundaries

**Atomicity Constraints**

Transactions spanning multiple sub-partitions within a primary partition can leverage local coordination if co-located on the same node. Cross-primary-partition transactions require distributed consensus (two-phase commit, Paxos, Raft). Composite partitioning exacerbates distributed transaction overhead when write patterns don't align with partition boundaries.

**Isolation Level Interactions**

Snapshot isolation implementations maintain version visibility per partition. Composite partitioning requires coordinating timestamps or version vectors across partition hierarchy. [Inference] Causal consistency guarantees become more complex as writes may propagate through multiple partition levels with different replication topologies. Relaxed consistency models (eventual, causal) better accommodate composite partitioning's distributed nature.

### Anti-Patterns

**Excessive Partition Depth**: Three or more partition levels introduce prohibitive metadata overhead and query planning complexity. Limit hierarchy depth to two levels; use alternative strategies (sharding + partitioning separation) for additional dimensions.

**Mismatched Partition Counts**: Creating 10 primary partitions with 1000 sub-partitions each yields unmanageable partition counts (10,000 total). [Inference] This overwhelms metadata systems, increases query planning time, and fragments data excessively. Guideline: total partition count should not exceed 10x node count; sub-partition count per primary should remain under 100.

**Static Partition Schemes**: Hard-coded partition boundaries prevent adapting to growth or workload changes. [Inference] This forces periodic full data migrations as boundaries become obsolete. Implementation must support dynamic partition modification without downtime.

**Ignoring Physical Topology**: Assigning sub-partitions to nodes without considering network topology or availability zones creates single points of failure. [Inference] Sub-partitions of the same primary partition should distribute across fault domains to maintain availability during node failures.

### Monitoring Requirements

Track metrics at both partition levels: request rate per partition, data size distribution, query latency percentiles per partition, and cross-partition query frequency. Alerting thresholds: individual partition load exceeding 2x average, partition size variance coefficient >0.5, or cross-partition query percentage >30% indicating poor key design.

**Related Topics**: Consistent hashing, partition pruning algorithms, distributed query planning, multi-dimensional indexing, shard rebalancing strategies

---

## Read Replicas

### Architectural Pattern

Read replicas implement asynchronous replication from a primary (master) database instance to one or more secondary (replica) instances. The primary handles all write operations and propagates changes to replicas, which serve read-only queries. This pattern fundamentally trades strict consistency for horizontal read scalability.

### Replication Mechanisms

**Statement-Based Replication** Replicas execute the same SQL statements as the primary. Suffers from non-deterministic function issues (NOW(), RAND(), UUID()) and statement ordering dependencies. Largely deprecated in production systems.

**Row-Based Replication** Transmits actual data changes as binary log events. Eliminates non-determinism but generates larger replication streams for bulk operations. Industry standard for MySQL/MariaDB production deployments.

**Logical Replication** Publishes data changes as logical changesets (PostgreSQL) allowing selective table replication, cross-version compatibility, and heterogeneous replication targets. Enables zero-downtime major version upgrades.

**Physical Replication** Streams WAL (Write-Ahead Log) segments or page-level changes. Provides byte-identical replicas but requires version matching and full-instance replication. Default for PostgreSQL streaming replication.

### Replication Lag Management

**Monitoring Strategy** Track `seconds_behind_master` (MySQL) or `pg_last_wal_receive_lsn` vs `pg_last_wal_replay_lsn` (PostgreSQL). Establish alerting thresholds based on business requirements (typical: <5s warning, <30s critical).

**Lag Mitigation**

- Tune `innodb_flush_log_at_trx_commit` and `sync_binlog` (MySQL) or `synchronous_commit` (PostgreSQL) based on durability vs performance tradeoffs
- Implement parallel replication workers (`slave_parallel_workers`, `max_parallel_workers`)
- Partition replication streams by database/schema to isolate hot tables
- Scale replica hardware (faster disks, more IOPS) independently from primary

**Application-Level Handling**

```python
# Anti-pattern: Blind replica reads
user = write_to_primary(user_data)
profile = read_from_replica(user.id)  # May not exist yet

# Correct: Sticky sessions after writes
session['last_write_ts'] = time.time()
if time.time() - session.get('last_write_ts', 0) < REPLICATION_LAG_SLA:
    profile = read_from_primary(user.id)
else:
    profile = read_from_replica(user.id)
```

### Load Distribution Strategies

**DNS-Based Routing** Multiple A records for replica endpoint. Coarse-grained, no health checking, client-side caching issues. Avoid for latency-sensitive workloads.

**Connection Pool Proxies** ProxySQL, PgBouncer, HAProxy with health checks. Enables query-level routing rules, connection multiplexing, and automatic failover detection.

**Application-Level**

```java
@Transactional(readOnly = true)
@ReplicaRoute  // Custom annotation
public List<Order> findRecentOrders(Long userId) {
    return orderRepository.findByUserIdAndCreatedAfter(
        userId, 
        Instant.now().minus(7, ChronoUnit.DAYS)
    );
}
```

**Service Mesh Integration** Envoy/Istio sidecar proxies with L7 routing based on SQL query inspection or custom headers (`X-Replica-Safe: true`).

### Consistency Models

**Eventual Consistency** Default model. Reads may return stale data until replication converges. Acceptable for dashboards, reporting, search indexing.

**Read-Your-Writes** Route user's reads to primary after their writes until lag window expires. Critical for user-facing operations (profile updates, post visibility).

**Monotonic Reads** Ensure single user never observes time going backwards. Implement session affinity to specific replica or track LSN/GTID in session state.

**Causal Consistency** Respect happens-before relationships across related entities. Requires vector clocks or lamport timestamps in application layer.

### Failover Considerations

**Promotion Mechanisms**

- Manual promotion: Operations team triggers switchover after verification
- Automatic promotion: Tools like Patroni, MHA (MySQL), repmgr (PostgreSQL) detect primary failure and promote replica
- Consensus-based: Use etcd/Consul to elect new primary, update DNS/proxy configuration atomically

**Data Loss Scenarios** Semi-synchronous replication (MySQL) or synchronous_commit = remote_apply (PostgreSQL) ensures at least one replica acknowledges before commit returns. Fully asynchronous replication risks data loss equal to replication lag at failure time.

**Split-Brain Prevention** Implement fencing mechanisms (STONITH in cluster environments) and enable GTID-based replication (MySQL) or replication slots (PostgreSQL) to prevent divergent timelines.

### Anti-Patterns

**Replica for Backups** Read replicas are not backups. Corruption, DROP TABLE, or malicious DELETE propagates immediately. Maintain separate PITR-enabled backup strategy.

**Ignoring Cascade Lag** Multi-tier replication (primary → replica1 → replica2) compounds lag multiplicatively. Flat topologies preferred.

**Oversized Transactions** Large batch operations (millions of rows) create replication lag spikes. Chunk into smaller transactions with explicit commit points.

**Replicating Hot Tables Only** Partial replication breaks foreign key relationships and JOIN queries. Use table-level routing or full logical replication.

**Unbounded Read Replica Count** Each replica increases primary load (replication stream bandwidth, IOPS for binlog/WAL reads). Practical limit: 5-10 replicas before introducing intermediate aggregators or CDC-based solutions.

### Advanced Patterns

**Delayed Replicas** Configure intentional lag (e.g., 1 hour) for protection against logical errors. Allows recovery from accidental data modification before it reaches delayed replica.

**Regional Replicas** Deploy replicas in geographic proximity to read-heavy services. Reduce cross-region latency but increases replication lag due to distance. Requires application-aware routing.

**Reporting Replicas** Dedicated replicas with analytical workload indexes, materialized views, or column-store extensions (PostgreSQL cstore_fdw). Isolate heavy aggregations from operational queries.

**CDC Integration** Consume replication stream (Debezium, Maxwell) to populate Elasticsearch, cache layers, or event buses without adding read load to databases.

### Operational Metrics

- Replication lag (seconds behind master)
- Replication throughput (events/sec, MB/sec)
- Replica query latency distribution (p50, p99, p999)
- Primary-replica query distribution ratio
- Failed replication events requiring manual intervention
- Network saturation between primary and replicas

Related topics: Connection pooling, query optimization, database sharding, multi-master replication, conflict-free replicated data types (CRDTs).

---

## Master-Slave Architecture

A replication pattern where a master node handles write operations and propagates changes to one or more slave nodes that serve read operations. This pattern addresses read scalability, fault tolerance, and geographic distribution requirements while introducing consistency trade-offs and operational complexity.

### Core Mechanics

The master maintains the authoritative dataset and processes all write operations. Slaves replicate data through log shipping, statement replication, or row-based replication mechanisms. Replication can be synchronous (master waits for slave acknowledgment) or asynchronous (fire-and-forget). The replication lag—the temporal gap between master writes and slave visibility—directly impacts consistency guarantees.

### Replication Strategies

**Synchronous Replication**: Master blocks write commits until at least one slave confirms receipt. Provides strong consistency guarantees but introduces latency proportional to network round-trip time and slave processing speed. Single slow or unavailable slave can degrade entire cluster write performance. Semi-synchronous variants (e.g., MySQL semi-sync) require acknowledgment from only a subset of slaves, balancing consistency with availability.

**Asynchronous Replication**: Master commits writes immediately without slave confirmation. Maximizes write throughput and decouples master performance from slave health, but creates eventual consistency windows. Slave failures or network partitions cause unbounded replication lag. Data loss occurs if master fails before slaves replicate pending changes.

**Logical vs Physical Replication**: Logical replication transmits high-level operations (SQL statements, document changes) enabling cross-version compatibility and selective replication. Physical replication transfers low-level data blocks or WAL segments, offering higher fidelity and performance but requiring identical software versions and architectures.

### Read Scaling Anti-Patterns

**Naive Load Balancing**: Distributing reads uniformly across slaves without considering replication lag exposes stale data to applications expecting read-after-write consistency. Applications must implement lag monitoring and intelligent routing, or accept stale reads as system-level constraint.

**Unbounded Slave Count**: Adding slaves linearly increases master replication overhead. Each slave consumes master network bandwidth, CPU for replication stream generation, and potentially locks for consistent snapshots. Replication topology becomes critical—cascading replication (slaves replicating from other slaves) reduces master load but increases end-to-end lag.

**Session Affinity Misuse**: Sticky sessions to guarantee consistent reads defeat horizontal scaling and create hotspots. Prefer explicit consistency controls (read-from-master flags, causal consistency tokens) over implicit session routing.

### Write Bottleneck Reality

Master remains single point of write contention. Write-heavy workloads cannot scale horizontally without partitioning data (sharding). Vertical scaling (larger master instance) provides temporary relief but hits hardware limits. Write scaling requires either:

- **Active-Active Multi-Master**: Multiple nodes accept writes with conflict resolution (last-write-wins, vector clocks, CRDTs). Introduces split-brain risks and complex conflict semantics.
- **Sharding**: Partition data across independent master-slave clusters by key ranges or hashes. Requires cross-shard query coordination and distributed transaction handling.
- **Write Caching**: Buffer writes in front of master using queues or write-through caches. Shifts consistency burden to application layer and complicates failure recovery.

### Failover Complexities

**Slave Promotion**: Promoting slave to master requires: verifying slave has latest data (comparing replication positions), reconfiguring remaining slaves to replicate from new master, redirecting application writes, updating DNS/service discovery. Automated failover systems must prevent split-brain scenarios where multiple nodes believe they are master.

**Data Divergence**: Asynchronous replication guarantees data loss during failover. Transactions committed on old master but not replicated to promoted slave are lost. Quantifying acceptable data loss (Recovery Point Objective) determines replication strategy. Zero data loss requires synchronous replication to at least one slave with significant performance cost.

**Cascading Failures**: Promoting slave reduces cluster read capacity and increases load on remaining slaves. If promotion triggers under high load, remaining slaves may fail from increased traffic, causing cascading collapse. Capacity planning must account for N-1 redundancy.

### Consistency Models

**Read-Your-Writes**: Application reads must reflect its own previous writes. Requires routing user's reads to master or tracking replication positions per session. Session tokens containing commit log position allow slaves to delay serving reads until reaching required position.

**Monotonic Reads**: Successive reads must not return older data. Requires sticky sessions or vector clocks to track causal dependencies. Without this, users may see items appear and disappear as requests hit slaves with different lag.

**Causal Consistency**: If operation B depends on operation A, all nodes must see A before B. Requires explicit dependency tracking or synchronous replication for causally-related operations. Most master-slave systems do not provide causal consistency without application-level mechanisms.

### Monitoring Critical Metrics

**Replication Lag**: Time or transaction count difference between master and slaves. Measured via log position comparison (MySQL binlog position, PostgreSQL LSN, MongoDB oplog timestamp). Alerts should trigger before lag causes user-visible inconsistencies.

**Slave Throughput**: Replication is often single-threaded per table/database, limiting slave ability to keep pace with parallel master writes. Parallel replication features (MySQL MTS, PostgreSQL parallel apply) improve throughput but introduce their own consistency challenges.

**Network Partitions**: Slave unreachable from master but still serving reads creates split-brain risk. Health checks must differentiate network failures from slave failures. Fencing mechanisms prevent partitioned slaves from accepting queries.

### Production Implementation Considerations

Configure separate monitoring for replication stream health versus data freshness. Replication can be "connected" but lagging hours behind. Set aggressive timeouts for replication connections to fail fast. Implement graceful degradation: redirect reads to master if all slaves lag beyond threshold, accepting reduced read capacity over serving stale data.

Use row-based replication over statement-based to avoid non-deterministic function execution differences (NOW(), RAND(), UUID()). Statement-based replication can cause silent divergence between master and slaves.

Test failover regularly under realistic load. Failover procedures that succeed in staging often fail in production due to load-induced timeouts, connection storms, or cache invalidation cascades.

Size slave instances identically to master to enable promotion without capacity loss. Heterogeneous slave sizes complicate promotion decisions and capacity planning.

Related topics: Database sharding strategies, Distributed consensus protocols, CQRS pattern, Event sourcing, CAP theorem trade-offs, Multi-region replication topologies

---

## Multi-Master Architecture

Multi-master architecture enables multiple nodes to accept write operations simultaneously, eliminating single points of failure and enabling horizontal write scalability. Each master node maintains a complete or partitioned copy of the dataset and propagates changes to other masters through replication mechanisms.

### Conflict Resolution Strategies

**Last-Write-Wins (LWW)** Timestamps or vector clocks determine which concurrent write prevails. Requires synchronized clocks across nodes or logical clock implementations like Lamport timestamps. Suffers from data loss when concurrent updates target the same record.

**Version Vectors** Each node maintains a vector of version numbers tracking updates from all nodes. Enables detection of concurrent modifications and causal relationships. Amazon's Dynamo DB uses this approach with sibling resolution at read time.

**Operational Transformation (OT)** Transforms concurrent operations to maintain consistency without blocking. Essential for collaborative editing systems. Requires commutative and associative transformation functions.

**Conflict-Free Replicated Data Types (CRDTs)** Mathematically proven convergence without coordination. CvRDTs (state-based) merge entire states; CmRDTs (operation-based) merge operations. Examples include G-Counter, PN-Counter, LWW-Element-Set, and OR-Set.

**Application-Level Resolution** Push conflict detection and resolution to application logic. Preserves all conflicting versions for manual or business-rule-based reconciliation. Used in systems requiring audit trails or regulatory compliance.

### Replication Topologies

**Full Mesh** Every master replicates to every other master. Provides fastest convergence but generates O(n²) replication traffic. Practical only for small clusters (≤10 nodes).

**Ring Topology** Each node replicates to the next node in a circular arrangement. Reduces connection overhead to O(n) but increases convergence latency. Single node failure breaks replication chain without proper failure detection.

**Star Topology** Designated hub nodes aggregate and redistribute changes. Reduces connection complexity but creates bottlenecks. Hub failure requires failover mechanisms.

**Hierarchical** Multi-tier replication with regional masters aggregating local writes. Optimizes for geographic distribution and reduces cross-region traffic. Increases complexity in failure scenarios.

### Quorum-Based Consistency

**Tunable Consistency** Configuration of R (read quorum), W (write quorum), and N (replication factor) controls consistency vs. availability trade-offs:

- `R + W > N`: Strong consistency guarantee
- `R + W ≤ N`: Eventual consistency with better availability
- `W = 1, R = N`: Optimized for write performance
- `W = N, R = 1`: Optimized for read performance

**Sloppy Quorums** Accepts writes to any N healthy nodes during network partitions, not just designated replicas. Improves write availability but requires hinted handoff mechanisms to restore proper replica placement.

**Hinted Handoff** Failed write targets stored temporarily on surviving nodes with metadata indicating intended recipient. Replayed automatically when target recovers. Creates additional storage and processing overhead.

### Split-Brain Prevention

**Fencing Tokens** Monotonically increasing tokens granted by coordination service. Operations include token in requests; storage layer rejects tokens lower than last processed. Prevents zombie masters from corrupting data.

**Distributed Locks** Coordination services (ZooKeeper, etcd, Consul) provide distributed locks ensuring only one master processes specific partitions. Requires careful handling of lock expiration and session timeouts.

**STONITH (Shoot The Other Node In The Head)** Forcefully power-cycles suspected failed nodes before allowing failover. Guarantees isolated node cannot corrupt shared storage. Common in HA clustering with shared storage.

**Witness Nodes** Lightweight arbitrator nodes break ties during network partitions without storing data. Prevents split-brain in two-datacenter deployments. Must reside in third failure domain.

### Anti-Patterns

**Ignoring Conflict Resolution** Assuming conflicts won't occur or handling them generically loses data or creates inconsistent states. [Unverified: behavior depends on specific implementation]

**Synchronous Cross-Region Replication** Blocking writes for cross-datacenter acknowledgment kills write latency. Multi-master deployments must use asynchronous replication between regions with careful conflict handling.

**Unbounded Replication Lag** Allowing indefinite delays between write acceptance and propagation creates unpredictable eventual consistency windows. Implement lag monitoring and backpressure mechanisms.

**Single Global Sequence** Requiring globally coordinated sequence numbers for ordering eliminates scalability benefits. Use per-node sequences with vector clocks for causal ordering.

**Uniform Data Distribution** Failing to account for hotspot partitions causes uneven write load distribution. Implement consistent hashing with virtual nodes and partition splitting.

### Monitoring and Observability

**Replication Lag Metrics** Track time delta between write timestamp and application on each replica. Alert on excessive lag indicating network issues, overload, or bugs.

**Conflict Rate** Monitor frequency of detected conflicts. Sustained high rates indicate insufficient partitioning, poor key selection, or application design issues.

**Version Vector Size** Growing version vectors indicate nodes not properly garbage collecting old versions. Can cause memory exhaustion and performance degradation.

**Cross-Node Traffic** Measure replication bandwidth consumption. Unexpected spikes suggest replication storms, inefficient change capture, or chatty conflict resolution.

### Implementation Considerations

**Schema Evolution** Multi-master systems must handle concurrent schema changes. Implement schema versioning with forward/backward compatibility. Consider schema-on-read approaches for flexibility.

**Transaction Boundaries** Distributed transactions across masters require two-phase commit, killing availability. Partition data to contain transactions within single master. Use saga pattern for cross-master workflows.

**Garbage Collection** Tombstones marking deleted records must propagate to all nodes before physical deletion. Implement vector-clock-based garbage collection avoiding premature deletion of unsynced data.

**Bootstrap and Synchronization** New nodes joining cluster must obtain consistent snapshot without blocking writes. Implement snapshot isolation with incremental catch-up using change logs.

**Related Topics:** Eventual consistency models, consensus algorithms (Paxos, Raft), sharding strategies, vector clock implementations, distributed transaction patterns, CAP theorem trade-offs, Byzantine fault tolerance

---

## Database Federation

Database federation is a horizontal partitioning strategy that distributes data across multiple autonomous database instances based on a sharding key, enabling linear scalability by eliminating single points of contention. Each federated database (federation member) owns a distinct subset of data, operates independently, and shares no physical resources with other members.

### Core Implementation Architecture

**Sharding Key Selection**: The sharding key determines data distribution and must exhibit high cardinality, uniform distribution, and stable access patterns. Poor key selection creates hotspots that negate federation benefits. Common anti-patterns include auto-incrementing integers (sequential writes concentrate on newest shard), low-cardinality fields (skewed distribution), and frequently updated values (cross-shard migration overhead).

**Partition Function Design**: Hash-based partitioning (consistent hashing with virtual nodes) provides uniform distribution but prevents range queries across logical groupings. Range-based partitioning enables efficient range scans but requires careful boundary management to prevent hotspots at range edges. Geographic or entity-based partitioning optimizes data locality but may create imbalanced shards requiring dynamic rebalancing.

**Federation Topology**: Logical shards map to physical database instances. Over-provisioning logical shards (10-100x physical nodes) enables granular rebalancing without data movement. Virtual shard layers decouple logical partitioning from physical infrastructure, allowing transparent node addition/removal through shard migration rather than repartitioning.

### Routing Layer Implementation

**Routing Strategy**: Client-side routing embeds shard resolution logic in application code, minimizing latency but complicating deployments and version management. Proxy-based routing centralizes logic in a stateless middleware layer, simplifying clients but introducing an additional network hop. Configuration-driven routers use external metadata stores (etcd, Consul) to maintain shard mappings, enabling dynamic reconfiguration without code changes.

**Query Routing Patterns**: Single-shard queries route directly to the target federation member based on sharding key lookup. Scatter-gather queries fan out to all shards, execute in parallel, and merge results at the router—acceptable for analytical workloads but prohibited for transactional paths due to latency multiplication. Targeted multi-shard queries use secondary indices or denormalization to minimize fanout scope.

**Connection Pool Management**: Each application instance maintains connection pools per federation member. Pool sizing follows `connections_per_shard = (total_app_instances × max_concurrent_queries) / num_shards`, with per-shard circuit breakers preventing cascade failures. Sticky routing based on consistent hashing reduces connection churn during shard rebalancing.

### Cross-Shard Operations

**Distributed Transactions**: Avoid two-phase commit (2PC) protocols—network partitions and coordinator failures create indefinite blocking states. Compensating transactions (Saga pattern) implement eventual consistency through forward recovery with explicit rollback handlers for each step. Deterministic operation ordering and idempotent handlers prevent duplicate execution during retries.

**Cross-Shard Joins**: Prohibited in federation architectures. Denormalize frequently joined entities into the same shard based on access patterns. Implement application-level joins by fetching related entities in parallel and merging in application memory. For read-heavy scenarios, maintain eventually consistent read replicas with pre-joined views.

**Secondary Indices**: Global secondary indices spanning all shards require scatter-gather queries or centralized index services that reference data locations. Local secondary indices within each shard avoid cross-shard coordination but only support queries including the sharding key. Implement application-level index tables in a separate federation using the secondary attribute as sharding key, storing pointers to primary data locations.

### Data Consistency Guarantees

**Intra-Shard Consistency**: Each federation member provides full ACID guarantees within its data partition. Transaction boundaries cannot span shards. Entity aggregates must colocate within single shards, requiring careful domain modeling to minimize cross-shard dependencies.

**Inter-Shard Consistency**: Federation inherently provides BASE (Basically Available, Soft state, Eventual consistency) semantics across shards. Implement explicit eventual consistency patterns: publish domain events on state changes, consume events asynchronously to update dependent entities in other shards. Use versioning and conflict resolution strategies (last-write-wins, application-specific merge functions) for concurrent updates.

**Causal Consistency**: Vector clocks or hybrid logical clocks track causality across shards. Clients include version vectors with requests, enabling detection of concurrent modifications and preservation of happens-before relationships. Required for scenarios where cross-shard operation ordering affects correctness.

### Rebalancing and Shard Migration

**Trigger Conditions**: Monitor per-shard metrics—storage utilization, query throughput, CPU saturation. Rebalance when coefficient of variation exceeds thresholds (typically CV > 0.3 indicates imbalance). Proactive rebalancing prevents emergency migrations under load.

**Migration Protocols**: Implement dual-write phases where writes propagate to both source and destination shards during migration. Read path checks both locations until cutover completes. Bulk copy historical data asynchronously with incremental catchup synchronization. Use timestamp-based filtering to avoid duplicate processing during cutover windows.

**Minimal Downtime Strategies**: Logical shard movement through routing table updates enables zero-downtime migration when using virtual shards. Physical data movement requires read-replica promotion—create replica on destination node, sync continuously, promote replica while demoting source. Reverse proxy cutover updates routing atomically.

### Monitoring and Observability

**Shard-Level Metrics**: Track query latency percentiles, connection pool saturation, replication lag (if using replicas), and storage growth per shard. Distributed tracing with shard ID propagation enables correlation of cross-shard request flows. Alert on shard imbalance metrics and hotspot detection (requests concentrated on specific keys).

**Query Pattern Analysis**: Log queries with execution plans and shard targeting information. Identify scatter-gather patterns in hot paths requiring schema optimization. Track cross-shard operation frequency to validate domain model boundaries.

### Anti-Patterns and Failure Modes

**Over-Sharding**: Excessive shard counts increase connection overhead, complicate operational management, and fragment data unnecessarily when query patterns don't require parallelism. Start conservatively; splitting shards is easier than merging.

**Under-Sharding**: Insufficient shards create resource contention and limit scaling headroom. Cannot exceed node capacity through parallelism alone. Pre-provision logical shards beyond immediate needs.

**Shared Schema Anti-Pattern**: Database-level federation with shared schema across tenants creates noisy neighbor effects and limits per-tenant optimization. True isolation requires separate database instances per federation member.

**Shard Key Mutation**: Changing a record's sharding key value requires cross-shard data movement and potential consistency violations. Designate sharding keys as immutable attributes or implement explicit migration workflows with versioned reads.

**Cascading Failures**: Single shard failure can trigger client retry storms affecting healthy shards. Implement per-shard circuit breakers, bulkheads limiting concurrent requests per shard, and fail-fast semantics with explicit degraded-mode handling.

Related topics: Consistent Hashing Algorithms, Distributed Transaction Patterns, Database Sharding vs Partitioning, Multi-Tenancy Isolation Strategies, Distributed Query Optimization.

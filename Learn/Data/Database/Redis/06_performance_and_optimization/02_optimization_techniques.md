## Optimization Techniques


### Command Optimization Strategies

#### Atomic Operations and Complexity Analysis

Redis commands have different time complexities that directly impact performance. Understanding these complexities enables better command selection and optimization strategies.

**Time Complexity Considerations:**

```
# O(1) operations - prefer these
SET key value
GET key
HGET hash field
LPUSH list value

# O(N) operations - use carefully
KEYS pattern        # Avoid in production
FLUSHALL           # Blocks entire server
SMEMBERS set       # Returns all members

# O(log N) operations - efficient for sorted sets
ZADD sortedset score member
ZRANGE sortedset start stop
```

#### Replacing Expensive Operations

**Avoiding KEYS Command:**

```python
# Bad - blocks server
keys = redis_client.keys("user:*")

# Good - use SCAN for large keyspaces
def scan_keys(pattern, count=1000):
    cursor = 0
    keys = []
    while True:
        cursor, partial_keys = redis_client.scan(
            cursor, match=pattern, count=count
        )
        keys.extend(partial_keys)
        if cursor == 0:
            break
    return keys
```

**Optimizing Range Operations:**

```python
# Instead of multiple individual gets
def get_multiple_inefficient(keys):
    result = {}
    for key in keys:
        result[key] = redis_client.get(key)
    return result

# Use MGET for batch retrieval
def get_multiple_efficient(keys):
    values = redis_client.mget(keys)
    return dict(zip(keys, values))
```

#### Lua Scripting for Complex Operations

Lua scripts execute atomically and reduce network roundtrips:

```lua
-- Atomic increment with limit
local current = redis.call('GET', KEYS[1])
if current == false then
    current = 0
else
    current = tonumber(current)
end

if current < tonumber(ARGV[1]) then
    redis.call('INCR', KEYS[1])
    redis.call('EXPIRE', KEYS[1], ARGV[2])
    return current + 1
else
    return -1
end
```

```python
# Python implementation
increment_script = redis_client.register_script(lua_script)
result = increment_script(keys=['counter:user:123'], args=[100, 3600])
```

#### Conditional Operations

**Using EXISTS for Conditional Logic:**

```python
# Inefficient - two roundtrips
if redis_client.exists('session:123'):
    data = redis_client.get('session:123')

# Efficient - single roundtrip with null check
data = redis_client.get('session:123')
if data is not None:
    # Process data
    pass
```

**Atomic Conditional Updates:**

```python
# Use SET with conditions
redis_client.set('lock:resource', 'owner123', nx=True, ex=30)

# Use SETNX for distributed locks
def acquire_lock(resource, owner, timeout=30):
    lock_key = f'lock:{resource}'
    if redis_client.set(lock_key, owner, nx=True, ex=timeout):
        return True
    return False
```

### Pipeline and Batch Operations

#### Pipelining Fundamentals

Pipelining reduces network latency by batching commands without waiting for individual responses:

```python
# Without pipelining - 1000 network roundtrips
def set_values_sequential(data):
    for key, value in data.items():
        redis_client.set(key, value)

# With pipelining - 1 network roundtrip
def set_values_pipelined(data):
    pipe = redis_client.pipeline()
    for key, value in data.items():
        pipe.set(key, value)
    pipe.execute()
```

#### Advanced Pipeline Patterns

**Chunked Pipeline Processing:**

```python
def process_large_dataset(data, chunk_size=1000):
    results = []
    for i in range(0, len(data), chunk_size):
        chunk = data[i:i + chunk_size]
        pipe = redis_client.pipeline()
        
        for item in chunk:
            pipe.set(f'key:{item["id"]}', item['value'])
            pipe.expire(f'key:{item["id"]}', 3600)
        
        chunk_results = pipe.execute()
        results.extend(chunk_results)
    
    return results
```

**Pipeline with Error Handling:**

```python
def robust_pipeline_execution(commands):
    pipe = redis_client.pipeline()
    
    try:
        for cmd, args in commands:
            getattr(pipe, cmd)(*args)
        
        results = pipe.execute()
        return results
    except redis.exceptions.ResponseError as e:
        # Handle individual command errors
        pipe.reset()
        results = []
        for cmd, args in commands:
            try:
                result = getattr(redis_client, cmd)(*args)
                results.append(result)
            except Exception as cmd_error:
                results.append(None)
        return results
```

#### Transaction Pipelines

**MULTI/EXEC with Pipelining:**

```python
def atomic_counter_update(counters):
    pipe = redis_client.pipeline()
    pipe.multi()
    
    for counter_key in counters:
        pipe.incr(counter_key)
        pipe.expire(counter_key, 3600)
    
    # Execute all commands atomically
    results = pipe.execute()
    return results
```

**Watch/Multi Pattern:**

```python
def optimistic_locking_update(key, update_func):
    while True:
        pipe = redis_client.pipeline()
        pipe.watch(key)
        
        current_value = pipe.get(key)
        pipe.multi()
        
        new_value = update_func(current_value)
        pipe.set(key, new_value)
        
        try:
            pipe.execute()
            break
        except redis.WatchError:
            # Value changed, retry
            continue
```

### Connection Pooling

#### Connection Pool Configuration

**Basic Pool Setup:**

```python
import redis

# Configure connection pool
pool = redis.ConnectionPool(
    host='localhost',
    port=6379,
    db=0,
    max_connections=20,
    retry_on_timeout=True,
    socket_timeout=5,
    socket_connect_timeout=5,
    socket_keepalive=True,
    socket_keepalive_options={}
)

redis_client = redis.Redis(connection_pool=pool)
```

**Advanced Pool Configuration:**

```python
# Production-ready pool settings
pool = redis.ConnectionPool(
    host='redis-cluster',
    port=6379,
    db=0,
    max_connections=50,
    retry_on_timeout=True,
    socket_timeout=2,
    socket_connect_timeout=2,
    socket_keepalive=True,
    socket_keepalive_options={
        'TCP_KEEPIDLE': 1,
        'TCP_KEEPINTVL': 3,
        'TCP_KEEPCNT': 5
    },
    health_check_interval=30
)
```

#### Pool Monitoring and Management

**Pool Statistics Monitoring:**

```python
def monitor_connection_pool(pool):
    created_connections = pool.created_connections
    available_connections = len(pool._available_connections)
    in_use_connections = len(pool._in_use_connections)
    
    print(f"Created: {created_connections}")
    print(f"Available: {available_connections}")
    print(f"In use: {in_use_connections}")
    
    # Calculate pool utilization
    utilization = (in_use_connections / pool.max_connections) * 100
    print(f"Pool utilization: {utilization:.2f}%")
```

**Connection Pool Strategies:**

```python
class RedisConnectionManager:
    def __init__(self, config):
        self.pools = {}
        self.config = config
    
    def get_pool(self, db=0):
        if db not in self.pools:
            self.pools[db] = redis.ConnectionPool(
                host=self.config['host'],
                port=self.config['port'],
                db=db,
                max_connections=self.config['max_connections'],
                **self.config['pool_options']
            )
        return self.pools[db]
    
    def get_client(self, db=0):
        pool = self.get_pool(db)
        return redis.Redis(connection_pool=pool)
```

#### Thread Safety and Pool Management

**Thread-Safe Pool Usage:**

```python
import threading
import redis

class ThreadSafeRedisClient:
    def __init__(self, **pool_kwargs):
        self.pool = redis.ConnectionPool(**pool_kwargs)
        self.local = threading.local()
    
    def get_client(self):
        if not hasattr(self.local, 'client'):
            self.local.client = redis.Redis(connection_pool=self.pool)
        return self.local.client
    
    def execute(self, command, *args, **kwargs):
        client = self.get_client()
        return getattr(client, command)(*args, **kwargs)
```

### Data Structure Selection for Performance

#### String vs Hash Trade-offs

**Memory Efficiency Analysis:**

```python
# Storing user data as individual keys
def store_user_strings(user_id, user_data):
    for field, value in user_data.items():
        redis_client.set(f'user:{user_id}:{field}', value)

# More memory efficient with hashes
def store_user_hash(user_id, user_data):
    redis_client.hmset(f'user:{user_id}', user_data)

# Benchmark comparison
import time
import random

def benchmark_storage_methods(num_users=10000):
    user_data = {
        'name': 'John Doe',
        'email': 'john@example.com',
        'age': '30',
        'status': 'active'
    }
    
    # String method
    start = time.time()
    for i in range(num_users):
        store_user_strings(i, user_data)
    string_time = time.time() - start
    
    # Hash method
    start = time.time()
    for i in range(num_users):
        store_user_hash(i, user_data)
    hash_time = time.time() - start
    
    print(f"String method: {string_time:.2f}s")
    print(f"Hash method: {hash_time:.2f}s")
```

#### List vs Set Performance Characteristics

**Choosing Between Lists and Sets:**

```python
# Use lists for ordered data with duplicates
def activity_log_list(user_id, activity):
    redis_client.lpush(f'activity:{user_id}', activity)
    redis_client.ltrim(f'activity:{user_id}', 0, 99)  # Keep last 100

# Use sets for unique membership testing
def user_permissions_set(user_id, permission):
    redis_client.sadd(f'permissions:{user_id}', permission)
    
def has_permission(user_id, permission):
    return redis_client.sismember(f'permissions:{user_id}', permission)
```

#### Sorted Set Optimization

**Efficient Sorted Set Operations:**

```python
# Leaderboard implementation
def update_leaderboard(user_id, score):
    redis_client.zadd('leaderboard', {user_id: score})

def get_top_players(limit=10):
    return redis_client.zrevrange('leaderboard', 0, limit-1, withscores=True)

def get_user_rank(user_id):
    rank = redis_client.zrevrank('leaderboard', user_id)
    return rank + 1 if rank is not None else None

# Time-based sorted sets for expiration
def add_session(session_id, expires_at):
    redis_client.zadd('sessions', {session_id: expires_at})

def cleanup_expired_sessions():
    current_time = time.time()
    expired = redis_client.zrangebyscore('sessions', 0, current_time)
    if expired:
        redis_client.zremrangebyscore('sessions', 0, current_time)
        # Clean up session data
        for session_id in expired:
            redis_client.delete(f'session:{session_id}')
```

#### HyperLogLog for Cardinality Estimation

**Memory-Efficient Unique Counting:**

```python
def track_unique_visitors(page, visitor_id):
    redis_client.pfadd(f'visitors:{page}', visitor_id)

def get_unique_visitor_count(page):
    return redis_client.pfcount(f'visitors:{page}')

# Merge multiple HyperLogLogs
def get_total_unique_visitors(pages):
    keys = [f'visitors:{page}' for page in pages]
    return redis_client.pfcount(*keys)
```

#### Bloom Filters for Membership Testing

**Custom Bloom Filter Implementation:**

```python
import hashlib

class RedisBloomFilter:
    def __init__(self, redis_client, key, size=1000000, hash_count=7):
        self.redis = redis_client
        self.key = key
        self.size = size
        self.hash_count = hash_count
    
    def _hashes(self, item):
        """Generate multiple hash values for an item"""
        item_bytes = str(item).encode('utf-8')
        hashes = []
        for i in range(self.hash_count):
            hash_obj = hashlib.md5(item_bytes + str(i).encode('utf-8'))
            hashes.append(int(hash_obj.hexdigest(), 16) % self.size)
        return hashes
    
    def add(self, item):
        pipe = self.redis.pipeline()
        for hash_val in self._hashes(item):
            pipe.setbit(self.key, hash_val, 1)
        pipe.execute()
    
    def contains(self, item):
        pipe = self.redis.pipeline()
        for hash_val in self._hashes(item):
            pipe.getbit(self.key, hash_val)
        results = pipe.execute()
        return all(results)
```

### Memory Optimization Strategies

#### Key Naming Conventions

**Efficient Key Design:**

```python
# Bad - long, descriptive keys
bad_key = "application:user:session:data:123456789"

# Good - short, structured keys
good_key = "u:s:123456789"

# Key compression mapping
key_mapping = {
    'user': 'u',
    'session': 's',
    'product': 'p',
    'order': 'o'
}
```

#### Memory-Efficient Data Encoding

**Compressed Data Storage:**

```python
import json
import zlib
import pickle

def store_compressed_data(key, data):
    # JSON + compression
    json_data = json.dumps(data)
    compressed = zlib.compress(json_data.encode('utf-8'))
    redis_client.set(key, compressed)

def retrieve_compressed_data(key):
    compressed = redis_client.get(key)
    if compressed:
        decompressed = zlib.decompress(compressed)
        return json.loads(decompressed.decode('utf-8'))
    return None
```

#### Expiration Strategies

**TTL Management:**

```python
def set_with_intelligent_ttl(key, value, base_ttl=3600):
    # Vary TTL based on access patterns
    access_count = redis_client.get(f'access:{key}') or 0
    
    if int(access_count) > 100:
        ttl = base_ttl * 2  # Frequently accessed, keep longer
    else:
        ttl = base_ttl
    
    redis_client.setex(key, ttl, value)
    redis_client.incr(f'access:{key}')
    redis_client.expire(f'access:{key}', ttl)
```

**Key points:**

- Command optimization focuses on choosing efficient operations and avoiding expensive ones
- Pipelining dramatically reduces network latency for batch operations
- Connection pooling manages resources efficiently and improves concurrent performance
- Data structure selection significantly impacts both memory usage and operation performance
- Lua scripting enables atomic complex operations with reduced network overhead
- Memory optimization through key design and compression techniques can substantially reduce Redis memory footprint

---


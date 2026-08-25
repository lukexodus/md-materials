## Redis


### Installation and Setup

#### Installing Redis on Different Operating Systems

**Linux (Ubuntu/Debian)**

```bash
sudo apt update
sudo apt install redis-server
```

**Linux (CentOS/RHEL)**

```bash
sudo yum install epel-release
sudo yum install redis
```

**macOS**

```bash
brew install redis
```

**Windows** Redis doesn't officially support Windows, but can be installed through:

- Windows Subsystem for Linux (WSL)
- Docker
- Memurai (Windows port)

**Docker Installation**

```bash
docker run -d --name redis-server -p 6379:6379 redis:latest
```

**Building from Source**

```bash
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make
sudo make install
```

#### Redis Configuration Files and Key Parameters

**Primary Configuration File Location**

- Linux: `/etc/redis/redis.conf`
- macOS: `/usr/local/etc/redis.conf`
- Source build: `redis-stable/redis.conf`

**Key Configuration Parameters**

**Network and Security**

```
bind 127.0.0.1 ::1
port 6379
protected-mode yes
requirepass yourpassword
```

**Memory Management**

```
maxmemory 256mb
maxmemory-policy allkeys-lru
```

**Persistence**

```
save 900 1
save 300 10
save 60 10000
dbfilename dump.rdb
dir /var/lib/redis
```

**Logging**

```
loglevel notice
logfile /var/log/redis/redis-server.log
```

**Performance Tuning**

```
tcp-keepalive 300
timeout 0
tcp-backlog 511
databases 16
```

#### Starting and Stopping Redis Server

**System Service (Linux)**

```bash
sudo systemctl start redis-server
sudo systemctl stop redis-server
sudo systemctl restart redis-server
sudo systemctl enable redis-server
```

**macOS (Homebrew)**

```bash
brew services start redis
brew services stop redis
brew services restart redis
```

**Manual Start**

```bash
redis-server
redis-server /path/to/redis.conf
redis-server --port 6380
```

**Background Process**

```bash
redis-server --daemonize yes
```

**Checking Status**

```bash
redis-cli ping
sudo systemctl status redis-server
ps aux | grep redis
```

#### Redis CLI Basics and Connection Methods

**Basic Connection**

```bash
redis-cli
redis-cli -h hostname -p port
redis-cli -h 127.0.0.1 -p 6379
```

**Authentication**

```bash
redis-cli -a password
redis-cli
> AUTH password
```

**Database Selection**

```bash
redis-cli -n 2
> SELECT 2
```

**Remote Connection**

```bash
redis-cli -h remote-server.com -p 6379 -a password
```

**Connection with SSL/TLS**

```bash
redis-cli --tls --cert client.crt --key client.key --cacert ca.crt
```

### Core Data Types and Operations

#### String Operations

**Basic String Commands**

```bash
SET key value
GET key
MSET key1 value1 key2 value2
MGET key1 key2
INCR counter
DECR counter
INCRBY counter 5
EXPIRE key 3600
TTL key
```

**Advanced String Operations**

```bash
APPEND key value
STRLEN key
SETRANGE key offset value
GETRANGE key start end
SETEX key seconds value
SETNX key value
```

#### Hash Operations

**Hash Commands**

```bash
HSET user:1 name "John" age 30
HGET user:1 name
HMSET user:2 name "Jane" age 25 email "jane@example.com"
HMGET user:2 name age
HGETALL user:1
HDEL user:1 age
HEXISTS user:1 name
HINCRBY user:1 visits 1
```

#### List Operations

**List Commands**

```bash
LPUSH mylist item1 item2
RPUSH mylist item3
LPOP mylist
RPOP mylist
LRANGE mylist 0 -1
LLEN mylist
LINDEX mylist 0
LSET mylist 0 newvalue
LTRIM mylist 0 2
```

#### Set Operations

**Set Commands**

```bash
SADD myset member1 member2
SMEMBERS myset
SREM myset member1
SCARD myset
SISMEMBER myset member1
SINTER set1 set2
SUNION set1 set2
SDIFF set1 set2
```

#### Sorted Set Operations

**Sorted Set Commands**

```bash
ZADD scoreboard 100 player1 200 player2
ZRANGE scoreboard 0 -1 WITHSCORES
ZREVRANGE scoreboard 0 -1 WITHSCORES
ZSCORE scoreboard player1
ZRANK scoreboard player1
ZREM scoreboard player1
ZINCRBY scoreboard 50 player1
```

### Advanced Features

#### Transactions

**Transaction Commands**

```bash
MULTI
SET key1 value1
SET key2 value2
EXEC
```

**Conditional Transactions**

```bash
WATCH key1
MULTI
SET key1 newvalue
EXEC
```

#### Pub/Sub Messaging

**Publisher**

```bash
PUBLISH channel message
```

**Subscriber**

```bash
SUBSCRIBE channel
PSUBSCRIBE pattern*
UNSUBSCRIBE channel
```

#### Lua Scripting

**Basic Lua Script**

```bash
EVAL "return redis.call('SET', KEYS[1], ARGV[1])" 1 mykey myvalue
```

**Script Management**

```bash
SCRIPT LOAD "lua script"
EVALSHA sha1 numkeys key1 arg1
SCRIPT EXISTS sha1
SCRIPT FLUSH
```

#### Geospatial Operations

**Geospatial Commands**

```bash
GEOADD locations 13.361389 38.115556 "Palermo"
GEOADD locations 15.087269 37.502669 "Catania"
GEODIST locations Palermo Catania km
GEORADIUS locations 15 37 200 km WITHCOORD WITHDIST
```

### Performance Optimization

#### Memory Optimization

**Memory Analysis**

```bash
MEMORY USAGE key
MEMORY STATS
INFO memory
```

**Memory Policies**

- `noeviction`: Return errors when memory limit reached
- `allkeys-lru`: Evict least recently used keys
- `allkeys-lfu`: Evict least frequently used keys
- `volatile-lru`: Evict LRU keys with expire set
- `volatile-lfu`: Evict LFU keys with expire set
- `allkeys-random`: Evict random keys
- `volatile-random`: Evict random keys with expire set
- `volatile-ttl`: Evict keys with shortest TTL

#### Connection Optimization

**Connection Pooling** Most Redis clients support connection pooling to reduce connection overhead and improve performance.

**Pipelining**

```bash
redis-cli --pipe < commands.txt
```

**Cluster Mode**

```bash
redis-cli -c -h cluster-node -p 7000
```

### Persistence

#### RDB (Redis Database File)

**RDB Configuration**

```
save 900 1
save 300 10
save 60 10000
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
```

**Manual RDB Operations**

```bash
SAVE
BGSAVE
LASTSAVE
```

#### AOF (Append Only File)

**AOF Configuration**

```
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
```

**AOF Management**

```bash
BGREWRITEAOF
CONFIG SET save ""
```

### Replication and High Availability

#### Master-Slave Replication

**Slave Configuration**

```
slaveof masterip masterport
slave-read-only yes
slave-priority 100
```

**Replication Commands**

```bash
SLAVEOF host port
SLAVEOF NO ONE
INFO replication
```

#### Redis Sentinel

**Sentinel Configuration**

```
sentinel monitor mymaster 127.0.0.1 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 10000
sentinel parallel-syncs mymaster 1
```

**Sentinel Commands**

```bash
redis-sentinel /path/to/sentinel.conf
SENTINEL masters
SENTINEL slaves mymaster
SENTINEL failover mymaster
```

#### Redis Cluster

**Cluster Setup**

```bash
redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 --cluster-replicas 1
```

**Cluster Management**

```bash
redis-cli -c -h 127.0.0.1 -p 7000
CLUSTER NODES
CLUSTER INFO
CLUSTER SLOTS
```

### Monitoring and Administration

#### Monitoring Commands

**Server Information**

```bash
INFO
INFO server
INFO memory
INFO replication
INFO persistence
```

**Real-time Monitoring**

```bash
MONITOR
SLOWLOG GET 10
SLOWLOG LEN
SLOWLOG RESET
```

**Client Information**

```bash
CLIENT LIST
CLIENT KILL ip:port
CLIENT SETNAME connectionname
CLIENT GETNAME
```

#### Database Management

**Database Operations**

```bash
SELECT database
FLUSHDB
FLUSHALL
DBSIZE
KEYS pattern
SCAN cursor
```

**Key Management**

```bash
EXISTS key
TYPE key
EXPIRE key seconds
PERSIST key
RENAME key newkey
DEL key1 key2
DUMP key
RESTORE key ttl serialized-value
```

### Security

#### Authentication

**Password Authentication**

```
requirepass strongpassword
```

**User Management (Redis 6+)**

```bash
ACL SETUSER username on >password ~* &* +@all
ACL LIST
ACL WHOAMI
ACL DELUSER username
```

#### Network Security

**Binding Configuration**

```
bind 127.0.0.1 192.168.1.100
protected-mode yes
```

**SSL/TLS Configuration**

```
port 0
tls-port 6380
tls-cert-file /path/to/cert.pem
tls-key-file /path/to/key.pem
tls-ca-cert-file /path/to/ca.pem
```

### Common Use Cases

#### Caching

**Cache Patterns**

- Cache-aside: Application manages cache
- Write-through: Write to cache and database simultaneously
- Write-behind: Write to cache first, database later
- Refresh-ahead: Proactively refresh cache before expiration

**Example Implementation**

```python
import redis
import json

r = redis.Redis(host='localhost', port=6379, db=0)

def get_user(user_id):
    cached_user = r.get(f"user:{user_id}")
    if cached_user:
        return json.loads(cached_user)
    
    # Fetch from database
    user = database.get_user(user_id)
    r.setex(f"user:{user_id}", 3600, json.dumps(user))
    return user
```

#### Session Management

**Session Storage**

```bash
SET session:abc123 '{"user_id": 1, "username": "john"}' EX 3600
GET session:abc123
DEL session:abc123
```

#### Real-time Analytics

**Counters and Metrics**

```bash
INCR page_views
HINCRBY user_stats:123 login_count 1
ZADD daily_scores 100 user1 150 user2
```

#### Message Queues

**Simple Queue with Lists**

```bash
LPUSH queue:tasks task1
BRPOP queue:tasks 0
```

**Priority Queue with Sorted Sets**

```bash
ZADD priority_queue 1 low_priority_task
ZADD priority_queue 10 high_priority_task
BZPOPMAX priority_queue 0
```

### Best Practices

#### Data Modeling

**Key Naming Conventions**

- Use descriptive, hierarchical names: `user:1000:profile`
- Avoid very long key names
- Use consistent separators (typically `:`)
- Include version information when needed: `user:v2:1000`

**Data Structure Selection**

- Use appropriate data types for specific use cases
- Consider memory usage and performance characteristics
- Leverage Redis data structure capabilities

#### Performance Best Practices

**Memory Management**

- Monitor memory usage regularly
- Set appropriate expiration times
- Use memory-efficient data structures
- Configure appropriate eviction policies

**Connection Management**

- Use connection pooling
- Implement proper connection timeouts
- Monitor connection usage

**Command Optimization**

- Use pipelining for batch operations
- Avoid commands with O(N) complexity on large datasets
- Use SCAN instead of KEYS for production systems

### Troubleshooting

#### Common Issues

**Memory Issues**

- Out of memory errors
- Memory fragmentation
- Memory leaks in applications

**Performance Issues**

- Slow queries
- High CPU usage
- Network latency

**Connection Issues**

- Connection timeouts
- Connection pool exhaustion
- Authentication failures

#### Debugging Tools

**Redis CLI Tools**

```bash
redis-cli --latency -h host -p port
redis-cli --latency-history -h host -p port
redis-cli --bigkeys
redis-cli --memkeys
```

**Log Analysis**

- Monitor Redis logs for errors
- Check slow query logs
- Analyze client connections

**Key points:**

- Redis is an in-memory data store with multiple data structures
- Installation varies by OS but follows similar patterns
- Configuration files control behavior, security, and performance
- CLI provides comprehensive interface for all operations
- Advanced features include transactions, pub/sub, and scripting
- Performance optimization involves memory management and connection pooling
- High availability achieved through replication, Sentinel, and clustering
- Security includes authentication, authorization, and network protection
- Common use cases span caching, sessions, analytics, and messaging

---


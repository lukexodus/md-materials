## Redis Replication


### Overview

Redis replication is a fundamental feature that allows data from one Redis server (master) to be copied to one or more Redis servers (replicas/slaves). This mechanism provides data redundancy, fault tolerance, and enables horizontal scaling for read operations while maintaining data consistency across multiple Redis instances.

### Master-Slave Replication Setup

#### Basic Configuration

Redis replication follows a master-slave architecture where one server acts as the master (primary) and others serve as slaves (replicas). The master handles all write operations while slaves can serve read requests.

**Master Configuration:**

```
# redis.conf on master
bind 0.0.0.0
port 6379
# Enable persistence if needed
save 900 1
save 300 10
save 60 10000
```

**Slave Configuration:**

```
# redis.conf on slave
bind 0.0.0.0
port 6380
replicaof 192.168.1.100 6379
# Optional: read-only mode (default)
replica-read-only yes
```

#### Runtime Configuration

Slaves can be configured dynamically without restart:

```
# Connect to slave and run
REPLICAOF 192.168.1.100 6379
# Or disconnect from master
REPLICAOF NO ONE
```

#### Authentication Setup

When master requires authentication:

```
# Master configuration
requirepass mypassword

# Slave configuration
masterauth mypassword
```

### Replication Configuration and Monitoring

#### Key Configuration Parameters

**Replication Timeout Settings:**

```
# Time limit for bulk transfer I/O
repl-timeout 60

# TCP keepalive for master-slave connection
tcp-keepalive 300

# Disable TCP_NODELAY for slave socket
repl-disable-tcp-nodelay no
```

**Backlog Configuration:**

```
# Replication backlog size
repl-backlog-size 1mb

# Backlog retention time
repl-backlog-ttl 3600
```

**Diskless Replication:**

```
# Enable diskless replication
repl-diskless-sync yes

# Delay before starting diskless replication
repl-diskless-sync-delay 5
```

#### Monitoring Commands

**Master Status:**

```
INFO replication
# Returns:
# - role:master
# - connected_slaves:2
# - slave0:ip=192.168.1.101,port=6380,state=online,offset=1234,lag=0
```

**Slave Status:**

```
INFO replication
# Returns:
# - role:slave
# - master_host:192.168.1.100
# - master_port:6379
# - master_link_status:up
# - master_last_io_seconds_ago:0
```

**Monitoring Script Example:**

```python
import redis
import time

def monitor_replication():
    master = redis.Redis(host='192.168.1.100', port=6379)
    slave = redis.Redis(host='192.168.1.101', port=6380)
    
    master_info = master.info('replication')
    slave_info = slave.info('replication')
    
    print(f"Master role: {master_info['role']}")
    print(f"Connected slaves: {master_info['connected_slaves']}")
    print(f"Slave lag: {slave_info.get('master_last_io_seconds_ago', 'N/A')}")
```

### Partial Resynchronization

#### Full vs Partial Resynchronization

**Full Resynchronization:**

- Occurs when slave first connects to master
- Master creates RDB snapshot and sends entire dataset
- Resource-intensive and time-consuming for large datasets

**Partial Resynchronization:**

- Introduced in Redis 2.8
- Uses replication backlog to sync only missing data
- Significantly faster for temporary disconnections

#### Replication Backlog Mechanics

The replication backlog is a circular buffer that stores recent write commands:

```
# Monitor backlog usage
INFO replication
# Look for:
# - repl_backlog_active:1
# - repl_backlog_size:1048576
# - repl_backlog_first_byte_offset:1234
# - repl_backlog_histlen:5678
```

#### Optimizing Partial Resync

**Backlog Sizing:**

```
# Calculate based on disconnection scenarios
# Formula: average_write_rate * max_disconnection_time * safety_factor
repl-backlog-size 10mb
```

**Replication ID Tracking:**

- Master maintains replication ID and offset
- Slaves track master's replication ID
- Enables partial resync after master restart with same dataset

### Read Scaling Strategies

#### Load Distribution Patterns

**Read Replicas for Scaling:**

```python
import redis
import random

class RedisCluster:
    def __init__(self):
        self.master = redis.Redis(host='master', port=6379)
        self.slaves = [
            redis.Redis(host='slave1', port=6379),
            redis.Redis(host='slave2', port=6379),
            redis.Redis(host='slave3', port=6379)
        ]
    
    def write(self, key, value):
        return self.master.set(key, value)
    
    def read(self, key):
        slave = random.choice(self.slaves)
        return slave.get(key)
```

#### Consistent Hashing for Reads

```python
import hashlib

class ConsistentReadDistribution:
    def __init__(self, slaves):
        self.slaves = slaves
        self.ring = {}
        self._build_ring()
    
    def _build_ring(self):
        for i, slave in enumerate(self.slaves):
            for j in range(100):  # Virtual nodes
                key = hashlib.md5(f"{slave.host}:{j}".encode()).hexdigest()
                self.ring[key] = slave
    
    def get_slave(self, key):
        hash_key = hashlib.md5(key.encode()).hexdigest()
        for ring_key in sorted(self.ring.keys()):
            if hash_key <= ring_key:
                return self.ring[ring_key]
        return self.ring[sorted(self.ring.keys())[0]]
```

#### Connection Pooling for Replicas

```python
import redis.sentinel

# Using Redis Sentinel for automatic failover
sentinel = redis.sentinel.Sentinel([
    ('sentinel1', 26379),
    ('sentinel2', 26379),
    ('sentinel3', 26379)
])

# Get master and slave connections
master = sentinel.master_for('mymaster', socket_timeout=0.1)
slave = sentinel.slave_for('mymaster', socket_timeout=0.1)
```

### Advanced Replication Features

#### Diskless Replication

Useful for scenarios with slow disk I/O but fast network:

```
# Enable diskless replication
repl-diskless-sync yes
repl-diskless-sync-delay 5

# For diskless load (experimental)
repl-diskless-load swapdb
```

#### Replication Safety

**Minimum Slaves Configuration:**

```
# Require at least 2 slaves with max 10 second lag
min-replicas-to-write 2
min-replicas-max-lag 10
```

**Write Consistency:**

```
# Wait for replication acknowledgment
WAIT 2 1000  # Wait for 2 slaves, timeout 1000ms
```

### Troubleshooting Common Issues

#### Replication Lag

**Causes and Solutions:**

- Network latency: Optimize network configuration
- Slow slave hardware: Upgrade slave resources
- Large commands: Use pipelining or split operations
- Disk I/O on slave: Consider diskless replication

#### Split-Brain Scenarios

**Prevention:**

```
# Use Redis Sentinel for monitoring
sentinel monitor mymaster 192.168.1.100 6379 2
sentinel down-after-milliseconds mymaster 30000
sentinel failover-timeout mymaster 180000
```

#### Memory Usage in Replication

**Buffer Management:**

```
# Monitor output buffer
INFO clients
# Look for client_longest_output_list and client_biggest_input_buf

# Adjust buffer limits
client-output-buffer-limit replica 256mb 64mb 60
```

### Performance Optimization

#### Replication Performance Tuning

**TCP Configuration:**

```
# Disable Nagle's algorithm for lower latency
repl-disable-tcp-nodelay no

# TCP keepalive settings
tcp-keepalive 300
```

**Persistence Impact:**

```
# Disable persistence on slaves if master persists
save ""
appendonly no
```

#### Monitoring Metrics

**Key Metrics to Track:**

- Replication lag (master_last_io_seconds_ago)
- Replication backlog utilization
- Network bandwidth usage
- Slave connection stability
- Command processing rate

**Key points:**

- Redis replication provides horizontal read scaling and data redundancy
- Partial resynchronization minimizes data transfer during reconnections
- Proper monitoring and configuration are essential for optimal performance
- Load distribution strategies can significantly improve read throughput
- Understanding replication mechanics is crucial for troubleshooting and optimization

---


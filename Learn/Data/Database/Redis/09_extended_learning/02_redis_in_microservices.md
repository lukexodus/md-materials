## Redis in Microservices


### Service Discovery with Redis

### Overview

Redis serves as an effective service registry and discovery mechanism in microservices architectures, providing fast lookups, health monitoring, and dynamic service registration capabilities.

### Basic Service Registration

Services register themselves with Redis using hash structures to store service metadata.

**Key points:**

- Services register with unique identifiers
- Include health status, endpoints, and metadata
- Use TTL for automatic cleanup of dead services
- Support multiple instances of same service

**Example:**

```redis
# Service registration
HMSET service:user-service:instance-1 
  host "192.168.1.100" 
  port 8080 
  status "healthy" 
  version "1.2.3" 
  last_heartbeat 1640995200

# Set TTL for automatic cleanup
EXPIRE service:user-service:instance-1 60

# Service index for quick lookup
SADD services:user-service "instance-1"
SADD services:active "user-service"
```

### Health Check Integration

Implement health monitoring through periodic heartbeats and status updates.

**Example:**

```python
import redis
import time
import json

class ServiceRegistry:
    def __init__(self, redis_client, service_name, instance_id):
        self.redis = redis_client
        self.service_name = service_name
        self.instance_id = instance_id
        self.service_key = f"service:{service_name}:{instance_id}"
        
    def register(self, host, port, metadata=None):
        service_data = {
            "host": host,
            "port": port,
            "status": "healthy",
            "registered_at": time.time(),
            "metadata": json.dumps(metadata or {})
        }
        
        # Register service
        self.redis.hmset(self.service_key, service_data)
        self.redis.expire(self.service_key, 60)
        
        # Add to service index
        self.redis.sadd(f"services:{self.service_name}", self.instance_id)
        
    def heartbeat(self):
        self.redis.hset(self.service_key, "last_heartbeat", time.time())
        self.redis.expire(self.service_key, 60)
        
    def deregister(self):
        self.redis.delete(self.service_key)
        self.redis.srem(f"services:{self.service_name}", self.instance_id)
```

### Service Discovery Implementation

Implement service lookup with load balancing and health filtering.

**Example:**

```python
import random
from typing import List, Dict, Optional

class ServiceDiscovery:
    def __init__(self, redis_client):
        self.redis = redis_client
        
    def discover_service(self, service_name: str) -> Optional[Dict]:
        instances = self.redis.smembers(f"services:{service_name}")
        healthy_instances = []
        
        for instance_id in instances:
            instance_key = f"service:{service_name}:{instance_id.decode()}"
            instance_data = self.redis.hgetall(instance_key)
            
            if instance_data and instance_data.get(b'status') == b'healthy':
                healthy_instances.append({
                    'instance_id': instance_id.decode(),
                    'host': instance_data[b'host'].decode(),
                    'port': int(instance_data[b'port']),
                    'metadata': json.loads(instance_data.get(b'metadata', b'{}'))
                })
        
        return random.choice(healthy_instances) if healthy_instances else None
    
    def discover_all_instances(self, service_name: str) -> List[Dict]:
        instances = self.redis.smembers(f"services:{service_name}")
        all_instances = []
        
        for instance_id in instances:
            instance_key = f"service:{service_name}:{instance_id.decode()}"
            instance_data = self.redis.hgetall(instance_key)
            
            if instance_data:
                all_instances.append({
                    'instance_id': instance_id.decode(),
                    'host': instance_data[b'host'].decode(),
                    'port': int(instance_data[b'port']),
                    'status': instance_data[b'status'].decode(),
                    'last_heartbeat': float(instance_data.get(b'last_heartbeat', 0))
                })
        
        return all_instances
```

### Load Balancing Strategies

### Round Robin Load Balancing

**Example:**

```python
class RoundRobinBalancer:
    def __init__(self, redis_client):
        self.redis = redis_client
        
    def get_next_instance(self, service_name: str) -> Optional[Dict]:
        instances_key = f"services:{service_name}"
        
        # Get current position
        current_pos = self.redis.get(f"lb:rr:{service_name}") or 0
        current_pos = int(current_pos)
        
        # Get all instances
        instances = list(self.redis.smembers(instances_key))
        if not instances:
            return None
            
        # Select next instance
        next_pos = (current_pos + 1) % len(instances)
        selected_instance = instances[next_pos]
        
        # Update position
        self.redis.set(f"lb:rr:{service_name}", next_pos)
        
        # Return instance details
        instance_key = f"service:{service_name}:{selected_instance.decode()}"
        return self._get_instance_details(instance_key)
```

### Weighted Load Balancing

**Example:**

```redis
# Store instance weights
HSET weights:user-service instance-1 100
HSET weights:user-service instance-2 50
HSET weights:user-service instance-3 200

# Weighted selection algorithm
HGETALL weights:user-service
```

### Service Mesh Integration

Integrate with service mesh solutions for advanced traffic management.

**Example:**

```python
class ServiceMeshIntegration:
    def __init__(self, redis_client):
        self.redis = redis_client
        
    def register_with_mesh(self, service_name: str, mesh_config: Dict):
        # Store mesh configuration
        mesh_key = f"mesh:config:{service_name}"
        self.redis.hmset(mesh_key, mesh_config)
        
        # Register routing rules
        if 'routing_rules' in mesh_config:
            rules_key = f"mesh:routing:{service_name}"
            self.redis.set(rules_key, json.dumps(mesh_config['routing_rules']))
            
    def get_routing_config(self, service_name: str) -> Dict:
        mesh_key = f"mesh:config:{service_name}"
        return self.redis.hgetall(mesh_key)
```

### Distributed Locking Patterns

### Basic Distributed Lock

Implement a simple distributed lock using Redis SET with NX and EX options.

**Example:**

```python
import time
import uuid
from typing import Optional

class DistributedLock:
    def __init__(self, redis_client, lock_name: str, timeout: int = 10):
        self.redis = redis_client
        self.lock_name = f"lock:{lock_name}"
        self.timeout = timeout
        self.identifier = str(uuid.uuid4())
        
    def acquire(self, blocking: bool = True, timeout: Optional[int] = None) -> bool:
        end_time = time.time() + (timeout or self.timeout)
        
        while time.time() < end_time:
            # Try to acquire lock
            if self.redis.set(self.lock_name, self.identifier, nx=True, ex=self.timeout):
                return True
                
            if not blocking:
                return False
                
            time.sleep(0.001)  # Small delay before retry
            
        return False
        
    def release(self) -> bool:
        # Use Lua script for atomic release
        lua_script = """
        if redis.call('get', KEYS[1]) == ARGV[1] then
            return redis.call('del', KEYS[1])
        else
            return 0
        end
        """
        
        result = self.redis.eval(lua_script, 1, self.lock_name, self.identifier)
        return result == 1
        
    def __enter__(self):
        if not self.acquire():
            raise Exception(f"Could not acquire lock: {self.lock_name}")
        return self
        
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.release()
```

### Redlock Algorithm

Implement the Redlock algorithm for distributed locking across multiple Redis instances.

**Example:**

```python
import time
import threading
from typing import List

class Redlock:
    def __init__(self, redis_instances: List, lock_name: str, ttl: int = 10000):
        self.redis_instances = redis_instances
        self.lock_name = lock_name
        self.ttl = ttl  # TTL in milliseconds
        self.identifier = str(uuid.uuid4())
        self.quorum = len(redis_instances) // 2 + 1
        
    def acquire(self) -> bool:
        start_time = time.time() * 1000  # Convert to milliseconds
        
        # Try to acquire lock on all instances
        acquired_instances = []
        for i, redis_instance in enumerate(self.redis_instances):
            try:
                if redis_instance.set(self.lock_name, self.identifier, 
                                    nx=True, px=self.ttl):
                    acquired_instances.append(i)
            except Exception:
                continue
                
        # Check if we have quorum
        elapsed_time = time.time() * 1000 - start_time
        if len(acquired_instances) >= self.quorum and elapsed_time < self.ttl:
            return True
        else:
            # Release acquired locks
            self._release_locks(acquired_instances)
            return False
            
    def release(self):
        self._release_locks(range(len(self.redis_instances)))
        
    def _release_locks(self, instance_indices: List[int]):
        lua_script = """
        if redis.call('get', KEYS[1]) == ARGV[1] then
            return redis.call('del', KEYS[1])
        else
            return 0
        end
        """
        
        for i in instance_indices:
            try:
                self.redis_instances[i].eval(lua_script, 1, 
                                           self.lock_name, self.identifier)
            except Exception:
                continue
```

### Lock with Renewal

Implement automatic lock renewal for long-running operations.

**Example:**

```python
class RenewableLock:
    def __init__(self, redis_client, lock_name: str, ttl: int = 30):
        self.redis = redis_client
        self.lock_name = f"lock:{lock_name}"
        self.ttl = ttl
        self.identifier = str(uuid.uuid4())
        self.renewal_thread = None
        self.stop_renewal = threading.Event()
        
    def acquire(self) -> bool:
        if self.redis.set(self.lock_name, self.identifier, nx=True, ex=self.ttl):
            self._start_renewal()
            return True
        return False
        
    def release(self):
        self._stop_renewal()
        
        lua_script = """
        if redis.call('get', KEYS[1]) == ARGV[1] then
            return redis.call('del', KEYS[1])
        else
            return 0
        end
        """
        
        self.redis.eval(lua_script, 1, self.lock_name, self.identifier)
        
    def _start_renewal(self):
        self.renewal_thread = threading.Thread(target=self._renew_lock)
        self.renewal_thread.daemon = True
        self.renewal_thread.start()
        
    def _renew_lock(self):
        while not self.stop_renewal.is_set():
            try:
                # Renew lock if we still own it
                lua_script = """
                if redis.call('get', KEYS[1]) == ARGV[1] then
                    return redis.call('expire', KEYS[1], ARGV[2])
                else
                    return 0
                end
                """
                
                self.redis.eval(lua_script, 1, self.lock_name, 
                              self.identifier, self.ttl)
                              
            except Exception:
                break
                
            time.sleep(self.ttl / 3)  # Renew at 1/3 of TTL
            
    def _stop_renewal(self):
        if self.renewal_thread:
            self.stop_renewal.set()
            self.renewal_thread.join()
```

### Semaphore Implementation

Implement distributed semaphores for controlling resource access.

**Example:**

```python
class DistributedSemaphore:
    def __init__(self, redis_client, semaphore_name: str, limit: int, timeout: int = 10):
        self.redis = redis_client
        self.semaphore_name = f"semaphore:{semaphore_name}"
        self.limit = limit
        self.timeout = timeout
        self.identifier = str(uuid.uuid4())
        
    def acquire(self, timeout: Optional[int] = None) -> bool:
        timeout = timeout or self.timeout
        end_time = time.time() + timeout
        
        while time.time() < end_time:
            # Clean up expired entries
            self._cleanup_expired()
            
            # Try to acquire semaphore
            current_time = time.time()
            if self.redis.zcard(self.semaphore_name) < self.limit:
                if self.redis.zadd(self.semaphore_name, 
                                 {self.identifier: current_time + self.timeout}):
                    return True
                    
            time.sleep(0.001)
            
        return False
        
    def release(self):
        self.redis.zrem(self.semaphore_name, self.identifier)
        
    def _cleanup_expired(self):
        current_time = time.time()
        self.redis.zremrangebyscore(self.semaphore_name, 0, current_time)
```

### Circuit Breaker Implementations

### Basic Circuit Breaker

Implement a circuit breaker pattern using Redis counters and states.

**Example:**

```python
from enum import Enum
import time

class CircuitState(Enum):
    CLOSED = "closed"
    OPEN = "open"
    HALF_OPEN = "half_open"

class CircuitBreaker:
    def __init__(self, redis_client, service_name: str, 
                 failure_threshold: int = 5, timeout: int = 60):
        self.redis = redis_client
        self.service_name = service_name
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.state_key = f"circuit:{service_name}:state"
        self.failure_count_key = f"circuit:{service_name}:failures"
        self.last_failure_key = f"circuit:{service_name}:last_failure"
        
    def call(self, func, *args, **kwargs):
        state = self.get_state()
        
        if state == CircuitState.OPEN:
            if self._should_attempt_reset():
                self._set_state(CircuitState.HALF_OPEN)
            else:
                raise Exception("Circuit breaker is OPEN")
                
        try:
            result = func(*args, **kwargs)
            self._on_success()
            return result
        except Exception as e:
            self._on_failure()
            raise e
            
    def get_state(self) -> CircuitState:
        state = self.redis.get(self.state_key)
        if state:
            return CircuitState(state.decode())
        return CircuitState.CLOSED
        
    def _set_state(self, state: CircuitState):
        self.redis.set(self.state_key, state.value)
        
    def _on_success(self):
        current_state = self.get_state()
        if current_state == CircuitState.HALF_OPEN:
            self._set_state(CircuitState.CLOSED)
            self.redis.delete(self.failure_count_key)
            
    def _on_failure(self):
        current_state = self.get_state()
        
        # Increment failure count
        failure_count = self.redis.incr(self.failure_count_key)
        self.redis.set(self.last_failure_key, int(time.time()))
        
        if current_state == CircuitState.HALF_OPEN:
            self._set_state(CircuitState.OPEN)
        elif failure_count >= self.failure_threshold:
            self._set_state(CircuitState.OPEN)
            
    def _should_attempt_reset(self) -> bool:
        last_failure = self.redis.get(self.last_failure_key)
        if last_failure:
            return time.time() - int(last_failure) > self.timeout
        return False
```

### Advanced Circuit Breaker with Metrics

Implement circuit breaker with detailed metrics and sliding window.

**Example:**

```python
class MetricsCircuitBreaker:
    def __init__(self, redis_client, service_name: str,
                 failure_threshold: float = 0.5, min_requests: int = 10,
                 window_size: int = 60, timeout: int = 60):
        self.redis = redis_client
        self.service_name = service_name
        self.failure_threshold = failure_threshold
        self.min_requests = min_requests
        self.window_size = window_size
        self.timeout = timeout
        
    def call(self, func, *args, **kwargs):
        if not self._can_execute():
            raise Exception("Circuit breaker is OPEN")
            
        start_time = time.time()
        try:
            result = func(*args, **kwargs)
            self._record_success(time.time() - start_time)
            return result
        except Exception as e:
            self._record_failure(time.time() - start_time)
            raise e
            
    def _can_execute(self) -> bool:
        state = self._get_current_state()
        
        if state == CircuitState.CLOSED:
            return True
        elif state == CircuitState.OPEN:
            return self._should_attempt_reset()
        else:  # HALF_OPEN
            return True
            
    def _record_success(self, duration: float):
        current_time = int(time.time())
        
        # Record success in sliding window
        pipe = self.redis.pipeline()
        pipe.zadd(f"circuit:{self.service_name}:requests", 
                 {f"success:{current_time}:{uuid.uuid4()}": current_time})
        pipe.zadd(f"circuit:{self.service_name}:response_times", 
                 {f"{current_time}:{uuid.uuid4()}": duration})
        pipe.execute()
        
        # Clean old entries
        self._cleanup_old_entries()
        
        # Update state if needed
        if self._get_current_state() == CircuitState.HALF_OPEN:
            self._set_state(CircuitState.CLOSED)
            
    def _record_failure(self, duration: float):
        current_time = int(time.time())
        
        # Record failure in sliding window
        pipe = self.redis.pipeline()
        pipe.zadd(f"circuit:{self.service_name}:requests", 
                 {f"failure:{current_time}:{uuid.uuid4()}": current_time})
        pipe.zadd(f"circuit:{self.service_name}:response_times", 
                 {f"{current_time}:{uuid.uuid4()}": duration})
        pipe.execute()
        
        # Clean old entries
        self._cleanup_old_entries()
        
        # Check if circuit should open
        if self._should_open_circuit():
            self._set_state(CircuitState.OPEN)
            self.redis.set(f"circuit:{self.service_name}:last_failure", 
                          int(time.time()))
            
    def _should_open_circuit(self) -> bool:
        current_time = int(time.time())
        window_start = current_time - self.window_size
        
        # Get request counts in window
        total_requests = self.redis.zcount(
            f"circuit:{self.service_name}:requests", 
            window_start, current_time
        )
        
        if total_requests < self.min_requests:
            return False
            
        # Get failure count
        failure_count = 0
        requests = self.redis.zrangebyscore(
            f"circuit:{self.service_name}:requests",
            window_start, current_time
        )
        
        for request in requests:
            if request.decode().startswith('failure:'):
                failure_count += 1
                
        failure_rate = failure_count / total_requests
        return failure_rate >= self.failure_threshold
        
    def get_metrics(self) -> Dict:
        current_time = int(time.time())
        window_start = current_time - self.window_size
        
        requests = self.redis.zrangebyscore(
            f"circuit:{self.service_name}:requests",
            window_start, current_time
        )
        
        total_requests = len(requests)
        failure_count = sum(1 for req in requests 
                          if req.decode().startswith('failure:'))
        success_count = total_requests - failure_count
        
        return {
            'state': self._get_current_state().value,
            'total_requests': total_requests,
            'success_count': success_count,
            'failure_count': failure_count,
            'failure_rate': failure_count / total_requests if total_requests > 0 else 0,
            'window_size': self.window_size
        }
```

### Event-Driven Architecture

### Event Publishing

Implement event publishing with guaranteed delivery and event sourcing.

**Example:**

```python
import json
import uuid
from datetime import datetime
from typing import Dict, Any

class EventPublisher:
    def __init__(self, redis_client):
        self.redis = redis_client
        
    def publish_event(self, event_type: str, aggregate_id: str, 
                     data: Dict[Any, Any], version: int = 1):
        event_id = str(uuid.uuid4())
        event = {
            'id': event_id,
            'type': event_type,
            'aggregate_id': aggregate_id,
            'data': data,
            'version': version,
            'timestamp': datetime.utcnow().isoformat(),
            'published': False
        }
        
        # Store event in stream
        stream_key = f"events:{aggregate_id}"
        self.redis.xadd(stream_key, {
            'event': json.dumps(event)
        })
        
        # Publish notification
        self.redis.publish(f"events:{event_type}", json.dumps(event))
        
        # Add to global event log
        self.redis.zadd("events:global", {event_id: time.time()})
        
        return event_id
        
    def get_events(self, aggregate_id: str, from_version: int = 0) -> List[Dict]:
        stream_key = f"events:{aggregate_id}"
        events = self.redis.xrange(stream_key)
        
        result = []
        for event_id, fields in events:
            event_data = json.loads(fields[b'event'])
            if event_data['version'] >= from_version:
                result.append(event_data)
                
        return result
```

### Event Handlers and Processors

Implement event handlers with competing consumers pattern.

**Example:**

```python
class EventProcessor:
    def __init__(self, redis_client, consumer_group: str, consumer_name: str):
        self.redis = redis_client
        self.consumer_group = consumer_group
        self.consumer_name = consumer_name
        self.handlers = {}
        
    def register_handler(self, event_type: str, handler_func):
        self.handlers[event_type] = handler_func
        
    def start_processing(self, stream_keys: List[str]):
        # Create consumer group if it doesn't exist
        for stream_key in stream_keys:
            try:
                self.redis.xgroup_create(stream_key, self.consumer_group, 
                                       id='0', mkstream=True)
            except Exception:
                pass  # Group already exists
                
        while True:
            try:
                # Read from streams
                messages = self.redis.xreadgroup(
                    self.consumer_group, 
                    self.consumer_name,
                    {stream: '>' for stream in stream_keys},
                    count=1,
                    block=1000
                )
                
                for stream, msgs in messages:
                    for msg_id, fields in msgs:
                        self._process_message(stream.decode(), msg_id, fields)
                        
            except Exception as e:
                print(f"Error processing events: {e}")
                time.sleep(1)
                
    def _process_message(self, stream: str, msg_id: bytes, fields: Dict):
        try:
            event_data = json.loads(fields[b'event'])
            event_type = event_data['type']
            
            if event_type in self.handlers:
                # Process event
                self.handlers[event_type](event_data)
                
                # Acknowledge message
                self.redis.xack(stream, self.consumer_group, msg_id)
                
                # Update processing metrics
                self._update_metrics(event_type, 'success')
            else:
                # Unknown event type - acknowledge to prevent reprocessing
                self.redis.xack(stream, self.consumer_group, msg_id)
                
        except Exception as e:
            print(f"Error processing message {msg_id}: {e}")
            self._update_metrics(event_data.get('type', 'unknown'), 'failure')
            
    def _update_metrics(self, event_type: str, status: str):
        current_time = int(time.time())
        metrics_key = f"metrics:events:{event_type}:{status}"
        
        # Increment counter
        self.redis.incr(metrics_key)
        
        # Add to time series
        self.redis.zadd(f"metrics:timeline:{event_type}:{status}", 
                       {current_time: current_time})
```

### Saga Pattern Implementation

Implement distributed transaction management using the saga pattern.

**Example:**

```python
class SagaOrchestrator:
    def __init__(self, redis_client):
        self.redis = redis_client
        
    def start_saga(self, saga_id: str, steps: List[Dict]) -> str:
        saga_data = {
            'id': saga_id,
            'steps': steps,
            'current_step': 0,
            'status': 'running',
            'started_at': time.time(),
            'completed_steps': [],
            'compensations': []
        }
        
        # Store saga state
        saga_key = f"saga:{saga_id}"
        self.redis.set(saga_key, json.dumps(saga_data))
        
        # Start first step
        self._execute_next_step(saga_id)
        
        return saga_id
        
    def handle_step_completion(self, saga_id: str, step_index: int, 
                             success: bool, result: Dict = None):
        saga_key = f"saga:{saga_id}"
        saga_data = json.loads(self.redis.get(saga_key))
        
        if success:
            # Mark step as completed
            saga_data['completed_steps'].append(step_index)
            saga_data['current_step'] = step_index + 1
            
            # Store compensation info if provided
            if result and 'compensation' in result:
                saga_data['compensations'].append({
                    'step_index': step_index,
                    'compensation': result['compensation']
                })
                
            # Check if saga is complete
            if saga_data['current_step'] >= len(saga_data['steps']):
                saga_data['status'] = 'completed'
                saga_data['completed_at'] = time.time()
            else:
                # Execute next step
                self._execute_next_step(saga_id)
                
        else:
            # Start compensation
            saga_data['status'] = 'compensating'
            self._start_compensation(saga_id, saga_data)
            
        # Update saga state
        self.redis.set(saga_key, json.dumps(saga_data))
        
    def _execute_next_step(self, saga_id: str):
        saga_key = f"saga:{saga_id}"
        saga_data = json.loads(self.redis.get(saga_key))
        
        current_step = saga_data['current_step']
        if current_step < len(saga_data['steps']):
            step = saga_data['steps'][current_step]
            
            # Publish step execution event
            step_event = {
                'saga_id': saga_id,
                'step_index': current_step,
                'action': step['action'],
                'data': step['data']
            }
            
            self.redis.publish('saga:step:execute', json.dumps(step_event))
            
    def _start_compensation(self, saga_id: str, saga_data: Dict):
        # Execute compensations in reverse order
        for compensation in reversed(saga_data['compensations']):
            compensation_event = {
                'saga_id': saga_id,
                'step_index': compensation['step_index'],
                'compensation': compensation['compensation']
            }
            
            self.redis.publish('saga:compensation:execute', 
                             json.dumps(compensation_event))
```

### Event Sourcing Implementation

Implement event sourcing with snapshots and projections.

**Example:**

```python
class EventStore:
    def __init__(self, redis_client):
        self.redis = redis_client
        
    def append_events(self, aggregate_id: str, events: List[Dict], 
                     expected_version: int = -1):
        stream_key = f"events:{aggregate_id}"
        
        # Check expected version
        if expected_version != -1:
            current_version = self._get_current_version(aggregate_id)
            if current_version != expected_version:
                raise Exception(f"Concurrency conflict: expected {expected_version}, got {current_version}")
                
        # Append events
        for event in events:
            event['aggregate_id'] = aggregate_id
            event['timestamp'] = time.time()
            
            self.redis.xadd(stream_key, {'event': json.dumps(event)})
            
            # Update version
            self.redis.incr(f"version:{aggregate_id}")
            
    def get_events(self, aggregate_id: str, from_version: int = 0) -> List[Dict]:
        stream_key = f"events:{aggregate_id}"
        events = self.redis.xrange(stream_key)
        
        result = []
        for event_id, fields in events:
            event_data = json.loads(fields[b'event'])
            if event_data.get('version', 0) >= from_version:
                result.append(event_data)
                
        return result
        
    def create_snapshot(self, aggregate_id: str, version: int, data: Dict):
        snapshot_key = f"snapshot:{aggregate_id}:{version}"
        snapshot_data = {
            'aggregate_id': aggregate_id,
            'version': version,
            'data': data,
            'timestamp': time.time()
        }
        
        self.redis.set(snapshot_key, json.dumps(snapshot_data))
        
        # Update latest snapshot pointer
        self.redis.set(f"snapshot:latest:{aggregate_id}", str(version))


def get_snapshot(self, aggregate_id: str, version: int = None) -> Dict:
    if version is None:
        # Get latest snapshot
        latest_version = self.redis.get(f"snapshot:latest:{aggregate_id}")
        if latest_version:
            version = int(latest_version)
        else:
            return None
            
    snapshot_key = f"snapshot:{aggregate_id}:{version}"
    snapshot_data = self.redis.get(snapshot_key)
    
    if snapshot_data:
        return json.loads(snapshot_data)
    return None
    
def _get_current_version(self, aggregate_id: str) -> int:
    version = self.redis.get(f"version:{aggregate_id}")
    return int(version) if version else 0
```

### Projection Management

Implement event projections for read models and query optimization.

**Example:**
```python
class ProjectionManager:
    def __init__(self, redis_client):
        self.redis = redis_client
        self.projections = {}
        
    def register_projection(self, name: str, projection_func):
        self.projections[name] = projection_func
        
    def rebuild_projection(self, name: str, aggregate_ids: List[str] = None):
        if name not in self.projections:
            raise Exception(f"Unknown projection: {name}")
            
        projection_func = self.projections[name]
        
        # Clear existing projection
        projection_key = f"projection:{name}"
        self.redis.delete(projection_key)
        
        # Get all events if no specific aggregates provided
        if aggregate_ids is None:
            aggregate_ids = self._get_all_aggregate_ids()
            
        # Process events for each aggregate
        for aggregate_id in aggregate_ids:
            events = self._get_events_for_aggregate(aggregate_id)
            
            for event in events:
                projection_func(event, self.redis)
                
        # Mark projection as rebuilt
        self.redis.set(f"projection:{name}:last_rebuild", time.time())
        
    def update_projection(self, name: str, event: Dict):
        if name in self.projections:
            self.projections[name](event, self.redis)
            
    def _get_all_aggregate_ids(self) -> List[str]:
        # Get all event streams
        keys = self.redis.keys("events:*")
        aggregate_ids = []
        
        for key in keys:
            key_str = key.decode()
            if key_str.startswith("events:"):
                aggregate_id = key_str[7:]  # Remove "events:" prefix
                aggregate_ids.append(aggregate_id)
                
        return aggregate_ids
        
    def _get_events_for_aggregate(self, aggregate_id: str) -> List[Dict]:
        stream_key = f"events:{aggregate_id}"
        events = self.redis.xrange(stream_key)
        
        result = []
        for event_id, fields in events:
            event_data = json.loads(fields[b'event'])
            result.append(event_data)
            
        return result
````

### Message Deduplication

Implement message deduplication to ensure exactly-once processing.

**Example:**

```python
class MessageDeduplicator:
    def __init__(self, redis_client, ttl: int = 3600):
        self.redis = redis_client
        self.ttl = ttl
        
    def is_duplicate(self, message_id: str, handler_name: str) -> bool:
        dedup_key = f"dedup:{handler_name}:{message_id}"
        return self.redis.exists(dedup_key)
        
    def mark_processed(self, message_id: str, handler_name: str):
        dedup_key = f"dedup:{handler_name}:{message_id}"
        self.redis.setex(dedup_key, self.ttl, "processed")
        
    def process_with_deduplication(self, message_id: str, handler_name: str, 
                                 handler_func, *args, **kwargs):
        if self.is_duplicate(message_id, handler_name):
            return None  # Already processed
            
        try:
            result = handler_func(*args, **kwargs)
            self.mark_processed(message_id, handler_name)
            return result
        except Exception as e:
            # Don't mark as processed if handler fails
            raise e
```

### Dead Letter Queue

Implement dead letter queue for failed message processing.

**Example:**

```python
class DeadLetterQueue:
    def __init__(self, redis_client):
        self.redis = redis_client
        
    def send_to_dlq(self, original_stream: str, message_id: str, 
                   message_data: Dict, error: str, retry_count: int = 0):
        dlq_entry = {
            'original_stream': original_stream,
            'original_message_id': message_id,
            'message_data': json.dumps(message_data),
            'error': error,
            'retry_count': retry_count,
            'timestamp': time.time()
        }
        
        # Add to dead letter queue
        dlq_key = f"dlq:{original_stream}"
        self.redis.xadd(dlq_key, dlq_entry)
        
        # Update metrics
        self.redis.incr(f"dlq:count:{original_stream}")
        
    def get_dlq_messages(self, stream: str, count: int = 10) -> List[Dict]:
        dlq_key = f"dlq:{stream}"
        messages = self.redis.xrange(dlq_key, count=count)
        
        result = []
        for msg_id, fields in messages:
            entry = {
                'dlq_message_id': msg_id,
                'original_stream': fields[b'original_stream'].decode(),
                'original_message_id': fields[b'original_message_id'].decode(),
                'message_data': json.loads(fields[b'message_data']),
                'error': fields[b'error'].decode(),
                'retry_count': int(fields[b'retry_count']),
                'timestamp': float(fields[b'timestamp'])
            }
            result.append(entry)
            
        return result
        
    def retry_dlq_message(self, stream: str, dlq_message_id: str, 
                         max_retries: int = 3):
        dlq_key = f"dlq:{stream}"
        
        # Get message from DLQ
        messages = self.redis.xrange(dlq_key, min=dlq_message_id, 
                                   max=dlq_message_id)
        
        if not messages:
            return False
            
        msg_id, fields = messages[0]
        retry_count = int(fields[b'retry_count'])
        
        if retry_count >= max_retries:
            return False
            
        # Requeue message to original stream
        original_stream = fields[b'original_stream'].decode()
        message_data = json.loads(fields[b'message_data'])
        
        self.redis.xadd(original_stream, message_data)
        
        # Update retry count in DLQ
        updated_entry = {
            'original_stream': original_stream,
            'original_message_id': fields[b'original_message_id'].decode(),
            'message_data': fields[b'message_data'].decode(),
            'error': fields[b'error'].decode(),
            'retry_count': retry_count + 1,
            'timestamp': time.time()
        }
        
        # Remove old entry and add updated one
        self.redis.xdel(dlq_key, msg_id)
        self.redis.xadd(dlq_key, updated_entry)
        
        return True
```

### Monitoring and Metrics

### Service Health Monitoring

Implement comprehensive health monitoring for microservices.

**Example:**

```python
class ServiceHealthMonitor:
    def __init__(self, redis_client):
        self.redis = redis_client
        
    def record_health_check(self, service_name: str, instance_id: str, 
                          status: str, metrics: Dict = None):
        health_data = {
            'status': status,
            'timestamp': time.time(),
            'metrics': json.dumps(metrics or {})
        }
        
        # Store current health
        health_key = f"health:{service_name}:{instance_id}"
        self.redis.hmset(health_key, health_data)
        self.redis.expire(health_key, 300)  # 5 minutes TTL
        
        # Add to health history
        history_key = f"health:history:{service_name}:{instance_id}"
        self.redis.zadd(history_key, {json.dumps(health_data): time.time()})
        
        # Keep only last 100 health checks
        self.redis.zremrangebyrank(history_key, 0, -101)
        
    def get_service_health(self, service_name: str) -> Dict:
        instances = self.redis.smembers(f"services:{service_name}")
        health_status = {}
        
        for instance_id in instances:
            instance_id = instance_id.decode()
            health_key = f"health:{service_name}:{instance_id}"
            health_data = self.redis.hgetall(health_key)
            
            if health_data:
                health_status[instance_id] = {
                    'status': health_data[b'status'].decode(),
                    'timestamp': float(health_data[b'timestamp']),
                    'metrics': json.loads(health_data[b'metrics'])
                }
            else:
                health_status[instance_id] = {
                    'status': 'unknown',
                    'timestamp': 0,
                    'metrics': {}
                }
                
        return health_status
        
    def get_health_metrics(self, service_name: str, time_window: int = 3600) -> Dict:
        current_time = time.time()
        start_time = current_time - time_window
        
        instances = self.redis.smembers(f"services:{service_name}")
        metrics = {
            'total_instances': len(instances),
            'healthy_instances': 0,
            'unhealthy_instances': 0,
            'unknown_instances': 0
        }
        
        for instance_id in instances:
            instance_id = instance_id.decode()
            health_key = f"health:{service_name}:{instance_id}"
            health_data = self.redis.hgetall(health_key)
            
            if health_data:
                status = health_data[b'status'].decode()
                timestamp = float(health_data[b'timestamp'])
                
                if timestamp >= start_time:
                    if status == 'healthy':
                        metrics['healthy_instances'] += 1
                    else:
                        metrics['unhealthy_instances'] += 1
                else:
                    metrics['unknown_instances'] += 1
            else:
                metrics['unknown_instances'] += 1
                
        return metrics
```

### Performance Monitoring

Track performance metrics across microservices.

**Example:**

```python
class PerformanceMonitor:
    def __init__(self, redis_client):
        self.redis = redis_client
        
    def record_request_metrics(self, service_name: str, endpoint: str,
                             duration: float, status_code: int,
                             request_size: int = 0, response_size: int = 0):
        current_time = int(time.time())
        
        # Record response time
        response_time_key = f"metrics:{service_name}:{endpoint}:response_time"
        self.redis.zadd(response_time_key, {f"{current_time}:{uuid.uuid4()}": duration})
        
        # Record status code
        status_key = f"metrics:{service_name}:{endpoint}:status:{status_code}"
        self.redis.incr(status_key)
        
        # Record request/response sizes
        if request_size > 0:
            req_size_key = f"metrics:{service_name}:{endpoint}:request_size"
            self.redis.zadd(req_size_key, {f"{current_time}:{uuid.uuid4()}": request_size})
            
        if response_size > 0:
            resp_size_key = f"metrics:{service_name}:{endpoint}:response_size"
            self.redis.zadd(resp_size_key, {f"{current_time}:{uuid.uuid4()}": response_size})
            
        # Clean up old metrics (keep last hour)
        self._cleanup_old_metrics(service_name, endpoint, current_time - 3600)
        
    def get_performance_metrics(self, service_name: str, endpoint: str,
                              time_window: int = 3600) -> Dict:
        current_time = int(time.time())
        start_time = current_time - time_window
        
        # Get response times
        response_time_key = f"metrics:{service_name}:{endpoint}:response_time"
        response_times = self.redis.zrangebyscore(response_time_key, start_time, current_time)
        
        times = [float(rt.decode().split(':')[0]) for rt in response_times]
        
        # Calculate statistics
        if times:
            avg_response_time = sum(times) / len(times)
            min_response_time = min(times)
            max_response_time = max(times)
            
            # Calculate percentiles
            sorted_times = sorted(times)
            p95_index = int(len(sorted_times) * 0.95)
            p99_index = int(len(sorted_times) * 0.99)
            
            p95_response_time = sorted_times[p95_index] if p95_index < len(sorted_times) else max_response_time
            p99_response_time = sorted_times[p99_index] if p99_index < len(sorted_times) else max_response_time
        else:
            avg_response_time = min_response_time = max_response_time = 0
            p95_response_time = p99_response_time = 0
            
        # Get status code counts
        status_codes = {}
        status_keys = self.redis.keys(f"metrics:{service_name}:{endpoint}:status:*")
        
        for key in status_keys:
            key_str = key.decode()
            status_code = key_str.split(':')[-1]
            count = int(self.redis.get(key) or 0)
            status_codes[status_code] = count
            
        return {
            'request_count': len(times),
            'avg_response_time': avg_response_time,
            'min_response_time': min_response_time,
            'max_response_time': max_response_time,
            'p95_response_time': p95_response_time,
            'p99_response_time': p99_response_time,
            'status_codes': status_codes,
            'time_window': time_window
        }
        
    def _cleanup_old_metrics(self, service_name: str, endpoint: str, cutoff_time: int):
        # Clean up response times
        response_time_key = f"metrics:{service_name}:{endpoint}:response_time"
        self.redis.zremrangebyscore(response_time_key, 0, cutoff_time)
        
        # Clean up request/response sizes
        req_size_key = f"metrics:{service_name}:{endpoint}:request_size"
        resp_size_key = f"metrics:{service_name}:{endpoint}:response_size"
        
        self.redis.zremrangebyscore(req_size_key, 0, cutoff_time)
        self.redis.zremrangebyscore(resp_size_key, 0, cutoff_time)
```

### Configuration Management

Implement distributed configuration management with change notifications.

**Example:**

```python
class ConfigurationManager:
    def __init__(self, redis_client):
        self.redis = redis_client
        
    def set_config(self, service_name: str, key: str, value: Any, 
                  environment: str = "production"):
        config_key = f"config:{environment}:{service_name}:{key}"
        old_value = self.redis.get(config_key)
        
        # Store new value
        self.redis.set(config_key, json.dumps(value))
        
        # Record change history
        change_record = {
            'key': key,
            'old_value': old_value.decode() if old_value else None,
            'new_value': json.dumps(value),
            'timestamp': time.time(),
            'environment': environment
        }
        
        history_key = f"config:history:{service_name}"
        self.redis.zadd(history_key, {json.dumps(change_record): time.time()})
        
        # Notify subscribers of config change
        notification = {
            'service': service_name,
            'key': key,
            'value': value,
            'environment': environment,
            'timestamp': time.time()
        }
        
        self.redis.publish(f"config:changes:{service_name}", json.dumps(notification))
        
    def get_config(self, service_name: str, key: str, 
                  environment: str = "production", default: Any = None) -> Any:
        config_key = f"config:{environment}:{service_name}:{key}"
        value = self.redis.get(config_key)
        
        if value:
            return json.loads(value)
        return default
        
    def get_all_config(self, service_name: str, 
                      environment: str = "production") -> Dict:
        pattern = f"config:{environment}:{service_name}:*"
        keys = self.redis.keys(pattern)
        
        config = {}
        for key in keys:
            key_str = key.decode()
            config_key = key_str.split(':')[-1]
            value = self.redis.get(key)
            
            if value:
                config[config_key] = json.loads(value)
                
        return config
        
    def subscribe_to_changes(self, service_name: str, callback_func):
        pubsub = self.redis.pubsub()
        pubsub.subscribe(f"config:changes:{service_name}")
        
        for message in pubsub.listen():
            if message['type'] == 'message':
                change_data = json.loads(message['data'])
                callback_func(change_data)
```

**Conclusion:** Redis provides a robust foundation for microservices architecture, offering solutions for service discovery, distributed locking, circuit breakers, and event-driven communication. The key to successful implementation lies in understanding the trade-offs between consistency, availability, and partition tolerance, and choosing the appropriate patterns based on specific use cases. Proper monitoring, error handling, and graceful degradation are essential for building resilient microservices systems with Redis.

**Related topics:** Redis Cluster configuration for high availability, Redis Sentinel for automatic failover, integration with API gateways, observability and tracing in distributed systems, and container orchestration with Kubernetes.

---


## Operational Considerations


### Logging and Audit Trails

#### Redis Logging Configuration

Redis provides multiple logging levels and output options that are essential for operational monitoring and debugging.

**Log Level Configuration:**

```
# redis.conf logging settings
loglevel notice
logfile /var/log/redis/redis-server.log
syslog-enabled yes
syslog-ident redis
syslog-facility local0
```

**Structured Logging Implementation:**

```python
import json
import time
import logging
from datetime import datetime

class RedisAuditLogger:
    def __init__(self, redis_client, log_level=logging.INFO):
        self.redis = redis_client
        self.logger = logging.getLogger('redis_audit')
        self.logger.setLevel(log_level)
        
        # Create structured log formatter
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        
        handler = logging.FileHandler('/var/log/redis/audit.log')
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
    
    def log_command(self, command, args, user_id=None, result=None, error=None):
        audit_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'command': command,
            'args': args,
            'user_id': user_id,
            'result_type': type(result).__name__ if result else None,
            'error': str(error) if error else None,
            'execution_time': time.time()
        }
        
        # Store in Redis for real-time monitoring
        self.redis.lpush('audit_log', json.dumps(audit_entry))
        self.redis.ltrim('audit_log', 0, 9999)  # Keep last 10k entries
        
        # Log to file
        self.logger.info(json.dumps(audit_entry))
```

#### Command Monitoring and Slowlog

**Slowlog Analysis:**

```python
def analyze_slowlog(redis_client, threshold_ms=100):
    slowlog = redis_client.slowlog_get(100)
    
    analysis = {
        'total_slow_commands': len(slowlog),
        'commands_by_type': {},
        'slowest_commands': [],
        'time_distribution': {}
    }
    
    for entry in slowlog:
        command = entry['command'][0].decode('utf-8')
        duration = entry['duration']
        
        # Count by command type
        analysis['commands_by_type'][command] = \
            analysis['commands_by_type'].get(command, 0) + 1
        
        # Track slowest commands
        analysis['slowest_commands'].append({
            'command': ' '.join([c.decode('utf-8') for c in entry['command']]),
            'duration_ms': duration / 1000,
            'timestamp': entry['start_time']
        })
    
    # Sort by duration
    analysis['slowest_commands'].sort(key=lambda x: x['duration_ms'], reverse=True)
    
    return analysis
```

**Real-time Command Monitoring:**

```python
import threading
import time

class RedisCommandMonitor:
    def __init__(self, redis_client):
        self.redis = redis_client
        self.monitoring = False
        self.stats = {
            'commands_per_second': 0,
            'memory_usage': 0,
            'connected_clients': 0,
            'keyspace_hits': 0,
            'keyspace_misses': 0
        }
    
    def start_monitoring(self):
        self.monitoring = True
        monitor_thread = threading.Thread(target=self._monitor_loop)
        monitor_thread.daemon = True
        monitor_thread.start()
    
    def _monitor_loop(self):
        last_commands = 0
        
        while self.monitoring:
            info = self.redis.info()
            
            # Calculate commands per second
            current_commands = info['total_commands_processed']
            self.stats['commands_per_second'] = current_commands - last_commands
            last_commands = current_commands
            
            # Update other stats
            self.stats['memory_usage'] = info['used_memory']
            self.stats['connected_clients'] = info['connected_clients']
            self.stats['keyspace_hits'] = info['keyspace_hits']
            self.stats['keyspace_misses'] = info['keyspace_misses']
            
            # Log critical thresholds
            if self.stats['commands_per_second'] > 10000:
                self._log_alert('HIGH_COMMAND_RATE', self.stats['commands_per_second'])
            
            time.sleep(1)
    
    def _log_alert(self, alert_type, value):
        alert = {
            'timestamp': datetime.utcnow().isoformat(),
            'type': alert_type,
            'value': value,
            'severity': 'WARNING'
        }
        self.redis.lpush('alerts', json.dumps(alert))
```

#### Application-Level Audit Trails

**Comprehensive Audit System:**

```python
import functools
import inspect

def audit_redis_operation(operation_type='unknown'):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            # Extract context information
            frame = inspect.currentframe().f_back
            caller_info = {
                'function': frame.f_code.co_name,
                'filename': frame.f_code.co_filename,
                'line_number': frame.f_lineno
            }
            
            start_time = time.time()
            
            try:
                result = func(*args, **kwargs)
                
                # Log successful operation
                audit_entry = {
                    'timestamp': datetime.utcnow().isoformat(),
                    'operation_type': operation_type,
                    'function': func.__name__,
                    'args': str(args)[:200],  # Truncate long args
                    'kwargs': str(kwargs)[:200],
                    'execution_time': time.time() - start_time,
                    'status': 'SUCCESS',
                    'caller': caller_info
                }
                
                # Store audit trail
                redis_client.lpush('operation_audit', json.dumps(audit_entry))
                
                return result
                
            except Exception as e:
                # Log failed operation
                audit_entry = {
                    'timestamp': datetime.utcnow().isoformat(),
                    'operation_type': operation_type,
                    'function': func.__name__,
                    'args': str(args)[:200],
                    'kwargs': str(kwargs)[:200],
                    'execution_time': time.time() - start_time,
                    'status': 'ERROR',
                    'error': str(e),
                    'caller': caller_info
                }
                
                redis_client.lpush('operation_audit', json.dumps(audit_entry))
                raise
        
        return wrapper
    return decorator

# Usage example
@audit_redis_operation('cache_operation')
def get_user_data(user_id):
    return redis_client.hgetall(f'user:{user_id}')
```

### Capacity Planning

#### Memory Usage Analysis

**Memory Profiling and Projection:**

```python
import statistics
from collections import defaultdict

class RedisCapacityAnalyzer:
    def __init__(self, redis_client):
        self.redis = redis_client
        self.memory_samples = []
        self.key_samples = []
    
    def collect_memory_sample(self):
        info = self.redis.info('memory')
        sample = {
            'timestamp': time.time(),
            'used_memory': info['used_memory'],
            'used_memory_rss': info['used_memory_rss'],
            'used_memory_peak': info['used_memory_peak'],
            'total_system_memory': info.get('total_system_memory', 0),
            'memory_fragmentation_ratio': info.get('mem_fragmentation_ratio', 1.0)
        }
        self.memory_samples.append(sample)
        return sample
    
    def analyze_key_distribution(self, sample_size=10000):
        key_stats = defaultdict(list)
        
        # Sample keys using SCAN
        cursor = 0
        sampled_keys = []
        
        while len(sampled_keys) < sample_size:
            cursor, keys = self.redis.scan(cursor, count=1000)
            sampled_keys.extend(keys)
            if cursor == 0:
                break
        
        # Analyze key patterns and memory usage
        for key in sampled_keys[:sample_size]:
            key_str = key.decode('utf-8')
            key_type = self.redis.type(key).decode('utf-8')
            
            # Estimate memory usage
            memory_usage = self.redis.memory_usage(key)
            
            # Extract key pattern
            pattern = self._extract_pattern(key_str)
            
            key_stats[pattern].append({
                'key': key_str,
                'type': key_type,
                'memory': memory_usage,
                'ttl': self.redis.ttl(key)
            })
        
        return dict(key_stats)
    
    def _extract_pattern(self, key):
        # Extract common patterns from keys
        parts = key.split(':')
        if len(parts) >= 2:
            return f"{parts[0]}:{parts[1]}:*"
        return key
    
    def project_memory_growth(self, days_ahead=30):
        if len(self.memory_samples) < 2:
            return None
        
        # Calculate growth rate
        recent_samples = self.memory_samples[-100:]  # Last 100 samples
        times = [s['timestamp'] for s in recent_samples]
        memory_values = [s['used_memory'] for s in recent_samples]
        
        # Simple linear regression
        n = len(times)
        sum_x = sum(times)
        sum_y = sum(memory_values)
        sum_xy = sum(x * y for x, y in zip(times, memory_values))
        sum_x2 = sum(x * x for x in times)
        
        slope = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)
        
        # Project future memory usage
        current_time = time.time()
        future_time = current_time + (days_ahead * 24 * 3600)
        projected_memory = memory_values[-1] + slope * (future_time - times[-1])
        
        return {
            'current_memory_mb': memory_values[-1] / (1024 * 1024),
            'projected_memory_mb': projected_memory / (1024 * 1024),
            'growth_rate_mb_per_day': (slope * 24 * 3600) / (1024 * 1024),
            'projection_days': days_ahead
        }
```

#### Performance Baseline Establishment

**Benchmark Suite:**

```python
import concurrent.futures
import statistics

class RedisPerformanceBenchmark:
    def __init__(self, redis_client):
        self.redis = redis_client
        self.results = {}
    
    def run_read_benchmark(self, num_operations=10000, concurrency=10):
        # Prepare test data
        test_keys = []
        for i in range(num_operations):
            key = f'benchmark:read:{i}'
            self.redis.set(key, f'value_{i}')
            test_keys.append(key)
        
        # Run concurrent reads
        def read_operation(key):
            start = time.time()
            self.redis.get(key)
            return time.time() - start
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as executor:
            futures = [executor.submit(read_operation, key) for key in test_keys]
            execution_times = [f.result() for f in futures]
        
        # Cleanup
        self.redis.delete(*test_keys)
        
        return {
            'operations': num_operations,
            'concurrency': concurrency,
            'avg_latency_ms': statistics.mean(execution_times) * 1000,
            'p95_latency_ms': statistics.quantiles(execution_times, n=20)[18] * 1000,
            'p99_latency_ms': statistics.quantiles(execution_times, n=100)[98] * 1000,
            'ops_per_second': num_operations / sum(execution_times)
        }
    
    def run_write_benchmark(self, num_operations=10000, concurrency=10):
        def write_operation(index):
            start = time.time()
            self.redis.set(f'benchmark:write:{index}', f'value_{index}')
            return time.time() - start
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as executor:
            futures = [executor.submit(write_operation, i) for i in range(num_operations)]
            execution_times = [f.result() for f in futures]
        
        # Cleanup
        keys_to_delete = [f'benchmark:write:{i}' for i in range(num_operations)]
        self.redis.delete(*keys_to_delete)
        
        return {
            'operations': num_operations,
            'concurrency': concurrency,
            'avg_latency_ms': statistics.mean(execution_times) * 1000,
            'p95_latency_ms': statistics.quantiles(execution_times, n=20)[18] * 1000,
            'ops_per_second': num_operations / sum(execution_times)
        }
```

#### Scaling Thresholds and Alerts

**Automated Capacity Monitoring:**

```python
class RedisCapacityMonitor:
    def __init__(self, redis_client, thresholds=None):
        self.redis = redis_client
        self.thresholds = thresholds or {
            'memory_usage_percent': 80,
            'cpu_usage_percent': 80,
            'connections_percent': 90,
            'keyspace_hit_ratio': 0.9,
            'commands_per_second': 10000
        }
        self.alerts = []
    
    def check_capacity_thresholds(self):
        info = self.redis.info()
        alerts = []
        
        # Memory usage check
        if 'total_system_memory' in info and info['total_system_memory'] > 0:
            memory_percent = (info['used_memory'] / info['total_system_memory']) * 100
            if memory_percent > self.thresholds['memory_usage_percent']:
                alerts.append({
                    'type': 'MEMORY_HIGH',
                    'value': memory_percent,
                    'threshold': self.thresholds['memory_usage_percent'],
                    'severity': 'WARNING'
                })
        
        # Connection usage check
        max_clients = info.get('maxclients', 10000)
        connection_percent = (info['connected_clients'] / max_clients) * 100
        if connection_percent > self.thresholds['connections_percent']:
            alerts.append({
                'type': 'CONNECTIONS_HIGH',
                'value': connection_percent,
                'threshold': self.thresholds['connections_percent'],
                'severity': 'WARNING'
            })
        
        # Hit ratio check
        hits = info['keyspace_hits']
        misses = info['keyspace_misses']
        total_requests = hits + misses
        
        if total_requests > 0:
            hit_ratio = hits / total_requests
            if hit_ratio < self.thresholds['keyspace_hit_ratio']:
                alerts.append({
                    'type': 'HIT_RATIO_LOW',
                    'value': hit_ratio,
                    'threshold': self.thresholds['keyspace_hit_ratio'],
                    'severity': 'WARNING'
                })
        
        return alerts
```

### Upgrade Strategies

#### Rolling Upgrade Planning

**Master-Slave Upgrade Process:**

```python
class RedisUpgradeManager:
    def __init__(self, master_config, slave_configs):
        self.master_config = master_config
        self.slave_configs = slave_configs
        self.upgrade_log = []
    
    def plan_rolling_upgrade(self, target_version):
        plan = {
            'target_version': target_version,
            'steps': [],
            'rollback_plan': [],
            'estimated_downtime': 0
        }
        
        # Step 1: Upgrade slaves first
        for i, slave_config in enumerate(self.slave_configs):
            plan['steps'].append({
                'step': f'upgrade_slave_{i}',
                'target': slave_config['host'],
                'estimated_time': 300,  # 5 minutes
                'risk_level': 'low'
            })
        
        # Step 2: Promote a slave to master
        plan['steps'].append({
            'step': 'promote_slave_to_master',
            'target': self.slave_configs[0]['host'],
            'estimated_time': 60,
            'risk_level': 'high'
        })
        
        # Step 3: Upgrade old master
        plan['steps'].append({
            'step': 'upgrade_old_master',
            'target': self.master_config['host'],
            'estimated_time': 300,
            'risk_level': 'medium'
        })
        
        # Step 4: Reconfigure as slave
        plan['steps'].append({
            'step': 'reconfigure_as_slave',
            'target': self.master_config['host'],
            'estimated_time': 60,
            'risk_level': 'low'
        })
        
        return plan
    
    def execute_upgrade_step(self, step):
        start_time = time.time()
        
        try:
            if step['step'].startswith('upgrade_slave'):
                self._upgrade_slave(step['target'])
            elif step['step'] == 'promote_slave_to_master':
                self._promote_slave_to_master(step['target'])
            elif step['step'] == 'upgrade_old_master':
                self._upgrade_master(step['target'])
            elif step['step'] == 'reconfigure_as_slave':
                self._reconfigure_as_slave(step['target'])
            
            execution_time = time.time() - start_time
            
            self.upgrade_log.append({
                'step': step['step'],
                'target': step['target'],
                'status': 'SUCCESS',
                'execution_time': execution_time,
                'timestamp': datetime.utcnow().isoformat()
            })
            
        except Exception as e:
            self.upgrade_log.append({
                'step': step['step'],
                'target': step['target'],
                'status': 'FAILED',
                'error': str(e),
                'timestamp': datetime.utcnow().isoformat()
            })
            raise
    
    def _upgrade_slave(self, target_host):
        # Implementation for upgrading a slave
        # 1. Stop Redis on slave
        # 2. Backup data
        # 3. Install new version
        # 4. Start Redis
        # 5. Verify replication
        pass
    
    def _promote_slave_to_master(self, target_host):
        # Implementation for promoting slave to master
        # 1. Stop replication on slave
        # 2. Update application configuration
        # 3. Verify new master is accepting writes
        pass
```

#### Configuration Migration

**Automated Config Migration:**

```python
import re

class RedisConfigMigrator:
    def __init__(self):
        self.migration_rules = {
            '6.0': {
                'deprecated': ['tcp-keepalive'],
                'renamed': {
                    'slave-read-only': 'replica-read-only',
                    'slaveof': 'replicaof'
                },
                'new_features': ['acl-log-max-len', 'io-threads']
            },
            '6.2': {
                'deprecated': ['hz'],
                'renamed': {},
                'new_features': ['tracking-table-max-keys']
            }
        }
    
    def migrate_config(self, old_config, target_version):
        migrated_config = old_config.copy()
        rules = self.migration_rules.get(target_version, {})
        
        # Handle deprecated settings
        for deprecated in rules.get('deprecated', []):
            if deprecated in migrated_config:
                del migrated_config[deprecated]
                print(f"Removed deprecated setting: {deprecated}")
        
        # Handle renamed settings
        for old_name, new_name in rules.get('renamed', {}).items():
            if old_name in migrated_config:
                migrated_config[new_name] = migrated_config.pop(old_name)
                print(f"Renamed setting: {old_name} -> {new_name}")
        
        # Add new features with defaults
        for new_feature in rules.get('new_features', []):
            if new_feature not in migrated_config:
                default_value = self._get_default_value(new_feature)
                migrated_config[new_feature] = default_value
                print(f"Added new setting: {new_feature} = {default_value}")
        
        return migrated_config
    
    def _get_default_value(self, setting):
        defaults = {
            'acl-log-max-len': 128,
            'io-threads': 1,
            'tracking-table-max-keys': 1000000
        }
        return defaults.get(setting, '')
```

#### Compatibility Testing

**Automated Compatibility Verification:**

```python
class RedisCompatibilityTester:
    def __init__(self, old_client, new_client):
        self.old_client = old_client
        self.new_client = new_client
        self.test_results = []
    
    def run_compatibility_tests(self):
        tests = [
            self._test_basic_operations,
            self._test_data_structures,
            self._test_lua_scripts,
            self._test_pub_sub,
            self._test_transactions
        ]
        
        for test in tests:
            try:
                result = test()
                self.test_results.append({
                    'test': test.__name__,
                    'status': 'PASS' if result else 'FAIL',
                    'timestamp': datetime.utcnow().isoformat()
                })
            except Exception as e:
                self.test_results.append({
                    'test': test.__name__,
                    'status': 'ERROR',
                    'error': str(e),
                    'timestamp': datetime.utcnow().isoformat()
                })
    
    def _test_basic_operations(self):
        # Test basic SET/GET operations
        test_key = 'compat_test:basic'
        test_value = 'test_value'
        
        self.new_client.set(test_key, test_value)
        retrieved_value = self.new_client.get(test_key)
        
        return retrieved_value.decode('utf-8') == test_value
    
    def _test_data_structures(self):
        # Test various data structures
        tests = [
            ('hash', lambda: self.new_client.hset('test:hash', 'field', 'value')),
            ('list', lambda: self.new_client.lpush('test:list', 'item')),
            ('set', lambda: self.new_client.sadd('test:set', 'member')),
            ('zset', lambda: self.new_client.zadd('test:zset', {'member': 1.0}))
        ]
        
        for data_type, operation in tests:
            try:
                operation()
            except Exception:
                return False
        
        return True
```

### Incident Response Procedures

#### Automated Incident Detection

**Real-time Monitoring System:**

```python
class RedisIncidentDetector:
    def __init__(self, redis_client, alert_thresholds):
        self.redis = redis_client
        self.thresholds = alert_thresholds
        self.incident_queue = []
        self.incident_handlers = {
            'MEMORY_CRITICAL': self._handle_memory_critical,
            'CONNECTION_LIMIT': self._handle_connection_limit,
            'REPLICATION_FAILURE': self._handle_replication_failure,
            'SLOW_QUERIES': self._handle_slow_queries
        }
    
    def detect_incidents(self):
        info = self.redis.info()
        incidents = []
        
        # Memory usage incident
        memory_usage = info['used_memory']
        max_memory = info.get('maxmemory', 0)
        if max_memory > 0 and memory_usage > max_memory * 0.95:
            incidents.append({
                'type': 'MEMORY_CRITICAL',
                'severity': 'CRITICAL',
                'details': {
                    'used_memory': memory_usage,
                    'max_memory': max_memory,
                    'usage_percent': (memory_usage / max_memory) * 100
                }
            })
        
        # Connection limit incident
        connected_clients = info['connected_clients']
        max_clients = info.get('maxclients', 10000)
        if connected_clients > max_clients * 0.9:
            incidents.append({
                'type': 'CONNECTION_LIMIT',
                'severity': 'WARNING',
                'details': {
                    'connected_clients': connected_clients,
                    'max_clients': max_clients,
                    'usage_percent': (connected_clients / max_clients) * 100
                }
            })
        
        # Replication failure incident
        if info['role'] == 'master' and info['connected_slaves'] == 0:
            incidents.append({
                'type': 'REPLICATION_FAILURE',
                'severity': 'CRITICAL',
                'details': {
                    'role': info['role'],
                    'connected_slaves': info['connected_slaves']
                }
            })
        
        return incidents
    
    def handle_incident(self, incident):
        incident_type = incident['type']
        handler = self.incident_handlers.get(incident_type)
        
        if handler:
            try:
                response = handler(incident)
                incident['response'] = response
                incident['status'] = 'HANDLED'
            except Exception as e:
                incident['response'] = f"Handler failed: {str(e)}"
                incident['status'] = 'FAILED'
        else:
            incident['response'] = f"No handler for incident type: {incident_type}"
            incident['status'] = 'UNHANDLED'
        
        # Log incident
        self._log_incident(incident)
        
        return incident
    
    def _handle_memory_critical(self, incident):
        # Implement memory pressure relief
        actions = []
        
        # Flush expired keys
        self.redis.execute_command('FLUSHEXPIRED')
        actions.append('Flushed expired keys')
        
        # Analyze memory usage
        memory_info = self.redis.memory_usage()
        actions.append(f'Memory analysis completed')
        
        # Trigger alerts
        self._send_alert('MEMORY_CRITICAL', incident['details'])
        actions.append('Alert sent to operations team')
        
        return actions
    
    def _handle_connection_limit(self, incident):
        # Kill idle connections
        client_list = self.redis.client_list()
        killed_connections = 0
        
        for client in client_list:
            if client.get('idle', 0) > 300:  # 5 minutes idle
                try:
                    self.redis.client_kill_filter(id=client['id'])
                    killed_connections += 1
                except:
                    pass
        
        return [f'Killed {killed_connections} idle connections']
    
    def _send_alert(self, alert_type, details):
        # Implementation for sending alerts (email, Slack, PagerDuty, etc.)
        alert_message = {
            'type': alert_type,
            'details': details,
            'timestamp': datetime.utcnow().isoformat(),
            'server': self.redis.info()['redis_version']
        }
        
        # Store alert in Redis for dashboard
        self.redis.lpush('alerts', json.dumps(alert_message))
        self.redis.ltrim('alerts', 0, 999)  # Keep last 1000 alerts
```

#### Disaster Recovery Procedures

**Automated Recovery System:**

```python
class RedisDisasterRecovery:
    def __init__(self, primary_config, backup_configs):
        self.primary_config = primary_config
        self.backup_configs = backup_configs
        self.recovery_steps = []
    
    def initiate_failover(self, failed_instance):
        recovery_plan = self._create_recovery_plan(failed_instance)
        
        for step in recovery_plan:
            try:
                self._execute_recovery_step(step)
                self.recovery_steps.append({
                    'step': step['name'],
                    'status': 'SUCCESS',
                    'timestamp': datetime.utcnow().isoformat()
                })
            except Exception as e:
                self.recovery_steps.append({
                    'step': step['name'],
                    'status': 'FAILED',
                    'error': str(e),
                    'timestamp': datetime.utcnow().isoformat()
                })
                raise
    
    def _create_recovery_plan(self, failed_instance):
        if failed_instance == 'master':
            return [
                {'name': 'select_new_master', 'target': 'best_slave'},
                {'name': 'promote_to_master', 'target': 'selected_slave'},
                {'name': 'update_app_config', 'target': 'application'},
                {'name': 'verify_operations', 'target': 'new_master'}
            ]
        else:
            return [
                {'name': 'provision_new_slave', 'target': 'new_instance'},
                {'name': 'sync_from_master', 'target': 'new_slave'},
                {'name': 'verify_replication', 'target': 'new_slave'}
            ]
    
    def _execute_recovery_step(self, step):
        if step['name'] == 'select_new_master':
            self._select_best_slave()
        elif step['name'] == 'promote_to_master':
            self._promote_slave_to_master(step['target'])
        elif step['name'] == 'update_app_config':
            self._update_application_config()
        elif step['name'] == 'verify_operations':
            self._verify_master_operations()
    
    def _select_best_slave(self):
        # Logic to select the best slave based on:
        # - Replication lag
        # - Data consistency
        # - Hardware capacity
        # - Network latency
        pass
```

**Key points:**

- Comprehensive logging and audit trails are essential for troubleshooting and compliance
- Capacity planning requires continuous monitoring and predictive analysis
- Upgrade strategies should minimize downtime through rolling deployments
- Incident response procedures must be automated and well-tested
- Real-time monitoring enables proactive issue detection and resolution
- Disaster recovery plans should be regularly tested and updated

---


## PostgreSQL Failover and Disaster Recovery Strategies


### Understanding Database Failures

Database systems can experience various types of failures that necessitate failover or recovery operations. Understanding these failure modes is crucial for planning appropriate strategies.

**Key Points**:

- Failures can occur at multiple levels: hardware, software, network, and facility
- Mean Time Between Failures (MTBF) and Mean Time To Recovery (MTTR) are key metrics
- Recovery Point Objective (RPO) defines acceptable data loss
- Recovery Time Objective (RTO) defines acceptable downtime
- Different failure scenarios require different recovery approaches

#### Common Failure Scenarios

|Failure Type|Examples|Typical Impact|
|---|---|---|
|Server Hardware|Disk failure, memory errors, CPU failures|Single node unavailability|
|Software|PostgreSQL crashes, OS kernel panics, bugs|Service interruption|
|Network|Switch failure, cable damage, routing issues|Connectivity loss|
|Data Corruption|Storage failures, software bugs|Data integrity issues|
|Regional|Power outages, natural disasters|Entire data center unavailability|

### High Availability Architecture Components

A robust PostgreSQL high availability setup typically includes several components working together:

1. **Replication**: Data duplication across servers
2. **Monitoring**: Detection of failures
3. **Fencing**: Prevention of split-brain scenarios
4. **Failover Mechanism**: Automated or manual process to switch to standby
5. **Connection Routing**: Redirecting application connections

### Failover Types

#### Manual Failover

Manual failover involves human intervention to promote a standby to primary. This approach provides complete control but has slower response times.

**Example Procedure**:

```bash
# 1. Stop applications from writing to the database
# 2. Ensure replication is caught up
psql -c "SELECT pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn()"

# 3. Promote standby to primary
pg_ctl promote -D /path/to/data_directory

# 4. Reconfigure former primary as new standby (if recoverable)
# 5. Update connection information for applications
```

#### Automated Failover

Automated failover uses software to detect failures and perform promotion without human intervention. This enables faster recovery but requires careful configuration to avoid false positives.

Popular tools include:

- Patroni
- repmgr
- PAF (PostgreSQL Automatic Failover)
- pgpool-II

### Failover Solutions Compared

|Solution|Pros|Cons|Best For|
|---|---|---|---|
|**Patroni**|Strong consistency guarantees, Consensus-based (etcd/Consul/ZooKeeper), Highly configurable|More complex setup, Requires additional infrastructure|Enterprise environments, Critical applications|
|**repmgr**|Simpler setup, Native PostgreSQL tooling, Witness server option|Less sophisticated fencing, Potential split-brain issues|Small to medium deployments|
|**PAF**|Integrates with Pacemaker/Corosync, Mature cluster stack|Complex setup, Linux-centric|Organizations already using Pacemaker|
|**pgpool-II**|Connection pooling included, Load balancing capabilities|More complex configuration, Less reliable failover detection|Environments needing connection pooling|

### Implementing Patroni for Automated Failover

Patroni is one of the most robust solutions for PostgreSQL high availability. Here's how to set it up:

#### Prerequisites

- Multiple servers (minimum 3 recommended)
- etcd, Consul, or ZooKeeper for distributed consensus
- PostgreSQL installed on database nodes

#### Configuration Example

```yaml
# patroni.yml
scope: postgres-cluster
name: node1

restapi:
  listen: 0.0.0.0:8008
  connect_address: 192.168.1.10:8008

etcd:
  host: 192.168.1.5:2379

bootstrap:
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576
    postgresql:
      use_pg_rewind: true
      parameters:
        max_connections: 100
        shared_buffers: 4GB
        wal_level: replica
        hot_standby: "on"
        max_wal_senders: 10
        max_replication_slots: 10
        wal_keep_segments: 100

postgresql:
  listen: 0.0.0.0:5432
  connect_address: 192.168.1.10:5432
  data_dir: /var/lib/postgresql/12/main
  bin_dir: /usr/lib/postgresql/12/bin
  pgpass: /tmp/pgpass
  authentication:
    replication:
      username: replicator
      password: replpass
    superuser:
      username: postgres
      password: secretpass
  parameters:
    unix_socket_directories: '/var/run/postgresql'
```

#### Starting the Cluster

```bash
# On each node, start Patroni
patroni /etc/patroni.yml
```

#### Verifying the Setup

```bash
# Check cluster status
patronictl -c /etc/patroni.yml list

# Sample output:
# + Cluster: postgres-cluster (6978782451474702822) -----+----+-----------+
# | Member | Host           | Role    | State    | TL | Lag in MB |
# +--------+----------------+---------+----------+----+-----------+
# | node1  | 192.168.1.10   | Leader  | running  |  1 |           |
# | node2  | 192.168.1.11   | Replica | running  |  1 |       0.0 |
# | node3  | 192.168.1.12   | Replica | running  |  1 |       0.0 |
# +--------+----------------+---------+----------+----+-----------+
```

#### Testing Failover

```bash
# Manually trigger a failover for testing
patronictl -c /etc/patroni.yml switchover
```

### Implementing repmgr for Automated Failover

repmgr is a more lightweight solution built natively for PostgreSQL:

#### Configuration Example

```ini
# repmgr.conf
node_id=1
node_name=node1
conninfo='host=192.168.1.10 user=repmgr dbname=repmgr connect_timeout=2'
data_directory='/var/lib/postgresql/12/main'

# Failover configuration
failover=automatic
promote_command='repmgr standby promote -f /etc/repmgr.conf --log-to-file'
follow_command='repmgr standby follow -f /etc/repmgr.conf --log-to-file --upstream-node-id=%n'

# Logging
log_file='/var/log/postgresql/repmgr.log'
log_level=INFO
```

#### Registering Nodes

```bash
# Register the primary
repmgr primary register

# Register standbys
repmgr standby register
```

#### Monitoring Status

```bash
# Check cluster status
repmgr cluster show

# Sample output:
# ID | Name  | Role    | Status    | Upstream | Location | Priority | Timeline
# ---+-------+---------+-----------+----------+----------+----------+---------
#  1 | node1 | primary | * running |          | default  | 100      | 1
#  2 | node2 | standby |   running | node1    | default  | 100      | 1
#  3 | node3 | standby |   running | node1    | default  | 100      | 1
```

### Connection Management During Failover

A critical aspect of failover is redirecting application traffic to the new primary. Several approaches exist:

#### Virtual IP (VIP)

A virtual IP address is reassigned to the current primary server:

```bash
# Example VIP assignment using arping
sudo ip addr add 192.168.1.100/24 dev eth0
sudo arping -U -c 3 -I eth0 192.168.1.100
```

#### DNS Updates

Update DNS records to point to the new primary:

```bash
# Example with nsupdate
nsupdate -k /etc/bind/ddns.key <<EOF
server dns.example.com
zone example.com
update delete db.example.com. A
update add db.example.com. 60 A 192.168.1.11
send
EOF
```

#### Connection Poolers

Tools like pgBouncer or Pgpool-II can manage connections:

```ini
# pgbouncer.ini with Consul integration
[databases]
postgres = host=postgres.service.consul port=5432 dbname=postgres

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
logfile = /var/log/postgresql/pgbouncer.log
pidfile = /var/run/postgresql/pgbouncer.pid
admin_users = postgres
```

#### Application-Level Handling

Applications can handle failover with connection retry logic:

```python
# Python example with psycopg2
import psycopg2
import time

def get_connection(max_attempts=3, retry_interval=5):
    attempts = 0
    while attempts < max_attempts:
        try:
            # Try all possible hosts in sequence
            for host in ["primary.example.com", "standby1.example.com", "standby2.example.com"]:
                try:
                    conn = psycopg2.connect(
                        host=host,
                        database="app_db",
                        user="app_user",
                        password="app_pass",
                        connect_timeout=3
                    )
                    if is_writable_connection(conn):
                        return conn
                except psycopg2.OperationalError:
                    continue
        except Exception as e:
            print(f"Connection attempt {attempts+1} failed: {e}")
            attempts += 1
            time.sleep(retry_interval)
    
    raise Exception("Failed to establish database connection after multiple attempts")

def is_writable_connection(conn):
    """Test if the connection is to a writable server (primary)"""
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT pg_is_in_recovery()")
        in_recovery = cursor.fetchone()[0]
        return not in_recovery
    except:
        return False
```

### Disaster Recovery Strategies

Disaster recovery focuses on recovering from catastrophic failures affecting an entire site or cluster.

#### Backup Types

PostgreSQL offers several backup options:

1. **Physical Backups**:
    
    - `pg_basebackup`: Complete copy of data files
    - Continuous Archiving: WAL archiving for point-in-time recovery
2. **Logical Backups**:
    
    - `pg_dump`: SQL dump of database objects and data
    - `pg_dumpall`: SQL dump of all databases including roles

#### Physical Backup Strategy

A comprehensive physical backup strategy combines:

```bash
# Base backup
pg_basebackup -D /backup/base/$(date +%Y%m%d) -Ft -z -P -U replicator

# WAL archiving (in postgresql.conf)
archive_mode = on
archive_command = 'test ! -f /backup/wal/%f && cp %p /backup/wal/%f'
```

#### Logical Backup Strategy

Regular logical backups provide another recovery option:

```bash
# Daily dumps of individual databases
pg_dump -Fc -f /backup/logical/appdb_$(date +%Y%m%d).dump appdb

# Weekly full cluster dumps
pg_dumpall -f /backup/logical/full_$(date +%Y%m%d).sql
```

#### Backup Validation

Regularly test backups to ensure recoverability:

```bash
# Test recovery from physical backup
pg_ctl -D /tmp/recovery_test init
tar -xf /backup/base/20230501.tar -C /tmp/recovery_test
echo "restore_command = 'cp /backup/wal/%f %p'" > /tmp/recovery_test/recovery.conf
pg_ctl -D /tmp/recovery_test start

# Test recovery from logical backup
createdb test_recovery
pg_restore -d test_recovery /backup/logical/appdb_20230501.dump
```

### Point-in-Time Recovery (PITR)

PITR allows recovery to any specific moment using base backup and WAL archives.

#### Configuration

```
# postgresql.conf
wal_level = replica
archive_mode = on
archive_command = 'rsync -a %p backup_server:/archive/%f'
```

#### Recovery Process

```bash
# 1. Restore the base backup
pg_basebackup -D /var/lib/postgresql/12/main -Ft -z -P -U replicator
tar -xf latest.tar -C /var/lib/postgresql/12/main

# 2. Create recovery configuration (PostgreSQL 12+)
cat > /var/lib/postgresql/12/main/postgresql.auto.conf <<EOF
restore_command = 'cp /path/to/archive/%f %p'
recovery_target_time = '2023-05-01 12:00:00'
recovery_target_action = 'promote'
EOF

# Create standby.signal to start in recovery mode
touch /var/lib/postgresql/12/main/standby.signal

# 3. Start PostgreSQL
pg_ctl -D /var/lib/postgresql/12/main start
```

### Cross-Region Disaster Recovery

For protection against regional disasters, implement cross-region replication:

#### Asynchronous Physical Replication

```
# On primary (region A)
primary_conninfo = 'host=standby.region-b.example.com user=replicator'
```

#### Logical Replication

For selective table replication across regions:

```sql
-- On primary (region A)
CREATE PUBLICATION region_pub FOR ALL TABLES;

-- On standby (region B)
CREATE SUBSCRIPTION region_sub 
  CONNECTION 'host=primary.region-a.example.com dbname=postgres user=replicator' 
  PUBLICATION region_pub;
```

#### WAL Shipping to Remote Storage

```
# postgresql.conf
archive_command = 'aws s3 cp %p s3://pg-backups/wal/%f'
```

### Recovery Time Optimization

Minimize downtime during recovery with these techniques:

#### Warm Standby

Maintain an always-ready standby server:

```
# postgresql.conf on standby
hot_standby = on
```

#### Parallel Restore

Improve restoration speed:

```bash
# Parallel restore from logical backup
pg_restore -j 8 -d target_db backup.dump
```

#### Fast Storage for WAL

Use high-performance storage for WAL to speed up replay:

```
# postgresql.conf
wal_directory = '/fast-storage/wal'
```

### Testing Disaster Recovery Plans

Regular testing is crucial for effective disaster recovery:

#### Scheduled DR Tests

```bash
#!/bin/bash
# DR test script
set -e

echo "Starting DR test at $(date)"

# Create test environment
mkdir -p /tmp/dr_test
pg_basebackup -D /tmp/dr_test -Ft -z -P -U replicator

# Test recovery
tar -xf /tmp/dr_test/base.tar -C /tmp/dr_test
cat > /tmp/dr_test/recovery.conf <<EOF
restore_command = 'cp /path/to/archive/%f %p'
recovery_target_time = '$(date -d "-1 hour" +"%Y-%m-%d %H:%M:%S")'
EOF

pg_ctl -D /tmp/dr_test start
sleep 30

# Verify data
psql -h localhost -p 5433 -U postgres -d postgres -c "SELECT count(*) FROM important_table"

# Cleanup
pg_ctl -D /tmp/dr_test stop
rm -rf /tmp/dr_test

echo "DR test completed at $(date)"
```

#### Chaos Engineering

Introduce controlled failures to test resilience:

```bash
# Example: Simulate primary failure
sudo systemctl stop postgresql@12-main

# Example: Network partition
sudo iptables -A INPUT -p tcp --dport 5432 -j DROP
```

### Documentation and Runbooks

Comprehensive documentation is essential for efficient response:
#### Failover Runbook Template

##### Prerequisites
- Access credentials for all database servers
- Access to monitoring system
- Contact information for all team members

##### Automated Failover Verification
1. Check if automated failover has occurred:
```
patronictl -c /etc/patroni.yml list
```
2. Verify the new primary is accepting connections:
```
psql -h $NEW_PRIMARY -U monitoring -c "SELECT pg_is_in_recovery()"
```
3. Verify replication is functioning:
```
psql -h $NEW_PRIMARY -U monitoring -c "SELECT client_addr, state FROM pg_stat_replication"
```

##### Manual Failover Procedure
If automated failover has failed:
1. Promote the most up-to-date standby:
```
pg_ctl promote -D /path/to/data_directory
```
2. Reconfigure connection routing:
```
sudo ip addr add $VIP_ADDRESS dev eth0
```
3. Verify application connectivity

##### Post-Failover Tasks
1. Configure former primary as standby (if recoverable)
2. Update monitoring system
3. Send notification to stakeholders
4. Update documentation with incident details

### Multi-Tier Disaster Recovery Strategy

A comprehensive DR strategy often includes multiple tiers:

#### Tier 1: Local High Availability

- Streaming replication with automated failover
- Response time: seconds to minutes
- Located in same data center

#### Tier 2: Metropolitan DR

- Synchronous replication to nearby facility
- Response time: minutes
- Located in same metropolitan area

#### Tier 3: Regional DR

- Asynchronous replication across regions
- Response time: tens of minutes to hours
- Located in different geographic region

#### Tier 4: Complete Backup Recovery

- Restoration from backup archives
- Response time: hours to days
- Can be done anywhere with backup access

### Monitoring and Alerting

Effective monitoring is essential for prompt failure detection:

#### Key Metrics to Monitor

1. **Replication Status**:
    
    ```sql
    SELECT client_addr, state, sent_lsn, write_lsn, flush_lsn, replay_lsn,
           pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
    FROM pg_stat_replication;
    ```
    
2. **Replication Lag**:
    
    ```sql
    SELECT now() - pg_last_xact_replay_timestamp() AS replication_lag;
    ```
    
3. **WAL Generation Rate**:
    
    ```bash
    watch -n 10 "psql -c \"SELECT pg_walfile_name(pg_current_wal_lsn()), pg_wal_lsn_diff(pg_current_wal_lsn(), '0/0')\""
    ```
    

#### Alerting Examples

Using Prometheus and Alertmanager:

```yaml
# Alert rule for replication lag
groups:
- name: postgresql_replication
  rules:
  - alert: PostgreSQLReplicationLag
    expr: pg_replication_lag > 300  # 5 minutes
    for: 1m
    labels:
      severity: warning
    annotations:
      summary: "PostgreSQL replication lag detected"
      description: "Replication lag on {{ $labels.instance }} is {{ $value }}s"

  - alert: PostgreSQLReplicationStopped
    expr: pg_replication_state != 1
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "PostgreSQL replication stopped"
      description: "Replication on {{ $labels.instance }} has stopped"
```

### Best Practices Summary

1. **Design for Failure**: Assume components will fail and plan accordingly
2. **Practice Recovery**: Regular testing of failover and recovery processes
3. **Automate Where Possible**: Reduce human error through automation
4. **Multiple Recovery Options**: Implement both physical and logical backups
5. **Monitor Proactively**: Detect issues before they cause outages
6. **Document Everything**: Maintain detailed runbooks and procedures
7. **Tiered Recovery Strategy**: Balance cost vs. recovery time objectives
8. **End-to-End Testing**: Test the entire stack, not just the database
9. **Regular Reviews**: Update plans as infrastructure and applications evolve
10. **Train Team Members**: Ensure everyone knows their role during recovery

### Related Topics

- PostgreSQL replication configurations
- Backup management and automation
- Data consistency and integrity verification
- Cloud-based disaster recovery options
- Recovery testing methodologies

---


## Partitioning and Sharding


### Understanding Database Partitioning

Database partitioning is a technique that divides large tables and indexes into smaller, more manageable pieces called partitions. Each partition contains a subset of the data based on defined rules, but they collectively represent a single logical table from the application's perspective. The database system handles the routing of queries to the appropriate partition(s).

#### Benefits of Partitioning

- **Improved query performance**: Queries can scan only relevant partitions
- **Easier maintenance**: Operations like backup, restore, and index rebuilding can target specific partitions
- **Enhanced availability**: Individual partitions can be maintained without affecting the entire table
- **Efficient data lifecycle management**: Old data partitions can be archived or removed quickly
- **Better resource utilization**: Partitions can be distributed across storage media or servers

### Types of Database Partitioning

#### Horizontal Partitioning (Row-Based)

Horizontal partitioning divides a table by distributing rows across multiple partitions based on values in specific columns. Each partition contains a complete subset of rows with the same schema.

**Common Partitioning Strategies:**

- **Range Partitioning**: Divides data based on value ranges (e.g., date ranges)
    
    ```sql
    CREATE TABLE sales (
        sale_id INT,
        sale_date DATE,
        amount DECIMAL(10,2),
        customer_id INT
    ) PARTITION BY RANGE (sale_date);
    
    CREATE TABLE sales_q1_2022 PARTITION OF sales
        FOR VALUES FROM ('2022-01-01') TO ('2022-04-01');
    
    CREATE TABLE sales_q2_2022 PARTITION OF sales
        FOR VALUES FROM ('2022-04-01') TO ('2022-07-01');
    ```
    
- **List Partitioning**: Separates data based on discrete values or categories
    
    ```sql
    CREATE TABLE customers (
        customer_id INT,
        name VARCHAR(100),
        region VARCHAR(50)
    ) PARTITION BY LIST (region);
    
    CREATE TABLE customers_east PARTITION OF customers
        FOR VALUES IN ('East', 'Northeast', 'Southeast');
    
    CREATE TABLE customers_west PARTITION OF customers
        FOR VALUES IN ('West', 'Northwest', 'Southwest');
    ```
    
- **Hash Partitioning**: Distributes data evenly based on a hash function
    
    ```sql
    CREATE TABLE orders (
        order_id INT,
        customer_id INT,
        order_date DATE
    ) PARTITION BY HASH (customer_id);
    
    CREATE TABLE orders_part0 PARTITION OF orders
        FOR VALUES WITH (MODULUS 4, REMAINDER 0);
    
    CREATE TABLE orders_part1 PARTITION OF orders
        FOR VALUES WITH (MODULUS 4, REMAINDER 1);
    ```
    

#### Vertical Partitioning (Column-Based)

Vertical partitioning splits a table by columns rather than rows. This technique is typically implemented as separate tables with shared primary keys rather than through database partitioning mechanisms.

```sql
-- Original wide table
CREATE TABLE user_profile (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    email VARCHAR(100),
    password_hash VARCHAR(128),
    bio TEXT,
    profile_image BYTEA,
    preferences JSONB
);

-- Vertically partitioned into multiple tables
CREATE TABLE user_credentials (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    email VARCHAR(100),
    password_hash VARCHAR(128)
);

CREATE TABLE user_content (
    user_id INT PRIMARY KEY REFERENCES user_credentials(user_id),
    bio TEXT,
    profile_image BYTEA
);

CREATE TABLE user_preferences (
    user_id INT PRIMARY KEY REFERENCES user_credentials(user_id),
    preferences JSONB
);
```

### Advanced Partitioning Techniques

#### Sub-partitioning (Composite Partitioning)

Sub-partitioning applies a second partitioning strategy to an already partitioned table, creating a hierarchy of partitions.

```sql
CREATE TABLE sales (
    sale_id INT,
    sale_date DATE,
    region VARCHAR(50),
    amount DECIMAL(10,2)
) PARTITION BY RANGE (sale_date);

-- First-level partition
CREATE TABLE sales_2022 PARTITION OF sales
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01')
    PARTITION BY LIST (region);

-- Second-level partitions
CREATE TABLE sales_2022_north PARTITION OF sales_2022
    FOR VALUES IN ('North', 'Northeast');

CREATE TABLE sales_2022_south PARTITION OF sales_2022
    FOR VALUES IN ('South', 'Southeast');
```

#### Dynamic Partition Management

Implementing automated partition creation and retirement for time-series data:

```sql
-- Function to create future partitions
CREATE OR REPLACE FUNCTION create_month_partition()
RETURNS TRIGGER AS $$
DECLARE
    future_date DATE;
    partition_name TEXT;
    start_date DATE;
    end_date DATE;
BEGIN
    -- Create partitions for the next 3 months
    FOR i IN 1..3 LOOP
        future_date := DATE_TRUNC('month', CURRENT_DATE) + (i || ' month')::INTERVAL;
        partition_name := 'events_' || TO_CHAR(future_date, 'YYYY_MM');
        start_date := DATE_TRUNC('month', future_date);
        end_date := start_date + '1 month'::INTERVAL;
        
        -- Check if partition exists
        IF NOT EXISTS (
            SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE c.relname = partition_name AND n.nspname = 'public'
        ) THEN
            EXECUTE format(
                'CREATE TABLE %I PARTITION OF events FOR VALUES FROM (%L) TO (%L)',
                partition_name, start_date, end_date
            );
            RAISE NOTICE 'Created partition %', partition_name;
        END IF;
    END LOOP;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to run monthly
CREATE TRIGGER maintain_partitions
    AFTER INSERT ON events
    FOR EACH STATEMENT
    EXECUTE FUNCTION create_month_partition();
```

### Understanding Database Sharding

Sharding is a database architecture strategy that horizontally partitions data across multiple separate database instances (shards), each running on its own server. Unlike partitioning, which operates within a single database instance, sharding distributes data across multiple independent databases.

#### Key Characteristics of Sharding

- **Complete separation**: Each shard is a fully independent database instance
- **Distribution**: Data is spread across multiple servers or physical locations
- **Scale-out approach**: Adds more capacity by adding more shards
- **Application-level implementation**: Often requires custom routing logic in the application layer

### Sharding Strategies

#### Key-Based Sharding

Data is distributed based on a key value from each record, typically using hash functions to determine placement.

```python
# Python example of application-level key-based sharding logic
def get_shard_connection(customer_id):
    shard_number = hash(customer_id) % TOTAL_SHARDS
    return shard_connections[shard_number]

def save_customer_order(customer_id, order_data):
    connection = get_shard_connection(customer_id)
    with connection.cursor() as cursor:
        cursor.execute(
            "INSERT INTO orders (customer_id, order_date, amount) VALUES (%s, %s, %s)",
            (customer_id, order_data['date'], order_data['amount'])
        )
    connection.commit()
```

#### Range-Based Sharding

Records are assigned to shards based on ranges of values, such as customer ID ranges or geographical regions.

```sql
-- Shard 1: Database for customers A-M
CREATE DATABASE customer_shard_a_m;
\c customer_shard_a_m
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    -- Other fields
    CHECK (name >= 'A' AND name < 'N')
);

-- Shard 2: Database for customers N-Z
CREATE DATABASE customer_shard_n_z;
\c customer_shard_n_z
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    -- Other fields
    CHECK (name >= 'N' AND name <= 'Z')
);
```

#### Directory-Based Sharding

This strategy uses a lookup service or routing table to map keys to specific shards, providing flexibility in data distribution.

```python
# Example of a directory-based sharding implementation
class ShardDirectory:
    def __init__(self):
        self.directory_db = connect_to_directory_database()
        self.shard_connections = {}
        
    def get_shard_for_key(self, key):
        with self.directory_db.cursor() as cursor:
            cursor.execute("SELECT shard_id FROM shard_map WHERE key_range @> %s", (key,))
            shard_id = cursor.fetchone()[0]
        return self.get_connection(shard_id)
    
    def get_connection(self, shard_id):
        if shard_id not in self.shard_connections:
            shard_config = self.get_shard_config(shard_id)
            self.shard_connections[shard_id] = connect_to_database(
                host=shard_config['host'],
                port=shard_config['port'],
                database=shard_config['database']
            )
        return self.shard_connections[shard_id]
```

### Implementing Sharding Architectures

#### Proxy-Based Sharding

A middleware component routes queries to the appropriate shard and aggregates results.

```
[Application] ---> [Sharding Proxy] ---> [Shard 1]
                     |      |             [Shard 2]
                     v      v             [Shard 3]
            [Shard Metadata]  [Query Parser]
```

#### Client-Based Sharding

The application itself contains logic to determine which shard to query.

```java
// Java example of client-based sharding
public class ShardedRepository {
    private final DataSource[] shardDataSources;
    private final int shardCount;
    
    public ShardedRepository(DataSource[] shardDataSources) {
        this.shardDataSources = shardDataSources;
        this.shardCount = shardDataSources.length;
    }
    
    public Order findOrderById(String customerId, Long orderId) {
        int shardIndex = Math.abs(customerId.hashCode() % shardCount);
        DataSource targetShard = shardDataSources[shardIndex];
        
        try (Connection conn = targetShard.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT * FROM orders WHERE customer_id = ? AND order_id = ?")) {
            stmt.setString(1, customerId);
            stmt.setLong(2, orderId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToOrder(rs);
                }
                return null;
            }
        } catch (SQLException e) {
            throw new RepositoryException("Error querying order", e);
        }
    }
}
```

### Challenges and Solutions in Partitioning and Sharding

#### Cross-Partition Queries

Querying data across multiple partitions or shards can be challenging and performance-intensive.

**Solutions:**

- Denormalize data to minimize cross-partition joins
- Use materialized views to consolidate data for reporting
- Implement query federation to execute and merge results from multiple partitions

```sql
-- Example of a PostgreSQL foreign data wrapper to query across shards
CREATE SERVER shard1 FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'shard1.example.com', port '5432', dbname 'sales');

CREATE USER MAPPING FOR current_user SERVER shard1
    OPTIONS (user 'reporting', password 'secret');

CREATE FOREIGN TABLE sales_shard1 (
    sale_id INT,
    product_id INT,
    sale_date DATE,
    amount DECIMAL(10,2)
) SERVER shard1 OPTIONS (table_name 'sales');

-- Create similar foreign tables for other shards

-- Create a UNION view across all shards
CREATE VIEW all_sales AS
    SELECT * FROM sales_shard1
    UNION ALL
    SELECT * FROM sales_shard2
    UNION ALL
    SELECT * FROM sales_shard3;
```

#### Data Distribution Skew

Uneven data distribution can lead to "hot spots" where some partitions or shards contain significantly more data or receive more traffic.

**Solutions:**

- Use consistent hashing algorithms to distribute load evenly
- Implement dynamic rebalancing of data
- Consider compound sharding keys to improve distribution

```python
# Example of consistent hashing for sharding
class ConsistentHashRing:
    def __init__(self, nodes=None, replicas=100):
        self.replicas = replicas
        self.ring = {}
        self.sorted_keys = []
        
        if nodes:
            for node in nodes:
                self.add_node(node)
                
    def add_node(self, node):
        for i in range(self.replicas):
            key = self._hash(f"{node}:{i}")
            self.ring[key] = node
        self.sorted_keys = sorted(self.ring.keys())
    
    def remove_node(self, node):
        for i in range(self.replicas):
            key = self._hash(f"{node}:{i}")
            del self.ring[key]
        self.sorted_keys = sorted(self.ring.keys())
    
    def get_node(self, key):
        if not self.ring:
            return None
            
        hash_key = self._hash(key)
        
        # Find the first point in the ring at or clockwise from hash_key
        for ring_key in self.sorted_keys:
            if hash_key <= ring_key:
                return self.ring[ring_key]
        
        # If we've gone all the way around the ring, return the first node
        return self.ring[self.sorted_keys[0]]
    
    def _hash(self, key):
        return hash(key) & 0xffffffff
```

#### Schema Changes and Migrations

Applying schema changes across multiple partitions or shards requires careful coordination.

**Solutions:**

- Use automated migration tools with shard awareness
- Apply changes in phases to minimize downtime
- Maintain backward compatibility during transitions

```python
# Example of a sharded migration script
def run_migration_across_shards(migration_sql):
    shard_connections = get_all_shard_connections()
    
    for connection in shard_connections:
        print(f"Running migration on {connection.dsn}")
        try:
            with connection.cursor() as cursor:
                cursor.execute("BEGIN")
                cursor.execute(migration_sql)
                cursor.execute("COMMIT")
            print("Migration successful")
        except Exception as e:
            print(f"Migration failed: {e}")
            connection.rollback()
```

#### Transaction Management

Maintaining ACID properties across partitions or shards is complex.

**Solutions:**

- Use eventual consistency models where appropriate
- Implement two-phase commit for critical transactions
- Consider saga patterns for complex workflows

```java
// Java example of a two-phase commit transaction manager for shards
public class ShardedTransactionManager {
    private final List<DataSource> shards;
    
    public void executeTransaction(ShardedTransaction transaction) throws TransactionException {
        List<Connection> connections = new ArrayList<>();
        
        try {
            // Phase 1: Prepare all connections
            for (DataSource shard : shards) {
                Connection conn = shard.getConnection();
                conn.setAutoCommit(false);
                connections.add(conn);
            }
            
            // Execute transaction logic across all shards
            transaction.execute(connections);
            
            // Phase 2: Commit if all succeeded
            for (Connection conn : connections) {
                conn.commit();
            }
        } catch (Exception e) {
            // Rollback all on any failure
            for (Connection conn : connections) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    // Log rollback failure
                }
            }
            throw new TransactionException("Transaction failed", e);
        } finally {
            // Clean up
            for (Connection conn : connections) {
                try {
                    conn.close();
                } catch (SQLException closeEx) {
                    // Log close failure
                }
            }
        }
    }
}
```

### Real-world Implementation Patterns

#### Time-Series Data Storage Pattern

Partitioning time-series data by time intervals allows for efficient data lifecycle management.

```sql
-- PostgreSQL example of time-series partitioning
CREATE TABLE sensor_readings (
    reading_id SERIAL,
    sensor_id INT NOT NULL,
    reading_time TIMESTAMP NOT NULL,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    pressure DECIMAL(8,2)
) PARTITION BY RANGE (reading_time);

-- Create partitions for each month
CREATE TABLE sensor_readings_202201 PARTITION OF sensor_readings
    FOR VALUES FROM ('2022-01-01') TO ('2022-02-01');
    
CREATE TABLE sensor_readings_202202 PARTITION OF sensor_readings
    FOR VALUES FROM ('2022-02-01') TO ('2022-03-01');

-- Add table partitioning policy for automatic retention
ALTER TABLE sensor_readings
    ATTACH PARTITION sensor_readings_default DEFAULT;
    
-- Create a procedure to manage retention
CREATE OR REPLACE PROCEDURE maintain_time_partitions(retention_months INT)
LANGUAGE plpgsql AS $$
DECLARE
    partition_date DATE;
    partition_name TEXT;
    drop_before DATE;
BEGIN
    -- Calculate cutoff date
    drop_before := CURRENT_DATE - (retention_months || ' months')::INTERVAL;
    
    -- Find and drop old partitions
    FOR partition_name IN
        SELECT tablename FROM pg_tables
        WHERE tablename LIKE 'sensor_readings_%'
        AND tablename != 'sensor_readings_default'
    LOOP
        -- Extract date from partition name
        BEGIN
            partition_date := TO_DATE(RIGHT(partition_name, 6), 'YYYYMM');
            
            IF partition_date < drop_before THEN
                EXECUTE 'DROP TABLE ' || partition_name;
                RAISE NOTICE 'Dropped old partition: %', partition_name;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Error processing partition %: %', partition_name, SQLERRM;
        END;
    END LOOP;
END;
$$;
```

#### Multi-tenant Database Pattern

Sharding by tenant ID for SaaS applications:

```sql
-- Implementing tenant-based sharding

-- Metadata database schema (central directory)
CREATE TABLE tenants (
    tenant_id UUID PRIMARY KEY,
    tenant_name VARCHAR(100) NOT NULL,
    shard_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE shards (
    shard_id INT PRIMARY KEY,
    connection_string VARCHAR(255) NOT NULL,
    current_size_gb DECIMAL(10,2),
    max_size_gb DECIMAL(10,2)
);

-- Application pseudocode to route tenant requests
function get_connection_for_tenant(tenant_id) {
    // Query metadata DB for shard info
    shard_info = execute_query(
        "SELECT s.connection_string FROM tenants t " +
        "JOIN shards s ON t.shard_id = s.shard_id " +
        "WHERE t.tenant_id = ?", 
        [tenant_id]
    );
    
    if (!shard_info) {
        throw new Error("Tenant not found");
    }
    
    // Return connection to the appropriate shard
    return create_connection(shard_info.connection_string);
}
```

#### Global Distribution Pattern

Geographically sharding data for low-latency access:

```
// Geo-sharding architecture

[Global Router Service]
      /     |     \
     /      |      \
[US Shard] [EU Shard] [APAC Shard]
    |          |          |
[US Replica] [EU Replica] [APAC Replica]
```

```javascript
// Node.js example of a geo-routing middleware
const express = require('express');
const app = express();

// Configuration for regional shards
const shardConfig = {
  'us-east': { host: 'db-us-east.example.com', region: 'US-East' },
  'us-west': { host: 'db-us-west.example.com', region: 'US-West' },
  'eu-central': { host: 'db-eu.example.com', region: 'EU' },
  'asia-east': { host: 'db-asia.example.com', region: 'Asia' }
};

// Geo-routing middleware
app.use((req, res, next) => {
  // Determine user region from headers or IP
  const userRegion = determineUserRegion(req);
  
  // Assign closest shard
  req.dbConnection = getShardForRegion(userRegion);
  next();
});

function determineUserRegion(req) {
  // Implementation to detect user region
  // Could use CloudFront headers, GeoIP database, etc.
  const ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
  return geoIpLookup(ip);
}

function getShardForRegion(userRegion) {
  // Map user region to closest database shard
  if (userRegion.startsWith('US')) {
    return userRegion.includes('West') ? 
      shardConfig['us-west'] : shardConfig['us-east'];
  } else if (userRegion.startsWith('EU')) {
    return shardConfig['eu-central'];
  } else {
    return shardConfig['asia-east'];
  }
}
```

**Conclusion:** Partitioning and sharding are powerful strategies for scaling databases and managing large datasets efficiently. While partitioning offers a simpler approach within a single database instance, sharding provides greater scalability by distributing data across multiple independent databases. Both techniques require careful planning to address challenges like cross-partition queries, data distribution skew, and transaction management. When implemented effectively, these strategies can significantly improve performance, availability, and manageability of large-scale database systems.

Related topics to consider exploring include: query optimization across partitions, distributed transaction protocols, NoSQL database sharding approaches, and cloud-native database scaling techniques.

---


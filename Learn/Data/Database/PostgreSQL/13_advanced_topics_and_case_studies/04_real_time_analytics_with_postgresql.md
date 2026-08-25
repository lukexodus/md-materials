## Real-Time Analytics with PostgreSQL


### Introduction to Real-Time Analytics

Real-time analytics refers to the process of collecting, processing, analyzing, and visualizing data immediately after it's generated. Unlike traditional batch processing that analyzes historical data, real-time analytics provides insights as events occur, enabling organizations to make immediate data-driven decisions. In today's fast-paced business environment, the ability to analyze and react to data in real-time has become a critical competitive advantage across industries from finance and e-commerce to IoT and telecommunications.

PostgreSQL, with its powerful feature set and extensibility, has evolved beyond a traditional transactional database to become a capable platform for real-time analytics workloads. Its ability to handle both operational and analytical processing makes it particularly suitable for applications requiring immediate insights from live data.

### PostgreSQL Foundations for Real-Time Analytics

#### Core PostgreSQL Features

**Advanced Query Planner**

- Cost-based query optimization
- Multiple join strategies
- Sophisticated statistics collection
- Parallel query execution
- Partitionwise joins and aggregations

**Robust Indexing Options**

- B-tree indexes (default)
- Hash indexes for equality comparisons
- GiST indexes for complex data types
- GIN indexes for multi-value data
- BRIN indexes for large datasets with natural ordering
- Custom index types through extensions

**Window Functions**

- Perform calculations across rows related to current row
- Support for ranking, aggregation, and offset functions
- Enables complex analytical queries without multiple self-joins
- Significant performance advantages for time-series analysis

**Common Table Expressions (CTEs)**

- Temporary result sets for complex queries
- Recursive query support
- Improved query organization and readability
- Materialization options for performance optimization

**Materialized Views**

- Pre-computed query results stored as tables
- Manual or triggered refresh options
- Indexing support for fast query performance
- Ideal for frequently accessed analytical datasets

#### Data Types for Analytics

**Numeric Types**

- Precise decimal calculations with `numeric`
- High-range integers with `bigint`
- Performance-optimized floating point with `double precision`

**Temporal Types**

- Timestamp with/without time zone
- Date and time ranges
- Interval type for duration calculations
- Support for complex date/time operations

**Array Types**

- Multi-dimensional arrays
- Array operators and functions
- Indexing support for array elements
- Efficient storage of vector data

**JSON/JSONB**

- Flexible schema for varying data structures
- Rich indexing options for JSONB
- Path-based querying
- Aggregation and transformation functions

**Range Types**

- Representation of ranges with bounds
- Built-in types like `daterange`, `numrange`
- Custom range type support
- Specialized operators for range operations

### Real-Time Data Ingestion Strategies

#### COPY Command for Bulk Loading

The `COPY` command provides high-speed data loading capabilities:

```sql
COPY events(event_id, event_time, event_type, payload)
FROM '/path/to/events.csv' 
WITH (FORMAT CSV, HEADER);
```

**Optimization Techniques**

- Temporarily disabling indexes during bulk loads
- Adjusting work_mem for sort operations
- Using multiple parallel COPY operations
- Implementing batch processing patterns

#### Continuous Data Integration

**Foreign Data Wrappers (FDW)**

- Real-time access to external data sources
- Support for various data stores (Kafka, Redis, MongoDB)
- Query federation across heterogeneous systems
- Implementation example:

```sql
CREATE EXTENSION postgres_fdw;

CREATE SERVER kafka_server
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'kafka-broker', port '5432', dbname 'kafka_connect');

CREATE FOREIGN TABLE kafka_events (
  event_id bigint,
  event_time timestamp with time zone,
  event_type text,
  payload jsonb
)
SERVER kafka_server
OPTIONS (schema_name 'public', table_name 'events');
```

**Logical Replication**

- Stream changes from operational databases
- Publication/subscription model
- Selective replication of tables or row subsets
- Setup example:

```sql
-- On publisher
CREATE PUBLICATION event_pub FOR TABLE events;

-- On subscriber
CREATE SUBSCRIPTION event_sub
  CONNECTION 'host=publisher dbname=sourcedb'
  PUBLICATION event_pub;
```

**Change Data Capture (CDC)**

- Capturing row-level changes
- Using output plugins with logical decoding
- Integration with streaming platforms
- Minimal impact on source systems

#### Message Queue Integration

**Message Queue Processing Patterns**

- Queue listeners with trigger functions
- Background workers for queue consumption
- Transaction-based queue processing
- Error handling and retry logic

**Example: pg_notify for Simple Messaging**

```sql
-- Sender
SELECT pg_notify('new_event_channel', '{"event_id": 12345, "type": "purchase"}');

-- Receiver (in application code or PL/pgSQL function)
LISTEN new_event_channel;
-- Then process notifications as they arrive
```

### Optimizing PostgreSQL for Real-Time Queries

#### Server Configuration

**Memory Settings**

- `shared_buffers`: 25-40% of system memory
- `work_mem`: 4-16MB per connection for complex queries
- `maintenance_work_mem`: 10% of system memory for maintenance
- `effective_cache_size`: 50-75% of total system memory

**Query Planning**

- `random_page_cost`: Lower values (e.g., 1.1-2.0) for SSD storage
- `effective_io_concurrency`: Higher values for SSDs or RAID arrays
- `default_statistics_target`: Increased for complex analytics
- `jit`: Enabling JIT compilation for CPU-intensive queries

**Checkpointing**

- `checkpoint_timeout`: Extended for write-heavy workloads
- `max_wal_size`: Increased to reduce checkpoint frequency
- `checkpoint_completion_target`: 0.9 for smoother I/O distribution

**Example Configuration for Analytics Workloads**

```
# Memory Configuration
shared_buffers = 4GB
work_mem = 16MB
maintenance_work_mem = 1GB
effective_cache_size = 12GB

# Query Planning
random_page_cost = 1.1
effective_io_concurrency = 200
default_statistics_target = 500

# Checkpointing
checkpoint_timeout = 15min
max_wal_size = 16GB
checkpoint_completion_target = 0.9

# Parallelism
max_worker_processes = 16
max_parallel_workers_per_gather = 8
max_parallel_workers = 16
parallel_leader_participation = on
```

#### Indexing Strategies for Analytics

**Partial Indexes**

- Indexing only relevant portions of data
- Reduced index size and maintenance overhead
- Targeted performance improvement

```sql
CREATE INDEX recent_events_idx ON events (event_time)
WHERE event_time > (CURRENT_TIMESTAMP - INTERVAL '7 days');
```

**Covering Indexes**

- Including all columns needed for query
- Eliminating table lookups
- Balancing index size with query performance

```sql
CREATE INDEX events_analysis_idx ON events (event_type, event_time)
INCLUDE (customer_id, amount);
```

**Expression Indexes**

- Indexing computed values
- Supporting function-based filters
- Enabling specialized sorting

```sql
CREATE INDEX events_hour_idx ON events (date_trunc('hour', event_time));
```

**BRIN Indexes for Time-Series Data**

- Block range indexing for sequential data
- Minimal index size for large tables
- Effective for time-partitioned data

```sql
CREATE INDEX events_brin_idx ON events USING BRIN (event_time)
WITH (pages_per_range = 128);
```

#### Table Partitioning

**Partition by Time**

- Common strategy for time-series data
- Improved query performance through partition pruning
- Efficient archiving of older partitions
- Simplified maintenance operations

```sql
CREATE TABLE events (
  event_id bigint,
  event_time timestamp with time zone,
  event_type text,
  payload jsonb
) PARTITION BY RANGE (event_time);

-- Daily partitions
CREATE TABLE events_y2023m05d01 PARTITION OF events
  FOR VALUES FROM ('2023-05-01') TO ('2023-05-02');

CREATE TABLE events_y2023m05d02 PARTITION OF events
  FOR VALUES FROM ('2023-05-02') TO ('2023-05-03');

-- Create partitions automatically
CREATE OR REPLACE FUNCTION create_partition_and_insert()
RETURNS trigger AS $$
DECLARE
  partition_date text;
  partition_name text;
BEGIN
  partition_date := to_char(NEW.event_time, 'YYYY_MM_DD');
  partition_name := 'events_' || partition_date;
  
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = partition_name) THEN
    EXECUTE format(
      'CREATE TABLE %I PARTITION OF events FOR VALUES FROM (%L) TO (%L)',
      partition_name,
      date_trunc('day', NEW.event_time),
      date_trunc('day', NEW.event_time) + INTERVAL '1 day'
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_events_partition
BEFORE INSERT ON events
FOR EACH ROW EXECUTE FUNCTION create_partition_and_insert();
```

**Partition by Key or Value**

- Distributing data by customer, product, region, etc.
- Balanced partition sizes for even performance
- Support for multi-level partitioning

```sql
CREATE TABLE events (
  event_id bigint,
  customer_id int,
  event_time timestamp with time zone,
  event_type text,
  payload jsonb
) PARTITION BY LIST (customer_segment);

CREATE TABLE events_premium PARTITION OF events
  FOR VALUES IN ('premium');
  
CREATE TABLE events_standard PARTITION OF events
  FOR VALUES IN ('standard');
  
CREATE TABLE events_basic PARTITION OF events
  FOR VALUES IN ('basic');
```

### PostgreSQL Extensions for Real-Time Analytics

#### TimescaleDB

TimescaleDB transforms PostgreSQL into a time-series database with enhanced performance and functionality for time-series data.

**Key Features**

- Automatic time-based partitioning (hypertables)
- Advanced query optimization for time-series
- Continuous aggregations for real-time materialized views
- Data compression for historical time-series
- Multi-node distributed architecture

**Installation and Setup**

```sql
CREATE EXTENSION timescaledb;

-- Create a hypertable
CREATE TABLE sensor_data (
  time TIMESTAMPTZ NOT NULL,
  sensor_id INTEGER,
  temperature DOUBLE PRECISION,
  humidity DOUBLE PRECISION
);

SELECT create_hypertable('sensor_data', 'time');

-- Create continuous aggregation
CREATE MATERIALIZED VIEW sensor_hourly
WITH (timescaledb.continuous) AS
SELECT
  sensor_id,
  time_bucket('1 hour', time) AS hour,
  AVG(temperature) AS avg_temp,
  MAX(temperature) AS max_temp,
  MIN(temperature) AS min_temp
FROM sensor_data
GROUP BY sensor_id, hour;

-- Automated refresh policy
SELECT add_continuous_aggregate_policy('sensor_hourly',
  start_offset => INTERVAL '3 days',
  end_offset => INTERVAL '1 hour',
  schedule_interval => INTERVAL '1 hour');
```

#### PG_Stat_Statements

This extension provides execution statistics for all SQL statements executed by the server.

**Key Features**

- Query performance tracking
- Identification of slow queries
- Resource usage statistics
- Query optimization opportunities

**Setup and Usage**

```sql
CREATE EXTENSION pg_stat_statements;

-- Configure in postgresql.conf
-- pg_stat_statements.track = all
-- pg_stat_statements.max = 10000

-- Query for top resource-consuming queries
SELECT
  query,
  calls,
  total_exec_time / 1000 AS total_exec_time_s,
  (total_exec_time / calls) / 1000 AS avg_exec_time_s,
  rows / calls AS avg_rows,
  100 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;
```

#### Citus

Citus extends PostgreSQL for distributed processing, enabling horizontal scaling for real-time analytics.

**Key Features**

- Distributed query processing
- Table sharding across multiple nodes
- Parallel query execution
- Real-time aggregation and rollups
- Support for both transactional and analytical workloads

**Setup Example**

```sql
-- On coordinator node
CREATE EXTENSION citus;

-- Create distributed table
CREATE TABLE events (
  event_id bigint,
  tenant_id int,
  event_time timestamp with time zone,
  event_type text,
  payload jsonb
);

-- Distribute by tenant_id
SELECT create_distributed_table('events', 'tenant_id');

-- Distributed real-time aggregation query
SELECT 
  tenant_id, 
  event_type, 
  date_trunc('hour', event_time) AS hour,
  count(*) AS event_count
FROM events
WHERE event_time >= NOW() - INTERVAL '24 hours'
GROUP BY tenant_id, event_type, hour
ORDER BY hour DESC, event_count DESC;
```

#### PostGIS

PostGIS adds support for geographic objects to PostgreSQL, enabling spatial analytics.

**Key Features**

- Spatial indexing for geographic data
- Geometric operations and calculations
- Support for GIS standards
- Spatial joins and aggregations

**Example Use Case: Real-Time Location Analytics**

```sql
CREATE EXTENSION postgis;

-- Track vehicle locations
CREATE TABLE vehicle_locations (
  vehicle_id integer,
  location_time timestamp with time zone,
  location geometry(Point, 4326),
  speed float,
  direction float
);

CREATE INDEX vehicle_locations_time_idx ON vehicle_locations (location_time);
CREATE INDEX vehicle_locations_gix ON vehicle_locations USING GIST (location);

-- Find vehicles near a point of interest in real-time
SELECT 
  vehicle_id, 
  ST_Distance(
    location, 
    ST_SetSRID(ST_MakePoint(-73.985130, 40.748817), 4326)
  ) AS distance_meters,
  speed
FROM vehicle_locations
WHERE 
  location_time > NOW() - INTERVAL '5 minutes'
  AND ST_DWithin(
    location,
    ST_SetSRID(ST_MakePoint(-73.985130, 40.748817), 4326),
    1000  -- 1000 meters radius
  )
ORDER BY distance_meters ASC;
```

### Real-Time Dashboarding and Visualization

#### Direct PostgreSQL Integrations

**Visualization Tools with Native PostgreSQL Support**

- Grafana
- Tableau
- Power BI
- Apache Superset
- Metabase
- Redash

**Example: Grafana PostgreSQL Dashboard Configuration**

```json
{
  "datasource": {
    "type": "postgres",
    "uid": "postgres_analytics"
  },
  "targets": [
    {
      "datasource": {
        "type": "postgres",
        "uid": "postgres_analytics"
      },
      "format": "time_series",
      "group": [],
      "metricColumn": "none",
      "rawQuery": true,
      "rawSql": "SELECT\n  time_bucket('5 minute', event_time) AS time,\n  event_type,\n  count(*) as event_count\nFROM events\nWHERE\n  $__timeFilter(event_time)\nGROUP BY 1, 2\nORDER BY 1",
      "refId": "A",
      "select": [
        [
          {
            "params": [
              "event_count"
            ],
            "type": "column"
          }
        ]
      ],
      "timeColumn": "time",
      "where": [
        {
          "name": "$__timeFilter",
          "params": [],
          "type": "macro"
        }
      ]
    }
  ],
  "options": {
    "legend": {
      "calcs": [],
      "displayMode": "list",
      "placement": "bottom",
      "showLegend": true
    },
    "tooltip": {
      "mode": "single",
      "sort": "none"
    }
  },
  "type": "timeseries"
}
```

#### Optimizing for Dashboard Queries

**Pre-aggregation Strategies**

- Materialized views for common dashboard metrics
- Scheduled refreshes aligned with dashboard needs
- Incremental refresh techniques

```sql
CREATE MATERIALIZED VIEW hourly_metrics AS
SELECT
  date_trunc('hour', event_time) AS hour,
  event_type,
  count(*) AS event_count,
  count(distinct user_id) AS unique_users,
  sum(amount) AS total_amount
FROM events
WHERE event_time > CURRENT_DATE - INTERVAL '30 days'
GROUP BY 1, 2;

CREATE UNIQUE INDEX hourly_metrics_hour_type_idx 
ON hourly_metrics (hour, event_type);

-- Refresh on a schedule
CREATE OR REPLACE FUNCTION refresh_dashboard_views()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY hourly_metrics;
END;
$$ LANGUAGE plpgsql;

SELECT cron.schedule('*/15 * * * *', 'SELECT refresh_dashboard_views()');
```

**Query Optimization Techniques**

- Parameterized queries for flexible filtering
- Time bucket functions for time-series grouping
- Result set limiting for faster response times
- Using CTEs to simplify complex dashboard queries

**Real-Time Aggregation Optimization**

```sql
-- Using window functions for efficient dashboarding
SELECT 
  date_trunc('hour', event_time) AS hour,
  event_type,
  count(*) AS events_count,
  sum(count(*)) OVER (PARTITION BY event_type ORDER BY date_trunc('hour', event_time)) AS running_total,
  avg(count(*)) OVER (PARTITION BY event_type ORDER BY date_trunc('hour', event_time) ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_average
FROM events
WHERE event_time >= NOW() - INTERVAL '24 hours'
GROUP BY 1, 2
ORDER BY 1 DESC, 2;
```

### Implementing Real-Time Data Pipelines

#### Change Data Capture (CDC) Pipelines

**Using Logical Decoding**

- Native PostgreSQL WAL decoding
- Stream changes to downstream systems
- Real-time ETL implementation

**Example: Debezium with PostgreSQL**

```json
{
  "name": "postgresql-connector",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "postgres",
    "database.port": "5432",
    "database.user": "postgres",
    "database.password": "postgres",
    "database.dbname": "analytics",
    "database.server.name": "postgres",
    "table.include.list": "public.events",
    "plugin.name": "pgoutput",
    "slot.name": "debezium",
    "publication.name": "dbz_publication"
  }
}
```

**Setting Up PostgreSQL for CDC**

```sql
-- Configure postgresql.conf
-- wal_level = logical
-- max_wal_senders = 10
-- max_replication_slots = 10

-- Create publication for CDC
CREATE PUBLICATION dbz_publication FOR TABLE events;

-- Create a replication slot
SELECT pg_create_logical_replication_slot('debezium', 'pgoutput');
```

#### Real-Time ETL Patterns

**Triggers for Transformation**

- Capturing changes with triggers
- Implementing business logic at data source
- Maintaining derived tables in real-time

```sql
CREATE OR REPLACE FUNCTION process_new_event()
RETURNS TRIGGER AS $$
BEGIN
  -- Extract fields and transform
  INSERT INTO event_metrics (
    event_date,
    event_type,
    customer_segment,
    event_count,
    revenue_impact
  )
  VALUES (
    date_trunc('day', NEW.event_time),
    NEW.event_type,
    (NEW.payload->>'customer_segment'),
    1,
    COALESCE((NEW.payload->>'amount')::numeric, 0)
  )
  ON CONFLICT (event_date, event_type, customer_segment)
  DO UPDATE SET
    event_count = event_metrics.event_count + 1,
    revenue_impact = event_metrics.revenue_impact + COALESCE((NEW.payload->>'amount')::numeric, 0);
    
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER event_processing_trigger
AFTER INSERT ON events
FOR EACH ROW
EXECUTE FUNCTION process_new_event();
```

**Background Worker Processes**

- Custom background workers for processing
- Batch update optimization
- Reduced contention with main workload

```c
// Example in C for PostgreSQL extension
#include "postgres.h"
#include "postmaster/bgworker.h"
#include "storage/ipc.h"
#include "storage/latch.h"
#include "storage/proc.h"
#include "executor/spi.h"

/* Function executed by background worker */
void analytics_worker_main(Datum arg) {
    /* Setup signal handling */
    /* Connect to database */
    /* Main processing loop */
    while (!got_shutdown) {
        /* Process batch of events */
        SPI_connect();
        SPI_execute("WITH new_events AS (\n"
                    "    SELECT * FROM events\n"
                    "    WHERE processed = false\n"
                    "    LIMIT 1000\n"
                    "    FOR UPDATE SKIP LOCKED\n"
                    "), processed AS (\n"
                    "    UPDATE events SET processed = true\n"
                    "    WHERE id IN (SELECT id FROM new_events)\n"
                    "    RETURNING *\n"
                    ")\n"
                    "INSERT INTO event_aggregates\n"
                    "SELECT\n"
                    "    date_trunc('minute', event_time),\n"
                    "    event_type,\n"
                    "    count(*)\n"
                    "FROM processed\n"
                    "GROUP BY 1, 2\n"
                    "ON CONFLICT (minute, event_type)\n"
                    "DO UPDATE SET\n"
                    "    event_count = event_aggregates.event_count + EXCLUDED.event_count;",
                    false, 0);
        SPI_finish();
        
        /* Sleep if no events to process */
        WaitLatch(&MyProc->procLatch, WL_LATCH_SET | WL_TIMEOUT, 1000L);
    }
}
```

#### Streaming Integration Patterns

**PostgreSQL with Kafka**

- Kafka Connect for CDC streams
- KSQL for stream processing
- Real-time materialized views

**Example: Kafka Streams Processing of PostgreSQL Events**

```java
// Java example using Kafka Streams
StreamsBuilder builder = new StreamsBuilder();
KStream<String, JsonNode> events = builder.stream("postgres.public.events");

// Real-time aggregation
KTable<Windowed<String>, Long> eventCounts = events
    .groupBy((key, event) -> event.get("event_type").asText())
    .windowedBy(TimeWindows.of(Duration.ofMinutes(5)))
    .count();

// Push results back to PostgreSQL via JDBC sink
eventCounts.toStream().foreach((windowedKey, count) -> {
    String eventType = windowedKey.key();
    long windowStart = windowedKey.window().start();
    
    try (Connection conn = DriverManager.getConnection(jdbcUrl, user, password)) {
        PreparedStatement stmt = conn.prepareStatement(
            "INSERT INTO event_counts (window_start, event_type, count) " +
            "VALUES (?, ?, ?) " +
            "ON CONFLICT (window_start, event_type) " +
            "DO UPDATE SET count = ?");
        
        stmt.setTimestamp(1, new Timestamp(windowStart));
        stmt.setString(2, eventType);
        stmt.setLong(3, count);
        stmt.setLong(4, count);
        stmt.executeUpdate();
    } catch (SQLException e) {
        // Error handling
    }
});
```

### Advanced Real-Time Analytics Techniques

#### Time-Series Analysis

**Moving Averages and Trends**

```sql
-- Calculate moving averages
SELECT 
  time_bucket('1 hour', event_time) AS hour,
  event_type,
  count(*) AS events,
  avg(count(*)) OVER (
    PARTITION BY event_type 
    ORDER BY time_bucket('1 hour', event_time) 
    ROWS BETWEEN 23 PRECEDING AND CURRENT ROW
  ) AS moving_avg_24h
FROM events
WHERE event_time >= NOW() - INTERVAL '7 days'
GROUP BY 1, 2
ORDER BY 1 DESC, 2;
```

**Anomaly Detection**

```sql
-- Z-score based anomaly detection
WITH hourly_stats AS (
  SELECT
    time_bucket('1 hour', event_time) AS hour,
    count(*) AS event_count
  FROM events
  WHERE event_time >= NOW() - INTERVAL '7 days'
  GROUP BY 1
),
stats AS (
  SELECT
    avg(event_count) AS mean,
    stddev(event_count) AS stddev
  FROM hourly_stats
)
SELECT
  hour,
  event_count,
  (event_count - mean) / NULLIF(stddev, 0) AS z_score
FROM hourly_stats, stats
WHERE ABS((event_count - mean) / NULLIF(stddev, 0)) > 3 -- Threshold for anomalies
ORDER BY hour DESC;
```

**Seasonal Decomposition**

```sql
-- Extracting seasonality components
WITH daily_data AS (
  SELECT
    date_trunc('day', event_time) AS day,
    extract(dow from event_time) AS day_of_week,
    count(*) AS events
  FROM events
  WHERE event_time >= NOW() - INTERVAL '90 days'
  GROUP BY 1, 2
)
SELECT
  day,
  events,
  avg(events) OVER (
    PARTITION BY day_of_week
    ORDER BY day
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS seasonal_component,
  events - avg(events) OVER (
    PARTITION BY day_of_week
    ORDER BY day
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS residual
FROM daily_data
ORDER BY day DESC;
```

#### Real-Time Machine Learning

**Feature Engineering in PostgreSQL**

```sql
-- Create features for machine learning
CREATE MATERIALIZED VIEW user_features AS
SELECT
  user_id,
  count(*) AS event_count,
  count(DISTINCT session_id) AS session_count,
  max(event_time) AS last_activity,
  NOW() - max(event_time) AS time_since_last_activity,
  sum(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
  sum(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS view_count,
  sum(CASE WHEN payment_amount > 0 THEN payment_amount ELSE 0 END) AS total_spent,
  -- Recency features
  sum(CASE WHEN event_time > NOW() - INTERVAL '24 hours' THEN 1 ELSE 0 END) AS events_last_24h,
  -- Ratio features
  CASE WHEN sum(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) > 0 
       THEN sum(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END)::float / 
            sum(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) 
       ELSE 0 END AS conversion_rate
FROM events
WHERE event_time >= NOW() - INTERVAL '90 days'
GROUP BY user_id;

-- Refresh periodically
CREATE OR REPLACE FUNCTION refresh_ml_features()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY user_features;
END;
$$ LANGUAGE plpgsql;

SELECT cron.schedule('0 */3 * * *', 'SELECT refresh_ml_features()');
```

**MADlib Integration for In-Database ML**

```sql
-- Install MADlib
CREATE EXTENSION madlib;

-- Train a classification model
SELECT madlib.logistic_regression(
  'user_features',                             -- source table
  'user_conversion_model',                     -- output table
  'converted',                                 -- dependent variable
  'ARRAY[1, event_count, session_count, purchase_count, view_count, 
         total_spent, events_last_24h, conversion_rate]',  -- features
  NULL,                                        -- grouping columns
  20,                                          -- max iterations
  'irls'                                       -- optimizer
);

-- Make predictions
SELECT
  user_id,
  madlib.logregr_predict(
    ARRAY[1, event_count, session_count, purchase_count, view_count, 
          total_spent, events_last_24h, conversion_rate],
    coef
  ) AS conversion_probability
FROM user_features, user_conversion_model
WHERE time_since_last_activity < INTERVAL '30 days'
ORDER BY conversion_probability DESC;
```

**Real-Time Scoring with Triggers**

```sql
-- Automatically score users when new events occur
CREATE OR REPLACE FUNCTION score_user_activity()
RETURNS TRIGGER AS $$
BEGIN
  -- Update user features
  INSERT INTO user_features AS uf (
    user_id, 
    event_count,
    last_activity,
    time_since_last_activity
  )
  VALUES (
    NEW.user_id,
    1,
    NEW.event_time,
    NOW() - NEW.event_time
  )
  ON CONFLICT (user_id)
  DO UPDATE SET
    event_count = uf.event_count + 1,
    last_activity = GREATEST(uf.last_activity, NEW.event_time),
    time_since_last_activity = NOW() - GREATEST(uf.last_activity, NEW.event_time);
    
  -- Calculate risk score
  INSERT INTO user_risk_scores (
    user_id,
    calculated_at,
    risk_score
  )
  SELECT
    NEW.user_id,
    NOW(),
    madlib.logregr_predict(
      -- Create feature array from updated features
      ARRAY[1, uf.event_count, uf.session_count, uf.purchase_count, 
            uf.view_count, uf.total_spent, uf.events_last_24h, 
            uf.conversion_rate],
      m.coef
    )
  FROM user_features uf, user_conversion_model m
  WHERE uf.user_id = NEW.user_id
  ON CONFLICT (user_id)
  DO UPDATE SET
    calculated_at = NOW(),
    risk_score = EXCLUDED.risk_score;
  
  RETURN NULL; -- Trigger is AFTER, so return value is ignored
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER score_user_on_event
AFTER INSERT ON events
FOR EACH ROW
WHEN (NEW.user_id IS NOT NULL)
EXECUTE FUNCTION score_user_activity();
```

#### Geospatial Analytics

**Real-Time Location Clustering**

```sql
-- Find location clusters in real-time
WITH recent_locations AS (
  SELECT
    location
  FROM user_locations
  WHERE timestamp > NOW() - INTERVAL '5 minutes'
)
SELECT
  ST_ClusterDBSCAN(location, eps := 100, minpoints := 5) OVER () AS cluster_id,
  ST_Centroid(ST_Collect(location)) AS cluster_center,
  count(*) AS point_count
FROM recent_locations
GROUP BY cluster_id
HAVING count(*) > 5
ORDER BY point_count DESC;
```

**Geofencing and Proximity Alerts**

```sql
-- Create geofence alert for users entering a defined area
WITH geofence AS (
  SELECT ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
    'LINESTRING(
      120.9800 14.6000,
      120.9900 14.6000,
      120.9900 14.6100,
      120.9800 14.6100,
      120.9800 14.6000
    )')), 4326) AS area
),
recent_locations AS (
  SELECT user_id, location
  FROM user_locations
  WHERE timestamp > NOW() - INTERVAL '1 minute'
)
SELECT
  rl.user_id,
  rl.location,
  g.area AS geofence_area
FROM recent_locations rl
JOIN geofence g
  ON ST_Contains(g.area, rl.location);
```

---


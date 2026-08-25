## Primary Key Design


### Partition Key Selection Strategies

The partition key determines how data is distributed across nodes in a Cassandra cluster and directly impacts query performance, data distribution, and cluster scalability. Effective partition key selection requires balancing several competing factors.

**Cardinality considerations** form the foundation of partition key design. High cardinality keys with many unique values distribute data more evenly across nodes, preventing hotspots where a few nodes handle disproportionate traffic. Low cardinality keys can create uneven distribution, causing some nodes to become bottlenecks while others remain underutilized.

**Query patterns** must align with partition key choices since Cassandra performs most efficiently when queries include the full partition key. Applications that frequently query by user ID benefit from using user ID as the partition key, while time-series data often uses date or time-based partition keys to support range queries.

**Data access frequency** influences partition key design through the need to avoid hot partitions. Keys that concentrate recent or popular data into single partitions can overwhelm specific nodes. Distributing frequently accessed data across multiple partitions through techniques like bucketing helps maintain balanced load distribution.

**Bucketing strategies** address scenarios where natural partition keys create uneven distribution. Adding artificial elements like hash values or date components to partition keys can improve distribution. For example, combining user ID with a hash bucket creates more partitions while maintaining query efficiency.

### Clustering Columns and Sort Order

Clustering columns define the sort order of data within partitions and enable efficient range queries and filtering operations. Their design significantly impacts query performance and storage efficiency.

**Sort order determination** occurs at table creation time and cannot be changed without recreating the table. Clustering columns sort data in ascending or descending order, with the first clustering column having the highest priority. Multiple clustering columns create hierarchical sorting similar to SQL ORDER BY clauses with multiple columns.

**Range query optimization** relies heavily on clustering column design. Queries that filter or sort by clustering columns can leverage the pre-sorted storage layout, avoiding expensive sorting operations at query time. Time-series data benefits from timestamp clustering columns that enable efficient time range queries.

**Filtering capabilities** expand when clustering columns align with common query patterns. Cassandra can efficiently filter on clustering column prefixes, meaning queries can include conditions on the first clustering column, or the first and second together, but cannot skip clustering columns in filter conditions.

**Storage efficiency** improves when clustering columns group related data together. Similar values in clustering columns compress better, and range scans read fewer storage blocks when target data is clustered. This physical data locality translates directly to improved query performance.

### Composite Partition Keys

Composite partition keys combine multiple columns to create more granular data distribution and support complex query patterns that require multiple key components.

**Multi-column combinations** enable partition keys that incorporate several data attributes. A composite key might combine tenant ID with date, allowing queries that specify both values while distributing data across multiple partitions per tenant and date combination.

**Distribution benefits** emerge when composite keys create more partition combinations than single-column keys. Instead of having one partition per user, a composite key of user ID and month creates twelve partitions per user annually, improving parallelism and reducing individual partition sizes.

**Query pattern support** expands with composite keys that match application access patterns. Applications that consistently query by multiple attributes benefit when those attributes form the composite partition key, eliminating the need for secondary indexes or filtering operations.

**Granularity control** becomes possible through composite key design choices. Fine-grained composite keys create many small partitions, while coarse-grained keys create fewer larger partitions. The optimal granularity depends on data size, query patterns, and cluster characteristics.

### Wide vs Skinny Partitions

The partition width spectrum ranges from skinny partitions containing few rows to wide partitions containing millions of rows. Each approach suits different use cases and has distinct performance characteristics.

**Wide partition advantages** include reduced metadata overhead since partition-level metadata is shared across many rows. Wide partitions also enable efficient range queries across large datasets and can improve compression ratios when similar data is stored together. Time-series applications often benefit from wide partitions that group related measurements.

**Wide partition challenges** include potential memory pressure during queries that access entire partitions. Very wide partitions can cause garbage collection issues and may overwhelm client applications. Repair operations and streaming can become resource-intensive with extremely wide partitions.

**Skinny partition benefits** encompass predictable memory usage and more granular distribution across cluster nodes. Skinny partitions often align well with entity-based access patterns where applications retrieve complete records. They also simplify capacity planning since partition sizes remain relatively constant.

**Skinny partition drawbacks** include increased metadata overhead and potentially less efficient range queries that span multiple partitions. Applications requiring aggregations or analytics across related data may perform poorly with overly skinny partition designs.

**Optimal width determination** [Inference] typically involves analyzing query patterns, data growth rates, and performance requirements. Partitions containing thousands to hundreds of thousands of rows often provide good balance, though specific applications may benefit from different approaches.

### Primary Key Uniqueness Rules

Cassandra enforces uniqueness at the primary key level, combining partition key and clustering columns to create unique row identifiers with specific insertion and update behaviors.

**Uniqueness scope** applies to the complete primary key, including all partition key columns and clustering columns. Two rows with identical primary keys cannot coexist, with later insertions overwriting earlier data. This differs from traditional relational databases where uniqueness constraints can apply to arbitrary column combinations.

**Upsert behavior** occurs automatically when inserting data with existing primary keys. Cassandra treats all writes as upserts, updating existing rows or creating new ones based on primary key existence. This eliminates the need for explicit UPDATE statements in many scenarios but requires careful consideration of data modeling.

**Null handling** follows specific rules where clustering columns can contain null values, but null values affect sorting and comparison operations. Null values sort before non-null values, and queries must account for null handling in filtering conditions.

**Tombstone creation** happens when deleting specific columns rather than entire rows. Understanding primary key uniqueness helps predict when deletions create tombstones versus removing entire rows, impacting storage efficiency and query performance.

**Data modeling implications** require designing primary keys that naturally ensure uniqueness for the application domain. Applications needing multiple unique identifiers may require separate tables or additional data modeling techniques since Cassandra supports only one primary key per table.

**Key points:**
- Partition key selection balances distribution, query patterns, and access frequency
- Clustering columns enable efficient sorting and range queries within partitions  
- Composite partition keys provide finer distribution control and support complex query patterns
- Wide partitions optimize for range queries while skinny partitions provide predictable performance
- Primary key uniqueness enables automatic upsert behavior but limits flexible uniqueness constraints

---


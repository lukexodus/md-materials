## Amazon DynamoDB


Amazon DynamoDB is a fully managed NoSQL database service that provides fast and predictable performance with seamless scalability. DynamoDB supports key-value and document data structures and is designed to handle any level of request traffic while maintaining consistent single-digit millisecond response times.

### Data Model and Access Patterns

DynamoDB organizes data in tables, items, and attributes. Tables serve as collections of items, items represent individual data records, and attributes are data elements within items. The service supports nested attributes up to 32 levels deep and various data types including strings, numbers, binary data, sets, lists, and maps.

Primary keys uniquely identify items in tables and can be simple (partition key only) or composite (partition key and sort key). The partition key determines the physical location where data is stored, while sort keys enable range queries and provide additional organization within partitions.

Access patterns should be designed around DynamoDB's strengths in handling predictable query patterns. The service excels at single-item lookups, range queries within partitions, and scan operations across tables. Complex relational queries requiring joins across multiple tables are not optimal for DynamoDB's architecture.

### Performance and Scaling

DynamoDB provides two capacity modes: on-demand and provisioned. On-demand mode automatically scales read and write capacity based on traffic patterns without capacity planning. Provisioned mode requires specifying read and write capacity units but offers more cost control for predictable workloads.

Auto Scaling can automatically adjust provisioned capacity based on traffic patterns, maintaining target utilization while minimizing costs. DynamoDB also supports burst capacity to accommodate temporary traffic spikes above provisioned levels.

Global Secondary Indexes enable queries on non-primary key attributes, while Local Secondary Indexes provide alternative sort key options within the same partition. These indexes are automatically maintained and provide their own scaling capabilities.

### Advanced Features

DynamoDB Streams capture data modification events in tables, enabling real-time processing of changes through AWS Lambda functions or other consumers. Streams record item-level modifications with before and after images of changed items.

Global Tables provide multi-region, multi-master replication for globally distributed applications. Changes made in any region are automatically replicated to all other regions, typically within seconds. This capability supports disaster recovery and improves read performance for global user bases.

DynamoDB Accelerator (DAX) provides in-memory caching that reduces response times from milliseconds to microseconds. DAX is fully managed and compatible with existing DynamoDB API calls, requiring minimal application changes to implement.


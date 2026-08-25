## Azure Stream Analytics


Azure Stream Analytics processes real-time streaming data from multiple sources with low-latency analytics capabilities.

**Key points:**

- Serverless real-time analytics engine with automatic scaling
- SQL-based query language for stream processing logic
- Built-in temporal functions for windowing and aggregation operations
- Integration with Azure Event Hubs, IoT Hub, and Blob Storage
- Machine learning function integration for anomaly detection
- Guaranteed event delivery with exactly-once processing semantics
- Visual query editor and testing capabilities with sample data

**Stream processing concepts:**

- **Input Sources**: Event Hubs, IoT Hub, Blob Storage, Data Lake Storage
- **Query Logic**: SQL-based transformations, joins, and aggregations
- **Output Sinks**: SQL Database, Cosmos DB, Event Hubs, Power BI, Data Lake
- **Windowing Functions**: Tumbling, hopping, sliding, and session windows
- **Reference Data**: Static lookup data for enriching streaming events

**Performance considerations:**

- Streaming Units (SUs) determine processing throughput and cost
- Partitioning strategies affect parallelization and performance
- Query complexity impacts latency and resource requirements


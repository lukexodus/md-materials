## Amazon Kinesis


Kinesis provides real-time data streaming capabilities for ingesting, processing, and analyzing streaming data at scale. It enables applications to respond to data as it arrives rather than waiting for batch processing completion.

**Kinesis Data Streams** Kinesis Data Streams captures and stores streaming data in shards, which are sequences of data records ordered by arrival time. Each shard can ingest up to 1,000 records per second or 1 MB per second and support up to 2 MB per second of read throughput. Applications write data using partition keys that determine which shard receives each record. Consumer applications can process data using the Kinesis Client Library, which handles shard assignment, checkpointing, and load balancing across multiple consumers.

**Kinesis Data Firehose** Kinesis Data Firehose provides managed delivery of streaming data to AWS destinations including S3, Redshift, Elasticsearch Service, and Splunk. It automatically scales to match data throughput and can transform data using Lambda functions before delivery. Firehose buffers data based on size or time intervals, compresses data for cost optimization, and encrypts data in transit and at rest. Error records are delivered to separate S3 buckets for debugging and reprocessing.

**Kinesis Data Analytics** Kinesis Data Analytics enables real-time analysis of streaming data using SQL queries or Apache Flink applications. SQL-based applications can perform windowed aggregations, pattern detection, and anomaly identification on streaming data. Flink applications support complex event processing, machine learning inference, and stateful stream processing. Applications automatically scale based on data volume and complexity of processing logic.

**Integration Patterns** Kinesis integrates with numerous AWS services for comprehensive streaming architectures. Lambda functions can process Kinesis records for real-time transformations and actions. Kinesis Analytics can trigger alerts through SNS or store results in DynamoDB. CloudWatch provides monitoring and alerting for stream health and performance metrics.


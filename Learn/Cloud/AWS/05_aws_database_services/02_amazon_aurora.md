## Amazon Aurora


Amazon Aurora is a MySQL and PostgreSQL-compatible relational database built for the cloud, combining the performance and availability of traditional enterprise databases with the simplicity and cost-effectiveness of open source databases. Aurora provides up to five times better performance than standard MySQL databases and three times better than standard PostgreSQL databases.

### Architecture and Performance

Aurora separates compute and storage, with a shared-nothing architecture that enables automatic scaling of storage from 10GB to 128TB without performance impact. The storage layer automatically replicates data six ways across three Availability Zones, providing high durability and availability without manual intervention.

The service implements continuous backup to Amazon S3, with point-in-time recovery capabilities. Aurora automatically detects database crashes and restarts without requiring crash recovery or database cache rebuilding. The buffer cache remains warm across database restarts, reducing recovery time significantly.

### Aurora Serverless

Aurora Serverless provides on-demand, auto-scaling configuration for Aurora databases that automatically starts up, shuts down, and scales capacity based on application needs. This option eliminates the need to manage database capacity and provides cost optimization for infrequent, intermittent, or unpredictable workloads.

The service automatically scales compute capacity from fractions of a CPU to thousands of CPUs within seconds. Applications connect through a proxy fleet that manages the connection pooling and scaling decisions. Aurora Serverless v2 provides more granular scaling and faster scaling responses compared to the original version.

### Global Database

Aurora Global Database enables a single Aurora database to span multiple AWS regions, providing low-latency global reads and disaster recovery from region-wide outages. Global databases replicate data with typical latency of less than 1 second across regions.

Secondary regions support up to 16 read replicas, and in case of database degradation or outage in the primary region, one of the secondary regions can be promoted to full read/write capabilities in less than 1 minute. This capability supports globally distributed applications requiring low-latency access to data.


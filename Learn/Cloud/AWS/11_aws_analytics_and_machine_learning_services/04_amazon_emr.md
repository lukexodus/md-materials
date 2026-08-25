## Amazon EMR


EMR provides managed Hadoop framework for processing large amounts of data across dynamically scalable EC2 instances. It supports multiple big data frameworks and enables cost-effective processing of petabyte-scale datasets.

**Supported Frameworks** EMR supports Apache Hadoop ecosystem tools including Spark, Hive, HBase, Presto, Flink, and Hudi. Spark provides fast in-memory processing for iterative algorithms and interactive queries. Hive enables SQL-like queries on large datasets stored in HDFS or S3. HBase provides NoSQL database capabilities for real-time read/write access. Jupyter and Zeppelin notebooks support interactive data science workflows.

**Cluster Architecture and Scaling** EMR clusters consist of master nodes that coordinate jobs and manage cluster state, core nodes that run tasks and store data in HDFS, and optional task nodes that provide additional compute capacity. Auto Scaling adjusts cluster size based on workload demands and custom metrics. Spot instances can reduce costs significantly for fault-tolerant workloads. Multiple master nodes provide high availability for long-running clusters.

**Storage Options** EMR supports multiple storage options including HDFS for temporary processing, S3 for persistent storage, and EBS for additional local storage. EMRFS optimizes S3 access with features like consistent view, retry logic, and multipart uploads. Data can be partitioned and stored in optimized formats like Parquet for improved query performance.

**Serverless EMR** EMR Serverless removes the need to configure, optimize, secure, or operate clusters. Applications automatically scale resources based on workload requirements. Pre-initialized compute resources reduce job startup times. Integrated with other AWS services for seamless data pipeline integration.


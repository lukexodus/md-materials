## HDInsight


HDInsight provides managed open-source analytics services including Apache Hadoop, Spark, HBase, and Kafka on Azure infrastructure.

**Key points:**

- Fully managed cluster services with automatic patching and scaling
- Support for multiple open-source frameworks and versions
- Enterprise security with Azure Active Directory integration
- Virtual network integration for secure connectivity
- Storage flexibility with Azure Storage and Data Lake Storage
- Monitoring integration with Azure Monitor and Ambari
- Custom script actions for cluster customization

**Supported cluster types:**

- **Apache Hadoop**: Distributed storage and processing with MapReduce
- **Apache Spark**: In-memory analytics for iterative algorithms
- **Apache HBase**: NoSQL database for real-time read/write access
- **Apache Kafka**: Distributed streaming platform for data pipelines
- **Apache Storm**: Real-time stream processing system
- **Interactive Query (LLAP)**: Interactive SQL queries on Hadoop data

**Cluster management:**

- Automatic scaling based on workload demands
- Script actions for software installation and configuration
- SSH access for direct cluster administration
- Jupyter and Zeppelin notebook integration

**Architecture patterns:** Common data and analytics architectures combine these services for comprehensive solutions:

- **Lambda Architecture**: Combines batch processing (Data Factory, Databricks) with stream processing (Stream Analytics) for comprehensive data processing
- **Data Lake Architecture**: Uses Data Lake Storage as central repository with various processing engines
- **Modern Data Warehouse**: Integrates data ingestion, processing, and visualization services
- **Real-time Analytics**: Combines streaming ingestion with immediate processing and visualization

**Important related topics:** Azure Synapse Analytics (combines many of these services), Azure Data Lake Storage (foundational storage service), Azure Cosmos DB (multi-model database service), Azure Machine Learning (ML platform integration).

---


## Azure Data Factory


Azure Data Factory (ADF) serves as the cloud-based data integration service for orchestrating and automating data movement and transformation workflows.

**Key points:**

- Hybrid data integration supporting 90+ data connectors including on-premises, cloud, and SaaS sources
- Code-free visual interface with drag-and-drop pipeline creation
- Built-in monitoring and alerting capabilities for pipeline execution
- Integration Runtime enables secure data movement across network environments
- Mapping Data Flows provides visual data transformation without coding
- Control Flow activities enable conditional logic, looping, and branching in pipelines
- Git integration supports version control and collaborative development

**Architecture components:**

- **Pipelines**: Logical grouping of activities that perform data processing tasks
- **Activities**: Processing steps within pipelines (copy, transform, control flow)
- **Datasets**: Named views of data pointing to source and destination systems
- **Linked Services**: Connection strings defining connection information to data stores
- **Integration Runtime**: Compute infrastructure for data integration capabilities
- **Triggers**: Execution mechanisms for pipelines (schedule, tumbling window, event-based)

**Common use cases:**

- ETL/ELT pipeline orchestration
- Data lake ingestion from multiple sources
- Database migration and synchronization
- Real-time data streaming integration
- Hybrid cloud data movement


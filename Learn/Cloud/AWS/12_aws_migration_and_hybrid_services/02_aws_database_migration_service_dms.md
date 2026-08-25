## AWS Database Migration Service (DMS)


DMS enables database migrations with minimal downtime, supporting homogeneous and heterogeneous database migrations while maintaining source database availability during the migration process.

### Migration Types

**Homogeneous Migrations:** Same database engine migrations (Oracle to Oracle, MySQL to MySQL) with schema structure preservation and data type compatibility.

**Heterogeneous Migrations:** Different database engine migrations requiring schema conversion using AWS Schema Conversion Tool (SCT).

**Common Migration Patterns:**

- Oracle to Amazon RDS for PostgreSQL
- SQL Server to Amazon Aurora MySQL
- MySQL to Amazon DynamoDB
- On-premises databases to managed AWS database services

### Migration Approaches

**One-Time Migration:** Complete database transfer with brief downtime window for cutover **Continuous Replication:** Ongoing data synchronization for disaster recovery or read replicas **Change Data Capture (CDC):** Real-time data replication maintaining source and target synchronization

### Schema Conversion Tool (SCT)

SCT automatically converts database schemas and application code from source to target database engines.

**Conversion Capabilities:**

- Database schema objects (tables, indexes, views, procedures)
- Application code conversion recommendations
- Assessment reports identifying conversion complexity
- Data warehouse schema conversion for analytics workloads

**Supported Conversions:**

- Oracle to PostgreSQL/MySQL/Amazon Aurora
- SQL Server to PostgreSQL/MySQL/Amazon Aurora
- Teradata/IBM Netezza to Amazon Redshift


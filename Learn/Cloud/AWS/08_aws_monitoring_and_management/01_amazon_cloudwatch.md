## Amazon CloudWatch


CloudWatch serves as AWS's native monitoring and observability platform, collecting and analyzing metrics, logs, and events from AWS resources and applications.

### Core Components

**Metrics:** Numerical data points representing system performance over time. AWS services automatically publish default metrics, while custom metrics can be published programmatically.

**Standard Metrics Include:**

- EC2: CPU utilization, network I/O, disk I/O
- RDS: Database connections, CPU utilization, free storage space
- S3: Number of objects, bucket size, request metrics
- Lambda: Invocations, duration, error count

**CloudWatch Logs:** Centralized log management system that ingests, stores, and analyzes log data from AWS services, applications, and on-premises systems.

**Log Features:**

- Real-time log streaming
- Log retention policies (indefinite to 1 day)
- Log insights for querying and analysis
- Metric filters to extract metrics from log data
- Export capabilities to S3 or other destinations

**CloudWatch Alarms:** Monitoring rules that trigger actions based on metric thresholds or anomaly detection.

**Alarm States:**

- OK: Metric within defined threshold
- ALARM: Metric breached threshold
- INSUFFICIENT_DATA: Not enough data to determine state

**CloudWatch Events/EventBridge:** Event-driven architecture service that responds to state changes in AWS resources.

### Advanced Features

**CloudWatch Insights:** Query and analyze log data using a SQL-like query language **CloudWatch Synthetics:** Automated testing of applications using configurable scripts **CloudWatch Container Insights:** Monitoring for containerized applications on ECS, EKS, and Fargate **CloudWatch Application Insights:** [Inference] Automated application monitoring with anomaly detection


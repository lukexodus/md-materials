## AWS Config Rules


AWS Config continuously monitors and evaluates AWS resource configurations against desired compliance rules and best practices.

### Configuration Management

**Configuration Items (CIs):** Point-in-time snapshots of resource configurations including relationships and metadata.

**Configuration Recorder:** Service that detects resource changes and creates configuration items **Delivery Channel:** Mechanism for delivering configuration snapshots and history files to S3

### Compliance Evaluation

**Config Rules Types:**

- **AWS Managed Rules:** Pre-built rules for common compliance requirements
- **Custom Rules:** Lambda-based rules for organization-specific requirements

**Evaluation Triggers:**

- Configuration changes
- Periodic evaluation
- On-demand evaluation

**Common Managed Rules:**

- Required tags on resources
- Security group compliance
- Encrypted EBS volumes
- Root access key usage
- S3 bucket public access

### Remediation

**Auto Remediation:** Automatic corrective actions using Systems Manager documents when rules detect non-compliance **Manual Remediation:** Guided remediation steps for manual correction **Compliance Timeline:** Historical view of resource compliance status changes

**Key Points:**

- Multi-account and multi-region aggregation capabilities
- Integration with AWS Organizations for centralized compliance management
- Conformance packs for deploying common compliance frameworks
- Query capabilities using SQL-like syntax for configuration data analysis

**Important Subtopics:** Consider exploring AWS Well-Architected Framework integration, advanced CloudWatch dashboard creation, Systems Manager maintenance windows configuration, and compliance automation strategies using Config Rules with Lambda functions for comprehensive operational excellence implementation.

---


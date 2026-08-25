## AWS Secrets Manager


Secrets Manager stores, retrieves, and rotates database credentials, API keys, and other secrets throughout their lifecycles. It provides fine-grained access control and automatic rotation capabilities to enhance security posture.

**Secret Types and Storage** Secrets Manager stores various secret types including database credentials, OAuth tokens, API keys, and arbitrary text or binary data. Secrets are encrypted at rest using AWS KMS customer-managed keys and in transit using TLS. Cross-region replication ensures high availability and disaster recovery capabilities.

**Automatic Rotation** Built-in rotation functions support automatic credential rotation for Amazon RDS, DocumentDB, and Redshift databases without application downtime. Custom Lambda functions enable rotation for other services and applications. Rotation schedules can be configured for specific intervals with immediate rotation capabilities for security incidents.

**Access Control and Auditing** Resource-based policies control which principals can access specific secrets with fine-grained permissions. VPC endpoints enable private network access without internet connectivity. CloudTrail logs all Secrets Manager API calls for audit and compliance purposes. Temporary access can be granted through cross-account roles with time-limited permissions.


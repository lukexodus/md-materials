## Shared Responsibility Model


The AWS Shared Responsibility Model defines the security responsibilities of AWS and its customers, creating a clear framework for understanding who is responsible for different aspects of cloud security. This model helps customers understand their security obligations when using AWS services.

AWS is responsible for "security of the cloud," which includes protecting the infrastructure that runs AWS services across all regions, edge locations, and Availability Zones. This encompasses the physical security of data centers, network controls, host operating system patching, and service configuration management. AWS also manages the security of managed services like Amazon RDS, Amazon DynamoDB, and AWS Lambda at the service level.

Customers are responsible for "security in the cloud," including managing guest operating systems, application-level controls, identity and access management, network traffic protection, and data encryption. The specific customer responsibilities vary depending on the AWS service being used and its configuration.

For Infrastructure as a Service offerings like Amazon EC2, customers have more responsibility, including operating system updates, security patches, and firewall configuration. For managed services, AWS handles more of the underlying security, but customers remain responsible for proper configuration and access management.

Data classification, encryption key management, network traffic protection, and identity and access management always remain customer responsibilities regardless of the service model. Understanding these responsibilities is crucial for maintaining a secure cloud environment.


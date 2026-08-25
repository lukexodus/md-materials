## AWS Outposts


Outposts brings native AWS services, infrastructure, and operating models to on-premises facilities, creating a hybrid cloud environment with consistent AWS experience.

### Infrastructure Options

**Outposts Racks:**

- 42U racks with AWS-designed hardware
- Multiple configuration options for compute and storage
- Redundant power and networking
- Starting configurations from 2 to 96 EC2 instances [Unverified - specific instance counts may vary]

**Outposts Servers:**

- 1U and 2U server options
- Individual servers for smaller deployments
- Same AWS APIs and tooling as cloud regions

### Service Availability

**Compute Services:**

- Amazon EC2 instances with same instance types as AWS regions
- Amazon EBS with gp2 and io1 volume types
- Amazon ECR for container image storage

**Database Services:**

- Amazon RDS on Outposts
- Amazon ElastiCache [Unverified - service availability may vary by configuration]

**Analytics and Machine Learning:**

- Amazon EMR on Outposts
- Amazon SageMaker [Unverified - specific ML services availability]

### Connectivity and Management

**Network Connectivity:**

- Service link connection to AWS region (minimum 1 Gbps)
- Local gateway for on-premises connectivity
- VPC extension from AWS region to Outposts

**Management:**

- AWS Systems Manager for infrastructure management
- CloudFormation for infrastructure as code
- Same IAM policies and security models as AWS regions


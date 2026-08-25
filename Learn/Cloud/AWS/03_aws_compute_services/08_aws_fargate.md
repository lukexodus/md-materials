## AWS Fargate


Fargate provides serverless compute for containers, removing the need to provision, configure, or scale EC2 instances. It works with both ECS and EKS to run containers without server management.

**Resource Allocation** Fargate tasks specify exact CPU and memory requirements from predefined combinations. Resources are allocated per task, ensuring isolation and predictable performance. Pricing is based on requested CPU and memory resources and duration of task execution.

**Integration Capabilities** Fargate integrates with AWS services including VPC networking, security groups, IAM roles, and CloudWatch monitoring. It supports both Linux and Windows containers with various runtime configurations. Tasks can mount EFS file systems for persistent storage.


## Amazon EC2 (Elastic Compute Cloud)


Amazon EC2 provides resizable compute capacity in the cloud through virtual servers called instances. Each instance runs on physical hardware managed by AWS, allowing users to launch and terminate instances as needed.

**Instance Types and Families** EC2 instances are categorized into families optimized for different use cases. General purpose instances (A1, T2, T3, T4g, M5, M6i) balance compute, memory, and networking resources. Compute optimized instances (C5, C6i, C7g) deliver high-performance processors for CPU-intensive applications. Memory optimized instances (R5, R6g, X1, z1d) provide large amounts of RAM for in-memory databases and analytics. Storage optimized instances (D2, D3, H1, I3) offer high sequential read/write access to large datasets. Accelerated computing instances (P3, P4, G4, F1) include hardware accelerators like GPUs for machine learning and high-performance computing.

**Amazon Machine Images (AMIs)** AMIs serve as templates containing the operating system, application server, and applications needed to launch an instance. AWS provides pre-configured AMIs for popular operating systems including Amazon Linux, Ubuntu, Windows Server, Red Hat Enterprise Linux, and SUSE Linux. Users can create custom AMIs from configured instances, enabling consistent deployments across environments. AMIs can be shared across AWS accounts or made publicly available through the AWS Marketplace.

**Security Groups** Security groups act as virtual firewalls controlling inbound and outbound traffic to instances. They operate at the instance level and use allow rules only - there are no deny rules. Each security group rule specifies the protocol, port range, and source (for inbound rules) or destination (for outbound rules). Sources and destinations can be IP addresses, CIDR blocks, or other security groups. Multiple security groups can be assigned to a single instance, with rules being evaluated collectively.


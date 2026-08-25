## Amazon EBS (Elastic Block Store)


EBS provides persistent, high-performance block storage volumes for EC2 instances, designed for workloads requiring consistent, low-latency performance.

### Volume Types

**General Purpose SSD (gp3/gp2):**

- gp3: Latest generation with customizable IOPS and throughput
- gp2: IOPS performance scales with volume size
- Use cases: Boot volumes, development environments, low-latency applications

**Provisioned IOPS SSD (io2/io1):**

- io2: Higher durability and IOPS per volume ratios
- io1: Previous generation provisioned IOPS
- Use cases: Critical business applications, databases requiring high IOPS

**Throughput Optimized HDD (st1):**

- Low-cost storage for frequently accessed, sequential workloads
- Use cases: Big data, data warehouses, log processing

**Cold HDD (sc1):**

- Lowest cost storage for infrequently accessed workloads
- Use cases: File servers, backup storage

### EBS Features

**Snapshots:** Point-in-time backups stored in S3, enabling volume restoration and cross-region copying **Encryption:** AES-256 encryption at rest and in transit using AWS KMS **Multi-Attach:** [Inference] Certain volume types can attach to multiple instances simultaneously **Elastic Volumes:** Modify volume size, IOPS, and volume type without downtime


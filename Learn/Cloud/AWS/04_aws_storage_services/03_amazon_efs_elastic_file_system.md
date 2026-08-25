## Amazon EFS (Elastic File System)


EFS provides fully managed, scalable NFS file systems that can be concurrently accessed by multiple EC2 instances across multiple availability zones.

### EFS Characteristics

**Scalability:** Automatically scales from gigabytes to petabytes without provisioning **Performance Modes:**

- General Purpose: Lowest latency per operation
- Max I/O: Higher levels of aggregate throughput and IOPS

**Throughput Modes:**

- Bursting: Throughput scales with file system size
- Provisioned: Specify throughput independent of storage size

**Storage Classes:**

- Standard: For frequently accessed files
- Infrequent Access (IA): Lower cost for files accessed less frequently


## AWS Snowball Family


The Snowball family provides physical data transfer devices for scenarios where network transfer is impractical due to bandwidth limitations, time constraints, or cost considerations.

### Device Types

**Snowball Edge Storage Optimized:**

- 80 TB usable storage capacity
- 40 vCPUs and 80 GiB memory for edge computing
- 1 Gb and 10 Gb network interfaces
- Local processing capabilities with Lambda functions

**Snowball Edge Compute Optimized:**

- 42 TB usable storage capacity
- 52 vCPUs and 208 GiB memory
- Optional GPU for machine learning inference
- Enhanced compute capabilities for edge processing

**Snowmobile:**

- Exabyte-scale data transfer truck
- 100 PB storage capacity per vehicle
- Dedicated security team and GPS tracking
- [Inference] Suitable for data center relocations and massive archival projects

### Transfer Process

**Data Transfer Workflow:**

1. Job creation through AWS console with encryption keys
2. Device shipping to customer location
3. Local data loading using Snowball client
4. Device return to AWS facility
5. Data ingestion into specified AWS storage services

**Security Features:**

- 256-bit encryption with customer-managed keys
- Tamper-resistant enclosures
- End-to-end tracking and chain of custody
- Trusted Platform Module (TPM) for device integrity

